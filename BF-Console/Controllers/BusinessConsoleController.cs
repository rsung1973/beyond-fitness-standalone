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
    public class BusinessConsoleController : SampleController<UserProfile>
    {
        // GET: BusinessConsole
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult PrepareRevenueGoal(MonthlyIndicatorQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.PeriodID = viewModel.DecryptKeyValue();
            }

            if (!viewModel.Year.HasValue || !viewModel.Month.HasValue)
            {
                viewModel.Year = DateTime.Today.Year;
                viewModel.Month = DateTime.Today.Month;
            }

            var item = models.GetTable<MonthlyIndicator>().Where(i => i.PeriodID == viewModel.PeriodID
                            || (i.Year == viewModel.Year && i.Month == viewModel.Month)).FirstOrDefault();

            if (item == null)
            {
                item = models.InitializeMonthlyIndicator(viewModel.Year.Value, viewModel.Month.Value);
            }

            item.UpdateMonthlyAchievement(models);
            item.UpdateMonthlyAchievementGoal(models);

            return Json(new { result = true, message = "OK" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult SelectMonth(MonthlySelectorViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (!viewModel.RecentCount.HasValue)
            {
                viewModel.RecentCount = 6;
            }
            return View("~/Views/Common/SelectMonth.cshtml");
        }

    }
}