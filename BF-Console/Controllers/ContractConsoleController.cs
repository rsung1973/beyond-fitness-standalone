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

        public ActionResult InquireContract(CourseContractQueryViewModel viewModel)
        {
            if(viewModel.ByCustom==true)
            {
                return InquireContractByCustom(viewModel);
            }

            IQueryable<CourseContract> items = viewModel.InquireContract(this, out string alertMessage);

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