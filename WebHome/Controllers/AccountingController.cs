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
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

using CommonLib.DataAccess;

using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Helper.BusinessOperation;
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
        public AccountingController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: Accounting
        public ActionResult ReceivableIndex()
        {
            return View();
        }

        public async Task<ActionResult> InquireAccountsReceivableAsync(CourseContractQueryViewModel viewModel)
        {
            IQueryable<CourseContract> items = models.PromptAccountingContract();

            var profile = await HttpContext.GetUserAsync();

            Expression<Func<CourseContract, bool>> queryExpr = c => false;
            bool hasConditon = false;
            if (viewModel.BypassCondition == true)
            {
                hasConditon = true;
                queryExpr = c => true;
            }
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

        public async Task<ActionResult> CreateAccountsReceivableXlsxAsync(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquireAccountsReceivableAsync(viewModel);
            IQueryable<CourseContract> items = (IQueryable<CourseContract>)result.Model;

            var details = items.ToArray()
                .Select(item => new
                {
                    合約編號 = item.ContractNo(),
                    合約名稱 = String.Concat(item.CourseContractType.TypeName,
                        "(", item.CurrentPrice.DurationInMinutes, " 分鐘)"),
                    簽約場所 = item.CourseContractExtension.BranchStore.BranchName,
                    合約體能顧問 = item.ServingCoach.UserProfile.FullName(),
                    學生 = item.CourseContractType.IsGroup == true
                        ? String.Join("/", item.CourseContractMember.Select(m => m.UserProfile).ToArray().Select(u => u.FullName()))
                        : item.ContractOwner.FullName(),                    
                    合約生效起日 = String.Format("{0:yyyyMMdd}", item.EffectiveDate),
                    合約生效迄日 = String.Format("{0:yyyyMMdd}", item.Expiration),
                    應收款期限 = String.Format("{0:yyyyMMdd}", item.PayoffDue),
                    合約總價金 = item.TotalCost ?? 0,
                    剩餘堂數 = item.RemainedLessonCount(),
                    購買上課數 = item.Lessons,
                    累計收款金額 =  item.TotalPaidAmount(),
                    累計欠款金額 =  (item.TotalCost - item.TotalPaidAmount()) ?? 0,
                    累計收款次數 = item.ContractPayment.Count,
                })
                .Where(r =>  r.累計欠款金額 != 0);

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.TableName = $"截至 {DateTime.Today:yyyyMMdd} 催收帳款";
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("AccountsReceivable"), DateTime.Now), viewModel.FileDownloadToken);
            }

            return new EmptyResult();
        }

        public ActionResult AchievementIndex(AchievementQueryViewModel viewModel)
        {
            viewModel.AchievementDateFrom = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            viewModel.AchievementDateTo = viewModel.AchievementDateFrom;
            viewModel.AchievementYearMonthTo = viewModel.AchievementYearMonthFrom = String.Format("{0:yyyy/MM}", viewModel.AchievementDateFrom);

            ViewBag.ViewModel = viewModel;
            return View();
        }

        public ActionResult TrustIndex(TrustQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            viewModel.TrustDateFrom = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            viewModel.TrustDateTo = viewModel.TrustDateFrom;
            viewModel.TrustYearMonth = String.Format("{0:yyyy/MM}", viewModel.TrustDateFrom);

            return View();
        }



        public ActionResult InquireAchievement(AchievementQueryViewModel viewModel)
        {
            var items = viewModel.InquireAchievement(models);
            return View("~/Views/Accounting/Module/LessonAttendanceAchievementList.ascx", items);
        }

        public async Task<ActionResult> InquireTuitionAchievementAsync(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.AchievementDateFrom.HasValue)
            {
                if (!String.IsNullOrEmpty(viewModel.AchievementYearMonthFrom))
                {
                    viewModel.AchievementDateFrom = DateTime.ParseExact(viewModel.AchievementYearMonthFrom, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture);
                }
            }

            if (!viewModel.AchievementDateTo.HasValue)
            {

                if (!String.IsNullOrEmpty(viewModel.AchievementYearMonthTo))
                {
                    viewModel.AchievementDateTo = DateTime.ParseExact(viewModel.AchievementYearMonthTo, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture);
                }
            }


            IQueryable<TuitionAchievement> items = models.GetTable<TuitionAchievement>().FilterByEffective();

            var profile = await HttpContext.GetUserAsync();

            bool hasConditon = false;
            if (viewModel.BypassCondition == true)
            {
                hasConditon = true;
            }

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

            if (viewModel.AchievementDateFrom.HasValue)
            {
                items = items.Where(c => c.Payment.PayoffDate >= viewModel.AchievementDateFrom);

                if (!viewModel.AchievementDateTo.HasValue)
                    viewModel.AchievementDateTo = viewModel.AchievementDateFrom;
            }

            if (viewModel.AchievementDateTo.HasValue)
            {
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

        public async Task<ActionResult> ListTuitionAchievementAsync(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquireTuitionAchievementAsync(viewModel);
            result.ViewName = "~/Views/Accounting/Module/TuitionAchievementItemList.ascx";
            return result;
        }

        public ActionResult InquireContractTrust(TrustQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;


            if (!viewModel.TrustDateFrom.HasValue)
            {
                if (!String.IsNullOrEmpty(viewModel.TrustYearMonth))
                {
                    viewModel.TrustDateFrom = DateTime.ParseExact(viewModel.TrustYearMonth, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture);
                }
                else
                {
                    ModelState.AddModelError("TrustYearMonth", "請輸入查詢月份!!");
                }
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
            //public int? 代墊信託金額 { get; set; }
        }

        public async Task<ActionResult> CreateTrustTrackXlsxAsync(TrustQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireContractTrust(viewModel);
            IQueryable<ContractTrustTrack> items = (IQueryable<ContractTrustTrack>)result.Model;

            IQueryable<Settlement> settlementItems = (IQueryable<Settlement>)ViewBag.DataItems;

            if (items.Count() == 0)
            {
                ViewBag.GoBack = true;
                return View("~/Views/Shared/JsAlert.cshtml", model: "無任何信託資料!!");
            }

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

                //if (headerItem != null)
                //{
                    //headerItem.應入信託金額 = settlement.BookingTrustAmount.AdjustTrustAmount();
                    //headerItem.代墊信託金額 = settlement.CurrentLiableAmount.AdjustTrustAmount();
                //}

            }

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.TableName = "預收款信託";
                ds.Tables.Add(table);

                ds.Tables.Add(summaryTable);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("TrustReport"), DateTime.Now), viewModel.FileDownloadToken);
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
                //代墊信託金額 = null,
            };
        }

        public ActionResult CreateTrustContractZip(TrustQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireContractTrust(viewModel);
            IQueryable<ContractTrustTrack> items = (IQueryable<ContractTrustTrack>)result.Model;

            var contractID = items.Where(t => t.TrustType == "B")
                .Select(t => t.ContractID);
            var contractItems = models.GetTable<CourseContract>().Where(c => contractID.Contains(c.ContractID));

            String temp = Startup.MapPath("~/temp");

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

            Response.Cookies.Append("fileDownloadToken", viewModel.FileDownloadToken ?? "");
            return new PhysicalFileResult(outFile, "application/x-zip-compressed")
            {
                FileDownloadName = $"({DateTime.Now:yyyy-MM-dd HH-mm-ss})信託合約.zip"
            };
        }
                

        public async Task<ActionResult> CreateContractTrustSummaryXlsxAsync(TrustQueryViewModel viewModel)
        {
            var settlement = models.GetTable<Settlement>()
                .OrderByDescending(s => s.SettlementID).FirstOrDefault();

            if (settlement == null)
            {
                ViewBag.GoBack = true;
                return View("~/Views/Shared/JsAlert.cshtml", model: "無任何信託結算資料!!");
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

            using (DataSet ds = new DataSet())
            {
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("ContractTrust"), DateTime.Now), viewModel.FileDownloadToken);
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
            models.ExecuteSettlement(startDate, startDate.AddMonths(1), settlementDate);

            return Json(new { result = true });
        }

        public async Task<ActionResult> ExecuteMonthlySettlementAsync(ContractSettlementViewModel viewModel)
        {
            if (!viewModel.SettlementDate.HasValue)
            {
                viewModel.SettlementDate = DateTime.Today;
            }

            await Task.Run(() =>
            {
                if (viewModel.SettlementFrom.HasValue)
                {
                    //bool effective = viewModel.Effective ?? true;
                    for (DateTime settlementDate = viewModel.SettlementFrom.Value; settlementDate <= viewModel.SettlementDate; settlementDate = settlementDate.AddMonths(1))
                    {
                        models.ExecuteMonthlySettlement(settlementDate);
                        //effective = true;
                    }
                }
                else
                {
                    models.ExecuteMonthlySettlement(viewModel.SettlementDate.Value);
                }

            });

            return Json(new { result = true });
        }

        public async Task<ActionResult> ExecuteMonthlyPerformanceSettlementAsync(DateTime? settlementDate,String forRole)
        {
            if (!settlementDate.HasValue)
            {
                settlementDate = DateTime.Today;
            }

            await Task.Run(() =>
            {
                DateTime execDate = settlementDate.Value;
                DateTime startDate = execDate.FirstDayOfMonth();
                models.ExecuteLessonPerformanceSettlement(startDate, startDate.AddMonths(1), forRole);
                //models.ExecuteVoidShareSettlement(startDate, startDate.AddMonths(1));
            });

            return Json(new { result = true });
        }

        public async Task<ActionResult> ExecuteYearlyPerformanceReviewAsync(int? year, String forRole)
        {
            if (!year.HasValue)
            {
                year = DateTime.Today.Year;
            }

            await Task.Run(() =>
            {
                models.ExecuteYearlyPerformanceReview(year.Value, forRole);
            });

            return Json(new { result = true });
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

            return Json(new { result = true });
        }

        public ActionResult ExecuteSettlement(DateTime? startDate,DateTime? endDate)
        {
            if (!startDate.HasValue || !endDate.HasValue )
            {
                return Json(new { result = false });
            }

            models.ExecuteSettlement(startDate.Value, endDate.Value);

            return Json(new { result = true });
        }

        enum MonthlySettlementColumn
        {
            入會契約編號 = 0,
            //身分證字號,
            姓名,
            是否信託,
            //累計收款金額,
            //累計上課金額,
            //折退金額,
            契約餘額,
            契約總價金,
            //累計上課數,
            契約起日,
            契約迄日,
        }

        public async Task<ActionResult> GetMonthlySettlementAsync(DateTime? settlementDate,DateTime? initialDate,String fileDownloadToken)
        {
            if (!settlementDate.HasValue)
            {
                settlementDate = DateTime.Today;
            }

            bool initial = false;
            var calcDate = settlementDate.Value.AddMonths(1).FirstDayOfMonth();
            if (initialDate.HasValue)
            {
                initial = initialDate.Value.FirstDayOfMonth() == calcDate;
            }

            IQueryable<ContractMonthlySummary> items = models.GetTable<ContractMonthlySummary>().Where(c => c.SettlementDate == calcDate);

            //										
            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("入會契約編號", typeof(String)));
            //table.Columns.Add(new DataColumn("身分證字號", typeof(String)));
            table.Columns.Add(new DataColumn("姓名", typeof(String)));
            table.Columns.Add(new DataColumn("是否信託", typeof(String)));
            //table.Columns.Add(new DataColumn("累計收款金額", typeof(int)));
            //table.Columns.Add(new DataColumn("累計上課金額", typeof(int)));
            //table.Columns.Add(new DataColumn("折退金額", typeof(int)));
            table.Columns.Add(new DataColumn("契約餘額", typeof(int)));
            table.Columns.Add(new DataColumn("契約總價金", typeof(int)));
            //table.Columns.Add(new DataColumn("累計上課數", typeof(int)));
            table.Columns.Add(new DataColumn("契約起日", typeof(String)));
            table.Columns.Add(new DataColumn("契約迄日", typeof(String)));

            DateTime validTo = calcDate.AddMonths(-1);

            foreach (var item in items)
            {
                if (!initial)
                {
                    if (item.CourseContract.ValidTo.HasValue
                            && item.CourseContract.ValidTo < validTo
                            && item.RemainedAmount == 0)
                    {
                        models.ExecuteCommand("delete CourseContractAction where ActionID = {0} and ContractID = {1}",
                                (int)CourseContractAction.ActionType.盤點,
                                item.ContractID);
                        continue;
                    }
                }

                var r = table.NewRow();
                var c = item.CourseContract;
                var ts = c.ContractTrustSettlement.Any();
                r[(int)MonthlySettlementColumn.入會契約編號] = c.ContractNo();
                //r[(int)MonthlySettlementColumn.身分證字號] = c.ContractOwner.UserProfileExtension.IDNo;
                r[(int)MonthlySettlementColumn.姓名] = c.ContractOwner.RealName;
                r[(int)MonthlySettlementColumn.是否信託] = ts ? "是" : "否";
                //r[(int)MonthlySettlementColumn.累計收款金額] = item.TotalPrepaid;
                //r[(int)MonthlySettlementColumn.累計上課金額] = item.TotalLessonCost;
                //if (item.TotalAllowanceAmount.HasValue)
                //    r[(int)MonthlySettlementColumn.折退金額] = item.TotalAllowanceAmount;
                //r[(int)MonthlySettlementColumn.契約餘額] = item.RemainedAmount;
                if (c.ContractTrustSettlement.Any() && item.RemainedAmount > 0)
                {
                    r[(int)MonthlySettlementColumn.契約餘額] = c.TotalCost - item.TotalLessonCost;
                }
                else
                {
                    r[(int)MonthlySettlementColumn.契約餘額] = item.RemainedAmount;
                }
                //r[(int)MonthlySettlementColumn.累計上課數] = c.AttendedLessonCount(calcDate);
                r[(int)MonthlySettlementColumn.契約總價金] = c.TotalCost;

                r[(int)MonthlySettlementColumn.契約起日] = $"{c.EffectiveDate:yyyyMMdd}";
                r[(int)MonthlySettlementColumn.契約迄日] = $"{(c.ValidTo ?? c.Expiration):yyyyMMdd}";
                table.Rows.Add(r);
            }

            table.TableName = $"截至 {calcDate.AddDays(-1):yyyyMMdd} 合約盤點表";


            using (DataSet ds = new DataSet())
            {
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("ContractsInventory"), DateTime.Now), fileDownloadToken);

            }

            return new EmptyResult();
        }

        class _LessonSummaryDataItem
        {
            public String A { get; set; }
            public int B { get; set; }
            public int C { get; set; }
            public int D { get; set; }
            public int E { get; set; }
            public int F { get; set; }
            public int G { get; set; }
        }

        class _LessonDataItem
        {
            public String A { get; set; }
            public int B { get; set; }
            public int C { get; set; }
            public int D { get; set; }
        }


        public async Task<ActionResult> GetMonthlyLessonsSummaryAsync(DateTime? settlementDate,String fileDownloadToken)
        {
            if (!settlementDate.HasValue)
            {
                settlementDate = DateTime.Today;
            }

            var dateFrom = settlementDate.Value.FirstDayOfMonth();
            var dateTo = dateFrom.AddMonths(1);

            IQueryable<LessonTime> items = models.GetTable<LessonTime>()
                .AllCompleteLesson()
                .Where(l => l.ClassTime >= dateFrom && l.ClassTime < dateTo);

            DataTable buildSummary(IQueryable<LessonTime> data)
            {
                List<_LessonSummaryDataItem> results = new List<_LessonSummaryDataItem>();
                _LessonSummaryDataItem subtotal = new _LessonSummaryDataItem
                {
                    A = "總計"
                };
                foreach (var branch in models.GetTable<BranchStore>())
                {
                    var lessonItems = data.Where(d => d.BranchID == branch.BranchID);
                    var i = new _LessonSummaryDataItem
                    {
                        A = branch.BranchName,
                        B = lessonItems.Count(),
                        C = lessonItems.Sum(l=>l.RegisterLesson.LessonPriceType.ListPrice * l.RegisterLesson.GroupingMemberCount * l.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount / 100) ?? 0,
                    };
                    i.D = (int)Math.Round(i.C * 20m / 100m);
                    i.E = (int)Math.Round(i.C * 80m / 100m);
                    i.F = (int)Math.Round(i.D / 1.05m);
                    i.G = (int)Math.Round(i.E / 1.05m);
                    subtotal.B += i.B;
                    subtotal.C += i.C;
                    subtotal.D += i.D;
                    subtotal.E += i.E;
                    subtotal.F += i.F;
                    subtotal.G += i.G;
                    results.Add(i);
                }
                results.Add(subtotal);
                DataTable table = results.ToDataTable();
                table.Columns[0].ColumnName = "上課場所";
                table.Columns[1].ColumnName = "上課總數";
                table.Columns[2].ColumnName = "累計上課金額";
                table.Columns[3].ColumnName = "信託 20%";
                table.Columns[4].ColumnName = "信託 80%";
                table.Columns[5].ColumnName = "信託 (未稅)20%";
                table.Columns[6].ColumnName = "信託 (未稅)80%";
                return table;
            }

            DataTable buildTable(IQueryable<LessonTime> data)
            {
                List<_LessonDataItem> results = new List<_LessonDataItem>();
                _LessonDataItem subtotal = new _LessonDataItem
                {
                    A = "總計"
                };
                foreach (var branch in models.GetTable<BranchStore>())
                {
                    var lessonItems = data.Where(d => d.BranchID == branch.BranchID);
                    var i = new _LessonDataItem
                    {
                        A = branch.BranchName,
                        B = lessonItems.Count(),
                        C = lessonItems.Sum(l => l.RegisterLesson.LessonPriceType.ListPrice * l.RegisterLesson.GroupingMemberCount * l.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount / 100) ?? 0,
                    };
                    i.D = (int)Math.Round(i.C / 1.05m);
                    subtotal.B += i.B;
                    subtotal.C += i.C;
                    subtotal.D += i.D;
                    results.Add(i);
                }
                results.Add(subtotal);
                DataTable table = results.ToDataTable();
                table.Columns[0].ColumnName = "上課場所";
                table.Columns[1].ColumnName = "上課總數";
                table.Columns[2].ColumnName = "累計上課金額";
                table.Columns[3].ColumnName = "累計上課金額(未稅)";
                return table;
            }

            DataTable buildEnterpriseTable(IQueryable<LessonTime> data)
            {
                List<_LessonDataItem> results = new List<_LessonDataItem>();
                _LessonDataItem subtotal = new _LessonDataItem
                {
                    A = "總計"
                };
                foreach (var branch in models.GetTable<BranchStore>())
                {
                    var lessonItems = data.Where(d => d.BranchID == branch.BranchID);
                    var i = new _LessonDataItem
                    {
                        A = branch.BranchName,
                        B = lessonItems.Count(),
                        C = lessonItems.Sum(l => l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.CoachPayoff) ?? 0,
                    };
                    i.D = (int)Math.Round(i.C / 1.05m);
                    subtotal.B += i.B;
                    subtotal.C += i.C;
                    subtotal.D += i.D;
                    results.Add(i);
                }
                results.Add(subtotal);
                DataTable table = results.ToDataTable();
                table.Columns[0].ColumnName = "上課場所";
                table.Columns[1].ColumnName = "上課總數";
                table.Columns[2].ColumnName = "累計上課金額";
                table.Columns[3].ColumnName = "累計上課金額(未稅)";
                return table;
            }

            using (DataSet ds = new DataSet())
            {
                var dataItems = items.Where(l => l.RegisterLesson.RegisterLessonContract != null)
                    .Where(l => l.RegisterLesson.RegisterLessonContract.CourseContract.Entrusted == true);
                var table = buildSummary(dataItems);
                table.TableName = $"{dateFrom:yyyyMM} 信託合約上課盤點彙總表";
                ds.Tables.Add(table);

                dataItems = items.Where(l => l.RegisterLesson.RegisterLessonContract != null)
                                .Where(l => l.RegisterLesson.RegisterLessonContract.CourseContract.Entrusted == false);
                table = buildTable(dataItems);
                table.TableName = $"{dateFrom:yyyyMM} 非信託合約上課盤點彙總表";
                ds.Tables.Add(table);

                dataItems = items.Where(l => l.RegisterLesson.RegisterLessonEnterprise != null);
                table = buildEnterpriseTable(dataItems);
                table.TableName = $"{dateFrom:yyyyMM} 企業方案上課盤點彙總表";
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("LessonsInventorySummary"), DateTime.Now), fileDownloadToken);

            }

            return new EmptyResult();
        }

        //public async Task<ActionResult> GetMonthlyLessonsListAsync(DateTime? settlementDate, String fileDownloadToken)
        //{
        //    if (!settlementDate.HasValue)
        //    {
        //        settlementDate = DateTime.Today;
        //    }

        //    var dateFrom = settlementDate.Value.FirstDayOfMonth();
        //    var dateTo = dateFrom.AddMonths(1);


        //    IQueryable<int> items = models.GetTable<LessonTime>()
        //            .AllCompleteLesson()
        //            .Where(l => l.ClassTime >= dateFrom && l.ClassTime < dateTo)
        //            .Join(models.GetTable<GroupingLesson>(), l => l.GroupID, g => g.GroupID, (l, g) => g)
        //            .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r)
        //            .Join(models.GetTable<RegisterLessonContract>(), r => r.RegisterID, c => c.RegisterID, (r, c) => c.ContractID)
        //            .Distinct();

        //    //										
        //    //           累計上課金額

        //    DataTable table = new DataTable();
        //    table.Columns.Add(new DataColumn("合約編號", typeof(String)));
        //    table.Columns.Add(new DataColumn("分店", typeof(String)));
        //    table.Columns.Add(new DataColumn("姓名", typeof(String)));
        //    table.Columns.Add(new DataColumn("是否信託", typeof(String)));
        //    table.Columns.Add(new DataColumn("課程單價", typeof(int)));
        //    table.Columns.Add(new DataColumn("本月上課堂數", typeof(int)));
        //    table.Columns.Add(new DataColumn("累計上課金額", typeof(int)));

        //    foreach (var item in items)
        //    {
        //        var c = models.GetTable<CourseContract>().Where(t => t.ContractID == item).First();

        //        var r = table.NewRow();
        //        r[0] = c.ContractNo();
        //        r[1] = c.CourseContractExtension.BranchStore.BranchName;
        //        r[2] = c.ContractLearner();
        //        r[3] = c.ContractTrustSettlement.Any() ? "是" : "否";
        //        r[4] = c.LessonPriceType.ListPrice;
        //        var count = c.AttendedLessonList().Where(l => l.ClassTime >= dateFrom && l.ClassTime < dateTo).Count();
        //        r[5] = count;
        //        r[6] = c.TotalAttendedCost(dateFrom, dateTo) * c.CourseContractType.GroupingMemberCount * c.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount / 100;
        //        table.Rows.Add(r);
        //    }

        //    table.TableName = $"上課盤點清單{dateFrom:yyyy-MM}";

        //    using (DataSet ds = new DataSet())
        //    {
        //        ds.Tables.Add(table);

        //        await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("LessonsInventory"), DateTime.Now), fileDownloadToken);

        //    }

        //    return new EmptyResult();
        //}

        class _AchievementGroupItem
        {
            public int? CoachID { get; set; }
            public IGrouping<int?, V_Tuition> LessonGroup { get; set; }
            public IGrouping<int, TuitionAchievement> AchievementGroup { get; set; }
        }

        public async Task<ActionResult> CreateAchievementShareXlsxAsync(PaymentQueryViewModel viewModel)
        {
            viewModel.IncomeOnly = true;
            if(!viewModel.PayoffDateFrom.HasValue)
            {
                viewModel.PayoffDateFrom = DateTime.Today.FirstDayOfMonth();
            }
            viewModel.PayoffDateTo = viewModel.PayoffDateFrom.Value.AddMonths(1).AddDays(-1);

            IQueryable<Payment> paymentItems = viewModel.InquirePayment(models);
            //.FilterByEffective();
            IQueryable<VoidPayment> voidItems = models.GetTable<VoidPayment>()
                    .Where(v => v.VoidDate >= viewModel.PayoffDateFrom)
                    .Where(v => v.VoidDate < viewModel.PayoffDateTo.Value.AddDays(1));

            IQueryable<TuitionAchievement> achievementItems = paymentItems.GetPaymentAchievement(models);
            IQueryable<TuitionAchievement> voidShares = voidItems.GetVoidShare(models);

            if (viewModel.CoachID.HasValue)
            {
                achievementItems = achievementItems.Where(t => t.CoachID == viewModel.CoachID);
            }

            DataTable details = models.CreateAchievementShareList(achievementItems);
            details.TableName = $"{viewModel.PayoffDateFrom:yyyyMM} 分潤業績明細(含稅)";

            DataTable voidDetails = models.CreateVoidShareList(voidShares.Where(t => t.VoidShare.HasValue));
            voidDetails.TableName = $"{viewModel.PayoffDateFrom:yyyyMM} 終止折讓分潤明細(含稅)";


            var tableItems = details.Rows.Cast<DataRow>();
            var tableVoidItems = voidDetails.Rows.Cast<DataRow>();

            DataTable buildBranchDetails()
            {
                //							
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("簽約場所", typeof(String)));
                table.Columns.Add(new DataColumn("實際收款業績", typeof(int)));
                table.Columns.Add(new DataColumn("分潤業績", typeof(int)));
                table.Columns.Add(new DataColumn("體能顧問費", typeof(int)));
                table.Columns.Add(new DataColumn("終止折讓金額", typeof(int)));
                table.Columns.Add(new DataColumn("體能顧問費佔比(%)", typeof(int)));
                table.Columns.Add(new DataColumn("新約體能顧問費", typeof(int)));
                table.Columns.Add(new DataColumn("新約佔比(%)", typeof(int)));
                table.Columns.Add(new DataColumn("續約體能顧問費", typeof(int)));
                table.Columns.Add(new DataColumn("續約佔比(%)", typeof(int)));
                table.Columns.Add(new DataColumn("P.I Session", typeof(int)));
                table.Columns.Add(new DataColumn("P.I Session佔比(%)", typeof(int)));
                table.Columns.Add(new DataColumn("其他販售商品及手續費收入", typeof(int)));
                table.Columns.Add(new DataColumn("其他販售商品及手續費收入占比(%)", typeof(int)));

                DataRow r;
                foreach (var branch in models.GetTable<BranchStore>())
                {
                    var branchItems = tableItems.Where(t => (String)t[6] == branch.BranchName);
                    var allowanceItems = models.GetTable<Payment>()
                                        .Join(models.GetTable<PaymentTransaction>().Where(t => t.BranchID == branch.BranchID),
                                            p => p.PaymentID, t => t.PaymentID, (p, t) => p)
                                        .Join(voidItems, p => p.PaymentID, v => v.VoidID, (p, v) => p)
                                        .Join(models.GetTable<InvoiceAllowance>(), p => p.AllowanceID, a => a.AllowanceID, (p, a) => a);

                    r = table.NewRow();
                    r[0] = branch.BranchName;
                    r[2] = branchItems.Sum(t => (int)t[2]);
                    var dataItems = branchItems.Where(p => (String)p[3] == Naming.PaymentTransactionType.體能顧問費.ToString());
                    r[3] = dataItems.Sum(t => (int)t[2]);
                    r[4] = -allowanceItems.Sum(a => a.TotalAmount + a.TaxAmount) ?? 0;

                    dataItems = branchItems.Where(p => (String)p[3] == Naming.PaymentTransactionType.自主訓練.ToString());
                    r[10] = dataItems.Sum(t => (int)t[2]);

                    dataItems = branchItems.Where(p => (String)p[3] == Naming.PaymentTransactionType.運動商品.ToString()
                                                || (String)p[3] == Naming.PaymentTransactionType.食飲品.ToString());
                    r[12] = dataItems.Sum(t => (int)t[2]);

                    decimal total = Math.Max((int)r[2], 1);
                    r[5] = Math.Round((int)r[3] * 100m / total);
                    r[11] = Math.Round((int)r[10] * 100m / total);
                    r[13] = Math.Round((int)r[12] * 100m / total);

                    dataItems = branchItems.Where(p => !p.IsNull(8) && (String)p[8] == "否");
                    r[6] = dataItems.Sum(t => (int)t[2]);
                    dataItems = branchItems.Where(p => !p.IsNull(8) && (String)p[8] == "是");
                    r[8] = dataItems.Sum(t => (int)t[2]);


                    total = Math.Max((int)r[3], 1);
                    r[7] = Math.Round((int)r[6] * 100m / total);
                    r[9] = Math.Round((int)r[8] * 100m / total);
                    r[1] = (int)r[2] + (int)r[4];
                    table.Rows.Add(r);
                }

                r = table.NewRow();
                r[0] = "總計";
                var data = table.Rows.Cast<DataRow>();
                foreach (int idx in (new int[] { 1, 2, 3, 4, 6, 8, 10, 12 }))
                {
                    r[idx] = data.Sum(d => (int)d[idx]);
                }
                decimal totalAmt = Math.Max((int)r[2], 1);
                r[5] = Math.Round((int)r[3] * 100m / totalAmt);
                r[11] = Math.Round((int)r[10] * 100m / totalAmt);
                r[13] = Math.Round((int)r[12] * 100m / totalAmt);

                totalAmt = Math.Max((int)r[3], 1);
                r[7] = Math.Round((int)r[6] * 100m / totalAmt);
                r[9] = Math.Round((int)r[8] * 100m / totalAmt);

                table.Rows.Add(r);
                return table;
            }

            DataTable buildCoachBranchDetails()
            {
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("所屬分店", typeof(String)));
                table.Columns.Add(new DataColumn("實際收款業績", typeof(int)));
                table.Columns.Add(new DataColumn("分潤業績", typeof(int)));
                table.Columns.Add(new DataColumn("體能顧問費", typeof(int)));
                table.Columns.Add(new DataColumn("終止折讓金額", typeof(int)));
                table.Columns.Add(new DataColumn("體能顧問費佔比(%)", typeof(int)));
                table.Columns.Add(new DataColumn("新約體能顧問費", typeof(int)));
                table.Columns.Add(new DataColumn("新約佔比(%)", typeof(int)));
                table.Columns.Add(new DataColumn("續約體能顧問費", typeof(int)));
                table.Columns.Add(new DataColumn("續約佔比(%)", typeof(int)));
                table.Columns.Add(new DataColumn("P.I Session", typeof(int)));
                table.Columns.Add(new DataColumn("P.I Session佔比(%)", typeof(int)));
                table.Columns.Add(new DataColumn("其他販售商品及手續費收入", typeof(int)));
                table.Columns.Add(new DataColumn("其他販售商品及手續費收入占比(%)", typeof(int)));


                DataRow r;

                var branchName = models.GetTable<BranchStore>().Select(b => b.BranchName).ToList();
                branchName.Add("其他");
                foreach (var branch in branchName)
                {
                    var branchItems = tableItems.Where(t => (String)t[7] == branch);
                    var branchVoidItems = tableVoidItems.Where(t => (String)t[7] == branch);

                    r = table.NewRow();
                    r[0] = branch;
                    r[2] = branchItems.Sum(t => (int)t[2]);
                    var dataItems = branchItems.Where(p => (String)p[3] == Naming.PaymentTransactionType.體能顧問費.ToString());
                    r[3] = dataItems.Sum(t => (int)t[2]);

                    dataItems = branchVoidItems.Where(p => (String)p[3] == Naming.PaymentTransactionType.體能顧問費.ToString());
                    r[4] = dataItems.Sum(t => t.IsNull(2) ? 0 : (int)t[2]);

                    dataItems = branchItems.Where(p => (String)p[3] == Naming.PaymentTransactionType.自主訓練.ToString());
                    r[10] = dataItems.Sum(t => (int)t[2]);

                    dataItems = branchItems.Where(p => (String)p[3] == Naming.PaymentTransactionType.運動商品.ToString()
                                                || (String)p[3] == Naming.PaymentTransactionType.食飲品.ToString());
                    r[12] = dataItems.Sum(t => (int)t[2]);

                    decimal total = Math.Max((int)r[2], 1);
                    r[5] = Math.Round((int)r[3] * 100m / total);
                    r[11] = Math.Round((int)r[10] * 100m / total);
                    r[13] = Math.Round((int)r[12] * 100m / total);

                    dataItems = branchItems.Where(p => !p.IsNull(8) && (String)p[8] == "否");
                    r[6] = dataItems.Sum(t => (int)t[2]);
                    dataItems = branchItems.Where(p => !p.IsNull(8) && (String)p[8] == "是");
                    r[8] = dataItems.Sum(t => (int)t[2]);

                    total = Math.Max((int)r[3], 1);
                    r[7] = Math.Round((int)r[6] * 100m / total);
                    r[9] = Math.Round((int)r[8] * 100m / total);
                    r[1] = (int)r[2] + (int)r[4];
                    table.Rows.Add(r);
                }

                r = table.NewRow();
                r[0] = "總計";
                var data = table.Rows.Cast<DataRow>();
                foreach (int idx in (new int[] { 1, 2, 3, 4, 6, 8, 10, 12 }))
                {
                    r[idx] = data.Sum(d => (int)d[idx]);
                }
                decimal totalAmt = Math.Max((int)r[2], 1);
                r[5] = Math.Round((int)r[3] * 100m / totalAmt);
                r[11] = Math.Round((int)r[10] * 100m / totalAmt);
                r[13] = Math.Round((int)r[12] * 100m / totalAmt);

                totalAmt = Math.Max((int)r[3], 1);
                r[7] = Math.Round((int)r[6] * 100m / totalAmt);
                r[9] = Math.Round((int)r[8] * 100m / totalAmt);

                table.Rows.Add(r);

                return table;
            }

            DataTable buildCoachDetails()
            {
                //							
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("體能顧問", typeof(String)));
                table.Columns.Add(new DataColumn("所屬分店", typeof(String)));
                table.Columns.Add(new DataColumn("實際收款業績", typeof(int)));
                table.Columns.Add(new DataColumn("分潤業績", typeof(int)));
                table.Columns.Add(new DataColumn("終止折讓金額", typeof(int)));
                table.Columns.Add(new DataColumn("體能顧問費", typeof(int)));
                table.Columns.Add(new DataColumn("體能顧問費佔比(%)", typeof(int)));
                table.Columns.Add(new DataColumn("新約體能顧問費", typeof(int)));
                table.Columns.Add(new DataColumn("新約佔比(%)", typeof(int)));
                table.Columns.Add(new DataColumn("續約體能顧問費", typeof(int)));
                table.Columns.Add(new DataColumn("續約佔比(%)", typeof(int)));
                table.Columns.Add(new DataColumn("P.I Session", typeof(int)));
                table.Columns.Add(new DataColumn("P.I Session佔比(%)", typeof(int)));
                table.Columns.Add(new DataColumn("其他販售商品及手續費收入", typeof(int)));
                table.Columns.Add(new DataColumn("其他販售商品及手續費收入占比(%)", typeof(int)));

                DataRow r;

                var coachItems = tableItems.GroupBy(l => (String)l[0])
                                    .OrderBy(g => g.First()[7]);
                foreach (var g in coachItems)
                {
                    r = table.NewRow();
                    var coachVoidItems = tableVoidItems.Where(t => (String)t[0] == g.Key);

                    r[0] = g.Key;
                    r[1] = g.First()[7];
                    r[3] = g.Sum(t => (int)t[2]);
                    var dataItems = g.Where(p => (String)p[3] == Naming.PaymentTransactionType.體能顧問費.ToString());
                    r[5] = dataItems.Sum(t => (int)t[2]);
                    r[4] = coachVoidItems.Any()
                        ? coachVoidItems.Sum(t => (int)t[2])
                        : 0;

                    dataItems = g.Where(p => (String)p[3] == Naming.PaymentTransactionType.自主訓練.ToString());
                    r[11] = dataItems.Sum(t => (int)t[2]);

                    dataItems = g.Where(p => (String)p[3] == Naming.PaymentTransactionType.運動商品.ToString()
                                                || (String)p[3] == Naming.PaymentTransactionType.食飲品.ToString());
                    r[13] = dataItems.Sum(t => (int)t[2]);

                    decimal total = Math.Max((int)r[3], 1);
                    r[6] = Math.Round((int)r[5] * 100m / total);
                    r[12] = Math.Round((int)r[11] * 100m / total);
                    r[14] = Math.Round((int)r[13] * 100m / total);

                    dataItems = g.Where(p => !p.IsNull(8) && (String)p[8] == "否");
                    r[7] = dataItems.Sum(t => (int)t[2]);
                    dataItems = g.Where(p => !p.IsNull(8) && (String)p[8] == "是");
                    r[9] = dataItems.Sum(t => (int)t[2]);

                    total = Math.Max((int)r[5], 1);
                    r[8] = Math.Round((int)r[7] * 100m / total);
                    r[10] = Math.Round((int)r[9] * 100m / total);
                    r[2] = (int)r[3] + (int)r[4];

                    table.Rows.Add(r);
                }

                r = table.NewRow();
                r[0] = "總計";
                var data = table.Rows.Cast<DataRow>();
                foreach (int idx in (new int[] { 2, 3, 4, 5, 7, 9, 11, 13 }))
                {
                    r[idx] = data.Sum(d => (int)d[idx]);
                }
                decimal totalAmt = Math.Max((int)r[3], 1);
                r[6] = Math.Round((int)r[5] * 100m / totalAmt);
                r[12] = Math.Round((int)r[11] * 100m / totalAmt);
                r[14] = Math.Round((int)r[13] * 100m / totalAmt);

                totalAmt = Math.Max((int)r[5], 1);
                r[8] = Math.Round((int)r[7] * 100m / totalAmt);
                r[10] = Math.Round((int)r[9] * 100m / totalAmt);
                table.Rows.Add(r);
                return table;
            }

            using (DataSet ds = new DataSet())
            {
                var table = buildBranchDetails();
                table.TableName = $"{viewModel.PayoffDateFrom:yyyyMM} 簽約場所彙總(含稅)";
                ds.Tables.Add(table);

                table = buildCoachBranchDetails();
                table.TableName = $"{viewModel.PayoffDateFrom:yyyyMM} 體能顧問所屬分店彙總(含稅)";
                ds.Tables.Add(table);

                table = buildCoachDetails();
                table.TableName = $"{viewModel.PayoffDateFrom:yyyyMM} 體能顧問彙總(含稅)";
                ds.Tables.Add(table);

                ds.Tables.Add(details);
                ds.Tables.Add(voidDetails);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("DividedAchievementSummary"), DateTime.Now), viewModel.FileDownloadToken);

            }

            return new EmptyResult();
        }

        public async Task<ActionResult> CreateMonthlyBonusXlsxAsync(AchievementQueryViewModel viewModel)
        {
            if (!viewModel.AchievementDateFrom.HasValue)
            {
                viewModel.AchievementDateFrom = DateTime.Today.FirstDayOfMonth();
            }
            viewModel.AchievementDateTo = viewModel.AchievementDateFrom.Value.AddMonths(1);

            IQueryable<CoachMonthlySalary> items = viewModel.InquireMonthlySalary(models);

            IEnumerable<CoachMonthlySalary> salaryItems = (IEnumerable<CoachMonthlySalary>)items;
            var branchItems = models.GetTable<BranchStore>().ToArray();
            int branchColIdx;
            bool rule2020 = viewModel.AchievementDateFrom >= new DateTime(2020, 1, 1);

            DataTable buildManagerBonusList()
            {
                //						
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("姓名", typeof(String)));
                table.Columns.Add(new DataColumn("所屬分店", typeof(String)));
                table.Columns.Add(new DataColumn("職級", typeof(String)));
                table.Columns.Add(new DataColumn("個人上課數", typeof(decimal)));
                table.Columns.Add(new DataColumn("分店總上課數", typeof(int)));
                table.Columns.Add(new DataColumn("總獎金", typeof(int)));
                table.Columns.Add(new DataColumn("管理獎金", typeof(int)));
                table.Columns.Add(new DataColumn("特別獎金", typeof(int)));
                table.Columns.Add(new DataColumn("上課獎金", typeof(int)));

                DataRow r;

                var coachItems = rule2020
                    ? salaryItems.Where(s => s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.Special
                                    || s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.FM
                                    || s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.AFM
                                    || s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.FES)
                    : salaryItems.Where(s => s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.Special
                                    || s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.FM);

                foreach (var g in coachItems.OrderBy(c => c.WorkPlace))
                {
                    r = table.NewRow();

                    r[0] = g.ServingCoach.UserProfile.FullName();
                    r[1] = g.BranchStore?.BranchName ?? "其他";
                    r[2] = g.ProfessionalLevel.LevelName;
                    r[3] = g.CoachBranchMonthlyBonus.Sum(b => b.AchievementAttendanceCount);
                    r[4] = g.CoachBranchMonthlyBonus.Where(b => b.BranchTotalAttendanceCount.HasValue)
                                .Sum(b => b.BranchTotalAttendanceCount);
                    r[6] = g.ManagerBonus ?? 0;
                    r[7] = g.SpecialBonus ?? 0;

                    table.Rows.Add(r);
                }
                return table;
            }

            DataTable buildCoachBonusList()
            {
                //														
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("姓名", typeof(String)));
                table.Columns.Add(new DataColumn("所屬分店", typeof(String)));
                table.Columns.Add(new DataColumn("P.T Level", typeof(String)));
                table.Columns.Add(new DataColumn("上課數", typeof(decimal)));
                table.Columns.Add(new DataColumn("上課金額", typeof(int)));
                table.Columns.Add(new DataColumn("上課獎金抽成(%)", typeof(decimal)));
                table.Columns.Add(new DataColumn("業績金額", typeof(int)));
                table.Columns.Add(new DataColumn("業績獎金抽成(%)", typeof(decimal)));
                table.Columns.Add(new DataColumn("總獎金", typeof(int)));
                table.Columns.Add(new DataColumn("管理獎金", typeof(int)));
                table.Columns.Add(new DataColumn("特別獎金", typeof(int)));
                table.Columns.Add(new DataColumn("月中上課+業績獎金", typeof(int)));
                table.Columns.Add(new DataColumn("上課總獎金", typeof(int)));
                branchColIdx = 13;
                for (int i = 0; i < branchItems.Length; i++)
                {
                    table.Columns.Add(new DataColumn($"上課獎金（地點：{branchItems[i].BranchName}）", typeof(int)));
                }
                table.Columns.Add(new DataColumn("業績獎金", typeof(int)));

                DataRow r;

                var coachItems = rule2020
                    ? salaryItems.Where(s => s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.Special
                                    && s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.FM
                                    && s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.AFM
                                    && s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.FES)
                    : salaryItems.Where(s => s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.Special
                                    && s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.FM);

                List<DataRow> rows = new List<DataRow>();
                foreach (var g in coachItems)
                {
                    r = table.NewRow();

                    r[0] = g.ServingCoach.UserProfile.FullName();
                    r[1] = g.BranchStore?.BranchName ?? "其他";
                    r[2] = g.ProfessionalLevel.LevelName;
                    r[3] = g.CoachBranchMonthlyBonus.Sum(b => b.AchievementAttendanceCount);
                    r[4] = g.CoachBranchMonthlyBonus.Where(b => b.Tuition.HasValue)
                                .Sum(b => b.Tuition);
                    r[5] = g.GradeIndex;
                    r[6] = g.PerformanceAchievement;
                    r[7] = g.AchievementShareRatio;
                    r[9] = g.ManagerBonus ?? 0;
                    r[10] = g.SpecialBonus ?? 0;

                    r[12] = g.CoachBranchMonthlyBonus.Sum(b => b.AttendanceBonus);
                    for (int i = 0; i < branchItems.Length; i++)
                    {
                        var br = g.CoachBranchMonthlyBonus.Where(b => b.BranchID == branchItems[i].BranchID).FirstOrDefault();
                        if (br != null)
                        {
                            if (br.AttendanceBonus.HasValue)
                            {
                                r[branchColIdx + i] = br.AttendanceBonus;
                            }
                        }
                    }

                    r[branchColIdx + branchItems.Length] = g.PerformanceAchievement * g.AchievementShareRatio / 100m;

                    rows.Add(r);
                }

                List<int> taxCol = new List<int> { 4, 6, 12 };
                for (int i = 0; i < branchItems.Length; i++)
                {
                    taxCol.Add(branchColIdx + i);
                }
                taxCol.Add(branchColIdx + branchItems.Length);

                foreach (var t in rows)
                {
                    eliminateTax(t, taxCol);
                    t[12] = 0;
                    for (int i = 0; i < branchItems.Length; i++)
                    {
                        t[12] = (int)t[12] + (int)t[branchColIdx + i];
                    }
                    t[11] = (int)t[12] + (int)t[branchColIdx + branchItems.Length];
                    t[8] = (int)t[9] + (int)t[10] + (int)t[11];
                }
                //rows.RemoveAll(t => (int)t[8] == 0);

                foreach (var t in rows.OrderBy(t => t[1]))
                {
                    table.Rows.Add(t);
                }

                return table;
            }

            DataTable buildAttendanceBonusSummary(DataTable source)
            {
                //		
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("上課場所", typeof(String)));
                table.Columns.Add(new DataColumn("上課獎金（含稅）", typeof(int)));
                table.Columns.Add(new DataColumn("上課獎金（未稅）", typeof(int)));

                DataRow r;
                var rowItems = source.Rows.Cast<DataRow>();
                for (int i = 0; i < branchItems.Length; i++)
                {
                    r = table.NewRow();

                    r[0] = branchItems[i].BranchName;
                    r[2] = rowItems.Where(t => t[branchColIdx + i] is int).Sum(t => (int)t[branchColIdx + i]);
                    r[1] = Math.Round((int)r[2] * 1.05);
                    table.Rows.Add(r);
                }

                r = table.NewRow();
                r[0] = "總計";
                var data = table.Rows.Cast<DataRow>();
                foreach (int idx in (new int[] { 1, 2 }))
                {
                    r[idx] = data.Where(d => d[idx] != DBNull.Value)
                        .Sum(d => (int?)d[idx]);
                }
                table.Rows.Add(r);

                return table;
            }

            DataTable buildCoachBranchSummary(DataTable source)
            {
                //		
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("上課場所", typeof(String)));
                table.Columns.Add(new DataColumn("業績獎金（含稅）", typeof(int)));
                table.Columns.Add(new DataColumn("業績獎金（未稅）", typeof(int)));

                DataRow r;
                var rowItems = source.Rows.Cast<DataRow>();
                foreach (var g in branchItems)
                {
                    r = table.NewRow();

                    r[0] = g.BranchName;
                    r[2] = rowItems.Where(t => (String)t[1] == g.BranchName).Sum(t => (int)t[branchColIdx + branchItems.Length]);
                    r[1] = Math.Round((int)r[2] * 1.05);
                    table.Rows.Add(r);
                }
                r = table.NewRow();

                r[0] = "總計";
                var data = table.Rows.Cast<DataRow>();
                foreach (int idx in (new int[] { 1, 2 }))
                {
                    r[idx] = data.Where(d => d[idx] != DBNull.Value)
                        .Sum(d => (int)d[idx]);
                }
                table.Rows.Add(r);

                return table;
            }

            void eliminateTax(DataRow row, IEnumerable<int> colIdx)
            {
                foreach (int i in colIdx)
                {
                    if (row[i] == DBNull.Value)
                    {
                        row[i] = 0;
                    }
                    else
                    {
                        row[i] = Math.Round((int)row[i] / 1.05);
                    }
                }
            }

            using (DataSet ds = new DataSet())
            {
                var table = buildManagerBonusList();
                table.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 獎金清單 - 主管(未稅)";
                ds.Tables.Add(table);

                var details = buildCoachBonusList();
                details.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 獎金清單 - 教練(未稅)";
                ds.Tables.Add(details);

                table = buildAttendanceBonusSummary(details);
                table.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 上課獎金彙總 - 上課場所";
                ds.Tables.Add(table);

                table = buildCoachBranchSummary(details);
                table.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 業績獎金彙總 - 教練所屬分店";
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("AchievementBonusList"), DateTime.Now), viewModel.FileDownloadToken);

            }

            return new EmptyResult();
        }

        enum ManagerBonusFields
        {
            姓名 = 0,
            所屬分店 = 1,
            職級 = 2,
            個人上課數 = 3,
            底薪 = 4,
            職務加給 = 5,
            分店總上課數 = 6,
            分店上課金額 = 7,
            總獎金 = 8,
            管理獎金 = 9,
            特別獎金 = 10,
            上課獎金 = 11,
            分店業績達成率百分比 = 12,
            滾動式堂數 = 13,
            滾動式平均單價 = 14,
            滾動式抽成 = 15,
        }

        enum ManagerYearlyBonusFields
        {
            姓名 = 0,
            所屬分店 = 1,
            職級 = 2,
            個人上課數 = 3,
            分店總上課數 = 4,
            分店上課金額 = 5,
            總獎金 = 6,
            管理獎金 = 7,
            特別獎金 = 8,
            上課獎金 = 9,
            分店業績達成率百分比 = 10,
        }

        //  

        enum CoachBonusFields
        {
            姓名 = 0,
            所屬分店 = 1,
            PT_Level = 2,
            底薪 = 3,
            職務加給 = 4,
            總上課數 = 5,
            上課抽成單價 = 6,
            PT_Session課數 = 7,
            上課獎金抽成百分比 = 8,
            業績金額 = 9,
            業績獎金抽成百分比 = 10,
            總獎金 = 11,
            管理獎金 = 12,
            特別獎金 = 13,
            月中上課加業績獎金 = 14,
            上課獎金 = 15,
            業績獎金 = 16,
            滾動式堂數 = 17,
            滾動式平均單價 = 18,
            滾動式抽成 = 19,
        }

        enum CoachYearlyBonusFields
        {
            姓名 = 0,
            所屬分店 = 1,
            PT_Level = 2,
            總上課數 = 3,
            上課平均抽成單價 = 4,
            PT_Session課數 = 5,
            每月平均PT_Session課數 = 6,
            上課獎金抽成百分比 = 7,
            業績金額 = 8,
            每月平均業績金額 = 9,
            業績獎金平均抽成百分比 = 10,
            總獎金 = 11,
            管理獎金 = 12,
            特別獎金 = 13,
            年終上課加業績獎金 = 14,
            上課獎金 = 15,
            業績獎金 = 16,
            工作月數 = 17,
        }

        public async Task<ActionResult> CreateMonthlyBonusXlsx2022Async(AchievementQueryViewModel viewModel)
        {
            if (!viewModel.AchievementDateFrom.HasValue)
            {
                viewModel.AchievementDateFrom = DateTime.Today.FirstDayOfMonth();
            }
            viewModel.AchievementDateTo = viewModel.AchievementDateFrom.Value.AddMonths(1);

            IQueryable<CoachMonthlySalary> items = viewModel.InquireMonthlySalary(models);

            IEnumerable<CoachMonthlySalary> salaryItems = (IEnumerable<CoachMonthlySalary>)items;
            var branchItems = models.GetTable<BranchStore>().ToArray();
            bool rule2020 = viewModel.AchievementDateFrom >= new DateTime(2020, 1, 1);

            DataTable buildManagerBonusList()
            {
                //						
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn(ManagerBonusFields.姓名.ToString(), typeof(String)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.所屬分店.ToString()	, typeof(String)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.職級.ToString(), typeof(String)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.個人上課數.ToString(), typeof(decimal)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.底薪.ToString(), typeof(decimal)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.職務加給.ToString(), typeof(decimal)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.分店總上課數.ToString()		, typeof(int)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.分店上課金額.ToString(), typeof(decimal)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.總獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.管理獎金.ToString()	, typeof(int)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.特別獎金.ToString()	, typeof(int)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.上課獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.分店業績達成率百分比.ToString(), typeof(decimal)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.滾動式堂數.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.滾動式平均單價.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(ManagerBonusFields.滾動式抽成.ToString(), typeof(int)));

                DataRow r;

                var coachItems = rule2020
                    ? salaryItems.Where(s => s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.Special
                                    || s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.FM
                                    || s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.AFM
                                    || s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.FES)
                    : salaryItems.Where(s => s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.Special
                                    || s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.FM);

                foreach (var g in coachItems.OrderBy(c => c.WorkPlace))
                {
                    r = table.NewRow();

                    r[(int)ManagerBonusFields.姓名] = g.ServingCoach.UserProfile.FullName();
                    r[(int)ManagerBonusFields.所屬分店] = g.BranchStore?.BranchName ?? "其他";
                    r[(int)ManagerBonusFields.職級] = g.ProfessionalLevel.LevelName;
                    r[(int)ManagerBonusFields.個人上課數] = g.CoachBranchMonthlyBonus.Sum(b => b.AchievementAttendanceCount);
                    //r[(int)ManagerBonusFields.分店總上課數] = g.CoachBranchMonthlyBonus.Where(b => b.BranchTotalAttendanceCount.HasValue)
                    //        .Sum(b => b.BranchTotalAttendanceCount);
                    r[(int)ManagerBonusFields.分店總上課數] = g.CoachBranchMonthlyBonus.Sum(b => b.BranchTotalPTCount) ?? 0;
                    r[(int)ManagerBonusFields.分店上課金額] = (int)(g.CoachBranchMonthlyBonus.Sum(b => b.BranchTotalPTTuition) / 1.05M + 0.5M ?? 0);
                    r[(int)ManagerBonusFields.管理獎金] = g.ManagerBonus ?? 0;
                    r[(int)ManagerBonusFields.特別獎金] = g.SpecialBonus ?? 0;
                    var salaryDetails = models.GetTable<MonthlySalaryDetails>()
                        .Where(s => s.UID == g.CoachID)
                        .Where(s => s.SettlementID == g.SettlementID).FirstOrDefault();
                    r[(int)ManagerBonusFields.底薪] = salaryDetails?.BasicWage ?? 0;
                    r[(int)ManagerBonusFields.職務加給] = salaryDetails?.DutyAllowance ?? 0;
                    //r[(int)ManagerBonusFields.底薪] = g.ProfessionalLevel.ProfessionalLevelBasicSalary?.SalaryDetails.PermanentWage ?? 0;
                    //r[(int)ManagerBonusFields.職務加給] = g.ServingCoach.UserProfile.EmployeeSalaryExtension?.DutyAllowance ?? 0;

                    r[(int)ManagerBonusFields.上課獎金] = g.AttendanceBonus ?? 0;
                    if (g.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.FM
                            || g.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.AFM)
                    {
                        var branchSummary = g.Settlement.BranchMonthlySummary.Where(s => s.BranchID == g.WorkPlace).FirstOrDefault();
                        if(branchSummary!=null)
                        {
                            r[(int)ManagerBonusFields.分店業績達成率百分比] = branchSummary.AchievementRatio;
                        }
                    }

                    r[(int)ManagerBonusFields.總獎金] = (int)r[(int)ManagerBonusFields.上課獎金] 
                        + (int)r[(int)ManagerBonusFields.管理獎金] 
                        + (int)r[(int)ManagerBonusFields.特別獎金];

                    r[(int)ManagerBonusFields.滾動式堂數] = g.AttendedByOther ?? 0;
                    r[(int)ManagerBonusFields.滾動式平均單價] = g.AttendedByOtherAvgPrice ?? 0;
                    r[(int)ManagerBonusFields.滾動式抽成] = g.AttendedShare ?? 0;

                    table.Rows.Add(r);
                }
                return table;
            }

            DataTable buildCoachBonusList()
            {
                //														
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn(CoachBonusFields.姓名.ToString(), typeof(String)));
                table.Columns.Add(new DataColumn(CoachBonusFields.所屬分店.ToString(), typeof(String)));
                table.Columns.Add(new DataColumn(CoachBonusFields.PT_Level.ToString(), typeof(String)));
                table.Columns.Add(new DataColumn(CoachBonusFields.底薪.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.職務加給.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.總上課數.ToString()	, typeof(decimal)));
                table.Columns.Add(new DataColumn(CoachBonusFields.上課抽成單價.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.PT_Session課數.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.上課獎金抽成百分比.ToString()			, typeof(decimal)));
                table.Columns.Add(new DataColumn(CoachBonusFields.業績金額.ToString()	, typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.業績獎金抽成百分比.ToString()			, typeof(decimal)));
                table.Columns.Add(new DataColumn(CoachBonusFields.總獎金.ToString()	, typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.管理獎金.ToString()	, typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.特別獎金.ToString()	, typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.月中上課加業績獎金.ToString()			, typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.上課獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.業績獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.滾動式堂數.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.滾動式平均單價.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachBonusFields.滾動式抽成.ToString(), typeof(int)));

                DataRow r;

                var coachItems = rule2020
                    ? salaryItems.Where(s => s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.Special
                                    && s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.FM
                                    && s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.AFM
                                    && s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.FES)
                    : salaryItems.Where(s => s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.Special
                                    && s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.FM);

                List<int> taxCol = new List<int>
                {
                    (int)CoachBonusFields.上課抽成單價,
                };

                List<DataRow> rows = new List<DataRow>();
                foreach (var g in coachItems)
                {
                    r = table.NewRow();

                    r[(int)CoachBonusFields.姓名] = g.ServingCoach.UserProfile.FullName();
                    r[(int)CoachBonusFields.所屬分店] = g.BranchStore?.BranchName ?? "其他";
                    r[(int)CoachBonusFields.PT_Level] = g.ProfessionalLevel.LevelName;
                    r[(int)CoachBonusFields.總上課數] = g.CoachBranchMonthlyBonus.Sum(b => b.AchievementAttendanceCount);
                    r[(int)CoachBonusFields.上課獎金抽成百分比] = g.GradeIndex;
                    r[(int)CoachBonusFields.業績金額] = (int)Math.Max((g.PerformanceAchievement.Value - g.VoidShare.Value) / 1.05M + 0.5M, 0);
                    r[(int)CoachBonusFields.業績獎金抽成百分比] = g.AchievementShareRatio ?? 0;
                    r[(int)CoachBonusFields.管理獎金] = g.ManagerBonus ?? 0;
                    r[(int)CoachBonusFields.特別獎金] = g.SpecialBonus ?? 0;

                    r[(int)CoachBonusFields.上課獎金] = g.AttendanceBonus ?? 0;
                    var salaryDetails = models.GetTable<MonthlySalaryDetails>()
                        .Where(s => s.UID == g.CoachID)
                        .Where(s => s.SettlementID == g.SettlementID).FirstOrDefault();
                    r[(int)CoachBonusFields.底薪] = salaryDetails?.BasicWage ?? 0;
                    r[(int)CoachBonusFields.職務加給] = salaryDetails?.DutyAllowance ?? 0;
                    //r[(int)CoachBonusFields.底薪] = g.ProfessionalLevel.ProfessionalLevelBasicSalary?.SalaryDetails.PermanentWage ?? 0;
                    //r[(int)CoachBonusFields.職務加給] = g.ServingCoach.UserProfile.EmployeeSalaryExtension?.DutyAllowance ?? 0;
                    r[(int)CoachBonusFields.上課抽成單價] = g.PTAverageUnitPrice ?? 0;
                    r[(int)CoachBonusFields.PT_Session課數] = g.PTAttendanceCount ?? 0;
                    r[(int)CoachBonusFields.業績獎金] = g.AchievementBonus ?? 0;
                    r[(int)CoachBonusFields.滾動式堂數] = g.AttendedByOther ?? 0;
                    r[(int)CoachBonusFields.滾動式平均單價] = g.AttendedByOtherAvgPrice ?? 0;
                    r[(int)CoachBonusFields.滾動式抽成] = g.AttendedShare ?? 0;

                    if (g.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.Health)
                    {
                        eliminateTax(r, taxCol);
                    }

                    rows.Add(r);
                }


                foreach (var t in rows)
                {
                    t[(int)CoachBonusFields.月中上課加業績獎金] = (int)t[(int)CoachBonusFields.上課獎金] + (int)t[(int)CoachBonusFields.業績獎金];
                    t[(int)CoachBonusFields.總獎金] = (int)t[(int)CoachBonusFields.管理獎金] + (int)t[(int)CoachBonusFields.特別獎金] + (int)t[(int)CoachBonusFields.月中上課加業績獎金];
                }
                //rows.RemoveAll(t => (int)t[(int)CoachBonusFields.總獎金] == 0);

                foreach (var t in rows.OrderBy(t => t[(int)CoachBonusFields.所屬分店]))
                {
                    table.Rows.Add(t);
                }

                return table;
            }

            DataTable buildCoachBranchSummary(DataTable source)
            {
                //		
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("上課場所", typeof(String)));
                table.Columns.Add(new DataColumn("業績獎金（含稅）", typeof(int)));
                table.Columns.Add(new DataColumn("業績獎金（未稅）", typeof(int)));

                DataRow r;
                var rowItems = source.Rows.Cast<DataRow>();
                foreach (var g in branchItems)
                {
                    r = table.NewRow();

                    r[0] = g.BranchName;
                    r[2] = rowItems.Where(t => (String)t[1] == g.BranchName).Sum(t => (int)t[(int)CoachBonusFields.業績獎金]);
                    r[1] = Math.Round((int)r[2] * 1.05);
                    table.Rows.Add(r);
                }
                r = table.NewRow();

                r[0] = "總計";
                var data = table.Rows.Cast<DataRow>();
                foreach (int idx in (new int[] { 1, 2}))
                {
                    r[idx] = data.Where(d => d[idx] != DBNull.Value)
                        .Sum(d => (int)d[idx]);
                }
                table.Rows.Add(r);

                return table;
            }

            void eliminateTax(DataRow row,IEnumerable<int> colIdx)
            {
                foreach (int i in colIdx)
                {
                    if (row[i] == DBNull.Value)
                    {
                        row[i] = 0;
                    }
                    else
                    {
                        row[i] = Math.Round((int)row[i] / 1.05);
                    }
                }
            }

            using (DataSet ds = new DataSet())
            {
                var table = buildManagerBonusList();
                table.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 獎金清單 - 主管(未稅)";
                ds.Tables.Add(table);

                var details = buildCoachBonusList();
                details.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 獎金清單 - 教練(未稅)";
                ds.Tables.Add(details);
                
                table = buildCoachBranchSummary(details);
                table.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 業績獎金彙總 - 教練所屬分店";
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("AchievementBonusList"), DateTime.Now), viewModel.FileDownloadToken);

            }

            return new EmptyResult();
        }

        public async Task<ActionResult> CreateFullAchievementXlsxAsync(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireAchievement(viewModel);
            IQueryable<V_Tuition> items = (IQueryable<V_Tuition>)result.Model;

            var lessonDetails = items.GroupBy(t => t.AttendingCoach);

            ViewResult tuitionResult = (ViewResult)await InquireTuitionAchievementAsync(viewModel);
            IQueryable<TuitionAchievement> achievementItems = (IQueryable<TuitionAchievement>)tuitionResult.Model;

            var achievementDetails = achievementItems.GroupBy(t => t.CoachID);

            var details = lessonDetails.Select(g => new _AchievementGroupItem
            {
                CoachID = g.Key.Value,
                LessonGroup = g
            }).ToList();

            foreach (var g in achievementDetails)
            {
                var item = details.Where(d => d.CoachID == g.Key).FirstOrDefault();
                if (item == null)
                {
                    item = new _AchievementGroupItem
                    {
                        CoachID = g.Key
                    };
                    details.Add(item);
                }
                item.AchievementGroup = g;
            }


            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("姓名", typeof(String)));
            table.Columns.Add(new DataColumn("總終點課數", typeof(decimal)));
            table.Columns.Add(new DataColumn("總鐘點費用", typeof(int)));
            table.Columns.Add(new DataColumn("等級", typeof(String)));
            table.Columns.Add(new DataColumn("實際抽成費用(含稅)", typeof(int)));
            table.Columns.Add(new DataColumn("實際抽成費用", typeof(decimal)));
            table.Columns.Add(new DataColumn("業績金額(含稅)", typeof(int)));
            table.Columns.Add(new DataColumn("業績金額", typeof(decimal)));

            foreach (var g in details)
            {
                var r = table.NewRow();
                var coach = models.GetTable<ServingCoach>().Where(u => u.CoachID == g.CoachID).First();
                r[0] = coach.UserProfile.RealName;
                if (g.LessonGroup != null)
                {
                    var item = g.LessonGroup;
                    int lessonID = item.First().LessonID;
                    var lesson = models.GetTable<LessonTime>().Where(l => l.LessonID == lessonID).First();
                    r[1] = item.Count() - (decimal)(item.LearnerPILesson().Count()) / 2m;
                    var lessons = item.ExclusivePILesson();
                    r[2] = models.CalcAchievement(lessons, out int shares);
                    r[3] = lesson.LessonTimeSettlement.ProfessionalLevel.LevelName;
                    r[4] = shares;
                    r[5] = Math.Round(shares / 1.05m);
                }
                if (g.AchievementGroup != null)
                {
                    IGrouping<int, TuitionAchievement> achievementItem = g.AchievementGroup;
                    r[6] = achievementItem.Sum(l => l.ShareAmount);
                    r[7] = Math.Round((int)r[6] / 1.05m);
                }

                table.Rows.Add(r);
            }
            table.TableName = "業績統計表" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo.Value.AddMonths(1).AddDays(-1));

            using (DataSet ds = new DataSet())
            {
                ds.Tables.Add(table);

                table = await createTuitionAchievementDetailsXlsxAsync(viewModel);
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("AchievementReport"), DateTime.Now), viewModel.FileDownloadToken);

            }

            return new EmptyResult();
        }

        public static readonly int?[] RegularPTSessionScope = new int?[]
                {
                        (int)Naming.LessonPriceStatus.一般課程,
                        (int)Naming.LessonPriceStatus.已刪除,
                        (int)Naming.LessonPriceStatus.團體學員課程,
                };
        public async Task<ActionResult> CreateAchievementSummaryXlsxAsync(AchievementQueryViewModel viewModel)
        {
            var detailsTable = createAchievementDetailsXlsx(viewModel, out IQueryable<V_Tuition> items);
            detailsTable.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 上課明細";

            var tableItems = detailsTable.Rows.Cast<DataRow>()
                                .Where(l => !l.IsNull(14));
            var otherItems = tableItems.Where(l => !l.IsNull(18));

            var given = models.GetTable<LessonPriceType>().Where(p => p.Status == (int)Naming.LessonPriceStatus.點數兌換課程);
            var givenPT = given.Where(p => p.LessonPriceProperty.Any(r => r.PropertyID == (int)Naming.LessonPriceFeature.一般課程))
                            .ToArray();
            var givenSR = given.Where(p => p.LessonPriceProperty.Any(r => r.PropertyID == (int)Naming.LessonPriceFeature.運動恢復課程))
                            .ToArray(); 
            var givenSD = given.Where(p => p.LessonPriceProperty.Any(r => r.PropertyID == (int)Naming.LessonPriceFeature.營養課程))
                            .ToArray();

            var ts = models.GetTable<LessonPriceType>().Where(p => p.Status == (int)Naming.LessonPriceStatus.體驗課程);
            var tsPT = ts.Where(p => p.LessonPriceProperty.Any(r => r.PropertyID == (int)Naming.LessonPriceFeature.一般課程))
                            .ToArray();
            var tsSR = ts.Where(p => p.LessonPriceProperty.Any(r => r.PropertyID == (int)Naming.LessonPriceFeature.運動恢復課程))
                            .ToArray();
            var tsSD = ts.Where(p => p.LessonPriceProperty.Any(r => r.PropertyID == (int)Naming.LessonPriceFeature.營養課程))
                            .ToArray();


            DateTime? idx = viewModel.AchievementDateFrom?.FirstDayOfMonth();

            DataTable buildBranchDetails()
            {
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("上課場所", typeof(String)));	        //	0
                table.Columns.Add(new DataColumn("P.T上課總數", typeof(int)));	        //	1
                table.Columns.Add(new DataColumn("P.T上課金額(含稅)", typeof(int)));	    //	2
                table.Columns.Add(new DataColumn("活動贈品P.T上課總數", typeof(int)));	//	3
                table.Columns.Add(new DataColumn("員工福利P.T上課總數", typeof(int)));   //	4
                table.Columns.Add(new DataColumn("C.S上課總數", typeof(int)));	        //	5
                table.Columns.Add(new DataColumn("T.S上課總數", typeof(int)));	        //	6
                table.Columns.Add(new DataColumn("P.I上課總數", typeof(int)));	        //	7
                table.Columns.Add(new DataColumn("A.T上課總數", typeof(int)));	        //	8
                table.Columns.Add(new DataColumn("A.T上課金額(含稅)", typeof(int)));	    //	9
                table.Columns.Add(new DataColumn("S.R上課總數", typeof(int)));	        //	10
                table.Columns.Add(new DataColumn("S.R上課金額(含稅)", typeof(int)));	    //	11
                table.Columns.Add(new DataColumn("S.D上課總數", typeof(int)));	        //	12
                table.Columns.Add(new DataColumn("S.D上課金額(含稅)", typeof(int)));	    //	13
                table.Columns.Add(new DataColumn("H.S上課總數", typeof(int)));	    //	14
                table.Columns.Add(new DataColumn("H.S上課金額(含稅)", typeof(int))); //	15
                table.Columns.Add(new DataColumn("C.S上課金額(含稅)", typeof(int)));      //	16
                table.Columns.Add(new DataColumn("活動贈品S.R上課總數", typeof(int)));      //	17
                table.Columns.Add(new DataColumn("活動贈品S.D上課總數", typeof(int)));      //	18
                table.Columns.Add(new DataColumn("T.S (P.T)上課總數", typeof(int)));      //	19
                table.Columns.Add(new DataColumn("T.S (S.R)上課總數", typeof(int)));      //	20
                table.Columns.Add(new DataColumn("T.S (S.D)上課總數", typeof(int)));      //	21

                DataRow r;

                foreach (var branch in models.GetTable<BranchStore>())
                {
                    var branchItems = tableItems.Where(l => (String)l[8] == branch.BranchName);
                    var branchOthers = otherItems.Where(l => (String)l[8] == branch.BranchName);
                    r = table.NewRow();
                    r[0] = branch.BranchName;

                    var dataItems = branchItems.Where(l => RegularPTSessionScope.Contains((int?)l[11]));
                    r[1] = dataItems.Sum(l => (int)l[6]);
                    r[2] = dataItems.Sum(l => (int)l[9]);
                    r[16] = r[2];

                    //dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.點數兌換課程);
                    dataItems = branchOthers.Where(l => givenPT.Any(p => p.PriceID == (int)l[18]));
                    r[3] = dataItems.Sum(l => (int)l[6]);
                    r[16] = (int)r[16] + dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.員工福利課程);
                    r[4] = dataItems.Sum(l => (int)l[6]);
                    r[16] = (int)r[16] + dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.體驗課程);
                    r[6] = dataItems.Sum(l => (int)l[6]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.自主訓練);
                    r[7] = dataItems.Sum(l => (int)l[6]);
                    //r[4] = dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.運動防護課程);
                    r[8] = dataItems.Sum(l => (int)l[6]);
                    r[9] = dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.運動恢復課程);
                    r[10] = dataItems.Sum(l => (int)l[6]);
                    r[11] = dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.營養課程);
                    r[12] = dataItems.Sum(l => (int)l[6]);
                    r[13] = dataItems.Sum(l => (int)l[9]);

                    dataItems = branchOthers.Where(l => givenSR.Any(p => p.PriceID == (int)l[18]));
                    r[17] = dataItems.Sum(l => (int)l[6]);
                    dataItems = branchOthers.Where(l => givenSD.Any(p => p.PriceID == (int)l[18]));
                    r[18] = dataItems.Sum(l => (int)l[6]);

                    dataItems = branchOthers.Where(l => tsPT.Any(p => p.PriceID == (int)l[18]));
                    r[19] = dataItems.Sum(l => (int)l[6]);
                    dataItems = branchOthers.Where(l => tsSR.Any(p => p.PriceID == (int)l[18]));
                    r[20] = dataItems.Sum(l => (int)l[6]);
                    dataItems = branchOthers.Where(l => tsSD.Any(p => p.PriceID == (int)l[18]));
                    r[21] = dataItems.Sum(l => (int)l[6]);

                    //P.T + 點數 + 員工
                    r[14] = (int)r[8] + (int)r[10] + (int)r[12];
                    r[5] = (int)r[1] + (int)r[3] + (int)r[4] + (int)r[14];
                    r[15] = (int)r[9] + (int)r[11] + (int)r[13];
                    r[16] = (int)r[15] + (int)r[16];

                    table.Rows.Add(r);
                }

                r = table.NewRow();
                r[0] = "總計";
                var data = table.Rows.Cast<DataRow>();
                for (int idx = 1; idx <= 21; idx++)
                {
                    r[idx] = data.Sum(d => (int)d[idx]);
                }
                table.Rows.Add(r);

                table.Columns[5].SetOrdinal(15);
                table.Columns[6].SetOrdinal(16);
                table.Columns[6].SetOrdinal(16);
                table.Columns[17].SetOrdinal(13);
                table.Columns[18].SetOrdinal(14);
                table.Columns[19].SetOrdinal(5);
                table.Columns[20].SetOrdinal(6);
                table.Columns[21].SetOrdinal(7);

                return table;
            }


            DataTable buildContractBranchDetails()
            {
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("簽約場所", typeof(String)));              //	0
                table.Columns.Add(new DataColumn("P.T上課總數", typeof(int)));              //	1
                table.Columns.Add(new DataColumn("P.T上課金額(含稅)", typeof(int)));        //	2
                table.Columns.Add(new DataColumn("活動贈品P.T上課總數", typeof(int)));      //	3
                table.Columns.Add(new DataColumn("員工福利P.T上課總數", typeof(int)));      //	4
                table.Columns.Add(new DataColumn("總上課數", typeof(int)));                 //	5
                table.Columns.Add(new DataColumn("T.S上課總數", typeof(int)));              //	6
                table.Columns.Add(new DataColumn("P.I上課總數", typeof(int)));              //	7
                table.Columns.Add(new DataColumn("A.T上課總數", typeof(int)));              //	8
                table.Columns.Add(new DataColumn("A.T上課金額(含稅)", typeof(int)));        //	9
                table.Columns.Add(new DataColumn("S.R上課總數", typeof(int)));              //	10
                table.Columns.Add(new DataColumn("S.R上課金額(含稅)", typeof(int)));        //	11
                table.Columns.Add(new DataColumn("S.D上課總數", typeof(int)));              //	12
                table.Columns.Add(new DataColumn("S.D上課金額(含稅)", typeof(int)));        //	13
                table.Columns.Add(new DataColumn("H.S上課總數", typeof(int)));         //	14
                table.Columns.Add(new DataColumn("H.S上課金額(含稅)", typeof(int)));	   //	15
                table.Columns.Add(new DataColumn("C.S上課金額(含稅)", typeof(int)));      //	16
                table.Columns.Add(new DataColumn("活動贈品S.R上課總數", typeof(int)));      //	17
                table.Columns.Add(new DataColumn("活動贈品S.D上課總數", typeof(int)));      //	18

                DataRow r;

                foreach (var branch in models.GetTable<BranchStore>())
                {
                    var branchItems = tableItems.Where(l => (String)l[2] == branch.BranchName);
                    var branchOthers = otherItems.Where(l => (String)l[8] == branch.BranchName);
                    r = table.NewRow();
                    r[0] = branch.BranchName;

                    var dataItems = branchItems.Where(l => RegularPTSessionScope.Contains((int?)l[11]));
                    r[1] = dataItems.Sum(l => (int)l[6]);
                    r[2] = dataItems.Sum(l => (int)l[9]);
                    r[16] = r[2];

                    //dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.點數兌換課程);
                    dataItems = branchOthers.Where(l => givenPT.Any(p => p.PriceID == (int)l[18]));
                    r[3] = dataItems.Sum(l => (int)l[6]);
                    r[16] = (int)r[16] + dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.員工福利課程);
                    r[4] = dataItems.Sum(l => (int)l[6]);
                    r[16] = (int)r[16] + dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.體驗課程);
                    r[6] = dataItems.Sum(l => (int)l[6]);                    

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.自主訓練);
                    r[7] = dataItems.Sum(l => (int)l[6]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.運動防護課程);
                    r[8] = dataItems.Sum(l => (int)l[6]);
                    r[9] = dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.運動恢復課程);
                    r[10] = dataItems.Sum(l => (int)l[6]);
                    r[11] = dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.營養課程);
                    r[12] = dataItems.Sum(l => (int)l[6]);
                    r[13] = dataItems.Sum(l => (int)l[9]);

                    dataItems = branchOthers.Where(l => givenSR.Any(p => p.PriceID == (int)l[18]));
                    r[17] = dataItems.Sum(l => (int)l[6]);
                    dataItems = branchOthers.Where(l => givenSD.Any(p => p.PriceID == (int)l[18]));
                    r[18] = dataItems.Sum(l => (int)l[6]);

                    //P.T + 點數 + 員工
                    r[14] = (int)r[8] + (int)r[10] + (int)r[12];
                    r[5] = (int)r[1] + (int)r[3] + (int)r[4] + (int)r[14];
                    r[15] = (int)r[9] + (int)r[11] + (int)r[13];
                    r[16] = (int)r[15] + (int)r[16];

                    table.Rows.Add(r);
                }

                r = table.NewRow();
                r[0] = "總計";
                var data = table.Rows.Cast<DataRow>();
                for (int idx = 1; idx <= 18; idx++)
                {
                    r[idx] = data.Sum(d => (int)d[idx]);
                }
                table.Rows.Add(r);

                table.Columns[6].SetOrdinal(16);
                table.Columns[6].SetOrdinal(16);
                table.Columns[17].SetOrdinal(14);
                table.Columns[18].SetOrdinal(15);

                return table;
            }

            DataTable buildCoachBranchDetails()
            {
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("所屬分店", typeof(String)));	//	0
                table.Columns.Add(new DataColumn("P.T上課總數", typeof(int)));	//	1
                table.Columns.Add(new DataColumn("P.T上課金額(含稅)", typeof(int)));  	//	2
                table.Columns.Add(new DataColumn("活動贈品P.T上課總數", typeof(int)));	//	3
                table.Columns.Add(new DataColumn("員工福利P.T上課總數", typeof(int)));   //	4
                table.Columns.Add(new DataColumn("C.S上課總數", typeof(int)));	//	5
                table.Columns.Add(new DataColumn("T.S上課總數", typeof(int)));	//	6
                table.Columns.Add(new DataColumn("P.I上課總數", typeof(int)));	//	7
                table.Columns.Add(new DataColumn("A.T上課總數", typeof(int)));	//	8
                table.Columns.Add(new DataColumn("A.T上課金額(含稅)", typeof(int)));	//	9
                table.Columns.Add(new DataColumn("S.R上課總數", typeof(int)));	//	10
                table.Columns.Add(new DataColumn("S.R上課金額(含稅)", typeof(int)));	//	11
                table.Columns.Add(new DataColumn("S.D上課總數", typeof(int)));	//	12
                table.Columns.Add(new DataColumn("S.D上課金額(含稅)", typeof(int)));	//	13
                table.Columns.Add(new DataColumn("H.S上課總數", typeof(int)));	//	14
                table.Columns.Add(new DataColumn("H.S上課金額(含稅)", typeof(int)));	//	15
                table.Columns.Add(new DataColumn("C.S上課金額(含稅)", typeof(int)));      //	16
                table.Columns.Add(new DataColumn("目標上課總數", typeof(int)));      //	17
                table.Columns.Add(new DataColumn("上課總數達成率(%)", typeof(int)));      //	18
                table.Columns.Add(new DataColumn("目標上課金額", typeof(int)));      //	19
                table.Columns.Add(new DataColumn("上課金額達成率(%)", typeof(int)));      //	20
                table.Columns.Add(new DataColumn("活動贈品S.R上課總數", typeof(int)));      //	21
                table.Columns.Add(new DataColumn("活動贈品S.D上課總數", typeof(int)));      //	22
                table.Columns.Add(new DataColumn("T.S (P.T)上課總數", typeof(int)));      //	23
                table.Columns.Add(new DataColumn("T.S (S.R)上課總數", typeof(int)));      //	24
                table.Columns.Add(new DataColumn("T.S (S.D)上課總數", typeof(int)));      //	25


                DataRow r;

                var branchList = models.GetTable<BranchStore>().Select(b => new KeyValuePair<int,String>(b.BranchID, b.BranchName)).ToList();
                branchList.Add(new KeyValuePair<int, string>(-1, "其他"));

                var indicator = models.GetTable<MonthlyIndicator>()
                    .Where(m => m.StartDate == idx)
                    .FirstOrDefault();

                foreach (var branch in branchList)
                {
                    var branchItems = tableItems.Where(l => (String)l[12] == branch.Value);
                    var branchOthers = otherItems.Where(l => (String)l[12] == branch.Value);
                    r = table.NewRow();
                    r[0] = branch.Value;

                    var dataItems = branchItems.Where(l => RegularPTSessionScope.Contains((int?)l[11]));
                    r[1] = dataItems.Sum(l => (int)l[6]);
                    r[2] = dataItems.Sum(l => (int)l[9]);
                    r[16] = r[2];

                    //dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.點數兌換課程);
                    dataItems = branchOthers.Where(l => givenPT.Any(p => p.PriceID == (int)l[18]));
                    r[3] = dataItems.Sum(l => (int)l[6]);
                    r[16] = (int)r[16] + dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.員工福利課程);
                    r[4] = dataItems.Sum(l => (int)l[6]);
                    r[16] = (int)r[16] + dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.體驗課程);
                    r[6] = dataItems.Sum(l => (int)l[6]);
                                        
                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.自主訓練);
                    r[7] = dataItems.Sum(l => (int)l[6]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.運動防護課程);
                    r[8] = dataItems.Sum(l => (int)l[6]);
                    r[9] = dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.運動恢復課程);
                    r[10] = dataItems.Sum(l => (int)l[6]);
                    r[11] = dataItems.Sum(l => (int)l[9]);

                    dataItems = branchItems.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.營養課程);
                    r[12] = dataItems.Sum(l => (int)l[6]);
                    r[13] = dataItems.Sum(l => (int)l[9]);

                    dataItems = branchOthers.Where(l => givenSR.Any(p => p.PriceID == (int)l[18]));
                    r[21] = dataItems.Sum(l => (int)l[6]);
                    dataItems = branchOthers.Where(l => givenSD.Any(p => p.PriceID == (int)l[18]));
                    r[22] = dataItems.Sum(l => (int)l[6]);

                    dataItems = branchOthers.Where(l => tsPT.Any(p => p.PriceID == (int)l[18]));
                    r[23] = dataItems.Sum(l => (int)l[6]);
                    dataItems = branchOthers.Where(l => tsSR.Any(p => p.PriceID == (int)l[18]));
                    r[24] = dataItems.Sum(l => (int)l[6]);
                    dataItems = branchOthers.Where(l => tsSD.Any(p => p.PriceID == (int)l[18]));
                    r[25] = dataItems.Sum(l => (int)l[6]);

                    //P.T + 點數 + 員工
                    r[14] = (int)r[8] + (int)r[10] + (int)r[12];
                    r[5] = (int)r[1] + (int)r[3] + (int)r[4] + (int)r[14];
                    r[15] = (int)r[9] + (int)r[11] + (int)r[13];
                    r[16] = (int)r[15] + (int)r[16];

                    var branchIndicator = indicator.MonthlyBranchIndicator.Where(b => b.BranchID == branch.Key).FirstOrDefault();
                    if(branchIndicator!=null)
                    {
                        var revenueGoal = branchIndicator
                            .MonthlyBranchRevenueIndicator.Where(r => r.MonthlyBranchRevenueGoal != null)
                                            .Select(r => r.MonthlyBranchRevenueGoal).FirstOrDefault();
                        if (revenueGoal != null)
                        {
                            if (revenueGoal.CompleteLessonsGoal > 0)
                            {
                                r[17] = revenueGoal.CompleteLessonsGoal;
                                r[18] = (int)Math.Round((int)r[5] * 100M / (int)r[17]);
                            }

                            if (revenueGoal.LessonTuitionGoal > 0)
                            {
                                r[19] = revenueGoal.LessonTuitionGoal;
                                r[20] = (int)Math.Round((int)r[16] * 100M / (int)r[19]);
                            }
                        }
                    }

                    table.Rows.Add(r);
                }

                r = table.NewRow();
                r[0] = "總計";
                var data = table.Rows.Cast<DataRow>();
                for (int idx = 1; idx <= 16; idx++)
                {
                    r[idx] = data.Sum(d => (int)d[idx]);
                }
                for (int idx = 21; idx <= 25; idx++)
                {
                    r[idx] = data.Sum(d => (int)d[idx]);
                }
                table.Rows.Add(r);

                table.Columns[5].SetOrdinal(15);
                table.Columns[6].SetOrdinal(16);
                table.Columns[6].SetOrdinal(16);
                table.Columns[21].SetOrdinal(16);
                table.Columns[22].SetOrdinal(17);
                table.Columns[23].SetOrdinal(5);
                table.Columns[24].SetOrdinal(6);
                table.Columns[25].SetOrdinal(7);

                return table;
            }

            DataTable buildCoachDetails()
            {
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("體能顧問", typeof(String)));	//	0
                table.Columns.Add(new DataColumn("所屬分店", typeof(String)));	//	1
                table.Columns.Add(new DataColumn("P.T上課總數", typeof(int)));	//	2
                table.Columns.Add(new DataColumn("P.T上課金額(含稅）", typeof(int)));  	//	3
                table.Columns.Add(new DataColumn("活動贈品P.T上課總數", typeof(int)));	//	4
                table.Columns.Add(new DataColumn("員工福利P.T上課總數", typeof(int)));   //	5
                table.Columns.Add(new DataColumn("C.S上課總數", typeof(int)));	//	6
                table.Columns.Add(new DataColumn("T.S上課總數", typeof(int)));	//	7
                table.Columns.Add(new DataColumn("P.I上課總數", typeof(int)));	//	8
                table.Columns.Add(new DataColumn("A.T上課總數", typeof(int)));	//	9
                table.Columns.Add(new DataColumn("A.T上課金額(含稅)", typeof(int)));	//	10
                table.Columns.Add(new DataColumn("S.R上課總數", typeof(int)));	//	11
                table.Columns.Add(new DataColumn("S.R上課金額(含稅)", typeof(int)));	//	12
                table.Columns.Add(new DataColumn("S.D上課總數", typeof(int)));	//	13
                table.Columns.Add(new DataColumn("S.D上課金額(含稅)", typeof(int)));	//	14
                table.Columns.Add(new DataColumn("H.S上課總數", typeof(int)));	//	15
                table.Columns.Add(new DataColumn("H.S上課金額(含稅)", typeof(int)));	//	16
                table.Columns.Add(new DataColumn("C.S上課金額(含稅)", typeof(int)));      //	17
                table.Columns.Add(new DataColumn("目標上課總數", typeof(int)));      //	18
                table.Columns.Add(new DataColumn("上課總數達成率(%)", typeof(int)));      //	19
                table.Columns.Add(new DataColumn("目標上課金額", typeof(int)));      //	20
                table.Columns.Add(new DataColumn("上課金額達成率(%)", typeof(int)));      //	21
                table.Columns.Add(new DataColumn("活動贈品S.R上課總數", typeof(int)));      //	22
                table.Columns.Add(new DataColumn("活動贈品S.D上課總數", typeof(int)));      //	23
                table.Columns.Add(new DataColumn("T.S (P.T)上課總數", typeof(int)));      //	24
                table.Columns.Add(new DataColumn("T.S (S.R)上課總數", typeof(int)));      //	25
                table.Columns.Add(new DataColumn("T.S (S.D)上課總數", typeof(int)));      //	26


                DataRow r;

                var coachItems = tableItems.GroupBy(l => (String)l[1])
                                    .OrderBy(g => g.First()[12]);
                foreach (var coach in coachItems)
                {
                    var coachOthers = otherItems.Where(l => (String)l[1] == coach.Key);
                    r = table.NewRow();
                    r[0] = coach.Key;
                    r[1] = (String)coach.First()[12];
                    var dataItems = coach.Where(l => RegularPTSessionScope.Contains((int?)l[11]));
                    r[2] = dataItems.Sum(l => (int)l[6]);
                    r[3] = dataItems.Sum(l => (int)l[9]);
                    r[17] = r[3];

                    //dataItems = coach.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.點數兌換課程);
                    dataItems = coachOthers.Where(l => givenPT.Any(p => p.PriceID == (int)l[18]));
                    r[4] = dataItems.Sum(l => (int)l[6]);
                    r[17] = (int)r[17] + dataItems.Sum(l => (int)l[9]);

                    dataItems = coach.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.員工福利課程);
                    r[5] = dataItems.Sum(l => (int)l[6]);
                    r[17] = (int)r[17] + dataItems.Sum(l => (int)l[9]);

                    dataItems = coach.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.體驗課程);
                    r[7] = dataItems.Sum(l => (int)l[6]);
                    r[17] = (int)r[17] + dataItems.Sum(l => (int)l[9]);

                    dataItems = coach.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.自主訓練);
                    r[8] = dataItems.Sum(l => (int)l[6]);

                    dataItems = coach.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.運動防護課程);
                    r[9] = dataItems.Sum(l => (int)l[6]);
                    r[10] = dataItems.Sum(l => (int)l[9]);

                    dataItems = coach.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.運動恢復課程);
                    r[11] = dataItems.Sum(l => (int)l[6]);
                    r[12] = dataItems.Sum(l => (int)l[9]);

                    dataItems = coach.Where(l => (int?)l[11] == (int)Naming.LessonPriceStatus.營養課程);
                    r[13] = dataItems.Sum(l => (int)l[6]);
                    r[14] = dataItems.Sum(l => (int)l[9]);

                    dataItems = coachOthers.Where(l => givenSR.Any(p => p.PriceID == (int)l[18]));
                    r[22] = dataItems.Sum(l => (int)l[6]);
                    dataItems = coachOthers.Where(l => givenSD.Any(p => p.PriceID == (int)l[18]));
                    r[23] = dataItems.Sum(l => (int)l[6]);

                    dataItems = coachOthers.Where(l => tsPT.Any(p => p.PriceID == (int)l[18]));
                    r[24] = dataItems.Sum(l => (int)l[6]);
                    dataItems = coachOthers.Where(l => tsSR.Any(p => p.PriceID == (int)l[18]));
                    r[25] = dataItems.Sum(l => (int)l[6]);
                    dataItems = coachOthers.Where(l => tsSD.Any(p => p.PriceID == (int)l[18]));
                    r[26] = dataItems.Sum(l => (int)l[6]);

                    //P.T + 點數 + 員工
                    r[15] = (int)r[9] + (int)r[11] + (int)r[13];
                    r[6] = (int)r[2] + (int)r[4] + (int)r[5] + (int)r[15];
                    r[16] = (int)r[10] + (int)r[12] + (int)r[14];
                    r[17] = (int)r[16] + (int)r[17];

                    var coachItem = models.GetTable<MonthlyIndicator>()
                        .Where(m => m.StartDate == idx)
                        .Join(models.GetTable<MonthlyCoachRevenueIndicator>().Where(c => c.CoachID == (int)coach.First()[16]),
                            m => m.PeriodID, c => c.PeriodID, (m, c) => c)
                        .FirstOrDefault();

                    if(coachItem != null)
                    {
                        if (coachItem.CompleteLessonsGoal > 0)
                        {
                            r[18] = coachItem.CompleteLessonsGoal;
                            r[19] = (int)Math.Round((int)r[6] * 100M / (int)r[18]);
                        }

                        if (coachItem.LessonTuitionGoal > 0)
                        {
                            r[20] = coachItem.LessonTuitionGoal;
                            r[21] = (int)Math.Round((int)r[17] * 100M / (int)r[20]);
                        }
                    }

                    table.Rows.Add(r);
                }

                r = table.NewRow();
                r[0] = "總計";
                var data = table.Rows.Cast<DataRow>();
                for (int idx = 2; idx <= 17; idx++)
                {
                    r[idx] = data.Sum(d => (int)d[idx]);
                }
                for (int idx = 22; idx <= 26; idx++)
                {
                    r[idx] = data.Sum(d => (int)d[idx]);
                }
                table.Rows.Add(r);

                table.Columns[6].SetOrdinal(16);
                table.Columns[7].SetOrdinal(17);
                table.Columns[7].SetOrdinal(17);
                table.Columns[22].SetOrdinal(17);
                table.Columns[23].SetOrdinal(18);
                table.Columns[24].SetOrdinal(6);
                table.Columns[25].SetOrdinal(7);
                table.Columns[26].SetOrdinal(8);

                return table;
            }

            using (DataSet ds = new DataSet())
            {
                var table = buildContractBranchDetails();
                table.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 簽約場所彙總";
                ds.Tables.Add(table);

                table = buildBranchDetails();
                table.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 上課場所彙總";
                ds.Tables.Add(table);

                table = buildCoachBranchDetails();
                table.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 體能顧問所屬分店彙總";
                ds.Tables.Add(table);

                table = buildCoachDetails();
                table.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 體能顧問彙總";
                ds.Tables.Add(table);

                detailsTable.Columns.RemoveAt(18);
                detailsTable.Columns.RemoveAt(14);
                detailsTable.Columns.RemoveAt(15);
                ds.Tables.Add(detailsTable);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("LessonAchievementSummary"), DateTime.Now), viewModel.FileDownloadToken);

            }

            return new EmptyResult();
        }


        public async Task<ActionResult> CreateAchievementXlsxAsync(AchievementQueryViewModel viewModel)
        {
            DataTable table;

            using (DataSet ds = new DataSet())
            {
                if (viewModel.DetailsOnly != true)
                {
                    table = createAchievementXlsx(viewModel);
                    if (viewModel.AchievementDateFrom.HasValue && viewModel.AchievementDateTo.HasValue)
                    {
                        table.TableName = "上課統計表" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo.Value.AddMonths(1).AddDays(-1));
                    }
                    ds.Tables.Add(table);
                    table = await createTuitionAchievementXlsxAsync(viewModel);
                    if (viewModel.AchievementDateFrom.HasValue && viewModel.AchievementDateTo.HasValue)
                    {
                        table.TableName = "業績統計表" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo.Value.AddMonths(1).AddDays(-1));
                    }
                    ds.Tables.Add(table);
                }
                if (viewModel.DetailsOnly != false)
                {
                    IQueryable<V_Tuition> items;
                    table = createAchievementDetailsXlsx(viewModel,out items);
                    table.TableName = String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo.Value.AddMonths(1).AddDays(-1));
                    ds.Tables.Add(table);
                }
                if (viewModel.DetailsOnly != true)
                {
                    table = await createTuitionAchievementDetailsXlsxAsync(viewModel);
                    ds.Tables.Add(table);
                }

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("LessonAchievementDetails"), DateTime.Now), viewModel.FileDownloadToken);

            }

            return new EmptyResult();
        }

        private DataTable createAchievementXlsx(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireAchievement(viewModel);
            IQueryable<V_Tuition> items = (IQueryable<V_Tuition>)result.Model;

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
                int lessonID = item.First().LessonID;
                var lesson = models.GetTable<LessonTime>().Where(l => l.LessonID == lessonID).First();
                var r = table.NewRow();
                var coach = models.GetTable<ServingCoach>().Where(u => u.CoachID == item.Key.CoachID).First();
                r[0] = coach.UserProfile.RealName;
                r[1] = item.Count() - (decimal)(item
                                    .Where(t => t.PriceStatus == (int)Naming.DocumentLevelDefinition.自主訓練
                                        || (t.ELStatus == (int)Naming.DocumentLevelDefinition.自主訓練)).Count()) / 2m;
                int shares;
                var lessons = item
                        .Where(t => t.PriceStatus != (int)Naming.DocumentLevelDefinition.自主訓練)
                        .Where(t => !t.ELStatus.HasValue
                            || t.ELStatus != (int)Naming.DocumentLevelDefinition.自主訓練);
                r[2] = models.CalcAchievement(lessons, out shares);
                r[3] = lesson.LessonTimeSettlement.ProfessionalLevel.LevelName;
                r[4] = shares;
                r[5] = Math.Round(shares / 1.05m);
                table.Rows.Add(r);
            }

            table.TableName = "上課統計表";
            return table;
        }

        private DataTable createAchievementDetailsXlsx(AchievementQueryViewModel viewModel,out IQueryable<V_Tuition> items)
        {
            viewModel.IgnoreAttendance = true;

            ViewResult result = (ViewResult)InquireAchievement(viewModel);
            items = (IQueryable<V_Tuition>)result.Model;

            return models.CreateLessonAchievementDetails(items);
        }

        private async Task<DataTable> createTuitionAchievementXlsxAsync(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquireTuitionAchievementAsync(viewModel);
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

        private async Task<DataTable> createTuitionAchievementDetailsXlsxAsync(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquireTuitionAchievementAsync(viewModel);
            IQueryable<TuitionAchievement> items = (IQueryable<TuitionAchievement>)result.Model;

            DataTable table = models.CreateTuitionAchievementDetails(items);

            return table;
        }

        public ActionResult ListPaymentHistory(CourseContractQueryViewModel viewModel)
        {
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            return View("~/Views/Accounting/Module/ContractPaymentList.ascx", item);
        }

        public async Task<ActionResult> ListTuitionSharesAsync(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquireTuitionAchievementAsync(viewModel);
            result.ViewName = "~/Views/Accounting/Module/TuitionAchievementShares.ascx";
            return result;
        }

        public async Task<ActionResult> CreateYearlyBonusXlsxAsync(AchievementQueryViewModel viewModel)
        {
            if (!viewModel.Year.HasValue)
            {
                viewModel.Year = DateTime.Today.Year; 
            }

            IQueryable<CoachYearlyAdditionalPay> items =
                models.GetTable<CoachYearlyAdditionalPay>()
                    .Where(p => p.Year == viewModel.Year);

            IEnumerable<CoachYearlyAdditionalPay> salaryItems = (IEnumerable<CoachYearlyAdditionalPay>)items;
            var branchItems = models.GetTable<BranchStore>().ToArray();

            DataTable buildManagerBonusList()
            {
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn(ManagerYearlyBonusFields.姓名.ToString(), typeof(String)));
                table.Columns.Add(new DataColumn(ManagerYearlyBonusFields.所屬分店.ToString(), typeof(String)));
                table.Columns.Add(new DataColumn(ManagerYearlyBonusFields.職級.ToString(), typeof(String)));
                table.Columns.Add(new DataColumn(ManagerYearlyBonusFields.個人上課數.ToString(), typeof(decimal)));
                table.Columns.Add(new DataColumn(ManagerYearlyBonusFields.分店總上課數.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(ManagerYearlyBonusFields.分店上課金額.ToString(), typeof(decimal)));
                table.Columns.Add(new DataColumn(ManagerYearlyBonusFields.總獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(ManagerYearlyBonusFields.管理獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(ManagerYearlyBonusFields.特別獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(ManagerYearlyBonusFields.上課獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(ManagerYearlyBonusFields.分店業績達成率百分比.ToString(), typeof(decimal)));

                DataRow r;

                var coachItems = salaryItems.Where(s => s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.Special
                                    || s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.FM
                                    || s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.AFM
                                    || s.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.FES);

                foreach (var g in coachItems.OrderBy(c => c.WorkPlace))
                {
                    r = table.NewRow();

                    var reviewItem = models.GetTable<V_YearlyReview>()
                                        .Where(s => s.Year == g.Year)
                                        .Where(s => s.CoachID == g.CoachID)
                                        .FirstOrDefault();

                    r[(int)ManagerYearlyBonusFields.姓名] = g.ServingCoach.UserProfile.FullName();
                    r[(int)ManagerYearlyBonusFields.所屬分店] = g.BranchStore?.BranchName ?? "其他";
                    r[(int)ManagerYearlyBonusFields.職級] = g.ProfessionalLevel.LevelName;
                    r[(int)ManagerYearlyBonusFields.個人上課數] = reviewItem?.AchievementAttendanceCount;
                    r[(int)ManagerYearlyBonusFields.分店總上課數] = reviewItem?.BranchTotalPTCount ?? 0;
                    r[(int)ManagerYearlyBonusFields.分店上課金額] = (int)((reviewItem?.BranchTotalPTTuition ?? 0M) / 1.05M + 0.5M);
                    r[(int)ManagerYearlyBonusFields.管理獎金] = g.ManagerBonus ?? 0;
                    r[(int)ManagerYearlyBonusFields.特別獎金] = g.SpecialBonus ?? 0;

                    r[(int)ManagerYearlyBonusFields.上課獎金] = g.AttendanceBonus ?? 0;
                    if (g.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.FM
                            || g.ProfessionalLevel.CategoryID == (int)Naming.ProfessionalCategory.AFM)
                    {
                        var branchSummary = models.GetTable<V_BranchYearlySummary>()
                                                .Where(s => s.Year == g.Year)
                                                .Where(s => s.BranchID == g.WorkPlace)
                                                .FirstOrDefault();
                        if (branchSummary!=null)
                        {
                            r[(int)ManagerYearlyBonusFields.分店業績達成率百分比] = Math.Round(branchSummary.AchievementRatio ?? 0M, 2);
                        }
                    }

                    r[(int)ManagerYearlyBonusFields.總獎金] = (int)r[(int)ManagerYearlyBonusFields.上課獎金]
                        + (int)r[(int)ManagerYearlyBonusFields.管理獎金]
                        + (int)r[(int)ManagerYearlyBonusFields.特別獎金];

                    table.Rows.Add(r);
                }
                return table;
            }

            DataTable buildCoachBonusList()
            {
                //														
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.姓名.ToString(), typeof(String)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.所屬分店.ToString(), typeof(String)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.PT_Level.ToString(), typeof(String)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.總上課數.ToString(), typeof(decimal)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.上課平均抽成單價.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.PT_Session課數.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.每月平均PT_Session課數.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.上課獎金抽成百分比.ToString(), typeof(decimal)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.業績金額.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.每月平均業績金額.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.業績獎金平均抽成百分比.ToString(), typeof(decimal)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.總獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.管理獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.特別獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.年終上課加業績獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.上課獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.業績獎金.ToString(), typeof(int)));
                table.Columns.Add(new DataColumn(CoachYearlyBonusFields.工作月數.ToString(), typeof(int)));

                DataRow r;

                var coachItems = salaryItems.Where(s => s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.Special
                                    && s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.FM
                                    && s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.AFM
                                    && s.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.FES);

                List<int> taxCol = new List<int>
                {
                    (int)CoachYearlyBonusFields.上課平均抽成單價,
                };

                List<DataRow> rows = new List<DataRow>();
                foreach (var g in coachItems)
                {
                    r = table.NewRow();

                    var reviewItem = models.GetTable<V_YearlyReview>()
                                        .Where(s => s.Year == g.Year)
                                        .Where(s => s.CoachID == g.CoachID)
                                        .FirstOrDefault();

                    r[(int)CoachYearlyBonusFields.姓名] = g.ServingCoach.UserProfile.FullName();
                    r[(int)CoachYearlyBonusFields.所屬分店] = g.BranchStore?.BranchName ?? "其他";
                    r[(int)CoachYearlyBonusFields.PT_Level] = g.ProfessionalLevel.LevelName;
                    r[(int)CoachYearlyBonusFields.總上課數] = reviewItem?.AchievementAttendanceCount;
                    r[(int)CoachYearlyBonusFields.上課平均抽成單價] = reviewItem?.PTAverageUnitPrice ?? 0;
                    r[(int)CoachYearlyBonusFields.PT_Session課數] = reviewItem.PTAttendanceCount ?? 0;
                    r[(int)CoachYearlyBonusFields.每月平均PT_Session課數] = reviewItem.PTAttendanceCountAVG ?? 0;
                    r[(int)CoachYearlyBonusFields.上課獎金抽成百分比] = g.GradeIndex;
                    r[(int)CoachYearlyBonusFields.業績金額] = (int)Math.Max(((reviewItem?.PerformanceAchievement - reviewItem?.VoidShare) ?? 0M) / 1.05M + 0.5M, 0);
                    r[(int)CoachYearlyBonusFields.每月平均業績金額] = (int)Math.Max(((reviewItem?.PerformanceAchievementAVG - reviewItem?.VoidShareAVG) ?? 0M) / 1.05M + 0.5M, 0);
                    r[(int)CoachYearlyBonusFields.業績獎金平均抽成百分比] = g.AchievementShareRatio ?? 0;
                    r[(int)CoachYearlyBonusFields.管理獎金] = g.ManagerBonus ?? 0;
                    r[(int)CoachYearlyBonusFields.特別獎金] = g.SpecialBonus ?? 0;

                    r[(int)CoachYearlyBonusFields.上課獎金] = g.AttendanceBonus ?? 0;
                    r[(int)CoachYearlyBonusFields.業績獎金] = g.AchievementBonus ?? 0;
                    r[(int)CoachYearlyBonusFields.年終上課加業績獎金] = (int)r[(int)CoachYearlyBonusFields.上課獎金] + (int)r[(int)CoachYearlyBonusFields.業績獎金];
                    r[(int)CoachYearlyBonusFields.工作月數] = reviewItem.DataCount ?? 0;

                    if (g.ProfessionalLevel.CategoryID != (int)Naming.ProfessionalCategory.Health)
                    {
                        eliminateTax(r, taxCol);
                    }

                    rows.Add(r);
                }


                foreach (var t in rows)
                {
                    t[(int)CoachYearlyBonusFields.總獎金] = (int)t[(int)CoachYearlyBonusFields.管理獎金] + (int)t[(int)CoachYearlyBonusFields.特別獎金] + (int)t[(int)CoachYearlyBonusFields.年終上課加業績獎金];
                }
                //rows.RemoveAll(t => (int)t[(int)CoachYearlyBonusFields.總獎金] == 0);

                foreach (var t in rows.OrderBy(t => t[(int)CoachYearlyBonusFields.所屬分店]))
                {
                    table.Rows.Add(t);
                }

                return table;
            }

            DataTable buildCoachBranchSummary(DataTable source)
            {
                //		
                DataTable table = new DataTable();
                table.Columns.Add(new DataColumn("上課場所", typeof(String)));
                table.Columns.Add(new DataColumn("業績獎金（含稅）", typeof(int)));
                table.Columns.Add(new DataColumn("業績獎金（未稅）", typeof(int)));

                DataRow r;
                var rowItems = source.Rows.Cast<DataRow>();
                foreach (var g in branchItems)
                {
                    r = table.NewRow();

                    r[0] = g.BranchName;
                    r[2] = rowItems.Where(t => (String)t[1] == g.BranchName).Sum(t => (int)t[(int)CoachYearlyBonusFields.業績獎金]);
                    r[1] = Math.Round((int)r[2] * 1.05);
                    table.Rows.Add(r);
                }
                r = table.NewRow();

                r[0] = "總計";
                var data = table.Rows.Cast<DataRow>();
                foreach (int idx in (new int[] { 1, 2 }))
                {
                    r[idx] = data.Where(d => d[idx] != DBNull.Value)
                        .Sum(d => (int)d[idx]);
                }
                table.Rows.Add(r);

                return table;
            }

            void eliminateTax(DataRow row, IEnumerable<int> colIdx)
            {
                foreach (int i in colIdx)
                {
                    if (row[i] == DBNull.Value)
                    {
                        row[i] = 0;
                    }
                    else
                    {
                        row[i] = Math.Round((int)row[i] / 1.05);
                    }
                }
            }

            using (DataSet ds = new DataSet())
            {
                var table = buildManagerBonusList();
                table.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 年終獎金清單 - 主管(未稅)";
                ds.Tables.Add(table);

                var details = buildCoachBonusList();
                details.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 年終獎金清單 - 教練(未稅)";
                ds.Tables.Add(details);

                table = buildCoachBranchSummary(details);
                table.TableName = $"{viewModel.AchievementDateFrom:yyyyMM} 年終業績獎金彙總 - 教練所屬分店";
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("AnnualAchievementBonusList"), DateTime.Now), viewModel.FileDownloadToken);

            }

            return new EmptyResult();
        }



    }
}