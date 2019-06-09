using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
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
using System.Web.Mvc;
using System.Web.Security;

using CommonLib.DataAccess;
using CommonLib.MvcExtension;
using Newtonsoft.Json;
using Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Helper.BusinessOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    public class MainActivityController : SampleController<UserProfile>
    {
        public const String DefaultLanguage = "zh-TW";
        // GET: MainActivity
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult ChangeLanguate(String lang)
        {
            Response.SetCookie(new HttpCookie("cLang", lang));
            return Json(new { result = true, message = System.Globalization.CultureInfo.CurrentCulture.Name }, JsonRequestBehavior.AllowGet);
        }

        protected override void HandleUnknownAction(string actionName)
        {
            this.View(actionName).ExecuteResult(this.ControllerContext);
        }

        public ActionResult CoachDetails(CoachItem viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public ActionResult Team(String branchName)
        {
            ViewBag.BranchName = branchName = branchName.GetEfficientString();
            CoachData model = null;
            String jsonFile = Server.MapPath($"~/MainActivity/Portfolio/{branchName}.json");
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
                return View(model);
            }
        }

        public ActionResult PricingList(BranchJsonViewModel viewModel)
        {
            viewModel.branchName = viewModel.branchName.GetEfficientString();
            viewModel.unit = viewModel.unit ?? 60;
            ViewBag.ViewModel = viewModel;
            PricingData model = null;
            String jsonFile = Server.MapPath($"~/MainActivity/Pricing/{viewModel.branchName}.json");
            if (System.IO.File.Exists(jsonFile))
            {
                var jsonData = System.IO.File.ReadAllText(jsonFile);
                model = JsonConvert.DeserializeObject<PricingData>(jsonData);
            }

            if (model == null)
            {
                return Index();
            }
            else
            {
                return View(model);
            }
        }

        public ActionResult BlogArticleList(BlogArticleQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var items = models.GetTable<BlogArticle>()
                .Where(b => b.BlogTag.Any(c => c.CategoryID == viewModel.CategoryID));
            return View(items);
        }

        public ActionResult BlogSingle(BlogArticleQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(viewModel.KeyID!=null)
            {
                viewModel.DocID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<BlogArticle>().Where(b => b.DocID == viewModel.DocID).FirstOrDefault();
            if (item == null)
            {
                return View("Index");
            }
            return View(item);
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
            item.Document.DocDate = viewModel.DocDate.Value;
            item.BlogID = blogID;

            models.SubmitChanges();
            models.ExecuteCommand("delete BlogTag where DocID = {0}", item.DocID);
            foreach(var categoryID in viewModel.TagID)
            {
                models.ExecuteCommand("insert BlogTag (DocID,CategoryID) values ({0},{1})", item.DocID, categoryID);
            }

            String blogRoot = Server.MapPath("~/MainActivity/Blog");
            String blogPath = Path.Combine(blogRoot, blogID);
            blogPath.CheckStoredPath();
            if (sourceBlogID != null && sourceBlogID != blogID)
            {
                Directory.Move(Path.Combine(blogRoot, sourceBlogID), blogPath);
            }

            return Json(new { result = true, item.DocID, item.BlogID });
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

            String blogRoot = Server.MapPath("~/MainActivity/Blog");
            String blogPath = Path.Combine(blogRoot, item.BlogID);
            blogPath.CheckStoredPath();

            if (Request.Files.Count == 0)
            {
                return Json(new { result = false, message = "請上傳文章內容" });
            }

            var file = Request.Files[0];

            try
            {
                using (ZipArchive zip = new ZipArchive(file.InputStream))
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
                return Json(new { result = true, item.DocID, item.BlogID });
            }
            catch(Exception ex)
            {
                Logger.Error(ex);
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

            String blogRoot = Server.MapPath("~/MainActivity/Blog");
            String blogPath = Path.Combine(blogRoot, item.BlogID);
            if(Directory.Exists(blogPath))
            {
                Directory.Delete(blogPath, true);
            }
            return Json(new { result = true });

        }


    }
}