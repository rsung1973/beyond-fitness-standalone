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
using WebHome.Helper.BusinessOperation;

namespace WebHome.Components
{
    public class AchievementConsoleViewComponent : ViewComponent
    {
        protected ModelSource<UserProfile> models;
        protected ModelStateDictionary _modelState;

        public AchievementConsoleViewComponent()
        {

        }

        public IViewComponentResult Invoke(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            models = (ModelSource<UserProfile>)HttpContext.Items["Models"];
            _modelState = ViewContext.ModelState;

            return InquireMonthlyCoachRevenue(viewModel);
        }


        public IViewComponentResult InquireMonthlyCoachRevenue(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            int? coachID = viewModel.CoachID;
            if (viewModel.KeyID != null)
            {
                coachID = viewModel.DecryptKeyValue();
            }

            IQueryable<MonthlyIndicator> indicatorItems = viewModel.InquireMonthlyIndicator(models);

            IQueryable<MonthlyCoachRevenueIndicator> items = models.GetTable<MonthlyCoachRevenueIndicator>()
                .Where(c => c.CoachID == viewModel.CoachID)
                .Join(indicatorItems, c => c.PeriodID, m => m.PeriodID, (c, m) => c);

            return View("~/Views/AchievementConsole/Module/InquireMonthlyCoachRevenue.cshtml", items);
        }

    }
}
