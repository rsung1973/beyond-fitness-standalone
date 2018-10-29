using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Helper;
using WebHome.Models.Locale;

namespace WebHome.Controllers
{
    public class FrontEndController : SampleController<UserProfile>
    {
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult ContactUs(String subject)
        {
            if (String.IsNullOrEmpty(subject))
                subject = "聯絡我們";

            ThreadPool.QueueUserWorkItem(t => {

                try
                {

                    StringBuilder body = new StringBuilder();
                    System.Net.Mail.MailMessage message = new System.Net.Mail.MailMessage();
                    message.ReplyToList.Add(Settings.Default.WebMaster);
                    message.From = new System.Net.Mail.MailAddress(Request["contact-email"], Request["contact-name"]);
                    message.To.Add(Settings.Default.WebMaster);
                    message.Subject = Request["contact-subject"];
                    message.IsBodyHtml = true;
                    message.BodyEncoding = new UTF8Encoding(false);

                    message.Body = HttpUtility.HtmlDecode(Request["contact-message"]);

                    System.Net.Mail.SmtpClient smtpclient = new System.Net.Mail.SmtpClient(Settings.Default.SmtpServer);
                    //smtpclient.Credentials = CredentialCache.DefaultNetworkCredentials;
                    smtpclient.Send(message);
                }
                catch (Exception ex)
                {
                    Logger.Error(ex);
                }
            });

            return Content("Your comment was successfully added!");
        }

        public ActionResult Blog()
        {
            var items = models.GetTable<Article>().Where(a => a.Document.CurrentStep == (int)Naming.DocumentLevelDefinition.正常);
            return View("~/Views/FrontEnd/Module/Blog.ascx", items);
        }

        public ActionResult BlogDetail(int id)
        {
            var item = models.GetTable<Article>().Where(a => a.DocID == id).FirstOrDefault();
            if (item == null)
            {
                return Content("文章已刪除或不存在！");
            }
            return View("~/Views/FrontEnd/Module/BlogDetail.ascx", item);
        }

        public ActionResult LastArticles(int count)
        {
            var items = models.GetTable<Article>().Where(a => a.Document.CurrentStep == (int)Naming.DocumentLevelDefinition.正常)
                .OrderByDescending(a => a.DocID).Take(count);

            return View("~/Views/FrontEnd/Module/BlogTitle.ascx", items);
        }

        public ActionResult CategoryList()
        {
            var items = models.GetTable<ArticleCategoryDefinition>();
            return View("~/Views/FrontEnd/Module/CategoryList.ascx", items);
        }

    }
}