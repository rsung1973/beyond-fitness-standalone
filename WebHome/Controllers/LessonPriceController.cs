using System;
using System.Collections.Generic;
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
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Newtonsoft.Json;


using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Security.Authorization;
using WebHome.Properties;
using Microsoft.Extensions.Logging;

namespace WebHome.Controllers
{
    [Authorize]
    public class LessonPriceController : SampleController<UserProfile>
    {
        public LessonPriceController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: LessonPrice
        public ActionResult PriceIndex()
        {
            return View("PriceIndex");
        }

        public ActionResult InquirePriceSeries(LessonPriceQueryViewModel viewModel)
        {
            IQueryable<LessonPriceSeries> items = models.GetTable<LessonPriceSeries>();
            if(viewModel.Status.HasValue)
            {
                items = items.Where(p => p.Status == viewModel.Status);
            }
            if (viewModel.Year.HasValue)
            {
                items = items.Where(p => p.Year == viewModel.Year);
            }
            if (viewModel.BranchID.HasValue)
            {
                items = items.Where(p => p.LessonPriceType.BranchID == viewModel.BranchID);
            }

            return View("~/Views/LessonPrice/Module/PriceSeriesList.ascx", items);
        }

        public ActionResult InquireProjectCourse(LessonPriceQueryViewModel viewModel)
        {
            IQueryable<LessonPriceType> items = models.GetTable<LessonPriceType>()
                .Where(p => !p.SeriesID.HasValue)
                .Where(p => p.BranchID.HasValue)
                .Where(p => p.IsInternalLesson == null)
                .Where(p => p.IsWelfareGiftLesson == null)
                .Where(p => p.Status == (int)Naming.LessonPriceStatus.一般課程 || p.Status == (int)Naming.LessonPriceStatus.已刪除);

            if (viewModel.Status.HasValue)
            {
                items = items.Where(p => p.Status == viewModel.Status);
            }
            if (viewModel.BranchID.HasValue)
            {
                items = items.Where(p => p.BranchID == viewModel.BranchID);
            }

            return View("~/Views/LessonPrice/Module/ProjectCourseList.ascx", items);
        }

        public ActionResult DeleteLessonPrice(LessonPriceQueryViewModel viewModel)
        {
            LessonPriceType item;
            try
            {
                item = models.DeleteAny<LessonPriceType>(p => p.PriceID == viewModel.PriceID);
                if (item != null)
                {
                    return Json(new { result = true });
                }
                return Json(new { result = false, message = "資料錯誤!!" });
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<LessonPriceController>().LogError(ex, ex.Message);
            }

            item = models.GetTable<LessonPriceType>().Where(l => l.PriceID == viewModel.PriceID).FirstOrDefault();
            if(item==null)
                return Json(new { result = false, message = "資料錯誤!!" });

            item.Status = (int)Naming.LessonSeriesStatus.已停用;
            models.SubmitChanges();

            return Json(new { result = true, message = "價目已使用，無法刪除，已改為停用!!" });

        }

        public ActionResult DeletePriceSeries(LessonPriceQueryViewModel viewModel)
        {
            try
            {
                models.ExecuteCommand("update LessonPriceSeries set Status = {0} where PriceID = {1}", Naming.LessonSeriesStatus.已停用, viewModel.SeriesID);
                models.ExecuteCommand("update LessonPriceType set Status = {0} where SeriesID = {1}", Naming.LessonSeriesStatus.已停用, viewModel.SeriesID);
                models.ExecuteCommand("delete LessonPriceType where SeriesID = {0}", viewModel.SeriesID);
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<LessonPriceController>().LogError(ex, ex.Message);
                return Json(new { result = true, message = "價目已使用，無法刪除，已改為停用!!" });
            }

            return Json(new { result = true });

        }

        public ActionResult EditProjectCourse(LessonPriceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<LessonPriceType>().Where(p => p.PriceID == viewModel.PriceID).FirstOrDefault();
            if(item!=null)
            {
                viewModel.Description = item.Description;
                viewModel.DurationInMinutes = item.DurationInMinutes;
                viewModel.BranchID = item.BranchID;
                viewModel.ListPrice = item.ListPrice;
                viewModel.Status = item.Status;
            }
            return View("~/Views/LessonPrice/Module/EditProjectCourse.ascx", item);
        }

