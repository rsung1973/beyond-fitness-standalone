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
            return View("~/Views/ConsoleHome/ContractIndex.aspx", profile.LoadInstance(models));
        }


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


            if (hasConditon)
            {

            }
            else
            {
                items = items.Where(c => false);
            }

            //if (viewModel.ContractType.HasValue)
            //    items = items.Where(c => c.ContractType == viewModel.ContractType);

            return View("~/Views/ContractConsole/Module/ContractList.ascx", items);
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
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Module/CustomContractList.ascx", items);
        }

        public ActionResult InvokeContractQuery(CourseContractQueryViewModel viewModel)
        {
            //viewModel.ContractDateFrom = DateTime.Today.FirstDayOfMonth();
            //viewModel.ContractDateTo = viewModel.ContractDateFrom.Value.AddMonths(1).AddDays(-1);
            viewModel.ByCustom = true;
            ViewBag.ViewModel = viewModel;
            return View("~/Views/ContractConsole/ContractModal/ContractQuery.ascx");
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
                return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: "合約資料錯誤!!");
            }

            return View("~/Views/ContractConsole/ContractModal/ProcessContract.ascx", item);
        }

        public ActionResult ProcessContractService(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)ProcessContract(viewModel);
            CourseContract item = result.Model as CourseContract;
            if(item!=null)
            {
                result.ViewName = "~/Views/ContractConsole/ContractModal/ProcessContractService.ascx";
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

            return View("~/Views/ContractConsole/ContractModal/AboutContractDetails.ascx", item);
        }

        public ActionResult SelectCoach()
        {
            var profile = HttpContext.GetUser();
            IQueryable<ServingCoach> items = models.GetTable<ServingCoach>();
            if (profile.IsOfficer() || profile.IsAssistant() || profile.IsSysAdmin())
            {

            }
            else if (profile.IsManager() || profile.IsViceManager())
            {
                items = profile.GetServingCoachInSameStore(models);
            }
            else if (profile.IsCoach())
            {
                items = items.Where(c => c.CoachID == profile.UID);
            }
            else
            {
                items = items.Where(c => false);
            }

            return View("~/Views/ContractConsole/ContractModal/SelectCoach.ascx", items);
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
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/CourseContractCommitted.ascx", item);
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
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/CourseContractSaved.ascx", item);
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

            return View("~/Views/ContractConsole/ContractModal/ListLessonPrice.ascx", items);
        }

        public ActionResult CalculateTotalCost(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var item = models.GetTable<LessonPriceType>().Where(p => p.PriceID == viewModel.PriceID).FirstOrDefault();
            viewModel.TotalCost = item?.ListPrice * viewModel.Lessons;

            return View("~/Views/ContractConsole/Editing/TotalCostSummary.ascx");
        }

        public ActionResult ListContractMember(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.UID != null && viewModel.UID.Length > 0)
            {
                viewModel.UID = viewModel.UID.Distinct().ToArray();
            }

            return View("~/Views/ContractConsole/Editing/ListContractMember.ascx");
        }

        public ActionResult SearchContractMember(String userName)
        {
            userName = userName.GetEfficientString();
            if (userName == null)
            {
                this.ModelState.AddModelError("userName", "請輸入查詢學員!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/ConsoleHome/Shared/ReportInputError.ascx");
            }

            var items = userName.PromptLearnerByName(models);

            if (items.Count() > 0)
                return View("~/Views/ContractConsole/ContractModal/SelectContractMember.ascx", items);
            else
                return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: "Opps！您確定您輸入的資料正確嗎！？");
        }

        public ActionResult ProcessContractMember(int uid)
        {
            return View("~/Views/ContractConsole/ContractModal/ProcessContractMember.ascx", uid);
        }

        public ActionResult EditContractMember(ContractMemberViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: "Opps！您確定您輸入的資料正確嗎！？");
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

            return View("~/Views/ContractConsole/ContractModal/EditContractMember.ascx");
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
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/ContractMemberCommitted.ascx", item);

        }

        public ActionResult SignaturePanel(CourseContractSignatureViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/ContractConsole/ContractModal/SignaturePanel.ascx");
        }

        public ActionResult ExecuteContractStatus(CourseContractViewModel viewModel)
        {
            var item = viewModel.ExecuteContractStatus(this, out String alertMessage);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/ContractStatusChanged.ascx", item);
        }

        public ActionResult EnableContractAmendment(CourseContractViewModel viewModel)
        {
            var item = viewModel.EnableContractAmendment(this, out String alertMessage, null);
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: alertMessage);
            }

            return View("~/Views/ContractConsole/Editing/ContractStatusChanged.ascx", item);
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
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/CourseContractSigned.ascx", item);
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
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/CourseContractSigned.ascx", item);
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
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: "合約狀態錯誤，請重新檢查!!");
                }
                else
                {
                    return View("~/Views/ContractConsole/Editing/CourseContractSigned.ascx", item);
                }
            }
            else
                return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: "合約資料錯誤!!");
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
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: alertMessage);
                }
            }

            return View("~/Views/ContractConsole/Editing/ContractServiceCommitted.ascx", item);
        }

        public ActionResult SearchContractOwner(String userName)
        {
            ViewResult result = (ViewResult)SearchContractMember(userName);

            if (result.Model is IQueryable<UserProfile> items)
            {
                result.ViewName = "~/Views/ContractConsole/ContractModal/SelectContractOwner.ascx";
            }

            return result;

        }


    }
}