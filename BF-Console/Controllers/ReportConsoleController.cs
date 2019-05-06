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

namespace BFConsole.Controllers
{
    [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class ReportConsoleController : SampleController<UserProfile>
    {
        // GET: ReportConsole
        public ActionResult SelectMonthlyReport()
        {
            return View("~/Views/ReportConsole/ReportModal/SelectMonthlyReport.cshtml");
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

        public ActionResult CreateContractQueryXlsx(CourseContractQueryViewModel viewModel)
        {
            IQueryable<CourseContract> items = viewModel.InquireContract(this, out string alertMessage);

            if (items.Count() == 0)
            {
                Response.AppendCookie(new HttpCookie("fileDownloadToken", viewModel.FileDownloadToken));
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "資料不存在!!");
            }

            var details = items
                .Select(i => new
                {
                    合約編號 = i.ContractNo(),
                    合約名稱 = i.ContractName(),
                    學生 = i.ContractLearnerName("/"),
                    合約生效起日 = $"{i.EffectiveDate:yyyy/MM/dd}",
                    合約生效迄日 = $"{i.Expiration:yyyy/MM/dd}",
                    合約結束日 = $"{i.ValidTo:yyyy/MM/dd}",
                    合約總價金 = i.TotalCost,
                    專業顧問服務總費用 = (i.TotalCost * 8 + 5) / 10,
                    教練課程費 = (i.TotalCost * 2 + 5) / 10,
                    課程單價 = i.LessonPriceType.ListPrice,
                    單堂原價 = i.LessonPriceType.SeriesSingleLessonPrice(),
                    剩餘上課數 = i.RemainedLessonCount(false),
                    購買上課數 = i.Lessons,
                    其他更多說明 = i.Remark,
                    合約體能顧問 = i.ServingCoach.UserProfile.FullName(false),
                    上課場所 = i.CourseContractExtension.BranchStore.BranchName,
                    狀態 = i.ContractCurrentStatus(),
                    應收款期限 = $"{i.PayoffDue:yyyy/MM/dd}",
                    累計收款金額 = i.TotalPaidAmount(),
                    累計收款次數 = i.TotalPayoffCount(),
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
                    table.TableName = $"{viewModel.EffectiveDateFrom:yyyy-MM-dd}~{viewModel.EffectiveDateFrom:yyyy-MM-dd}";

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
                            上課場所 = i.CourseContractExtension.BranchStore.BranchName,
                            學生 = i.ContractLearnerName("/"),
                            合約生效起日 = $"{i.CourseContractRevision.SourceContract.EffectiveDate:yyyy/MM/dd}",
                            合約生效迄日 = $"{i.CourseContractRevision.SourceContract.Expiration:yyyy/MM/dd}",
                            合約結束日 = $"{i.CourseContractRevision.SourceContract.ValidTo:yyyy/MM/dd}",
                            合約總價金 = i.TotalCost,
                            專業顧問服務總費用 = (i.TotalCost * 8 + 5) / 10,
                            教練課程費 = (i.TotalCost * 2 + 5) / 10,
                            課程單價 = i.LessonPriceType.ListPrice,
                            單堂原價 = i.LessonPriceType.SeriesSingleLessonPrice(),
                            購買上課數 = i.Lessons,
                            編輯日期 = $"{i.ContractDate:yyyy/MM/dd}",
                            簽約日期 = reason== "轉換體能顧問" || i.CourseContractRevision.OriginalContract==(int)Naming.OperationMode.快速終止
                                ? null
                                : $"{i.CourseContractLevel.Where(l => l.LevelID == (int)Naming.ContractServiceStatus.已生效).Select(l => l.LevelDate).FirstOrDefault():yyyy/MM/dd}",
                            審核日期 = reason == "轉換體能顧問" || i.CourseContractRevision.OriginalContract == (int)Naming.OperationMode.快速終止
                                ? $"{i.EffectiveDate:yyyy/MM/dd}"
                                : $"{i.CourseContractLevel.Where(l => l.LevelID == (int)Naming.ContractServiceStatus.待簽名).Select(l => l.LevelDate).FirstOrDefault():yyyy/MM/dd}",
                            狀態 = i.ContractCurrentStatus(),
                            其他更多說明 = i.Remark,
                        });

                DataTable table = details.ToDataTable();
                table.TableName = reason;
                ds.Tables.Add(table);
            }

            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AppendCookie(new HttpCookie("fileDownloadToken", viewModel.FileDownloadToken));
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("ContractDetails"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                buildDetails(ds, "展延");
                buildDetails(ds, "終止");
                buildDetails(ds, "轉讓");
                buildDetails(ds, "轉換體能顧問");

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }

    }
}