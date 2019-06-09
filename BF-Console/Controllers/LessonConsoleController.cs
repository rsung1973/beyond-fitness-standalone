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

namespace WebHome.Controllers
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
            return View("~/Views/LessonConsole/ProcessModal/ProcessCrossBranch.cshtml", item);
        }

        public ActionResult ShowTodayLessons(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (!viewModel.ClassTimeStart.HasValue)
            {
                viewModel.ClassTimeStart = DateTime.Today;
            }

            var profile = HttpContext.GetUser();
            if (!viewModel.BranchID.HasValue)
            {
                if (profile.IsManager() || profile.IsViceManager())
                {
                    var branch = models.GetTable<BranchStore>().Where(b => b.ManagerID == profile.UID || b.ViceManagerID == profile.UID)
                            .FirstOrDefault();
                    if (branch != null)
                    {
                        viewModel.BranchID = branch.BranchID;
                        viewModel.BranchName = branch.BranchName;
                    }
                }
            }

            return View("~/Views/LessonConsole/ProcessModal/TodayLessons.cshtml", profile.LoadInstance(models));
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

        public ActionResult LessonContentDetails(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            LessonTime item = models.GetTable<LessonTime>()
                    .Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();

            if (item == null)
            {
                return Json(new { result = false, message = "課程資料錯誤!!" }, JsonRequestBehavior.AllowGet);
            }

            return View("~/Views/LessonConsole/Module/LessonContentDetails.cshtml", item);

        }

        public ActionResult ViewTrainingExecution(LessonTimeBookingViewModel viewModel)
        {
            ActionResult result = LessonContentDetails(viewModel);
            if (result is JsonResult)
                return result;

            ViewBag.Learner = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (ViewBag.Learner == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" }, JsonRequestBehavior.AllowGet);
            }

            ((ViewResult)result).ViewName = "~/Views/LearnerProfile/ProfileModal/ViewTrainingExecution.cshtml";
            return result;
        }


        public ActionResult CloneLearnerTrainingPlan(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if(viewModel.KeyID!=null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            LessonTime item = models.GetTable<LessonTime>()
                .Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();

            if (item == null)
            {
                return Json(new { result = false, message = "課程資料錯誤!!" }, JsonRequestBehavior.AllowGet);
            }

            if (!viewModel.UID.HasValue)
            {
                return Json(new { result = false, message = "未指定同步來源之學員!!" }, JsonRequestBehavior.AllowGet);
            }

            var lessonItems = item.GroupingLesson.RegisterLesson.Where(r => r.UID != viewModel.UID.Value);
            if (lessonItems.Count() == 0)
            {
                return Json(new { result = false, message = "課程非一對多!!" }, JsonRequestBehavior.AllowGet);
            }

            var source = item.AssertLearnerTrainingPlan(models, viewModel.UID.Value);
            foreach(var lesson in lessonItems)
            {
                var target = item.AssertLearnerTrainingPlan(models, lesson.UID);
                models.CloneTrainingPlan(source, target);
            }

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);

        }

        public ActionResult CloneCoachPITrainingPlan(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            LessonTime item = models.GetTable<LessonTime>()
                .Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();

            if (item == null)
            {
                return Json(new { result = false, message = "課程資料錯誤!!" }, JsonRequestBehavior.AllowGet);
            }

            var lessonItems = models.GetTable<LessonTime>().Where(l => l.GroupID == item.GroupID && l.LessonID != item.LessonID);
            if (lessonItems.Count() == 0)
            {
                return Json(new { result = false, message = "課程非一對多!!" }, JsonRequestBehavior.AllowGet);
            }

            var source = item.AssertTrainingPlan(models);
            foreach (var lesson in lessonItems)
            {
                var target = lesson.AssertTrainingPlan(models);
                models.CloneTrainingPlan(source, target);
            }

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);

        }

        public ActionResult CopyTrainingPlan(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            LessonTime copyTo = models.GetTable<LessonTime>()
                .Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();

            if (copyTo == null)
            {
                return Json(new { result = false, message = "課程資料錯誤!!" }, JsonRequestBehavior.AllowGet);
            }

            LessonTime copyFrom = models.GetTable<LessonTime>()
                .Where(l => l.LessonID == viewModel.CopyFrom).FirstOrDefault();

            if (copyTo == null)
            {
                return Json(new { result = false, message = "複製來源課程資料錯誤!!" }, JsonRequestBehavior.AllowGet);
            }

            var source = copyFrom.AssertLearnerTrainingPlan(models, viewModel.UID.Value);
            var target = copyTo.AssertLearnerTrainingPlan(models, viewModel.UID.Value);
            models.CloneTrainingPlan(source, target);

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);

        }

        public ActionResult SwitchLessonFavorite(TrainingExecutionViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (models.GetTable<FavoriteLesson>().Any(f => f.ExecutionID == viewModel.ExecutionID && f.UID == viewModel.UID))
            {
                models.ExecuteCommand("delete FavoriteLesson where ExecutionID = {0} and UID = {1}", viewModel.ExecutionID, viewModel.UID);
            }
            else
            {
                models.ExecuteCommand(@"
                        insert FavoriteLesson (ExecutionID,UID)
                        SELECT        TrainingPlan.ExecutionID, UserProfile.UID
                        FROM            TrainingPlan CROSS JOIN
                                                 UserProfile
                        WHERE        (TrainingPlan.ExecutionID = {0}) AND (UserProfile.UID = {1})", viewModel.ExecutionID, viewModel.UID);
            }

            return Json(new { result = true, message = models.GetTable<FavoriteLesson>().Where(f => f.ExecutionID == viewModel.ExecutionID).Count() }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult InquireLesson(LessonQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<LessonTime> items = models.GetTable<LessonTime>();
            if (viewModel.LearnerID.HasValue)
            {
                items = viewModel.LearnerID.Value.PromptLearnerLessons(models);
            }

            if (viewModel.CoachID.HasValue)
                items = items.Where(t => t.AttendingCoach == viewModel.CoachID);

            if (viewModel.QueryStart.HasValue)
                items = items.Where(t => t.ClassTime >= viewModel.QueryStart && t.ClassTime < viewModel.QueryStart.Value.AddMonths(1));

            if (viewModel.ClassTime.HasValue)
                items = items.Where(t => t.ClassTime >= viewModel.ClassTime && t.ClassTime < viewModel.ClassTime.Value.AddDays(1));

            return View("~/Views/LearnerProfile/Module/LessonItems.cshtml", items);
        }

    }
}