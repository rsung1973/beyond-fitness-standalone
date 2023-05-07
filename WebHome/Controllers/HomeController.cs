using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using WebHome.Models;
using WebHome.Models.DataEntity;
using WebHome.Models.ViewModel;
using CommonLib.Utility;
using WebHome.Security.Authorization;
using WebHome.Models.Locale;
using WebHome.Properties;
using System.Threading;

namespace WebHome.Controllers
{
    public class HomeController : SampleController<UserProfile>
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger, IServiceProvider serviceProvider) : base(serviceProvider)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            //var residentID = "00001-1011400";
            //var jsonData = new
            //{
            //    ResidentID = residentID,
            //    AuthToken = new String[] { residentID.EncryptKey(), residentID.EncryptKey(), residentID.EncryptKey() }
            //};

            //var json = jsonData.JsonStringify();
            return RedirectToAction("Main", "MainActivity");
            //return View("~/Views/Home/Index.cshtml");
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        [AuthorizedSysAdmin]
        public ActionResult AllSettings()
        {
            return Json(new
            {
                AppSettings = AppSettings.Default,
                TimerCount = Timer.ActiveCount
            });
        }
    }
}
