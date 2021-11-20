using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
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
using WebHome.Models.ViewModel;
using WebHome.Security.Authorization;
using Microsoft.Extensions.Primitives;

namespace WebHome.Controllers
{
    [Authorize]
    public class InteractivityController : SampleController<UserProfile>
    {
        public InteractivityController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: Interactivity
        public ActionResult Questionnaire(int id)
        {
            var item = models.GetTable<QuestionnaireRequest>().Where(q => q.QuestionnaireID == id).FirstOrDefault();

            if (item==null)
            {
                ViewBag.Message = "問卷資料尚未建立!!";
                return RedirectToAction("Vip", "Account");
            }

            return View(item);
        }

        public async Task<ActionResult> CommitQuestionnaire(int id)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Json(new { result = false, message = "您的連線已中斷，請重新登入系統!!" });
            }

            var item = models.GetTable<QuestionnaireRequest>().Where(l => l.QuestionnaireID == id).FirstOrDefault();
            if (item == null /*|| item.UID!=profile.UID*/)
            {
                return Json(new { result = false, message = "問卷資料不存在!!" });
            }

            models.ExecuteCommand(@"
                DELETE FROM PDQTask
                    WHERE   (QuestionnaireID = {0})", item.QuestionnaireID);

            DateTime taskDate = DateTime.Now;
            foreach (var key in Request.Form.Keys.Where(k => Regex.IsMatch(k, "_\\d")))
            {
                saveQuestionnaire(item, key, ref taskDate, profile);
            }

            models.SubmitChanges();

            var questItems = item.PDQGroup.PDQQuestion;
            var ansItems = item.PDQTask.Select(p => p.PDQQuestion.QuestionID);

            var voidAns = questItems
                .Where(q => !ansItems.Contains(q.QuestionID))
                .OrderBy(q => q.QuestionNo);
            if (voidAns.Count() > 0)
            {

                models.ExecuteCommand(@"
                DELETE FROM PDQTask
                    WHERE   (QuestionnaireID = {0})", item.QuestionnaireID);
                return Json(new { result = false, message = "請填選第" + String.Join("、", voidAns.Select(q => q.QuestionNo)) + "題答案!!" });
            }
            else
            {
                item.Status = (int)Naming.IncommingMessageStatus.未讀;
                models.SubmitChanges();

                var items = models.GetQuestionnaireRequest(profile);
                return Json(new { result = true, message = items.Count() > 0 ? items.Count().ToString() : null });
            }

        }

        protected void saveQuestionnaire(QuestionnaireRequest item, string key,ref DateTime taskDate,UserProfile actor)
        {
            int questionID = int.Parse(key.Substring(1));
            var quest = models.GetTable<PDQQuestion>().Where(q => q.QuestionID == questionID).FirstOrDefault();
            if (quest == null)
                return;

            StringValues values = Request.Form[key];
            if (values == (String)null || values.Count == 0)
                return;

            switch ((Naming.QuestionType)quest.QuestionType)
            {
                case Naming.QuestionType.問答題:
                    String strVal;
                    if (values.Count > 0 && (strVal=values[0].GetEfficientString())!=null)
                    {
                        models.GetTable<PDQTask>().InsertOnSubmit(new PDQTask
                        {
                            QuestionID = quest.QuestionID,
                            UID = actor.UID,
                            PDQAnswer = strVal,
                            QuestionnaireID = item.QuestionnaireID,
                            TaskDate = taskDate
                        });
                        models.SubmitChanges();
                    }
                    break;

                case Naming.QuestionType.單選題:
                case Naming.QuestionType.單選其他:
                    foreach (var v in values)
                    {
                        int suggestID;
                        if (int.TryParse(v, out suggestID))
                        {
                            models.GetTable<PDQTask>().InsertOnSubmit(new PDQTask
                            {
                                QuestionID = quest.QuestionID,
                                UID = actor.UID,
                                SuggestionID = suggestID,
                                QuestionnaireID = item.QuestionnaireID,
                                TaskDate = taskDate
                            });
                        }
                        else
                        {
                            models.GetTable<PDQTask>().InsertOnSubmit(new PDQTask
                            {
                                QuestionID = quest.QuestionID,
                                UID = actor.UID,
                                PDQAnswer = v,
                                QuestionnaireID = item.QuestionnaireID,
                                TaskDate = taskDate
                            });
                        }
                        models.SubmitChanges();
                    }
                    break;

                case Naming.QuestionType.多重選:
                    break;

                case Naming.QuestionType.是非題:
                    if (values.Count > 0)
                    {
                        models.GetTable<PDQTask>().InsertOnSubmit(new PDQTask
                        {
                            QuestionID = quest.QuestionID,
                            UID = actor.UID,
                            YesOrNo = values[0] == "1" ? true : false,
                            QuestionnaireID = item.QuestionnaireID,
                            TaskDate = taskDate
                        });
                        models.SubmitChanges();
                    }
                    break;
            }
        }

        public async Task<ActionResult> RejectQuestionnaireAsync(int id, int? status)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Json(new { result = false, message = "您的連線已中斷，請重新登入系統!!" });
            }

