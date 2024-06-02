using System;
using System.Collections.Generic;
using System.Data;

using System.IO;
using System.IO.Compression;
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
using Microsoft.AspNetCore.Mvc.Rendering;

using CommonLib.DataAccess;

using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc.Filters;
using WebHome.Properties;
using System.Net.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Http;
using CommonLib.Core.Utility;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Newtonsoft.Json.Linq;
using System.Text.Json.Nodes;
using DocumentFormat.OpenXml.Spreadsheet;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using LineMessagingAPISDK.Models;

namespace WebHome.Controllers
{
    [Authorize]
    public class LearnerActivityController : ActivityBaseController
    {
        public LearnerActivityController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

        // GET: MainActivity
        [Authorize]
        public ActionResult Main()
        {
            ViewEngineResult viewResult = CheckView("Index");
            return CheckLanguageRoute() ?? View(viewResult.ViewName);
        }

        [HttpPost]
        [Authorize]
        public async Task<ActionResult> UpdateProfileImageAsync([FromBody]LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null || !(viewModel.DataContent?.Length > 0))
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            var idx = viewModel.DataContent.IndexOf(',');
            if (!(idx > 0))
            {
                return Json(new { result = false, message = "請選擇圖像檔!!" });
            }


            String storePath = Path.Combine(FileLogger.Logger.LogDailyPath, Guid.NewGuid().ToString() + ".dat");
            System.IO.File.WriteAllBytes(storePath, Convert.FromBase64String(viewModel.DataContent.Substring(idx + 1)));

            item = item.LoadInstance(models);
            if (item.Attachment == null)
            {
                item.Attachment = new Attachment
                {

                };
            }

            item.Attachment.StoredPath = storePath;
            models.SubmitChanges();

            return Json(new { result = true, pictureID = item.PictureID });
        }

        [HttpPost]
        [Authorize]
        public async Task<ActionResult> CommitUserNameAsync([FromBody] LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName == null)
            {
                return Json(new { result = false, message = "請輸入暱稱!!" });
            }

            item = item.LoadInstance(models);
            item.UserName = viewModel.UserName;
            models.SubmitChanges();