        public ActionResult EditPriceSeries(LessonPriceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.ListPriceSeries = new int?[16];
            viewModel.PriceSeriesID = new int?[16];
            viewModel.ReadOnly = new bool?[16];

            var item = models.GetTable<LessonPriceSeries>().Where(p => p.PriceID == viewModel.SeriesID).FirstOrDefault();
            if (item != null)
            {
                viewModel.Year = item.Year;
                viewModel.BranchID = item.LessonPriceType.BranchID;
                viewModel.Status = item.Status;

                var priceItems = item.AllLessonPrice.ToArray();
                var limitItems = new int[] { 1, 25, 50, 75 };
                for (int i = 0; i < limitItems.Length; i++)
                {
                    var price = priceItems.Where(p => p.LowerLimit == limitItems[i] && p.DurationInMinutes == 60 && !p.Description.Contains("舊會員")).FirstOrDefault();
                    if (price != null)
                    {
                        viewModel.ListPriceSeries[i * 4] = price.ListPrice;
                        viewModel.PriceSeriesID[i * 4] = price.PriceID;
                        viewModel.ReadOnly[i * 4] = price.RegisterLesson.Count > 0 || price.CourseContract.Count > 0;
                    }
                    price = priceItems.Where(p => p.LowerLimit == limitItems[i] && p.DurationInMinutes == 90 && !p.Description.Contains("舊會員")).FirstOrDefault();
                    if (price != null)
                    {
                        viewModel.ListPriceSeries[i * 4 + 1] = price.ListPrice;
                        viewModel.PriceSeriesID[i * 4 + 1] = price.PriceID;
                        viewModel.ReadOnly[i * 4 + 1] = price.RegisterLesson.Count > 0 || price.CourseContract.Count > 0;
                    }
                    price = priceItems.Where(p => p.LowerLimit == limitItems[i] && p.DurationInMinutes == 60 && p.Description.Contains("舊會員")).FirstOrDefault();
                    if (price != null)
                    {
                        viewModel.ListPriceSeries[i * 4 + 2] = price.ListPrice;
                        viewModel.PriceSeriesID[i * 4 + 2] = price.PriceID;
                        viewModel.ReadOnly[i * 4 + 2] = price.RegisterLesson.Count > 0 || price.CourseContract.Count > 0;
                    }
                    price = priceItems.Where(p => p.LowerLimit == limitItems[i] && p.DurationInMinutes == 90 && p.Description.Contains("舊會員")).FirstOrDefault();
                    if (price != null)
                    {
                        viewModel.ListPriceSeries[i * 4 + 3] = price.ListPrice;
                        viewModel.PriceSeriesID[i * 4 + 3] = price.PriceID;
                        viewModel.ReadOnly[i * 4 + 3] = price.RegisterLesson.Count > 0 || price.CourseContract.Count > 0;
                    }
                }
            }

            return View("~/Views/LessonPrice/Module/EditPriceSeries.ascx");

        }


