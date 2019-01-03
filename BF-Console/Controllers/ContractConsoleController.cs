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
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace BFConsole.Controllers
{
    [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class ContractConsoleController : SampleController<UserProfile>
    {
        // GET: ContractConsole
        public ActionResult ShowContractList(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireContract(viewModel);
            ViewBag.Contracts = result.Model;

            var profile = HttpContext.GetUser();
            return View("~/Views/ConsoleHome/ContractIndex.aspx", profile.LoadInstance(models));
        }


        public ActionResult InquireContract(CourseContractQueryViewModel viewModel)
        {
            if(viewModel.ByCustom==true)
            {
                return InquireContractByCustom(viewModel);
            }

            bool hasConditon = false;
            var profile = HttpContext.GetUser();
            ViewBag.ViewModel = viewModel;

            IQueryable<CourseContract> items;

            if (viewModel.ContractQueryMode == Naming.ContractServiceMode.ContractOnly)
            {
                if (viewModel.Status >= (int)Naming.CourseContractStatus.已生效)
                {
                    items = models.PromptOriginalContract();
                }
                else if(viewModel.PayoffMode.HasValue)
                {
                    items = models.PromptAccountingContract();
                }
                else
                {
                    items = models.PromptContract();
                }
            }
            else if (viewModel.ContractQueryMode == Naming.ContractServiceMode.ServiceOnly)
            {
                items = models.PromptContractService();
            }
            else
            {
                items = models.GetTable<CourseContract>();
            }

            if (viewModel.PayoffMode == Naming.ContractPayoffMode.Unpaid)
            {
                hasConditon = true;
                items = items
                    .FilterByToPay(models);
            }
            else if (viewModel.PayoffMode == Naming.ContractPayoffMode.Paid)
            {
                hasConditon = true;
                items = items.Where(c => c.ContractPayment.Any());
            }

            if (viewModel.IncludeTotalUnpaid == true)
            {
                Expression<Func<CourseContract, bool>> expr = c => true;
                Expression<Func<CourseContract, bool>> defaultExpr = expr;
                if (viewModel.PayoffDueFrom.HasValue)
                {
                    hasConditon = true;
                    expr = expr.And(c => c.PayoffDue >= viewModel.PayoffDueFrom);
                }

                if (viewModel.PayoffDueTo.HasValue)
                {
                    hasConditon = true;
                    expr = expr.And(c => c.PayoffDue < viewModel.PayoffDueTo);
                }

                if (defaultExpr != expr)
                {
                    expr = expr.Or(c => !c.PayoffDue.HasValue);
                    items = items.Where(expr);
                }
            }
            else
            {
                if (viewModel.PayoffDueFrom.HasValue)
                {
                    hasConditon = true;
                    items = items.Where(c => c.PayoffDue >= viewModel.PayoffDueFrom);
                }

                if (viewModel.PayoffDueTo.HasValue)
                {
                    hasConditon = true;
                    items = items.Where(c => c.PayoffDue < viewModel.PayoffDueTo);
                }
            }

            if (viewModel.Status.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.Status == viewModel.Status);
            }

            if (viewModel.FitnessConsultant.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.FitnessConsultant == viewModel.FitnessConsultant);
            }

            if (viewModel.ManagerID.HasValue)
            {
                hasConditon = true;
                items = items.FilterByBranchStoreManager(models, viewModel.ManagerID);
            }

            if (viewModel.OfficerID.HasValue)
            {
                hasConditon = true;
            }

            if (viewModel.IsExpired == true)
            {
                hasConditon = true;
                items = items.FilterByExpired(models);
            }
            else if (viewModel.IsExpired == false)
            {
                hasConditon = true;
                items = items.Where(c => c.Expiration >= DateTime.Today);
            }

            if (viewModel.EffectiveDateFrom.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.EffectiveDate >= viewModel.EffectiveDateFrom);
            }

            if (viewModel.EffectiveDateTo.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.EffectiveDate < viewModel.EffectiveDateTo);
            }

            if (viewModel.ExpirationFrom.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.Expiration >= viewModel.ExpirationFrom);
            }

            if (viewModel.ExpirationTo.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.Expiration < viewModel.ExpirationTo.Value);
            }

            if (hasConditon)
            {

            }
            else
            {
                items = items.Where(c => false);
            }

            //if (viewModel.ContractType.HasValue)
            //    items = items.Where(c => c.ContractType == viewModel.ContractType);

            return View("~/Views/ContractConsole/Module/ContractList.ascx", items);
        }

        public ActionResult InquireContractByCustom(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            bool hasConditon = false;
            var profile = HttpContext.GetUser();

            IQueryable<CourseContract> items;

            if (viewModel.ContractQueryMode == Naming.ContractServiceMode.ContractOnly)
            {
                items = models.PromptContract();
            }
            else if (viewModel.ContractQueryMode == Naming.ContractServiceMode.ServiceOnly)
            {
                items = models.PromptContractService();
            }
            else
            {
                items = models.GetTable<CourseContract>();
            }

            if (viewModel.ContractDateFrom.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.ContractDate >= viewModel.ContractDateFrom);
            }

            if (viewModel.ContractDateTo.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.ContractDate < viewModel.ContractDateTo.Value);
            }

            Expression<Func<CourseContract, bool>> queryExpr = c => false;
            bool subCondition = false;

            viewModel.ContractNo = viewModel.ContractNo.GetEfficientString();
            if (viewModel.ContractNo != null)
            {
                subCondition = true;
                var no = viewModel.ContractNo.Split('-');
                int seqNo;
                if (no.Length > 1)
                {
                    int.TryParse(no[1], out seqNo);
                    queryExpr = queryExpr.Or(c => c.ContractNo.StartsWith(no[0])
                        && c.SequenceNo == seqNo);
                }
                else
                {
                    queryExpr = queryExpr.Or(c => c.ContractNo.StartsWith(viewModel.ContractNo));
                }
            }

            viewModel.RealName = viewModel.RealName.GetEfficientString();
            if (viewModel.RealName != null)
            {
                subCondition = true;
                queryExpr = queryExpr.Or(c => c.CourseContractMember.Any(m => m.UserProfile.RealName.Contains(viewModel.RealName) || m.UserProfile.Nickname.Contains(viewModel.RealName)));
            }

            if (hasConditon)
            {
                if (subCondition)
                {
                    items = items.Where(queryExpr);
                }
                else
                {
                    if (viewModel.FitnessConsultant.HasValue)
                    {
                        hasConditon = true;
                        items = items.Where(c => c.FitnessConsultant == viewModel.FitnessConsultant);
                    }

                    if (viewModel.ManagerID.HasValue)
                    {
                        hasConditon = true;
                        items = items.FilterByBranchStoreManager(models, viewModel.ManagerID);
                    }

                    if (viewModel.OfficerID.HasValue)
                    {
                        hasConditon = true;
                    }
                }
            }
            else
            {
                if (subCondition)
                {
                    items = items.Where(queryExpr);
                }
                else
                {
                    //items = items.Where(c => false);
                    //return Json(new { result = false, message = "請設定查詢條件!!" });
                    this.ModelState.AddModelError("RealName", "請輸入查詢學生姓名(暱稱)!!");
                    this.ModelState.AddModelError("ContractNo", "請輸入查詢合約編號!!");
                    this.ModelState.AddModelError("ContractDateFrom", "請輸入查詢合約起日!!");
                    this.ModelState.AddModelError("ContractDateTo", "請輸入查詢合約迄日!!");
                    ViewBag.ModelState = this.ModelState;
                    return View("~/Views/ConsoleHome/Shared/ReportInputError.ascx");
                }
            }

            return View("~/Views/ContractConsole/Module/CustomContractList.ascx", items);
        }

        public ActionResult InvokeContractQuery(CourseContractQueryViewModel viewModel)
        {
            //viewModel.ContractDateFrom = DateTime.Today.FirstDayOfMonth();
            //viewModel.ContractDateTo = viewModel.ContractDateFrom.Value.AddMonths(1).AddDays(-1);
            viewModel.ByCustom = true;
            ViewBag.ViewModel = viewModel;
            return View("~/Views/ContractConsole/ContractModal/ContractQuery.ascx");
        }

        public ActionResult ProcessContract(CourseContractQueryViewModel viewModel)
        {
            if(viewModel.KeyID!=null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.ascx", model: "合約資料錯誤!!");
            }

            return View("~/Views/ContractConsole/ContractModal/ProcessContract.ascx", item);
        }

        public ActionResult ShowContractDetails(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)ProcessContract(viewModel);

            CourseContract item = result.Model as CourseContract;
            if (item == null)
            {
                return result;
            }

            return View("~/Views/ContractConsole/ContractModal/AboutContractDetails.ascx", item);
        }

    }
}