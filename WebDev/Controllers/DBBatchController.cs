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

namespace WebHome.Controllers
{
    public class DBBatchController : SampleController<UserProfile>
    {
        public DBBatchController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

        public IActionResult CheckContractLearner(MonthlyIndicatorQueryViewModel viewModel)
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

            var item = viewModel.GetAlmostMonthlyIndicator(models, true);

            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsGoback.cshtml", model: "資料尚未設定!!");
            }

            ViewBag.ViewModel = viewModel;
            ViewBag.DataItem = item;

            return View(item);
        }
    }
}
