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

namespace WebHome.Controllers
{
    [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class PaymentConsoleController : SampleController<UserProfile>
    {
        // GET: PaymentConsole
        public ActionResult ShowPaymentList(PaymentQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.PaymentID = viewModel.DecryptKeyValue();
            }

            IQueryable<Payment> items = viewModel.InquirePayment(this, out string alertMessage);
            return View("~/Views/PaymentConsole/Module/PaymentItemsList.cshtml", items);
        }

        public ActionResult InquirePayment(PaymentQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.PaymentID = viewModel.DecryptKeyValue();
            }

            viewModel.CustomQuery = viewModel.CustomQuery.GetEfficientString();
            //if (viewModel.CustomQuery != null)
            //{
            //    viewModel.ContractNo = viewModel.UserName = viewModel.InvoiceNo = viewModel.CustomQuery;
            //}

            if (viewModel.CustomQuery == null)
            {
                bool hasQuery = false;
                if (!viewModel.PayoffDateFrom.HasValue)
                {
                    ModelState.AddModelError("PayoffDateFrom", "請選擇查詢起日");
                }
                else
                {
                    hasQuery = true;
                }

                if (!viewModel.PayoffDateTo.HasValue)
                {
                    ModelState.AddModelError("PayoffDateTo", "請選擇查詢迄日");
                }
                else
                {
                    hasQuery = true;
                }

                if (!hasQuery)
                {
                    ModelState.AddModelError("CustomQuery", "請輸入學生姓名(暱稱) 或 合約編號 或 發票號碼");
                }
            }


            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            IQueryable<Payment> items = viewModel.InquirePayment(this, out string alertMessage);
            return View("~/Views/PaymentConsole/Module/CustomPaymentList.cshtml", items);
        }



        public ActionResult ClearUnpaidContract()
        {
            models.ClearUnpaidOverdueContract();
            return Json(new { result = true }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ProcessPayment(PaymentQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.PaymentID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<Payment>().Where(c => c.PaymentID == viewModel.PaymentID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "收款資料錯誤!!");
            }

            return View("~/Views/PaymentConsole/Module/ProcessPayment.cshtml", item);
        }

        public ActionResult ShowPaymentDetails(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)ProcessPayment(viewModel);

            Payment item = result.Model as Payment;
            if (item == null)
            {
                return result;
            }

            return View("~/Views/PaymentConsole/PaymentModal/AboutPaymentDetails.cshtml", item);
        }

        public ActionResult InvokePaymentQuery(PaymentQueryViewModel viewModel)
        {
            //viewModel.ContractDateFrom = DateTime.Today.FirstDayOfMonth();
            //viewModel.ContractDateTo = viewModel.ContractDateFrom.Value.AddMonths(1).AddDays(-1);
            ViewBag.ViewModel = viewModel;
            return View("~/Views/PaymentConsole/PaymentModal/PaymentQuery.cshtml");
        }


    }
}