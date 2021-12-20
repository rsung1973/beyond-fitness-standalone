using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Data.Linq;
using System.Data;
using System.Text.RegularExpressions;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Html;


using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    public class TrainingController : SampleController<UserProfile>
    {
        public TrainingController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: Training
        public ActionResult ShowTrainingAids(TrainingItemViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/Training/Module/ShowTrainingAids.ascx");
        }

        public ActionResult EditTrainingItem(TrainingItemViewModel viewModel)
        {
            if (!models.GetTable<TrainingExecution>().Any(t => t.ExecutionID == viewModel.ExecutionID))
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            var stage = models.GetTable<TrainingStage>().Where(s => s.StageID == viewModel.StageID).FirstOrDefault();
            if (stage == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }
            ViewBag.TrainingStage = stage;

            TrainingItem item = models.GetTable<TrainingItem>().Where(x => x.ItemID == viewModel.ItemID).FirstOrDefault();

            if (item != null)
            {
                viewModel.ItemID = item.ItemID;
                viewModel.TrainingID = item.TrainingID;
                viewModel.GoalTurns = item.GoalTurns;
                viewModel.GoalStrength = item.GoalStrength;
                viewModel.ExecutionID = item.ExecutionID;
                viewModel.Description = item.Description;
                viewModel.ActualStrength = item.ActualStrength;
                viewModel.ActualTurns = item.ActualTurns;
                viewModel.Remark = item.Remark;
                viewModel.Repeats = item.Repeats;
                viewModel.DurationInSeconds = item.DurationInMinutes * 60;
                viewModel.BreakInterval = item.BreakIntervalInSecond;

                viewModel.AidID = item.TrainingItemAids.Select(s => s.AidID).ToArray();
            }

            ViewBag.ViewModel = viewModel;
            return View("~/Views/Training/Module/EditTrainingItem.ascx", item);

        }

        public ActionResult EditBreakInterval(TrainingItemViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditTrainingItem(viewModel);
            result.ViewName = "~/Views/Training/Module/EditBreakInterval.ascx";
            return result;
        }


        public ActionResult DeleteTrainingItem(TrainingItemViewModel viewModel)
        {

            var item = models.GetTable<TrainingItem>().Where(i => i.ItemID == viewModel.ItemID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "課程項目不存在!!" });
            }

            var execution = item.TrainingExecution;
            if (item.PurposeID.HasValue)
            {
                models.ExecuteCommand("delete PersonalExercisePurposeItem where ItemID = {0}", item.PurposeID);
            }
            models.ExecuteCommand("delete TrainingItem where ItemID = {0}", item.ItemID);

            calculateTotalMinutes(execution, viewModel.StageID.Value);

            return Content(new { result = true, viewModel.StageID }.JsonStringify(), "application/json");
        }

        public ActionResult CommitTrainingItem(TrainingItemViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.Description = viewModel.Description.GetEfficientString();
            if (viewModel.Description == null)
            {
                ModelState.AddModelError("Description", "請輸入動作");
            }

            //viewModel.ActualStrength = viewModel.ActualStrength.GetEfficientString();
            //if(viewModel.ActualStrength == null)
            //{
            //    ModelState.AddModelError("ActualStrength", "請輸入強度");
            //}

            //viewModel.ActualTurns = viewModel.ActualTurns.GetEfficientString();
            //if (viewModel.ActualTurns == null)
            //{
            //    ModelState.AddModelError("ActualTurns", "請輸入次數");
            //}

            if (!viewModel.DurationInSeconds.HasValue)
            {
                ModelState.AddModelError("DurationInSeconds", "請輸入時間");
            }

            if (!viewModel.TrainingID.HasValue)
            {
                ModelState.AddModelError("TrainingID", "請選擇類別");
            }

            viewModel.Remark = viewModel.Remark.GetEfficientString();
            if (viewModel.PurposeID.HasValue && viewModel.Remark == null)
            {
                ModelState.AddModelError("Remark", "請輸入里程碑內容");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View(Startup.Properties["ReportInputError"]);
            }

            TrainingExecution execution = models.GetTable<TrainingExecution>().Where(t => t.ExecutionID == viewModel.ExecutionID).FirstOrDefault();
            if (execution == null)
            {
                return Json(new { result = false, message = "預編課程項目不存在!!" });
            }

            TrainingItem item = execution.TrainingItem.Where(i => i.ItemID == viewModel.ItemID).FirstOrDefault();
            if (item == null)
            {
                item = new TrainingItem
                {
                    ExecutionID = execution.ExecutionID,
                    Sequence = execution.TrainingItem.Count
                };
                execution.TrainingItem.Add(item);
            }

            item.GoalStrength = viewModel.GoalStrength;
            item.GoalTurns = viewModel.GoalTurns;
            item.Description = viewModel.Description;
            item.TrainingID = viewModel.TrainingID;
            item.Remark = viewModel.Remark;
            item.DurationInMinutes = viewModel.DurationInMinutes;

            models.SubmitChanges();

            models.ExecuteCommand("delete TrainingItemAids where ItemID = {0}", item.ItemID);
            if (viewModel.AidID != null && viewModel.AidID.Length > 0)
            {
                foreach (var aid in viewModel.AidID)
                {
                    item.TrainingItemAids.Add(new TrainingItemAids { AidID = aid });
                }
                models.SubmitChanges();
            }

            calculateTotalMinutes(execution, viewModel.StageID.Value);
            bool UpdatePurpose = false;
            if (item.PurposeID.HasValue)
            {
                if (viewModel.PurposeID.HasValue)
                {
                    models.ExecuteCommand("Update PersonalExercisePurposeItem set PurposeItem = {0} where ItemID = {1}", viewModel.Remark, item.PurposeID);
                }
                else
                {
                    models.ExecuteCommand("delete PersonalExercisePurposeItem where ItemID = {0}", item.PurposeID);
                }
                UpdatePurpose = true;
            }
            else if (viewModel.PurposeID == -1 && item.Remark != null)
            {
                var purpose = item.TrainingExecution.TrainingPlan.LessonTime.RegisterLesson.UserProfile.AssertPurposeItem(models, item.Remark);
                purpose.CompleteDate = item.TrainingExecution.TrainingPlan.LessonTime.ClassTime;    //DateTime.Now;
                item.PurposeID = purpose.ItemID;
                models.SubmitChanges();
                UpdatePurpose = true;
            }

            return Json(new { result = true, message = "", viewModel.StageID, UpdatePurpose });

        }

        private void calculateTotalMinutes(TrainingExecution execution,int stageID)
        {
            TrainingExecutionStage stage = execution.TrainingExecutionStage.Where(t => t.StageID == stageID).FirstOrDefault();
            if (stage == null)
            {
                stage = new TrainingExecutionStage
                {
                    StageID = stageID,
                    ExecutionID = execution.ExecutionID
                };
                execution.TrainingExecutionStage.Add(stage);
            }

            var items = models.GetTable<TrainingItem>()
                    .Where(t => t.ExecutionID == execution.ExecutionID)
                    .Where(t => t.TrainingType.TrainingStageItem.StageID == stageID)
                    .OrderBy(t => t.Sequence);
            stage.TotalMinutes = calculateDuration(items);
            models.SubmitChanges();
        }

        private decimal calculateDuration(IEnumerable<TrainingItem> items)
        {
            decimal totalDuration = 0, duration = 0;
            var regex = new Regex("[0-9]+");
            foreach (var item in items)
            {
                if (item.TrainingType.BreakMark == true)
                {
                    if (item.Repeats != null)
                    {
                        var m = regex.Match(item.Repeats);
                        if (m.Success)
                        {
                            duration *= decimal.Parse(m.Value);
                        }
                    }
                    totalDuration += duration;
                    duration = 0;
                }
                else if (item.DurationInMinutes.HasValue)
                {
                    duration += item.DurationInMinutes.Value;
                }
            }

            totalDuration += duration;
            return totalDuration;
        }


        public ActionResult EditEmphasis(TrainingExecutionViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.ExecutionID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<TrainingExecution>().Where(t => t.ExecutionID == viewModel.ExecutionID).FirstOrDefault();
            if(item==null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            return View("~/Views/Training/Module/EditEmphasis.ascx", item);
        }

        public ActionResult CommitEmphasis(TrainingExecutionViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditEmphasis(viewModel);
            TrainingExecution model = result.Model as TrainingExecution;
            if(model==null)
            {
                return result;
            }

            viewModel.Emphasis = viewModel.Emphasis.GetEfficientString();
            if(viewModel.Emphasis==null)
            {
                return Json(new { result = false, message = "Unfinished？!" });
            }
            else if (viewModel.Emphasis.Length > 20)
            {
                return Json(new { result = false, message = "太長了！超過20個中英文字" });
            }
            model.Emphasis = viewModel.Emphasis;
            models.SubmitChanges();

            return Json(new { result = true });
        }

        public ActionResult SelectTrainingAids(TrainingItemViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditTrainingItem(viewModel);
            result.ViewName = "~/Views/Training/Module/SelectTrainingAids.ascx";
            return result;
        }

        public ActionResult CommitBreakInterval(TrainingItemViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            //if (!ModelState.IsValid)
            //{
            //    ViewBag.ModelState = this.ModelState;
            //    return View(Startup.Properties["ReportInputError"]);
            //}

            TrainingExecution execution = models.GetTable<TrainingExecution>().Where(t => t.ExecutionID == viewModel.ExecutionID).FirstOrDefault();
            if (execution == null)
            {
                return Json(new { result = false, message = "預編課程項目不存在!!" });
            }

            var stage = models.GetTable<TrainingStage>().Where(s => s.StageID == viewModel.StageID).FirstOrDefault();
            if (stage == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            TrainingItem item = execution.TrainingItem.Where(i => i.ItemID == viewModel.ItemID).FirstOrDefault();
            if (item == null)
            {
                item = new TrainingItem
                {
                    ExecutionID = execution.ExecutionID,
                    Sequence = execution.TrainingItem.Count,
                    TrainingID = stage.TrainingStageItem
                        .Select(t => t.TrainingType)
                        .Where(t => t.BreakMark == true)
                        .Select(t => t.TrainingID).FirstOrDefault()
                };
                execution.TrainingItem.Add(item);
            }

            item.BreakIntervalInSecond = viewModel.BreakInterval = viewModel.BreakInterval.GetEfficientString();
            item.Repeats = viewModel.Repeats = viewModel.Repeats.GetEfficientString();
            item.Remark = viewModel.Remark;

            models.SubmitChanges();

            if (item.Repeats != null)
            {
                calculateTotalMinutes(execution, stage.StageID);
            }

            return Content(new { result = true, message = "", stage.StageID }.JsonStringify(), "application/json");

        }

        public ActionResult CurrentLessonContentPieData(TrainingExecutionViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var item = models.GetTable<TrainingExecution>().Where(f => f.ExecutionID == viewModel.ExecutionID).FirstOrDefault();
            if (item == null)
            {
                return Json(new object[] { });
            }

            return Json(item.TrainingExecutionStage
                .Select(r => new
                {
                    label = r.TrainingStage.Stage + " " + String.Format("{0:.#}", r.TotalMinutes) + "分鐘",
                    data = r.TotalMinutes
                }).ToArray());

        }

        public ActionResult LearnerLessonContentPieData(int uid)
        {
            var items = models.GetTable<RegisterLesson>().Where(f => f.UID == uid)
                .Join(models.GetTable<GroupingLesson>(), r => r.RegisterGroupID, g => g.GroupID, (r, g) => g)
                .Join(models.GetTable<LessonTime>(), g => g.GroupID, l => l.GroupID, (g, l) => l)
                .Join(models.GetTable<TrainingPlan>(), l => l.LessonID, p => p.LessonID, (l, p) => p)
                .Join(models.GetTable<TrainingExecution>(), p => p.ExecutionID, x => x.ExecutionID, (p, x) => x)
                .Join(models.GetTable<TrainingExecutionStage>(), x => x.ExecutionID, s => s.ExecutionID, (x, s) => s);

            if (items.Count() == 0)
            {
                return Json(new object[] { });
            }

            var result = items.GroupBy(s => s.StageID)
                .Select(g => new { StageID = g.Key, TotalMinutes = g.Sum(v => v.TotalMinutes) });

            return Json(result
                .Select(r => new
                {
                    label = models.GetTable<TrainingStage>().Where(s => s.StageID == r.StageID).First().Stage,
                    data = r.TotalMinutes
                }).ToArray());

        }

        class _MonthlyGraphKey
        {
            public int Year { get; set; }
            public int Month { get; set; }
        }

        public ActionResult LearnerLessonContentGraphData(int uid)
        {
            DateTime start = DateTime.Today.AddYears(-1);
            start = new DateTime(start.Year, start.Month, 1);

            var items = models.GetTable<RegisterLesson>().Where(f => f.UID == uid)
                .Join(models.GetTable<GroupingLesson>(), r => r.RegisterGroupID, g => g.GroupID, (r, g) => g)
                .Join(models.GetTable<LessonTime>()
                    .Where(l => l.ClassTime >= start), g => g.GroupID, l => l.GroupID, (g, l) => l)
                .Join(models.GetTable<TrainingPlan>(), l => l.LessonID, p => p.LessonID, (l, p) => p)
                .Join(models.GetTable<TrainingExecution>(), p => p.ExecutionID, x => x.ExecutionID, (p, x) => x)
                .Join(models.GetTable<TrainingExecutionStage>(), x => x.ExecutionID, s => s.ExecutionID, (x, s) => s);

            if (items.Count() == 0)
            {
                return Json(new object[] { });
            }

            var result = items.Select(x => new { ClassTime = x.TrainingExecution.TrainingPlan.LessonTime.ClassTime.Value, x.StageID, x.TotalMinutes })
                .ToArray()
                .GroupBy(s => new { Year = s.ClassTime.Year,Month = s.ClassTime.Month })
                .OrderBy(g => g.Key.Year)
                .ThenBy(g => g.Key.Month);

            List<_MonthlyGraphKey> dateItems = new List<_MonthlyGraphKey>();
            while(start<DateTime.Today)
            {
                dateItems.Add(new _MonthlyGraphKey
                {
                    Year = start.Year,
                    Month = start.Month
                });
                start = start.AddMonths(1);
            }

            var dataResult = dateItems.Select(d => new { Key = d, Data = result.Where(g => g.Key.Year == d.Year && g.Key.Month == d.Month).FirstOrDefault() });

            return Json(dataResult
                .Select(r => new
                {
                    period = r.Key.Year + "-" + r.Key.Month.ToString("00"),
                    basic = r.Data != null ? r.Data.Where(v => v.StageID == 1).Sum(v => v.TotalMinutes) : null,
                    tech = r.Data != null ? r.Data.Where(v => v.StageID == 2).Sum(v => v.TotalMinutes) : null,
                    muscle = r.Data != null ? r.Data.Where(v => v.StageID == 3).Sum(v => v.TotalMinutes) : null,
                    cardio = r.Data != null ? r.Data.Where(v => v.StageID == 4).Sum(v => v.TotalMinutes) : null,
                }).ToArray());
        }

        public ActionResult LearnerExerciseGraphData(int uid)
        {
            DateTime start = DateTime.Today.AddYears(-1);
            start = new DateTime(start.Year, start.Month, 1);

            var items = models.GetTable<RegisterLesson>().Where(f => f.UID == uid)
                .Join(models.GetTable<GroupingLesson>(), r => r.RegisterGroupID, g => g.GroupID, (r, g) => g)
                .Join(models.GetTable<LessonTime>()
                    .Where(l => l.ClassTime >= start), g => g.GroupID, l => l.GroupID, (g, l) => l);

            if (items.Count() == 0)
            {
                return Json(new object[] { });
            }

            var result = items
                .ToArray()
                .GroupBy(s => new { Year = s.ClassTime.Value.Year, Month = s.ClassTime.Value.Month })
                .OrderBy(g => g.Key.Year)
                .ThenBy(g => g.Key.Month);

            List<_MonthlyGraphKey> dateItems = new List<_MonthlyGraphKey>();
            while (start < DateTime.Today)
            {
                dateItems.Add(new _MonthlyGraphKey
                {
                    Year = start.Year,
                    Month = start.Month
                });
                start = start.AddMonths(1);
            }

            var dataResult = dateItems.Select(d => new { Key = d, Data = result.Where(g => g.Key.Year == d.Year && g.Key.Month == d.Month).FirstOrDefault() });

            return Json(dataResult
                .Select(r => new
                {
                    period = r.Key.Year + "-" + r.Key.Month.ToString("00"),
                    pt = r.Data!=null ? r.Data.Where(v => v.RegisterLesson.LessonPriceType.Status != (int)Naming.LessonPriceStatus.在家訓練
                            && v.RegisterLesson.LessonPriceType.Status != (int)Naming.LessonPriceStatus.自主訓練).Sum(v => v.DurationInMinutes) : null,
                    pi = r.Data != null ? r.Data.Where(v => v.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.自主訓練).Sum(v => v.DurationInMinutes) : null,
                    st = r.Data != null ? r.Data.Where(v => v.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.在家訓練).Sum(v => v.DurationInMinutes) : null,
                }).ToArray());
        }

        class _PieItem
        {
            public String label { get; set; }
            public decimal? data { get; set; }
        }
        public ActionResult LearnerTrainingAidsPieData(int uid)
        {
            var items = uid.LearnerTrainingAids(models)
                .Select(s => s.TrainingAids.ItemName);

            if (items.Count() == 0)
            {
                return Json(new object[] { });
            }

            var result = items.GroupBy(s => s)
                .Select(g => new { ItemName = g.Key, Count = g.Count() })
                .OrderByDescending(g => g.Count).ToArray();

            if(result.Count()>4)
            {
                var resultData = result.Take(4)
                    .Select(r => new _PieItem
                    {
                        label = r.ItemName,
                        data = r.Count
                    }).ToList();

                resultData.Add(new _PieItem {
                    label = "其他",
                    data = result.Skip(4).Sum(r => r.Count)
                });
                return Content(resultData.JsonStringify(), "application/json");
            }
            else
            {
                var resultData = result
                    .Select(r => new _PieItem
                    {
                        label = r.ItemName,
                        data = r.Count
                    }).ToList();

                return Content(resultData.JsonStringify(), "application/json");
            }

        }

        public ActionResult UpdateTrainingDuration()
        {
            foreach(var item in models.GetTable<TrainingExecutionStage>())
            {
                var items = models.GetTable<TrainingItem>()
                    .Where(t => t.ExecutionID == item.ExecutionID)
                    .Where(t => t.TrainingType.TrainingStageItem.StageID == item.StageID)
                    .OrderBy(t => t.Sequence);

                item.TotalMinutes = calculateDuration(items);
                models.SubmitChanges();
            }
            return Json(new { result = true });
        }

    }
}