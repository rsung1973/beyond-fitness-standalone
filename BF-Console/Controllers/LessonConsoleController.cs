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
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace BFConsole.Controllers
{
    [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class LessonConsoleController : SampleController<UserProfile>
    {
        // GET: LessonConsole
        public ActionResult ProcessCrossBranch(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(viewModel.KeyID!=null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<LessonTime>().Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();
            return View("~/Views/LessonConsole/ProcessModal/ProcessCrossBranch.ascx", item);
        }

        public ActionResult ShowTodayLessons(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (!viewModel.ClassTimeStart.HasValue)
            {
                viewModel.ClassTimeStart = DateTime.Today;
            }

            var profile = HttpContext.GetUser();
            return View("~/Views/LessonConsole/ProcessModal/TodayLessons.ascx", profile.LoadInstance(models));
        }

        public ActionResult CommitCrossBranch(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            var profile = HttpContext.GetUser();
            LessonTime item = profile.PreferredLessonTimeToApprove(models)
                    .Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();

            if (item == null)
            {
                return Json(new { result = false, message = "課程資料錯誤!!" });
            }

            item.PreferredLessonTime.ApprovalDate = DateTime.Now;
            item.PreferredLessonTime.ApproverID = profile.UID;
            models.SubmitChanges();

            return Json(new { result = true });

        }


    }
}