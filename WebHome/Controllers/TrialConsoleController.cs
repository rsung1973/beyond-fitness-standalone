using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNetCore.Mvc; //System.Web.Mvc;
//using Microsoft.AspNetCore.Authorization;
using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using CommonLib.Core.Utility;
using CommonLib.DataAccess;
using Microsoft.AspNetCore.Http;
//using System.Data.Entity;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using WebHome.Helper.BusinessOperation;
using System.Linq.Expressions;
using Microsoft.Extensions.DependencyInjection;
using Newtonsoft.Json;
using System.Net.Http;
using System.Data.Linq;

namespace WebHome.Controllers
{
    public class TrialConsoleController : SampleController<UserProfile>
    {
        private readonly IViewRenderService _viewRenderService;
        public TrialConsoleController(IViewRenderService viewRenderService, IServiceProvider serviceProvider) : base(serviceProvider)
        {
            _viewRenderService = viewRenderService;
        }

        public async Task<ActionResult> InquireTrialLearnerAsync(TrialLearnerQueryViewModel viewModel)
        {

            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            IQueryable<TrialLearner> items = models.GetTable<TrialLearner>();

            if (viewModel.Year.HasValue && viewModel.Month.HasValue)
            {
                DateTime start = new DateTime(viewModel.Year.Value, viewModel.Month.Value, 1);
                items = items.Where(t => t.SubmitDate >= start)
                                .Where(t => t.SubmitDate < start.AddMonths(1));
            }

            if (viewModel.NotAssigned == true)
            {
                items = items.Where(t => !t.Status.HasValue);
            }
            else if (viewModel.ByStatus != null)
            {
                if (viewModel.ByStatus.Length > 0)
                {
                    items = items.Where(t => t.Status.HasValue && viewModel.ByStatus.Contains((int)t.Status));
                }
                else
                {

                }
            }

            if(viewModel.IsClosed == true)
            {
                items = items.Where(t => t.IsClosed == true);
            }
            else if (viewModel.IsClosed == false)
            {
                items = items.Where(t => !t.IsClosed.HasValue || t.IsClosed == false);
            }

            if (viewModel.BranchID.HasValue)
            {
                items = items.Where(t => t.BranchID == viewModel.BranchID);
            }

            if (viewModel.AssigneeID.HasValue)
            {
                items = items.Where(t => t.AssigneeID == viewModel.AssigneeID);
            }

            if (viewModel.AttendingCoach.HasValue)
            {
                items = items.Where(t => t.AttendingCoach == viewModel.AttendingCoach);
            }

            return View("~/Views/TrialConsole/Module/TrialLearnerList.cshtml", items);
        }

        public ActionResult ProcessTrial(TrialLearnerQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<TrialLearner>().Where(c => c.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            return View("~/Views/TrialConsole/Module/ProcessTrial.cshtml", item);
        }

        public static readonly int[] AssignedTrial =
            {
                (int)TrialLearner.TrialStatusDefinition.時間確認中,
                (int)TrialLearner.TrialStatusDefinition.已約好準備體驗,
                (int)TrialLearner.TrialStatusDefinition.完成體驗,
            };

        public static readonly int[] Assigned =
            {
                (int)TrialLearner.TrialStatusDefinition.已PARQ,
                (int)TrialLearner.TrialStatusDefinition.不需要,
                (int)TrialLearner.TrialStatusDefinition.聯繫不上,
                (int)TrialLearner.TrialStatusDefinition.尚未聯繫,
                (int)TrialLearner.TrialStatusDefinition.電話空號,
            };

        public ActionResult SearchAssignee(QueryViewModel viewModel, String userName)
        {
            ViewBag.ViewModel = viewModel;
            IQueryable<UserProfile> items =
                userName.PromptUserProfileByName(models)
                    .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked);

            var coaches = models.PromptEffectiveCoach();
            var employee = models.GetTable<ForEmployee>();

            items = items.Where(u => coaches.Any(c => c.CoachID == u.UID)
                            || employee.Any(e => e.UID == u.UID));

            if (items.Count() > 0)
                return View("~/Views/TrialConsole/Module/SelectAssignee.cshtml", items);
            else
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "Opps！您確定您輸入的資料正確嗎！？");
        }

        public ActionResult SearchAttendingCoach(QueryViewModel viewModel, String userName)
        {
            ViewBag.ViewModel = viewModel;
            IQueryable<UserProfile> items = userName.PromptUserProfileByName(models);
            var coaches = models.PromptEffectiveCoach();

            items = items.Where(u => coaches.Any(c => c.CoachID == u.UID));

            if (items.Count() > 0)
                return View("~/Views/TrialConsole/Module/SelectAttendingCoach.cshtml", items);
            else
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "Opps！您確定您輸入的資料正確嗎！？");
        }

        public ActionResult UpdateTrialLearner(TrialLearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ModelState.Clear();

            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<TrialLearner>().Where(c => c.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            if (viewModel.UpdateMethod == TrialLearnerViewModel.UpdateWhat.Status)
            {
                item.Status = (int?)viewModel.Status;
            }
            else if (viewModel.UpdateMethod == TrialLearnerViewModel.UpdateWhat.Close)
            {
                item.IsClosed = item.IsClosed == true ? false : true;
            }
            else if (viewModel.UpdateMethod == TrialLearnerViewModel.UpdateWhat.Contact)
            {
                if (!viewModel.Status.HasValue)
                {
                    return Json(new { result = false, message = "請勾選聯繫狀態!" });
                }

                if (!viewModel.AssigneeID.HasValue)
                {
                    return Json(new { result = false, message = "請選擇聯繫教練!" });
                }

                item.Status = (int?)viewModel.Status;
                item.AssigneeID = viewModel.AssigneeID;
                item.AssignDate = DateTime.Now;
                item.HowToKnow = new EntitySet<HowToKnow>();
                if (viewModel.MediaID != null)
                {
                    item.HowToKnow.AddRange(viewModel.MediaID.Select(m => new HowToKnow
                    {
                        MediaID = m,
                    }));
                }
            }
            else if (viewModel.UpdateMethod == TrialLearnerViewModel.UpdateWhat.Reservation)
            {
                if (!viewModel.Status.HasValue)
                {
                    return Json(new { result = false, message = "請勾選體驗狀態!" });
                }

                if (!viewModel.AttendingCoach.HasValue)
                {
                    return Json(new { result = false, message = "請選擇體驗教練!" });
                }

                item.Status = (int?)viewModel.Status;
                item.AttendingCoach = viewModel.AttendingCoach;
                item.ReserveDate = DateTime.Now;
            }

            models.SubmitChanges();

            return Json(new { result = true, AssignDate = item.AssignDate.ToString(), ReserveDate = item.ReserveDate.ToString(), Status = $"{(TrialLearner.TrialStatusDefinition?)item.Status}" });
        }


    }
}