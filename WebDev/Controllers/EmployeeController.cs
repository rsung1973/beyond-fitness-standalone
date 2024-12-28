using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNetCore.Mvc;
using WebHome.Models.DataEntity;
using WebHome.Models.ViewModel;
using WebHome.Helper;
using System.Threading;
using System.Text;
using WebHome.Models.Locale;
using CommonLib.Utility;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using Microsoft.AspNetCore.Authorization;
using System.Text.RegularExpressions;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [Authorize]
    public class EmployeeController : SampleController<UserProfile>
    {
        public EmployeeController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: Employee
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult RegisterGiftLesson(int?[] uid)
        {
            models.RegisterMonthlyGiftLesson(uid);
            return Json(new { result = true });
        }
    }
}