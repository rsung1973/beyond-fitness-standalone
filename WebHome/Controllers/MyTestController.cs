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
using Microsoft.AspNetCore.Mvc; //System.Web.Mvc;
//using Microsoft.AspNetCore.Authorization;
using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using CommonLib.Core.Utility;
using CommonLib.DataAccess;
using Microsoft.AspNetCore.Http;
//using System.Data.Entity;
using Microsoft.EntityFrameworkCore;

namespace WebHome.Controllers
{
    public class MyTestController : SampleController<UserProfile>
    {
        private readonly IViewRenderService _viewRenderService;
        public MyTestController(IViewRenderService viewRenderService, IServiceProvider serviceProvider) : base(serviceProvider)
        {
            _viewRenderService = viewRenderService;
        }
        // GET: MyTest
        public IActionResult Index()
        {
            return View();
        }
        public IActionResult RedirectTo(String url)
        {
            return Redirect(url);
        }

        public async Task<IActionResult> RenderAllAsync()
        {
            long seqNo = (long)SqlHelper.ExecuteScalar(models.Connection.ConnectionString, System.Data.CommandType.Text, "select next value for CourseContractNoSeq");
            var profile = await HttpContext.GetUserAsync();
            HttpContextDataModelCache cache = new HttpContextDataModelCache(HttpContext);
            var timeInfo = $"{DateTime.Now}";
            var obj = new
            {
                SessionID = HttpContext.Session.Id,
                LastTimeInfo = HttpContext.Session.GetString("LastTimeInfo"),
                CacheTimeInfo = cache["CacheTimeInfo"],
                CurrentTimeInfo = timeInfo,
                PID = profile?.PID
            };
            HttpContext.Session.SetString("LastTimeInfo", timeInfo);
            cache["CacheTimeInfo"] = timeInfo;
            return Content(obj.JsonStringify());
        }

        public async Task<IActionResult> GetJsonAsync()
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

            return Json(new { result = true, details = await _viewRenderService.RenderToStringAsync("Test01", null) });
        }

        public IActionResult Test(String view)
        {
            return View(view, null);
        }

        public IActionResult TestError()
        {
            this.ModelState.AddModelError("memberCode", "Error Member Code!!");
            ViewBag.ModelState = ModelState;
            return View("Test01", null);
        }

        public IActionResult TestException()
        {
            throw new Exception("Test Exception!!");
        }

        public IActionResult TestPopup(String message)
        {
            if (!String.IsNullOrEmpty(message))
            {
                ViewBag.Message = message;
            }
            return View("TestPopup", model: message);
        }

        public IActionResult TestMaster2017()
        {
            return View();
        }

        public IActionResult Unauthorize()
        {
            return new UnauthorizedResult();
        }

        public IActionResult TestViewModel(ViewModelA A,ViewModelB B)
        {
            return Content(A.Data + B.Data);
        }

        public IActionResult TestContractAllowance(int? revisionID,int? balance)
        {
            var item = models.GetTable<CourseContractRevision>().Where(r => r.RevisionID == revisionID).FirstOrDefault();
            models.CreateAllowanceForContract(item.SourceContract, balance.Value, null, item.SourceContract.ContractDate);
            models.SubmitChanges();
            return Json(new { result = true });
        }

        public IActionResult TestDataTable()
        {
            var item0 = models.GetTable<UserProfile>().OrderBy(u => u.UID).FirstOrDefault();
            var item1 = models.GetTable<UserProfile>().Where(u => u.UID == 1).FirstOrDefault();
            var item2 = ((IEnumerable<UserProfile>)models.GetTable<UserProfile>()).Where(u => u.PID.Contains("info")).FirstOrDefault();
            return new EmptyResult();
        }

        public IActionResult UrlToPDF(String url)
        {
            String pdfFile = Path.Combine(FileLogger.Logger.LogDailyPath, $"{Guid.NewGuid()}.pdf");
            url.ConvertHtmlToPDF(pdfFile, 20);
            return new PhysicalFileResult(pdfFile, "application/pdf");
        }

        public async Task<ActionResult> ConsoleHome(LoginViewModel viewModel, string returnUrl)
        {
            ViewBag.ViewModel = viewModel;
            if(viewModel.KeyID!=null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            //var items = models.DataContext.UserProfile
            //    .Include(u => u.UserRole)
            //    .Include(u => u.UserRoleAuthorization);

            //models.DataContext.UserRole.Include(r => r.UserRoleDefinition);

            UserProfile item = models.GetTable<UserProfile>()
                //.Include(u => u.UserRole)
                //.Include(u => u.UserRoleAuthorization)
                .Where(u => u.UID == viewModel.UID
                    && u.LevelID == (int)Naming.MemberStatusDefinition.Checked).FirstOrDefault();
            if (item == null)
            {
                item = models.GetTable<UserProfile>()
                    //.Include(u => u.UserRole)
                    //.Include(u => u.UserRoleAuthorization)
                    .Where(u => u.PID == viewModel.PID
                        && u.LevelID == (int)Naming.MemberStatusDefinition.Checked).FirstOrDefault();
            }

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "登入資料錯誤!!");
            }

            await HttpContext.SignOnAsync(item, viewModel.RememberMe);

            //return Content("has signed on...");
            return Redirect("~/ConsoleHome/Index");

        }

        public IActionResult TestKey(QueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.id = viewModel.DecryptKeyValue();
            }
            else if (viewModel.HKeyID != null)
            {
                viewModel.id = viewModel.DecryptHexKeyValue();
            }

            return Json(viewModel);
        }

        public IActionResult SystemInfo()
        {
            return Json(new
            {
                ReportInputError = Startup.Properties["ReportInputError"],
                ContractViewUrl = BusinessExtensionMethods.ContractViewUrl.ToString(),
                ContractServiceViewUrl = BusinessExtensionMethods.ContractServiceViewUrl.ToString(),
            });
        }

        public IActionResult TestDateTime()
        {
            DateTime t = DateTime.Today.AddHours(18);
            var items = models.GetTable<LessonTime>()
                            .Where(l => !(l.ClassTime >= t.AddMinutes(90)
                                    || t >= l.ClassTime.Value.AddMinutes(l.DurationInMinutes.Value)));
            return Json(new {Count =  items.Count(),SQL = items.ToString() });
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