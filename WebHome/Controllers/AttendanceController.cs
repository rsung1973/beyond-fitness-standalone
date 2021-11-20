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
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;

namespace WebHome.Controllers
{
    public class AttendanceController : LessonsController
    {
        public AttendanceController(IServiceProvider serviceProvider) : base(serviceProvider) { }
        // GET: Attendance

        public ActionResult SaveAssessment(TrainingAssessmentViewModel viewModel)
        {
            ActionResult result;
            LessonTimeExpansion model = storeAssessment(viewModel, out result);

            if (result != null)
                return result;

            models.SubmitChanges();
            return Json(new { result = true, message = "資料存檔完成!!" });

        }

        public ActionResult SaveThenAddTraining(TrainingAssessmentViewModel viewModel)
        {
            ActionResult result;
            LessonTimeExpansion model = storeAssessment(viewModel, out result);

            if (result != null)
                return result;

            models.SubmitChanges();

            return AddTraining(viewModel);
        }

        private LessonTimeExpansion storeAssessment(TrainingAssessmentViewModel viewModel,out ActionResult result,bool assessmentOnly = false)
        {
            result = null;
            LessonTimeExpansion model = null;
            LessonTimeExpansion item = (LessonTimeExpansion)HttpContext.GetCacheValue("Training");
            if (item != null)
            {
                model = models.GetTable<LessonTimeExpansion>()
                    .Where(l => l.ClassDate == item.ClassDate
                        && l.RegisterID == item.RegisterID
                        && l.Hour == item.Hour).FirstOrDefault();
            }

            if (model == null)
            {
                result = Json(new { result = false, message = "未登記此上課時間!!", forceLogout = true });
                return null;
            }

            if (model.LessonTime.TrainingPlan.Count == 0)
            {
                result = Json(new { result = false, message = "尚未編定上課內容!!" });
                return null;
            }

            var coach = models.GetTable<ServingCoach>().Where(c => c.CoachID == viewModel.CoachID).FirstOrDefault();
            if(coach==null)
            {
                result = Json(new { result = false, message = "上課教練資料錯誤!!" });
                return null;
            }

            if (assessmentOnly != true)
            {
                if (viewModel.Conclusion != null)
                {
                    int itemIdx = 0;
                    for (int idx = 0; idx < viewModel.Conclusion.Length && idx < model.LessonTime.TrainingPlan.Count; idx++)
                    {
                        model.LessonTime.TrainingPlan[idx].TrainingExecution.Conclusion = viewModel.Conclusion[idx];
                        foreach (var trainItem in model.LessonTime.TrainingPlan[idx].TrainingExecution.TrainingItem)
                        {
                            trainItem.ActualStrength = viewModel.ActualStrength[itemIdx];
                            trainItem.ActualTurns = viewModel.ActualTurns[itemIdx];
                            itemIdx++;
                        }
                    }
                }

                LessonPlan plan = model.LessonTime.LessonPlan;
                plan.Warming = viewModel.Warming;
                //plan.RecentStatus = viewModel.RecentStatus;
                //model.RegisterLesson.UserProfile.RecentStatus = viewModel.RecentStatus;
                plan.EndingOperation = viewModel.EndingOperation;
                plan.Remark = viewModel.Remark;
            }

            LessonTrend trend = model.LessonTime.LessonTrend;
            if (trend == null)
                trend = model.LessonTime.LessonTrend = new LessonTrend { };
            trend.ActionLearning = viewModel.ActionLearning;
            trend.PostureRedress = viewModel.PostureRedress;
            trend.Training = viewModel.Training;
            trend.Counseling = viewModel.Counseling;

            FitnessAssessment fitness = model.LessonTime.FitnessAssessment;
            if (fitness == null)
                fitness = model.LessonTime.FitnessAssessment = new FitnessAssessment { };
            fitness.Flexibility = viewModel.Flexibility;
            fitness.Cardiopulmonary = viewModel.Cardiopulmonary;
            fitness.Endurance = viewModel.Endurance;
            fitness.ExplosiveForce = viewModel.ExplosiveForce;
            fitness.SportsPerformance = viewModel.SportsPerformance;
            fitness.Strength = viewModel.Strength;

            model.LessonTime.AssignLessonAttendingCoach(coach);
            model.LessonTime.RegisterLesson.Attended = (int)Naming.LessonStatus.上課中;

            return model;
        }

