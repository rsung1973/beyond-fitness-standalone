using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
using System.Drawing;
using System.Drawing.Imaging;
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

using CommonLib.DataAccess;

using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Helper.Jobs;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;
using CoreHtmlToImage;
using Microsoft.AspNetCore.WebUtilities;
using ImageFormat = System.Drawing.Imaging.ImageFormat;

namespace WebHome.Controllers
{
    [Authorize]
    public class InvoiceController : SampleController<UserProfile>
    {
        public InvoiceController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: Invoice
        public ActionResult InvoiceNoIndex(InvoiceNoViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public async Task<ActionResult> PrintIndexAsync(InvoiceQueryViewModel viewModel)
        {
            if (String.IsNullOrEmpty(viewModel.InvoiceNo) && viewModel.InvoiceID == null)
            {
                viewModel.HandlerID = -1;
            }
            ViewBag.ViewModel = viewModel;
            ViewResult result = (ViewResult)await InquireInvoiceAsync(viewModel);
            return View("PrintIndex",result.Model ?? models.GetTable<Payment>().Where(p => false));
        }

        public ActionResult AllowanceIndex(InvoiceQueryViewModel viewModel)
        {
            return View("AllowanceIndex", models.GetTable<Payment>().Where(p => false));
        }


        public ActionResult TurnkeyIndex(InvoiceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View(viewModel);
        }

        public ActionResult VacantNoIndex(InvoiceNoViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public ActionResult TaxCsvIndex(InvoiceNoViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }


        public async Task<ActionResult> InquireInvoiceNoIntervalAsync(InvoiceNoViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<InvoiceNoInterval> items = models.GetTable<InvoiceNoInterval>()
                .Where(n => n.EndNo >= n.StartNo);

            var profile = await HttpContext.GetUserAsync();
            bool hasCondition = false;

            if (viewModel.BranchID.HasValue)
            {
                items = items.Where(t => t.InvoiceTrackCodeAssignment.SellerID == viewModel.BranchID);
                hasCondition = true;
            }

            if (viewModel.Year.HasValue)
            {
                items = items.Where(t => t.InvoiceTrackCodeAssignment.InvoiceTrackCode.Year == viewModel.Year);
                hasCondition = true;
            }

            if (viewModel.PeriodNo.HasValue)
            {
                items = items.Where(t => t.InvoiceTrackCodeAssignment.InvoiceTrackCode.PeriodNo == viewModel.PeriodNo);
                hasCondition = true;
            }

            if(viewModel.IntervalID.HasValue)
            {
                if(hasCondition)
                {
                    if (!items.Any(i => i.IntervalID == viewModel.IntervalID))
                        items = items.Concat(models.GetTable<InvoiceNoInterval>().Where(t => t.IntervalID == viewModel.IntervalID));
                }
                else
                {
                    items = items.Where(t => t.IntervalID == viewModel.IntervalID);
                }
                hasCondition = true;
            }

            if (viewModel.GroupID.HasValue)
            {
                if (hasCondition)
                {
                    if (!items.Any(i => i.GroupID == viewModel.GroupID))
                        items = items.Concat(models.GetTable<InvoiceNoInterval>().Where(t => t.GroupID == viewModel.GroupID));
                }
                else
                {
                    items = items.Where(t => t.GroupID == viewModel.GroupID);
                }

                hasCondition = true;

            }

            //if (!hasCondition)
            //{
            //    items = items.Where(f => false);
            //}

            return View("~/Views/Invoice/Module/TrackCodeNoList.ascx", items);
        }

        public ActionResult EditInvoiceNoInterval(InvoiceNoViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<InvoiceNoInterval>().Where(t => t.IntervalID == viewModel.IntervalID).FirstOrDefault();
            if(item!=null)
            {
                viewModel.BranchID = item.InvoiceTrackCodeAssignment.SellerID;
                viewModel.StartNo = item.StartNo;
                viewModel.EndNo = item.EndNo;
                viewModel.IntervalID = item.IntervalID;
                viewModel.TrackCode = item.InvoiceTrackCodeAssignment.InvoiceTrackCode.TrackCode;
                viewModel.Year = item.InvoiceTrackCodeAssignment.InvoiceTrackCode.Year;
                viewModel.PeriodNo = item.InvoiceTrackCodeAssignment.InvoiceTrackCode.PeriodNo;
            }
            return View("~/Views/Invoice/Module/EditInvoiceNoInterval.ascx", item);
        }

        public ActionResult EditInvoiceNoIntervalGroup(InvoiceNoViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<InvoiceNoIntervalGroup>().Where(t => t.GroupID == viewModel.GroupID).FirstOrDefault();
            if (item != null)
            {
                var groups = item.InvoiceNoInterval.ToArray();
                viewModel.BranchID = groups[0].InvoiceTrackCodeAssignment.SellerID;
                viewModel.StartNo = groups[0].StartNo;
                viewModel.EndNo = groups[groups.Length-1].EndNo;
                viewModel.IntervalID = groups[0].IntervalID;
                viewModel.TrackCode = groups[0].InvoiceTrackCodeAssignment.InvoiceTrackCode.TrackCode;
                viewModel.Year = groups[0].InvoiceTrackCodeAssignment.InvoiceTrackCode.Year;
                viewModel.PeriodNo = groups[0].InvoiceTrackCodeAssignment.InvoiceTrackCode.PeriodNo;
                viewModel.BookletCount = groups.Select(g => (int?)(g.EndNo - g.StartNo + 1) / 50).ToArray();
                viewModel.BookletBranchID = groups.Select(g => (int?)g.IntervalID).ToArray();
            }
            return View("~/Views/Invoice/Module/EditInvoiceNoIntervalGroup.ascx", item);
        }

        public ActionResult DeleteInvoiceNoInterval(InvoiceNoViewModel viewModel)
        {
            try
            {
                var item = models.GetTable<InvoiceNoInterval>().Where(t => t.IntervalID == viewModel.IntervalID).FirstOrDefault();
                if (item == null)
                {
                    return Json(new { result = false, message = "資料錯誤!!" });
                }
                models.ExecuteCommand(@"delete InvoiceNoInterval where GroupID={0} ", item.GroupID);
                models.ExecuteCommand(@"delete InvoiceNoInterval where IntervalID={0} ", item.IntervalID);
                models.ExecuteCommand(@"delete InvoiceNoIntervalGroup where GroupID={0} ", item.GroupID);
                models.ExecuteCommand(@"DELETE FROM InvoiceTrackCode
                    WHERE   (TrackID NOT IN
                        (SELECT  TrackID
                            FROM     InvoiceNoInterval)) AND (TrackID = {0})", item.TrackID);
                return Json(new { result = true });
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<InvoiceController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
        }

        public async Task<ActionResult> CommitInvoiceNoInterval(InvoiceNoViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (!viewModel.BranchID.HasValue)
            {
                ModelState.AddModelError("BranchID", "請選擇分店!!");
            }

            viewModel.TrackCode = viewModel.TrackCode.GetEfficientString();
            if (viewModel.TrackCode==null || !Regex.IsMatch(viewModel.TrackCode,"[A-Z]{2}"))
            {
                ModelState.AddModelError("TrackCode", "字軌錯誤!!");
            }

            if (!viewModel.Year.HasValue)
            {
                ModelState.AddModelError("Year", "請選擇年份!!");
            }

            if (!viewModel.PeriodNo.HasValue)
            {
                ModelState.AddModelError("PeriodNo", "請選擇期別!!");
            }

            var trackCode = models.GetTable<InvoiceTrackCode>()
                .Where(t => t.TrackCode == viewModel.TrackCode && t.Year == viewModel.Year && t.PeriodNo == viewModel.PeriodNo).FirstOrDefault();

            var table = models.GetTable<InvoiceNoInterval>();
            var item = table.Where(i => i.IntervalID == viewModel.IntervalID).FirstOrDefault();

            if (!viewModel.StartNo.HasValue || !(viewModel.StartNo >= 0 && viewModel.StartNo < 100000000))
            {
                ModelState.AddModelError("StartNo", "起號非8位整數!!");
            }
            else if (!viewModel.EndNo.HasValue || !(viewModel.EndNo >= 0 && viewModel.EndNo < 100000000))
            {
                ModelState.AddModelError("EndNo", "迄號非8位整數!!");
            }
            else if (viewModel.EndNo <= viewModel.StartNo || ((viewModel.EndNo - viewModel.StartNo + 1) % 50 != 0))
            {
                ModelState.AddModelError("StartNo", "不符號碼大小順序與差距為50之倍數原則!!");
            }
            else
            {
                if (item != null)
                {
                    if (item.InvoiceNoAssignment.Count > 0)
                    {
                        ModelState.AddModelError("StartNo", "該區間之號碼已經被使用,不可修改!!!!");
                    }
                    else if (table.Any(t => t.IntervalID != item.IntervalID && t.TrackID == item.TrackID && t.StartNo >= viewModel.EndNo && t.InvoiceNoAssignment.Count > 0
                        && t.SellerID == item.SellerID))
                    {
                        ModelState.AddModelError("StartNo", "違反序時序號原則該區段無法修改!!");
                    }
                    else if (table.Any(t => t.IntervalID != item.IntervalID && t.TrackID == item.TrackID
                        && ((t.EndNo <= viewModel.EndNo && t.EndNo >= viewModel.StartNo) || (t.StartNo <= viewModel.EndNo && t.StartNo >= viewModel.StartNo) || (t.StartNo <= viewModel.StartNo && t.EndNo >= viewModel.StartNo) || (t.StartNo <= viewModel.EndNo && t.EndNo >= viewModel.EndNo))))
                    {
                        ModelState.AddModelError("StartNo", "系統中已存在重疊的區段!!");
                    }
                }
                else
                {
                    if (trackCode != null)
                    {
                        if (table.Any(t => t.TrackID == trackCode.TrackID && t.StartNo >= viewModel.EndNo && t.InvoiceNoAssignment.Count > 0
                            && t.SellerID == viewModel.BranchID))
                        {
                            ModelState.AddModelError("StartNo", "違反序時序號原則該區段無法新增!!");
                        }
                        else if (table.Any(t => t.TrackID == trackCode.TrackID
                            && ((t.EndNo <= viewModel.EndNo && t.EndNo >= viewModel.StartNo) || (t.StartNo <= viewModel.EndNo && t.StartNo >= viewModel.StartNo) || (t.StartNo <= viewModel.StartNo && t.EndNo >= viewModel.StartNo) || (t.StartNo <= viewModel.EndNo && t.EndNo >= viewModel.EndNo))))
                        {
                            ModelState.AddModelError("StartNo", "系統中已存在重疊的區段!!");
                        }
                    }
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            if (item == null)
            {
                if(trackCode==null)
                {
                    trackCode = new InvoiceTrackCode
                    {
                        TrackCode = viewModel.TrackCode,
                        PeriodNo = viewModel.PeriodNo.Value,
                        Year = viewModel.Year.Value
                    };
                    models.GetTable<InvoiceTrackCode>().InsertOnSubmit(trackCode);
                }

                var codeAssignment = trackCode.InvoiceTrackCodeAssignment.Where(t => t.SellerID == viewModel.BranchID).FirstOrDefault();
                if (codeAssignment == null)
                {
                    codeAssignment = new InvoiceTrackCodeAssignment
                    {
                        SellerID = viewModel.BranchID.Value,
                        InvoiceTrackCode = trackCode
                    };

                    trackCode.InvoiceTrackCodeAssignment.Add(codeAssignment);
                }

                item = new InvoiceNoInterval { };
                codeAssignment.InvoiceNoInterval.Add(item);
            }

            item.StartNo = viewModel.StartNo.Value;
            item.EndNo = viewModel.EndNo.Value;

            try
            {
                models.SubmitChanges();
                return Json(new { result = true, item.IntervalID });
            }
            catch(Exception ex)
            {
                ApplicationLogging.CreateLogger<InvoiceController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }

        }

        public async Task<ActionResult> CommitInvoiceNoIntervalGroup(InvoiceNoViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (viewModel.BookletBranchID == null || viewModel.BookletBranchID.Length < 3 || viewModel.BookletBranchID.Any(c => !c.HasValue))
            {
                ModelState.AddModelError("BookletBranchID", "請選擇分店!!");
            }

            viewModel.TrackCode = viewModel.TrackCode.GetEfficientString();
            if (viewModel.TrackCode == null || !Regex.IsMatch(viewModel.TrackCode, "[A-Z]{2}"))
            {
                ModelState.AddModelError("TrackCode", "字軌錯誤!!");
            }

            if (!viewModel.Year.HasValue)
            {
                ModelState.AddModelError("Year", "請選擇年份!!");
            }

            if (!viewModel.PeriodNo.HasValue)
            {
                ModelState.AddModelError("PeriodNo", "請選擇期別!!");
            }

            var trackCode = models.GetTable<InvoiceTrackCode>()
                .Where(t => t.TrackCode == viewModel.TrackCode && t.Year == viewModel.Year && t.PeriodNo == viewModel.PeriodNo).FirstOrDefault();

            var table = models.GetTable<InvoiceNoInterval>()
                    .Where(n => n.EndNo > n.StartNo);
            var item = table.Where(i => i.IntervalID == viewModel.IntervalID).FirstOrDefault();
            int? range;
            if (!viewModel.StartNo.HasValue || !(viewModel.StartNo >= 0 && viewModel.StartNo < 100000000))
            {
                ModelState.AddModelError("StartNo", "起號非8位整數!!");
            }
            else if (!viewModel.EndNo.HasValue || !(viewModel.EndNo >= 0 && viewModel.EndNo < 100000000))
            {
                ModelState.AddModelError("EndNo", "迄號非8位整數!!");
            }
            else if (viewModel.EndNo <= viewModel.StartNo || (((range = viewModel.EndNo - viewModel.StartNo + 1)) % 50 != 0))
            {
                ModelState.AddModelError("StartNo", "不符號碼大小順序與差距為50之倍數原則!!");
            }
            else if (viewModel.BookletCount == null || viewModel.BookletCount.Length < 3 || viewModel.BookletCount.Any(c => !c.HasValue || c < 0))
            {
                ModelState.AddModelError("BookletCount", "請輸入有效本數!!");
            }
            else if (viewModel.BookletCount.Sum(c => c) > (range / 50))
            {
                ModelState.AddModelError("BookletCount", "輸入總本數超過配號區間!!");
            }
            else
            {
                if (item != null)
                {
                    if (item.InvoiceNoAssignment.Count > 0)
                    {
                        ModelState.AddModelError("StartNo", "該區間之號碼已經被使用,不可修改!!!!");
                    }
                    else if (table.Any(t => t.IntervalID != item.IntervalID && t.TrackID == item.TrackID && t.StartNo >= viewModel.EndNo && t.InvoiceNoAssignment.Count > 0
                        && t.SellerID == item.SellerID))
                    {
                        ModelState.AddModelError("StartNo", "違反序時序號原則該區段無法修改!!");
                    }
                    else if (table.Any(t => t.IntervalID != item.IntervalID && t.TrackID == item.TrackID
                        && ((t.EndNo <= viewModel.EndNo && t.EndNo >= viewModel.StartNo) || (t.StartNo <= viewModel.EndNo && t.StartNo >= viewModel.StartNo) || (t.StartNo <= viewModel.StartNo && t.EndNo >= viewModel.StartNo) || (t.StartNo <= viewModel.EndNo && t.EndNo >= viewModel.EndNo))))
                    {
                        ModelState.AddModelError("StartNo", "系統中已存在重疊的區段!!");
                    }
                }
                else
                {
                    if (trackCode != null)
                    {
                        if (table.Any(t => t.TrackID == trackCode.TrackID && t.StartNo >= viewModel.EndNo && t.InvoiceNoAssignment.Count > 0))
                        {
                            ModelState.AddModelError("StartNo", "違反序時序號原則該區段無法新增!!");
                        }
                        else if (table.Any(t => t.TrackID == trackCode.TrackID
                            && ((t.EndNo <= viewModel.EndNo && t.EndNo >= viewModel.StartNo) || (t.StartNo <= viewModel.EndNo && t.StartNo >= viewModel.StartNo) || (t.StartNo <= viewModel.StartNo && t.EndNo >= viewModel.StartNo) || (t.StartNo <= viewModel.EndNo && t.EndNo >= viewModel.EndNo))))
                        {
                            ModelState.AddModelError("StartNo", "系統中已存在重疊的區段!!");
                        }
                    }
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            if (item != null)
            {
                models.DeleteAllOnSubmit<InvoiceNoInterval>(i => i.GroupID == item.IntervalID);
            }

            if (trackCode == null)
            {
                trackCode = new InvoiceTrackCode
                {
                    TrackCode = viewModel.TrackCode,
                    PeriodNo = viewModel.PeriodNo.Value,
                    Year = viewModel.Year.Value
                };
                models.GetTable<InvoiceTrackCode>().InsertOnSubmit(trackCode);
            }

            InvoiceNoInterval prevItem = null;
            for (int i = 0; i < viewModel.BookletBranchID.Length; i++)
            {
                var branchID = viewModel.BookletBranchID[i];
                var bookletCount = viewModel.BookletCount[i];

                var codeAssignment = trackCode.InvoiceTrackCodeAssignment.Where(t => t.SellerID == branchID.Value).FirstOrDefault();
                if (codeAssignment == null)
                {
                    codeAssignment = new InvoiceTrackCodeAssignment
                    {
                        SellerID = branchID.Value,
                        InvoiceTrackCode = trackCode
                    };

                    trackCode.InvoiceTrackCodeAssignment.Add(codeAssignment);
                }

                item = new InvoiceNoInterval
                {

                };
                if (i == 0)
                {
                    item.StartNo = viewModel.StartNo.Value;
                    item.EndNo = item.StartNo + (bookletCount.Value * 50) - 1;
                    item.InvoiceNoIntervalGroup = new InvoiceNoIntervalGroup { };
                }
                else
                {
                    item.StartNo = prevItem.EndNo + 1;
                    item.EndNo = item.StartNo + (bookletCount.Value * 50) - 1;
                    item.InvoiceNoIntervalGroup = prevItem.InvoiceNoIntervalGroup;
                }
                codeAssignment.InvoiceNoInterval.Add(item);
                prevItem = item;
            }

            try
            {
                models.SubmitChanges();
                return Json(new { result = true, item.GroupID });
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<InvoiceController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }

        }

        public ActionResult InquireInvoiceDispatchLog(InvoiceQueryViewModel viewModel)
        {
            return View("~/Views/Invoice/Module/InvoiceDispatchLogSummary.cshtml", viewModel);

        }


        public async Task<ActionResult> InquireInvoiceAsync(InvoiceQueryViewModel viewModel)
        {
            IQueryable<InvoiceItem> items = models.GetTable<InvoiceItem>().Where(i => i.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票);
            IQueryable<Payment> paymentItems = models.GetTable<Payment>();

            var profile = await HttpContext.GetUserAsync();

            bool hasConditon = false;

            if(viewModel.InvoiceID!=null &&viewModel.InvoiceID.Length>0)
            {
                items = items.Where(i => viewModel.InvoiceID.Contains(i.InvoiceID));
            }

            viewModel.InvoiceNo = viewModel.InvoiceNo.GetEfficientString();
            if (viewModel.InvoiceNo != null)
            {
                if (Regex.IsMatch(viewModel.InvoiceNo, "[A-Za-z]{2}[0-9]{8}"))
                {
                    String trackCode = viewModel.InvoiceNo.Substring(0, 2).ToUpper();
                    String no = viewModel.InvoiceNo.Substring(2);
                    items = items.Where(c => c.TrackCode == trackCode
                        && c.No == no);
                    hasConditon = true;
                }
                else
                {
                    ModelState.AddModelError("InvoiceNo", "請輸入正確發票號碼!!");
                }
            }

            if(viewModel.DispatchStatus.HasValue)
            {
                items = items
                    .Join(models.GetTable<InvoiceItemDispatchLog>().Where(d => d.Status == viewModel.DispatchStatus),
                        i => i.InvoiceID, d => d.InvoiceID, (i, d) => i);
            }

            if (!hasConditon)
            {
                if (viewModel.BranchID.HasValue)
                {
                    hasConditon = true;
                    paymentItems = paymentItems.Where(c => c.PaymentTransaction.BranchID == viewModel.BranchID);
                }
            }

            if (!hasConditon)
            {
                if (viewModel.HandlerID.HasValue)
                {
                    hasConditon = true;
                    paymentItems = paymentItems.Where(c => c.HandlerID == viewModel.HandlerID);
                }
            }

            if (!hasConditon)
            {
                if (profile.IsAssistant() || profile.IsAccounting() || profile.IsOfficer())
                {

                }
                else if (profile.IsManager() || profile.IsViceManager())
                {
                    var branches = models.GetTable<BranchStore>().Where(b => b.ManagerID == profile.UID || b.ViceManagerID == profile.UID);
                    paymentItems = paymentItems
                            .Join(models.GetTable<PaymentTransaction>()
                                .Join(branches, p => p.BranchID, b => b.BranchID, (p, b) => p),
                                c => c.PaymentID, h => h.PaymentID, (c, h) => c);
                }
                else if (profile.IsCoach())
                {
                    paymentItems = paymentItems.Where(c => c.HandlerID == profile.UID);
                }
                else
                {
                    items = items.Where(p => false);
                }
            }

            if (viewModel.IsPrinted.HasValue)
            {
                if (viewModel.IsPrinted == true)
                {
                    items = items.Where(i => i.Document.DocumentPrintLog.Count > 0);
                }
                else if (viewModel.IsPrinted == false)
                {
                    items = items.Where(i => i.Document.DocumentPrintLog.Count == 0);
                }
            }

            if (viewModel.InvoiceType.HasValue)
            {
                items = items.Where(c => c.InvoiceType == (byte)viewModel.InvoiceType);
            }

            if (viewModel.DateFrom.HasValue && viewModel.DocType==Naming.DocumentTypeDefinition.E_Invoice)
                items = items.Where(c => c.InvoiceDate >= viewModel.DateFrom);

            if (viewModel.DateTo.HasValue && viewModel.DocType == Naming.DocumentTypeDefinition.E_Invoice)
                items = items.Where(c => c.InvoiceDate < viewModel.DateTo.Value.AddDays(1));

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            if (viewModel.DocType == Naming.DocumentTypeDefinition.E_Allowance)
            {
                IQueryable<InvoiceAllowance> allowanceItems = models.GetTable<InvoiceAllowance>();

                if (viewModel.DateFrom.HasValue)
                    allowanceItems = allowanceItems.Where(c => c.AllowanceDate >= viewModel.DateFrom);

                if (viewModel.DateTo.HasValue)
                    allowanceItems = allowanceItems.Where(c => c.AllowanceDate < viewModel.DateTo.Value.AddDays(1));

                items = items.Join(allowanceItems, i => i.InvoiceID, a => a.InvoiceID, (i, a) => i);
                paymentItems = paymentItems.Join(items, p => p.InvoiceID, i => i.InvoiceID, (p, i) => p);

                return View("~/Views/Invoice/Module/AllowanceItemList.ascx", paymentItems);

            }
            else
            {
                paymentItems = paymentItems.Join(items, p => p.InvoiceID, i => i.InvoiceID, (p, i) => p);

                return View("~/Views/Invoice/Module/InvoiceItemList.ascx", paymentItems);
            }

        }

        public async Task<ActionResult> InquireInvoiceByDispatch(InvoiceQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquireInvoiceAsync(viewModel);
            if(result.Model is IQueryable<Payment>)
            {
                result.ViewName = "~/Views/Invoice/Module/InvoiceItemSummary.ascx";
            }
            return result;
        }

        public async Task<ActionResult> InquireInvoiceToCommitAllowance(InvoiceQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquireInvoiceAsync(viewModel);
            if (result.Model is IQueryable<Payment>)
            {
                ViewBag.DataAction = "CommitAllowance";
                result.ViewName = "~/Views/Invoice/Module/InvoiceItemList.ascx";
            }
            return result;
        }

        public async Task<ActionResult> PrintAll(InvoiceQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquireInvoiceAsync(viewModel);
            IQueryable<Payment> items = (IQueryable<Payment>)result.Model;

            string pdfFile = await createInvoicePDFAsync(items.Select(p => p.InvoiceItem));
            return new PhysicalFileResult(pdfFile, "application/octet-stream"/*, Path.GetFileName(pdfFile)*/);

        }

        public async Task<ActionResult> PrintAllInvoice(InvoiceQueryViewModel viewModel, String printerIP)
        {
            ViewResult result = (ViewResult)await InquireInvoiceAsync(viewModel);
            IQueryable<Payment> items = (IQueryable<Payment>)result.Model;
            ViewBag.PrinterIP = printerIP;
            return View("PrintInvoiceImage", items.Select(p => p.InvoiceItem));
         }


        [AllowAnonymous]
        public ActionResult PrintInvoice(InvoiceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var items = models.GetTable<InvoiceItem>().Where(i => false);
            if (viewModel.InvoiceID != null && viewModel.InvoiceID.Length > 0)
            {
                items = models.GetTable<InvoiceItem>().Where(i => viewModel.InvoiceID.Contains(i.InvoiceID));
            }
            else if(viewModel.UID.HasValue)
            {
                var profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
                if (profile != null)
                {
                    items = models.GetTable<DocumentPrintQueue>().Where(d => d.UID == viewModel.UID)
                        .Join(models.GetTable<InvoiceItem>(), d => d.DocID, i => i.InvoiceID, (d, i) => i);
                }
            }
            else
            {
                viewModel.InvoiceNo = viewModel.InvoiceNo.GetEfficientString();
                if (viewModel.InvoiceNo != null)
                {
                    if (Regex.IsMatch(viewModel.InvoiceNo, "[A-Za-z]{2}[0-9]{8}"))
                    {
                        String trackCode = viewModel.InvoiceNo.Substring(0, 2).ToUpper();
                        String no = viewModel.InvoiceNo.Substring(2);
                        items = models.GetTable<InvoiceItem>().Where(c => c.TrackCode == trackCode
                            && c.No == no);
                    }
                }
            }
            return View(items);
        }

        [AllowAnonymous]
        public ActionResult CanvasPrintInvoice(InvoiceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewResult result = (ViewResult)PrintInvoice(viewModel);
            result.ViewName = "CanvasPrintInvoice";
            return result;
        }


        public ActionResult CanvasDrawInvoice(InvoiceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewResult result = (ViewResult)PrintInvoice(viewModel);
            result.ViewName = "CanvasDrawInvoice";
            return result;
        }

        public ActionResult LoadInvoiceImage(InvoiceQueryViewModel viewModel,String printerIP)
        {
            ViewBag.ViewModel = viewModel;
            ViewResult result = (ViewResult)PrintInvoice(viewModel);
            //if (String.IsNullOrEmpty(printerIP))
            //{
            //    result.ViewName = "LoadInvoiceImage";
            //}
            //else
            {
                ViewBag.PrinterIP = printerIP;
                result.ViewName = "~/Views/Invoice/PrintInvoiceImage.cshtml";
            }
            return result;
        }

        [AllowAnonymous]
        public async Task<ActionResult> LoadInvoiceImageByUID(InvoiceQueryViewModel viewModel, String printerIP)
        {
            var profile = await HttpContext.GetUserAsync();
            if(profile==null)
            {
                profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
                if (profile != null)
                    await HttpContext.SignOnAsync(profile);
            }

            return LoadInvoiceImage(viewModel, printerIP);
        }

        public ActionResult PrintAllowanceImage(InvoiceQueryViewModel viewModel, String printerIP)
        {
            ViewBag.ViewModel = viewModel;
            ViewResult result = (ViewResult)PrintAllowance(viewModel);
            result.ViewName = "~/Views/Invoice/PrintAllowanceImage.cshtml";
            ViewBag.PrinterIP = printerIP;
            return result;
        }

        [AllowAnonymous]
        public async Task<ActionResult> PrintAllowanceImageByUID(InvoiceQueryViewModel viewModel, String printerIP)
        {
            var profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
                if (profile != null)
                    await HttpContext.SignOnAsync(profile);
            }

            return PrintAllowanceImage(viewModel, printerIP);
        }



        [AllowAnonymous]
        public async Task<ActionResult> DrawInvoiceAsync(InvoiceQueryViewModel viewModel)
        {
            //HtmlRender.RenderToImage
            //ViewBag.ViewModel = viewModel;
            //ViewResult result = (ViewResult)PrintInvoice(viewModel);
            //result.ViewName = "CanvasDrawInvoice";
            //return result;
            String viewUrl = $"{Startup.Properties["HostDomain"]}{VirtualPathUtility.ToAbsolute("~/Invoice/CanvasPrintInvoice")}{Request.QueryString}";
            var converter = new HtmlConverter();
            var bytes = converter.FromUrl(viewUrl);

            Response.ContentType = "image/jpeg";
            using (FileBufferingWriteStream output = new FileBufferingWriteStream())
            {
                output.Write(bytes);
                //output.Seek(0, SeekOrigin.Begin);
                await output.DrainBufferAsync(Response.Body);
            }

            return new EmptyResult();
        }

        [AllowAnonymous]
        public async Task<ActionResult> DrawAllowanceAsync(InvoiceQueryViewModel viewModel)
        {
            String viewUrl = $"{Startup.Properties["HostDomain"]}{VirtualPathUtility.ToAbsolute("~/Invoice/CanvasPrintAllowance")}{Request.QueryString}";
            var converter = new HtmlConverter();
            var bytes = converter.FromUrl(viewUrl);

            Response.ContentType = "image/jpeg";
            using (FileBufferingWriteStream output = new FileBufferingWriteStream())
            {
                output.Write(bytes);
                //output.Seek(0, SeekOrigin.Begin);
                await output.DrainBufferAsync(Response.Body);
            }

            return new EmptyResult();
        }

        public ActionResult GetPrinterIP(int? companyID)
        {
            var item = models.GetTable<Organization>().Where(o => o.CompanyID == companyID).FirstOrDefault();
            return Json(new { printerIP = item != null ? item.InvoiceSignature : null });
        }

        public ActionResult UpdatePrinterIP(int? companyID,String printerIP)
        {
            var item = models.GetTable<Organization>().Where(o => o.CompanyID == companyID).FirstOrDefault();
            if(item!=null)
            {
                item.InvoiceSignature = printerIP;
                models.SubmitChanges();
                return Json(new { result = true });
            }
            return Json(new { result = false });
        }

        public async Task<ActionResult> CaptchaImgAsync(String code)
        {

            string captcha = code;

            Response.ContentType = "image/Png";
            using (Bitmap bmp = new Bitmap(120, 30))
            {
                int x1 = 0;
                int y1 = 0;
                int x2 = 0;
                int y2 = 0;
                int x3 = 0;
                int y3 = 0;
                int intNoiseWidth = 25;
                int intNoiseHeight = 15;
                Random rdn = new Random();
                using (Graphics g = Graphics.FromImage(bmp))
                {

                    //設定字型
                    using (Font font = new Font("Courier New", 16, FontStyle.Bold))
                    {

                        //設定圖片背景
                        g.Clear(Color.CadetBlue);

                        //產生雜點
                        for (int i = 0; i < 100; i++)
                        {
                            x1 = rdn.Next(0, bmp.Width);
                            y1 = rdn.Next(0, bmp.Height);
                            bmp.SetPixel(x1, y1, Color.DarkGreen);
                        }

                        using (Pen pen = new Pen(Brushes.Gray))
                        {
                            //產生擾亂弧線
                            for (int i = 0; i < 15; i++)
                            {
                                x1 = rdn.Next(bmp.Width - intNoiseWidth);
                                y1 = rdn.Next(bmp.Height - intNoiseHeight);
                                x2 = rdn.Next(1, intNoiseWidth);
                                y2 = rdn.Next(1, intNoiseHeight);
                                x3 = rdn.Next(0, 45);
                                y3 = rdn.Next(-270, 270);
                                g.DrawArc(pen, x1, y1, x2, y2, x3, y3);
                            }
                        }

                        //把GenPassword()方法換成你自己的密碼產生器，記得把產生出來的密碼存起來日後才能與user的輸入做比較。

                        g.DrawString(captcha, font, Brushes.Black, 3, 3);


                        Response.ContentType = "image/Png";
                        using (FileBufferingWriteStream output = new FileBufferingWriteStream())
                        {
                            bmp.Save(output, ImageFormat.Png);
                            ////output.Seek(0, SeekOrigin.Begin);
                            await output.DrainBufferAsync(Response.Body);
                            //await output.CopyToAsync(Response.Body);
                        }

                        //context.Response.End();
                    }
                }
            }

            return new EmptyResult();
        }



        [AllowAnonymous]
        public ActionResult PrintAllowance(InvoiceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var items = models.GetTable<InvoiceAllowance>().Where(i => false);
            if (viewModel.AllowanceID != null && viewModel.AllowanceID.Length > 0)
            {
                items = models.GetTable<InvoiceAllowance>().Where(i => viewModel.AllowanceID.Contains(i.AllowanceID));
            }
            else if (viewModel.UID.HasValue)
            {
                var profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
                if (profile != null)
                {
                    items = models.GetTable<DocumentPrintQueue>().Where(d => d.UID == viewModel.UID)
                        .Join(models.GetTable<InvoiceAllowance>(), d => d.DocID, i => i.AllowanceID, (d, i) => i);
                }
            }
            else
            {
                viewModel.InvoiceNo = viewModel.InvoiceNo.GetEfficientString();
                if (viewModel.InvoiceNo != null)
                {
                        items = models.GetTable<InvoiceAllowance>().Where(c => c.AllowanceNumber==viewModel.InvoiceNo);
                }
            }
            return View(items);
        }

        [AllowAnonymous]
        public ActionResult CanvasPrintAllowance(InvoiceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewResult result = (ViewResult)PrintAllowance(viewModel);
            result.ViewName = "CanvasPrintAllowance";
            return result;
        }


        public async Task<ActionResult> GetInvoicePDF(InvoiceQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)PrintInvoice(viewModel);
            IQueryable<InvoiceItem> items = (IQueryable<InvoiceItem>)result.Model;

            string pdfFile = await createInvoicePDFAsync(items);
            return new PhysicalFileResult(pdfFile, "application/pdf");
            //return new PhysicalFileResult(pdfFile, "application/pdf", Path.GetFileName(pdfFile));

        }

        public async Task<ActionResult> GetAllowancePDF(InvoiceQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)PrintAllowance(viewModel);
            IQueryable<InvoiceAllowance> items = (IQueryable<InvoiceAllowance>)result.Model;

            string pdfFile = await createAllowancePDFAsync(items);
            //return new PhysicalFileResult(pdfFile, "application/pdf", Path.GetFileName(pdfFile));
            return new PhysicalFileResult(pdfFile, "application/pdf");

        }

        private async Task<string> createInvoicePDFAsync(IQueryable<InvoiceItem> items)
        {
            var profile = await HttpContext.GetUserAsync();
            var queue = models.GetTable<DocumentPrintQueue>();
            foreach (var item in items)
            {
                if (!queue.Any(d => d.UID == profile.UID && d.DocID == item.InvoiceID))
                {
                    queue.InsertOnSubmit(new DocumentPrintQueue
                    {
                        UID = profile.UID,
                        DocID = item.InvoiceID,
                        SubmitDate = DateTime.Now
                    });
                    models.SubmitChanges();
                }
            }

            String pdfFile = profile.CreateQueuedInvoicePDF();
            return pdfFile;
        }

        private async Task<string> createAllowancePDFAsync(IQueryable<InvoiceAllowance> items)
        {
            var profile = await HttpContext.GetUserAsync();
            var queue = models.GetTable<DocumentPrintQueue>();
            foreach (var item in items)
            {
                if (!queue.Any(d => d.UID == profile.UID && d.DocID == item.InvoiceID))
                {
                    queue.InsertOnSubmit(new DocumentPrintQueue
                    {
                        UID = profile.UID,
                        DocID = item.AllowanceID,
                        SubmitDate = DateTime.Now
                    });
                    models.SubmitChanges();
                }
            }

            String pdfFile = profile.CreateQueuedAllowancePDF();
            return pdfFile;
        }


        public ActionResult InquireVacantNo(InvoiceNoViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.Year.HasValue)
            {
                ModelState.AddModelError("Year", "請選擇發票年度!!");
            }

            if (!viewModel.PeriodNo.HasValue)
            {
                ModelState.AddModelError("PeriodNo", "請選擇發票期別!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            var items = models.GetTable<BranchStore>();

            models.ProcessVacantNo(viewModel.Year.Value, viewModel.PeriodNo.Value);

            return View("~/Views/Invoice/Module/VacantNoList.ascx", items);
        }

        public ActionResult DownloadVacantNoCsv(InvoiceNoViewModel viewModel)
        {

            List<InquireVacantNoResult> items = models.DataContext.InquireVacantNo(viewModel.BranchID, viewModel.Year, viewModel.PeriodNo).ToList();
            return View("~/Views/Invoice/Module/DownloadVacantNoCsv.ascx", items);

        }

        public ActionResult ProcessE0402(InvoiceNoViewModel viewModel)
        {
            try
            {
                models.ProcessE0402(viewModel.Year.Value, viewModel.PeriodNo.Value, viewModel.BranchID);
                return Json(new { result = true });
            }
            catch(Exception ex)
            {
                ApplicationLogging.CreateLogger<InvoiceController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
        }

        public async Task<ActionResult> DownloadInvoiceNoIntervalCsv(InvoiceNoViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquireInvoiceNoIntervalAsync(viewModel);
            return View("~/Views/Invoice/Module/DownloadInvoiceNoIntervalCsv.ascx", result.Model);
        }

        public ActionResult InquireInvoiceMedia(InvoiceNoViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.Year.HasValue)
            {
                ModelState.AddModelError("Year", "請選擇年份!!");
            }

            if (!viewModel.PeriodNo.HasValue)
            {
                ModelState.AddModelError("PeriodNo", "請選擇期別!!");
            }

            if (!viewModel.BranchID.HasValue)
            {
                ModelState.AddModelError("BranchID", "請選擇分店!!");
            }


            DateTime startDate = new DateTime((int)viewModel.Year, (int)viewModel.PeriodNo * 2 - 1, 1);
            DataLoadOptions ops = new DataLoadOptions();
            ops.LoadWith<InvoiceItem>(i => i.InvoiceBuyer);
            ops.LoadWith<InvoiceItem>(i => i.InvoiceCancellation);
            ops.LoadWith<InvoiceItem>(i => i.InvoiceAmountType);
            ops.LoadWith<InvoiceItem>(i => i.InvoiceSeller);
            models.DataContext.LoadOptions = ops;

            var items = models.GetTable<InvoiceItem>().Where(i => i.SellerID == viewModel.BranchID
                        && i.InvoiceDate >= startDate
                        && i.InvoiceDate < startDate.AddMonths(2))
                    .Where(i => i.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
                    .OrderBy(i => i.InvoiceID);

            var allowance = models.GetTable<InvoiceAllowance>()
                    .Where(a => a.InvoiceAllowanceCancellation == null)
                    .Where(a => a.InvoiceAllowanceSeller.SellerID == viewModel.BranchID)
                    .Where(a => a.AllowanceDate >= startDate && a.AllowanceDate < startDate.AddMonths(2))
                    .Join(models.GetTable<Payment>()
                        .Join(models.GetTable<InvoiceItem>().Where(i => i.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票),
                            p => p.InvoiceID, i => i.InvoiceID, (p, i) => p),
                        a => a.AllowanceID, p => p.AllowanceID, (a, p) => a);

            ViewBag.AllowanceItems = allowance;

            return View("~/Views/Invoice/Module/InquireInvoiceMedia.ascx", items);

        }




        public ActionResult CheckInvoiceDispatch()
        {
            (new CheckInvoiceDispatch()).DoJob();
            return Json(new { result = true });
        }

        public ActionResult ResetProcessInvoiceToGov()
        {
            return Json(new { result = true, initialCount = TaskExtensionMethods.ResetProcessInvoiceToGov() });
        }

        public async Task<ActionResult> VoidInvoice(InvoiceQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await InquireInvoiceAsync(viewModel);
            IQueryable<Payment> items = (IQueryable<Payment>)result.Model;

            if (items.Count() > 0)
            {
                String C0701Outbound = Path.Combine(Startup.Properties["EINVTurnKeyPath"], "C0701", "SRC");
                if (!Directory.Exists(C0701Outbound))
                {
                    Directory.CreateDirectory(C0701Outbound);
                }

                foreach (var item in items.Select(p=>p.InvoiceItem).Where(i=>i.InvoiceType==(int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票).ToArray())
                {
                    String fileName = Path.Combine(C0701Outbound, item.TrackCode + item.No + ".xml");
                    item.CreateC0701().ConvertToXml().Save(fileName);
                }
            }

            return Json(new { result = true });
        }

    }
}