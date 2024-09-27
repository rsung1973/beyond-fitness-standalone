using CommonLib.Core.Utility;
using CommonLib.Utility;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Newtonsoft.Json;
using System.Data;
using System.Text.Json.Nodes;
using System.Text.RegularExpressions;
using WebHome.Helper;
using WebHome.Helper.BusinessOperation;
using WebHome.Helper.MessageOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;

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

        [AllowAnonymous, HttpPost]
        public async Task<ActionResult> CommitPasswordAsync([FromBody] PasswordViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            UserProfile profile = await HttpContext.GetUserAsync();

            if (profile == null)
            {
                profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            }
            else
            {
                profile = profile.LoadInstance(models);
            }

            if (profile == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            if (!this.CreatePassword(viewModel))
            {
                return Json(new { result = false, message = "密碼設定錯誤!!" });
            }


            profile.Password = (viewModel.Password).MakePassword();
            profile.ResetPassword.Clear();
            models.SubmitChanges();

            var viewResult = CheckView("PasswordCommitted");
            return View(viewResult.ViewName, profile);
        }

        [AllowAnonymous, HttpPost]
        public async Task<ActionResult> CommitRegistrationPasswordAsync([FromBody] PasswordViewModel viewModel)
        {
            var result = await CommitPasswordAsync(viewModel);
            if (result is not ViewResult)
            {
                return result;
            }

            UserProfile profile = ((ViewResult)result).Model as UserProfile;
            var viewResult = CheckView("RegistrationCommitted");
            return View(viewResult.ViewName, profile);
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

            viewModel.Email = viewModel.Email.GetEfficientString();
            if (viewModel.Email == null || !viewModel.Email.IsEmail())
            {
                return Json(new { result = false, message = "Email格式錯誤[E0001]，請重新確認！" });
            }

            if (profile == null)
            {
                profile = models.GetTable<UserProfile>().Where(u => u.PID == viewModel.Email).FirstOrDefault();
            }

            if (profile == null)
            {
                return Json(new { result = false, message = "輸入資料錯誤[XA001]，請重新確認！" });
            }

            if (profile.PID != viewModel.Email)
            {
                return Json(new { result = false, message = "輸入資料錯誤[XA001]，請重新確認！" });
            }

            if (profile.LevelID == (int)Naming.MemberStatusDefinition.ReadyToRegister)
            {
                return Json(new { result = false, message = "帳號未啟用[XA008]，請聯繫您的專屬顧問！" });
            }

            if (profile.LevelID == (int)Naming.MemberStatusDefinition.Deleted)
            {
                return Json(new { result = false, message = "帳號已停用[XA003]，請聯繫您的專屬顧問！" });
            }

            if (profile.LevelID == (int)Naming.MemberStatusDefinition.Anonymous)
            {
                return Json(new { result = false, message = "帳號已停用[XA004]，請聯繫您的專屬顧問！" });
            }

            var viewResult = CheckView("CheckOTP");
            return View(viewResult.ViewName, profile);

        }

        [AllowAnonymous]
        [HttpPost]
        public async Task<ActionResult> ForgetPasswordPageAsync([FromBody] LearnerViewModel viewModel)
        {
            var result = await ForgetPasswordAsync(viewModel);
            if(result is ViewResult)
            {
                UserProfile profile = ((ViewResult)result).Model as UserProfile;
                return Json(new { result = true, keyID = profile.UID.EncryptKey() });
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

        [AllowAnonymous, HttpPost]
        public async Task<ActionResult> SendOTPAsync([FromBody] LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            UserProfile profile = await HttpContext.GetUserAsync();

            if (profile == null)
            {
                profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            }
            else
            {
                profile = profile.LoadInstance(models);
            }

            if (profile == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            return View("~/Views/LearnerActivity/SendOTP.cshtml", profile);

        }

        [HttpPost]
        public async Task<ActionResult> ValidateSignerPINAsync([FromBody] CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

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

            viewModel.SignerPIN = viewModel.SignerPIN.GetEfficientString();
            if (viewModel.SignerPIN != item.CourseContractExtension.SignerPIN)
            {
                ModelState.AddModelError("SignerPIN", "動態密碼輸入錯誤，請確認後再重新輸入");
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }

            if (item.CourseContractExtension.SignerPINExpiration < DateTime.Now)
            {
                return View("~/Views/LearnerActivity/Page.zh-TW/Module/ResendSignContractOTP.cshtml", item);
            }

            ViewEngineResult viewResult;
            viewResult = CheckView("NextStep");

            return View(viewResult.ViewName);

        }

        [AllowAnonymous]
        [HttpPost]
        public async Task<ActionResult> ValidatePINAsync([FromBody] LearnerViewModel viewModel)
        {
            var profile = await CheckPINAsync(viewModel);
            if (!ModelState.IsValid)
            {
                return Json(new { result = false, message = ModelState.ErrorMessage() });
            }

            ViewEngineResult viewResult;

            models.ExecuteCommand("delete ResetPassword where UID = {0}", profile.UID);
            profile.ResetPassword
                .Add(new ResetPassword
                {
                    ResetID = Guid.NewGuid(),
                });
            models.SubmitChanges();
            viewResult = CheckView("UpdatePassword");

            return View(viewResult.ViewName, profile);

        }

        [AllowAnonymous]
        public ActionResult CommitEmail()
        {
            ViewEngineResult viewResult;

            if (!Request.QueryString.HasValue)
            {
                viewResult = CheckView("EmailAuthUnsuccess");
                return View(viewResult.ViewName);
            }

            LearnerViewModel viewModel = JsonConvert.DeserializeObject<LearnerViewModel>(Request.QueryString.Value[1..].UrlDecodeBase64String().DecryptKey());

            if (viewModel.TimeTicks < DateTime.Now.Ticks)
            {
                viewResult = CheckView("EmailAuthUnsuccess");
                return View(viewResult.ViewName);
            }

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();

            if (item == null)
            {
                viewResult = CheckView("EmailAuthUnsuccess");
                return View(viewResult.ViewName);
            }

            viewModel.Email = viewModel.Email.GetEfficientString();
            if (viewModel.Email == null || !viewModel.Email.IsEmail())
            {
                viewResult = CheckView("EmailAuthUnsuccess");
                return View(viewResult.ViewName);
            }

            if (models.GetTable<UserProfile>()
                .Where(u => u.UID != item.UID)
                .Any(u => u.PID == viewModel.Email))
            {
                viewResult = CheckView("EmailAuthUnsuccess");
                return View(viewResult.ViewName);
            }

            item.PID = viewModel.Email;
            CommitEmailCertified(item);

            viewResult = CheckView("EmailAuthResult");
            return View(viewResult.ViewName, item);
        }

        private void CommitEmailCertified(UserProfile item)
        {
            var property = models.GetTable<UserProfileProperty>()
                .Where(u => u.UID == item.UID)
                .Where(p => p.PropertyID == (int)UserProfileProperty.PropertyDefinition.ValidEmail)
                .FirstOrDefault();
            if (property == null)
            {
                property = new UserProfileProperty
                {
                    UID = item.UID,
                    PropertyID = (int)UserProfileProperty.PropertyDefinition.ValidEmail,
                };
                models.GetTable<UserProfileProperty>().InsertOnSubmit(property);
            }
            property.CommitmentDate = DateTime.Now;
            models.SubmitChanges();
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
        public ActionResult CommitToRegister(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewEngineResult viewResult;

            viewModel.MemberCode = viewModel.MemberCode.GetEfficientString();
            if (viewModel.MemberCode == null)
            {
                ModelState.AddModelError("MemberCode", "會員編號資料錯誤，請確認後再重新輸入!!");
            }

            viewModel.PID = viewModel.PID.GetEfficientString();
            if (viewModel.PID == null || viewModel.PID.Length > 48)
            {
                ModelState.AddModelError("PID", "Email長度超過[E0002]，請重新確認！");
            }
            else if (!Regex.IsMatch(viewModel.PID, "\\w+([-+.']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"))
            {
                ModelState.AddModelError("PID", "Email格式錯誤[E0001]，請重新確認！");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                viewResult = CheckView("ActivateAccount");
                return View(viewResult.ViewName);
            }

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.MemberCode == viewModel.MemberCode
                || u.UserProfileExtension.IDNo == viewModel.MemberCode).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("MemberCode", "輸入資料錯誤[XA005]，請重新確認！");
            }
            else
            {
                if (models.GetTable<UserProfile>().Any(u => u.PID == viewModel.PID && u.UID != item.UID))
                {
                    ModelState.AddModelError("PID", "輸入資料錯誤[XA006]，請重新確認！");
                }
                //else if (item.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                //{
                //    if (item.PID.IsEmail())
                //    {
                //        ModelState.AddModelError("PID", "輸入資料錯誤[XA006]，請重新確認！");
                //    }
                //}
                else if (item.LevelID == (int)Naming.MemberStatusDefinition.Deleted)
                {
                    ModelState.AddModelError("PID", "帳號已停用[XA003]，請聯繫您的專屬顧問！");
                }
                else if (item.LevelID == (int)Naming.MemberStatusDefinition.Anonymous)
                {
                    ModelState.AddModelError("PID", "帳號已停用[XA004]，請聯繫您的專屬顧問！");
                }
            }

            //if (item.UserProfileExtension.CurrentTrial == 1 /*|| !item.IsLearner()*/)
            //{
            //    ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
            //}

            //var pwd = (viewModel.Password).MakePassword();
            //if (item.LevelID != (int)Naming.MemberStatusDefinition.ReadyToRegister)
            //{
            //    if (item.Password != pwd)
            //    {
            //        ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
            //    }
            //}
            //else if (pwd == null)
            //{
            //    ModelState.AddModelError("PID", "您輸入的資料錯誤，請確認後再重新輸入!!");
            //}
            //else
            //{
            //    item.Password = pwd;
            //}

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                viewResult = CheckView("ActivateAccount");
                return View(viewResult.ViewName, item);
            }

            if (!item.PID.IsEmail())
            {
                item.PID = viewModel.PID;
                models.SubmitChanges();
            }

            viewResult = CheckView("CheckRegistrationOTP");
            return View(viewResult.ViewName, item);

        }

        [AllowAnonymous]
        public ActionResult Login(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            this.HttpContext.Logout();

            var viewResult = CheckView("Login");
            return CheckLanguageRoute() ?? View(viewResult.ViewName);

        }

        [AllowAnonymous]
        public async Task<ActionResult> ActivateAccountAsync(RegisterViewModel viewModel)
        {
            await Request.SaveAsAsync(System.IO.Path.Combine(FileLogger.Logger.LogDailyPath, $"{Guid.NewGuid()}.txt"));
            ViewBag.ViewModel = viewModel;
            var viewResult = CheckView("ActivateAccount");
            return CheckLanguageRoute() ?? View(viewResult.ViewName);

        }

        [AllowAnonymous]
        public ActionResult Logout(RegisterViewModel viewModel, String message = null)
        {
            ViewBag.Message = message;
            return Login(viewModel);
        }

        [HttpPost]
        public async Task<ActionResult> ValidateSignatureAsync([FromBody] CourseContractViewModel viewModel, [FromBody] CourseContractSignatureViewModel signatureViewModel)
        {
            if (viewModel == null)
            {
                viewModel = PrepareViewModel<CourseContractViewModel>(viewModel);
                ModelState.Clear();
            }

            if (signatureViewModel == null)
            {
                signatureViewModel = PrepareViewModel<CourseContractSignatureViewModel>(signatureViewModel);
                ModelState.Clear();
            }


            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

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

            return Json(new { result = true });
        }


        [HttpPost]
        public async Task<ActionResult> ConfirmSignatureAsync([FromBody] CourseContractViewModel viewModel, [FromBody] CourseContractSignatureViewModel signatureViewModel)
        {
            if (viewModel == null)
            {
                viewModel = PrepareViewModel<CourseContractViewModel>(viewModel);
                ModelState.Clear();
            }

            if (signatureViewModel == null)
            {
                signatureViewModel = PrepareViewModel<CourseContractSignatureViewModel>(signatureViewModel);
                ModelState.Clear();
            }


            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();
            //ViewEngineResult viewResult = null;

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

            return Json(new { result = true });
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
                viewModel = PrepareViewModel<SelfAssessmentViewModel>(viewModel);
                ModelState.Clear();
            }

            var profile = await HttpContext.GetUserAsync();

            var item = viewModel.CommitSelfAssessment(this, out bool updateOnly);

            if (!ModelState.IsValid)
            {
                ViewBag.AlertError = true;
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/LearnerActivity/Shared/ReportInputError.cshtml");
            }

            var txn = item.AwardLessonMissionBonus(models, CampaignMission.CampaignMissionType.SelfAssessment);

            return Json(new { result = true, point = txn?.TransactionPoint });
        }

        [HttpPost]
        public async Task<ActionResult> CommitSurveyAnswerAsync([FromBody] FeedbackSurveyViewModel viewModel)
        {
            if (viewModel == null)
            {
                viewModel = PrepareViewModel<FeedbackSurveyViewModel>(viewModel);
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

            if(!lessonItem.LessonPlan.CommitAttendance.HasValue)
            {
                lessonItem.LessonPlan.CommitAttendance = DateTime.Now;
                lessonItem.LessonPlan.CommitAttendanceIP = HttpContext.Connection.RemoteIpAddress?.ToString();
            }

            models.SubmitChanges();

            BonusTransaction txn = null;
            StageProgress current = models.PromptCurrentStage();
            if (current != null)
            {
                if (lessonItem.ClassTime >= current.StartDate && lessonItem.ClassTime < current.EndExclusiveDate)
                {
                    txn = item.AwardLessonMissionBonus(models, CampaignMission.CampaignMissionType.FeedbackSurvey);
                }
            }

            return Json(new { result = true, point = txn?.TransactionPoint });
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

                var monthStart = DateTime.Today.FirstDayOfMonth();
                var awardingLessonsThisMonth =
                        models.GetTable<BonusTransaction>()
                            .Where(t => t.UID == profile.UID)
                            .Where(t => t.TransactionDate >= monthStart)
                            .Where(t => t.LearnerAward.ItemID == item.ItemID);
                if (awardingLessonsThisMonth.Count() >= 2)
                {
                    return Json(new { result = false, message = "本月可兌換課程堂數2堂已用完!!" });
                }
            }
            else
            {
                var coach = models.PromptEffectiveCoach(models.GetTable<UserProfile>().Where(l => l.Phone == viewModel.WriteoffCode)).FirstOrDefault();
                if (coach == null)
                {
                    ModelState.AddModelError("WriteoffCode", "兌換核銷碼錯誤，請確認後再重新輸入");
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
                        GroupingLesson = new GroupingLesson { },
                        Expiration = DateTime.Today.AddDays(181),
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
                        GroupingLesson = new GroupingLesson { },
                        Expiration = DateTime.Today.AddDays(181),
                    };
                    award.AwardingLesson = new AwardingLesson
                    {
                        RegisterLesson = awardLesson
                    };
                    models.GetTable<RegisterLesson>().InsertOnSubmit(awardLesson);
                }
            }

            models.SubmitChanges();
            account.CommitBonusSettlement(models);

            return Json(new { result = true });

        }

        [AllowAnonymous]
        [HttpPost]
        public ActionResult CheckOTP(LoginViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            var viewResult = CheckView("CheckOTP");
            return View(viewResult.ViewName, item);
        }

        [AllowAnonymous]
        [HttpPost]
        public async Task<ActionResult> ValidateRegistrationPINAsync([FromBody] LearnerViewModel viewModel)
        {
            var profile = await CheckPINAsync(viewModel);
            if (!ModelState.IsValid)
            {
                return Json(new { result = false, message = ModelState.ErrorMessage() });
            }

            if (viewModel.LineID != null) 
            {
                if (models.GetTable<UserProfileExtension>()
                        .Where(u => u.LineID == viewModel.LineID)
                        .Where(u => u.UID != profile.UID)
                        .Any())
                {
                    return Json(new { result = false, message = "帳號已綁定其他帳號[XA007]，請聯繫您的專屬顧問！" });
                }
                else
                {
                    profile.UserProfileExtension.LineID = viewModel.LineID;
                }
            }

            profile.LevelID = (int)Naming.MemberStatusDefinition.Checked;
            models.SubmitChanges();

            CommitEmailCertified(profile);

            await HttpContext.SignOnAsync(profile);

            ViewEngineResult viewResult;

            if (viewModel.LineID != null)
            {
                viewResult = CheckView("RegistrationCommitted");
            }
            else
            {
                viewResult = CheckView("UpdatePassword");
            }

            return View(viewResult.ViewName, profile);
        }

        protected async Task<UserProfile> CheckPINAsync(LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            UserProfile profile = await HttpContext.GetUserAsync();

            if (profile == null)
            {
                profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            }
            else
            {
                profile = profile.LoadInstance(models);
            }

            if (profile == null)
            {
                ModelState.AddModelError("Message", "輸入資料錯誤[XA001]，請重新確認！");
                return null;
            }

            viewModel.PIN = viewModel.PIN.GetEfficientString();
            if (viewModel.PIN == null || viewModel.PIN.Length < 4)
            {
                ModelState.AddModelError("Message", "請輸入動態密碼!!");
            }
            else if (profile.UserProfileExtension.PINExpiration < DateTime.Now)
            {
                ModelState.AddModelError("Message", "動態密碼過期!!");
            }
            else if (profile.UserProfileExtension.PIN != viewModel.PIN)
            {
                ModelState.AddModelError("Message", "動態密碼錯誤!!");
            }

            return profile;
        }

        [AllowAnonymous]
        public ActionResult Error()
        {
            ViewEngineResult viewResult;

            viewResult = CheckView("SystemUnderMaintenance");
            return CheckLanguageRoute() ?? View(viewResult.ViewName);
        }

        public async Task<ActionResult> RebuildBonusSettlement()
        {
            var profile = await HttpContext.GetUserAsync();
            var account = profile?.UID.PromptDepositAccount(models)?.CommitBonusSettlement(models, true);
            return Json(new { account.DepositPoint });
        }

        public async Task<ActionResult> TransferBonusCreditNewAsync(AwardQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            return View("~/Views/LearnerActivity/TransferBonusCreditNew.cshtml");
        }

        public async Task<ActionResult> AppraisePlayerLevelAsync(AwardQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            return View("~/Views/LearnerActivity/AppraisePlayerLevel.cshtml");
        }

        [AllowAnonymous]
        public async Task<ActionResult> NotifyToTakeSelfAssessmentAsync()
        {
            DateTime now = DateTime.Now;
            DateTime start = new DateTime(now.Year, now.Month, now.Day, now.Hour, 0, 0);
            start = start.AddHours(2);

            var items = models.GetTable<LessonTime>()
                    .Where(f => f.RegisterLesson.LessonPriceType.LessonMissionBonusAwardingItem.Any(b => b.MissionID == (int)CampaignMission.CampaignMissionType.SelfAssessment))
                    .Where(l => l.ClassTime >= start)
                    .Where(l => l.ClassTime < start.AddHours(1));
                    //.Where(l => !l.LessonFeedBack
                    //                .Where(f => f.Status == (int)Naming.IncommingMessageStatus.已通知
                    //                    || f.CommitAssessment.HasValue)
                    //                .Any());

            foreach (var item in items) 
            {
                await item.LineNotifyLessonSelfAssessmentAsync(this);
            }

            return Json(new { result = true, done = now });
        }

        [AllowAnonymous]
        public ActionResult LineAuth(RegisterViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel = JsonConvert.DeserializeObject<RegisterViewModel>(viewModel.KeyID.DecryptKey());
            }
            Url.Action("test");
            ViewBag.ViewModel = viewModel;
            return View("~/Views/LearnerActivity//LineAuth.cshtml");
        }

        [HttpPost]
        public ActionResult CheckSelfAssessment([FromBody] SelfAssessmentViewModel viewModel)
        {
            if (viewModel == null)
            {
                viewModel = PrepareViewModel<SelfAssessmentViewModel>(viewModel);
                ModelState.Clear();
            }

            if (viewModel.KeyID != null)
            {
                SelfAssessmentViewModel tmpModel = JsonConvert.DeserializeObject<SelfAssessmentViewModel>(viewModel.KeyID.DecryptKey());
                viewModel.LessonID = tmpModel.LessonID;
                viewModel.RegisterID = tmpModel.RegisterID;
            }

            var item = models.GetTable<LessonFeedBack>()
                        .Where(l => l.LessonID == viewModel.LessonID)
                        .Where(l => l.RegisterID == viewModel.RegisterID)
                        .FirstOrDefault();

            return Json(new { result = true, done = item?.CommitAssessment.HasValue == true });

        }

        [AllowAnonymous]
        public async Task<ActionResult> LineToTakeSelfAssessmentAsync(RegisterViewModel viewModel, LessonTimeViewModel lessonViewModel)
        {
            ActionResult CheckResult(UserProfile profile)
            {
                var feedback = models.GetTable<LessonFeedBack>()
                                .Where(f => f.LessonID == lessonViewModel.LessonID)
                                .Where(f => f.RegisterLesson.UID == profile.UID)
                                .FirstOrDefault();

                if (feedback != null)
                {
                    if (feedback.CommitAssessment.HasValue)
                    {
                        return RedirectToAction("CourseItem", "LearnerActivity", new { KeyID = feedback.LessonID.EncryptKey(), from = Url.Action("ContactBook", "LearnerActivity") });
                    }
                    else
                    {
                        return RedirectToAction("TakeSelfAssessment", "LearnerActivity", new { KeyID = feedback.LessonID.EncryptKey(), from = Url.Action("Events", "LearnerActivity") });
                    }
                }
                else
                {
                    return RedirectToAction("Events", "LearnerActivity");
                }
            }

            UserProfile item = await HttpContext.GetUserAsync();
            if (item != null)
            {
                return CheckResult(item);
            }

            ViewResult result = (ViewResult)await SignOnByLineAsync(viewModel);
            item = result.Model as UserProfile;

            if (item != null)
            {
                return CheckResult(item);
            }

            return result;
        }

        [AllowAnonymous]
        public async Task<ActionResult> LineToTakeFeedbackSurveyAsync(RegisterViewModel viewModel, LessonTimeViewModel lessonViewModel)
        {
            ActionResult CheckResult(UserProfile profile)
            {
                var feedback = models.GetTable<LessonFeedBack>()
                                .Where(f => f.LessonID == lessonViewModel.LessonID)
                                .Where(f => f.RegisterLesson.UID == profile.UID)
                                .FirstOrDefault();

                if (feedback != null)
                {
                    if (feedback.FeedBackDate.HasValue)
                    {
                        return RedirectToAction("CourseItem", "LearnerActivity", new { KeyID = feedback.LessonID.EncryptKey(), from = Url.Action("ContactBook", "LearnerActivity") });
                    }
                    else
                    {
                        return RedirectToAction("TakeFeedbackSurvey", "LearnerActivity", new { KeyID = feedback.LessonID.EncryptKey(), from = Url.Action("Events", "LearnerActivity") });
                    }
                }
                else
                {
                    return RedirectToAction("Events", "LearnerActivity");
                }
            }

            UserProfile item = await HttpContext.GetUserAsync();
            if (item != null)
            {
                return CheckResult(item);
            }

            ViewResult result = (ViewResult)await SignOnByLineAsync(viewModel);
            item = result.Model as UserProfile;

            if (item != null)
            {
                return CheckResult(item);
            }

            return result;
        }

        [AllowAnonymous]
        public async Task<ActionResult> SignOnByLineAsync(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.LineID = viewModel.KeyID.DecryptKey();
            }
            var item = models.GetTable<UserProfileExtension>().Where(u => u.LineID == viewModel.LineID)
                    .Select(u => u.UserProfile)
                    .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                    .FirstOrDefault();

            if (item != null)
            {
                await HttpContext.SignOnAsync(item);
                return View("Views/LearnerActivity/Page.zh-TW/Index.cshtml", item);
            }
            else
            {
                ViewBag.Message = "此支裝置尚未設定過專屬服務，請點選下方更多資訊/專屬服務/帳號設定才可使用！";
                return Login(viewModel);
            }

        }

        [AllowAnonymous]
        public ActionResult LineNotifyExpiringCourseContract(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/LearnerActivity/LineNotifyExpiringCourseContract.cshtml");
        }

    }
}