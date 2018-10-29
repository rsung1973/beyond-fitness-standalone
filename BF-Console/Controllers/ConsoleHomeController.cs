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
    public class ConsoleHomeController : SampleController<UserProfile>
    {
        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public ActionResult Index()
        {
            var profile = HttpContext.GetUser().LoadInstance(models);
            return View(profile);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public ActionResult Calendar(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser().LoadInstance(models);
            viewModel.KeyID = profile.UID.EncryptKey();
            return View(profile);
        }

        public ActionResult CalendarEventItems(FullCalendarViewModel viewModel)
        {
            ViewResult result = (ViewResult)CalendarEvents(viewModel, true);
            result.ViewName = "~/Views/ConsoleHome/Module/EventItems.ascx";
            return result;
        }


        public ActionResult CalendarEvents(FullCalendarViewModel viewModel,bool? toHtml = false)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            DataLoadOptions ops = new DataLoadOptions();
            ops.LoadWith<LessonTime>(i => i.GroupingLesson);
            ops.LoadWith<LessonTime>(i => i.RegisterLesson);
            ops.LoadWith<GroupingLesson>(i => i.RegisterLesson);
            ops.LoadWith<RegisterLesson>(i => i.UserProfile);
            ops.LoadWith<RegisterLesson>(i => i.LessonPriceType);
            models.GetDataContext().LoadOptions = ops;


            IQueryable<LessonTime> dataItems = models.GetTable<LessonTime>();
            IQueryable<UserEvent> eventItems = models.GetTable<UserEvent>().Where(e => e.EventType == 1);
            if (viewModel.DateFrom.HasValue && viewModel.DateTo.HasValue)
            {
                dataItems = dataItems.Where(t => t.ClassTime >= viewModel.DateFrom.Value
                    && t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                eventItems = eventItems.Where(t =>
                    (t.StartDate >= viewModel.DateFrom.Value && t.StartDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.StartDate >= viewModel.DateFrom.Value && t.StartDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.EndDate >= viewModel.DateFrom.Value && t.EndDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.StartDate < viewModel.DateFrom.Value && t.EndDate >= viewModel.DateTo.Value));
            }
            else if (viewModel.DateFrom.HasValue)
            {
                dataItems = dataItems.Where(t => t.ClassTime >= viewModel.DateFrom.Value);
                eventItems = eventItems.Where(t => t.StartDate >= viewModel.DateFrom.Value);
            }
            else if (viewModel.DateTo.HasValue)
            {
                dataItems = dataItems.Where(t => t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                eventItems = eventItems.Where(t => t.EndDate < viewModel.DateTo.Value.AddDays(1));
            }
            if (viewModel.BranchID.HasValue)
            {
                dataItems = dataItems.Where(t => t.BranchID == viewModel.BranchID);
                eventItems = eventItems.Where(t => t.BranchID == viewModel.BranchID);
            }
            if (viewModel.UID.HasValue)
            {
                dataItems = dataItems.Where(t => t.AttendingCoach == viewModel.UID
                    || t.RegisterLesson.UID == viewModel.UID);
                eventItems = eventItems.Where(t => t.UID == viewModel.UID
                    || t.GroupEvent.Any(g => g.UID == viewModel.UID));
            }
            else
            {
                eventItems = eventItems.Where(f => false);
            }

            var items = dataItems.Select(d => new CalendarEventItem
            {
                EventTime = d.ClassTime,
                EventItem = d
            }).ToList();

            items.AddRange(eventItems.Select(v => new CalendarEventItem
            {
                EventTime = v.StartDate,
                EventItem = v
            }));

            if (toHtml == true)
            {

            }
            else
            {
                Response.ContentType = "application/json";
            }
            return View("~/Views/ConsoleHome/Module/CalendarEvents.ascx", items);

        }



        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public ActionResult ExerciseBillboard()
        {
            var profile = HttpContext.GetUser().LoadInstance(models);
            return View(profile);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public ActionResult InquireExerciseBillboard(ExerciseBillboardQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(!viewModel.StartDate.HasValue)
            {
                viewModel.StartDate = DateTime.Today.FirstDayOfMonth();
            }
            if(!viewModel.EndDate.HasValue)
            {
                viewModel.EndDate = DateTime.Today;
            }

            IQueryable<RegisterLesson> lessons = models.GetTable<RegisterLesson>();
            if(viewModel.BranchID.HasValue)
            {
                lessons = lessons.Join(models.GetTable<CoachWorkplace>().Where(w => w.BranchID == viewModel.BranchID), 
                    r => r.UID, w => w.CoachID, (r, w) => r);
            }

            IQueryable<LessonTime> items = models.PromptMemberExerciseLessons(lessons)
                    .Where(l => l.ClassTime >= viewModel.StartDate)
                    .Where(l => l.ClassTime < viewModel.EndDate.Value.AddDays(1));

            return View("~/Views/ConsoleHome/Module/CurrentExerciseBillboard.ascx", items);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public ActionResult InquireExerciseBillboardLastMonth(ExerciseBillboardQueryViewModel viewModel)
        {
            var queryDate = DateTime.Today.FirstDayOfMonth();
            viewModel.StartDate = queryDate.AddMonths(-1);
            viewModel.EndDate = queryDate.AddDays(-1);
            ViewResult result = (ViewResult)InquireExerciseBillboard(viewModel);
            result.ViewName = "~/Views/ConsoleHome/Module/ExerciseBillboard.ascx";
            return result;
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public ActionResult GetExerciseBillboardDetails(ExerciseBillboardQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireExerciseBillboard(viewModel);

            IQueryable<LessonTime> items = result.Model as IQueryable<LessonTime>;
            if (items == null)
                return new EmptyResult { };

            Response.ContentType = "application/json";
            return View("~/Views/ConsoleHome/Module/ExerciseBillboardDetails.ascx", items);
        }



    }
}