using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNetCore.Mvc;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Helper;
using WebHome.Models.ViewModel;
using CommonLib.Utility;
using Microsoft.AspNetCore.Authorization;
using WebHome.Security.Authorization;
using System.Threading.Tasks;

namespace WebHome.Controllers
{
    public class HtmlController : SampleController<UserProfile>
    {
        public HtmlController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        public ActionResult Login(bool? confirmedID)
        {
            return View("~/Views/Html/Module/Login.ascx", confirmedID);
        }
        public ActionResult ForgetPassword()
        {
            return View("~/Views/Html/Module/ForgetPassword.ascx");
        }

        public ActionResult Register()
        {
            return View("~/Views/Html/Module/Register.ascx");
        }

        public ActionResult RegisterByMail(RegisterViewModel viewModel)
        {

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.MemberCode == viewModel.MemberCode).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("MemberCode", "學員編號錯誤!!");
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            if (item.LevelID != (int)Naming.MemberStatusDefinition.ReadyToRegister)
            {
                ModelState.AddModelError("MemberCode", "學員編號已註冊!!");
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            ViewBag.ViewModel = viewModel;
            return View("~/Views/Html/Module/RegisterByMail.ascx", item);
        }

        public async Task<ActionResult> CompleteRegisterAsync(RegisterViewModel viewModel)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.MemberCode == viewModel.MemberCode).FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml",model:"會員編號錯誤!!");
            }

            viewModel.EMail = viewModel.EMail.GetEfficientString();
            if (viewModel.EMail == null)
            {
                this.ModelState.AddModelError("EMail", "請輸入Email");
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            if (models.GetTable<UserProfile>().Any(u => u.PID == viewModel.EMail))
            {
                ModelState.AddModelError("EMail", "您的Email已經是註冊使用者!!請直接登入系統!!");
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            item.PID = viewModel.EMail;
            item.UserName = viewModel.UserName.GetEfficientString();
            item.LevelID = (int)Naming.MemberStatusDefinition.Checked;
            item.UserProfileExtension.RegisterStatus = true;

            if (!this.CreatePassword(viewModel))
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            if (!String.IsNullOrEmpty(viewModel.Password))
            {
                item.Password = (viewModel.Password).MakePassword();
            }

            models.SubmitChanges();

            await HttpContext.SignOnAsync(item);

            ViewBag.ViewModel = viewModel;
            return View("~/Views/Html/Module/CompleteRegister.ascx", item);
        }

        [Authorize]
        public async Task<ActionResult> EditMySelf(RegisterViewModel viewModel)
        {
            //UserProfile item = viewModel.UID.HasValue
            //    ? models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault()
            //    : await HttpContext.GetUserAsync();

            UserProfile item = await HttpContext.GetUserAsync();

            //if (item == null)
            //{
            //    return Redirect($"~{Startup.Properties["LoginUrl"]}");
            //}

            viewModel.EMail = item.PID.Contains("@") ? item.PID : null;
            viewModel.MemberCode = item.MemberCode;
            viewModel.PictureID = item.PictureID;
            viewModel.UserName = item.UserName;
            viewModel.Birthday = item.Birthday;
            viewModel.UID = item.UID;

            ViewBag.ViewModel = viewModel;
            return View("~/Views/Html/Module/EditMySelf.ascx", item);
        }

        public async Task<ActionResult> CommitMySelfAsync(RegisterViewModel viewModel)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            int uid = item.UID;
            item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();

            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            viewModel.PictureID = item.PictureID;
            viewModel.EMail = viewModel.EMail.GetEfficientString();
            if (viewModel.EMail == null)
            {
                this.ModelState.AddModelError("EMail", "請輸入Email");
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            viewModel.EMail = viewModel.EMail.GetEfficientString();
            if (viewModel.EMail != null)
            {
                if (item.PID != viewModel.EMail && models.GetTable<UserProfile>().Any(u => u.PID == viewModel.EMail))
                {
                    ModelState.AddModelError("EMail", "您的Email已經是註冊使用者!!請重新設定Email!!");
                    ViewBag.ModelState = ModelState;
                    return View("~/Views/Shared/ReportInputError.ascx");
                }
                item.PID = viewModel.EMail;
            }

            item.UserName = viewModel.UserName.GetEfficientString();
            item.BirthdateIndex = null;
            item.Birthday = null;
            if (viewModel.Birthday.HasValue)
            {
                item.Birthday = viewModel.Birthday;
                item.BirthdateIndex = viewModel.Birthday.Value.Month * 100 + viewModel.Birthday.Value.Day;
            }

            if (!this.CreatePassword(viewModel))
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }
            item.Password = (viewModel.Password).MakePassword();

            models.SubmitChanges();

            await HttpContext.SignOnAsync(item);

            return View("~/Views/Html/Module/CompleteRegister.ascx", item);
        }


        public ActionResult CompleteRegisterReview(RegisterViewModel viewModel)
        {
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.MemberCode == viewModel.MemberCode).FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "會員編號錯誤!!");
            }

            return View("~/Views/Account/CompleteRegister.aspx", item);
        }

        public async Task<ActionResult> AutoLoginAsync(long? timeTicks)
        {
            //HttpCookie cookie = Request.Cookies["loginToken"];
            //if (cookie != null && !String.IsNullOrEmpty(cookie.Value))
            //{
            //    FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(cookie.Value);
            //    FormsIdentity identity = new FormsIdentity(ticket);
            //    Context.User = new ClaimsPrincipal(identity);
            //}

            var item = await HttpContext.GetUserAsync();
            if (item != null)
            {
                await HttpContext.SignOnAsync(item);
                return View("~/Views/Html/Module/AutoLogin.ascx", model: this.ProcessLogin(item));
            }

            return new EmptyResult();
        }

        public async Task<ActionResult> LoginByForm(LoginViewModel viewModel, string returnUrl)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item = viewModel.ValiateLogin(models, ModelState);

            if (item == null)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            await HttpContext.SignOnAsync(item, viewModel.RememberMe);

            if (!String.IsNullOrEmpty(returnUrl))
            {
                return View("~/Views/Html/Module/AutoLogin.ascx", model: returnUrl);

            }

            return View("~/Views/Html/Module/AutoLogin.ascx", model: this.ProcessLogin(item));

        }

        public async Task<ActionResult> LearnerPromptAsync()
        {
            var result = PromptQuestionnaire();
            if (result is EmptyResult)
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

            //if (item == null)
            //{
            //    return new EmptyResult();
            //}
            //else
            //{
            //    return View("~/Views/Html/Module/PromptQuestionnaire.ascx", item);
            //}

            return new EmptyResult();

        }

        //[CoachOrAssistantAuthorize]
        //public ActionResult PromptCurrentQuestionnaire(int? registerID,int? questionnaireID)
        //{
        //    QuestionnaireRequest item = null;
        //    if(questionnaireID.HasValue)
        //    {
        //        item = models.GetTable<QuestionnaireRequest>().Where(q => q.QuestionnaireID == questionnaireID).FirstOrDefault();
        //    }

        //    if (item == null)
        //    {
        //        var lesson = models.GetTable<RegisterLesson>().Where(u => u.RegisterID == registerID).FirstOrDefault();
        //        if (lesson == null)
        //        {
        //            return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
        //        }

        //        item = models.GetQuestionnaireRequest(lesson.UserProfile).FirstOrDefault();
        //        if (item == null && models.CheckCurrentQuestionnaireRequest(lesson))
        //        {
        //            item = models.CreateQuestionnaire(lesson);
        //        }
        //    }

        //    if (item != null)
        //    {
        //        ViewBag.ByCoach = true;
        //        return View("~/Views/Html/Module/PromptQuestionnaire.ascx", item);
        //    }

        //    return View("~/Views/Shared/JsAlert.cshtml", model: "階段性調整資料待建立!!");

        //}

        public async Task<ActionResult> LearnerDailyQuestionAsync()
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return new EmptyResult();
            }

            var item = models.PromptLearnerDailyQuestion(profile);
            if (item == null)
            {
                return new EmptyResult();
            }

            return View("~/Views/Html/Module/LearnerDailyQuestion.ascx", item);
        }

        [HttpGet]
        public ActionResult ResetPass(Guid id)
        {

            UserProfile item = models.GetTable<ResetPassword>().Where(r => r.ResetID == id)
                .Select(r => r.UserProfile)
                .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                .FirstOrDefault();

            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            PasswordViewModel viewModel = new PasswordViewModel
            {
                PID = item.PID
            };

            ViewBag.ViewModel = viewModel;
            return View(item);

        }

        [HttpPost]
        public async Task<ActionResult> ResetPass(PasswordViewModel viewModel)
        {

            ViewBag.ViewModel = viewModel;

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.PID == viewModel.PID
                && u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                .FirstOrDefault();

            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }
            ViewBag.ModelState = this.ModelState;

            if (!this.CreatePassword(viewModel))
                return View(item);

            item.Password = (viewModel.Password).MakePassword();
            //models.DeleteAllOnSubmit<ResetPassword>(r => r.UID == item.UID);
            models.SubmitChanges();

            await HttpContext.SignOnAsync(item);

            return Redirect(this.ProcessLogin(item));

        }


    }
}