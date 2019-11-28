using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [Authorize]
    public class InformationController : SampleController<UserProfile>
    {
        public InformationController() : base() { }
        // GET: Information
        [AllowAnonymous]
        public ActionResult Blog(PagingIndexViewModel viewModel)
        {
            ViewBag.PagingModel = viewModel;


            var items = models.GetNormalArticles()
                .OrderByDescending(a => a.Document.DocDate)
                .Skip(viewModel.CurrentIndex * viewModel.PageSize)
                .Take(viewModel.PageSize);

            return View(items);
        }

        [AllowAnonymous]
        public ActionResult BlogDetail(int id)
        {



            var item = models.GetTable<Article>().Where(a => a.DocID == id).FirstOrDefault();
            if (item == null)
            {
                return Redirect("~/Views/Shared/Error.aspx");
            }
            return View(item);
        }

        public ActionResult Preview(int id)
        {
            return BlogDetail(id);
        }

        public ActionResult DeleteBlog(int docID)
        {



            var item = models.GetTable<Article>().Where(a => a.DocID == docID).FirstOrDefault();
            if (item == null)
            {
                ViewBag.Message = "資料錯誤!!";
                return Publish(null);
            }

            item.Document.CurrentStep = (int)Naming.DocumentLevelDefinition.已刪除;
            models.SubmitChanges();

            ViewBag.Message = "文件已刪除!!";
            return Publish(null);

        }

        //[CoachOrAssistantAuthorize]
        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor})]
        public ActionResult Publish(PagingIndexViewModel viewModel)
        {
            ViewBag.PagingModel = viewModel;


            var items = models.GetNormalArticles()
                .OrderByDescending(a => a.Document.DocDate);
            //.Skip(viewModel.CurrentIndex * viewModel.PageSize)
            //.Take(viewModel.PageSize);

            return View("Publish",items);
        }

        //[CoachOrAssistantAuthorize]
        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Servitor })]
        public ActionResult CreateNew()
        {



            var item = models.GetTable<Article>().Where(a => a.Document.CurrentStep == (int)Naming.DocumentLevelDefinition.暫存).FirstOrDefault();
            if (item == null)
            {
                item = new Article
                {
                    Document = new Document
                    {
                        DocDate = DateTime.Now,
                        CurrentStep = (int)Naming.DocumentLevelDefinition.暫存,
                        DocType = (int)Naming.DocumentTypeDefinition.Knowledge
                    }
                };
                models.GetTable<Article>().InsertOnSubmit(item);
                models.SubmitChanges();
            }
            return View("EditBlog", item);
        }

        //[CoachOrAssistantAuthorize]
        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Coach, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Servitor })]
        public ActionResult EditBlog(int id)
        {

            var item = models.GetTable<Article>().Where(a => a.DocID == id).FirstOrDefault();
            if (item == null)
            {
                ViewBag.Message = "文章資料不存在!!";
                return RedirectToAction("Publish");
            }
            return View(item);
        }

        [CoachOrAssistantAuthorize]
        public ActionResult PriceList()
        {
            return View();
        }


        [AllowAnonymous]
        public ActionResult Resource(int id)
        {



            var item = models.GetTable<Article>().Where(a => a.DocID == id).FirstOrDefault();
            return View(item);
        }

        [AllowAnonymous]
        public ActionResult UploadResource(int id)
        {


            var item = models.GetTable<Article>().Where(a => a.DocID == id).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "文章不存在!!" });
            }
            if (Request.Files.Count <= 0)
            {
                return Json(new { result = false, message = "檔案上載失敗!!" });
            }

            try
            {
                String storePath = Path.Combine(Logger.LogDailyPath, Guid.NewGuid().ToString() + Path.GetExtension(Request.Files[0].FileName));
                Request.Files[0].SaveAs(storePath);

                models.GetTable<Attachment>().InsertOnSubmit(new Attachment
                {
                    DocID = item.DocID,
                    StoredPath = storePath
                });
                models.SubmitChanges();
                return Json(new { result = true });

            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }

        }

        [AllowAnonymous]
        public ActionResult RetrieveResource(int docID, String imgUrl)
        {


            var item = models.GetTable<Article>().Where(a => a.DocID == docID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "文章不存在!!" });
            }

            if (String.IsNullOrEmpty(imgUrl))
            {
                return Json(new { result = false, message = "來源網址錯誤!!" });
            }

            try
            {
                String storePath = Path.Combine(Logger.LogDailyPath, Guid.NewGuid().ToString() + ".dat");
                using (WebClient client = new WebClient())
                {
                    client.DownloadFile(imgUrl, storePath);
                }

                models.GetTable<Attachment>().InsertOnSubmit(new Attachment
                {
                    DocID = item.DocID,
                    StoredPath = storePath
                });
                models.SubmitChanges();
                return Json(new { result = true, message = "擷取完成!!" });

            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }

        }

        public ActionResult MakeTheme(int docID, int attachmentID)
        {


            var item = models.GetTable<Article>().Where(a => a.DocID == docID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "文章不存在!!" });
            }

            var attachment = models.GetTable<Attachment>().Where(a => a.AttachmentID == attachmentID).FirstOrDefault();
            if (attachment == null)
            {
                return Json(new { result = false, message = "圖檔不存在!!" });
            }


            try
            {
                item.Illustration = attachment.AttachmentID;
                models.SubmitChanges();
                return Json(new { result = true, message = "資料已更新!!" });
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }

        }

        public ActionResult UpdateArticle(int docID, int docType, String title,String subtitle,String[] category, String docDate, String content,int? authorID)
        {

            if(String.IsNullOrEmpty(title))
            {
                return Json(new { result = false, message = "請輸入文標題!!" });
            }

            var item = models.GetTable<Article>().Where(a => a.DocID == docID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "文章不存在!!" });
            }

            try
            {
                item.Document.DocType = docType;
                item.Document.DocDate = DateTime.ParseExact(docDate, "yyyy/MM/dd", System.Globalization.CultureInfo.CurrentCulture);
                item.Document.CurrentStep = (int)Naming.DocumentLevelDefinition.正常;
                item.Title = title;
                item.Subtitle = subtitle;
                item.AuthorID = authorID;
                item.ArticleContent = HttpUtility.HtmlDecode(content);

                models.SubmitChanges();

                models.ExecuteCommand("delete ArticleCategory where DocID = {0}", item.DocID);
                if(category!=null && category.Length>0)
                {
                    foreach(var c in category)
                    {
                        models.ExecuteCommand("INSERT INTO ArticleCategory (DocID, Category) VALUES({0},{1})", item.DocID, c);
                    }
                }

                return Json(new { result = true, message = "文章已更新!!" });
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }

        }

        public ActionResult DeleteResource(int docID, int attachmentID)
        {


            var item = models.GetTable<Article>().Where(a => a.DocID == docID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "文章不存在!!" });
            }

            var attachment = models.GetTable<Attachment>().Where(a => a.AttachmentID == attachmentID).FirstOrDefault();
            if (attachment == null)
            {
                return Json(new { result = false, message = "圖檔不存在!!" });
            }

            try
            {
                if (item.Illustration == attachment.AttachmentID)
                {
                    item.Illustration = null;
                }


                models.GetTable<Attachment>().DeleteOnSubmit(attachment);
                if (System.IO.File.Exists(attachment.StoredPath))
                    System.IO.File.Delete(attachment.StoredPath);

                models.SubmitChanges();

                return Json(new { result = true, message = "圖片已更新!!" });
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }

        }

        [AllowAnonymous]
        public ActionResult GetResource(int id, bool? stretch = false)
        {
            var item = models.GetTable<Attachment>().Where(a => a.AttachmentID == id).FirstOrDefault();
            if (item != null)
            {
                if (System.IO.File.Exists(item.StoredPath))
                {
                    if (stretch == true)
                    {
                        using (Bitmap img = new Bitmap(item.StoredPath))
                        {
                            checkOrientation(img);

                            if (img.Width > Settings.Default.ResourceMaxWidth)
                            {
                                using (Bitmap m = new Bitmap(img, new Size(Settings.Default.ResourceMaxWidth, img.Height * Settings.Default.ResourceMaxWidth / img.Width)))
                                {
                                    Response.Clear();
                                    Response.ContentType = "image/jpeg";
                                    m.Save(Response.OutputStream, ImageFormat.Jpeg);
                                    return new EmptyResult();
                                }
                            }
                        }
                    }
                    return File(item.StoredPath, "application/octet-stream");
                }
            }
            return new EmptyResult();

        }

        [AllowAnonymous]
        public ActionResult GetResourceWithMime(AttachmentQueryViewModel viewModel)
        {
            if(viewModel.KeyID!=null)
            {
                viewModel.AttachmentID = viewModel.DecryptKeyValue();
            }
            else if(viewModel.HKeyID!=null)
            {
                viewModel.AttachmentID = viewModel.DecryptHexKeyValue();
            }

            var item = models.GetTable<Attachment>().Where(a => a.AttachmentID == viewModel.AttachmentID).FirstOrDefault();
            if (item != null)
            {
                if (System.IO.File.Exists(item.StoredPath))
                {
                    return File(item.StoredPath, MimeMapping.GetMimeMapping(Path.GetFileName(item.StoredPath)));
                }
            }
            return new EmptyResult();

        }


        private void checkOrientation(Bitmap img)
        {
            if (Array.IndexOf(img.PropertyIdList, 274) > -1)
            {
                var orientation = (int)img.GetPropertyItem(274).Value[0];
                switch (orientation)
                {
                    case 1:
                        // No rotation required.
                        break;
                    case 2:
                        img.RotateFlip(RotateFlipType.RotateNoneFlipX);
                        break;
                    case 3:
                        img.RotateFlip(RotateFlipType.Rotate180FlipNone);
                        break;
                    case 4:
                        img.RotateFlip(RotateFlipType.Rotate180FlipX);
                        break;
                    case 5:
                        img.RotateFlip(RotateFlipType.Rotate90FlipX);
                        break;
                    case 6:
                        img.RotateFlip(RotateFlipType.Rotate90FlipNone);
                        break;
                    case 7:
                        img.RotateFlip(RotateFlipType.Rotate270FlipX);
                        break;
                    case 8:
                        img.RotateFlip(RotateFlipType.Rotate270FlipNone);
                        break;
                }
                // This EXIF data is now invalid and should be removed.
                img.RemovePropertyItem(274);
            }
        }

        [AllowAnonymous]
        public ActionResult Footer()
        {
            return View();
        }

        [AllowAnonymous]
        public ActionResult Rental()
        {
            return View();
        }

        [AllowAnonymous]
        public ActionResult Products()
        {
            return View();
        }

        [AllowAnonymous]
        public ActionResult Cooperation()
        {
            return View();
        }

        [AllowAnonymous]
        public ActionResult Location()
        {
            return View();
        }

        [HttpGet]
        [AllowAnonymous]
        public ActionResult ContactUs()
        {
            return View();
        }

        [HttpPost]
        [AllowAnonymous]
        public ActionResult ContactUs(String email,String userName,String subject,String comment)
        {
            ThreadPool.QueueUserWorkItem(t => {

                try
                {

                    StringBuilder body = new StringBuilder();
                    System.Net.Mail.MailMessage message = new System.Net.Mail.MailMessage();
                    message.ReplyToList.Add(Settings.Default.WebMaster);
                    message.From = new System.Net.Mail.MailAddress(email,userName);
                    message.To.Add(Settings.Default.WebMaster);
                    message.Subject = subject;
                    message.IsBodyHtml = true;

                    message.Body = HttpUtility.HtmlDecode(comment);

                    System.Net.Mail.SmtpClient smtpclient = new System.Net.Mail.SmtpClient(Settings.Default.SmtpServer);
                    //smtpclient.Credentials = CredentialCache.DefaultNetworkCredentials;
                    smtpclient.Send(message);
                }
                catch (Exception ex)
                {
                    Logger.Error(ex);
                }
            });

            ViewBag.Success = "Your comment was successfully added!";
            return View("Success");
        }

        public ActionResult Vip()
        {
            return View();
        }

        [AllowAnonymous]
        public ActionResult Professional(String content)
        {
            if (String.IsNullOrEmpty(content))
            {
                return View();
            }

            return View(content);
        }

        [AllowAnonymous]
        public ActionResult Error()
        {
            return View();
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer })]
        public ActionResult MotivationalWords()
        {
            var items = models.GetTable<Article>().Where(a => a.Document.DocType == (int)Naming.DocumentTypeDefinition.Inspirational);
            return View(items);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer })]
        public ActionResult EditMotivationalWords(int? id)
        {
            var item = models.GetTable<Article>().Where(a => a.DocID == id && a.Document.DocType == (int)Naming.DocumentTypeDefinition.Inspirational).FirstOrDefault();

            MotivationalWordsViewModel viewModel = new MotivationalWordsViewModel
            {
                StartDate = DateTime.Today
            };
            ViewBag.ViewModel = viewModel;

            if(item!=null)
            {
                viewModel.DocID = item.DocID;
                viewModel.Title = item.Title;
                viewModel.StartDate = item.Publication.StartDate;
                viewModel.EndDate = item.Publication.EndDate;
            }

            return View(item);
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer })]
        public ActionResult CommitMotivationalWords(MotivationalWordsViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = HttpContext.GetUser();

            if(String.IsNullOrEmpty(viewModel.Title))
            {
                ModelState.AddModelError("Title", "請輸入激勵小語!!");
            }

            if(!viewModel.StartDate.HasValue)
            {
                ModelState.AddModelError("StartDate", "請選擇開始時間!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("EditMotivationalWords",viewModel);
            }

            var item = models.GetTable<Article>().Where(a => a.DocID == viewModel.DocID && a.Document.DocType == (int)Naming.DocumentTypeDefinition.Inspirational).FirstOrDefault();

            if (item == null)
            {
                item = new Article
                {
                    Document = new Document
                    {
                        DocDate = DateTime.Now,
                        DocType = (int)Naming.DocumentTypeDefinition.Inspirational
                    },
                    Publication = new Publication { }
                };
                models.GetTable<Article>().InsertOnSubmit(item);
            }

            item.AuthorID = profile.UID;
            item.Title = viewModel.Title;
            item.Publication.StartDate = viewModel.StartDate;
            item.Publication.EndDate = viewModel.EndDate;

            models.SubmitChanges();

            ViewBag.Message = "資料已儲存!!";
            ViewResult result = (ViewResult)MotivationalWords();
            result.ViewName = "MotivationalWords";
            return result;
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer })]
        public ActionResult DeleteMotivationalWords(int? id)
        {
            var item = models.DeleteAny<Document>(a => a.DocID == id && a.DocType == (int)Naming.DocumentTypeDefinition.Inspirational);

            if (item == null)
            {
                ViewBag.Message = "資料不存在!!";
            }
            else
            {
                ViewBag.Message = "資料已刪除!!";
            }

            ViewResult result = (ViewResult)MotivationalWords();
            result.ViewName = "MotivationalWords";
            return result;

        }

    }
}