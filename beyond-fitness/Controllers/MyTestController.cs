using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using CommonLib.MvcExtension;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Controllers
{
    public class MyTestController : SampleController<UserProfile>
    {
        // GET: MyTest
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult RedirectTo(String url)
        {
            return Redirect(url);
        }

        public ActionResult RenderAll()
        {
            return Content("Hello...");
        }

        public ActionResult GetJson()
        {
                TempData["msg"] = "Hello...";
                ViewBag.Message = "TEST~~";
            //StringBuilder sb = new StringBuilder();
            //using (StringWriter sw = new StringWriter(sb))
            //{
            //    //Server.Execute("~/Lessons/DailyBookingMembers?lessonDate=2016-08-20&hour=8", sw);
               
            //    Server.Execute("~/MyTest/RenderAll", sw);
            //    sw.Flush();
            //}
            return Json(new { result = true, details = this.RenderViewToString("Test01", null) }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult Test(String view)
        {
            return View(view, null);
        }

        public ActionResult TestError()
        {
            this.ModelState.AddModelError("memberCode", "Error Member Code!!");
            ViewBag.ModelState = ModelState;
            return View("Test01", null);
        }

        public ActionResult TestException()
        {
            throw new Exception("Test Exception!!");
        }

        public ActionResult TestPopup(String message)
        {
            if (!String.IsNullOrEmpty(message))
            {
                ViewBag.Message = message;
            }
            return View("TestPopup", model: message);
        }

        public ActionResult TestMaster2017()
        {
            return View();
        }

        public ActionResult Unauthorize()
        {
            return new HttpUnauthorizedResult();
        }

        public ActionResult TestViewModel(ViewModelA A,ViewModelB B)
        {
            return Content(A.Data + B.Data);
        }

        public ActionResult TestContractAllowance(int? revisionID,int? balance)
        {
            var item = models.GetTable<CourseContractRevision>().Where(r => r.RevisionID == revisionID).FirstOrDefault();
            models.CreateAllowanceForContract(item.SourceContract, balance.Value, item.CourseContract.ContractDate);
            models.SubmitChanges();
            return Json(new { result = true }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult TestDataTable()
        {
            return View();
        }

        public ActionResult UrlToPDF(String url)
        {
            String pdfFile = Path.Combine(Logger.LogDailyPath, $"{Guid.NewGuid()}.pdf");
            url.ConvertHtmlToPDF(pdfFile, 20);
            return File(pdfFile, "application/pdf");
        }

        public async Task<ActionResult> ConsoleHome(LoginViewModel viewModel, string returnUrl)
        {

            UserProfile item = models.EntityList.Where(u => u.PID == viewModel.PID
                && u.LevelID == (int)Naming.MemberStatusDefinition.Checked).FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "登入資料錯誤!!");
            }

            HttpContext.SignOn(item, viewModel.RememberMe);

            return Redirect("~/ConsoleHome/Index");

        }

    }

    public class ViewModelA
    {
        public int? No { get; set; }
        public String Data { get; set; }
    }
    public class ViewModelB
    {
        public int? ID { get; set; }
        public String Data { get; set; }
    }
}