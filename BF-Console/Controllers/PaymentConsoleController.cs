﻿using System;
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
using WebHome.Controllers.Base;
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
    public class PaymentConsoleController : PaymentBaseController
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

        public ActionResult ShowCurrentMonthPaymentView(PaymentQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            IQueryable<Payment> items = models.PromptIncomePayment();
            return View("~/Views/PaymentConsole/Module/CurrentMonthPaymentView.cshtml", items);
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
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "收款資料錯誤!!");
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

        public ActionResult GetMerchandiseList(PaymentQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var items = models.GetTable<MerchandiseTransaction>()
                .Where(t => t.TransactionID == viewModel.TransactionID)
                .Select(t => t.MerchandiseWindow)
                .Where(p => p.Status == (int)Naming.MerchandiseStatus.OnSale);

            return View("~/Views/PaymentConsole/Module/MerchandiseList.cshtml", items);

        }

        public ActionResult ApplyCoachAchievementShare(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)ProcessPayment(viewModel);

            Payment item = result.Model as Payment;
            if (item == null)
            {
                return result;
            }

            return View("~/Views/PaymentConsole/PaymentModal/ApplyCoachAchievementShare.cshtml", item);
        }

        public ActionResult ShowAchievementShareList(PaymentQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.PaymentID = viewModel.DecryptKeyValue();
            }

            var items = models.GetTable<TuitionAchievement>().Where(t => t.InstallmentID == viewModel.PaymentID);
            return View("~/Views/PaymentConsole/Module/AchievementShareList.cshtml", items);
        }

        public ActionResult ProcessAchievementShare(PaymentQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.PaymentID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<TuitionAchievement>()
                .Where(t => t.InstallmentID == viewModel.PaymentID)
                .Where(t => t.CoachID == viewModel.CoachID)
                .FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "收款資料錯誤!!");
            }

            return View("~/Views/PaymentConsole/Module/ProcessAchievementShare.cshtml", item);
        }

        public ActionResult DeleteAchievementShare(PaymentQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.PaymentID = viewModel.DecryptKeyValue();
            }

            if (models.ExecuteCommand("delete TuitionAchievement where CoachID = {0} and InstallmentID = {1}",
                    viewModel.CoachID, viewModel.PaymentID) > 0)
            {
                return Json(new { result = true }, JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json(new { result = false, message = "資料錯誤!!" }, JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult EditPaymentForPI2020(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            var lesson = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == viewModel.RegisterID).FirstOrDefault();
            if (!viewModel.RegisterID.HasValue || lesson == null)
            {
                return Json(new { result = false, message = "收款自主訓練資料錯誤!!" }, JsonRequestBehavior.AllowGet);
            }
            else
            {
                viewModel.SellerID = lesson.LessonTime.First().BranchID.Value;
            }

            viewModel.PayoffAmount = lesson.LessonPriceType.ListPrice;
            viewModel.CarrierId1 = lesson.UserProfile.UserProfileExtension?.CarrierNo;
            return View("~/Views/PaymentConsole/Module/EditPaymentForPI2020.cshtml");
        }

        public ActionResult EditPaymentForSession(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            var lesson = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == viewModel.RegisterID).FirstOrDefault();
            LessonTime item;
            if (lesson == null)
            {
                return Json(new { result = false, message = "收款資料錯誤!!" }, JsonRequestBehavior.AllowGet);
            }
            else
            {
                item = lesson.LessonTime.First();

                viewModel.SellerID = lesson.BranchStore?.IsVirtualClassroom() == true
                    ? item.AsAttendingCoach.SelectWorkBranchID()
                    : lesson.LessonTime.First().BranchID.Value;
            }

            viewModel.PayoffAmount = lesson.LessonPriceType.ListPrice;
            viewModel.CarrierId1 = lesson.UserProfile.UserProfileExtension?.CarrierNo;
            return View("~/Views/PaymentConsole/Module/EditPaymentForSession.cshtml", item);
        }

        public ActionResult CommitPaymentForSession(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            var lesson = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == viewModel.RegisterID).FirstOrDefault();
            LessonTime timeItem = null;
            if (lesson == null)
            {
                ModelState.AddModelError("RegisterID", "請選擇收款課程!!");
            }
            else
            {
                timeItem = lesson.LessonTime.First();
                viewModel.SellerID = timeItem.BranchStore?.IsVirtualClassroom() == true
                    ? timeItem.AsAttendingCoach.SelectWorkBranchID()
                    : timeItem.BranchID.Value;
            }

            if (!viewModel.PayoffDate.HasValue)
            {
                ModelState.AddModelError("PayoffDate", "請選擇收款日期!!");
            }

            viewModel.ItemNo = new string[] { "01" };
            viewModel.Brief = new string[] { $"{timeItem.RegisterLesson.LessonPriceType.SimpleDescription}訓練費用" };
            viewModel.CostAmount = new int?[] { viewModel.PayoffAmount };
            viewModel.UnitCost = new int?[] { viewModel.PayoffAmount };
            viewModel.Piece = new int?[] { 1 };
            viewModel.ItemRemark = new string[] { null };
            viewModel.InvoiceType = Naming.InvoiceTypeDefinition.一般稅額計算之電子發票;
            viewModel.CarrierId1 = viewModel.CarrierId1.GetEfficientString();
            viewModel.TransactionType =  (int)Naming.PaymentTransactionType.自主訓練;

            if (viewModel.CarrierId1 != null)
            {
                if (viewModel.CarrierType == null)
                {
                    viewModel.CarrierType = "3J0002";
                }
            }

            var invoice = checkInvoiceNo(viewModel);

            if (String.IsNullOrEmpty(viewModel.PaymentType))
            {
                ModelState.AddModelError("PaymentType", "請選擇收款方式!!");
            }

            if (!viewModel.InvoiceType.HasValue)
            {
                ModelState.AddModelError("InvoiceType", "請選擇發票類型");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(Settings.Default.ReportInputError);
            }

            try
            {
                Payment item = models.GetTable<Payment>()
                    .Where(p => p.PaymentID == viewModel.PaymentID).FirstOrDefault();

                if (item == null)
                {
                    item = new Payment
                    {
                        Status = (int)Naming.CourseContractStatus.已生效,
                        TuitionInstallment = new TuitionInstallment
                        {

                        },
                        PaymentTransaction = new PaymentTransaction
                        { },
                        PaymentAudit = new Models.DataEntity.PaymentAudit { }
                    };
                    item.TuitionAchievement.Add(new TuitionAchievement
                    {
                        CoachID = lesson.AdvisorID.Value,
                        ShareAmount = viewModel.PayoffAmount,
                        CoachWorkPlace = lesson.ServingCoach.WorkBranchID()
                    });
                    models.GetTable<Payment>().InsertOnSubmit(item);
                    item.InvoiceItem = invoice;
                }
                item.TuitionInstallment.RegisterID = lesson.IntuitionCharge.RegisterID;
                item.TuitionInstallment.PayoffAmount = viewModel.PayoffAmount;
                item.TuitionInstallment.PayoffDate = viewModel.PayoffDate;

                item.PaymentTransaction.BranchID = viewModel.SellerID.Value;

                preparePayment(viewModel, profile, item);

                models.SubmitChanges();

                if (timeItem.IsPISession())
                {
                    models.AttendLesson(lesson.LessonTime.First(), profile);
                }

                if (invoice.InvoiceCarrier != null && viewModel.MyCarrier == true)
                {
                    lesson.UserProfile.UserProfileExtension.CarrierType = invoice.InvoiceCarrier.CarrierType;
                    lesson.UserProfile.UserProfileExtension.CarrierNo = invoice.InvoiceCarrier.CarrierNo;
                    models.SubmitChanges();
                }

                TaskExtensionMethods.ProcessInvoiceToGov();

                return Json(new { result = true, invoiceNo = item.InvoiceItem.TrackCode + item.InvoiceItem.No, item.InvoiceID, item.InvoiceItem.InvoiceType, item.PaymentID });
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = ex.Message });
            }
        }



    }
}