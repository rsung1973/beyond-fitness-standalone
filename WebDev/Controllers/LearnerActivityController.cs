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
using WebHome.Helper.MessageOperation;
using WebHome.Helper.BusinessOperation;

namespace WebHome.Controllers
{
    [Authorize]
    public class LearnerActivityController : ActivityBaseController
    {
        public LearnerActivityController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

        // GET: MainActivity
        public ActionResult Main()
        {
            ViewEngineResult viewResult = CheckView("Index");
            return CheckLanguageRoute() ?? View(viewResult.ViewName);
        }

        [HttpPost]
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

            var viewResult = CheckView("CheckOTP");
            return View(viewResult.ViewName, profile);

        }

        [HttpPost]
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

            ViewEngineResult viewResult;

            switch(viewModel.UrlAction)
            {
                case "SignCourseContract":
                    viewResult = CheckView("NextStep");
                    break;

                default:
                    models.ExecuteCommand("delete ResetPassword where UID = {0}", profile.UID);
                    profile.ResetPassword
                        .Add(new ResetPassword
                        {
                            ResetID = Guid.NewGuid(),
                        });
                    models.SubmitChanges();
                    viewResult = CheckView("UpdatePassword");
                    break;
            }

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

        public async Task<ActionResult> CalendarAsync(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            viewModel.DateFrom ??= DateTime.Today.FirstDayOfMonth();
            viewModel.DateTo = viewModel.DateFrom.Value.AddMonths(1);

            var profile = await HttpContext.GetUserAsync();
            viewModel.KeyID = profile.UID.EncryptKey();
            var viewResult = CheckView("Calendar");
            return View(viewResult.ViewName, profile);
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

        [AllowAnonymous]
        public ActionResult Login(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var viewResult = CheckView("Login");
            return View(viewResult.ViewName);

        }

        [AllowAnonymous]
        public ActionResult Logout(RegisterViewModel viewModel, String message = null)
        {
            this.HttpContext.Logout();
            ViewBag.Message = message;
            return Login(viewModel);
        }

        [HttpPost]
        public async Task<ActionResult> ConfirmSignatureAsync([FromBody] CourseContractViewModel viewModel, CourseContractSignatureViewModel signatureViewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();
            ViewEngineResult viewResult = null;

            if (viewModel.Agree != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意BF隱私政策、服務條款、相關使用及消費合約，即表示即日起您同意接受本合約正面及背面條款之相關約束及其責任");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }
            else if (viewModel.Booking != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意第8條服務預約之規定");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }
            else if (viewModel.Extension != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意第9條體能/健康顧問服務期間與一般展延之申請之規定");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }
            else if (viewModel.HasViewedDetails != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意產品及服務特約條款");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }
            else if (viewModel.GDPRAgree != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意個人資料告知事項暨同意書");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }
            else if (viewModel.PersonalData != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意提供各項個人資料");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }
            else if (viewModel.Understood != true)
            {
                ModelState.AddModelError("Message", "請閱讀並充分知悉和同意本告知暨同意書之內容");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }

            viewModel.SignerPIN = viewModel.SignerPIN.GetEfficientString();
            if (viewModel.SignerPIN == null)
            {
                ModelState.AddModelError("SignerPIN", "動態密碼輸入錯誤，請確認後再重新輸入");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            CourseContract item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("Message", "合約資料錯誤!!");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }

            if (item.InstallmentID.HasValue)
            {
                foreach (var c in models.GetTable<CourseContract>().Where(c => c.InstallmentID == item.InstallmentID))
                {
                    var contract = await CommitSignatureAsync(viewModel, signatureViewModel, c);
                    if (contract == null)
                    {
                        ModelState.AddModelError("Message", ModelState.ErrorMessage());
                        ViewBag.AlertError = true;
                        ViewBag.ModelState = this.ModelState;
                        return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
                    }
                }
            }
            else
            {
                item = await CommitSignatureAsync(viewModel, signatureViewModel, item);
                if (item == null)
                {
                    ModelState.AddModelError("Message", ModelState.ErrorMessage());
                    ViewBag.AlertError = true;
                    ViewBag.ModelState = this.ModelState;
                    return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
                }
            }

            String jsonData = await RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyToContractPayment.cshtml", item);
            jsonData.PushLineMessage();

            viewResult = CheckView("SignCourseContractResult");
            return View(viewResult.ViewName, item);
        }

        private async Task<CourseContract> CommitSignatureAsync(CourseContractViewModel viewModel, CourseContractSignatureViewModel signatureViewModel, CourseContract item)
        {
            var profile = await HttpContext.GetUserAsync();

            for (int i = 0; i < (signatureViewModel.SignatureCount ?? 1); i++)
            {
                String signatureName = $"{signatureViewModel.SignatureName}{i:#}";
                var sigItem = models.GetTable<CourseContractSignature>()
                    .Where(s => s.ContractID == item.ContractID)
                    .Where(s => s.UID == profile.UID)
                    .Where(s => s.SignatureName == signatureName)
                    .FirstOrDefault();

                if (sigItem == null)
                {
                    sigItem = new CourseContractSignature
                    {
                        ContractID = item.ContractID,
                        UID = profile.UID,
                        SignatureName = signatureName,
                    };
                    models.GetTable<CourseContractSignature>().InsertOnSubmit(sigItem);
                }

                sigItem.Signature = signatureViewModel.Signature;
                models.SubmitChanges();
            }

            if (item.CourseContractRevision != null)
            {
                return await viewModel.ConfirmContractServiceSignatureAsync(this, item.CourseContractRevision);
            }
            else
            {
                return await viewModel.ConfirmContractSignatureAsync(this, item);
            }
        }

        [HttpPost]
        public async Task<ActionResult> CommitSelfAssessmentAsync([FromBody] SelfAssessmentViewModel viewModel)
        {
            if (viewModel == null)
            {
                viewModel = await PrepareViewModelAsync<SelfAssessmentViewModel>(viewModel);
                ModelState.Clear();
            }
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (viewModel.CheckTerms != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意課前健康狀況自我檢視聲明書");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }
            else if (viewModel.Agree != true)
            {
                ModelState.AddModelError("Message", "請閱讀並同意個人身體健康狀況事項切結書");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }


            if (!(viewModel.SleepDuration >= 0))
            {
                ModelState.AddModelError("SleepDuration", "請填寫睡眠時間");
            }

            if (!(viewModel.WaterIntake >= 0))
            {
                ModelState.AddModelError("WaterIntake", "請填寫水分攝取");
            }

            if (!(viewModel.FatigueIndex >= 0 && viewModel.FatigueIndex <= 10))
            {
                ModelState.AddModelError("FatigueIndex", "請填寫生理疲勞");
            }

            if (!(viewModel.StressIndex >= 0 && viewModel.StressIndex <= 10))
            {
                ModelState.AddModelError("StressIndex", "請填寫心理壓力");
            }

            if (viewModel.KeyID != null)
            {
                SelfAssessmentViewModel tmpModel = JsonConvert.DeserializeObject<SelfAssessmentViewModel>(viewModel.KeyID.DecryptKey());
                viewModel.LessonID = tmpModel.LessonID;
                viewModel.RegisterID = tmpModel.RegisterID;
            }

            var lessonItem = models.GetTable<LessonTime>().Where(l=>l.LessonID== viewModel.LessonID).FirstOrDefault();
            if(lessonItem == null || !viewModel.RegisterID.HasValue)
            {
                ModelState.AddModelError("Message", "資料錯誤");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }

            LessonFeedBack item = models.GetTable<LessonFeedBack>()
                .Where(c => c.LessonID == viewModel.LessonID)
                .Where(c => c.RegisterID == viewModel.RegisterID)
                .FirstOrDefault();

            if (item == null)
            {
                item = new LessonFeedBack
                {
                    LessonID = viewModel.LessonID.Value,
                    RegisterID = viewModel.RegisterID.Value,
                };
                models.GetTable<LessonFeedBack>()
                    .InsertOnSubmit(item);
                models.SubmitChanges();
            }
            else
            {
                models.ExecuteCommand(@"DELETE FROM BG.LessonSelfAssessment
                            WHERE   LessonID = {0} and RegisterID = {1}", item.LessonID, item.RegisterID);
            }

            item.LessonSelfAssessment.Add(new LessonSelfAssessment 
            {
                Assessment = "SleepDuration",
                Score = viewModel.SleepDuration,
            });

            item.LessonSelfAssessment.Add(new LessonSelfAssessment
            {
                Assessment = "WaterIntake",
                Score = viewModel.WaterIntake,
            });

            item.LessonSelfAssessment.Add(new LessonSelfAssessment
            {
                Assessment = "FatigueIndex",
                Score = viewModel.FatigueIndex,
            });

            item.LessonSelfAssessment.Add(new LessonSelfAssessment
            {
                Assessment = "StressIndex",
                Score = viewModel.StressIndex,
            });

            item.LessonSelfAssessment.Add(new LessonSelfAssessment
            {
                Assessment = "SupplementaryStatement",
                Answer = viewModel.SupplementaryStatement.GetEfficientString(),
            });

            item.CommitAssessment = DateTime.Now;

            lessonItem.LessonPlan.CommitAttendance = DateTime.Now;
            lessonItem.LessonPlan.CommitAttendanceIP = HttpContext.Connection.RemoteIpAddress?.ToString();

            models.SubmitChanges();

            item.AwardLessonMissionBonus(models, CampaignMission.CampaignMissionType.SelfAssessment);

            return Json(new { result = true });
        }

        [HttpPost]
        public async Task<ActionResult> CommitSurveyAnswerAsync([FromBody] FeedbackSurveyViewModel viewModel)
        {
            if (viewModel == null)
            {
                viewModel = await PrepareViewModelAsync<FeedbackSurveyViewModel>(viewModel);
                ModelState.Clear();
            }
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (viewModel.KeyID != null)
            {
                FeedbackSurveyViewModel tmpModel = JsonConvert.DeserializeObject<FeedbackSurveyViewModel>(viewModel.KeyID.DecryptKey());
                viewModel.LessonID = tmpModel.LessonID;
                viewModel.RegisterID = tmpModel.RegisterID;
            }

            var lessonItem = models.GetTable<LessonTime>().Where(l=>l.LessonID==viewModel.LessonID).FirstOrDefault();

            if (lessonItem == null || !viewModel.RegisterID.HasValue)
            {
                ModelState.AddModelError("Message", "資料錯誤");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }

            IQueryable<FeedbackSurveyType> questItems = models.GetTable<FeedbackSurveyType>().Where(s => false);

            if (lessonItem.IsPTSession())
            {
                questItems = models.GetTable<FeedbackSurveyType>().Where(s => s.ClassType == (int)Naming.LessonPriceStatus.一般課程);
            }
            else if (lessonItem.IsPISession())
            {
                questItems = models.GetTable<FeedbackSurveyType>().Where(s => s.ClassType == (int)Naming.LessonPriceStatus.自主訓練);
            }
            if (lessonItem.IsSRSession())
            {
                questItems = models.GetTable<FeedbackSurveyType>().Where(s => s.ClassType == (int)Naming.LessonPriceStatus.運動恢復課程);
            }

            List<LessonFeedbackSurvey> surveyItems = new List<LessonFeedbackSurvey>();
            if (questItems.Any())
            {
                foreach (var quest in questItems)
                {
                    var ansItem = viewModel.Answer?.Where(a => a.Name == quest.QuestionNo).FirstOrDefault();
                    if (ansItem == null)
                    {
                        if (quest.FeedbackSurvey.RequiredLevel == (int)FeedbackSurvey.RequiredLevelDefinition.Required)
                        {
                            ModelState.AddModelError("Message", $"請回答{quest.QuestionNo}");
                        }
                    }
                    else
                    {
                        LessonFeedbackSurvey survey = new LessonFeedbackSurvey
                        {
                            LessonID = lessonItem.LessonID,
                            RegisterID = viewModel.RegisterID.Value,
                            QuestionID = quest.QuestionID,
                        };

                        if (quest.FeedbackSurvey.QuestionType == (int)FeedbackSurvey.QuestionTypeDefinition.SingleChoice)
                        {
                            if (int.TryParse(ansItem.Value, out int score))
                            {
                                survey.Score = score;
                                surveyItems.Add(survey);
                            }
                            else
                            {
                                ModelState.AddModelError("Message", $"請回答{quest.QuestionNo}");
                            }
                        }
                        else /*if (quest.FeedbackSurvey.QuestionType == (int)FeedbackSurvey.QuestionTypeDefinition.QandA)*/
                        {
                            survey.Answer = ansItem.Value.GetEfficientString();
                            surveyItems.Add(survey);
                        }
                    }
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }

            LessonFeedBack item = models.GetTable<LessonFeedBack>()
                .Where(c => c.LessonID == viewModel.LessonID)
                .Where(c => c.RegisterID == viewModel.RegisterID)
                .FirstOrDefault();

            if (item == null)
            {
                item = new LessonFeedBack
                {
                    LessonID = viewModel.LessonID.Value,
                    RegisterID = viewModel.RegisterID.Value,
                };
                models.GetTable<LessonFeedBack>()
                    .InsertOnSubmit(item);
                models.SubmitChanges();
            }
            else
            {
                models.ExecuteCommand(@"DELETE FROM BG.LessonFeedbackSurvey
                            WHERE   LessonID = {0} and RegisterID = {1}", item.LessonID, item.RegisterID);
            }

            item.LessonFeedbackSurvey.AddRange(surveyItems);
            item.FeedBackDate = DateTime.Now;

            models.SubmitChanges();

            item.AwardLessonMissionBonus(models, CampaignMission.CampaignMissionType.FeedbackSurvey);

            return Json(new { result = true });
        }

        public ActionResult BonusSettlement(LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var viewResult = CheckView("BonusSettlement");
            return View(viewResult.ViewName);

        }

        [HttpPost]
        public async Task<ActionResult> ExchangeBonusPointAsync([FromBody] AwardQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel?.KeyID != null) 
            {
                viewModel.ItemID = viewModel.DecryptKeyValue();
            }

            var profile = await HttpContext.GetUserAsync();

            var item = models.GetTable<BonusAwardingItem>().Where(i => i.ItemID == viewModel.ItemID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "兌換商品錯誤!!" });
            }

            var account = profile.UID.PromptDepositAccount(models)?.CommitBonusSettlement(models);

            if (!(account?.DepositPoint >= item.PointValue))
            {
                return Json(new { result = false, message = "累積點數不足!!" });
            }

            viewModel.WriteoffCode = viewModel.WriteoffCode.GetEfficientString();
            int? recipientID = null;
            if (item.BonusAwardingLesson != null)
            {
                viewModel.ActorID = profile.UID;

                if (item.BonusAwardingIndication != null && item.BonusAwardingIndication.Indication == "AwardingLessonGift")
                {
                    var users = models.GetTable<UserProfile>()
                        .Where(u => u.UID != profile.UID)
                        .Where(u => u.LevelID != (int)Naming.MemberStatusDefinition.Deleted)
                        .Where(u => u.LevelID != (int)Naming.MemberStatusDefinition.Anonymous)
                        .Where(l => l.Phone == viewModel.WriteoffCode)
                        .FilterByLearner(models)
                        .Where(u => u.UserProfileExtension != null)
                        .Where(u => !u.UserProfileExtension.CurrentTrial.HasValue);

                    int count = users.Count();

                    if (count == 0)
                    {
                        ModelState.AddModelError("WriteoffCode", "受贈會員資料錯誤，請確認後再重新輸入");
                    }
                    else if (count > 1)
                    {
                        ModelState.AddModelError("WriteoffCode", "受贈學員手機號碼重複，請連絡您的體能顧問");
                    }
                    else
                    {
                        recipientID = users.First().UID;
                    }
                }
            }
            else
            {
                var coach = models.PromptEffectiveCoach(models.GetTable<UserProfile>().Where(l => l.Phone == viewModel.WriteoffCode)).FirstOrDefault();
                if (coach == null)
                {
                    ModelState.AddModelError("WriteoffCode", "兌換核銷密碼欄位資料錯誤，請確認後再重新輸入");
                }
                else
                {
                    viewModel.ActorID = coach.CoachID;
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }

            var txnItem = new BonusTransaction
            {
                UID = account.UID,
                TransactionDate = DateTime.Now,
                TransactionPoint = -item.PointValue,
                Reason = $"兌換{item.ItemName}",
                LearnerAward = new LearnerAward
                {
                    UID = profile.UID,
                    AwardDate = DateTime.Now,
                    ItemID = item.ItemID,
                    ActorID = viewModel.ActorID.Value,
                },
            };

            models.GetTable<BonusTransaction>().InsertOnSubmit(txnItem);

            var award = txnItem.LearnerAward;
            ///兌換課程
            ///
            if (item.BonusAwardingLesson != null)
            {
                var lesson = models.GetTable<RegisterLesson>().Where(r => r.UID == profile.UID)
                    .Join(models.GetTable<RegisterLessonContract>(), r => r.RegisterID, c => c.RegisterID, (r, c) => r)
                    .OrderByDescending(r => r.RegisterID).FirstOrDefault();

                if (item.BonusAwardingIndication != null && item.BonusAwardingIndication.Indication == "AwardingLessonGift")
                {
                    var giftLesson = new RegisterLesson
                    {
                        RegisterDate = DateTime.Now,
                        GroupingMemberCount = 1,
                        ClassLevel = item.BonusAwardingLesson.PriceID,
                        Lessons = 1,
                        UID = recipientID.Value,
                        AdvisorID = lesson?.RegisterLessonContract.CourseContract.FitnessConsultant,
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
                        AdvisorID = lesson?.AdvisorID,
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
            return Json(new { result = true });

        }


    }
}