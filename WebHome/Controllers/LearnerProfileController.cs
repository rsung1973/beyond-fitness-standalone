using System;
using System.Collections.Generic;
using System.Data;

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

using CommonLib.DataAccess;

using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;
using System.Data.Linq;

namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class LearnerProfileController : SampleController<UserProfile>
    {
        public LearnerProfileController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: LearnerProfile
        public ActionResult ProfileIndex()
        {
            return View();
        }

        public async Task<ActionResult> LearnerCalendarAsync(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/LearnerProfile/Module/LearnerCalendar.cshtml", profile.LoadInstance(models));
        }

        public async Task<ActionResult> LearnerCalendar2020Async(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/LearnerProfile/Module/LearnerCalendar2020.cshtml", profile.LoadInstance(models));
        }

        public ActionResult LearnerCalendarEvents(FullCalendarViewModel viewModel, bool? toHtml = false)
        {
            ViewBag.ViewModel = viewModel;

            DataLoadOptions ops = new DataLoadOptions();
            ops.LoadWith<LessonTime>(i => i.GroupingLesson);
            ops.LoadWith<LessonTime>(i => i.RegisterLesson);
            ops.LoadWith<GroupingLesson>(i => i.RegisterLesson);
            ops.LoadWith<RegisterLesson>(i => i.UserProfile);
            ops.LoadWith<RegisterLesson>(i => i.LessonPriceType);
            models.DataContext.LoadOptions = ops;

            IQueryable<LessonTime> dataItems = viewModel.LearnerID.Value.PromptLearnerLessons(models);
            IQueryable<LessonTime> coachPI = viewModel.LearnerID.Value.PromptCoachPILessons(models);
            IQueryable<UserEvent> eventItems = models.GetTable<UserEvent>()
                .Where(e => !e.SystemEventID.HasValue)
                .Where(e => e.UID == viewModel.LearnerID
                    || e.GroupEvent.Any(g => g.UID == viewModel.LearnerID));
            IQueryable<LessonTime> givingItems = models.GetTable<LessonTime>().Where(l => l.AttendingCoach == viewModel.LearnerID);
            if (viewModel.DateFrom.HasValue && viewModel.DateTo.HasValue)
            {
                dataItems = dataItems.Where(t => t.ClassTime >= viewModel.DateFrom.Value
                    && t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                coachPI = coachPI.Where(t => t.ClassTime >= viewModel.DateFrom.Value
                    && t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                eventItems = eventItems.Where(t =>
                    (t.StartDate >= viewModel.DateFrom.Value && t.StartDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.StartDate >= viewModel.DateFrom.Value && t.StartDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.EndDate >= viewModel.DateFrom.Value && t.EndDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.StartDate < viewModel.DateFrom.Value && t.EndDate >= viewModel.DateTo.Value));
                givingItems = givingItems.Where(t => t.ClassTime >= viewModel.DateFrom.Value
                    && t.ClassTime < viewModel.DateTo.Value.AddDays(1));

            }
            else if (viewModel.DateFrom.HasValue)
            {
                dataItems = dataItems.Where(t => t.ClassTime >= viewModel.DateFrom.Value);
                coachPI = coachPI.Where(t => t.ClassTime >= viewModel.DateFrom.Value);
                eventItems = eventItems.Where(t => t.StartDate >= viewModel.DateFrom.Value);
                givingItems = givingItems.Where(t => t.ClassTime >= viewModel.DateFrom.Value);
            }
            else if (viewModel.DateTo.HasValue)
            {
                dataItems = dataItems.Where(t => t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                coachPI = coachPI.Where(t => t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                eventItems = eventItems.Where(t => t.EndDate < viewModel.DateTo.Value.AddDays(1));
                givingItems = givingItems.Where(t => t.ClassTime < viewModel.DateTo.Value.AddDays(1));
            }

            var items = dataItems
                .ToList()
                .Select(d => new CalendarEventItem
                {
                    EventTime = d.ClassTime,
                    EventItem = d
                }).ToList();

            items.AddRange(coachPI.Select(v => new CalendarEventItem
            {
                EventTime = v.ClassTime,
                EventItem = v
            }));

            items.AddRange(eventItems.Select(v => new CalendarEventItem
            {
                EventTime = v.StartDate,
                EventItem = v
            }));

            items.AddRange(givingItems.Select(v => new CalendarEventItem
            {
                EventTime = v.ClassTime,
                EventItem = v
            }));

            if (toHtml == true)
            {

            }
            else
            {
                Response.ContentType = "application/json";
            }
            return View("~/Views/LearnerProfile/Module/LearnerCalendarEvents.cshtml", items);

        }

        public ActionResult LearnerLessonsReviewDetails(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.LearnerID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.LearnerID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            return View("~/Views/LearnerProfile/Module/LearnerLessonsReviewDetails.cshtml", item);
        }

        public ActionResult LoadCompleteExercisePurposeItems(ExercisePurposeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var items = models.GetTable<PersonalExercisePurposeItem>()
                .Where(p => p.UID == viewModel.UID)
                .Where(p => p.CompleteDate.HasValue)
                .OrderByDescending(p => p.CompleteDate);

            return View("~/Views/LearnerProfile/Module/TrainingMilestoneItems.cshtml", items);
        }

        public ActionResult EditTrainingItem(TrainingItemViewModel viewModel)
        {
            if (!models.GetTable<TrainingExecution>().Any(t => t.ExecutionID == viewModel.ExecutionID))
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            var stage = models.GetTable<TrainingStage>().Where(s => s.StageID == viewModel.StageID).FirstOrDefault();
            if (stage == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }
            ViewBag.TrainingStage = stage;

            TrainingItem item = models.GetTable<TrainingItem>().Where(x => x.ItemID == viewModel.ItemID).FirstOrDefault();

            if (item != null)
            {
                viewModel.ItemID = item.ItemID;
                viewModel.TrainingID = item.TrainingID;
                viewModel.GoalTurns = item.GoalTurns;
                viewModel.GoalStrength = item.GoalStrength;
                viewModel.ExecutionID = item.ExecutionID;
                viewModel.Description = item.Description;
                viewModel.ActualStrength = item.ActualStrength;
                viewModel.ActualTurns = item.ActualTurns;
                viewModel.Remark = item.Remark;
                viewModel.Repeats = item.Repeats;
                viewModel.DurationInSeconds = item.DurationInMinutes * 60;
                viewModel.BreakInterval = item.BreakIntervalInSecond;
                viewModel.PurposeID = item.PurposeID;

                viewModel.AidID = item.TrainingItemAids.Select(s => s.AidID).ToArray();
            }

            ViewBag.ViewModel = viewModel;
            if (item == null)
            {
                return View("~/Views/LearnerProfile/ProfileModal/CreateTrainingItem.cshtml", item);
            }
            else
            {
                return View("~/Views/LearnerProfile/ProfileModal/EditTrainingItem.cshtml", item);
            }

        }

        public ActionResult EditBreakInterval(TrainingItemViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditTrainingItem(viewModel);
            result.ViewName = "~/Views/LearnerProfile/ProfileModal/EditBreakInterval.cshtml";
            return result;
        }

        public ActionResult CommitPDQ(PDQTaskItemViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            var question = models.GetTable<PDQQuestion>().Where(q => q.QuestionID == viewModel.QuestionID).FirstOrDefault();
            if (question == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            int?[] sugguestion = null;
            viewModel.PDQAnswer = viewModel.PDQAnswer.GetEfficientString();
            if (viewModel.SuggestionID != null && viewModel.SuggestionID.Length > 0)
            {
                sugguestion = viewModel.SuggestionID
                    .Where(s => s.HasValue).ToArray();
            }

            if (viewModel.NoChecked != true && (sugguestion == null || sugguestion.Length == 0) && viewModel.PDQAnswer == null)
            {
                return Json(new { result = false, message = "請至少勾選一項或填寫其它內容喔！" });
            }

            if (viewModel.QuestionnaireID.HasValue)
            {
                models.ExecuteCommand("delete PDQTask where UID = {0} and QuestionID = {1} and QuestionnaireID = {2}",
                        viewModel.UID, viewModel.QuestionID, viewModel.QuestionnaireID);
                models.ExecuteCommand("update QuestionnaireRequest set Status = {0} where QuestionnaireID = {1} and Status is null", (int)Naming.IncommingMessageStatus.未讀, viewModel.QuestionnaireID);
            }

            var item = new PDQTask
            {
                PDQAnswer = viewModel.PDQAnswer,
                TaskDate = DateTime.Now,
                UID = viewModel.UID.Value,
                QuestionID = viewModel.QuestionID,
                QuestionnaireID = viewModel.QuestionnaireID,
            };

            if (sugguestion != null)
            {
                if (sugguestion.Length > 0)
                {
                    if (question.QuestionType == (int)Naming.QuestionType.多重選 || question.QuestionType == (int)Naming.QuestionType.多重選其他)
                    {
                        item.PDQTaskItem.AddRange(viewModel.SuggestionID
                            .Where(s => s.HasValue)
                            .Select(s => new PDQTaskItem
                            {
                                SuggestionID = s.Value
                            }));
                    }
                    else
                    {
                        item.SuggestionID = sugguestion[0];
                    }
                }
            }

            models.GetTable<PDQTask>().InsertOnSubmit(item);
            models.SubmitChanges();

            return Json(new { result = true });

        }

        private ActionResult prepareLearner(ExercisePurposeViewModel viewModel,out UserProfile item)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: "學員資料錯誤!!");
            }

            return null;
        }

        public ActionResult EditLearnerFeature(ExercisePurposeViewModel viewModel)
        {
            ActionResult result = prepareLearner(viewModel, out UserProfile item);
            if (result != null)
                return result;

            var purpose = item.PersonalExercisePurpose;
            if (purpose != null)
            {
                viewModel.Purpose = purpose.Purpose.GetEfficientString();
                viewModel.Ability = purpose.PowerAbility;
                viewModel.Cardiopulmonary = purpose.Cardiopulmonary;
                viewModel.Flexibility = purpose.Flexibility;
                viewModel.MuscleStrength = purpose.MuscleStrength;
                viewModel.AbilityStyle = purpose.AbilityStyle;
                viewModel.AbilityLevel = (Naming.PowerAbilityLevel?)purpose.AbilityLevel;
            }

            return View("~/Views/LearnerProfile/Module/EditLearnerFeature.cshtml", item);
        }

        public ActionResult EditExercisePurpose(ExercisePurposeViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditLearnerFeature(viewModel);
            if (!(result.Model is UserProfile item))
                return result;

            result.ViewName = "~/Views/LearnerProfile/Module/EditExercisePurpose.cshtml";
            return result;
        }


        public ActionResult CommitLearnerFeature(ExercisePurposeViewModel viewModel)
        {
            ActionResult result = prepareLearner(viewModel, out UserProfile item);
            if (result != null)
            {
                return result;
            }

            viewModel.AbilityStyle = viewModel.AbilityStyle.GetEfficientString();
            if (viewModel.AbilityStyle == null)
            {
                ModelState.AddModelError("AbilityStyle", "請選擇運動類型");
            }

            if (!viewModel.AbilityLevel.HasValue)
            {
                ModelState.AddModelError("AbilityLevel", "請選擇Level");
            }

            if((!viewModel.Cardiopulmonary.HasValue || viewModel.Cardiopulmonary==0)
                && (!viewModel.MuscleStrength.HasValue || viewModel.MuscleStrength==0)
                && (!viewModel.Flexibility.HasValue || viewModel.Flexibility==0))
            {
                ModelState.AddModelError("StrengthFeature", "請選擇至少一項強度");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            if (item.PersonalExercisePurpose == null)
            {
                item.PersonalExercisePurpose = new PersonalExercisePurpose { };
            }

            viewModel.Ability = $"{viewModel.AbilityStyle}（{viewModel.AbilityLevel}）";

            var purpose = item.PersonalExercisePurpose;
            //purpose.Purpose = viewModel.Purpose;
            purpose.PowerAbility = viewModel.Ability;
            purpose.Flexibility = viewModel.Flexibility;
            purpose.Cardiopulmonary = viewModel.Cardiopulmonary;
            purpose.MuscleStrength = viewModel.MuscleStrength;
            purpose.AbilityStyle = viewModel.AbilityStyle;
            purpose.AbilityLevel = (int?)viewModel.AbilityLevel;

            models.SubmitChanges();

            return Json(new { result = true, message = viewModel.Ability });

        }

        public ActionResult CommitExercisePurpose(ExercisePurposeViewModel viewModel)
        {
            ActionResult result = prepareLearner(viewModel, out UserProfile item);
            if (result != null)
            {
                return result;
            }

            viewModel.Purpose = viewModel.Items?.Purpose.GetEfficientString();
            if (viewModel.Purpose == null)
            {
                ModelState.AddModelError("Purpose", "週期性目標");
            }

            var itemCount = models.GetTable<PersonalExercisePurposeItem>()
                .Where(p => !p.CompleteDate.HasValue)
                .Where(p => p.UID == item.UID).Count();
            if (viewModel.Items != null)
            {
                if (viewModel.Items.ItemID != null)
                {
                    foreach (var id in viewModel.Items.ItemID)
                    {
                        if(models.GetTable<PersonalExercisePurposeItem>().Any(p=>p.UID==item.UID && p.ItemID==id))
                        {
                            itemCount--;
                        }
                    }
                }
                if (viewModel.Items.PurposeItem != null)
                {
                    itemCount = itemCount + viewModel.Items.PurposeItem
                        .Select(i => i.GetEfficientString())
                        .Where(i => i != null).Count();
                }
            }

            if (!(itemCount >= 1 && itemCount <= 3))
            {
                ModelState.AddModelError("PurposeItem", "近期目標至少一項，最多三項!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            if (item.PersonalExercisePurpose == null)
            {
                item.PersonalExercisePurpose = new PersonalExercisePurpose { };
            }

            var purpose = item.PersonalExercisePurpose;
            //purpose.Purpose = viewModel.Purpose;
            purpose.Purpose = viewModel.Purpose;

            if(viewModel.Items!=null)
            {
                if (viewModel.Items.ItemID != null)
                {
                    foreach (var id in viewModel.Items.ItemID)
                    {
                        models.ExecuteCommand("delete PersonalExercisePurposeItem where UID = {0} and ItemID = {1}", item.UID, id);
                    }
                }
                if (viewModel.Items.PurposeItem != null)
                {
                    foreach (var p in viewModel.Items.PurposeItem
                        .Select(i => i.GetEfficientString())
                        .Where(i => i != null))
                    {
                        models.GetTable<PersonalExercisePurposeItem>().InsertOnSubmit(new PersonalExercisePurposeItem
                        {
                            PersonalExercisePurpose = purpose,
                            InitialDate = DateTime.Now,
                            PurposeItem = p
                        });
                    }
                }
            }

            models.SubmitChanges();

            return Json(new { result = true, message = viewModel.Purpose });

        }

        public async Task<ActionResult> CommitLearnerCharacterAsync(LearnerCharacterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            if (viewModel.QuestionnaireID.HasValue)
            {
                var count = models.ExecuteCommand(@"
                    UPDATE       QuestionnaireRequest
                    SET                Status = {0}
                    WHERE        (UID = {1}) AND (QuestionnaireID = {2})", 
                    (int)Naming.IncommingMessageStatus.已讀, 
                    viewModel.UID, 
                    viewModel.QuestionnaireID);

                models.ExecuteCommand("delete QuestionnaireCoachFinish where QuestionnaireID = {0}", viewModel.QuestionnaireID);
                models.ExecuteCommand(@"
                    INSERT INTO QuestionnaireCoachFinish  (QuestionnaireID, UID)
                    values ({0},{1})", viewModel.QuestionnaireID, profile.UID);
            }

            return Json(new { result = true });

        }

        public ActionResult SearchLearner(String userName)
        {
            userName = userName.GetEfficientString();
            if (userName == null)
            {
                this.ModelState.AddModelError("userName", "請輸入查詢學員!!");
                ViewBag.ModelState = this.ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            var items = userName.PromptUserProfileByName(models);

            if (items.Count() > 0)
                return View("~/Views/LearnerProfile/ProfileModal/SelectLearnerProfile.cshtml", items);
            else
            {
                //return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "Opps！您確定您輸入的資料正確嗎！？");
                return Json(new { result = false, message = "Opps！您確定您輸入的資料正確嗎！？" });
            }

        }

        public ActionResult ResumeLearnerCharacter(LearnerCharacterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            var profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (profile == null)
            {
                return Json(new { result = false, message = "資料錯誤!" });
            }

            var questionnaire = models.GetEffectiveQuestionnaireRequest(profile, Naming.QuestionnaireGroup.身體心靈密碼).FirstOrDefault();
            if(questionnaire==null || !questionnaire.PDQTask.Any())
            {
                return Json(new { result = true });
            }

            if (!questionnaire.PartID.HasValue && viewModel.PartID == QuestionnaireRequest.PartIDEnum.PartA)
            {
                return View("~/Views/ConsoleHome/EditLearnerCharacter/ResumeLearnerCharacterPartA.cshtml", questionnaire);
            }

            return View("~/Views/LearnerProfile/Module/ResumeLearnerCharacter.cshtml", questionnaire);

        }

        public ActionResult RejectLearnerCharacter(LearnerCharacterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            var questionnaire = models.GetTable<QuestionnaireRequest>().Where(q => q.QuestionnaireID == viewModel.QuestionnaireID)
                                    .Where(q => q.UID == viewModel.UID).FirstOrDefault();

            if (questionnaire == null)
            {
                return Json(new { result = false, message = "資料錯誤!" });
            }

            questionnaire.Status = (int)Naming.IncommingMessageStatus.拒答;
            models.SubmitChanges();

            return Json(new { result = true });

        }

        public ActionResult ShowLearnerAboutToBirth(LearnerQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var items = models.PromptLearner(viewModel.IncludeTrial == true);

            if(viewModel.KeyID!=null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            if(viewModel.CoachID.HasValue)
            {
                var coach = models.GetTable<ServingCoach>().Where(c => c.CoachID == viewModel.CoachID).FirstOrDefault();
                items = items.FilterLearnerByAdvisor(coach, models);
            }

            if (viewModel.BirthIncomingDays.HasValue)
            {
                items = items.FilterLearnerWithBirthday(DateTime.Today, DateTime.Today.AddDays(viewModel.BirthIncomingDays.Value));
            }

            return View("~/Views/LearnerProfile/ProfileModal/LearnerAboutToBirth.cshtml", items);
        }

        public ActionResult LoadTrainingExecution(DailyBookingQueryViewModel viewModel,int? stageID)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            var item = ViewBag.DataItem = models.GetTable<LessonTime>().Where(u => u.LessonID == viewModel.LessonID).First();
            ViewBag.Learner = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.LearnerID).First();
            ViewBag.StageID = stageID;
            ViewBag.ViewID = viewModel.ViewID;

            return View("~/Views/LearnerProfile/Module/LessonTrainingExecution.cshtml", item);
        }

        public ActionResult ShowLearnerBonusDetails(LearnerCharacterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            var profile = models.GetTable<UserProfile>().Where(q => q.UID == viewModel.UID).FirstOrDefault();
            ViewBag.DataItem = profile;

            if (profile == null)
            {
                return Json(new { result = false, message = "資料錯誤!" });
            }

            return View("~/Views/LearnerProfile/ProfileModal/ShowLearnerBonusDetails.cshtml", profile);

        }

        public ActionResult ShowLearnerBonusAwards(LearnerCharacterViewModel viewModel)
        {
            var result = ShowLearnerBonusDetails(viewModel);
            UserProfile item = ViewBag.DataItem as UserProfile;
            if (item == null)
                return result;

            return View("~/Views/LearnerProfile/Module/ShowLearnerBonusAwards.cshtml", item);
        }
        public ActionResult ShowLearnerBonusCredits(LearnerCharacterViewModel viewModel)
        {
            var result = ShowLearnerBonusDetails(viewModel);
            UserProfile item = ViewBag.DataItem as UserProfile;
            if (item == null)
                return result;

            return View("~/Views/LearnerProfile/Module/ShowLearnerBonusCredits.cshtml", item);
        }
        public ActionResult ShowLearnerDailyAnswers(LearnerCharacterViewModel viewModel)
        {
            var result = ShowLearnerBonusDetails(viewModel);
            UserProfile item = ViewBag.DataItem as UserProfile;
            if (item == null)
                return result;

            return View("~/Views/LearnerProfile/Module/ShowLearnerDailyAnswers.cshtml", item);
        }


    }
}