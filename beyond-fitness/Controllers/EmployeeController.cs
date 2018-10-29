using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using WebHome.Models.DataEntity;
using WebHome.Models.ViewModel;
using WebHome.Helper;
using System.Threading;
using System.Text;
using WebHome.Models.Locale;
using Utility;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Web.Security;
using System.Text.RegularExpressions;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [Authorize]
    public class EmployeeController : SampleController<UserProfile>
    {
        public EmployeeController() : base()
        {

        }
        // GET: Employee
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult RegisterGiftLesson()
        {
            models.RegisterMonthlyGiftLesson();
            return Json(new { result = true }, JsonRequestBehavior.AllowGet);
        }
    }
}