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

using CommonLib.DataAccess;

using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Helper.BusinessOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc.Filters;
using WebHome.Properties;
using System.Net.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Http;
using Validation = WebHome.Models.Resources.CommitTrialLearner;
using CommonLib.Core.Utility;
using Microsoft.AspNetCore.Mvc.ViewEngines;

namespace WebHome.Controllers
{
    public class MainActivityController : SampleController<UserProfile>
    {
        public const String DefaultLanguage = "zh-TW";
        private readonly ICompositeViewEngine _viewEngine;
        public MainActivityController(IServiceProvider serviceProvider) : base(serviceProvider)
        {
            _viewEngine = serviceProvider.GetService<ICompositeViewEngine>();
        }

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);

            var lang = Request.Cookies["cLang"];
            if (lang == null)
            {
                lang = AppSettings.Default.Language;
                //lang = Request.Headers.AcceptLanguage.Contains("zh")
                //                ? "zh-TW"
                //                : Request.Headers.AcceptLanguage.Contains("en")
                //                    ? "en-US"
                //                    : Request.Headers.AcceptLanguage.Contains("ja")
                //                        ? "ja"
                //                        : AppSettings.Default.Language;
                lang.SelectUICulture();
            }
            ViewBag.Lang = lang;
        }

        protected String Lang 
        { 
            get
            {
                return ViewBag.Lang ?? "zh-TW";
            } 
        }
        // GET: MainActivity
        public ActionResult Index()
        {
            ViewEngineResult viewResult = CheckView("Index");
            return CheckLanguageRoute() ?? View(viewResult.ViewName);
        }
        public ActionResult Main()
        {
            return Index();
        }

        public ActionResult ChangeLanguage(String lang)
        {
            Response.Cookies.Append("cLang", lang);
            Response.Cookies.Append("setLang", lang);
            return Json(new { result = true, message = System.Globalization.CultureInfo.CurrentCulture.Name });
        }

        public ActionResult CommitGDPR()
        {
            Response.Cookies.Append("GDPR", "agree");
            return Json(new { result = true, GDPR = true});
        }

        protected ViewEngineResult CheckView(String actionName)
        {
            ViewEngineResult viewResult = _viewEngine.GetView("~/", $"/Views/MainActivity/Page.{Lang}/{actionName}.cshtml", isMainPage: false);
            if(!viewResult.Success)
            {
                viewResult = _viewEngine.GetView("~/", $"/Views/MainActivity/Page.zh-TW/{actionName}.cshtml", isMainPage: false);
            }
            return viewResult;
        }

        protected ActionResult CheckLanguageRoute()
        {
            var lang = RouteData.Values["lang"] as String;
            if (lang == "tw" || lang == "en" || lang == "ja")
            {
                if ((ViewBag.Lang as String).Contains(lang))
                {
                    return null;
                }
                else
                {
                    if (Request.Cookies["setLang"] != null)
                    {
                        Response.Cookies.Delete("setLang");
                        lang = ViewBag.Lang == "zh-TW"
                                ? "tw"
                                : ViewBag.Lang == "en-US"
                                    ? "en"
                                    : "ja";
                    }
                    else
                    {
                        ViewBag.Lang = lang == "tw"
                                ? "zh-TW"
                                : lang == "en"
                                    ? "en-US"
                                    : "ja";
                        Response.Cookies.Append("cLang", (String)ViewBag.Lang);

                        return null;
                    }
                }
            }
            else
            {
                lang = "tw";
                //lang = Request.Headers.AcceptLanguage.Contains("zh")
                //                    ? "tw"
                //                    : Request.Headers.AcceptLanguage.Contains("en")
                //                        ? "en"
                //                        : Request.Headers.AcceptLanguage.Contains("ja")
                //                            ? "ja"
                //                            : "tw";

            }

            return Redirect($"~/Official/{lang}/{RouteData.Values["actionName"] ?? RouteData.Values["action"]}{Request.QueryString}");
        }

        public ActionResult HandleUnknownAction(string actionName, IFormCollection forms, QueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            //string viewName = "YourViewName"; // 替换为你要检查的视图名称
            //string viewPath = "/Views/YourFolder/" + viewName + ".cshtml"; // 替换为你的视图路径

            //ViewEngineResult viewResult = _viewEngine.GetView("~/", $"/Views/MainActivity/{actionName}.cshtml", isMainPage: false);
            ViewEngineResult viewResult = CheckView(actionName);

            if (viewResult.Success)
            {
                // 视图存在
                return CheckLanguageRoute() ?? View(viewResult.ViewName, forms);
            }
            else
            {
                if (actionName != null && System.IO.Path.GetExtension(actionName).Length > 0)
                {
                    return NotFound();
                }
                else
                {
                    // 视图不存在
                    return Index();
                }
            }

            //this.View(actionName).ExecuteResult(this.ControllerContext);
        }

        public ActionResult CoachDetails(CoachItem viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewEngineResult viewResult = CheckView("CoachDetails");

            return CheckLanguageRoute() ?? View(viewResult.ViewName);
        }

        public ActionResult Team(String branchName)
        {
            ViewBag.BranchName = branchName = branchName.GetEfficientString();
            CoachData model = null;
            String jsonFile = Startup.MapPath($"~/MainActivity/Portfolio/{branchName}.json");
            if (System.IO.File.Exists(jsonFile))
            {
                var jsonData = System.IO.File.ReadAllText(jsonFile);
                model = JsonConvert.DeserializeObject<CoachData>(jsonData);
            }

            if (model == null)
            {
                return Index();
            }
            else
            {
                ViewEngineResult viewResult = CheckView("Team");

                return CheckLanguageRoute() ?? View(viewResult.ViewName, model);
            }
        }

        public ActionResult PricingList(BranchJsonViewModel viewModel)
        {
            // viewModel.branchName = viewModel.branchName.GetEfficientString();
            // viewModel.unit = viewModel.unit ?? 60;
            // ViewBag.ViewModel = viewModel;
            // PricingData model = null;
            // String jsonFile = Startup.MapPath($"~/MainActivity/Pricing/{viewModel.branchName}.json");
            // if (System.IO.File.Exists(jsonFile))
            // {
            //     var jsonData = System.IO.File.ReadAllText(jsonFile);
            //     model = JsonConvert.DeserializeObject<PricingData>(jsonData);
            // }

            // if (model == null)
            // {
            //     return Index();
            // }
            // else
            // {
            //     return View(model);
            // }
            ViewEngineResult viewResult = CheckView("PricingList");

            return View(viewResult.ViewName);
        }

        public ActionResult BlogArticleList(BlogArticleQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var items = models.GetTable<BlogArticle>()
                .Where(b => b.BlogTag.Any(c => c.CategoryID == viewModel.CategoryID));
            ViewEngineResult viewResult = CheckView("BlogArticleList");

            return CheckLanguageRoute() ?? View(viewResult.ViewName,items);
        }

        public ActionResult BlogSingle(BlogArticleQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.DocID = viewModel.DecryptKeyValue();
            }

            if(!viewModel.DocID.HasValue)
            {
                if (Request.QueryString.HasValue)
                {
                    int fbclid = Request.QueryString.Value.IndexOf("&fbclid");
                    ViewBag.ViewModel = viewModel = JsonConvert.DeserializeObject<BlogArticleQueryViewModel>(
                        fbclid > 0
                        ? Request.QueryString.Value[1..fbclid].UrlDecodeBase64String().DecryptKey()
                        : Request.QueryString.Value[1..].UrlDecodeBase64String().DecryptKey());
                }
            }

            var item = models.GetTable<BlogArticle>().Where(b => b.DocID == viewModel.DocID).FirstOrDefault();
            if (item == null || item.NotAfter < DateTime.Today)
            {
                return Index();
            }
            ViewEngineResult viewResult = CheckView("BlogSingle");

            return CheckLanguageRoute() ?? View(viewResult.ViewName, item);
        }

        public ActionResult DropifyUpload()
        {
            return View("~/Views/ConsoleHome/Shared/DropifyUpload.cshtml");
        }

        public ActionResult CommitArticle(BlogArticleQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(viewModel.KeyID!=null)
            {
                viewModel.DocID = viewModel.DecryptKeyValue();
            }

            viewModel.Title = viewModel.Title.GetEfficientString();
            if(viewModel.Title==null)
            {
                ModelState.AddModelError("Title", "請輸入撰稿標題");
            }
            if (!viewModel.AuthorID.HasValue)
            {
                ModelState.AddModelError("AuthorName", "請選擇撰稿人員");
            }
            String blogID = null;
            if (!viewModel.DocDate.HasValue)
            {
                ModelState.AddModelError("DocDate", "請選擇發佈時間");
            }
            else
            {
                blogID = $"{viewModel.DocDate:yyyyMMdd}";
                var duplicated = viewModel.DocID.HasValue
                    ? models.GetTable<BlogArticle>().Any(b => b.DocID != viewModel.DocID && b.BlogID == blogID)
                    : models.GetTable<BlogArticle>().Any(b => b.BlogID == blogID);
                if(duplicated)
                {
                    ModelState.AddModelError("DocDate", "該時間已有其它文章發佈");
                }
            }

            if (viewModel.TagID == null || !viewModel.TagID.Any(i => i.HasValue))
            {
                ModelState.AddModelError("Category", "請選擇文章類別");
            }
            else
            {
                viewModel.TagID = viewModel.TagID.Where(i => i.HasValue).ToArray();
            }

            String blogRoot = Startup.MapPath("~/MainActivity/Blog");
            String blogPath = Path.Combine(blogRoot, blogID);
            if (Directory.Exists(blogPath))
            {
                ModelState.AddModelError("DocDate", "該時間指定的資料夾路徑已存在");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            var item = models.GetTable<BlogArticle>().Where(a => a.DocID == viewModel.DocID).FirstOrDefault();
            String sourceBlogID = null;
            if (item == null)
            {
                item = new BlogArticle
                {
                    Document = new Document
                    {
                        DocDate = DateTime.Now,
                        DocType = (int)Naming.DocumentTypeDefinition.Knowledge
                    },
                };
                models.GetTable<BlogArticle>().InsertOnSubmit(item);
            }
            else
            {
                sourceBlogID = item.BlogID;
            }

            item.AuthorID = viewModel.AuthorID;
            item.Title = viewModel.Title;
            item.Subtitle = viewModel.Subtitle.GetEfficientString();
            item.Document.DocDate = viewModel.DocDate.Value;
            item.BlogID = blogID;

            models.SubmitChanges();
            models.ExecuteCommand("delete BlogTag where DocID = {0}", item.DocID);
            foreach(var categoryID in viewModel.TagID)
            {
                models.ExecuteCommand("insert BlogTag (DocID,CategoryID) values ({0},{1})", item.DocID, categoryID);
            }

            //blogPath.CheckStoredPath();
            if (sourceBlogID != null && sourceBlogID != blogID)
            {
                String sourcePath = Path.Combine(blogRoot, sourceBlogID);
                if (Directory.Exists(sourcePath))
                {
                    Directory.Move(sourcePath, blogPath);
                }
            }

            return Content(new { result = true, item.DocID, item.BlogID }.JsonStringify(), "application/json");
        }

        public ActionResult CommitArticleContent(BlogArticleQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            viewModel.KeyID = viewModel.KeyID.GetEfficientString();
            if (viewModel.KeyID != null)
            {
                viewModel.DocID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<BlogArticle>().Where(a => a.DocID == viewModel.DocID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "請先建立文章資料" });
            }

            String blogRoot = Startup.MapPath("~/MainActivity/Blog");
            String blogPath = Path.Combine(blogRoot, item.BlogID);
            blogPath.CheckStoredPath();

            if (Request.Form.Files.Count == 0)
            {
                return Json(new { result = false, message = "請上傳文章內容" });
            }

            var file = Request.Form.Files[0];

            try
            {
                using (ZipArchive zip = new ZipArchive(file.OpenReadStream()))
                {
                    foreach(var entry in zip.Entries)
                    {
                        var destName = Path.Combine(blogPath, entry.FullName);
                        if (String.IsNullOrEmpty(entry.Name))
                        {
                            destName.CheckStoredPath();
                        }
                        else
                        {
                            entry.ExtractToFile(destName, true);
                        }
                    }
                    //zip.ExtractToDirectory(blogPath);
                }
                return Content(new { result = true, item.DocID, item.BlogID }.JsonStringify(), "application/json");
            }
            catch(Exception ex)
            {
                ApplicationLogging.CreateLogger<MainActivityController>()
                    .LogError(ex, ex.Message);
                return Json(new { result = false, message = $"上傳失敗:{ex.Message}" });
            }

        }

        public ActionResult DeleteArticle(BlogArticleQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.DocID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<BlogArticle>().Where(a => a.DocID == viewModel.DocID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤" });
            }

            models.ExecuteCommand("delete Document where DocID = {0}", item.DocID);

            String blogRoot = Startup.MapPath("~/MainActivity/Blog");
            String blogPath = Path.Combine(blogRoot, item.BlogID);
            if(Directory.Exists(blogPath))
            {
                Directory.Delete(blogPath, true);
            }
            return Json(new { result = true });

        }

        public async Task<ActionResult> CommitTrialLearnerAsync(TrialLearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ModelState.Clear();

            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName == null)
            {
                ModelState.AddModelError("UserName", Validation.InvalidUserName);
            }

            viewModel.Phone = viewModel.Phone.GetEfficientString();
            if (viewModel.Phone == null || !Regex.IsMatch(viewModel.Phone, "^[0-9]{10}$"))
            {
                ModelState.AddModelError("Phone", Validation.InvalidPhone);
            }

            viewModel.Gender = viewModel.Gender.GetEfficientString();
            if (viewModel.Gender == null)
            {
                ModelState.AddModelError("Gender", Validation.InvalidGender);
            }

            viewModel.Email = viewModel.Email.GetEfficientString();
            //if (viewModel.Email == null || !Regex.IsMatch(viewModel.Email, "\\w+([-+.']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"))
            //{
            //    ModelState.AddModelError("Email", Validation.InvalidEmail);
            //}

            if (viewModel.HelpID?.Any(d => d.HasValue) != true)
            {
                ModelState.AddModelError("Message", Validation.InvalidHelpID);
            }

            if (viewModel.TimeID?.Any(d => d.HasValue) != true)
            {
                ModelState.AddModelError("Message", Validation.InvalidTimeID);
            }

            if (viewModel.Agree != true)
            {
                ModelState.AddModelError("Message", Validation.InvalidAgreement);
            }

            if (!viewModel.BranchID.HasValue)
            {
                ModelState.AddModelError("BranchID", Validation.InvalidBranch);
            }

            viewModel.gRecaptchaResponse = viewModel.gRecaptchaResponse.GetEfficientString();
            if (viewModel.gRecaptchaResponse == null)
            {
                return Json(new { result = false, message = Validation.UseCaptcha });
                //ModelState.AddModelError("Message", Validation.UseCaptcha);
            }
            else
            {
                var parameters = new Dictionary<string, string>
                {
                    { "secret", AppSettings.Default.ReCaptcha.SecretKey },
                    { "response", viewModel.gRecaptchaResponse }
                };

                IHttpClientFactory httpClientFactory = ServiceProvider.GetRequiredService<IHttpClientFactory>();
                var client = httpClientFactory.CreateClient();

                var response = await client.PostAsync(AppSettings.Default.ReCaptcha.UrlVerification, new FormUrlEncodedContent(parameters));
                var responseBody = await response.Content.ReadAsStringAsync();

                dynamic captchaResult = JsonConvert.DeserializeObject(responseBody);

                if (captchaResult.success == true)
                {
                    // reCAPTCHA 驗證通過，繼續處理您的業務邏輯
                }
                else
                {
                    // reCAPTCHA 驗證失敗，返回錯誤頁面或相應的處理邏輯
                    return Json(new { result = false, message = Validation.InvalidCaptcha });
                    //ModelState.AddModelError("Message", Validation.InvalidCaptcha);
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.AlertError = false;
                return View("~/Views/MainActivity/Shared/ReportInputError.cshtml", model: ModelState.ErrorMessage());
            }

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            TrialLearner profileItem = null;
            if (!viewModel.UID.HasValue)
            {
                profileItem = models.GetTable<TrialLearner>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            }

            if (profileItem == null)
            {
                profileItem = new TrialLearner
                {
                    SubmitDate = DateTime.Now,
                };

                models.GetTable<TrialLearner>().InsertOnSubmit(profileItem);
            }
            else
            {
                models.ExecuteCommand(@"DELETE FROM tmp.TrialLearnerPurpose
                            WHERE   (UID = {0})", profileItem.UID);

                models.ExecuteCommand(@"DELETE FROM tmp.ContactTime
                            WHERE   (UID = {0})", profileItem.UID);
            }

            profileItem.UserName = viewModel.UserName;
            profileItem.Gender = viewModel.Gender;
            profileItem.Phone = viewModel.Phone;
            profileItem.Email = viewModel.Email;
            profileItem.BranchID = viewModel.BranchID.Value;
            profileItem.Question = viewModel.Question.GetEfficientString();

            profileItem.TrialLearnerPurpose
                .AddRange(viewModel.HelpID.Where(d => d.HasValue).Select(d => new TrialLearnerPurpose
                {
                    HelpID = d.Value,
                }));

            profileItem.ContactTime
                .AddRange(viewModel.TimeID.Where(d => d.HasValue).Select(d => new ContactTime
                {
                    TimeID = d.Value,
                }));

            try
            {
                models.SubmitChanges();
                //return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", Validation.Success);
                return Json(new { result = true });
            }
            catch (Exception ex)
            {
                FileLogger.Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }
        }

        public async Task<ActionResult> ValidateTrialLearnerAsync(TrialLearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ModelState.Clear();

            if (!viewModel.Step.HasValue || viewModel.Step == 1)
            {
                viewModel.UserName = viewModel.UserName.GetEfficientString();
                if (viewModel.UserName == null)
                {
                    ModelState.AddModelError("UserName", Validation.InvalidUserName);
                    return Json(new { result = false, message = ModelState.ErrorMessage() });
                }

                viewModel.Phone = viewModel.Phone.GetEfficientString();
                if (viewModel.Phone == null || !Regex.IsMatch(viewModel.Phone, "^[0-9]{10}$"))
                {
                    ModelState.AddModelError("Phone", Validation.InvalidPhone);
                    return Json(new { result = false, message = ModelState.ErrorMessage() });
                }

                viewModel.Gender = viewModel.Gender.GetEfficientString();
                if (viewModel.Gender == null)
                {
                    ModelState.AddModelError("Gender", Validation.InvalidGender);
                    return Json(new { result = false, message = ModelState.ErrorMessage() });
                }

                //viewModel.Email = viewModel.Email.GetEfficientString();
                //if (viewModel.Email == null || !Regex.IsMatch(viewModel.Email, "\\w+([-+.']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"))
                //{
                //    ModelState.AddModelError("Email", Validation.InvalidEmail);
                //}

                if (viewModel.TimeID?.Any(d => d.HasValue) != true)
                {
                    ModelState.AddModelError("Message", Validation.InvalidTimeID);
                    return Json(new { result = false, message = ModelState.ErrorMessage() });
                }
            }
            else if (viewModel.Step == 2)
            {
                if (viewModel.HelpID?.Any(d => d.HasValue) != true)
                {
                    ModelState.AddModelError("Message", Validation.InvalidHelpID);
                    return Json(new { result = false, message = ModelState.ErrorMessage() });
                }

            }
            else if (viewModel.Step == 3)
            {

                if (!viewModel.BranchID.HasValue)
                {
                    ModelState.AddModelError("BranchID", Validation.InvalidBranch);
                    return Json(new { result = false, message = ModelState.ErrorMessage() });
                }
            }
            else
            {
                if (viewModel.Agree != true)
                {
                    ModelState.AddModelError("Message", Validation.InvalidAgreement);
                    return Json(new { result = false, message = ModelState.ErrorMessage() });
                }

                //viewModel.gRecaptchaResponse = viewModel.gRecaptchaResponse.GetEfficientString();
                //if (viewModel.gRecaptchaResponse == null)
                //{
                //    return Json(new { result = false, message = Validation.UseCaptcha });
                //    //ModelState.AddModelError("Message", Validation.UseCaptcha);
                //}
                //else
                //{
                //    var parameters = new Dictionary<string, string>
                //    {
                //        { "secret", AppSettings.Default.ReCaptcha.SecretKey },
                //        { "response", viewModel.gRecaptchaResponse }
                //    };

                //    IHttpClientFactory httpClientFactory = ServiceProvider.GetRequiredService<IHttpClientFactory>();
                //    var client = httpClientFactory.CreateClient();

                //    var response = await client.PostAsync(AppSettings.Default.ReCaptcha.UrlVerification, new FormUrlEncodedContent(parameters));
                //    var responseBody = await response.Content.ReadAsStringAsync();

                //    dynamic captchaResult = JsonConvert.DeserializeObject(responseBody);

                //    if (captchaResult.success == true)
                //    {
                //        // reCAPTCHA 驗證通過，繼續處理您的業務邏輯
                //    }
                //    else
                //    {
                //        // reCAPTCHA 驗證失敗，返回錯誤頁面或相應的處理邏輯
                //        return Json(new { result = false, message = Validation.InvalidCaptcha });
                //        //ModelState.AddModelError("Message", Validation.InvalidCaptcha);
                //    }
                //}
            }
                
            if (!ModelState.IsValid)
            {
                //ViewBag.AlertError = false;
                //return View("~/Views/MainActivity/Shared/ReportInputError.cshtml", model: ModelState.ErrorMessage());
                return Json(new { result = false, message = ModelState.ErrorMessage() });
            }

            return Json(new { result = true });
        }

    }
}