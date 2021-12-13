using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CommonLib.DataAccess;
using CommonLib.Core.Utility;
using CommonLib.Utility;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.DependencyInjection;
using System.Globalization;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web;
using WebHome.Models.DataEntity;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using WebHome.Models.ViewModel;
using WebHome.Models.Locale;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using WebHome.Helper;

namespace WebHome.Components
{
    public class ConsoleHomeViewComponent : ViewComponent
    {
        protected ModelSource<UserProfile> models;
        protected ModelStateDictionary _modelState;

        public ConsoleHomeViewComponent()
        {

        }

        public IViewComponentResult CalendarEventItems(FullCalendarViewModel viewModel)
        {
            ViewViewComponentResult result = (ViewViewComponentResult)CalendarEvents(viewModel, true);
            if (viewModel.MasterVer == Naming.MasterVersion.Ver2020)
            {
                result.ViewName = "~/Views/ConsoleHome/Index/Coach/EventItems.cshtml";
            }
            else
            {
                result.ViewName = "~/Views/ConsoleHome/Module/EventItems.cshtml";
            }
            return result;
        }

        public IViewComponentResult CalendarEvents(FullCalendarViewModel viewModel, bool? toHtml = false)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }


            IQueryable<LessonTime> learnerLessons = models.PromptLearnerLessons();
            IQueryable<LessonTime> coachPI = models.PromptCoachPILessons();
            IQueryable<UserEvent> eventItems = models.GetTable<UserEvent>().Where(e => !e.SystemEventID.HasValue);
            if (viewModel.DateFrom.HasValue && viewModel.DateTo.HasValue)
            {
                learnerLessons = learnerLessons.Where(t => t.ClassTime >= viewModel.DateFrom.Value
                    && t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                coachPI = coachPI.Where(t => t.ClassTime >= viewModel.DateFrom.Value
                    && t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                eventItems = eventItems.Where(t =>
                    (t.StartDate >= viewModel.DateFrom.Value && t.StartDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.StartDate >= viewModel.DateFrom.Value && t.StartDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.EndDate >= viewModel.DateFrom.Value && t.EndDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.StartDate < viewModel.DateFrom.Value && t.EndDate >= viewModel.DateTo.Value));
            }
            else if (viewModel.DateFrom.HasValue)
            {
                learnerLessons = learnerLessons.Where(t => t.ClassTime >= viewModel.DateFrom.Value);
                coachPI = coachPI.Where(t => t.ClassTime >= viewModel.DateFrom.Value);
                eventItems = eventItems.Where(t => t.StartDate >= viewModel.DateFrom.Value);
            }
            else if (viewModel.DateTo.HasValue)
            {
                learnerLessons = learnerLessons.Where(t => t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                coachPI = coachPI.Where(t => t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                eventItems = eventItems.Where(t => t.EndDate < viewModel.DateTo.Value.AddDays(1));
            }
            if (viewModel.BranchID.HasValue)
            {
                learnerLessons = learnerLessons.Where(t => t.BranchID == viewModel.BranchID);
                coachPI = coachPI.Where(t => t.BranchID == viewModel.BranchID);
                eventItems = eventItems.Where(t => t.BranchID == viewModel.BranchID);
            }
            if (viewModel.UID.HasValue)
            {
                learnerLessons = learnerLessons.Where(t => t.AttendingCoach == viewModel.UID
                                        || t.RegisterLesson.UID == viewModel.UID);
                coachPI = coachPI.Where(t => t.RegisterLesson.UID == viewModel.UID);
                eventItems = eventItems.Where(t => t.UID == viewModel.UID
                    || t.GroupEvent.Any(g => g.UID == viewModel.UID));
            }
            else
            {
                eventItems = eventItems.Where(f => false);
            }

            var items = learnerLessons
                .Select(d => new CalendarEventItem
                {
                    EventTime = d.ClassTime,
                    EventItem = d
                }).ToList();

            items.AddRange(coachPI.GroupBy(l => l.GroupID)
                .ToList()
                .Select(d => new CalendarEventItem
                {
                    EventTime = d.First().ClassTime,
                    EventItem = d.First()
                }));

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
                //Response.ContentType = "application/json";
            }

            return View("~/Views/ConsoleHome/Module/CalendarEvents.cshtml", items);

        }

        public IViewComponentResult Invoke(FullCalendarViewModel viewModel)
        {
            models = (ModelSource<UserProfile>)HttpContext.Items["Models"];
            _modelState = ViewContext.ModelState;

            return CalendarEventItems(viewModel);
        }

    }
}
