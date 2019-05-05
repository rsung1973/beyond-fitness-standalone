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
    public class ContractConsoleController : SampleController<UserProfile>
    {
        // GET: ContractConsole
        public ActionResult ShowContractList(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireContract(viewModel);
            ViewBag.Contracts = result.Model;

            var profile = HttpContext.GetUser();
            return View("~/Views/ConsoleHome/ContractIndex.cshtml", profile.LoadInstance(models));
        }

        //public ActionResult CreateContractQueryXlsx(CourseContractQueryViewModel viewModel)
        //{
        //    ViewResult result = (ViewResult)InquirePayment(viewModel);
        //    IQueryable<Payment> items = (IQueryable<Payment>)result.Model;

        //    if (items.Count() == 0)
        //    {
        //        return View("~/Views/Shared/JsAlert.ascx", model: "資料不存在!!");
        //    }

        //    var details = items
        //        .OrderByDescending(i => i.PayoffDate)
        //        .ToArray()
        //        .Select(i => new
        //        {
        //            發票號碼 = i.InvoiceItem.TrackCode + i.InvoiceItem.No,
        //            分店 = i.PaymentTransaction.BranchStore.BranchName,
        //            收款人 = i.UserProfile.FullName(),
        //            學員 = i.TuitionInstallment != null
        //                ? i.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName()
        //                : i.ContractPayment != null
        //                    ? i.ContractPayment.CourseContract.CourseContractType.IsGroup == true
        //                        ? String.Join("/", i.ContractPayment.CourseContract.CourseContractMember.Select(m => m.UserProfile).ToArray().Select(u => u.FullName()))
        //                        : i.ContractPayment.CourseContract.ContractOwner.FullName()
        //                    : "--",
        //            收款日期 = String.Format("{0:yyyy/MM/dd}", i.PayoffDate),
        //            發票日期 = String.Format("{0:yyyy/MM/dd}", i.InvoiceItem.InvoiceDate),
        //            作廢或折讓日 = i.InvoiceItem.InvoiceCancellation != null && i.VoidPayment != null
        //                ? String.Format("{0:yyyy/MM/dd}", i.InvoiceItem.InvoiceCancellation.CancelDate)
        //                : i.InvoiceAllowance != null
        //                    ? String.Format("{0:yyyy/MM/dd}", i.InvoiceAllowance.AllowanceDate)
        //                    : "--",
        //            收款品項 = String.Concat(((Naming.PaymentTransactionType)i.TransactionType).ToString(),
        //                    i.TransactionType == (int)Naming.PaymentTransactionType.運動商品 || i.TransactionType == (int)Naming.PaymentTransactionType.飲品
        //                        ? String.Format("({0})", String.Join("、", i.PaymentTransaction.PaymentOrder.Select(p => p.MerchandiseWindow.ProductName)))
        //                        : null),
        //            收款金額 = i.PayoffAmount,
        //            發票金額 = i.InvoiceItem.InvoiceBuyer.IsB2C() ? i.InvoiceItem.InvoiceAmountType.TotalAmount : i.InvoiceItem.InvoiceAmountType.SalesAmount,
        //            收款未稅金額 = Math.Round((decimal)i.PayoffAmount / 1.05m),
        //            營業稅 = i.PayoffAmount - Math.Round((decimal)i.PayoffAmount / 1.05m),
        //            作廢金額 = i.InvoiceItem.InvoiceCancellation != null && i.VoidPayment != null
        //                ? i.PayoffAmount
        //                : null,
        //            折讓金額 = i.InvoiceAllowance?.TotalAmount,
        //            折讓稅額 = i.InvoiceAllowance?.TaxAmount,
        //            收款方式 = i.PaymentType,
        //            發票類型 = i.InvoiceID.HasValue
        //                ? i.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
        //                    ? "電子發票"
        //                    : "紙本"
        //                : "--",
        //            發票狀態 = i.InvoiceItem.InvoiceCancellation != null && i.VoidPayment != null
        //                ? "已作廢"
        //                : i.InvoiceAllowance != null
        //                    ? "已折讓"
        //                    : "已開立",
        //            買受人統編 = i.InvoiceID.HasValue
        //                ? i.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : i.InvoiceItem.InvoiceBuyer.ReceiptNo
        //                : "--",
        //            合約編號 = i.ContractPayment != null
        //                ? i.ContractPayment.CourseContract.ContractNo()
        //                : "--",
        //            合約總金額 = i.ContractPayment != null
        //                ? i.ContractPayment.CourseContract.TotalCost
        //                : (int?)null,
        //            備註 = i.VoidPayment != null
        //                ? i.VoidPayment.Remark
        //                : i.InvoiceAllowance != null
        //                    ? i.InvoiceAllowance.InvoiceAllowanceDetails.First().InvoiceAllowanceItem.Remark
        //                    : null,
        //            狀態 = i.VoidPayment == null
        //                ? String.Concat((Naming.CourseContractStatus)i.Status, i.PaymentAudit.AuditorID.HasValue ? "" : "(*)")
        //                : String.Concat((Naming.VoidPaymentStatus)i.VoidPayment.Status, "(作廢)"),
        //            //i.PaymentID,
        //            //VoidID = i.VoidPayment != null ? i.VoidPayment.VoidID : (int?)null
        //        });


        //    Response.Clear();
        //    Response.ClearContent();
        //    Response.ClearHeaders();
        //    Response.AppendCookie(new HttpCookie("fileDownloadToken", viewModel.FileDownloadToken));
        //    Response.AddHeader("Cache-control", "max-age=1");
        //    Response.ContentType = "application/vnd.ms-excel";
        //    Response.AddHeader("Content-Disposition", String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("PaymentDetails"), DateTime.Now));

        //    using (DataSet ds = new DataSet())
        //    {
        //        DataTable table = details.ToDataTable();
        //        if (viewModel.PayoffDateFrom.HasValue)
        //        {
        //            table.TableName = $"收款資料明細{viewModel.PayoffDateFrom:yyyy-MM-dd}~{viewModel.PayoffDateTo:yyyy-MM-dd}";
        //        }
        //        else
        //        {
        //            table.TableName = "收款資料明細";
        //        }
        //        ds.Tables.Add(table);

        //        foreach (var r in table.Select("買受人統編 = '0000000000'"))
        //        {
        //            r["買受人統編"] = "";
        //        }

        //        using (var xls = ds.ConvertToExcel())
        //        {
        //            xls.SaveAs(Response.OutputStream);
        //        }
        //    }

        //    return new EmptyResult();
        //}



        public ActionResult InquireContract(CourseContractQueryViewModel viewModel)
        {
            if(viewModel.ByCustom==true)
            {
                return InquireContractByCustom(viewModel);
            }

            bool hasConditon = false;
            var profile = HttpContext.GetUser();
            ViewBag.ViewModel = viewModel;

            IQueryable<CourseContract> items;

            if (viewModel.ContractQueryMode == Naming.ContractServiceMode.ContractOnly)
            {
                if (viewModel.Status >= (int)Naming.CourseContractStatus.已生效)
                {
                    items = models.PromptOriginalContract();
                }
                else if(viewModel.PayoffMode.HasValue)
                {
                    items = models.PromptAccountingContract();
                }
                else
                {
                    items = models.PromptContract();
                }
            }
            else if (viewModel.ContractQueryMode == Naming.ContractServiceMode.ServiceOnly)
            {
                items = models.PromptContractService();
            }
            else
            {
                items = models.GetTable<CourseContract>();
            }

            if (viewModel.PayoffMode == Naming.ContractPayoffMode.Unpaid)
            {
                hasConditon = true;
                items = items
                    .FilterByToPay(models);
            }
            else if (viewModel.PayoffMode == Naming.ContractPayoffMode.Paid)
            {
                hasConditon = true;
                items = items.Where(c => c.ContractPayment.Any());
            }

            if (viewModel.IncludeTotalUnpaid == true)
            {
                Expression<Func<CourseContract, bool>> expr = c => true;
                Expression<Func<CourseContract, bool>> defaultExpr = expr;
                if (viewModel.PayoffDueFrom.HasValue)
                {
                    hasConditon = true;
                    expr = expr.And(c => c.PayoffDue >= viewModel.PayoffDueFrom);
                }

                if (viewModel.PayoffDueTo.HasValue)
                {
                    hasConditon = true;
                    expr = expr.And(c => c.PayoffDue < viewModel.PayoffDueTo);
                }

                if (defaultExpr != expr)
                {
                    expr = expr.Or(c => !c.PayoffDue.HasValue);
                    items = items.Where(expr);
                }
            }
            else
            {
                if (viewModel.PayoffDueFrom.HasValue)
                {
                    hasConditon = true;
                    items = items.Where(c => c.PayoffDue >= viewModel.PayoffDueFrom);
                }

                if (viewModel.PayoffDueTo.HasValue)
                {
                    hasConditon = true;
                    items = items.Where(c => c.PayoffDue < viewModel.PayoffDueTo);
                }
            }

            if (viewModel.Status.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.Status == viewModel.Status);
            }

            if (viewModel.FitnessConsultant.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.FitnessConsultant == viewModel.FitnessConsultant);
            }

            if (viewModel.ManagerID.HasValue)
            {
                hasConditon = true;
                items = items.FilterByBranchStoreManager(models, viewModel.ManagerID);
            }

            if (viewModel.OfficerID.HasValue)
            {
                hasConditon = true;
            }

            if (viewModel.IsExpired == true)
            {
                hasConditon = true;
                items = items.FilterByExpired(models);
            }
            else if (viewModel.IsExpired == false)
            {
                hasConditon = true;
                items = items.Where(c => c.Expiration >= DateTime.Today);
            }

            if (viewModel.EffectiveDateFrom.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.EffectiveDate >= viewModel.EffectiveDateFrom);
            }

            if (viewModel.EffectiveDateTo.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.EffectiveDate < viewModel.EffectiveDateTo);
            }

            if (viewModel.ExpirationFrom.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.Expiration >= viewModel.ExpirationFrom);
            }

            if (viewModel.ExpirationTo.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.Expiration < viewModel.ExpirationTo.Value);
            }

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            if (viewModel.ContractID.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.ContractID == viewModel.ContractID);
            }

            if(viewModel.AlarmCount.HasValue)
            {
                hasConditon = true;
                items = items.FilterByAlarmedContract(models, viewModel.AlarmCount.Value);
            }

            if (viewModel.InstallmentID.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.InstallmentID == viewModel.InstallmentID);
            }

            if (hasConditon)
            {

            }
            else
            {
                items = items.Where(c => false);
            }

            //if (viewModel.ContractType.HasValue)
            //    items = items.Where(c => c.ContractType == viewModel.ContractType);

            return View("~/Views/ContractConsole/Module/ContractList.cshtml", items);
        }

        public ActionResult InquireContractByCustom(CourseContractQueryViewModel viewModel)
        {
            IQueryable<CourseContract> items = viewModel.InquireContractByCustom(this, out String alertMessage);
            if (items == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Module/CustomContractList.cshtml", items);
        }

        public ActionResult InvokeContractQuery(CourseContractQueryViewModel viewModel)
        {
            //viewModel.ContractDateFrom = DateTime.Today.FirstDayOfMonth();
            //viewModel.ContractDateTo = viewModel.ContractDateFrom.Value.AddMonths(1).AddDays(-1);
            viewModel.ByCustom = true;
            ViewBag.ViewModel = viewModel;
            return View("~/Views/ContractConsole/ContractModal/ContractQuery.cshtml");
        }

        public ActionResult ProcessContract(CourseContractQueryViewModel viewModel)
        {
            if(viewModel.KeyID!=null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "合約資料錯誤!!");
            }

            return View("~/Views/ContractConsole/ContractModal/ProcessContract.cshtml", item);
        }

        public ActionResult ProcessContractService(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)ProcessContract(viewModel);
            CourseContract item = result.Model as CourseContract;
            if(item!=null)
            {
                result.ViewName = "~/Views/ContractConsole/ContractModal/ProcessContractService.cshtml";
            }
            return result;
        }


        public ActionResult ShowContractDetails(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)ProcessContract(viewModel);

            CourseContract item = result.Model as CourseContract;
            if (item == null)
            {
                return result;
            }

            return View("~/Views/ContractConsole/ContractModal/AboutContractDetails.cshtml", item);
        }

        public ActionResult SelectCoach()
        {
            var profile = HttpContext.GetUser();
            IQueryable<ServingCoach> items = models.GetTable<ServingCoach>()
                .Join(models.GetTable<UserProfile>().Where(u => u.LevelID != (int)Naming.MemberStatus.已停用), 
                    s => s.CoachID, u => u.UID, (s, u) => s);
            if (profile.IsOfficer() || profile.IsAssistant() || profile.IsSysAdmin())
            {

            }
            else if (profile.IsManager() || profile.IsViceManager())
            {
                items = profile.GetServingCoachInSameStore(models, items);
            }
            else if (profile.IsCoach())
            {
                items = items.Where(c => c.CoachID == profile.UID);
            }
            else
            {
                items = items.Where(c => false);
            }

            return View("~/Views/ContractConsole/ContractModal/SelectCoach.cshtml", items);
        }

        public ActionResult CommitContract(CourseContractViewModel viewModel)
        {
            var item = viewModel.CommitCourseContract(this, out String alertMessage);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/CourseContractCommitted.cshtml", item);
        }

        public ActionResult SaveContract(CourseContractViewModel viewModel)
        {
            var item = viewModel.SaveCourseContract(this, out String alertMessage);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/CourseContractSaved.cshtml", item);
        }

        public ActionResult ListLessonPrice(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (!viewModel.BranchID.HasValue)
            {
                ModelState.AddModelError("BranchID", "請選擇上課場所");
            }
            if (!viewModel.DurationInMinutes.HasValue)
            {
                ModelState.AddModelError("DurationInMinutes", "請選擇上課時間長度");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            IQueryable<LessonPriceType> items = models.PromptEffectiveLessonPrice()
                .Where(p => p.BranchID == viewModel.BranchID)
                .Where(l => !l.DurationInMinutes.HasValue || l.DurationInMinutes == viewModel.DurationInMinutes);

            return View("~/Views/ContractConsole/ContractModal/ListLessonPrice.cshtml", items);
        }

        public ActionResult CalculateTotalCost(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var item = models.GetTable<LessonPriceType>().Where(p => p.PriceID == viewModel.PriceID).FirstOrDefault();
            viewModel.TotalCost = item?.ListPrice * viewModel.Lessons;

            return View("~/Views/ContractConsole/Editing/TotalCostSummary.cshtml");
        }

        public ActionResult ListContractMember(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.UID != null && viewModel.UID.Length > 0)
            {
                viewModel.UID = viewModel.UID.Distinct().ToArray();
            }

            return View("~/Views/ContractConsole/Editing/ListContractMember.cshtml");
        }

        public ActionResult SearchContractMember(String userName)
        {
            userName = userName.GetEfficientString();
            if (userName == null)
            {
                this.ModelState.AddModelError("userName", "請輸入查詢學員!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/ConsoleHome/Shared/ReportInputError.cshtml");
            }

            var items = userName.PromptLearnerByName(models, true);

            if (items.Count() > 0)
                return View("~/Views/ContractConsole/ContractModal/SelectContractMember.cshtml", items);
            else
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "Opps！您確定您輸入的資料正確嗎！？");
        }

        public ActionResult ProcessContractMember(int uid)
        {
            return View("~/Views/ContractConsole/ContractModal/ProcessContractMember.cshtml", uid);
        }

        public ActionResult EditContractMember(ContractMemberViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "Opps！您確定您輸入的資料正確嗎！？");
            }

            viewModel.Gender = item.UserProfileExtension.Gender;
            viewModel.EmergencyContactPhone = item.UserProfileExtension.EmergencyContactPhone;
            viewModel.EmergencyContactPerson = item.UserProfileExtension.EmergencyContactPerson;
            viewModel.Relationship = item.UserProfileExtension.Relationship;
            viewModel.AdministrativeArea = item.UserProfileExtension.AdministrativeArea;
            viewModel.IDNo = item.UserProfileExtension.IDNo;
            viewModel.Phone = item.Phone;
            viewModel.Birthday = item.Birthday;
            viewModel.AthleticLevel = item.UserProfileExtension.AthleticLevel;
            viewModel.RealName = item.RealName;
            viewModel.Address = item.Address;
            viewModel.Nickname = item.Nickname;

            return View("~/Views/ContractConsole/ContractModal/EditContractMember.cshtml");
        }

        public ActionResult CommitContractMember(ContractMemberViewModel viewModel)
        {
            var item = viewModel.CommitContractMember(this, out String alertMessage);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/ContractMemberCommitted.cshtml", item);

        }

        public ActionResult SignaturePanel(CourseContractSignatureViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/ContractConsole/ContractModal/SignaturePanel.cshtml");
        }

        public ActionResult ExecuteContractStatus(CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var item = viewModel.ExecuteContractStatus(this, out String alertMessage);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/ContractStatusChanged.cshtml", item);
        }

        public ActionResult EnableContractAmendment(CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = viewModel.EnableContractAmendment(this, out String alertMessage, viewModel.FromStatus);
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: alertMessage);
            }

            return View("~/Views/ContractConsole/Editing/ContractStatusChanged.cshtml", item);
        }

        public ActionResult ConfirmSignature(CourseContractViewModel viewModel)
        {
            var item = viewModel.ConfirmContractSignature(this, out String alertMessage,out String pdfFile);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/CourseContractSigned.cshtml", item);
        }

        public ActionResult ConfirmContractServiceSignature(CourseContractViewModel viewModel)
        {
            var item = viewModel.ConfirmContractServiceSignature(this, out String alertMessage, out String pdfFile);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/CourseContractSigned.cshtml", item);
        }

        public ActionResult EnableContractStatus(CourseContractViewModel viewModel)
        {
            var profile = HttpContext.GetUser();
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                var pdfFile = item.MakeContractEffective(models, profile, Naming.CourseContractStatus.待審核);
                if (pdfFile == null)
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "合約狀態錯誤，請重新檢查!!");
                }
                else
                {
                    return View("~/Views/ContractConsole/Editing/CourseContractSigned.cshtml", item);
                }
            }
            else
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "合約資料錯誤!!");
        }

        public ActionResult CommitContractService(CourseContractViewModel viewModel)
        {
            var item = viewModel.CommitContractService(this, out String alertMessage);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/ContractServiceCommitted.cshtml", item);
        }

        public ActionResult SearchContractOwner(String userName)
        {
            ViewResult result = (ViewResult)SearchContractMember(userName);

            if (result.Model is IQueryable<UserProfile> items)
            {
                result.ViewName = "~/Views/ContractConsole/ContractModal/SelectContractOwner.cshtml";
            }

            return result;

        }

    }
}