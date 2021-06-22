using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
using System.IO;
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
using WebHome.Controllers;
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
    [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class ReportConsoleController : SampleController<UserProfile>
    {
        // GET: ReportConsole
        public ActionResult SelectMonthlyReport()
        {
            return View("~/Views/ReportConsole/ReportModal/SelectMonthlyReport.cshtml");
        }
        public ActionResult SelectCoachMonthlyReport()
        {
            return View("~/Views/ReportConsole/ReportModal/SelectCoachMonthlyReport.cshtml");
        }

        public ActionResult SelectPeriodReport()
        {
            return View("~/Views/ReportConsole/ReportModal/SelectPeriodReport.cshtml");
        }

        public ActionResult SelectReportByContractNo()
        {
            ViewBag.ConditionView = "~/Views/ReportConsole/ReportModal/ByContractNo.cshtml";
            return View("~/Views/ReportConsole/ReportModal/SelectReportCondition.cshtml");
        }

        public ActionResult SelectAwardItem()
        {
            return View("~/Views/ReportConsole/ReportModal/SelectAwardItem.cshtml");
        }


        public ActionResult CreateContractQueryXlsx(CourseContractQueryViewModel viewModel)
        {
            IQueryable<CourseContract> items = viewModel.InquireContract(this, out string alertMessage);

            if (items.Count() == 0)
            {
                Response.AppendCookie(new HttpCookie("fileDownloadToken", viewModel.FileDownloadToken));
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "資料不存在!!");
            }

            var details = items
                .ToList()
                .Select(i => new
                {
                    合約編號 = i.ContractNo(),
                    合約名稱 = i.ContractName(),
                    學生 = i.ContractLearnerName("/"),
                    合約生效起日 = $"{i.EffectiveDate:yyyyMMdd}",
                    合約生效迄日 = $"{i.Expiration:yyyyMMdd}",
                    合約結束日 = $"{i.ValidTo:yyyyMMdd}",
                    合約總價金 = i.TotalCost,
                    專業顧問服務總費用 = (i.TotalCost * 8 + 5) / 10,
                    教練課程費 = (i.TotalCost * 2 + 5) / 10,
                    課程單價 = i.LessonPriceType.ListPrice,
                    單堂原價 = i.LessonPriceType.SeriesSingleLessonPrice(),
                    剩餘上課數 = i.RemainedLessonCount(false),
                    購買上課數 = i.Lessons,
                    其他更多說明 = i.Remark,
                    合約體能顧問 = i.ServingCoach.UserProfile.FullName(false),
                    簽約場所 = i.CourseContractExtension.BranchStore.BranchName,
                    狀態 = i.ContractCurrentStatus(),
                    應收款期限 = $"{i.PayoffDue:yyyyMMdd}",
                    累計收款金額 = i.TotalPaidAmount(),
                    累計收款次數 = i.TotalPayoffCount(),
                    遠距 = i.LessonPriceType.BranchStore.IsVirtualClassroom() ? "是" : "",
                });


            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AppendCookie(new HttpCookie("fileDownloadToken", viewModel.FileDownloadToken));
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("ContractDetails"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.TableName = $"{viewModel.EffectiveDateFrom:yyyyMMdd}~{viewModel.EffectiveDateTo.Value.AddDays(-1):yyyyMMdd}";

                ds.Tables.Add(table);

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        public ActionResult CreateContractServiceQueryXlsx(CourseContractQueryViewModel viewModel)
        {
            IQueryable<CourseContract> items = viewModel.InquireContract(this, out string alertMessage);

            if (items.Count() == 0)
            {
                Response.AppendCookie(new HttpCookie("fileDownloadToken", viewModel.FileDownloadToken));
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "資料不存在!!");
            }

            void buildDetails(DataSet ds, string reason)
            {
                var details = items.Join(models.GetTable<CourseContractRevision>().Where(r => r.Reason == reason),
                        c => c.ContractID, r => r.RevisionID, (c, r) => c)
                        .ToArray()
                        .Select(i => new
                        {
                            合約編號 = i.ContractNo(),
                            合約名稱 = i.ContractName(),
                            合約體能顧問 = i.ServingCoach.UserProfile.FullName(false),
                            簽約場所 = i.CourseContractExtension.BranchStore.BranchName,
                            學生 = i.ContractLearnerName("/"),
                            合約生效起日 = $"{i.CourseContractRevision.SourceContract.EffectiveDate:yyyyMMdd}",
                            合約生效迄日 = $"{i.CourseContractRevision.SourceContract.Expiration:yyyyMMdd}",
                            合約結束日 = $"{i.CourseContractRevision.SourceContract.ValidTo:yyyyMMdd}",
                            合約總價金 = i.TotalCost,
                            專業顧問服務總費用 = (i.TotalCost * 8 + 5) / 10,
                            教練課程費 = (i.TotalCost * 2 + 5) / 10,
                            課程單價 = i.LessonPriceType.ListPrice,
                            單堂原價 = i.LessonPriceType.SeriesSingleLessonPrice(),
                            剩餘堂數 = i.RemainedLessonCount(),
                            購買上課數 = i.Lessons,
                            編輯日期 = $"{i.ContractDate:yyyyMMdd}",                            
                            審核日期 = reason == "轉換體能顧問" || i.CourseContractRevision.OriginalContract == (int)Naming.OperationMode.快速終止
                                ? $"{i.EffectiveDate:yyyyMMdd}"
                                : $"{i.CourseContractLevel.Where(l => l.LevelID == (int)Naming.ContractServiceStatus.待簽名).Select(l => l.LevelDate).FirstOrDefault():yyyyMMdd}",
                            簽約日期 = reason== "轉換體能顧問" || i.CourseContractRevision.OriginalContract==(int)Naming.OperationMode.快速終止
                                ? null
                                : $"{i.CourseContractLevel.Where(l => l.LevelID == (int)Naming.ContractServiceStatus.已生效).Select(l => l.LevelDate).FirstOrDefault():yyyyMMdd}",
                            狀態 = i.ContractCurrentStatus(),
                            其他更多說明 = i.Remark,
                        });

                DataTable table = details.ToDataTable();
                table.TableName = $"{reason} {viewModel.EffectiveDateFrom:yyyyMMdd}~{viewModel.EffectiveDateTo.Value.AddDays(-1):yyyyMMdd}";
                ds.Tables.Add(table);
            }
            void buildTerminationDetails(DataSet ds, string reason)
            {
                var details = items.Join(models.GetTable<CourseContractRevision>().Where(r => r.Reason == reason),
                        c => c.ContractID, r => r.RevisionID, (c, r) => c)
                        .ToArray()
                        .Select(i => new
                        {
                            合約編號 = i.ContractNo(),
                            合約名稱 = i.ContractName(),
                            合約體能顧問 = i.ServingCoach.UserProfile.FullName(false),
                            簽約場所 = i.CourseContractExtension.BranchStore.BranchName,
                            學生 = i.ContractLearnerName("/"),
                            合約生效起日 = $"{i.CourseContractRevision.SourceContract.EffectiveDate:yyyyMMdd}",
                            合約生效迄日 = $"{i.CourseContractRevision.SourceContract.Expiration:yyyyMMdd}",
                            合約結束日 = $"{i.CourseContractRevision.SourceContract.ValidTo:yyyyMMdd}",
                            合約總價金 = i.TotalCost,
                            專業顧問服務總費用 = (i.TotalCost * 8 + 5) / 10,
                            教練課程費 = (i.TotalCost * 2 + 5) / 10,
                            課程單價 = i.LessonPriceType.ListPrice,
                            單堂原價 = i.LessonPriceType.SeriesSingleLessonPrice(),
                            剩餘堂數 = i.RemainedLessonCount(),
                            購買上課數 = i.Lessons,
                            編輯日期 = $"{i.ContractDate:yyyyMMdd}",                            
                            審核日期 = reason == "轉換體能顧問" || i.CourseContractRevision.OperationMode == (int)Naming.OperationMode.快速終止
                                ? $"{i.EffectiveDate:yyyyMMdd}"
                                : $"{i.CourseContractLevel.Where(l => l.LevelID == (int)Naming.ContractServiceStatus.待簽名).Select(l => l.LevelDate).FirstOrDefault():yyyyMMdd}",
                            簽約日期 = reason == "轉換體能顧問" || i.CourseContractRevision.OperationMode == (int)Naming.OperationMode.快速終止
                                ? null
                                : $"{i.CourseContractLevel.Where(l => l.LevelID == (int)Naming.ContractServiceStatus.已生效).Select(l => l.LevelDate).FirstOrDefault():yyyyMMdd}",
                            終止類別 = $"{(Naming.OperationMode?)i.CourseContractRevision.OperationMode}",
                            狀態 = i.ContractCurrentStatus(),
                            其他更多說明 = i.Remark,
                        });

                DataTable table = details.ToDataTable();
                table.TableName = $"{reason} {viewModel.EffectiveDateFrom:yyyyMMdd}~{viewModel.EffectiveDateTo.Value.AddDays(-1):yyyyMMdd}";
                ds.Tables.Add(table);
            }
            void buildConsultantAssignmentDetails(DataSet ds, string reason)
            {
                var details = items.Join(models.GetTable<CourseContractRevision>().Where(r => r.Reason == reason),
                        c => c.ContractID, r => r.RevisionID, (c, r) => c)
                        .ToArray()
                        .Select(i => new
                        {
                            合約編號 = i.ContractNo(),
                            合約名稱 = i.ContractName(),
                            原合約體能顧問 = i.CourseContractRevision.CourseContractRevisionItem?.ServingCoach.UserProfile.FullName(false),
                            合約體能顧問 = i.ServingCoach.UserProfile.FullName(false),
                            簽約場所 = i.CourseContractExtension.BranchStore.BranchName,
                            學生 = i.ContractLearnerName("/"),
                            合約生效起日 = $"{i.CourseContractRevision.SourceContract.EffectiveDate:yyyyMMdd}",
                            合約生效迄日 = $"{i.CourseContractRevision.SourceContract.Expiration:yyyyMMdd}",
                            合約結束日 = $"{i.CourseContractRevision.SourceContract.ValidTo:yyyyMMdd}",
                            合約總價金 = i.TotalCost,
                            專業顧問服務總費用 = (i.TotalCost * 8 + 5) / 10,
                            教練課程費 = (i.TotalCost * 2 + 5) / 10,
                            課程單價 = i.LessonPriceType.ListPrice,
                            單堂原價 = i.LessonPriceType.SeriesSingleLessonPrice(),
                            購買上課數 = i.Lessons,
                            編輯日期 = $"{i.ContractDate:yyyyMMdd}",
                            //簽約日期 = reason == "轉換體能顧問" || i.CourseContractRevision.OriginalContract == (int)Naming.OperationMode.快速終止
                            //    ? null
                            //    : $"{i.CourseContractLevel.Where(l => l.LevelID == (int)Naming.ContractServiceStatus.已生效).Select(l => l.LevelDate).FirstOrDefault():yyyyMMdd}",
                            審核日期 = reason == "轉換體能顧問" || i.CourseContractRevision.OriginalContract == (int)Naming.OperationMode.快速終止
                                ? $"{i.EffectiveDate:yyyyMMdd}"
                                : $"{i.CourseContractLevel.Where(l => l.LevelID == (int)Naming.ContractServiceStatus.待簽名).Select(l => l.LevelDate).FirstOrDefault():yyyyMMdd}",
                            狀態 = i.ContractCurrentStatus(),
                            其他更多說明 = i.Remark,
                        });

                DataTable table = details.ToDataTable();
                table.TableName = $"{reason} {viewModel.EffectiveDateFrom:yyyyMMdd}~{viewModel.EffectiveDateTo.Value.AddDays(-1):yyyyMMdd}";
                ds.Tables.Add(table);
            }

            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AppendCookie(new HttpCookie("fileDownloadToken", viewModel.FileDownloadToken));
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("ContractServiceDetails"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                buildDetails(ds, "展延");
                buildTerminationDetails(ds, "終止");
                //buildDetails(ds, "轉讓");
                buildConsultantAssignmentDetails(ds, "轉換體能顧問");

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        public ActionResult CreateBonusCreditXlsx(AwardQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var taskItems = models.GetTable<PDQTask>()
                .Join(models.GetTable<PDQTaskBonus>(),
                    t => t.TaskID, q => q.TaskID, (t, q) => t)
                .Select(t => t.UID);


            IQueryable<UserProfile> items = models.GetTable<UserProfile>().Where(u => taskItems.Contains(u.UID));

            if (items.Count() == 0)
            {
                Response.AppendCookie(new HttpCookie("fileDownloadToken", viewModel.FileDownloadToken));
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "資料不存在!!");
            }

            var details = items
                .Select(i => new
                {
                    姓名 = i.FullName(true),
                    目前Beyond幣金額 = i.BonusPoint(models),
                });


            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AppendCookie(new HttpCookie("fileDownloadToken", viewModel.FileDownloadToken));
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("BonusAccumulation"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.TableName = $"截至 {DateTime.Today:yyyyMMdd} Beyond幣金額";

                ds.Tables.Add(table);

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        public ActionResult CreateBonusAwardXlsx(AwardQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<LearnerAward> items = models.GetTable<LearnerAward>();

            if(viewModel.ItemID.HasValue)
            {
                items = items.Where(a => a.ItemID == viewModel.ItemID);
            }

            if (items.Count() == 0)
            {
                Response.AppendCookie(new HttpCookie("fileDownloadToken", viewModel.FileDownloadToken));
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "資料不存在!!");
            }


            var details = items.ToArray()
                .Select(item => new
                {
                    兌換時間 = String.Format("{0:yyyyMMdd}", item.AwardDate),
                    姓名 = item.UserProfile.FullName(true),
                    兌換場所 = models.GetTable<CoachWorkplace>().Where(c=>c.CoachID==item.ActorID)
                                .Select(c=>c.BranchStore.BranchName).FirstOrDefault(),
                    兌換人員 = item.Actor.FullName(false),
                    兌換商品 = item.BonusAwardingItem.ItemName,
                    使用日期 = item.BonusAwardingItem.BonusAwardingLesson != null
                        ? item.AwardingLesson != null
                            ? item.AwardingLesson.RegisterLesson.LessonTime.Count > 0
                                ? String.Format("{0:yyyyMMdd}", item.AwardingLesson.RegisterLesson.LessonTime.First().ClassTime)
                                : ""
                            : item.AwardingLessonGift.RegisterLesson.LessonTime.Count > 0
                                ? String.Format("{0:yyyyMMdd}", item.AwardingLessonGift.RegisterLesson.LessonTime.First().ClassTime)
                                : ""
                        : "",
                    贈與學員 = item.AwardingLessonGift != null ? item.AwardingLessonGift.RegisterLesson.UserProfile.FullName(true) : "",
                });


            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AppendCookie(new HttpCookie("fileDownloadToken", viewModel.FileDownloadToken));
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("BonusAward"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                DataTable table = details.ToDataTable();
                table.TableName = $"截至 {DateTime.Today:yyyyMMdd} 兌換商品";

                ds.Tables.Add(table);

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

        public ActionResult PrepareMonthlyBonus(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.AchievementDateFrom.HasValue)
            {
                viewModel.AchievementDateFrom = DateTime.Today.FirstDayOfMonth();
            }
            viewModel.AchievementDateTo = viewModel.AchievementDateFrom.Value.AddMonths(1);

            IQueryable<CoachMonthlySalary> items = viewModel.InquireMonthlySalary(models);

            return View("~/Views/ReportConsole/Module/PrepareMonthlyBonus.cshtml", items);
        }

        public ActionResult PrepareAchievementDetails(AchievementQueryViewModel viewModel)
        {
            //IQueryable<LessonTime> items = viewModel.InquireAchievement(this, out string alertMessage);

            //items = items.Join(models.GetTable<LessonTimeSettlement>().Where(l => l.SettlementID.HasValue), 
            //                l => l.LessonID, t => t.LessonID, (l, t) => l);

            //IQueryable<V_Tuition> tuitionItems = items.Join(models.GetTable<V_Tuition>(), l => l.LessonID, t => t.LessonID, (l, t) => t);
            //return View("~/Views/ReportConsole/Module/PrepareAchievementDetails.cshtml", items);
            ViewResult result = (ViewResult)PrepareMonthlyBonus(viewModel);
            result.ViewName = "~/Views/ReportConsole/Module/PrepareAchievementDetails.cshtml";
            return result;
        }
    }
}