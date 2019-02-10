using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
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

namespace BFConsole.Controllers
{
    [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class ReportConsoleController : SampleController<UserProfile>
    {
        // GET: ReportConsole
        public ActionResult SelectMonthlyReport()
        {
            return View("~/Views/ReportConsole/ReportModal/SelectMonthlyReport.ascx");
        }

        public ActionResult SelectPeriodReport()
        {
            return View("~/Views/ReportConsole/ReportModal/SelectPeriodReport.ascx");
        }

        public ActionResult SelectReportByContractNo()
        {
            ViewBag.ConditionView = "~/Views/ReportConsole/ReportModal/ByContractNo.ascx";
            return View("~/Views/ReportConsole/ReportModal/SelectReportCondition.ascx");
        }


    }
}