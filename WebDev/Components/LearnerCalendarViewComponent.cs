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
using WebHome.Helper;

namespace WebHome.Components
{
    public class LearnerCalendarViewComponent : ViewComponent
    {

        protected ModelSource<UserProfile> models;
        protected ModelStateDictionary _modelState;

        public LearnerCalendarViewComponent()
        {

        }

        public Task<IViewComponentResult> InvokeAsync(DailyBookingQueryViewModel viewModel)
        {
            models = (ModelSource<UserProfile>)HttpContext.Items["Models"];
            _modelState = ViewContext.ModelState;

            return LearnerCalendarAsync(viewModel);
        }

        public async Task<IViewComponentResult> LearnerCalendarAsync(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/LearnerProfile/Module/LearnerCalendar.cshtml", profile.LoadInstance(models));
        }
    }
}
