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
                    items = models.PromptRegisterLessonContract();
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
                    .Where(c => c.Status == (int)Naming.CourseContractStatus.已生效)
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

            if (!hasConditon)
            {
                items = items.Where(c => false);
            }


            //if (viewModel.ContractType.HasValue)
            //    items = items.Where(c => c.ContractType == viewModel.ContractType);



            return View("~/Views/ContractConsole/Module/ContractList.ascx", items);
        }

    }
}