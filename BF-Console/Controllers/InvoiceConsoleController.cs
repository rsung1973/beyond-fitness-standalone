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
    public class InvoiceConsoleController : SampleController<UserProfile>
    {
        // GET: InvoiceConsole
        public ActionResult DownloadInvoiceNoIntervalCsv(InvoiceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.TrackID = viewModel.DecryptKeyValue();
            }

            IQueryable<InvoiceTrackCode> items = models.GetTable<InvoiceTrackCode>();

            if (viewModel.TrackID.HasValue)
            {
                items = items.Where(t => t.TrackID == viewModel.TrackID);
            }
            else
            {
                if (!viewModel.DateFrom.HasValue)
                {
                    viewModel.DateFrom = DateTime.Today.FirstDayOfMonth();
                    if (viewModel.DateFrom.Value.Month % 2 == 0)
                    {
                        viewModel.DateFrom = viewModel.DateFrom.Value.AddMonths(-1);
                    }
                }
                items = items.Where(t => t.Year == viewModel.DateFrom.Value.Year)
                            .Where(t => t.PeriodNo == viewModel.TrackPeriodNo);
            }

            viewModel.TrackCode = viewModel.TrackCode.GetEfficientString();
            if (viewModel.TrackCode != null)
            {
                items = items.Where(t => t.TrackCode == viewModel.TrackCode);
            }

            return View("~/Views/InvoiceConsole/Module/DownloadInvoiceNoIntervalCsv.cshtml", items);
        }

        public ActionResult CheckTurnkeyLogs(InvoiceQueryViewModel viewModel)
        {
            if (viewModel.Year.HasValue && viewModel.Month.HasValue)
            {
                viewModel.DateFrom = new DateTime(viewModel.Year.Value, viewModel.Month.Value, 1);
                if (viewModel.DateFrom.Value.Month % 2 == 0)
                {
                    viewModel.DateFrom = viewModel.DateFrom.Value.AddMonths(-1);
                }
                viewModel.DateTo = viewModel.DateFrom.Value.AddMonths(2);
            }
            else
            {
                if (!viewModel.DateFrom.HasValue)
                {
                    viewModel.DateFrom = DateTime.Today.FirstDayOfMonth();
                    if (viewModel.DateFrom.Value.Month % 2 == 0)
                    {
                        viewModel.DateFrom = viewModel.DateFrom.Value.AddMonths(-1);
                    }
                }
                if (!viewModel.DateTo.HasValue)
                {
                    viewModel.DateTo = viewModel.DateFrom.Value.AddMonths(2);
                }
            }

            var items = models.GetTable<InvoiceItem>()
                .Where(i => i.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
                .Where(i => i.InvoiceDate >= viewModel.DateFrom && i.InvoiceDate < viewModel.DateTo);

            ViewBag.ViewModel = viewModel;
            ViewBag.DataItems = items;

            var cancellationItems = models.GetTable<InvoiceCancellation>().Where(i => i.CancelDate >= viewModel.DateFrom && i.CancelDate < viewModel.DateTo);
            ViewBag.CancellationItems = cancellationItems;

            var allowanceItems = models.GetTable<InvoiceAllowance>().Where(a => a.AllowanceDate >= viewModel.DateFrom && a.AllowanceDate < viewModel.DateTo);
            ViewBag.AllowanceItems = allowanceItems;

            void buildInvoiceLogs(DataSet ds)
            {
                var logItems = items.Where(i => i.InvoiceItemDispatchLog == null || !i.InvoiceItemDispatchLog.Status.HasValue || i.InvoiceItemDispatchLog.Status == (int)Naming.GeneralStatus.Failed);
                var details = logItems
                        .OrderBy(i=>i.SellerID)
                        .ThenBy(i=>i.InvoiceID)
                        .ToArray()
                        .Select(i => new
                        {
                            發票號碼 = $"{i.TrackCode}{i.No}",
                            發票日期 = i.InvoiceDate,
                            開立人統編 = i.Organization.ReceiptNo,
                        });

                DataTable table = details.ToDataTable();
                table.TableName = "發票未傳送";
                ds.Tables.Add(table);
            }

            void buildInvoiceCancellationLogs(DataSet ds)
            {
                var calcCancellation = models.GetTable<InvoiceItem>()
                    .Where(i => i.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
                    .Join(models.GetTable<Payment>()
                            .Join(models.GetTable<VoidPayment>().Where(v => v.Status == (int)Naming.CourseContractStatus.已生效),
                                p => p.PaymentID, v => v.VoidID, (p, v) => p),
                        i => i.InvoiceID, p => p.InvoiceID, (i, p) => i)
                    .Join(cancellationItems, i => i.InvoiceID, c => c.InvoiceID, (i, c) => c);

                var logItems = calcCancellation.Where(i => i.InvoiceCancellationDispatchLog == null || !i.InvoiceCancellationDispatchLog.Status.HasValue || i.InvoiceCancellationDispatchLog.Status == (int)Naming.GeneralStatus.Failed);
                var details = logItems
                        .OrderBy(i => i.InvoiceItem.SellerID)
                        .ThenBy(i => i.InvoiceID)
                        .ToArray()
                        .Select(i => new
                        {
                            作廢發票號碼 = $"{i.CancellationNo}",
                            作廢日期 = i.CancelDate,
                            開立人統編 = i.InvoiceItem.Organization.ReceiptNo,
                        });

                DataTable table = details.ToDataTable();
                table.TableName = "作廢發票未傳送";
                ds.Tables.Add(table);
            }

            void buildAllowanceLogs(DataSet ds)
            {
                var calcAllowance = models.GetTable<InvoiceItem>()
                    .Where(i => i.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
                    .Join(allowanceItems, i => i.InvoiceID, c => c.InvoiceID, (i, c) => c);

                var logItems = calcAllowance.Where(i => i.InvoiceAllowanceDispatchLog == null || !i.InvoiceAllowanceDispatchLog.Status.HasValue || i.InvoiceAllowanceDispatchLog.Status == (int)Naming.GeneralStatus.Failed);
                var details = logItems
                        .OrderBy(i => i.InvoiceAllowanceSeller.SellerID)
                        .ThenBy(i => i.AllowanceID)
                        .ToArray()
                        .Select(i => new
                        {
                            折讓單號碼= i.AllowanceNumber,
                            發票號碼 = $"{i.InvoiceItem?.TrackCode}{i.InvoiceItem?.No}",
                            折讓日期 = i.AllowanceDate,
                            開立人統編 = i.InvoiceAllowanceSeller.ReceiptNo,
                        });

                DataTable table = details.ToDataTable();
                table.TableName = "折讓單未傳送";
                ds.Tables.Add(table);
            }


            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AppendCookie(new HttpCookie("fileDownloadToken", viewModel.FileDownloadToken));
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("IncompleteTurnkeyLogs"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                buildInvoiceLogs(ds);
                buildInvoiceCancellationLogs(ds);
                buildAllowanceLogs(ds);

                using (var xls = ds.ConvertToExcel())
                {
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();


        }

    }
}