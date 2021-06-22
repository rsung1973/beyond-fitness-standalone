using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using System.Web.Mvc.Html;

using CommonLib.MvcExtension;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using System.Data.Linq;
using WebHome.Security.Authorization;
using System.Data;

namespace WebHome.Controllers
{
    [Authorize]
    public class PromotionController : SampleController<UserProfile>
    {
        // GET: Promotion
        public ActionResult BonusPromotionIndex(PromotionQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            return View();
        }

        public ActionResult ListBonusPromotion(PromotionQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var items = models.GetBonusPromotion();

            return View("~/Views/Promotion/Module/BonusPromotionList.ascx", items);
        }


        public ActionResult EditBonusPromotion(PromotionViewModel viewModel)
        {
            PDQGroup item = loadPromotionItem(viewModel);

            if (item != null)
            {
                var pdq = item.PDQQuestion.First();
                var pdqExt = pdq.PDQQuestionExtension;

                viewModel.GroupID = item.GroupID;
                viewModel.GroupName = item.GroupName;
                viewModel.StartDate = item.StartDate;
                viewModel.EndDate = item.EndDate;
                viewModel.QuestionID = pdq.QuestionID;
                viewModel.Question = pdq.Question;
                viewModel.BonusPoint = pdqExt.BonusPoint;
                viewModel.Status = (Naming.LessonSeriesStatus?)pdqExt.Status;
                viewModel.AwardingAction = (Naming.BonusAwardingAction?)pdqExt.AwardingAction;
                viewModel.CreationTime = pdqExt.CreationTime;
            }

            ViewBag.ViewModel = viewModel;
            return View("~/Views/Promotion/Module/EditBonusPromotion.ascx", item);

        }

        private PDQGroup loadPromotionItem(PromotionViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.GroupID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<PDQGroup>().Where(c => c.GroupID == viewModel.GroupID).FirstOrDefault();
            return item;
        }

        public ActionResult CommitBonusPromotion(PromotionViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.BonusPoint.HasValue || viewModel.BonusPoint < 1)
            {
                ModelState.AddModelError("BonusPoint", "請輸入贈送點數!!");
            }

            if (!viewModel.StartDate.HasValue)
            {
                ModelState.AddModelError("StartDate", "請選擇活動起日!!");
            }

            viewModel.GroupName = viewModel.GroupName.GetEfficientString();
            if (viewModel.GroupName == null)
            {
                ModelState.AddModelError("GroupName", "請輸入活動名稱!!");
            }

            viewModel.Question = viewModel.Question.GetEfficientString();
            if (viewModel.Question == null)
            {
                ModelState.AddModelError("Question", "請輸入活動說明!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            var item = loadPromotionItem(viewModel);
            PDQQuestion pdq;
            PDQQuestionExtension pdqExt;
            if (item == null)
            {
                var table = models.GetTable<PDQGroup>();
                item = new PDQGroup
                {
                };
                item.GroupID = (table.OrderByDescending(p => p.GroupID).FirstOrDefault()?.GroupID + 1) ?? 1;

                table.InsertOnSubmit(item);

                pdq = new PDQQuestion
                {
                    PDQGroup = item
                };
                pdqExt = new PDQQuestionExtension
                {
                    PDQQuestion = pdq,
                    CreationTime = DateTime.Now,
                    AwardingAction = (int)Naming.BonusAwardingAction.手動,
                };
            }
            else
            {
                pdq = item.PDQQuestion.First();
                pdqExt = pdq.PDQQuestionExtension;
            }

            item.GroupName = viewModel.GroupName;
            item.StartDate = viewModel.StartDate;
            item.EndDate = viewModel.EndDate;
            pdq.Question = viewModel.Question;
            pdqExt.BonusPoint = viewModel.BonusPoint;

            models.SubmitChanges();

            return Json(new { result = true });
        }

        public ActionResult UpdateBonusPromotionStatus(PromotionViewModel viewModel, bool? tryToDelete)
        {
            var item = loadPromotionItem(viewModel);
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "活動方案資料錯誤!!");
            }

            item.PDQQuestion.First().PDQQuestionExtension.Status = (int?)viewModel.Status;
            models.SubmitChanges();

