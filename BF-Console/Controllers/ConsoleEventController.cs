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
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace BFConsole.Controllers
{
    [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class ConsoleEventController : SampleController<UserProfile>
    {
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
                return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: "課程資料錯誤!!");
            }

            return View("~/Views/ConsoleEvent/EventModal/LessonItem.ascx", item);
        }

        public ActionResult ShowUserEventModal(CalendarEventQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.EventID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<UserEvent>().Where(l => l.EventID == viewModel.EventID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: "自訂行事曆資料錯誤!!");
            }

            return View("~/Views/ConsoleEvent/EventModal/UserEvent.ascx", item);
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
            //else if (item.LessonPlan != null || item.TrainingPlan.Count > 0)
            //{
            //    ViewBag.Message = "請先刪除預編課程!!";
            //    return RedirectToAction("Coach", "Account", new { lessonDate = lessonDate, message= "請先刪除預編課程!!" });
            //}
            item.RevokeBooking(models);

            return Json(new { result = true });

        }

        public ActionResult RevokeCoachEvent(CalendarEventQueryViewModel viewModel)
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

            var profile = HttpContext.GetUser();
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
            return View("~/Views/ConsoleEvent/EventModal/AddEvent.ascx");
        }

        public ActionResult AttendeeSelector(CalendarEventQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName == null)
            {
                this.ModelState.AddModelError("userName", "請輸入查詢學員!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/ConsoleHome/Shared/ReportInputError.ascx");
            }

            //var lessons = models.GetTable<RegisterLesson>()
            //        .Where(r => r.RegisterLessonContract != null)
            //        .Where(l => l.Attended != (int)Naming.LessonStatus.課程結束 )
            //        .Where(l => l.Lessons > l.GroupingLesson.LessonTime.Count)
            //        .Where(l => l.RegisterGroupID.HasValue);

            var items = viewModel.UserName.PromptLearnerByName(models);

            if (items.Count() > 0)
                return View("~/Views/ConsoleEvent/EventModal/AttendeeSelector.ascx", items);
            else
                return Json(new { result = false, message = "Opps！您確定您輸入的資料正確嗎！？" },JsonRequestBehavior.AllowGet);
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

            return View("~/Views/ConsoleEvent/EventModal/BookingLesson.ascx", item);

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
                viewModel.CoachID = item.AttendingCoach;
                viewModel.RegisterID = item.RegisterID;
            }
            return View("~/Views/ConsoleEvent/EventModal/BookingCoachPI.ascx", item);

        }

        public ActionResult BookingCustomEvent(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            if(viewModel.KeyID!=null)
            {
                viewModel.EventID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<UserEvent>().Where(v => v.EventID == viewModel.EventID
                && v.UID == profile.UID).FirstOrDefault();

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

            return View("~/Views/ConsoleEvent/EventModal/BookingCustomEvent.ascx");
        }

    }
}