            var item = models.GetTable<QuestionnaireRequest>().Where(l => l.QuestionnaireID == id).FirstOrDefault();
            if (item == null /*|| item.UID != profile.UID*/)
            {
                return Json(new { result = false, message = "問卷資料不存在!!" });
            }

            item.Status = status ?? (int)Naming.IncommingMessageStatus.拒答;
            if(status==(int)Naming.IncommingMessageStatus.教練代答 && item.QuestionnaireCoachBypass==null)
            {
                item.QuestionnaireCoachBypass = new QuestionnaireCoachBypass
                {
                    UID = profile.UID
                };
            }
            models.SubmitChanges();

            var items = models.GetQuestionnaireRequest(item.UserProfile);
            return Json(new { result = true, message = items.Count() > 0 ? items.Count().ToString() : null });
        }


        public ActionResult LearnerQuestionnaire(int id)
        {
            var model = models.GetTable<QuestionnaireRequest>().Where(l => l.QuestionnaireID == id).FirstOrDefault();

            if (model == null)
            {
                ViewBag.Message = "問卷資料不存在!!";
                return View("~/Views/Shared/ShowMessage.ascx");
            }

            return View("~/Views/Interactivity/Questionnaire/LearnerQuestionnaire.ascx", model);

        }

        public async Task<ActionResult> LearnerPromptAsync()
        {
            var result = PromptQuestionnaire();
            if(result is EmptyResult)
            {
                result = await LearnerDailyQuestionAsync();
            }
            return result;
        }

        public ActionResult PromptQuestionnaire()
        {
            //UserProfile profile = await HttpContext.GetUserAsync();
            //if (profile == null)
            //{
            //    return new EmptyResult();
            //}

            //profile = models.GetTable<UserProfile>().Where(u => u.UID == profile.UID).First();

            //var item = models.GetQuestionnaireRequest(profile).FirstOrDefault();

            //if (item==null)
            //{
            //    return new EmptyResult();
            //}
            //else
            //{
            //    return View("~/Views/Interactivity/Questionnaire/PromptQuestionnaire.ascx", item);
            //}

            return new EmptyResult();
        }

        public async Task<ActionResult> LearnerDailyQuestionAsync()
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return new EmptyResult();
            }

            if (models.GetTable<PDQTask>().Any(t => t.UID == profile.UID
                 && t.TaskDate >= DateTime.Today && t.TaskDate < DateTime.Today.AddDays(1)
                 && t.PDQQuestion.GroupID == 6))
            {
                return new EmptyResult();
            }

            if (models.GetTable<PDQTask>().Count(t => t.UID == profile.UID && t.PDQQuestion.GroupID == 6) >=
                models.GetTable<RegisterLesson>().Where(r => r.UID == profile.UID)
                    .Select(r => r.GroupingLesson).Sum(g => g.LessonTime.Count(l => l.LessonPlan.CommitAttendance.HasValue || l.LessonAttendance != null)))
            {
                return new EmptyResult();
            }


            IQueryable<PDQQuestion> questItems = models.GetTable<PDQQuestion>().Where(q => q.GroupID == 6)
                .Join(models.GetTable<PDQQuestionExtension>().Where(t => !t.Status.HasValue),
                    q => q.QuestionID, t => t.QuestionID, (q, t) => q);
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
            return View("~/Views/Activity/LearnerDailyQuestion.ascx", item);
        }



    }
}