        public ActionResult CommitProjectCourse(LessonPriceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.Description = viewModel.Description.GetEfficientString();
            if(viewModel.Description==null)
            {
                ModelState.AddModelError("Description", "請輸入專案名稱!!");
            }

            if (!viewModel.ListPrice.HasValue)
            {
                ModelState.AddModelError("ListPrice", "請輸入價格!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            LessonPriceType item = models.GetTable<LessonPriceType>()
                .Where(p => p.PriceID == viewModel.PriceID).FirstOrDefault();

            if (item == null)
            {
                item = new LessonPriceType
                {
                    PriceID = models.GetTable<LessonPriceType>().Select(p => p.PriceID).Max() + 1,
                    Status = (int)Naming.LessonSeriesStatus.已啟用,
                    LowerLimit = 999
                };
                models.GetTable<LessonPriceType>().InsertOnSubmit(item);
            }

            item.Description = viewModel.Description;
            item.ListPrice = item.CoachPayoffCreditCard = item.CoachPayoff = viewModel.ListPrice;
            item.Status = viewModel.Status;
            item.BranchID = viewModel.BranchID;
            item.DurationInMinutes = viewModel.DurationInMinutes;

            models.SubmitChanges();

            return Json(new { result = true });
        }

        public ActionResult CommitPriceSeries(LessonPriceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if(viewModel.ListPriceSeries==null || viewModel.ListPriceSeries.Length!=16
                || viewModel.ListPriceSeries.Any(p=>!p.HasValue))
            {
                ModelState.AddModelError("ListPriceSeries", "請輸入價格!!");
            }

            if(!viewModel.BranchID.HasValue)
            {
                ModelState.AddModelError("BranchID", "請選擇分店!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            LessonPriceType[] items = new LessonPriceType[16];
            var lowerLimit = new int[] { 1, 25, 50, 75 };
            var upperBound = new int?[] { 25, 50, 75, (int?)null };
            var duration = new int[] { 60, 90 };
            //【2017-02】《南京小巨蛋》75堂 / 60分鐘（舊會員續約）
            var info = new String[] { null, "（舊會員續約）" };
            var priceID = models.GetTable<LessonPriceType>().Select(p => p.PriceID).Max() + 1;
            var series = models.GetTable<LessonPriceSeries>().Where(s => s.Year == viewModel.Year)
                    .Where(s => s.LessonPriceType.BranchID == viewModel.BranchID)
                    .OrderByDescending(s => s.PeriodNo).FirstOrDefault();
            var periodNo = series == null ? 1 : series.PeriodNo.Value + 1;
            var branch = models.GetTable<BranchStore>().Where(b => b.BranchID == viewModel.BranchID).First();

            LessonPriceSeries item = models.GetTable<LessonPriceSeries>()
                .Where(p => p.PriceID == viewModel.SeriesID).FirstOrDefault();

            if (item == null)
            {
                item = new LessonPriceSeries
                {
                    PeriodNo = periodNo
                };
                models.GetTable<LessonPriceSeries>().InsertOnSubmit(item);
            }

            item.Status = viewModel.Status;
            item.Year = viewModel.Year;

            for (int i = 0; i < lowerLimit.Length; i++)
            {
                for (int f = 0; f < info.Length; f++)
                {
                    for (int d = 0; d < duration.Length; d++)
                    {
                        var idx = 4 * i + 2 * f + d;
                        items[idx] = models.GetTable<LessonPriceType>().Where(p => p.PriceID == viewModel.PriceSeriesID[idx]).FirstOrDefault();
                        if (items[idx] == null)
                        {
                            items[idx] = new LessonPriceType
                            {
                                PriceID = priceID++
                            };
                            //items[idx].CurrentPriceSeries = item;
                            models.GetTable<LessonPriceType>().InsertOnSubmit(items[idx]);
                        }

                        items[idx].Description = String.Format("【{0}-{1:00}】《{2}》{3}堂 / {4}分鐘{5}",
                            viewModel.Year, item.PeriodNo, branch.BranchName, lowerLimit[i], duration[d], info[f]);
                        items[idx].ListPrice = items[idx].CoachPayoff= items[idx].CoachPayoffCreditCard = viewModel.ListPriceSeries[idx];
                        items[idx].Status = viewModel.Status;
                        items[idx].BranchID = branch.BranchID;
                        items[idx].LowerLimit = lowerLimit[i];
                        items[idx].UpperBound = upperBound[i];
                        items[idx].DurationInMinutes = duration[d];
                        if (f == 1)
                        {
                            if (!items[idx].LessonPriceProperty.Any(p => p.PropertyID == (int)Naming.LessonPriceFeature.舊會員續約))
                            {
                                items[idx].LessonPriceProperty.Add(new LessonPriceProperty
                                {
                                    PropertyID = (int)Naming.LessonPriceFeature.舊會員續約
                                });
                            }
                        }
                    }
                }
            }

            if (item.LessonPriceType == null)
                item.LessonPriceType = items[0];

            models.SubmitChanges();

            foreach(var p in items)
            {
                if (p.SeriesID != item.PriceID)
                    p.SeriesID = item.PriceID;
            }
            models.SubmitChanges();

            if(item.Status==(int)Naming.LessonSeriesStatus.已啟用)
            {
                models.ExecuteCommand(@"UPDATE LessonPriceSeries
                        SET        Status = 0
                        FROM     LessonPriceSeries INNER JOIN
                                       LessonPriceType ON LessonPriceSeries.PriceID = LessonPriceType.PriceID
                        WHERE   (LessonPriceSeries.PriceID <> {0}) AND (LessonPriceType.BranchID = {1})", item.PriceID, item.LessonPriceType.BranchID);
                models.ExecuteCommand(@"UPDATE LessonPriceType
                        SET        Status = 0
                        FROM     LessonPriceSeries INNER JOIN
                                       LessonPriceType ON LessonPriceSeries.PriceID = LessonPriceType.SeriesID
                        WHERE   (LessonPriceSeries.PriceID <> {0}) AND (LessonPriceType.BranchID = {1})", item.PriceID, item.LessonPriceType.BranchID);
            }

            return Json(new { result = true });
        }

    }
}