using Newtonsoft.Json;
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
using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;

namespace WebHome.Controllers
{
    public class LessonEventController : SampleController<UserProfile>
    {
        public LessonEventController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

        protected void ValidateCommonBooking(LessonTimeViewModel viewModel, out ServingCoach coach, out BranchStore branch)
        {
            if (!viewModel.ClassDate.HasValue)
            {
                ModelState.AddModelError("ClassDate", "請選擇上課日期!!");
            }
            else if (viewModel.ClassDate < DateTime.Today)
            {
                ModelState.AddModelError("ClassDate", "預約時間不可早於今天!!");
            }

            branch = null;
            if (!viewModel.BranchID.HasValue)
            {
                ModelState.AddModelError("BranchID", "請選擇上課地點!!");
            }
            else
            {
                branch = models.GetTable<BranchStore>().Where(b => b.BranchID == viewModel.BranchID).FirstOrDefault();
            }

            coach = models.GetTable<ServingCoach>().Where(s => s.CoachID == viewModel.CoachID).FirstOrDefault();
            if (coach == null)
            {
                ModelState.AddModelError("CoachID", "未指定體能顧問!!");
            }

            viewModel.Place = viewModel.Place.GetEfficientString();
            if (branch?.IsVirtualClassroom() == true)
            {
                if (!viewModel.Place.ValidateMeetingRoom(branch, models))
                {
                    ModelState.AddModelError("Place", "請輸入正確會議室連結!!");
                }
            }
        }

        // GET: LessonEvent
        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach })]
        public ActionResult CommitEnterpriseBookingByCoach(LessonTimeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            ValidateCommonBooking(viewModel, out ServingCoach coach, out BranchStore branch);

            RegisterLesson lesson = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == viewModel.RegisterID).FirstOrDefault();
            if (lesson == null)
            {
                ModelState.AddModelError("RegisterID", "學員未購買課程!!");
            }

            if (lesson.Attended == (int)Naming.LessonStatus.課程結束)
            {
                ModelState.AddModelError("RegisterID", "學員課程已結束!!");
            }

            var lessonCount = lesson.GroupingLesson.LessonTime.Count;
            if (lessonCount + (lesson.AttendedLessons ?? 0) >= lesson.Lessons)
            {
                ModelState.AddModelError("RegisterID", "學員上課堂數已滿!!");
            }

            var contract = lesson.RegisterLessonEnterprise.EnterpriseCourseContract;
            if (contract.Expiration.Value < DateTime.Today)
            {
                ModelState.AddModelError("RegisterID", "企業方案合約已過期!!");
            }

            if (!this.ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View(Startup.Properties["ReportInputError"]);
            }

            if (branch?.IsVirtualClassroom() != true && !models.GetTable<CoachWorkplace>()
                            .Any(c => c.BranchID == viewModel.BranchID
                                && c.CoachID == viewModel.CoachID)
                && viewModel.ClassDate.Value < DateTime.Today.AddDays(1))
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "此時段不允許跨店預約!!");
            }

            LessonTime timeItem = new LessonTime
            {
                InvitedCoach = viewModel.CoachID,
                AttendingCoach = viewModel.CoachID,
                //ClassTime = viewModel.ClassDate.Add(viewModel.ClassTime),
                ClassTime = viewModel.ClassDate,
                DurationInMinutes = lesson.RegisterLessonEnterprise.EnterpriseCourseContent.DurationInMinutes,
                RegisterID = lesson.RegisterID,
                LessonPlan = new LessonPlan
                {

                },
                BranchID = viewModel.BranchID,
                LessonTimeSettlement = new LessonTimeSettlement
                {
                    ProfessionalLevelID = coach.LevelID.Value,
                    MarkedGradeIndex = coach.ProfessionalLevel.GradeIndex,
                    CoachWorkPlace = coach.WorkBranchID(),
                },
                Place = viewModel.Place,
            };

            if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassDate.Value.Hour))
                timeItem.HourOfClassTime = viewModel.ClassDate.Value.Hour;


            if (lesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.自主訓練)
                timeItem.TrainingBySelf = 1;

            var users = models.CheckOverlapedBooking(timeItem, lesson);
            if (users.Count() > 0)
            {
                ModelState.AddModelError("UID", "學員(" + String.Join("、", users.Select(u => u.RealName)) + ")上課時間重複!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            if (lesson.GroupingMemberCount > 1)
            {
                timeItem.GroupID = lesson.RegisterGroupID;
                timeItem.LessonFitnessAssessment.AddRange(
                    lesson.GroupingLesson.RegisterLesson.Select(
                        r => new LessonFitnessAssessment
                        {
                            UID = r.UID
                        }));
            }
            else
            {
                timeItem.LessonFitnessAssessment.Add(new LessonFitnessAssessment
                {
                    UID = lesson.UID
                });
                if (!lesson.RegisterGroupID.HasValue)
                {
                    timeItem.GroupingLesson = lesson.GroupingLesson = new GroupingLesson { };
                }
                else
                {
                    timeItem.GroupID = lesson.RegisterGroupID;
                }
            }

            models.GetTable<LessonTime>().InsertOnSubmit(timeItem);

            try
            {
                models.SubmitChanges();

                timeItem.BookingLessonTimeExpansion(models, timeItem.ClassTime.Value, timeItem.DurationInMinutes.Value);
                timeItem.ProcessBookingWhenCrossBranch(models);
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<LessonEventController>().LogError(ex, ex.Message);
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "預約未完成，請重新預約!!");
            }

            return Json(new { result = true, message = "上課時間預約完成!!" });
        }
    }
}