            if (tryToDelete == true)
            {
                try
                {
                    models.ExecuteCommand("delete PDQGroup where GroupID = {0}", item.GroupID);
                    return Json(new { result = true }, JsonRequestBehavior.AllowGet);
                }
                catch (Exception ex)
                {
                    Logger.Error(ex);
                    return Json(new { result = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
                }
            }
            else
            {
                return Json(new { result = true }, JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult CreateBonusPromotionXlsx(PromotionViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(viewModel.KeyID!=null)
            {
                viewModel.GroupID = viewModel.DecryptKeyValue();
            }

            var promotions = models.GetBonusPromotion();
            if (viewModel.GroupID.HasValue)
            {
                promotions = promotions.Where(g => g.GroupID == viewModel.GroupID);
            }

            IQueryable<PDQTask> items = models.GetTable<PDQTask>()
                .Join(models.GetTable<PDQQuestion>()
                    .Join(promotions, q => q.GroupID, p => p.GroupID, (q, p) => q),
                    t => t.QuestionID, q => q.QuestionID, (t, q) => t);

            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("學員姓名", typeof(String)));
            table.Columns.Add(new DataColumn("活動名稱", typeof(String)));
            table.Columns.Add(new DataColumn("獲得點數", typeof(int)));
            table.Columns.Add(new DataColumn("獲得日期", typeof(String)));

            foreach (var item in items)
            {
                var pdq = item.PDQQuestion;
                var pdqExt = pdq.PDQQuestionExtension;
                var r = table.NewRow();
                r[0] = $"{item.UserProfile.FullName()}";
                r[1] = pdq.PDQGroup.GroupName;
                r[2] = pdqExt.BonusPoint;
                r[3] = $"{item.TaskDate:yyyy/MM/dd}";

                table.Rows.Add(r);
            }

            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename=({1:yyyy-MM-dd HH-mm-ss}){0}", HttpUtility.UrlEncode("BonusPromotion.xlsx"), DateTime.Now));

            using (DataSet ds = new DataSet())
            {
                ds.Tables.Add(table);

                using (var xls = ds.ConvertToExcel())
                {
                    xls.Worksheets.ElementAt(0).Name = "活動方案明細表";
                    xls.SaveAs(Response.OutputStream);
                }
            }

            return new EmptyResult();
        }


        public ActionResult DeletePromotionParticipant(PromotionParticipantViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.TaskID = viewModel.DecryptKeyValue();
            }

            try
            {
                models.ExecuteCommand("delete PDQTask where TaskID = {0}", viewModel.TaskID);
                return Json(new { result = true }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                return Json(new { result = false, message = "點數已兌換，無法刪除!!" }, JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult EditPromotionParticipant(PromotionParticipantViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = loadPromotionItem(viewModel);
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "活動方案資料錯誤!!");
            }

            return View("~/Views/Promotion/Module/EditPromotionParticipant.ascx", item);

        }

        public ActionResult SelectPromotionParticipant(PromotionParticipantViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditPromotionParticipant(viewModel);
            PDQGroup item = result.Model as PDQGroup;
            if (item == null)
                return result;

            return View("~/Views/Promotion/Module/SelectPromotionParticipant.ascx", item);
        }

        public ActionResult ListPromotionParticipant(PromotionParticipantViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditPromotionParticipant(viewModel);
            PDQGroup item = result.Model as PDQGroup;
            if (item == null)
                return result;

            var pdq = item.PDQQuestion.First();
            var items = models.GetTable<PDQTask>().Where(t => t.QuestionID == pdq.QuestionID);

            ViewBag.DataItem = item;

            return View("~/Views/Promotion/Module/PromotionParticipantList.ascx", items);
        }


        public ActionResult InquirePromotionParticipant(PromotionParticipantViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditPromotionParticipant(viewModel);
            PDQGroup item = result.Model as PDQGroup;
            if (item == null)
                return result;

            IQueryable<UserProfile> items;
            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName == null)
            {
                this.ModelState.AddModelError("UserName", "請輸學員名稱!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }
            else
            {
                items = models.GetTable<UserProfile>()
                    .Where(l => l.RealName.Contains(viewModel.UserName) || l.Nickname.Contains(viewModel.UserName))
                    .FilterByLearner(models, true)
                    .OrderBy(l => l.RealName);
            }

            return View("~/Views/CoachFacet/Module/VipSelector.ascx", items);
        }

        public ActionResult CommitPromotionParticipant(PromotionParticipantViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditPromotionParticipant(viewModel);
            PDQGroup item = result.Model as PDQGroup;
            if (item == null)
                return result;

            if (!viewModel.UID.HasValue)
            {
                this.ModelState.AddModelError("UID", "請選擇學員!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            var quest = item.PDQQuestion.First();

            var taskItem = new PDQTask
            {
                QuestionID = quest.QuestionID,
                UID = viewModel.UID.Value,
                TaskDate = DateTime.Now,
                PDQTaskBonus = new PDQTaskBonus { },
            };
            models.GetTable<PDQTask>().InsertOnSubmit(taskItem);
            models.SubmitChanges();

            return Json(new { result = true, bonus = taskItem != null }, JsonRequestBehavior.AllowGet);

        }

    }
}