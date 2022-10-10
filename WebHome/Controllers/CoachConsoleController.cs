using System;
using System.Collections.Generic;
using System.Data;

using System.IO;
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
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.Routing;
using Microsoft.Extensions.DependencyInjection;

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
using CommonLib.Core.Utility;
using Microsoft.AspNetCore.Http;
namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class CoachConsoleController : SampleController<UserProfile>
    {
        public CoachConsoleController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

        public async Task<ActionResult> ShowCoachPerformanceListAsync(CoachQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();
            if (viewModel.Employed == false)
            {
                return View("~/Views/CoachConsole/Module/LeavedCoachList.cshtml", profile.LoadInstance(models));
            }
            else
            {
                return View("~/Views/CoachConsole/Module/CoachMonthlyPerformance.cshtml", profile.LoadInstance(models));
            }
        }

        public ActionResult ProcessCoachView(CoachQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<ServingCoach>().Where(c => c.CoachID == viewModel.CoachID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "合約資料錯誤!!");
            }

            return View("~/Views/CoachConsole/Module/ProcessCoachView.cshtml", item);
        }
    }
}
