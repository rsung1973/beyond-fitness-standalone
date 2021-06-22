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
using Newtonsoft.Json;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [Authorize]
    public class LearnerFacetController : SampleController<UserProfile>
    {

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Learner, (int)Naming.RoleID.Assistant })]
        public ActionResult LearnerIndex(DateTime? lessonDate, DateTime? endQueryDate)
        {
            UserProfile item = HttpContext.GetUser();
            if (item == null)
            {
                return Redirect(FormsAuthentication.LoginUrl);
            }

            var model = models.GetTable<UserProfile>().Where(u => u.UID == item.UID).First();

            if (!lessonDate.HasValue)
                lessonDate = DateTime.Today.AddYears(-1);
            if (!endQueryDate.HasValue)
                endQueryDate = lessonDate.Value.AddYears(1);

            ViewBag.LessonDate = lessonDate;
            ViewBag.EndQueryDate = endQueryDate;

            return View("~/Views/LearnerFacet/Index.aspx", model);
        }

        public ActionResult CheckBonus(int id)
        {
            var model = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();
            if (model != null)
            {
                return View("~/Views/LearnerFacet/Module/CheckBonus.ascx", model);
            }
            return View("~/Views/Shared/JsAlert.cshtml", model: "學員資料錯誤!!");
        }

        public ActionResult CheckBonusAward(int id)
        {
            var model = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();
            if (model != null)
            {
                return View("~/Views/LearnerFacet/Module/CheckBonusAward.ascx", model);
            }
            return View("~/Views/Shared/JsAlert.cshtml", model: "學員資料錯誤!!");
        }

        public ActionResult ExchangeBonusPoint(int uid,int itemID,int? recipientID)
        {
            var profile = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (profile == null)
            {
                return Json(new { result = false, message = "學員資料錯誤!!" }, JsonRequestBehavior.AllowGet);
            }

            var item = models.GetTable<BonusAwardingItem>().Where(i => i.ItemID == itemID).FirstOrDefault();
            if(item==null)
            {
                return Json(new { result = false, message = "兌換商品錯誤!!" }, JsonRequestBehavior.AllowGet);
            }

            if (profile.BonusPoint(models) < item.PointValue)
            {
                return Json(new { result = false, message = "累積點數不足!!" }, JsonRequestBehavior.AllowGet);
            }

            var award = new LearnerAward
            {
                UID = profile.UID,
                AwardDate = DateTime.Now,
                ItemID = item.ItemID,
                ActorID = HttpContext.GetUser().UID
            };
            models.GetTable<LearnerAward>().InsertOnSubmit(award);

            int usedPoints = item.PointValue;
            foreach(var bounsItem in profile.BonusPointList(models))
            {
                if (usedPoints <= 0)
                    break;
                award.BonusExchange.Add(new BonusExchange
                {
                    TaskID = bounsItem.TaskID
                });
                usedPoints -= bounsItem.PDQTask.PDQQuestion.PDQQuestionExtension.BonusPoint.Value;
            }

            ///兌換課程
            ///
            if (item.BonusAwardingLesson != null)
            {
                var lesson = models.GetTable<RegisterLesson>().Where(r => r.UID == uid).OrderByDescending(r => r.RegisterID).First();

                if (item.BonusAwardingIndication != null && item.BonusAwardingIndication.Indication == "AwardingLessonGift")
                {
                    if(!recipientID.HasValue)
                    {
                        return Json(new { result = false, message = "請選擇受贈學員!!" }, JsonRequestBehavior.AllowGet);
                    }

                    var giftLesson = new RegisterLesson
                        {
                            RegisterDate = DateTime.Now,
                            GroupingMemberCount = 1,
                            ClassLevel = item.BonusAwardingLesson.PriceID,
                            Lessons = 1,
                            UID = recipientID.Value,
                            AdvisorID = lesson.AdvisorID,
                            Attended = (int)Naming.LessonStatus.準備上課,
                            GroupingLesson = new GroupingLesson { }
                        };
                    award.AwardingLessonGift = new AwardingLessonGift
                        {
                            RegisterLesson = giftLesson
                        };
                    models.GetTable<RegisterLesson>().InsertOnSubmit(giftLesson);
                }
                else
                {
                    var awardLesson = new RegisterLesson
                    {
                        RegisterDate = DateTime.Now,
                        GroupingMemberCount = 1,
                        ClassLevel = item.BonusAwardingLesson.PriceID,
                        Lessons = 1,
                        UID = profile.UID,
                        AdvisorID = lesson.AdvisorID,
                        Attended = (int)Naming.LessonStatus.準備上課,
                        GroupingLesson = new GroupingLesson { }
                    };
                    award.AwardingLesson = new AwardingLesson
                    {
                        RegisterLesson = awardLesson
                    };
                    models.GetTable<RegisterLesson>().InsertOnSubmit(awardLesson);
                }
            }

            models.SubmitChanges();
            return Json(new { result = true }, JsonRequestBehavior.AllowGet);

        }

        public ActionResult CheckLessonAttendance(int id)
        {
            var model = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();
            if (model != null)
            {
                return View("~/Views/LearnerFacet/Module/CheckLessonAttendance.ascx", model);
            }
            return View("~/Views/Shared/JsAlert.cshtml", model: "學員資料錯誤!!");
        }

        public ActionResult PushComment(int speakerID, String comment)
        {
            int? hearerID = models.GetTable<LessonComment>().Where(c => c.HearerID == speakerID)
                .OrderByDescending(c => c.CommentDate)
                .Select(c => (int?)c.SpeakerID).FirstOrDefault();

            if (!hearerID.HasValue)
            {
                hearerID = models.GetTable<RegisterLesson>().Where(r => r.UID == speakerID)
                    .OrderByDescending(r => r.RegisterID)
                    .Select(r => r.AdvisorID).FirstOrDefault();
            }

            if (hearerID.HasValue)
            {
                LessonComment item = new LessonComment
                {
                    Comment = comment,
                    HearerID = hearerID.Value,
                    SpeakerID = speakerID,
                    CommentDate = DateTime.Now,
                    Status = (int)Naming.IncommingMessageStatus.未讀
                };

                models.GetTable<LessonComment>().InsertOnSubmit(item);
                models.SubmitChanges();

                return View("~/Views/LearnerFacet/Module/LessonCommentItem.ascx", item);
            }

            return new EmptyResult();

        }

        public ActionResult PersonalStrengthAssessment(int uid, int[] itemID)
        {
            var items = getAssessmentReportItem(uid, itemID);
            if (items.Count() == 0)
                return View("~/Views/LearnerFacet/Module/EmptyAssessment.ascx");
            else
                return View("~/Views/LearnerFacet/Module/PersonalStrengthAssessment.ascx", items);

        }

        public ActionResult MuscleStrengthAssessment(int uid, int[] itemID)
        {
            var items = getAssessmentReportItem(uid, itemID);
            if (items.Count() == 0)
                return View("~/Views/LearnerFacet/Module/EmptyAssessment.ascx");
            else
                return View("~/Views/LearnerFacet/Module/MuscleStrengthAssessment.ascx", items);

        }

        private IQueryable<LessonFitnessAssessment> getAssessmentReportItem(int uid, int[] itemID)
        {
            DataLoadOptions ops = new DataLoadOptions();
            ops.LoadWith<LessonFitnessAssessment>(f => f.LessonFitnessAssessmentReport);
            ops.LoadWith<LessonFitnessAssessmentReport>(f => f.FitnessAssessmentItem);
            models.GetDataContext().LoadOptions = ops;

            var items = models.GetTable<LessonFitnessAssessment>().Where(u => u.UID == uid)
                .Where(u => u.LessonFitnessAssessmentReport.Count(r => itemID.Contains(r.ItemID) && (r.TotalAssessment.HasValue || r.SingleAssessment.HasValue)) > 0);

            return items;

        }

        public ActionResult DrawFitnessAssessment(int uid)
        {
            return View("~/Views/LearnerFacet/Module/DrawFitnessAssessment.ascx", uid);
        }

        public ActionResult HealthIndex(int id)
        {
            var model = models.GetTable<UserProfile>().Where(f => f.UID == id).FirstOrDefault();
            if (model == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "學員資料錯誤!!");
            }
            return View("~/Views/LearnerFacet/Module/HealthIndex.ascx", model);
        }

        public ActionResult LearnerLesson(int lessonID, bool? attendance)
        {
            var item = models.GetTable<LessonTime>().Where(t => t.LessonID == lessonID).FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "學員未建立上課資料!!");
            }

            ViewBag.LearnerAttendance = attendance;
            ViewBag.Profile = item.RegisterLesson.UserProfile;
            return View("~/Views/LearnerFacet/Module/LearnerLesson.ascx", item);
        }

        public ActionResult CreateUserEvent(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (profile == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "學員資料錯誤!!");
            }

            var item = models.GetTable<UserEvent>().Where(u => u.EventID == viewModel.EventID).FirstOrDefault();
            if (item != null)
            {
                viewModel.StartDate = item.StartDate;
                viewModel.EndDate = item.EndDate;
                viewModel.Title = item.Title;
            }

            return View("~/Views/LearnerFacet/Module/CreateUserEvent.ascx");
        }

        public ActionResult CommitUserEvent(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (profile == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "學員資料錯誤!!");
            }

            if (!viewModel.StartDate.HasValue)
            {
                ModelState.AddModelError("StartDate", "請選擇開始時間!!");
            }
            if (!viewModel.EndDate.HasValue)
            {
                ModelState.AddModelError("EndDate", "請選擇結束時間!!");
            }
            if (String.IsNullOrEmpty(viewModel.Title))
            {
                ModelState.AddModelError("Title", "請輸入行事曆內容!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            var item = models.GetTable<UserEvent>().Where(u => u.EventID == viewModel.EventID).FirstOrDefault();
            if (item == null)
            {
                item = new UserEvent
                {
                    UID = profile.UID
                };
                models.GetTable<UserEvent>().InsertOnSubmit(item);
            }

            item.StartDate = viewModel.StartDate.Value;
            item.EndDate = viewModel.EndDate.Value;
            item.Title = viewModel.Title;

            models.SubmitChanges();

            return View("~/Views/LearnerFacet/Module/CompleteUserEvent.ascx", item);
        }

        public ActionResult CancelEvent(int id)
        {
            var item = models.DeleteAny<UserEvent>(v => v.EventID == id);
            if(item!=null)
            {
                return Json(new { result = true },JsonRequestBehavior.AllowGet);
            }
            return Json(new { result = false, message = "資料錯誤!!" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult QueryRecipient()
        {
            return View("~/Views/LearnerFacet/Module/QueryRecipient.ascx");
        }


    }
}