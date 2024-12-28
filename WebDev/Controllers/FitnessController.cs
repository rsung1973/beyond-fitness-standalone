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
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;


using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

namespace WebHome.Controllers
{
    [Authorize]
    public class FitnessController : SampleController<UserProfile>
    {
        public FitnessController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: Fitness
        public ActionResult PersonalStrengthAssessment(int uid,int[] itemID)
        {
            ViewBag.Header = "肌力系統強度";
            ViewBag.Subject = "肌力總訓練、上肢肌力總訓練、下肢肌力總訓練";
            return getAssessmentReportItem(uid, itemID);
        }

        public ActionResult BodyEnergyAssessment(int uid, int[] itemID)
        {
            return getAssessmentReportItem(uid, itemID);
        }

        public ActionResult MuscleStrengthAssessment(int uid, int[] itemID)
        {
            return getAssessmentReportItem(uid, itemID);
        }

        public ActionResult BodyEnergyMuscleStrengthAssessment(int uid, int[] itemID)
        {
            return getAssessmentReportItem(uid, itemID);
        }

        public ActionResult EnhancedTraining(int uid, int[] itemID)
        {
            //ViewBag.Header = "訓練系統強度";
            //ViewBag.Subject = "增強式訓練";
            return getAssessmentReportItem(uid, itemID);
        }




        private ActionResult getAssessmentReportItem(int uid, int[] itemID)
        {
            DataLoadOptions ops = new DataLoadOptions();
            ops.LoadWith<LessonFitnessAssessment>(f => f.LessonFitnessAssessmentReport);
            ops.LoadWith<LessonFitnessAssessmentReport>(f => f.FitnessAssessmentItem);
            models.DataContext.LoadOptions = ops;

            var items = models.GetTable<LessonFitnessAssessment>().Where(u => u.UID == uid)
                .Where(u => u.LessonFitnessAssessmentReport.Count(r => itemID.Contains(r.ItemID) && (r.TotalAssessment.HasValue || r.SingleAssessment.HasValue)) > 0);

            if (items.Count() == 0)
                return View("EmptyAssessment");
            else
                return View(items);
        }

        public ActionResult EditLearnerHealth(int lessonID,int uid)
        {
            var model = models.GetTable<LessonFitnessAssessment>().Where(f => f.LessonID == lessonID && f.UID == uid).FirstOrDefault();
            if(model==null)
            {
                ViewBag.Message = "學員課程資料錯誤!!";
                return View("~/Views/Shared/AlertMessage.ascx");
            }
            else
            {
                return View("~/Views/Fitness/LearnerHealthAssessment.ascx", model);
            }
        }
    }
}