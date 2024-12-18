﻿using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading;
using System.Web;
using Microsoft.AspNetCore.Mvc;
using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Configuration;
using CommonLib.Core.Utility;
using Microsoft.AspNetCore.WebUtilities;
using System.Threading.Tasks;
using Microsoft.AspNetCore.StaticFiles;

namespace WebHome.Controllers
{
    [Authorize]
    public class InformationController : SampleController<UserProfile>
    {
        public InformationController(IServiceProvider serviceProvider) : base(serviceProvider) { }
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
        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach,(int)Naming.RoleID.Assistant,(int)Naming.RoleID.Servitor})]
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
        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Servitor })]
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
        [RoleAuthorize(new int[] { (int)Naming.RoleID.Coach, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Servitor })]
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


        // [AllowAnonymous]
        // public ActionResult Resource(int id)
        // {
        //     var item = models.GetTable<Article>().Where(a => a.DocID == id).FirstOrDefault();
        //     return View(item);
        // }


        [AllowAnonymous]
        public async Task<ActionResult> GetResourceAsync(QueryViewModel viewModel, bool? stretch = false)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.id = viewModel.DecryptKeyValue();
            }
            else if (viewModel.HKeyID != null)
            {
                viewModel.id = viewModel.DecryptHexKeyValue();
            }

            var item = models.GetTable<Attachment>().Where(a => a.AttachmentID == viewModel.id).FirstOrDefault();
            if (item != null)
            {
                String imgPath = item.StoredPath;
                if (!System.IO.File.Exists(imgPath))
                {
                    imgPath = WebApp.MapPath(imgPath);
                }

                if (System.IO.File.Exists(imgPath))
                {
                    if (stretch == true)
                    {
                        using (Bitmap img = new Bitmap(imgPath))
                        {
                            checkOrientation(img);

                            if (img.Width > WebApp.Properties.GetValue<int>("ResourceMaxWidth"))
                            {
                                using (Bitmap m = new Bitmap(img, new Size(WebApp.Properties.GetValue<int>("ResourceMaxWidth"), img.Height * WebApp.Properties.GetValue<int>("ResourceMaxWidth") / img.Width)))
                                {
                                    Response.ContentType = "image/jpeg";
                                    using (FileBufferingWriteStream output = new FileBufferingWriteStream())
                                    {
                                        m.Save(output, ImageFormat.Jpeg);
                                        //output.Seek(0, SeekOrigin.Begin);
                                        await output.DrainBufferAsync(Response.Body);
                                    }

                                    return new EmptyResult();
                                }
                            }
                        }
                    }
                    return new PhysicalFileResult(imgPath, "application/octet-stream");
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
                    new FileExtensionContentTypeProvider().TryGetContentType(item.StoredPath, out string contentType);
                    if (contentType == null)
                    {
                        try
                        {
                            using(Image img = Image.FromFile(item.StoredPath))
                            {
                                if (img != null)
                                {
                                    contentType = $"image/{img.RawFormat}";
                                }
                            }
                        }
                        catch(Exception ex)
                        {
                            FileLogger.Logger.Warn(ex);
                        }
                    }
                    return new PhysicalFileResult(item.StoredPath, contentType ?? "application/octet-stream");
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
                    message.ReplyToList.Add(WebApp.Properties["WebMaster"]);
                    message.From = new System.Net.Mail.MailAddress(email,userName);
                    message.To.Add(WebApp.Properties["WebMaster"]);
                    message.Subject = subject;
                    message.IsBodyHtml = true;

                    message.Body = HttpUtility.HtmlDecode(comment);

                    using System.Net.Mail.SmtpClient smtpclient = new System.Net.Mail.SmtpClient(AppSettings.Default.Smtp.Host, AppSettings.Default.Smtp.Port);
                    smtpclient.EnableSsl = AppSettings.Default.Smtp.EnableSsl;
                    //smtpclient.UseDefaultCredentials = false;
                    if(AppSettings.Default.Smtp.UserName != null)
                    {
                        smtpclient.Credentials = new NetworkCredential(AppSettings.Default.Smtp.UserName, AppSettings.Default.Smtp.Password);
                    }
                    smtpclient.Send(message);
                }
                catch (Exception ex)
                {
                    ApplicationLogging.CreateLogger<InformationController>().LogError(ex, ex.Message);
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

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer })]
        public ActionResult MotivationalWords()
        {
            var items = models.GetTable<Article>().Where(a => a.Document.DocType == (int)Naming.DocumentTypeDefinition.Inspirational);
            return View(items);
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer })]
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

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer })]
        public async Task<ActionResult> CommitMotivationalWordsAsync(MotivationalWordsViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();

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

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer })]
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