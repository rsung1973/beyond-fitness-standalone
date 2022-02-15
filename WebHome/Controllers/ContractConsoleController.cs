using System;
using System.Collections.Generic;
using System.Data;

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
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.Routing;
using Microsoft.Extensions.DependencyInjection;

using CommonLib.DataAccess;
using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Helper.BusinessOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;
using CommonLib.Core.Utility;

namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class ContractConsoleController : SampleController<UserProfile>
    {
        public ContractConsoleController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: ContractConsole
        public async Task<ActionResult> ShowContractListAsync(CourseContractQueryViewModel viewModel,bool? popupModal)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            ViewResult result = (ViewResult)await InquireContractAsync(viewModel);
            ViewBag.Contracts = result.Model;

            var profile = await HttpContext.GetUserAsync();

            if (popupModal == true)
            {
                return View("~/Views/ConsoleHome/CourseContract/ContractListModal.cshtml", profile.LoadInstance(models));
            }
            else
            {
                return View("~/Views/ConsoleHome/ContractIndex.cshtml", profile.LoadInstance(models));
            }
        }

        public async Task<ActionResult> InquireContractAsync(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if(viewModel.ByCustom==true)
            {
                return await InquireContractByCustomAsync(viewModel);
            }

            IQueryable<CourseContract> items = viewModel.InquireContract(models);

            return View("~/Views/ContractConsole/Module/ContractList.cshtml", items);
        }

        public async Task<ActionResult> InquireContractByCustomAsync(CourseContractQueryViewModel viewModel)
        {
            IQueryable<CourseContract> items = await viewModel.InquireContractByCustomAsync(this);
            if (items == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: ModelState.ErrorMessage());
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

        public async Task<ActionResult> SelectCoachAsync(ServingCoachQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewBag.SelectAll = viewModel.SelectAll;
            ViewBag.Allotment = viewModel.Allotment;
            ViewBag.AllotmentCoach = viewModel.AllotmentCoach;

            var profile = await HttpContext.GetUserAsync();
            IQueryable<ServingCoach> items = models.PromptEffectiveCoach();
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

        public async Task<ActionResult> CommitContractAsync(CourseContractViewModel viewModel)
        {
            CourseContract item = null;
            try
            {
                item = await viewModel.CommitCourseContractAsync(this, true);
            }
            catch(Exception ex)
            {
                var logger = ServiceProvider.GetRequiredService<ILogger<ContractConsoleController>>();
                logger.LogError(ex, ex.Message);
                ModelState.AddModelError("Message", ex.Message);
            }

            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    ViewBag.AlertError = true;
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: ModelState.ErrorMessage());
                }
            }

            return View("~/Views/ContractConsole/Editing/CourseContractCommitted.cshtml", item);
        }

        public async Task<ActionResult> SaveContractAsync(CourseContractViewModel viewModel)
        {
            var item = await viewModel.SaveCourseContractAsync(this, true);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    ViewBag.AlertError = true;
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: ModelState.ErrorMessage());
                }
            }

            return View("~/Views/ContractConsole/Editing/CourseContractSaved.cshtml", item);
        }

        public ActionResult ListLessonPrice(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var branch = models.GetTable<BranchStore>()
                .Where(b => b.BranchID == viewModel.BranchID).FirstOrDefault();
            if (branch == null)
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

            IQueryable<LessonPriceType> items = models.GetTable<LessonPriceType>()
                .Where(l => !l.DurationInMinutes.HasValue || l.DurationInMinutes == viewModel.DurationInMinutes);

            if(viewModel.ContractType == CourseContractType.ContractTypeDefinition.CGA)
            {
                items = items
                    .Where(p => p.BranchID == viewModel.BranchID)
                    .Join(models.GetTable<ObjectiveContractLessonPrice>().Where(c => c.ContractType == (int)viewModel.ContractType),
                        p => p.PriceID, c => c.PriceID, (p, c) => p);

                if(items.Any())
                {
                    return View("~/Views/ContractConsole/ContractModal/ListLessonPackagePrice.cshtml", items);
                }
                else
                {
                    return Json(new { result = false, message = "無相符條件的項目!" });
                }
            }
            else if (viewModel.ContractType == CourseContractType.ContractTypeDefinition.CNA)
            {
                items = items
                    .Where(p => p.BranchID == viewModel.BranchID)
                    .Join(models.GetTable<ObjectiveContractLessonPrice>().Where(c => c.ContractType == (int)viewModel.ContractType),
                        p => p.PriceID, c => c.PriceID, (p, c) => p);

                if (items.Any())
                {
                    return View("~/Views/ContractConsole/ContractModal/ListLessonBundlePrice.cshtml", items);
                }
                else
                {
                    return Json(new { result = false, message = "無相符條件的項目!" });
                }
            }
            else
            {
                items = models.PromptEffectiveLessonPrice()
                    .Where(p => p.BranchID == viewModel.BranchID)
                    .Where(l => !l.DurationInMinutes.HasValue || l.DurationInMinutes == viewModel.DurationInMinutes);
            }

            return View("~/Views/ContractConsole/ContractModal/ListLessonPrice.cshtml", items);
        }

        public ActionResult CalculateTotalCost(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var item = models.GetTable<LessonPriceType>().Where(p => p.PriceID == viewModel.PriceID).FirstOrDefault();

            if (item != null)
            {
                if (item.IsPackagePrice)
                {
                    viewModel.TotalCost = item.ListPrice;
                }
                else
                {
                    viewModel.TotalCost = item.ListPrice * viewModel.Lessons;

                    var typeItem = models.GetTable<CourseContractType>().Where(t => t.TypeID == (int?)viewModel.ContractType).FirstOrDefault();
                    if (typeItem != null)
                    {
                        viewModel.TotalCost = viewModel.TotalCost * typeItem.GroupingMemberCount * typeItem.GroupingLessonDiscount.PercentageOfDiscount / 100;
                    }
                }
            }

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

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

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

            return View("~/Views/ContractConsole/ContractModal/EditContractMember2022.cshtml", item);
        }

        public async Task<ActionResult> CommitContractMemberAsync(ContractMemberViewModel viewModel)
        {
            var item = await viewModel.CommitUserProfileAsync(this);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: ModelState.ErrorMessage());
                }
            }

            if (viewModel.ProfileOnly == true)
            {
                return View("~/Views/ContractConsole/Editing/UserProfileCommitted.cshtml", item);

            }
            else
            {
                return View("~/Views/ContractConsole/Editing/ContractMemberCommitted.cshtml", item);
            }

        }

        public ActionResult SignaturePanel(CourseContractSignatureViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/ContractConsole/ContractModal/SignaturePanel.cshtml");
        }

        public async Task<ActionResult> ExecuteContractStatusAsync(CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var item = await viewModel.ExecuteContractStatusAsync(this);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: ModelState.ErrorMessage());
                }
            }
            else if (viewModel.FromStatus == Naming.CourseContractStatus.待審核 && viewModel.Status == (int)Naming.CourseContractStatus.待簽名)
            {
                if (item.InstallmentID.HasValue)
                {
                    var contractItems = item.ContractInstallment.CourseContract.ToArray();
                    CourseContract nextItem = null;
                    int idx = 0;
                    for (; idx < contractItems.Length; idx++)
                    {
                        if (contractItems[idx].Status == (int?)viewModel.FromStatus && contractItems[idx].ContractID != item.ContractID)
                        {
                            nextItem = contractItems[idx];
                            break;
                        }
                    }

                    if (nextItem != null)
                    {
                        viewModel.UrlAction = Url.Action("SignCourseContract", "ConsoleHome");
                        viewModel.KeyID = nextItem.ContractID.EncryptKey();
                        viewModel.AlertMessage = $"總共有{contractItems.Length}張分期合約，請繼續第{idx+1}張分期合約的審核!!";
                        return View("~/Views/ConsoleHome/Shared/ViewModelCommitted.cshtml", viewModel);
                    }
                }
            }

            return View("~/Views/ContractConsole/Editing/ContractStatusChanged.cshtml", item);
        }

        public async Task<ActionResult> EnableContractAmendmentAsync(CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = await viewModel.EnableContractAmendmentAsync(this,viewModel.FromStatus);
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: ModelState.ErrorMessage());
            }

            return View("~/Views/ContractConsole/Editing/ContractStatusChanged.cshtml", item);
        }

        public async Task<ActionResult> ConfirmSignatureAsync(CourseContractViewModel viewModel)
        {
            var item = await viewModel.ConfirmContractSignatureAsync(this);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    ViewBag.AlertError = true;
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: ModelState.ErrorMessage());
                }
            }

            if (item.InstallmentID.HasValue)
            {
                var contractItems = item.ContractInstallment.CourseContract.ToArray();
                CourseContract nextItem = null;
                int idx = 0;
                for (; idx < contractItems.Length; idx++)
                {
                    if (contractItems[idx].Status != (int?)Naming.CourseContractStatus.已生效 && contractItems[idx].ContractID != item.ContractID)
                    {
                        nextItem = contractItems[idx];
                        break;
                    }
                }

                if (nextItem != null)
                {
                    viewModel.UrlAction = Url.Action("SignCourseContract", "ConsoleHome");
                    viewModel.KeyID = nextItem.ContractID.EncryptKey();
                    viewModel.AlertMessage = $"總共有{contractItems.Length}張分期合約，請繼續第{idx + 1}張分期合約的簽名!!";
                    return View("~/Views/ConsoleHome/Shared/ViewModelCommitted.cshtml", viewModel);
                }
            }

            return View("~/Views/ContractConsole/Editing/CourseContractSigned.cshtml", item);
        }

        public async Task<ActionResult> ConfirmContractServiceSignatureAsync(CourseContractViewModel viewModel)
        {
            var item = await viewModel.ConfirmContractServiceSignatureAsync(this);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    ViewBag.AlertError = true;
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: ModelState.ErrorMessage());
                }
            }

            return View("~/Views/ContractConsole/Editing/CourseContractSigned.cshtml", item);
        }

        public async Task<ActionResult> EnableContractStatusAsync(CourseContractViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();
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

        public async Task<ActionResult> CommitContractServiceAsync(CourseContractViewModel viewModel)
        {
            String storedPath = null;
            if (Request.Form.Files.Count > 0)
            {
                storedPath = Path.Combine(FileLogger.Logger.LogDailyPath, Guid.NewGuid().ToString() + Path.GetExtension(Request.Form.Files[0].FileName));
                Request.Form.Files[0].SaveAs(storedPath);
            }
            var item = await viewModel.CommitContractServiceAsync(this, storedPath);
            if (item == null)
            {
                if (!ModelState.IsValid)
                {
                    return View(ConsoleHomeController.InputErrorView);
                }
                else
                {
                    return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: ModelState.ErrorMessage());
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

        public ActionResult EditPaymentForContract(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            Payment item = viewModel.EditPaymentForContract(this.HttpContext);
            return View("~/Views/ContractConsole/Module/EditPaymentForContract.cshtml", item);
        }

        public async Task<ActionResult> ShowCauseForEndingDonutChartAsync(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/ContractConsole/Module/ShowCauseForEndingDonutChart.cshtml", profile);
        }

        public ActionResult ShowRemainedLessonList(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.MemberID)
                .FirstOrDefault() ?? new UserProfile { UID = -1 };
            _ = profile.RemainedLessonCount(models, out int remainedCount, out IQueryable<RegisterLesson> remainedLessons);

            return View("~/Views/ConsoleHome/CourseContract/RemainedLessonListModal.cshtml", remainedLessons);
        }

    }
}