            return Json(new { result = true });
        }

        [HttpPost]
        [Authorize]
        public async Task<ActionResult> CommitCarrierNoAsync([FromBody] LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            viewModel.CarrierNo = viewModel.CarrierNo.GetEfficientString();
            if (viewModel.CarrierNo == null || !Regex.IsMatch(viewModel.CarrierNo, "^/[A-Z0-9+-\\.]{7}$"))
            {
                return Json(new { result = false, message = "請輸入正確手機載具條碼!!" });
            }

            item = item.LoadInstance(models);
            item.UserProfileExtension.CarrierNo = viewModel.CarrierNo;
            models.SubmitChanges();

            return Json(new { result = true });
        }

        [HttpPost]
        [Authorize]
        public async Task<ActionResult> CommitPasswordAsync([FromBody] PasswordViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            if (!this.CreatePassword(viewModel))
            {
                return Json(new { result = false, message = "密碼設定錯誤!!" });
            }


            item = item.LoadInstance(models);
            item.Password = (viewModel.Password).MakePassword();
            item.ResetPassword.Clear();
            models.SubmitChanges();

            var viewResult = CheckView("PasswordCommitted");
            return View(viewResult.ViewName, item);
        }

        [HttpPost]
        [Authorize]
        public async Task<ActionResult> UnbindLineAsync([FromBody] LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            item = item.LoadInstance(models);
            item.UserProfileExtension.LineID = null;
            models.SubmitChanges();

            return Json(new { result = true });
        }


        [HttpPost]
        [Authorize]
        public async Task<ActionResult> CommitUserProfileAsync([FromBody] JsonObject viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            String itemName = ((String)viewModel["ItemName"]).GetEfficientString();
            if (itemName == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }


            //viewModel.UserName = viewModel.UserName.GetEfficientString();
            //if (viewModel.UserName == null)
            //{
            //    return Json(new { result = false, message = "請輸入暱稱!!" });
            //}

            //item = item.LoadInstance(models);
            //item.UserName = viewModel.UserName;
            //models.SubmitChanges();

            return Json(new { result = true });
        }

        [HttpPost]
        [Authorize]
        public async Task<ActionResult> ValidateEmailAsync([FromBody] LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            viewModel.Email = viewModel.Email.GetEfficientString();
            if (viewModel.Email == null || !viewModel.Email.IsEmail())
            {
                return Json(new { result = false, message = "請確認您的電子郵件格式正確！" });
            }

            if (models.GetTable<UserProfile>()
                .Where(u => u.UID != item.UID)
                .Any(u => u.PID == viewModel.Email))
            {
                return Json(new { result = false, message = "此電子郵件已被註冊使用！" });
            }

            return View("~/Views/LearnerActivity/ValidateEmail.cshtml");
        }

        [HttpPost]
        [Authorize]
        public async Task<ActionResult> ForgetPasswordAsync([FromBody] LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile profile = await HttpContext.GetUserAsync();

            if (profile == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            viewModel.Email = viewModel.Email.GetEfficientString();
            if (viewModel.Email == null || !viewModel.Email.IsEmail())
            {
                return Json(new { result = false, message = "請輸入正確Email!!" });
            }

            if (profile.PID != viewModel.Email)
            {
                return Json(new { result = false, message = "您提供的電子郵件信箱資料不存在!!" });
            }

            profile = profile.LoadInstance(models);
            profile.UserProfileExtension.PIN = BusinessExtensions.CreatePIN();
            profile.UserProfileExtension.PINExpiration = DateTime.Now.AddMinutes(10);
            models.SubmitChanges();

            var viewResult = CheckView("CheckOTP");
            return View(viewResult.ViewName, profile);

        }

        [HttpPost]
        [Authorize]
        public async Task<ActionResult> ForgetPasswordPageAsync([FromBody] LearnerViewModel viewModel)
        {
            var result = await ForgetPasswordAsync(viewModel);
            if(result is ViewResult)
            {
                return Json(new { result = true });
            }
            return result;
        }

        public async Task<ActionResult> CheckOTPByPageAsync()
        {
            UserProfile profile = await HttpContext.GetUserAsync();

            if (profile == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }
            profile = profile.LoadInstance(models);

            var viewResult = CheckView("CheckOTPByPage");
            return View(viewResult.ViewName, profile);

        }

        [Authorize]
        public async Task<ActionResult> SendOTPAsync()
        {
            UserProfile profile = await HttpContext.GetUserAsync();

            if (profile == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            profile = profile.LoadInstance(models);
            return View("~/Views/LearnerActivity/SendOTP.cshtml", profile);

        }

        [HttpPost]
        [Authorize]
        public async Task<ActionResult> ValidatePINAsync([FromBody] LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile profile = await HttpContext.GetUserAsync();

            if (profile == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            viewModel.PIN = viewModel.PIN.GetEfficientString();
            if (viewModel.PIN == null || viewModel.PIN.Length < 4)
            {
                return Json(new { result = false, message = "請輸入動態密碼!!" });
            }

            profile = profile.LoadInstance(models);
            if (profile.UserProfileExtension.PINExpiration < DateTime.Now)
            {
                return Json(new { result = false, message = "動態密碼過期!!" });
            }

            if (profile.UserProfileExtension.PIN != viewModel.PIN)
            {
                return Json(new { result = false, message = "動態密碼錯誤!!" });
            }

            models.ExecuteCommand("delete ResetPassword where UID = {0}", profile.UID);
            profile.ResetPassword
                .Add(new ResetPassword
                {
                    ResetID = Guid.NewGuid(),
                });
            models.SubmitChanges();

            var viewResult = CheckView("UpdatePassword");
            return View(viewResult.ViewName, profile);

        }

        [AllowAnonymous]
        public ActionResult CommitEmail()
        {
            if(!Request.QueryString.HasValue)
            {
                return NotFound();
            }

            LearnerViewModel viewModel = JsonConvert.DeserializeObject<LearnerViewModel>(Request.QueryString.Value[1..].UrlDecodeBase64String().DecryptKey());

            if (viewModel.TimeTicks < DateTime.Now.Ticks)
            {
                return NotFound();
            }

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();

            if (item == null)
            {
                return NotFound();
            }

            viewModel.Email = viewModel.Email.GetEfficientString();
            if (viewModel.Email == null || !viewModel.Email.IsEmail())
            {
                return NotFound();
            }

            if (models.GetTable<UserProfile>()
                .Where(u => u.UID != item.UID)
                .Any(u => u.PID == viewModel.Email))
            {
                return NotFound();
            }

            item.PID = viewModel.Email;
            models.SubmitChanges();

            var viewResult = CheckView("EmailAuthResult");
            return View(viewResult.ViewName, item);
        }

        [HttpPost]
        public async Task<ActionResult> ShowLessonInfoAsync([FromBody] LessonTimeViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(viewModel.KeyID!=null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            UserProfile profile = await HttpContext.GetUserAsync();

            var item = models.GetTable<LessonTime>().Where(l=>l.LessonID==viewModel.LessonID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            var viewResult = CheckView("LessonInfo");
            return View(viewResult.ViewName, item);

        }

        [HttpPost]
        public async Task<ActionResult> ShowPaymentInfoAsync([FromBody] PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.PaymentID = viewModel.DecryptKeyValue();
            }

            UserProfile profile = await HttpContext.GetUserAsync();

            var item = models.GetTable<Payment>().Where(l => l.PaymentID == viewModel.PaymentID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            var viewResult = CheckView("PopupPaymentInfo");
            return View(viewResult.ViewName, item);

        }

        [AllowAnonymous]
        public async Task<ActionResult> SignOnAsync(LoginViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            UserProfile item = models.GetTable<UserProfile>().Where(l => l.UID == viewModel.UID).FirstOrDefault();
            item ??= viewModel.ValiateLogin(models, ModelState);

            if (item == null)
            {
                ViewBag.ModelState = ModelState;
                var viewResult = CheckView("Login");
                return View(viewResult.ViewName, item);
            }

            await HttpContext.SignOnAsync(item, viewModel.RememberMe);
            return Main();

        }

    }
}