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
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [CoachOrAssistantAuthorize]
    public class ClassFacetController : SampleController<UserProfile>
    {
        public ClassFacetController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: ClassFacet
        public ActionResult ClassIndex(int? lessonID)
        {
            var item = models.GetTable<LessonTime>().Where(i => i.LessonID == lessonID).First();
            return View(item);
        }
        public ActionResult ShowUndone(int? lessonID, int? direction)
        {
            var current = models.GetTable<LessonTime>().Where(t => t.LessonID == lessonID).FirstOrDefault();
            if (current != null)
            {
                LessonTime item;
                if (direction < 0)
                {
                    item = models.GetTable<LessonTime>().Where(t => t.AttendingCoach == current.AttendingCoach && t.ClassTime < current.ClassTime)
                        .Where(t => t.LessonAttendance == null)
                        .OrderByDescending(t => t.ClassTime).FirstOrDefault();
                }
                else
                {
                    item = models.GetTable<LessonTime>().Where(t => t.AttendingCoach == current.AttendingCoach && t.ClassTime > current.ClassTime)
                        .Where(t => t.LessonAttendance == null)
                        .OrderBy(t => t.ClassTime).FirstOrDefault();
                }
                if (item != null)
                    return View("~/Views/ClassFacet/Module/WidgetGrid.ascx", item);
            }

            return new EmptyResult();

        }

        public ActionResult RebookingByCoach(int id)
        {

            LessonTime item = models.GetTable<LessonTime>().Where(l => l.LessonID == id).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "修改上課時間資料不存在!!");
            }

            ViewBag.ViewModel = new LessonTimeViewModel
            {
                LessonID = item.LessonID,
                ClassDate = item.ClassTime.Value,
                CoachID = item.AttendingCoach.Value,
                //Duration = item.DurationInMinutes.Value,
                TrainingBySelf = (LessonTime.SelfTrainingDefinition?)item.TrainingBySelf,
                BranchID = item.BranchID.Value
            };

            return View("~/Views/ClassFacet/Module/RebookingByCoach.ascx", item);

        }


        public async Task<ActionResult> UpdateBookingByCoach(LessonTimeViewModel viewModel)
        {

            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();
            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            LessonTime item = models.GetTable<LessonTime>().Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "修改上課時間資料不存在!!");
            }

            if (item.LessonAttendance != null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "已完成上課，不可修改!!");
            }

            if (item.ContractTrustTrack.Any(t => t.SettlementID.HasValue))
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "課程資料已信託，不可修改!!");
            }

            var coach = models.GetTable<ServingCoach>().Where(c => c.CoachID == viewModel.CoachID).FirstOrDefault();
            if (coach == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "上課教練資料錯誤!!");
            }

            if (!viewModel.ClassDate.HasValue)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "請選擇上課日期間!!");
            }

            if(!item.BranchStore.IsVirtualClassroom() && !item.IsSTSession() && !models.GetTable<CoachWorkplace>()
                            .Any(c => c.BranchID == item.BranchID
                                && c.CoachID == item.AttendingCoach) 
                && viewModel.ClassDate.Value<DateTime.Today.AddDays(1))
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "此時段不允許跨店預約!!");
            }


            LessonTime timeItem = new LessonTime
            {
                InvitedCoach = item.InvitedCoach,
                AttendingCoach = item.AttendingCoach,
                ClassTime = viewModel.ClassDate,
                DurationInMinutes = item.DurationInMinutes
            };

            if (item.IsPTSession())
            {
                if (models.GetTable<Settlement>().Any(s => s.StartDate <= viewModel.ClassDate && s.EndExclusiveDate > viewModel.ClassDate))
                {
                    ViewBag.Message = "修改上課時間(" + String.Format("{0:yyyy/MM/dd}", viewModel.ClassDate) + "已信託結算!!";
                    return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml");
                }
            }
            
            if(!item.IsCoachPISession() && !item.IsSTSession())
            {
                var users = models.CheckOverlappingBooking(timeItem, item);
                if (users.Count() > 0)
                {
                    ViewBag.Message = "上課成員(" + String.Join("、", users.Select(u => u.RealName)) + ")上課時間重複!!";
                    return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml");
                }
            }
            else
            {
                if (viewModel.ClassEndTime.HasValue)
                {
                    timeItem.DurationInMinutes =
                             (int)(viewModel.ClassEndTime.Value - viewModel.ClassDate.Value).TotalMinutes;
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View(Startup.Properties["ReportInputError"]);
            }

            var changeCoach = item.AttendingCoach != viewModel.CoachID;

            if (item.IsCoachPISession())
            {
                if (viewModel.AttendeeID == null || viewModel.AttendeeID.Length == 0)
                {
                    models.DeleteAll<LessonTime>(r => r.LessonID != item.LessonID && r.GroupID == item.GroupID);
                    models.DeleteAll<RegisterLesson>(r => r.RegisterID != item.RegisterID && r.RegisterGroupID == item.GroupID);
                }
                else
                {
                    models.DeleteAll<LessonTime>(r => r.LessonID != item.LessonID && r.GroupID == item.GroupID
                                && !viewModel.AttendeeID.Contains(r.AttendingCoach.Value));
                    models.DeleteAll<RegisterLesson>(r => r.RegisterID != item.RegisterID && r.RegisterGroupID == item.GroupID
                                && !viewModel.AttendeeID.Contains(r.UID));
                    foreach (var uid in viewModel.AttendeeID.Distinct())
                    {
                        if (!models.GetTable<RegisterLesson>().Any(r => r.UID == uid && r.RegisterGroupID == item.GroupID))
                        {
                            var coachPI = models.GetTable<ServingCoach>().Any(s => s.CoachID == uid)
                                    ? LessonsController.SpawnCoachPI(item, uid, uid)
                                    : LessonsController.SpawnCoachPI(item, uid, coach.CoachID);
                            models.GetTable<LessonTime>().InsertOnSubmit(coachPI);
                        }
                    }
                }

                models.SubmitChanges();

                foreach (var s in models.GetTable<LessonTime>().Where(l => l.GroupID == item.GroupID))
                {
                    s.ClassTime = viewModel.ClassDate;
                    if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassDate.Value.Hour))
                        s.HourOfClassTime = viewModel.ClassDate.Value.Hour;

                    s.DurationInMinutes = timeItem.DurationInMinutes;
                    s.BranchID = viewModel.BranchID;

                    //item.TrainingBySelf = viewModel.TrainingBySelf;
                }
            }
            else
            {

                item.InvitedCoach = viewModel.CoachID;
                item.AssignLessonAttendingCoach(coach);
                item.ClassTime = viewModel.ClassDate;
                if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassDate.Value.Hour))
                    item.HourOfClassTime = viewModel.ClassDate.Value.Hour;

                item.DurationInMinutes = timeItem.DurationInMinutes;
                item.BranchID = viewModel.BranchID;
                foreach (var t in item.ContractTrustTrack)
                {
                    t.EventDate = viewModel.ClassDate.Value;
                }
                //item.TrainingBySelf = viewModel.TrainingBySelf;
            }

            models.SubmitChanges();

            if (item.IsPISession())
            {
                models.ExecuteCommand("update TuitionInstallment set PayoffDate = {0} where RegisterID = {1} ", item.ClassTime, item.RegisterID);
            }

            if(!item.IsSTSession())
            {
                item.BookingLessonTimeExpansion(models, item.ClassTime.Value, item.DurationInMinutes.Value);

                models.ExecuteCommand("delete PreferredLessonTime where LessonID = {0}", item.LessonID);
                item.ProcessBookingWhenCrossBranch(models);
            }

            return Json(new
            {
                result = true,
                message = "上課時間修改完成!!",
                changeCoach = changeCoach,
                classTime = String.Format("{0:yyyy/MM/dd H:mm}", item.ClassTime) + "-" + String.Format("{0:H:mm}", item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value))
            });

        }


        public ActionResult EditRecentStatus(int uid)
        {
            UserProfile profile = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (profile == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "學員資料錯誤!!");
            }

            return View("~/Views/ClassFacet/Module/EditRecentStatus.ascx", profile);
        }

        public ActionResult CommitRecentStatus(int uid, String recentStatus)
        {
            UserProfile profile = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (profile == null)
            {
                return Json(new { result = false, message = "學員資料錯誤!!" });
            }

            profile.RecentStatus = recentStatus.GetEfficientString();

            models.SubmitChanges();
            return Json(new { result = true, message = "資料更新完成!!" });

        }

        public ActionResult ShowLessonWidget(int lessonID, int? registerID)
        {
            var model = models.GetTable<LessonTime>().Where(t => t.LessonID == lessonID).First();
            ViewBag.RegisterID = registerID;
            return View("~/Views/ClassFacet/Module/LessonWidget.ascx", model);
        }

        public ActionResult LessonContent(int lessonID, int registerID)
        {
            var item = models.GetTable<LessonTime>().Where(t => t.LessonID == lessonID).First();
            var model = item.GroupingLesson.RegisterLesson.Where(r => r.RegisterID == registerID).First();

            ViewBag.LessonTime = item;
            return View("~/Views/ClassFacet/Module/LessonContent.ascx", model);
        }

        public ActionResult LearnerRecentLessons(int uid, int? lessonID)
        {
            var item = models.GetTable<LessonTime>().Where(u => u.LessonID == lessonID)
                .Where(l => l.GroupingLesson.RegisterLesson.Any(r => r.UID == uid))
                .FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "課程資料錯誤!!");
            }

            ViewBag.LessonTime = item;
            return View("~/Views/ClassFacet/Module/LearnerRecentLessons.ascx", item.GroupingLesson.RegisterLesson.Where(r => r.UID == uid).First());
        }

        public ActionResult LearnerAssessment(int uid, int? lessonID)
        {
            var item = models.GetTable<LessonFitnessAssessment>().Where(u => u.UID == uid)
                .OrderByDescending(u => u.AssessmentID)
                .FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "體能分析表資料錯誤!!");
            }

            return View("~/Views/ClassFacet/Module/LearnerAssessment.ascx", item);
        }

        public ActionResult BookingByCoach(FullCalendarViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/ClassFacet/Module/BookingByCoach.ascx");
        }

        public ActionResult CommitExercisePurpose(ExercisePurposeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "學員資料錯誤!!");
            }

            if (item.PersonalExercisePurpose == null)
            {
                item.PersonalExercisePurpose = new PersonalExercisePurpose { };
            }

            item.PersonalExercisePurpose.Purpose = viewModel.Purpose;
            models.SubmitChanges();

            return Json(new { result = true, message = viewModel.Purpose });

        }

        public ActionResult EditPowerAbility(ExercisePurposeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "學員資料錯誤!!");
            }

            return View("~/Views/ClassFacet/Module/EditPowerAbility.ascx", item);
        }


        public ActionResult CommitPowerAbility(ExercisePurposeViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditPowerAbility(viewModel);
            UserProfile item = result.Model as UserProfile;

            if (item == null)
                return result;

            if (item.PersonalExercisePurpose == null)
            {
                item.PersonalExercisePurpose = new PersonalExercisePurpose { };
            }

            switch(viewModel.Feature)
            {
                case "Flexibility":
                    item.PersonalExercisePurpose.Flexibility = viewModel.Point;
                    break;
                case "Cardiopulmonary":
                    item.PersonalExercisePurpose.Cardiopulmonary = viewModel.Point;
                    break;
                case "MuscleStrength":
                    item.PersonalExercisePurpose.MuscleStrength = viewModel.Point;
                    break;
                default:
                    item.PersonalExercisePurpose.PowerAbility = viewModel.Ability;
                    break;
            }

            models.SubmitChanges();

            return Json(new { result = true, message = viewModel.Ability });

        }

        public ActionResult GetPowerAbility(ExercisePurposeViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditPowerAbility(viewModel);
            UserProfile item = result.Model as UserProfile;

            if (item == null || item.PersonalExercisePurpose == null)
                return Json(new object { });

            var data = item.PersonalExercisePurpose;

            return Content(new { data.Cardiopulmonary, data.Flexibility, data.MuscleStrength, data.PowerAbility }.JsonStringify(), "application/json");

        }


        public ActionResult CommitPurposeItem(ExercisePurposeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "學員資料錯誤!!");
            }

            viewModel.PurposeItem = viewModel.PurposeItem.GetEfficientString();
            if (viewModel.PurposeItem == null || viewModel.PurposeItem.Length > 20)
            {
                return Json(new { result = false, message = "請輸入目標最多20個字!!" });
            }

            item.AssertPurposeItem(models, viewModel.PurposeItem);

            return Json(new { result = true });

        }

        public ActionResult ExercisePurposeItemList(ExercisePurposeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewBag.IsComplete = viewModel.IsComplete;

            var item = models.GetTable<PersonalExercisePurpose>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "學員資料錯誤!!");
            }

            if (viewModel.IsComplete == true)
            {
                return View("~/Views/ClassFacet/Module/CompletePurposeItemList.ascx", item);
            }
            else
            {
                return View("~/Views/ClassFacet/Module/ExercisePurposeItemList.ascx", item);
            }
        }

        public ActionResult DeletePurposeItem(ExercisePurposeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.DeleteAny<PersonalExercisePurposeItem>(p => p.UID == viewModel.UID && p.ItemID == viewModel.ItemID);

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            return Json(new { result = true });
        }

        public ActionResult CompletePurposeItem(ExercisePurposeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<PersonalExercisePurposeItem>().Where(p => p.UID == viewModel.UID && p.ItemID == viewModel.ItemID).FirstOrDefault();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            item.CompleteDate = DateTime.Now;
            models.SubmitChanges();

            return Json(new { result = true });
        }
    }
}