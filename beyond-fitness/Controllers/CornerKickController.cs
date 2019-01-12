using System;
using System.Collections.Generic;
using System.Data;
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

using CommonLib.DataAccess;
using CommonLib.MvcExtension;
using Newtonsoft.Json;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    public class CornerKickController : SampleController<UserProfile>
    {
        // GET: CornerKick
        public ActionResult Index(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.LineID = viewModel.KeyID.DecryptKey();
            }
            return View("Index");
        }

        public ActionResult TestError()
        {
            throw new Exception("Test Error...");
        }

        public ActionResult Login(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("Login");
        }

        public ActionResult Error(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("Error");
        }

        protected override void OnException(ExceptionContext filterContext)
        {
            if (filterContext.Exception is CryptographicException)
            {
                Response.Redirect((new UrlHelper(filterContext.RequestContext)).Action("InvalidCrypto", "Error"));
            }
            else
            {
                if (filterContext.Exception != null)
                {
                    Logger.Error(filterContext.Exception);
                }
                Response.Redirect((new UrlHelper(filterContext.RequestContext)).Action("Error", "CornerKick"));
                //base.OnException(filterContext);
            }
        }


        public ActionResult ForgetPassword(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public ActionResult AutoLogin(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = HttpContext.GetUser();
            if (item != null)
            {
                HttpContext.SignOn(item);
                return View("~/Views/CornerKick/Module/AutoLogin.ascx", model: this.ProcessLogin(item));
            }

            return new EmptyResult();
        }

        public ActionResult Register(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<UserProfileExtension>().Where(u => u.LineID == viewModel.LineID)
                    .Select(u => u.UserProfile).FirstOrDefault();

            if (item != null)
            {
                HttpContext.SignOn(item);
                return View("~/Views/CornerKick/Module/AutoLogin.ascx", model: this.ProcessLogin(item, true));
            }
            else
            {
                return View();
            }

        }

        public ActionResult Unbind(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<UserProfileExtension>().Where(u => u.LineID == viewModel.LineID)
                    .Select(u => u.UserProfile).FirstOrDefault();

            if (item != null)
            {
                return View(item);
            }
            else
            {
                return View("Index");
            }

        }

        public ActionResult CommitUnbound(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();

            if (item != null)
            {
                item.UserProfileExtension.LineID = null;
                models.SubmitChanges();
            }

            return View("Index");

        }


        public ActionResult BindUser(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.LineID = viewModel.LineID.GetEfficientString();
            if (viewModel.LineID == null)
            {
                ModelState.AddModelError("PID", "您輸入的Line ID錯誤，請確認後再重新輸入!!");
            }

            viewModel.MemberCode = viewModel.MemberCode.GetEfficientString();
            if (viewModel.MemberCode == null)
            {
                ModelState.AddModelError("MemberCode", "會員編號資料錯誤，請確認後再重新輸入!!");
            }

            viewModel.PID = viewModel.PID.GetEfficientString();
            if (viewModel.PID == null || !Regex.IsMatch(viewModel.PID, "\\w+([-+.']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"))
            {
                ModelState.AddModelError("PID", "電子信箱資料錯誤，請確認後再重新輸入!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                ViewBag.SingleError = true;
                return View("~/Views/Shared/Materialize/ReportInputError.ascx");
            }

            UserProfile item = models.EntityList.Where(u => u.MemberCode == viewModel.MemberCode
                || u.UserProfileExtension.IDNo == viewModel.MemberCode).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/Materialize/ReportInputError.ascx");
            }

            if (item.UserProfileExtension.LineID != null)
            {
                ModelState.AddModelError("PID", "您的帳號已設定過其他Line ID，請確認後再重新輸入!!");
            }

            if (models.GetTable<UserProfileExtension>().Any(u => u.LineID == viewModel.LineID))
            {
                ModelState.AddModelError("PID", "您的Line ID已設定其他使用者帳號，請確認後再重新輸入!!");
            }

            if (models.EntityList.Any(u => u.PID == viewModel.PID && u.UID != item.UID))
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                ViewBag.ModelState = ModelState;
            }

            if (item.UserProfileExtension.CurrentTrial == 1 || !item.IsLearner())
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
            }

            var pwd = (viewModel.Password).MakePassword();
            if (item.LevelID != (int)Naming.MemberStatusDefinition.ReadyToRegister)
            {
                if (item.Password != pwd)
                {
                    ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                }
            }
            else if (pwd == null)
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
            }
            else
            {
                item.Password = pwd;
                item.LevelID = (int)Naming.MemberStatusDefinition.Checked;
            }


            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                ViewBag.SingleError = true;
                return View("~/Views/Shared/Materialize/ReportInputError.ascx");
            }

            if (item.PID != viewModel.PID)
            {
                item.PID = viewModel.PID;
            }

            item.UserProfileExtension.LineID = viewModel.LineID;
            models.SubmitChanges();

            HttpContext.SignOn(item);

            //綁定Line贈點活動
            PDQTask taskItem = null;
            if (!models.GetTable<PDQTask>().Any(t => t.UID == item.UID && t.PDQQuestion.GroupID == 8))
            {
                var quest = models.GetTable<PDQQuestion>().Where(q => q.GroupID == 8).FirstOrDefault();
                if (quest != null)
                {
                    taskItem = new PDQTask
                    {
                        QuestionID = quest.QuestionID,
                        UID = item.UID,
                        TaskDate = DateTime.Now,
                        PDQTaskBonus = new PDQTaskBonus { },
                    };
                    models.GetTable<PDQTask>().InsertOnSubmit(taskItem);
                    models.SubmitChanges();
                }
            }

            return Json(new { result = true, bonus = taskItem!=null }, JsonRequestBehavior.AllowGet);

        }

        public ActionResult CommitToRegister(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.MemberCode = viewModel.MemberCode.GetEfficientString();
            if (viewModel.MemberCode == null)
            {
                ModelState.AddModelError("MemberCode", "會員編號資料錯誤，請確認後再重新輸入!!");
            }

            viewModel.PID = viewModel.PID.GetEfficientString();
            if (viewModel.PID == null || !Regex.IsMatch(viewModel.PID, "\\w+([-+.']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"))
            {
                ModelState.AddModelError("PID", "電子信箱資料錯誤，請確認後再重新輸入!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                ViewBag.SingleError = true;
                return View("~/Views/Shared/Materialize/ReportInputError.ascx");
            }

            UserProfile item = models.EntityList.Where(u => u.MemberCode == viewModel.MemberCode
                || u.UserProfileExtension.IDNo == viewModel.MemberCode).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/Materialize/ReportInputError.ascx");
            }

            if (models.EntityList.Any(u => u.PID == viewModel.PID && u.UID != item.UID))
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                ViewBag.ModelState = ModelState;
            }

            if (item.UserProfileExtension.CurrentTrial == 1 /*|| !item.IsLearner()*/)
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
            }

            var pwd = (viewModel.Password).MakePassword();
            if (item.LevelID != (int)Naming.MemberStatusDefinition.ReadyToRegister)
            {
                if (item.Password != pwd)
                {
                    ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
                }
            }
            else if (pwd == null)
            {
                ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
            }
            else
            {
                item.Password = pwd;
                item.LevelID = (int)Naming.MemberStatusDefinition.Checked;
            }


            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                ViewBag.SingleError = true;
                return View("~/Views/Shared/Materialize/ReportInputError.ascx");
            }

            if (item.PID != viewModel.PID)
            {
                item.PID = viewModel.PID;
            }

            models.SubmitChanges();

            HttpContext.SignOn(item);

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);

        }


        [Authorize]
        public ActionResult Settings(bool? learnerSettings,bool? bonus)
        {
            ViewBag.LearnerSettings = learnerSettings;
            ViewBag.LineBonus = bonus;
            return View();
        }

        [Authorize]
        public ActionResult CommitSettings(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName == null)
            {
                ModelState.AddModelError("UserName", "請輸入暱稱!!");
            }


            UserProfile item = HttpContext.GetUser().LoadInstance(models);

            if (viewModel.LearnerSettings == true)
            {
                viewModel.PID = viewModel.PID.GetEfficientString();
                if (viewModel.PID != null)
                {
                    if (item.PID != viewModel.PID && models.EntityList.Any(u => u.PID == viewModel.PID && u.UID != item.UID))
                    {
                        ModelState.AddModelError("EMail", "您的Email已經是註冊使用者!!請重新設定Email!!");
                    }
                    else
                    {
                        item.PID = viewModel.PID;
                    }
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/Materialize/ReportInputError.ascx");
            }
            
            item.UserName = viewModel.UserName;
            models.SubmitChanges();

            return View("~/Views/Html/Module/AutoLogin.ascx", model: this.ProcessLogin(item, true));

        }

        public ActionResult Notice(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.LineID = viewModel.KeyID.DecryptKey();
            }
            var item = models.GetTable<UserProfileExtension>().Where(u => u.LineID == viewModel.LineID)
                    .Select(u => u.UserProfile).FirstOrDefault();

            if (item != null)
            {
                HttpContext.SignOn(item);
                return View(item);
            }
            else
            {
                ViewBag.Message = "此支裝置尚未設定過專屬服務，請點選下方更多資訊/專屬服務/帳號設定才可使用！";
                return View("Index");
            }

        }

        public ActionResult NoticeNotFound(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public ActionResult CheckAttendance(RegisterViewModel viewModel)
        {
            ViewResult result = (ViewResult)Notice(viewModel);
            UserProfile item = result.Model as UserProfile;

            if(item!=null)
            {
                result.ViewName = "CheckAttendance";
            }

            return result;
        }

        [Authorize]
        public ActionResult LearnerToCheckAttendance()
        {
            var profile = HttpContext.GetUser().LoadInstance(models);
            return View("CheckAttendance", profile);
        }


        public ActionResult AttendanceAccomplished(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        [Authorize]
        public ActionResult CommitAttendance(LearnerQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser().LoadInstance(models);

            if(viewModel.LessonID!=null && viewModel.LessonID.Length>0)
            {
                foreach (var item in models.GetTable<LessonTime>().Where(l => viewModel.LessonID.Contains(l.LessonID)))
                {
                    if (item.GroupingLesson.RegisterLesson.Any(r => r.UID == profile.UID))
                    {
                        item.LessonPlan.CommitAttendance = DateTime.Now;
                        models.SubmitChanges();
                    }
                }
            }

            return View("CheckAttendance",profile);

        }

        [Authorize]
        public ActionResult AnswerDailyQuestion()
        {
            var profile = HttpContext.GetUser();
            var item = models.PromptLearnerDailyQuestion(profile);
            return View("AnswerDailyQuestion", item);
        }

        [Authorize]
        public ActionResult CommitAnswerDailyQuestion(DailyQuestionViewModel viewModel)
        {

            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            if(viewModel.KeyID!=null)
            {
                viewModel.QuestionID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<PDQQuestion>().Where(q => q.QuestionID == viewModel.QuestionID).FirstOrDefault();
            if (item == null || !viewModel.SuggestionID.HasValue)
            {
                return AnswerDailyQuestion();
            }

            if (models.GetTable<PDQTask>().Any(t => t.UID == profile.UID
                 && t.TaskDate >= DateTime.Today && t.TaskDate < DateTime.Today.AddDays(1)
                 && t.PDQQuestion.GroupID == 6))
            {
                return AnswerDailyQuestion();
            }

            var taskItem = new PDQTask
            {
                QuestionID = item.QuestionID,
                SuggestionID = viewModel.SuggestionID,
                UID = profile.UID,
                TaskDate = DateTime.Now
            };
            models.GetTable<PDQTask>().InsertOnSubmit(taskItem);
            models.SubmitChanges();

            if (item.PDQSuggestion.Any(s => s.SuggestionID == viewModel.SuggestionID && s.RightAnswer == true))
            {
                if (item.PDQQuestionExtension != null)
                {
                    taskItem.PDQTaskBonus = new PDQTaskBonus { };
                    models.SubmitChanges();
                }
            }

            return AnswerDailyQuestion();
        }

        [Authorize]
        public ActionResult LearnerIndex()
        {
            var profile = HttpContext.GetUser().LoadInstance(models);
            return View(profile);
        }

        public ActionResult Logout(RegisterViewModel viewModel,String message = null)
        {
            this.HttpContext.Logout();
            ViewBag.Message = message;
            return Index(viewModel);
        }

        [Authorize]
        public ActionResult LearnerNotice()
        {
            var profile = HttpContext.GetUser().LoadInstance(models);
            return View("Notice", profile);
        }

        public ActionResult ResetPassword(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item;
            if (viewModel.UUID != null)
            {
                item = models.GetTable<ResetPassword>().Where(r => r.ResetID == viewModel.UUID)
                    .Select(r => r.UserProfile)
                    .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                    .FirstOrDefault();
            }
            else
            {
                item = HttpContext.GetUser()?.LoadInstance(models);
            }

            if (item == null)
            {
                return Index(viewModel);
            }

            return View(item);
        }

        public ActionResult CommitPassword(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item;
            if (viewModel.UUID != null)
            {
                item = models.GetTable<ResetPassword>().Where(r => r.ResetID == viewModel.UUID)
                    .Select(r => r.UserProfile)
                    .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                    .FirstOrDefault();
            }
            else
            {
                item = HttpContext.GetUser()?.LoadInstance(models);
            }

            if (item == null)
            {
                if (viewModel.KeyID != null)
                {
                    viewModel.UID = viewModel.DecryptKeyValue();
                }
                item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            }

            if (item == null)
            {
                return Login(viewModel);
            }

            var pwd = (viewModel.Password).MakePassword();
            if (pwd == null)
            {
                ModelState.AddModelError("Password", "您輸入的資料錯誤，請確認後再重新輸入!!");
            }
            else if (viewModel.Password.ToUpper() == "BEYOND")
            {
                ModelState.AddModelError("Password", "您所輸入的密碼安全性不足，請重新設定!!");
            }
            else
            {
                item.Password = pwd;
                item.LevelID = (int)Naming.MemberStatusDefinition.Checked;
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                ViewBag.SingleError = true;
                return View("~/Views/Shared/Materialize/ReportInputError.ascx");
            }

            models.SubmitChanges();

            //if (viewModel.UUID != null)
            //{
                HttpContext.SignOn(item);
            //}

            return View("~/Views/CornerKick/Module/CommitPassword.ascx", item);

        }

        [Authorize]
        public ActionResult TrainingAnalysis()
        {
            var profile = HttpContext.GetUser().LoadInstance(models);
            return View(profile);
        }

        [Authorize]
        public ActionResult LearnerTrainingGoal()
        {
            var profile = HttpContext.GetUser().LoadInstance(models);
            return View(profile);
        }

        [Authorize]
        public ActionResult LearnerToCheckTrainingGoal()
        {
            var profile = HttpContext.GetUser().LoadInstance(models);
            models.ExecuteCommand(@"UPDATE PersonalExercisePurposeItem
                            SET        NoticeStatus = {0}
                            WHERE   (UID = {1})", (int)Naming.IncommingMessageStatus.已讀, profile.UID);
            return View("LearnerTrainingGoal", profile);
        }


        [Authorize]
        public ActionResult StartNavigation(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.EventID = viewModel.DecryptKeyValue();
            }

            var profile = HttpContext.GetUser().LoadInstance(models);
            if (viewModel.EventID.HasValue)
            {
                models.ExecuteCommand("delete UserEvent where UID={0} and EventID={1}", profile.UID, viewModel.EventID);
            }

            return View(profile);
        }

        [Authorize]
        public ActionResult CheckBonusPoint()
        {
            var profile = HttpContext.GetUser().LoadInstance(models);
            return View(profile);
        }


        public ActionResult TodayLesson(RegisterViewModel viewModel)
        {
            ViewResult result = (ViewResult)Notice(viewModel);
            UserProfile item = result.Model as UserProfile;

            if (item != null)
            {
                return View("TodayLesson", item);
            }
            else
            {
                return result;
            }
        }

        public ActionResult CheckBonusPointByLine(RegisterViewModel viewModel)
        {
            ViewResult result = (ViewResult)Notice(viewModel);
            UserProfile item = result.Model as UserProfile;

            if (item != null)
            {
                return View("CheckBonusPoint", item);
            }
            else
            {
                return result;
            }
        }

        [Authorize]
        public ActionResult ViewLesson(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(viewModel.KeyID!=null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            ViewBag.DataItem = models.GetTable<LessonTime>().Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();
            var profile = HttpContext.GetUser().LoadInstance(models);
            return View("TodayLesson", profile);
        }

        public ActionResult SignOn(LoginViewModel viewModel, string returnUrl)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item = viewModel.ValiateLogin(models, ModelState);

            if (item == null)
            {
                ViewBag.ModelState = ModelState;
                return View("Login");
            }
            
            if (viewModel.Password.ToUpper() == "BEYOND")
            {
                return View("ResetPassword", item);
            }

            HttpContext.SignOn(item, viewModel.RememberMe);

            if (!String.IsNullOrEmpty(returnUrl))
            {
                return View("~/Views/Html/Module/AutoLogin.ascx", model: returnUrl);
            }

            return View("~/Views/Html/Module/AutoLogin.ascx", model: this.ProcessLogin(item, false));

        }

        public ActionResult CommitToForgetPassword(String email)
        {
            if (String.IsNullOrEmpty(email))
            {
                ModelState.AddModelError("email", "請輸入您的 email address");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/Materialize/ReportInputError.ascx");
            }


            UserProfile item = models.EntityList.Where(u => u.PID == email.Trim()
                && u.LevelID == (int)Naming.MemberStatusDefinition.Checked).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("email", "您輸入的資料錯誤，請確認後再重新輸入!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/Materialize/ReportInputError.ascx");
            }

            ResetPassword toReset = new ResetPassword
            {
                ResetID = Guid.NewGuid(),
                UserProfile = item
            };

            models.GetTable<ResetPassword>().InsertOnSubmit(toReset);
            models.SubmitChanges();

            toReset.NotifyResetPassword(notifyUrl:$"{WebHome.Properties.Settings.Default.HostDomain}{VirtualPathUtility.ToAbsolute("~/CornerKick/NotifyResetPassword")}");

            return View("~/Views/Shared/JsAlert.ascx", model: "重設密碼通知郵件已寄出!!");

        }

        public ActionResult NotifyResetPassword(String resetID)
        {
            return View("NotifyResetPassword", model: resetID);
        }

        [Authorize]
        public ActionResult LearnerCalendar()
        {
            var profile = HttpContext.GetUser().LoadInstance(models);
            return View(profile);
        }

        [Authorize]
        public ActionResult LearnerEvents(DateTime dateFrom, DateTime? dateTo)
        {
            ViewBag.StartDate = dateFrom;
            var profile = HttpContext.GetUser().LoadInstance(models);
            return View("~/Views/CornerKick/Module/LearnerEvents.ascx", profile);
        }

        [Authorize]
        public ActionResult EditUserEvent(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser().LoadInstance(models);

            if(viewModel.KeyID!=null)
            {
                viewModel.EventID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<UserEvent>().Where(v => v.EventID == viewModel.EventID && v.UID == profile.UID).FirstOrDefault();
            if (item != null)
            {
                viewModel.UID = item.UID;
                viewModel.StartDate = item.StartDate;
                viewModel.EndDate = item.EndDate;
                viewModel.Title = item.Title;
            }

            return View("EditUserEvent", profile);
        }

        [Authorize]
        public ActionResult CommitUserEvent(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = HttpContext.GetUser();

            if (!viewModel.StartDate.HasValue)
            {
                ModelState.AddModelError("StartDate", "請選擇開始時間!!");
            }
            if (!viewModel.EndDate.HasValue)
            {
                ModelState.AddModelError("EndDate", "請選擇結束時間!!");
            }

            if(viewModel.StartTime.HasValue)
            {
                viewModel.StartDate = viewModel.StartDate.Value + viewModel.StartTime.Value;
            }

            if (viewModel.EndTime.HasValue)
            {
                viewModel.EndDate = viewModel.EndDate.Value + viewModel.EndTime.Value;
            }

            if (viewModel.StartDate > viewModel.EndDate)
            {
                ModelState.AddModelError("StartDate", "開始日期晚於結束日期!!");
            }


            if (String.IsNullOrEmpty(viewModel.Title))
            {
                ModelState.AddModelError("Title", "請輸入行事曆內容!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/Materialize/ReportInputError.ascx");
            }

            var item = models.GetTable<UserEvent>().Where(u => u.EventID == viewModel.EventID).FirstOrDefault();
            if (item == null)
            {
                item = new UserEvent
                {
                    UID = profile.UID
                };
                models.GetTable<UserEvent>().InsertOnSubmit(item);
                viewModel.CreateNew = true;
            }

            item.StartDate = viewModel.StartDate.Value;
            item.EndDate = viewModel.EndDate.Value;
            item.Title = viewModel.Title;

            models.SubmitChanges();

            return View("~/Views/CornerKick/Module/CompleteUserEvent.ascx", item);
        }

        [Authorize]
        public ActionResult ShowLearnerEvent(UserEventViewModel viewModel)
        {
            var profile = HttpContext.GetUser();

            var eventItem = models.GetTable<UserEvent>().Where(v => v.UID == profile.UID && v.EventID == viewModel.EventID).FirstOrDefault();
            if (eventItem != null)
            {
                return EditUserEvent(viewModel);
            }

            var lessonItem = models.GetTable<LessonTime>().Where(l => l.LessonID == viewModel.EventID).FirstOrDefault();
            if (lessonItem != null)
            {
                ViewBag.DataItem = lessonItem;
                return View("TodayLesson", profile.LoadInstance(models));
            }

            return View("LearnerCalendar", profile.LoadInstance(models));
        }

        [Authorize]
        public ActionResult DeleteLearnerEvent(UserEventViewModel viewModel)
        {
            var profile = HttpContext.GetUser();
            var eventItem = models.DeleteAny<UserEvent>(v => v.UID == profile.UID && v.EventID == viewModel.EventID);
            return View("LearnerCalendar", profile.LoadInstance(models));
        }


    }
}