        public ActionResult CheckLessonEmphasis(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            LessonTime item = models.GetTable<LessonTime>().Where(t => t.LessonID == viewModel.LessonID).FirstOrDefault();

            var items = models.GetTable<TrainingPlan>().Where(p => p.LessonID == viewModel.LessonID)
                            .Where(p => p.TrainingExecution.Emphasis == null)
                            .Select(p => p.RegisterLesson);

            int count = items.Count();
            if (count == 1 && item.TrainingPlan.Count() == 1)
            {
                return Json(new { result = false, message = "請先輸入上課重點!?" });
            }
            else if (count > 0)
            {
                return Json(new { result = false, message = String.Concat(String.Join("、", items.Select(r => r.UserProfile.RealName)), "的上課重點未完成!?") });
            }
            else
            {
                return Json(new { result = true });
            }
        }


        public async Task<ActionResult> AttendLessonAsync(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if(viewModel.KeyID!=null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            LessonTime item = models.GetTable<LessonTime>().Where(t => t.LessonID == viewModel.LessonID).FirstOrDefault();

            if (item == null)
                return Json(new { result = false, message = "未登記此上課時間!!" });

            if (item.TrainingPlan.Select(p => p.TrainingExecution.Emphasis).Any(a => a == null))
            {
                return Json(new { result = false, message = "未輸入課表重點，無法完成上課!!" });
            }

            item.LessonPlan.Remark = viewModel.Remark.GetEfficientString();

            models.AttendLesson(item, profile, viewModel.QuestionnaireGroupID);
            //foreach (var r in item.GroupingLesson.RegisterLesson)
            //{
            //    models.CheckLearnerQuestionnaireRequest(r);
            //}

            return Json(new { result = true, message = "資料存檔完成!!" });

        }

        public ActionResult LearnerAttendLesson(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }
            LessonTime item = models.GetTable<LessonTime>().Where(t => t.LessonID == viewModel.LessonID).FirstOrDefault();

            if (item == null)
                return Json(new { result = false, message = "未登記此上課時間!!" });

            item.LessonPlan.CommitAttendance = DateTime.Now;

            models.SubmitChanges();

            return Json(new { result = true, message = "資料存檔完成!!" });

        }

        public async Task<ActionResult> CommitAssessmentAsync(TrainingAssessmentViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();
            LessonTimeExpansion model = storeAssessment(viewModel, out ActionResult result, true);

            if (result != null)
                return result;

            if (models.IsAttendanceOverdue(model.LessonTime))
            {
                models.SubmitChanges();
            }
            else
            {
                if (model.LessonTime.ContractTrustTrack.Any(t => t.SettlementID.HasValue))
                {
                    models.SubmitChanges();
                }
                else
                {
                    models.AttendLesson(model.LessonTime, profile);
                    //LessonAttendance attendance = model.LessonTime.LessonAttendance;
                    //if (attendance == null)
                    //{
                    //    attendance = model.LessonTime.LessonAttendance = new LessonAttendance { };
                    //    attendance.CompleteDate = DateTime.Now;
                    //    models.SubmitChanges();
                    //    foreach (var r in model.LessonTime.GroupingLesson.RegisterLesson)
                    //    {
                    //        models.CheckLearnerQuestionnaireRequest(r);
                    //    }
                    //}
                    //else
                    //{
                    //    attendance.CompleteDate = DateTime.Now;
                    //    models.SubmitChanges();
                    //}

                    //var timeItem = model.LessonTime;
                    //var group = timeItem.GroupingLesson;
                    //var lesson = group.RegisterLesson.First();
                    //if (lesson.Lessons - (lesson.AttendedLessons ?? 0) <= group.LessonTime.Count(t => t.LessonAttendance != null))
                    //{
                    //    foreach (var r in group.RegisterLesson)
                    //    {
                    //        r.Attended = (int)Naming.LessonStatus.課程結束;
                    //    }
                    //    models.SubmitChanges();
                    //}
                }
            }

            return Json(new { result = true, message = "資料存檔完成!!" });

        }


        public ActionResult EndAssessment()
        {
            LessonTimeExpansion item = (LessonTimeExpansion)HttpContext.GetCacheValue("Training");

            if (item == null)
            {
                return RedirectToAction("Coach", "Account");
            }

            HttpContext.RemoveCache("Training");
            return RedirectToAction("Coach", "Account", new { lessonDate = item.ClassDate, hour = item.Hour, registerID = item.RegisterID, lessonID = item.LessonID });
        }


    }
}