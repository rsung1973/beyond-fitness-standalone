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
    public class LearnerCalendar2020ViewComponent : ViewComponent
    {
        protected ModelSource<UserProfile> models;
        protected ModelStateDictionary _modelState;

        public LearnerCalendar2020ViewComponent()
        {

        }

        public Task<IViewComponentResult> InvokeAsync(DailyBookingQueryViewModel viewModel)
        {
            models = (ModelSource<UserProfile>)HttpContext.Items["Models"];
            _modelState = ViewContext.ModelState;

            return LearnerCalendar2020Async(viewModel);
        }

        public async Task<IViewComponentResult> LearnerCalendar2020Async(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/LearnerProfile/Module/LearnerCalendar2020.cshtml", profile.LoadInstance(models));
        }

    }
}
