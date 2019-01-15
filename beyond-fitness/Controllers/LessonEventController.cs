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
using System.Web.Mvc;
using System.Web.Security;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    public class LessonEventController : SampleController<UserProfile>
    {
        public LessonEventController() : base()
        {

        }
        // GET: LessonEvent
        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach })]
        public ActionResult CommitEnterpriseBookingByCoach(LessonTimeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.ClassDate.HasValue)
            {
                ModelState.AddModelError("ClassDate", "請選擇上課日期!!");
            }
            else if (viewModel.ClassDate < DateTime.Today)
            {
                ModelState.AddModelError("ClassDate", "預約時間不可早於今天!!");
            }

            if (!viewModel.BranchID.HasValue)
            {
                ModelState.AddModelError("BranchID", "請選擇上課地點!!");
            }

            var coach = models.GetTable<ServingCoach>().Where(s => s.CoachID == viewModel.CoachID).FirstOrDefault();
            if (coach == null)
            {
                ModelState.AddModelError("CoachID", "未指定體能顧問!!");
            }

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
                return View("~/Views/Shared/ReportInputError.ascx");
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
                    MarkedGradeIndex = coach.ProfessionalLevel.GradeIndex
                }
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
            //models.SubmitChanges();

            var timeExpansion = models.GetTable<LessonTimeExpansion>();
            if (lesson.GroupingMemberCount > 1)
            {
                for (int i = 0; i <= (timeItem.DurationInMinutes + timeItem.ClassTime.Value.Minute - 1) / 60; i++)
                {
                    foreach (var regles in lesson.GroupingLesson.RegisterLesson)
                    {
                        timeExpansion.InsertOnSubmit(new LessonTimeExpansion
                        {
                            ClassDate = timeItem.ClassTime.Value.Date,
                            //LessonID = timeItem.LessonID,
                            LessonTime = timeItem,
                            Hour = timeItem.ClassTime.Value.Hour + i,
                            RegisterID = regles.RegisterID
                        });
                    }
                }
            }
            else
            {
                for (int i = 0; i <= (timeItem.DurationInMinutes + timeItem.ClassTime.Value.Minute - 1) / 60; i++)
                {
                    timeExpansion.InsertOnSubmit(new LessonTimeExpansion
                    {
                        ClassDate = timeItem.ClassTime.Value.Date,
                        //LessonID = timeItem.LessonID,
                        LessonTime = timeItem,
                        Hour = timeItem.ClassTime.Value.Hour + i,
                        RegisterID = lesson.RegisterID
                    });
                }
            }

            try
            {
                models.SubmitChanges();
                timeItem.ProcessBookingWhenCrossBranch(models);
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return View("~/Views/Shared/MessageView.ascx", model: "預約未完成，請重新預約!!");
            }

            return Json(new { result = true, message = "上課時間預約完成!!" });
        }
    }
}