using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;

using CommonLib.DataAccess;
using CommonLib.MvcExtension;
using Newtonsoft.Json;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [Authorize]
    public class AccountingController : SampleController<UserProfile>
    {
        // GET: Accounting
        public ActionResult ReceivableIndex()
        {
            return View();
        }

        public ActionResult InquireAccountsReceivable(CourseContractQueryViewModel viewModel)
        {
            IQueryable<CourseContract> items = models.PromptAccountingContract();

            var profile = HttpContext.GetUser();

            Expression<Func<CourseContract, bool>> queryExpr = c => false;
            bool hasConditon = false;

            viewModel.RealName = viewModel.RealName.GetEfficientString();
            if (viewModel.RealName != null)
            {
                hasConditon = true;
                queryExpr = queryExpr.Or(c => c.CourseContractMember.Any(m => m.UserProfile.RealName.Contains(viewModel.RealName) || m.UserProfile.Nickname.Contains(viewModel.RealName)));
            }

            if (!hasConditon)
            {
                viewModel.ContractNo = viewModel.ContractNo.GetEfficientString();
                if (viewModel.ContractNo != null)
                {
                    hasConditon = true;
                    var no = viewModel.ContractNo.Split('-');
                    int seqNo;
                    if (no.Length > 1)
                    {
                        int.TryParse(no[1], out seqNo);
                        queryExpr = queryExpr.Or(c => c.ContractNo.StartsWith(no[0])
                            && c.SequenceNo == seqNo);
                    }
                    else
                    {
                        queryExpr = queryExpr.Or(c => c.ContractNo.StartsWith(viewModel.ContractNo));
                    }
                }
            }


            if (!hasConditon)
            {
                if (viewModel.FitnessConsultant.HasValue)
                {
                    hasConditon = true;
                    queryExpr = queryExpr.Or(c => c.FitnessConsultant == viewModel.FitnessConsultant);
                }
            }

            if (!hasConditon)
            {
                if (viewModel.BranchID.HasValue)
                {
                    hasConditon = true;
                    queryExpr = queryExpr.Or(c => c.CourseContractExtension.BranchID == viewModel.BranchID);
                }
            }

            if (!hasConditon)
            {
                if (profile.IsAssistant() || profile.IsAccounting() || profile.IsOfficer())
                {

                }
                else if (profile.IsManager() || profile.IsViceManager())
                {
                    var coaches = profile.GetServingCoachInSameStore(models);
                    items = items.Join(coaches, c => c.FitnessConsultant, h => h.CoachID, (c, h) => c);
                }
                else if (profile.IsCoach())
                {
                    items = items.Where(c => c.FitnessConsultant == profile.UID);
                }
            }

            if (hasConditon)
            {
                items = items.Where(queryExpr);
            }

            return View("~/Views/Accounting/Module/AccountsReceivableList.ascx", items);
        }

        public ActionResult CreateAccountsReveivableXlsx(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireAccountsReceivable(viewModel);
            IQueryable<CourseContract> items = (IQueryable<CourseContract>)result.Model;

            var details = items.ToArray()
                .Select(item => new
                {
                    合約編號 = item.ContractNo(),
                    分店 = item.CourseContractExtension.BranchStore.BranchName,
                    簽約體能顧問 = item.ServingCoach.UserProfile.FullName(),
                    學員 = item.CourseContractType.IsGroup == true
                        ? String.Join("/", item.CourseContractMember.Select(m => m.UserProfile).ToArray().Select(u => u.FullName()))
                        : item.ContractOwner.FullName(),
                    合約名稱 = String.Concat(item.CourseContractType.TypeName,
                        "(", item.LessonPriceType.DurationInMinutes, " 分鐘)"),
                    生效日 = String.Format("{0:yyyy/MM/dd}", item.EffectiveDate),
                    剩餘堂數 = item.RemainedLessonCount(),
                    購買堂數 = item.Lessons,
                    應付金額 = item.TotalCost ?? 0,
                    已付金額 =  item.TotalPaidAmount() ?? 0,
                    欠款金額 =  (item.TotalCost - item.TotalPaidAmount()) ?? 0,
                    已繳期數 = item.ContractPayment.Count,
                })
                .Where(r =>  r.欠款金額 != 0);


            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename=({1:yyyy-MM-dd HH-mm-ss}){0}", HttpUtility.UrlEncode("AccountsReceivable.xlsx"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.TableName = "應收帳款催收表";
                ds.Tables.Add(table);

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        public ActionResult AchievementIndex(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public ActionResult TrustIndex(TrustQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }



        public ActionResult InquireAchievement(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if(String.IsNullOrEmpty(viewModel.AchievementYearMonthFrom))
            {
                ModelState.AddModelError("AchievementYearMonthFrom", "請選擇查詢月份");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            IQueryable<LessonTime> items = models.GetTable<LessonTime>().AllCompleteLesson();

            var profile = HttpContext.GetUser();

            bool hasConditon = false;

            if (viewModel.CoachID.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.AttendingCoach == viewModel.CoachID);
            }

            if (viewModel.ByCoachID != null && viewModel.ByCoachID.Length > 0)
            {
                items = items.Where(c => viewModel.ByCoachID.Contains(c.AttendingCoach));
            }

            //if (!hasConditon)
            //{
            if (viewModel.BranchID.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.BranchID == viewModel.BranchID);
            }
            //}


            if (!hasConditon)
            {
                if (profile.IsAssistant() || profile.IsAccounting() || profile.IsOfficer())
                {

                }
                else if (profile.IsManager() || profile.IsViceManager())
                {
                    var coaches = profile.GetServingCoachInSameStore(models);
                    items = items.Join(coaches, c => c.AttendingCoach, h => h.CoachID, (c, h) => c);
                }
                else if (profile.IsCoach())
                {
                    items = items.Where(c => c.AttendingCoach == profile.UID);
                }
            }

            if (!String.IsNullOrEmpty(viewModel.AchievementYearMonthFrom))
            {
                viewModel.AchievementDateFrom = DateTime.ParseExact(viewModel.AchievementYearMonthFrom, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture);
                items = items.Where(c => c.ClassTime >= viewModel.AchievementDateFrom);

                viewModel.AchievementDateTo = viewModel.AchievementDateFrom;
                items = items.Where(c => c.ClassTime < viewModel.AchievementDateTo.Value.AddMonths(1));

            }

            if (!String.IsNullOrEmpty(viewModel.AchievementYearMonthTo))
            {
                viewModel.AchievementDateTo = DateTime.ParseExact(viewModel.AchievementYearMonthTo, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture);
                items = items.Where(c => c.ClassTime < viewModel.AchievementDateTo.Value.AddMonths(1));
            }

            return View("~/Views/Accounting/Module/LessonAttendanceAchievementList.ascx", items);
        }

        public ActionResult InquireTuitionAchievement(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<TuitionAchievement> items = models.GetTable<TuitionAchievement>()
                .Where(t => t.Payment.VoidPayment == null || t.Payment.AllowanceID.HasValue);

            var profile = HttpContext.GetUser();

            bool hasConditon = false;

            if (viewModel.CoachID.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.CoachID == viewModel.CoachID);
            }

            if (viewModel.ByCoachID != null && viewModel.ByCoachID.Length > 0)
            {
                items = items.Where(t => viewModel.ByCoachID.Contains(t.CoachID));
            }

            if (viewModel.BranchID.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.Payment.PaymentTransaction.BranchID == viewModel.BranchID);
            }

            if (!hasConditon)
            {
                if (profile.IsAssistant() || profile.IsAccounting() || profile.IsOfficer())
                {

                }
                else if (profile.IsManager() || profile.IsViceManager())
                {
                    var coaches = profile.GetServingCoachInSameStore(models);
                    items = items
                            .Join(coaches, p => p.CoachID, b => b.CoachID, (p, b) => p);
                }
                else if (profile.IsCoach())
                {
                    items = items.Where(p => p.CoachID == profile.UID);
                }
                else
                {
                    items = items.Where(p => false);
                }
            }

            if (!String.IsNullOrEmpty(viewModel.AchievementYearMonthFrom))
            {
                viewModel.AchievementDateFrom = DateTime.ParseExact(viewModel.AchievementYearMonthFrom, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture);
                items = items.Where(c => c.Payment.PayoffDate >= viewModel.AchievementDateFrom);

                viewModel.AchievementDateTo = viewModel.AchievementDateFrom;
                items = items.Where(c => c.Payment.PayoffDate < viewModel.AchievementDateTo.Value.AddMonths(1));
            }

            if (!String.IsNullOrEmpty(viewModel.AchievementYearMonthTo))
            {
                viewModel.AchievementDateTo = DateTime.ParseExact(viewModel.AchievementYearMonthTo, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture);
                items = items.Where(c => c.Payment.PayoffDate < viewModel.AchievementDateTo.Value.AddMonths(1));
            }

            return View("~/Views/Accounting/Module/TuitionAchievementList.ascx", items);

        }

        public ActionResult ListAttendanceAchievement(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireAchievement(viewModel);
            result.ViewName = "~/Views/Accounting/Module/AttendanceAchievementList.ascx";
            return result;
        }

        public ActionResult ListTuitionAchievement(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireTuitionAchievement(viewModel);
            result.ViewName = "~/Views/Accounting/Module/TuitionAchievementItemList.ascx";
            return result;
        }

        public ActionResult InquireContractTrust(TrustQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (String.IsNullOrEmpty(viewModel.TrustYearMonth))
            {
                ModelState.AddModelError("TrustYearMonth", "請輸入查詢月份!!");
            }
            else
            {
                viewModel.TrustDateFrom = DateTime.ParseExact(viewModel.TrustYearMonth, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture);
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            IQueryable<Settlement> items = models.GetTable<Settlement>()
                    .Where(c => c.StartDate == viewModel.TrustDateFrom);

            Expression<Func<ContractTrustTrack, bool>> queryExpr = c => false;
            bool hasConditon = false;

            if (!String.IsNullOrEmpty(viewModel.TrustType))
            {
                hasConditon = true;
                queryExpr = queryExpr.Or(c => c.TrustType == viewModel.TrustType);
                if (viewModel.TrustType == Naming.TrustType.N.ToString())
                {
                    queryExpr = queryExpr.Or(c => c.TrustType == Naming.TrustType.V.ToString());
                }
            }

            IQueryable<ContractTrustTrack> trackItems = models.GetTable<ContractTrustTrack>();
            if (hasConditon)
            {
                trackItems = trackItems.Where(queryExpr);
            }

            viewModel.ContractNo = viewModel.ContractNo.GetEfficientString();
            if(viewModel.ContractNo!=null)
            {
                trackItems = trackItems.Join(models.GetTable<CourseContract>().Where(c => c.ContractNo == viewModel.ContractNo),
                    t => t.ContractID, c => c.ContractID, (t, c) => t);
            }

            ViewBag.DataItems = items;
            return View("~/Views/Accounting/Module/ContractTrustList.ascx", items.Join(trackItems, s => s.SettlementID, t => t.SettlementID, (s, t) => t));
        }

        class _TrustSummaryReportItem
        {
            public int 信託期初金額 { get; set; }
            public int T_轉入 { get; set; }
            public int B_新增 { get; set; }
            public int N_返還 { get; set; }
            public int S_終止 { get; set; }
            public int X_轉讓 { get; set; }
            public int 收_付金額 { get; set; }
            public int 信託期末金額 { get; set; }
        }

        class _TrustTrackReportItem
        {
            public String 處理代碼 { get; set; }
            public String 契約編號 { get; set; }
            public String 入會契約編號 { get; set; }
            public String 買受人證號 { get; set; }
            public String 姓名 { get; set; }
            public String 通訊地址 { get; set; }
            public String 電話 { get; set; }
            public String 轉出買受人証號 { get; set; }
            public int? 當期信託金額 { get; set; }
            public int? 信託餘額 { get; set; }
            public int? 契約總價金 { get; set; }
            public String 交付信託日期 { get; set; }
            public DateTime? 契約起日 { get; set; }
            public DateTime? 契約迄日 { get; set; }
            //public int? 應入信託金額 { get; set; }
            public int? 代墊信託金額 { get; set; }
        }

        public ActionResult CreateTrustTrackXlsx(TrustQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireContractTrust(viewModel);
            IQueryable<ContractTrustTrack> items = (IQueryable<ContractTrustTrack>)result.Model;

            IQueryable<Settlement> settlementItems = (IQueryable<Settlement>)ViewBag.DataItems;
            var summary = settlementItems.ToArray()
                .Select(item => new _TrustSummaryReportItem
                {
                    信託期初金額 = item.ContractTrustSettlement.Sum(s => s.InitialTrustAmount).AdjustTrustAmount(),
                    T_轉入 = item.ContractTrustTrack.Where(t => t.TrustType == "T").Sum(t => t.Payment.PayoffAmount).AdjustTrustAmount(),
                    //B_新增 = item.ContractTrustTrack.Where(t => t.TrustType == "B").Sum(t => t.Payment.PayoffAmount).AdjustTrustAmount().ToString(),
                    B_新增 = item.ContractTrustSettlement.Where(s => s.InitialTrustAmount == 0)
                        .Join(items.Where(t => t.TrustType == "B").Select(t => t.ContractID).Distinct(), s => s.ContractID, t => t, (s, t) => s)
                        .Select(s => s.CourseContract).Sum(c => c.TotalCost).AdjustTrustAmount(),
                    N_返還 =
                        ((item.ContractTrustTrack.Where(t => t.TrustType == "N")
                            .Select(t => t.LessonTime.RegisterLesson)
                            .Sum(lesson => lesson.LessonPriceType.ListPrice * lesson.GroupingMemberCount * lesson.GroupingLessonDiscount.PercentageOfDiscount / 100) ?? 0)
                            /*+ (item.ContractTrustTrack.Where(t => t.TrustType == "V")
                                .Select(t => t.VoidPayment.Payment)
                                .Sum(p => p.PayoffAmount) ?? 0)*/).AdjustTrustAmount(),
                    S_終止 = (item.ContractTrustTrack.Where(t => t.TrustType == "S").Sum(t => t.ReturnAmount)).AdjustTrustAmount(),
                    X_轉讓 = (-item.ContractTrustTrack.Where(t => t.TrustType == "X").Sum(t => t.Payment.PayoffAmount)).AdjustTrustAmount(),
                    收_付金額 = (item.ContractTrustSettlement.Sum(s => s.BookingTrustAmount) - item.ContractTrustSettlement.Sum(s => s.InitialTrustAmount)).AdjustTrustAmount(),
                    信託期末金額 = item.ContractTrustSettlement.Sum(s => s.BookingTrustAmount).AdjustTrustAmount(),
                }).ToArray();

            //foreach(var s in summary)
            //{
            //    s.收_付金額 = s.B_新增 + s.T_轉入 - s.N_返還 - s.S_終止 - s.X_轉讓;
            //}

            DataTable summaryTable = summary.ToDataTable();
            summaryTable.TableName = "彙總表(差額請領)";

            List<_TrustTrackReportItem> details = new List<_TrustTrackReportItem>();

            foreach (var item in items.GroupBy(t => t.ContractID))
            {
                var contract = models.GetTable<CourseContract>().Where(c => c.ContractID == item.Key).First();
                var settlement = models.GetTable<ContractTrustSettlement>().Where(s => s.ContractID == item.Key && s.SettlementID == item.First().SettlementID).First();
                var initialTrustAmount = settlement.InitialTrustAmount == 0 ? contract.TotalCost : settlement.InitialTrustAmount;   //settlement.BookingTrustAmount;
                _TrustTrackReportItem headerItem = null;

                var amt = item.Where(t => t.TrustType == "B").Sum(t => t.Payment.PayoffAmount);
                if (amt.HasValue && amt > 0 && settlement.InitialTrustAmount == 0)
                {
                    _TrustTrackReportItem reportItem = newReportItem(contract);
                    reportItem.處理代碼 = "B";
                    settlement.InitialTrustAmount += amt.Value;
                    reportItem.當期信託金額 = contract.TotalCost.AdjustTrustAmount();
                    reportItem.信託餘額 = initialTrustAmount.AdjustTrustAmount();   // settlement.InitialTrustAmount.AdjustTrustAmount();
                    details.Add(reportItem);
                    headerItem = reportItem;
                }
                amt = item.Where(t => t.TrustType == "T").Sum(t => t.Payment.PayoffAmount);
                if (amt.HasValue && amt > 0)
                {
                    _TrustTrackReportItem reportItem = newReportItem(contract);
                    reportItem.處理代碼 = "T";
                    settlement.InitialTrustAmount += amt.Value;
                    reportItem.當期信託金額 = amt.AdjustTrustAmount(); 
                    reportItem.信託餘額 = initialTrustAmount.AdjustTrustAmount();   // settlement.InitialTrustAmount.AdjustTrustAmount();
                    reportItem.轉出買受人証號 = contract.CourseContractExtension.CourseContractRevision.SourceContract.ContractOwner.UserProfileExtension.IDNo;
                    details.Add(reportItem);
                    if (headerItem == null)
                        headerItem = reportItem;
                }

                amt = item.Where(t => t.TrustType == "N").Select(t => t.LessonTime.RegisterLesson)
                         .Sum(lesson => lesson.LessonPriceType.ListPrice * lesson.GroupingMemberCount * lesson.GroupingLessonDiscount.PercentageOfDiscount / 100);
                if (amt.HasValue && amt > 0)
                {
                    _TrustTrackReportItem reportItem = newReportItem(contract);
                    reportItem.處理代碼 = "N";
                    settlement.InitialTrustAmount -= amt.Value;
                    initialTrustAmount -= amt.Value;
                    reportItem.當期信託金額 = amt.AdjustTrustAmount(); ;
                    reportItem.信託餘額 = initialTrustAmount.AdjustTrustAmount();   //settlement.InitialTrustAmount.AdjustTrustAmount();
                    details.Add(reportItem);
                    if (headerItem == null)
                        headerItem = reportItem;
                }

                amt = item.Where(t => t.TrustType == "V").Select(t => t.VoidPayment.Payment)
                         .Sum(p => p.PayoffAmount);
                if (amt.HasValue && amt > 0 && settlement.InitialTrustAmount == 0)
                {
                    _TrustTrackReportItem reportItem = newReportItem(contract);
                    reportItem.處理代碼 = "N";
                    settlement.InitialTrustAmount -= amt.Value;
                    initialTrustAmount -= amt.Value;
                    reportItem.當期信託金額 = amt.AdjustTrustAmount();
                    reportItem.信託餘額 = initialTrustAmount.AdjustTrustAmount();   //settlement.InitialTrustAmount.AdjustTrustAmount();
                    details.Add(reportItem);
                    if (headerItem == null)
                        headerItem = reportItem;
                }

                amt = -item.Where(t => t.TrustType == "X").Sum(t => t.Payment.PayoffAmount);
                if (amt.HasValue && amt > 0)
                {
                    _TrustTrackReportItem reportItem = newReportItem(contract);
                    reportItem.處理代碼 = "X";
                    settlement.InitialTrustAmount -= amt.Value;
                    initialTrustAmount -= amt.Value;
                    reportItem.當期信託金額 = amt.AdjustTrustAmount(); 
                    reportItem.信託餘額 = initialTrustAmount.AdjustTrustAmount();   //settlement.InitialTrustAmount.AdjustTrustAmount();
                    details.Add(reportItem);
                    if (headerItem == null)
                        headerItem = reportItem;
                }

                amt = item.Where(t => t.TrustType == "S").Sum(t => t.ReturnAmount);
                if (amt.HasValue && amt > 0)
                {
                    _TrustTrackReportItem reportItem = newReportItem(contract);
                    reportItem.處理代碼 = "S";
                    settlement.InitialTrustAmount -= amt.Value;
                    initialTrustAmount -= amt.Value;
                    reportItem.當期信託金額 = amt.AdjustTrustAmount();
                    reportItem.信託餘額 = initialTrustAmount.AdjustTrustAmount();   //settlement.InitialTrustAmount.AdjustTrustAmount();
                    details.Add(reportItem);
                    if (headerItem == null)
                        headerItem = reportItem;
                }

                if (headerItem != null)
                {
                    //headerItem.應入信託金額 = settlement.BookingTrustAmount.AdjustTrustAmount();
                    headerItem.代墊信託金額 = settlement.CurrentLiableAmount.AdjustTrustAmount();
                }

            }

            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename=({1:yyyy-MM-dd HH-mm-ss}){0}", HttpUtility.UrlEncode("TrustReport.xlsx"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.TableName = "預收款信託";
                ds.Tables.Add(table);

                ds.Tables.Add(summaryTable);

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        private _TrustTrackReportItem newReportItem(CourseContract contract)
        {
            return new _TrustTrackReportItem
            {
                處理代碼 = null,
                入會契約編號 = contract.ContractNo(),
                契約編號 = null,
                買受人證號 = contract.ContractOwner.UserProfileExtension.IDNo,
                姓名 = contract.ContractOwner.RealName,
                通訊地址 = contract.ContractOwner.Address(),
                電話 = contract.ContractOwner.Phone,
                轉出買受人証號 = null,
                當期信託金額 = null,
                信託餘額 = null,
                契約總價金 = contract.TotalCost.AdjustTrustAmount(),
                交付信託日期 = null,
                契約起日 = contract.ValidFrom.Value.Date,
                契約迄日 = contract.Expiration.Value.Date,
                //應入信託金額 = null,
                代墊信託金額 = null,
            };
        }

        public ActionResult CreateTrustContractZip(TrustQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireContractTrust(viewModel);
            IQueryable<ContractTrustTrack> items = (IQueryable<ContractTrustTrack>)result.Model;

            var contractID = items.Where(t => t.TrustType == "B")
                .Select(t => t.ContractID);
            var contractItems = models.GetTable<CourseContract>().Where(c => contractID.Contains(c.ContractID));

            String temp = Server.MapPath("~/temp");

            if (!Directory.Exists(temp))
            {
                Directory.CreateDirectory(temp);
            }
            String outFile = Path.Combine(temp, Guid.NewGuid().ToString() + ".zip");
            using (var zipOut = System.IO.File.Create(outFile))
            {
                using (ZipArchive zip = new ZipArchive(zipOut, ZipArchiveMode.Create))
                {
                    foreach (var item in contractItems)
                    {
                        var pdfFile = item.CreateContractPDF();
                        ZipArchiveEntry entry = zip.CreateEntry(Path.GetFileName(pdfFile));
                        using (Stream outStream = entry.Open())
                        {
                            using (FileStream stream = System.IO.File.OpenRead(pdfFile))
                            {
                                stream.CopyTo(outStream);
                            }
                        }
                    }
                }
            }

            return File(outFile, "application/x-zip-compressed", $"({DateTime.Now:yyyy-MM-dd HH-mm-ss})信託合約.zip");
        }

        public ActionResult CreateTrustLessonXlsx(TrustQueryViewModel viewModel)
        {
            if (String.IsNullOrEmpty(viewModel.TrustYearMonth))
            {
                ModelState.AddModelError("TrustYearMonth", "請輸入查詢月份!!");
            }
            else
            {
                viewModel.TrustDateFrom = DateTime.ParseExact(viewModel.TrustYearMonth, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture);
            }

            if (!ModelState.IsValid)
            {
                ViewBag.GoBack = true;
                return View("~/Views/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            models.GetDataContext().DeleteRedundantTrack();

            IQueryable<ContractTrustTrack> items = models.GetTable<ContractTrustTrack>()
                .Where(t => t.EventDate >= viewModel.TrustDateFrom && t.EventDate < viewModel.TrustDateFrom.Value.AddMonths(1))
                .Join(models.GetTable<LessonTime>(), t => t.LessonID, l => l.LessonID, (t, l) => t);

            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("合約編號", typeof(String)));
            table.Columns.Add(new DataColumn("合約總金額", typeof(int)));
            table.Columns.Add(new DataColumn("課程單價", typeof(int)));
            table.Columns.Add(new DataColumn("上課日期", typeof(String)));
            table.Columns.Add(new DataColumn("上課時間", typeof(String)));
            table.Columns.Add(new DataColumn("上課地點", typeof(String)));
            table.Columns.Add(new DataColumn("上課時間長度", typeof(int)));
            table.Columns.Add(new DataColumn("體能顧問姓名", typeof(String)));
            table.Columns.Add(new DataColumn("學員姓名", typeof(String)));
            table.Columns.Add(new DataColumn("簽到時間", typeof(String)));

            foreach (var item in items.OrderBy(l => l.LessonTime.ClassTime))
            {
                var lesson = item.LessonTime;
                var contract = item.CourseContract;

                var r = table.NewRow();
                r[0] = $"{contract.ContractNo()}";
                r[1] = contract.TotalCost.AdjustTrustAmount();
                r[2] = contract.LessonPriceType.ListPrice;
                r[3] = $"{lesson.ClassTime.Value.Date:yyyy/MM/dd}";
                r[4] = $"{lesson.ClassTime:HH:mm}~{lesson.ClassTime.Value.AddMinutes(lesson.DurationInMinutes.Value):HH:mm}";
                if (lesson.BranchID.HasValue)
                    r[5] = lesson.BranchStore.BranchName;
                r[6] = lesson.DurationInMinutes;
                r[7] = lesson.AsAttendingCoach.UserProfile.FullName();
                if (contract.CourseContractType.ContractCode == "CFA")
                {
                    r[8] = contract.ContractOwner.RealName + "(" + String.Join("/", lesson.GroupingLesson.RegisterLesson.Select(g => g.UserProfile.RealName)) + ")";
                }
                else
                {
                    r[8] = String.Join("/", lesson.GroupingLesson.RegisterLesson.Select(g => g.UserProfile.RealName));
                }
                r[9] = $"{lesson.LessonPlan.CommitAttendance:yyyy/MM/dd HH:mm:ss}";

                table.Rows.Add(r);
            }

            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename=({1:yyyy-MM-dd HH-mm-ss}){0}", HttpUtility.UrlEncode("TrustLessons.xlsx"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                ds.Tables.Add(table);

                using (var xls = ds.ConvertToExcel())
                {
                    xls.Worksheets.ElementAt(0).Name = "上課明細表" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.TrustDateFrom, viewModel.TrustDateFrom.Value.AddMonths(1).AddDays(-1));

                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        public ActionResult CreateContractTrustSummaryXlsx(TrustQueryViewModel viewModel)
        {
            var settlement = models.GetTable<Settlement>()
                .OrderByDescending(s => s.SettlementID).FirstOrDefault();

            if (settlement == null)
            {
                ViewBag.GoBack = true;
                return View("~/Views/Shared/JsAlert.ascx", model: "無任何信託結算資料!!");
            }

            var items = models.GetTable<ContractTrustSettlement>()
                    .Where(t => t.SettlementID == settlement.SettlementID);

            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("入會契約編號", typeof(String)));
            table.Columns.Add(new DataColumn("買受人證號", typeof(String)));
            table.Columns.Add(new DataColumn("姓名", typeof(String)));
            table.Columns.Add(new DataColumn("電話", typeof(String)));
            table.Columns.Add(new DataColumn("信託餘額", typeof(int)));
            table.Columns.Add(new DataColumn("契約總價金", typeof(int)));
            table.Columns.Add(new DataColumn("契約起日", typeof(String)));
            table.Columns.Add(new DataColumn("契約迄日", typeof(String)));
            table.Columns.Add(new DataColumn("代墊信託金額", typeof(int)));
            table.TableName = $"信託盤點表{settlement.StartDate:yyyy-MM}截止";

            foreach (var item in items)
            {
                var contract = item.CourseContract;

                var r = table.NewRow();
                r[0] = $"{contract.ContractNo()}";
                r[1] = contract.ContractOwner.UserProfileExtension?.IDNo;
                r[2] = contract.ContractOwner.RealName;
                r[3] = contract.ContractOwner.Phone;
                r[4] = item.BookingTrustAmount.AdjustTrustAmount();
                r[5] = contract.TotalCost.AdjustTrustAmount();
                r[6] = $"{contract.EffectiveDate:yyyy/MM/dd}";
                r[7] = $"{contract.Expiration:yyyy/MM/dd}";
                r[8] = item.CurrentLiableAmount.AdjustTrustAmount();

                table.Rows.Add(r);
            }

            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename=({1:yyyy-MM-dd HH-mm-ss}){0}", HttpUtility.UrlEncode("ContractTrust.xlsx"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                ds.Tables.Add(table);

                using (var xls = ds.ConvertToExcel())
                {
                    //xls.Worksheets.ElementAt(0).Name = "上課明細表" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.TrustDateFrom, viewModel.TrustDateFrom.Value.AddMonths(1).AddDays(-1));
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        public ActionResult ExecuteSettlementForLastMonth(DateTime? settlementDate)
        {
            if (!settlementDate.HasValue)
            {
                settlementDate = DateTime.Today;
            }

            DateTime execDate = settlementDate.Value.AddMonths(-1);
            DateTime startDate = new DateTime(execDate.Year, execDate.Month, 1);
            models.ExecuteSettlement(startDate, startDate.AddMonths(1));

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult InitializeTrust()
        {
            var items = models.GetTable<RegisterLesson>().Where(r => r.AttendedLessons > 0)
                    .Where(r => r.GroupingLesson.LessonTime.Count > 0);

            foreach(var item in items)
            {
                var firstLesson = item.GroupingLesson.LessonTime.First();
                for (int i = 0; i < item.AttendedLessons; i++)
                {
                    models.GetTable<ContractTrustTrack>().InsertOnSubmit(new ContractTrustTrack
                    {
                        ContractID = item.RegisterLessonContract.ContractID,
                        EventDate = firstLesson.ClassTime.Value,
                        LessonID = firstLesson.LessonID,
                        TrustType = Naming.TrustType.N.ToString()
                    });
                }
            }

            models.SubmitChanges();

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExecuteSettlement(DateTime? startDate,DateTime? endDate)
        {
            if (!startDate.HasValue || !endDate.HasValue )
            {
                return Json(new { result = false }, JsonRequestBehavior.AllowGet);
            }

            models.ExecuteSettlement(startDate.Value, endDate.Value);

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);
        }


        public ActionResult CreateAchievementXlsx(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireAchievement(viewModel);
            IQueryable<LessonTime> items = (IQueryable<LessonTime>)result.Model;

            var details = items.GroupBy(t => new { CoachID = t.AttendingCoach });
            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("姓名", typeof(String)));
            table.Columns.Add(new DataColumn("總終點課數", typeof(decimal)));
            table.Columns.Add(new DataColumn("總鐘點費用", typeof(int)));
            table.Columns.Add(new DataColumn("等級", typeof(String)));
            table.Columns.Add(new DataColumn("實際抽成費用(含稅)", typeof(int)));
            table.Columns.Add(new DataColumn("實際抽成費用", typeof(decimal)));

            foreach (var item in details)
            {
                var lesson = item.First();
                var r = table.NewRow();
                var coach = models.GetTable<ServingCoach>().Where(u => u.CoachID == item.Key.CoachID).First();
                r[0] = coach.UserProfile.RealName;
                r[1] = item.Count() - (decimal)(item
                                    .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自主訓練
                                        || (t.RegisterLesson.RegisterLessonEnterprise != null
                                            && t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.DocumentLevelDefinition.自主訓練)).Count()) / 2m;
                int shares;
                var lessons = item
                        .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
                        .Where(t => t.RegisterLesson.RegisterLessonEnterprise == null
                            || t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status != (int)Naming.DocumentLevelDefinition.自主訓練);
                r[2] = models.CalcAchievement(lessons, out shares);
                r[3] = lesson.LessonTimeSettlement.ProfessionalLevel.LevelName;
                r[4] = shares;
                r[5] = Math.Round(shares / 1.05m);
                table.Rows.Add(r);
            }

            table.TableName = "上課統計表";

            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename=({1:yyyy-MM-dd HH-mm-ss}){0}", HttpUtility.UrlEncode("AchievementReport.xlsx"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                ds.Tables.Add(table);
                table = createTuitionAchievementXlsx(viewModel);
                ds.Tables.Add(table);
                table = createAchievementDetailsXlsx(viewModel);
                ds.Tables.Add(table);
                table = createTuitionAchievementDetailsXlsx(viewModel);
                ds.Tables.Add(table);

                using (var xls = ds.ConvertToExcel())
                {
                    if (viewModel.AchievementDateFrom.HasValue && viewModel.AchievementDateTo.HasValue)
                    {
                        xls.Worksheets.ElementAt(0).Name = "上課統計表" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo.Value.AddMonths(1).AddDays(-1));
                        xls.Worksheets.ElementAt(1).Name = "業績統計表" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo.Value.AddMonths(1).AddDays(-1));
                    }
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        private DataTable createAchievementDetailsXlsx(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireAchievement(viewModel);
            IQueryable<LessonTime> items = (IQueryable<LessonTime>)result.Model;

            return models.CreateLessonAchievementDetails(items);

        }

        private DataTable createTuitionAchievementXlsx(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireTuitionAchievement(viewModel);
            IQueryable<TuitionAchievement> items = (IQueryable<TuitionAchievement>)result.Model;

            var details = items.GroupBy(t => t.CoachID);

            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("姓名", typeof(String)));
            table.Columns.Add(new DataColumn("業績金額(含稅)", typeof(int)));
            table.Columns.Add(new DataColumn("業績金額", typeof(decimal)));

            foreach (var item in details)
            {
                var r = table.NewRow();
                var coach = models.GetTable<ServingCoach>().Where(u => u.CoachID == item.Key).First();
                r[0] = coach.UserProfile.RealName;
                r[1] = item.Sum(l => l.ShareAmount);
                r[2] = Math.Round((int)r[1] / 1.05m);
                table.Rows.Add(r);
            }

            table.TableName = "業績統計表";

            return table;
        }

        private DataTable createTuitionAchievementDetailsXlsx(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireTuitionAchievement(viewModel);
            IQueryable<TuitionAchievement> items = (IQueryable<TuitionAchievement>)result.Model;

            DataTable table = models.CreateTuitionAchievementDetails(items);

            return table;
        }

        public ActionResult ListPaymentHistory(CourseContractQueryViewModel viewModel)
        {
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();

            if (item == null)
            {
                return View("~/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            return View("~/Views/Accounting/Module/ContractPaymentList.ascx", item);
        }

        public ActionResult ListTuitionShares(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireTuitionAchievement(viewModel);
            result.ViewName = "~/Views/Accounting/Module/TuitionAchievementShares.ascx";
            return result;
        }



    }
}