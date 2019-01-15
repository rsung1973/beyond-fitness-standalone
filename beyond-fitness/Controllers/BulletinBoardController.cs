using System;
using System.Collections.Generic;
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

using CommonLib.MvcExtension;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;


namespace WebHome.Controllers
{
    public class BulletinBoardController : SampleController<UserProfile>
    {
        // GET: BulletinBoard
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult IncomingQuestionnaireActivity()
        {
            return View("~/Views/BulletinBoard/IncomingQuestionnaireActivity.ascx");
        }

        public ActionResult IncomingLearnerRemarkActivity()
        {
            return View("~/Views/BulletinBoard/IncomingLearnerRemarkActivity.ascx");
        }


    }
}