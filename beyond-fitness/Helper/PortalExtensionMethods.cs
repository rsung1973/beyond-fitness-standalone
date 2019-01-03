using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Mvc;

using CommonLib.DataAccess;
using MessagingToolkit.QRCode.Codec;
using Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static class PortalExtensionMethods
    {
        public static DateTime FirstDayOfMonth(this DateTime date)
        {
            return new DateTime(date.Year, date.Month, 1);
        }

        public static DateTime FirstDayOfWeek(this DateTime date)
        {
            int offsetDays = (int)date.DayOfWeek;
            offsetDays = offsetDays == 0 ? 6 : offsetDays - 1;
            return date.AddDays(-offsetDays);
        }


        public static String ProcessLogin(this Controller controller, UserProfile item,bool fromLine = false)
        {
            UrlHelper url = new UrlHelper(controller.ControllerContext.RequestContext);

            if(fromLine)
            {
                if (item.IsLearner())
                {
                    return url.Action("LearnerIndex", "CornerKick");
                }
            }

            if (item.IsAuthorizedSysAdmin())
            {
                return url.Action("Index", "CoachFacet", new { KeyID = item.UID.EncryptKey() });
            }
            else if (item.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Coach || r.RoleID == (int)Naming.RoleID.Manager || r.RoleID == (int)Naming.RoleID.ViceManager))
            {
                return url.Action("Index", "CoachFacet", new { KeyID = item.UID.EncryptKey() });
            }
            else if (item.IsAssistant())
            {
                return url.Action("Index", "CoachFacet", new { KeyID = item.UID.EncryptKey() });
            }
            else if (item.IsAccounting())
            {
                return url.Action("TrustIndex", "Accounting");
            }
            else if (item.IsServitor())
            {
                return url.Action("PaymentIndex", "Payment");
            }
            

            switch ((Naming.RoleID)item.UserRole[0].RoleID)
            {
                case Naming.RoleID.Administrator:
                    return url.Action("Index", "CoachFacet");

                case Naming.RoleID.Learner:
                    return url.Action("LearnerIndex", "CornerKick");
                    //return fromLine ? url.Action("LearnerIndex", "CornerKick") : url.Action("LearnerIndex", "LearnerFacet");

                case Naming.RoleID.Manager:
                case Naming.RoleID.ViceManager:
                case Naming.RoleID.Officer:
                case Naming.RoleID.Assistant:
                    return url.Action("Index", "CoachFacet", new { KeyID = item.UID.EncryptKey() });

                //case Naming.RoleID.Assistant:
                //    return url.Action("Index", "CoachFacet");

                case Naming.RoleID.Accounting:
                    return url.Action("TrustIndex", "Accounting");


                case Naming.RoleID.Servitor:
                    return url.Action("PaymentIndex", "Payment");

                case Naming.RoleID.FreeAgent:
                    return url.Action("FreeAgent", "Account");

            }

            return url.Action("Index", "Account"); ;
        }

        public static IQueryable<PDQQuestion> PromptDailyQuestion<TEntity>(this ModelSource<TEntity> models)
                    where TEntity : class, new()
        {
            return models.GetTable<PDQQuestion>()
                        .Where(q => q.GroupID == 6)
                        .Join(models.GetTable<PDQQuestionExtension>().Where(t => !t.Status.HasValue),
                            q => q.QuestionID, t => t.QuestionID, (q, t) => q);
        }


        public static PDQQuestion PromptLearnerDailyQuestion<TEntity>(this ModelSource<TEntity> models, UserProfile profile)
                    where TEntity : class, new()
        {

            if (models.GetTable<PDQTask>().Any(t => t.UID == profile.UID
                 && t.TaskDate >= DateTime.Today && t.TaskDate < DateTime.Today.AddDays(1)
                 && t.PDQQuestion.GroupID == 6))
            {
                return null;
            }

            if (models.GetTable<PDQTask>().Count(t => t.UID == profile.UID && t.PDQQuestion.GroupID == 6) >=
                models.GetTable<RegisterLesson>().Where(r => r.UID == profile.UID && r.LessonPriceType.Status != (int)Naming.LessonPriceStatus.在家訓練)
                    .Join(models.GetTable<GroupingLesson>(), r => r.RegisterGroupID, g => g.GroupID, (r, g) => g)
                    .Join(models.GetTable<LessonTime>(), g => g.GroupID, l => l.GroupID, (g, l) => l)
                    .Where(l => l.LessonPlan.CommitAttendance.HasValue || l.LessonAttendance != null).Count())
            {
                return null;
            }

            IQueryable<PDQQuestion> questItems = models.PromptDailyQuestion()
                .Join(models.GetTable<UserProfile>().Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked), 
                    q => q.AskerID, u => u.UID, (q, u) => q);
            int[] items = questItems
                .Select(q => q.QuestionID)
                .Where(q => !models.GetTable<PDQTask>().Where(t => t.UID == profile.UID).Select(t => t.QuestionID).Contains(q)).ToArray();

            if (items.Length == 0)
            {
                items = questItems
                .Select(q => q.QuestionID).ToArray();
            }

            profile.DailyQuestionID = items[DateTime.Now.Ticks % items.Length];

            var item = models.GetTable<PDQQuestion>().Where(q => q.QuestionID == profile.DailyQuestionID).FirstOrDefault();
            return item;
        }

        //public static IQueryable<CourseContract> PromptContract<TEntity>(this ModelSource<TEntity> models)
        //    where TEntity : class, new()
        //{
        //    var expansionID = models.GetTable<CourseContractRevision>().Where(r => r.Reason == "展延")
        //        .Select(r => r.OriginalContract);

        //    var closedID = models.GetTable<CourseContractRevision>().Where(r => r.Reason == "終止")
        //        .Select(r => r.OriginalContract);

        //    var terminationID = models.GetTable<CourseContractRevision>().Where(r => r.Reason == "終止")
        //        .Select(r => r.RevisionID);

        //    var items = models.GetTable<CourseContract>()
        //        .Where(c => c.Expiration >= DateTime.Today || c.RegisterLessonContract.Any())
        //        .Where(c => !c.RegisterLessonContract.Any(r => r.RegisterLesson.Attended == (int)Naming.LessonStatus.課程結束))
        //        .Where(c => !expansionID.Any(r => r == c.ContractID))
        //        .Where(c => !terminationID.Any(r => r == c.ContractID))
        //        .Where(c => !closedID.Any(r => r == c.ContractID));

        //    return items;
        //}


        public static LessonAttendanceCheckEvent CheckLessonAttendanceEvent<TEntity>(this UserProfile profile, ModelSource<TEntity> models, bool includeAfterToday = false)
            where TEntity : class, new()
        {
            var items = profile.LearnerGetUncheckedLessons(models);

            var count = items.Count();
            if (count > 0)
            {
                return new LessonAttendanceCheckEvent
                {
                    Profile = profile,
                    CheckCount = count
                };
            }
            return null;
        }

        public static DailyQuestionEvent CheckDailyQuestionEvent<TEntity>(this UserProfile profile, ModelSource<TEntity> models, bool includeAfterToday = false)
            where TEntity : class, new()
        {
            var question = models.PromptLearnerDailyQuestion(profile);

            if (question != null)
            {
                return new DailyQuestionEvent
                {
                    Profile = profile,
                    DailyQuestion = question
                };
            }

            return null;

        }

        public static UserGuideEvent CheckUserGuideEvent<TEntity>(this UserProfile profile, ModelSource<TEntity> models, bool includeAfterToday = false)
            where TEntity : class, new()
        {
            var items = models.GetTable<UserEvent>().Where(v => v.StartDate <= DateTime.Today && v.UID == profile.UID)
                    .Join(models.GetTable<SystemEventBulletin>(), v => v.SystemEventID, b => b.EventID, (v, b) => v);
            if (items.Count() > 0)
            {
                return new UserGuideEvent
                {
                    GuideEventList = items,
                    Profile = profile,
                };
            }

            return null;
        }

        public static ExpiringContractEvent CheckExpiringContractEvent<TEntity>(this UserProfile profile, ModelSource<TEntity> models, bool includeAfterToday = false)
            where TEntity : class, new()
        {
            var contract = models.PromptExpiringContract().Where(c => c.CourseContractMember.Any(m => m.UID == profile.UID)).FirstOrDefault();
            if (contract != null)
            {
                return new ExpiringContractEvent
                {
                    Profile = profile,
                    ExpiringContract = contract
                };
            }

            return null;

        }

        public static PromptContractEvent CheckPromptContractEvent<TEntity>(this UserProfile profile, ModelSource<TEntity> models, bool includeAfterToday = false)
            where TEntity : class, new()
        {
            var items = models.PromptEffectiveContract()
                .Where(c => c.Expiration >= DateTime.Today)
                .Where(c => c.CourseContractMember.Any(m => m.UID == profile.UID));
            if (items.Count()>0)
            {
                return new PromptContractEvent
                {
                    Profile = profile,
                    ContractList = items
                };
            }

            return null;

        }

        public static PersonalExercisePurposeEvent CheckExercisePurposeEvent<TEntity>(this UserProfile profile, ModelSource<TEntity> models, bool includeAfterToday = false)
            where TEntity : class, new()
        {
            var items = models.GetTable<PersonalExercisePurposeItem>().Where(v => v.UID == profile.UID && !v.NoticeStatus.HasValue);
            if (items.Count() > 0)
            {
                return new PersonalExercisePurposeEvent
                {
                    PurposeItemEventList = items,
                    Profile = profile,
                };
            }

            return null;
        }

        public static PersonalExercisePurposeAccomplishedEvent CheckAccomplishedExercisePurposeEvent<TEntity>(this UserProfile profile, ModelSource<TEntity> models, bool includeAfterToday = false)
            where TEntity : class, new()
        {
            var items = models.GetTable<PersonalExercisePurposeItem>()
                .Where(v => v.UID == profile.UID
                    && v.CompleteDate >= DateTime.Today.AddDays(-30));
            if (items.Count() > 0)
            {
                return new PersonalExercisePurposeAccomplishedEvent
                {
                    PurposeItemEventList = items,
                    Profile = profile,
                };
            }

            return null;
        }



        public static UserProfile ValiateLogin<TEntity>(this LoginViewModel viewModel, ModelSource<TEntity> models, ModelStateDictionary modelState)
            where TEntity : class, new()
        {
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.PID == viewModel.PID
                      && u.LevelID == (int)Naming.MemberStatusDefinition.Checked).FirstOrDefault();

            if (item == null)
            {
                modelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                return null;
            }

            if (item.Password != (viewModel.Password).MakePassword())
            {
                modelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                return null;
            }

            return item;

        }
    }
    
}