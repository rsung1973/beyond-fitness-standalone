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
using Microsoft.AspNetCore.Mvc; //System.Web.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;

using CommonLib.DataAccess;  //  CommonLib.DataAccess;
//
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using System.Text.RegularExpressions;
using LineMessagingAPISDK.Models;
////

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
            if(fromLine)
            {
                if (item.IsLearner())
                {
                    return controller.Url.Action("Index", "LearnerActivity");
                }
            }

            if (item.IsAuthorizedSysAdmin())
            {
                //return url.Action("Index", "CoachFacet", new { KeyID = item.UID.EncryptKey() });
                return VirtualPathUtility.ToAbsolute("~/ConsoleHome/Index");
            }
            else if (item.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Coach || r.RoleID == (int)Naming.RoleID.Manager || r.RoleID == (int)Naming.RoleID.ViceManager))
            {
                //return url.Action("Index", "CoachFacet", new { KeyID = item.UID.EncryptKey() });
                return VirtualPathUtility.ToAbsolute("~/ConsoleHome/Index");
            }
            else if (item.IsAssistant())
            {
                //return url.Action("Index", "CoachFacet", new { KeyID = item.UID.EncryptKey() });
                return VirtualPathUtility.ToAbsolute("~/ConsoleHome/Index");
            }
            else if (item.IsAccounting())
            {
                //return url.Action("TrustIndex", "Accounting");
                return VirtualPathUtility.ToAbsolute("~/ConsoleHome/Index");
            }
            else if (item.IsServitor())
            {
                return VirtualPathUtility.ToAbsolute("~/ConsoleHome/Index");
                //return url.Action("PaymentIndex", "Payment");
            }
            

            switch ((Naming.RoleID)item.UserRole.FirstOrDefault()?.RoleID)
            {
                case Naming.RoleID.Administrator:
                    return controller.Url.Action("Index", "CoachFacet");

                case Naming.RoleID.Learner:
                    return controller.Url.Action("Index", "LearnerActivity");
                    //return fromLine ? controller.Url.Action("LearnerIndex", "CornerKick") : controller.Url.Action("LearnerIndex", "LearnerFacet");

                case Naming.RoleID.Manager:
                case Naming.RoleID.ViceManager:
                case Naming.RoleID.Assistant:
                    return controller.Url.Action("Index", "CoachFacet", new { KeyID = item.UID.EncryptKey() });

                case Naming.RoleID.Officer:
                    if (item.UserRole.Count == 1 && item.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Officer))
                    {
                        return VirtualPathUtility.ToAbsolute("~/ConsoleHome/Index");
                    }
                    else
                    {
                        return controller.Url.Action("Index", "CoachFacet", new { KeyID = item.UID.EncryptKey() });
                    }

                //case Naming.RoleID.Assistant:
                //    return controller.Url.Action("Index", "CoachFacet");

                case Naming.RoleID.Accounting:
                    return controller.Url.Action("TrustIndex", "Accounting");


                case Naming.RoleID.Servitor:
                    return controller.Url.Action("PaymentIndex", "Payment");

                case Naming.RoleID.FreeAgent:
                    return controller.Url.Action("FreeAgent", "Account");

            }

            return controller.Url.Action("Index", "Account"); ;
        }

        public static IQueryable<PDQQuestion> PromptDailyQuestion(this GenericManager<BFDataContext> models)
                    
        {
            return models.GetTable<PDQQuestion>()
                        .Where(q => q.GroupID == 6)
                        .Join(models.GetTable<PDQQuestionExtension>().Where(t => !t.Status.HasValue),
                            q => q.QuestionID, t => t.QuestionID, (q, t) => q);
        }

        public static PDQQuestion PromptLearnerDailyQuestion(this GenericManager<BFDataContext> models, UserProfile profile)
        {
            if (models.GetTable<PDQTask>().Any(t => t.UID == profile.UID
                 && t.TaskDate >= DateTime.Today && t.TaskDate < DateTime.Today.AddDays(1)
                 && t.PDQQuestion.GroupID == 6))
            {
                return null;
            }

            var promptItems = models.GetTable<PromptLessonQuestion>()
                .Where(p => !p.TaskID.HasValue)
                .Where(t => t.UID == profile.UID);

            if (!promptItems.Any())
            {
                return null;
            }

            bool hasPrompt = false;
            foreach (var promptItem in promptItems)
            {
                if (!models.GetTable<PromptLessonRequirement>().Any(p => p.PriceID == promptItem.LessonTime.RegisterLesson.ClassLevel))
                {
                    hasPrompt = true;
                    break;
                }
            }

            if (!hasPrompt)
            {
                var groupItems = promptItems.GroupBy(l => l.LessonTime.RegisterLesson.LessonPriceType.PromptLessonRequirement);
                foreach (var g in groupItems)
                {
                    if (g.Count() >= g.Key.RequiredCount)
                    {
                        hasPrompt = true;
                        break;
                    }
                }
                if (!hasPrompt)
                {
                    return null;
                }
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

        //public static PDQQuestion PromptLearnerDailyQuestion(this GenericManager<BFDataContext> models, UserProfile profile)

        //{

        //    if (models.GetTable<PDQTask>().Any(t => t.UID == profile.UID
        //         && t.TaskDate >= DateTime.Today && t.TaskDate < DateTime.Today.AddDays(1)
        //         && t.PDQQuestion.GroupID == 6))
        //    {
        //        return null;
        //    }

        //    if (models.GetTable<PDQTask>().Count(t => t.UID == profile.UID && t.PDQQuestion.GroupID == 6) >=
        //        models.GetTable<RegisterLesson>()
        //            .Where(r => r.UID == profile.UID)
        //            .Where(r => r.LessonPriceType.Status != (int)Naming.LessonPriceStatus.在家訓練)
        //            .Where(r => r.LessonPriceType.Status != (int)Naming.LessonPriceStatus.教練PI)
        //            .Where(r => r.LessonPriceType.Status != (int)Naming.LessonPriceStatus.點數兌換課程)
        //            .Join(models.GetTable<GroupingLesson>(), r => r.RegisterGroupID, g => g.GroupID, (r, g) => g)
        //            .Join(models.GetTable<LessonTime>(), g => g.GroupID, l => l.GroupID, (g, l) => l)
        //            .Where(l => l.LessonPlan.CommitAttendance.HasValue || l.LessonAttendance != null).Count())
        //    {
        //        return null;
        //    }

        //    IQueryable<PDQQuestion> questItems = models.PromptDailyQuestion()
        //        .Join(models.GetTable<UserProfile>().Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked), 
        //            q => q.AskerID, u => u.UID, (q, u) => q);
        //    int[] items = questItems
        //        .Select(q => q.QuestionID)
        //        .Where(q => !models.GetTable<PDQTask>().Where(t => t.UID == profile.UID).Select(t => t.QuestionID).Contains(q)).ToArray();

        //    if (items.Length == 0)
        //    {
        //        items = questItems
        //        .Select(q => q.QuestionID).ToArray();
        //    }

        //    profile.DailyQuestionID = items[DateTime.Now.Ticks % items.Length];

        //    var item = models.GetTable<PDQQuestion>().Where(q => q.QuestionID == profile.DailyQuestionID).FirstOrDefault();
        //    return item;
        //}

        //public static IQueryable<CourseContract> PromptContract(this GenericManager<BFDataContext> models)
        //    
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


        public static LessonAttendanceCheckEvent CheckLessonAttendanceEvent(this UserProfile profile, GenericManager<BFDataContext> models, bool includeAfterToday = false)
            
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

        public static DailyQuestionEvent CheckDailyQuestionEvent(this UserProfile profile, GenericManager<BFDataContext> models, bool includeAfterToday = false)
            
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

        public static UserGuideEvent CheckUserGuideEvent(this UserProfile profile, GenericManager<BFDataContext> models, bool includeAfterToday = false)
            
        {
            var items = models.GetTable<UserEvent>().Where(v => v.StartDate <= DateTime.Today && v.UID == profile.UID)
                    .Join(models.GetTable<SystemEventBulletin>()
                                .Where(s => s.EventID == (int)SystemEventBulletin.BulletinEventType.新手上路導覽推播
                                        || s.EventID == (int)SystemEventBulletin.BulletinEventType.新手上路), v => v.SystemEventID, b => b.EventID, (v, b) => v);
            if (items.Any())
            {
                return new UserGuideEvent
                {
                    GuideEventList = items,
                    Profile = profile,
                };
            }

            return null;
        }

        public static SimpleAnnouncementEvent CheckCurrentAnnouncementEvent(this UserProfile profile, GenericManager<BFDataContext> models, bool includeAfterToday = false)
        {
            IQueryable<UserEvent> items = PromptEffectiveSystemEvent(profile, models);

            var item = items.FirstOrDefault();
            if (item != null)
            {
                return new SimpleAnnouncementEvent
                {
                    Announcement = item,
                    Profile = profile,
                };
            }

            return null;
        }

        public static IQueryable<UserEvent> PromptEffectiveSystemEvent(this UserProfile profile, GenericManager<BFDataContext> models)
        {
            var items = models.GetTable<UserEvent>()
                    .Where(v => v.UID == profile.UID)
                    .Where(v => !models.GetTable<UserEventCommitment>().Any(c => c.EventID == v.EventID))
                    .Join(models.GetTable<SystemEventBulletin>()
                                    .Where(s => s.StartDate <= DateTime.Today)
                                    .Where(s => s.EndDate > DateTime.Today)
                                /*.Where(s => s.EventID == (int)SystemEventBulletin.BulletinEventType.系統公告)*/, v => v.SystemEventID, b => b.EventID, (v, b) => v);
            return items;
        }

        public static SystemBulletinEvent PromptEffectiveSystemBulletin(this UserProfile profile, GenericManager<BFDataContext> models)
        {

            var committedItems = models.GetTable<UserEvent>()
                    .Where(v => v.UID == profile.UID)
                    .Where(v => v.UserEventCommitment != null);

            var items = models.GetTable<SystemEventBulletin>()
                                    .Where(s => s.StartDate <= DateTime.Today)
                                    .Where(s => s.EndDate > DateTime.Today)
                                    .Where(s => !committedItems.Any(v => v.SystemEventID == s.EventID));
            if (items.Any())
            {
                return new SystemBulletinEvent
                {
                    BulletinEventList = items,
                    Profile = profile,
                };
            }

            return null;
        }

        public static SelfAssessmentEvent PromptSelfAssessment(this UserProfile profile, GenericManager<BFDataContext> models, StageProgress current)
        {

            //var lessons = models.GetTable<RegisterLesson>()
            //        .Where(r=> BusinessConsoleExtensions.SessionScopeForSelfAssessment.Contains(r.LessonPriceType.Status))
            //        .Where(r => r.UID == profile.UID);

            //IQueryable<LessonTime> lessonItems = models.GetTable<LessonTime>();

            //if (current != null)
            //{
            //    lessonItems = lessonItems.Where(l => l.ClassTime >= current.StartDate)
            //                    .Where(l => l.ClassTime < current.EndExclusiveDate);
            //}

            //lessonItems = models.PromptLearnerLessons(lessons, lessonItems);

            //var feedbackItems = models.GetTable<LessonFeedBack>()
            //    .Where(f => f.CommitAssessment.HasValue)
            //    .Join(lessons, f => f.RegisterID, r => r.RegisterID, (f, r) => f);

            //var items = lessonItems.Where(l => !feedbackItems.Any(f => f.LessonID == l.LessonID));
            if (current != null)
            {
                var items = models.GetTable<LessonTime>()
                        .Where(f => f.RegisterLesson.LessonPriceType.LessonMissionBonusAwardingItem.Any(b => b.MissionID == (int)CampaignMission.CampaignMissionType.SelfAssessment))
                        .Where(l => l.ClassTime >= current.StartDate)
                        .Where(l => l.ClassTime < current.EndExclusiveDate)
                        .Where(l => l.GroupingLesson.RegisterLesson.Any(r => r.UID == profile.UID))
                        .Where(l => !l.LessonFeedBack
                                        .Where(f => f.RegisterLesson.UID == profile.UID)
                                        .Where(f => f.CommitAssessment.HasValue)
                                        .Any())
                        .Where(l => DateTime.Now.AddHours(2.5) >= l.ClassTime);

                if (items.Any())
                {
                    return new SelfAssessmentEvent
                    {
                        LessonList = items,
                        Profile = profile,
                    };
                }
            }

            return null;
        }

        public static FeedbackSurveyEvent PromptFeedbackSurvey(this UserProfile profile, GenericManager<BFDataContext> models, StageProgress current)
        {

            //var lessons = models.GetTable<RegisterLesson>().Where(r => r.UID == profile.UID);
            //IQueryable<LessonTime> lessonItems =
            //    models.GetTable<LessonTime>()
            //        .Where(l => l.LessonAttendance != null);

            //if (current != null)
            //{
            //    lessonItems = lessonItems.Where(l => l.ClassTime >= current.StartDate)
            //                    .Where(l => l.ClassTime < current.EndExclusiveDate);
            //}

            //lessonItems = models.PromptLearnerLessons(lessons, lessonItems);

            //var serveyItems = models.GetTable<LessonFeedBack>()
            //    .Where(f => f.FeedBackDate.HasValue)
            //    .Join(lessons, f => f.RegisterID, r => r.RegisterID, (f, r) => f);

            //var items = lessonItems.Where(l => !serveyItems.Any(f => f.LessonID == l.LessonID));
            if (current != null)
            {
                var items = models.GetTable<LessonTime>()
                            .Where(f => f.RegisterLesson.LessonPriceType.LessonMissionBonusAwardingItem.Any(b => b.MissionID == (int)CampaignMission.CampaignMissionType.FeedbackSurvey))
                            .Where(l => l.ClassTime >= current.StartDate)
                            .Where(l => l.ClassTime < current.EndExclusiveDate)
                            .Where(l => l.LessonAttendance != null)
                            .Where(l => l.GroupingLesson.RegisterLesson.Any(r => r.UID == profile.UID))
                            .Where(l => !l.LessonFeedBack
                                            .Where(f => f.RegisterLesson.UID == profile.UID)
                                            .Where(f => f.FeedBackDate.HasValue)
                                            .Any());

                if (items.Any())
                {
                    return new FeedbackSurveyEvent
                    {
                        LessonList = items,
                        Profile = profile,
                    };
                }
            }

            return null;
        }

        public static ExpiringContractEvent CheckExpiringContractEvent(this UserProfile profile, GenericManager<BFDataContext> models, bool includeAfterToday = false)
            
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

        public static PromptContractEvent CheckPromptContractEvent(this UserProfile profile, GenericManager<BFDataContext> models, bool includeAfterToday = false)
            
        {
            var items = models.PromptExpiringContract()
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

        public static PromptSignContractEvent CheckSignContractEvent(this UserProfile profile, GenericManager<BFDataContext> models, bool includeAfterToday = false)
            
        {
            //var items = models.PromptContractToSign(true)
            //    .Where(c => c.CourseContractExtension.SignOnline == true)
            //    .Where(c => c.OwnerID == profile.UID
            //        || (c.CourseContractType.IsGroup == true
            //            && c.CourseContractMember.Any(m => m.UID == profile.UID)));

            var items = models.PromptContractToSign(true)
                .Where(c => c.CourseContractExtension.SignOnline == true)
                .Where(c => c.OwnerID == profile.UID);

            if (items.Count() > 0)
            {
                return new PromptSignContractEvent
                {
                    Profile = profile,
                    ContractList = items
                };
            }

            return null;

        }

        public static PromptSignContractServiceEvent CheckSignContractServiceEvent(this UserProfile profile, GenericManager<BFDataContext> models)
            
        {
            var items = models.PromptContractServiceToSign()
                .Where(c => c.CourseContractExtension.SignOnline == true)
                .Where(c => c.CourseContractMember.Any(m => m.UID == profile.UID));


            if (items.Count() > 0)
            {
                return new PromptSignContractServiceEvent
                {
                    Profile = profile,
                    ContractList = items
                };
            }

            return null;

        }


        public static PromptPayoffDueEvent CheckPayoffDueEvent(this UserProfile profile, GenericManager<BFDataContext> models, bool includeAfterToday = false)
            
        {
            var items = models.PromptEffectiveContract()
                .Where(c => c.PayoffDue < DateTime.Today.AddMonths(1))
                .Where(c => c.CourseContractMember.Any(m => m.UID == profile.UID));

            if (items.Count() > 0)
            {
                var unpaid = items.ToList()
                        .Where(c => c.TotalCost > c.TotalPaidAmount());
                if (unpaid.Count() > 0)
                {
                    return new PromptPayoffDueEvent
                    {
                        Profile = profile,
                        ContractList = unpaid
                    };
                }
            }

            return null;

        }

        public static PersonalExercisePurposeEvent CheckExercisePurposeEvent(this UserProfile profile, GenericManager<BFDataContext> models, bool includeAfterToday = false)
            
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

        public static PersonalExercisePurposeAccomplishedEvent CheckAccomplishedExercisePurposeEvent(this UserProfile profile, GenericManager<BFDataContext> models, bool includeAfterToday = false)
            
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



        public static UserProfile ValiateLogin(this LoginViewModel viewModel, GenericManager<BFDataContext> models, ModelStateDictionary modelState)
        {
            if (viewModel.PID == null || viewModel.PID.Length > 48)
            {
                modelState.AddModelError("PID", "Email長度超過[E0002]，請重新確認！");
                return null;
            }
            else if (!Regex.IsMatch(viewModel.PID, "\\w+([-+.']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"))
            {
                modelState.AddModelError("PID", "Email格式錯誤[E0001]，請重新確認！");
                return null;
            }

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.PID == viewModel.PID
                      /*&& u.LevelID == (int)Naming.MemberStatusDefinition.Checked*/).FirstOrDefault();

            if (item == null)
            {
                modelState.AddModelError("PID", "輸入資料錯誤[XA001]，請重新確認！");
                return null;
            }

            if (item.Password != (viewModel.Password).MakePassword())
            {
                modelState.AddModelError("PID", "輸入資料錯誤[XA002]，請重新確認！");
                return null;
            }

            if (item.LevelID == (int)Naming.MemberStatusDefinition.Deleted)
            {
                modelState.AddModelError("PID", "帳號已停用[XA003]，請聯繫您的專屬顧問！");
                return null;
            }

            if (item.LevelID == (int)Naming.MemberStatusDefinition.Anonymous)
            {
                modelState.AddModelError("PID", "帳號已停用[XA004]，請聯繫您的專屬顧問！");
                return null;
            }

            return item;

        }

        public static int RemainedLearnerDailyQuestionCount(this GenericManager<BFDataContext> models, UserProfile profile)
        {
            int count = 0;
            var promptItems = models.GetTable<PromptLessonQuestion>()
                .Where(p => !p.TaskID.HasValue)
                .Where(t => t.UID == profile.UID);

            var groupItems = promptItems.GroupBy(l => l.LessonTime.RegisterLesson.ClassLevel);
            foreach (var g in groupItems)
            {
                var require = models.GetTable<LessonPriceType>().Where(p => p.PriceID == g.Key)
                                    .First().PromptLessonRequirement;
                if (require?.RequiredCount > 0)
                {
                    count += (g.Count() / require.RequiredCount.Value);
                }
                else
                {
                    count += g.Count();
                }
            }
            return count;
        }

    }

}