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

using CommonLib.DataAccess;

using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class ConsoleEventController : SampleController<UserProfile>
    {
        public ConsoleEventController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: ConsoleEvent
        public ActionResult ShowLessonEventModal(CalendarEventQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<LessonTime>().Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "課程資料錯誤!!");
            }

            return View("~/Views/ConsoleEvent/EventModal/LessonItem.cshtml", item);
        }

        public async Task<ActionResult> ShowUserEventModalAsync(CalendarEventQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.EventID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<UserEvent>().Where(l => l.EventID == viewModel.EventID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "自訂行事曆資料錯誤!!");
            }

            var profile = await HttpContext.GetUserAsync();
            if (profile.IsAssistant() || item.UID == profile.UID)
            {
                return await BookingCustomEventAsync(new UserEventViewModel
                {
                    EventID = item.EventID,
                });
            }

            return View("~/Views/ConsoleEvent/EventModal/UserEvent.cshtml", item);
        }

        public ActionResult RevokeBooking(CalendarEventQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            LessonTime item = models.GetTable<LessonTime>().Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "課程資料錯誤!!" });
            }
            else if (item.ContractTrustTrack.Any(t => t.SettlementID.HasValue))
            {
                return Json(new { result = false, message = "課程資料已信託，不可取消!!" });
            }
            else if (item.RegisterLesson.IsPaid)
            {
                return Json(new { result = false, message = "課程資料已收款，不可取消!!" });
            }
            //else if (item.LessonPlan != null || item.TrainingPlan.Count > 0)
            //{
            //    ViewBag.Message = "請先刪除預編課程!!";
            //    return RedirectToAction("Coach", "Account", new { lessonDate = lessonDate, message= "請先刪除預編課程!!" });
            //}
            item.RevokeBooking(models);

            return Json(new { result = true });

        }

        public async Task<ActionResult> RevokeCoachEventAsync(CalendarEventQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.EventID = viewModel.DecryptKeyValue();
            }

            UserEvent item = models.DeleteAny<UserEvent>(l => l.EventID == viewModel.EventID);
            if (item == null)
            {
                return Json(new { result = false, message = "行事曆資料錯誤!!" });
            }

            var profile = await HttpContext.GetUserAsync();
            if (!profile.IsAssistant())
            {
                if (item.UID != profile.UID)
                {
                    return Json(new { result = false, message = "原行事曆發起人才可以刪除!!" });
                }
            }

            return Json(new { result = true });

        }

        public ActionResult AddEvent(CalendarEventQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/ConsoleEvent/EventModal/AddEvent.cshtml");
        }

        public ActionResult AttendeeSelector(CalendarEventQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName == null)
            {
                this.ModelState.AddModelError("userName", "請輸入查詢學員!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/ConsoleHome/Shared/ReportInputError.cshtml");
            }

            //var lessons = models.GetTable<RegisterLesson>()
            //        .Where(r => r.RegisterLessonContract != null)
            //        .Where(l => l.Attended != (int)Naming.LessonStatus.課程結束 )
            //        .Where(l => l.Lessons > l.GroupingLesson.LessonTime.Count)
            //        .Where(l => l.RegisterGroupID.HasValue);

            var items = viewModel.UserName.PromptLearnerByName(models, true);

            if (items.Count() > 0)
                return View("~/Views/ConsoleEvent/EventModal/AttendeeSelector.cshtml", items);
            else
                return Json(new { result = false, message = "Opps！您確定您輸入的資料正確嗎！？" });
        }

        public ActionResult BookingLesson(CalendarEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }
            
            var item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "學員資料錯誤!!" });
            }

            if (!viewModel.StartDate.HasValue)
            {
                viewModel.StartDate = DateTime.Today.AddHours(8);
            }
            else if (viewModel.StartDate.Value.TimeOfDay.Hours == 0)
            {
                viewModel.StartDate = viewModel.StartDate.Value.Date.AddHours(8);
            }

            return View("~/Views/ConsoleEvent/EventModal/BookingLesson.cshtml", item);

        }

        public ActionResult BookingLesson2022(CalendarEventViewModel viewModel)
        {
            var result = BookingLesson(viewModel);
            if (result is ViewResult)
            {
                ((ViewResult)result).ViewName = "~/Views/ConsoleEvent/EventModal/BookingLesson2022.cshtml";
            }
            return result;
        }


        public ActionResult BookingCoachPI(LessonTimeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(viewModel.KeyID!=null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<LessonTime>().Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();
            if (item != null)
            {
                viewModel.AttendeeID = item.GroupingLesson.RegisterLesson.Select(r => r.UID).ToArray();
                viewModel.BranchID = item.BranchID;
                viewModel.ClassDate = item.ClassTime;
                if (item.ClassTime.HasValue && item.DurationInMinutes.HasValue)
                {
                    viewModel.ClassEndTime = item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value);
                }
                viewModel.CoachID = item.AttendingCoach;
                viewModel.RegisterID = item.RegisterID;
            }

            if(!viewModel.ClassEndTime.HasValue)
            {
                viewModel.ClassEndTime = viewModel.ClassDate;
            }

            return View("~/Views/ConsoleEvent/EventModal/BookingCoachPI.cshtml", item);

        }

        public async Task<ActionResult> BookingCustomEventAsync(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if(viewModel.KeyID!=null)
            {
                viewModel.EventID = viewModel.DecryptKeyValue();
            }

            UserEvent item;
            if(profile.IsAssistant())
            {
                item = models.GetTable<UserEvent>().Where(v => v.EventID == viewModel.EventID).FirstOrDefault();
            }
            else
            {
                item = models.GetTable<UserEvent>().Where(v => v.EventID == viewModel.EventID
                    && v.UID == profile.UID).FirstOrDefault();
            }

            if (item != null)
            {
                viewModel.EventID = item.EventID;
                viewModel.UID = item.UID;
                viewModel.Title = item.Title;
                viewModel.StartDate = item.StartDate;
                viewModel.EndDate = item.EndDate;
                viewModel.ActivityProgram = item.ActivityProgram;
                viewModel.Accompanist = item.Accompanist;
                viewModel.BranchID = (Naming.BranchName?)item.BranchID;
                viewModel.Place = item.Place;
                viewModel.MemberID = item.GroupEvent.Select(g => g.UID).ToArray();
            }

            if (!viewModel.EndDate.HasValue)
            {
                viewModel.EndDate = viewModel.StartDate;
            }
            if (!viewModel.UID.HasValue)
            {
                viewModel.UID = profile.UID;
            }

            return View("~/Views/ConsoleEvent/EventModal/BookingCustomEvent.cshtml");
        }

    }
}