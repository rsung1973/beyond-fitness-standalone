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
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [Authorize]
    public class ExerciseGameController : SampleController<UserProfile>
    {

        public ActionResult GameIndex(ExerciseGameViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).First();
            return View("~/Views/ExerciseGame/Module/GameWidgetGrid.ascx", item);
        }

        public ActionResult ShowGameWidget(ExerciseGameViewModel viewModel)
        {
            ViewResult result = (ViewResult)GameIndex(viewModel);
            result.ViewName = "~/Views/ExerciseGame/Module/WidgetGridDialog.ascx";
            return result;
        }

        public ActionResult ShowGameResult(ExerciseGameViewModel viewModel)
        {
            return View("~/Views/ExerciseGame/Module/ExerciseGameResult.ascx");
        }

        public ActionResult ShowContestantRecord(ExerciseGameViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditExerciseResult(viewModel);
            ExerciseGameContestant item = result.Model as ExerciseGameContestant;
            if (item != null)
                result.ViewName = "~/Views/ExerciseGame/Module/ContestantRecord.ascx";

            return result;
        }


        public ActionResult CommitGameStatus(ExerciseGameViewModel viewModel)
        {
            ViewResult result = (ViewResult)GameIndex(viewModel);
            UserProfile profile = (UserProfile)result.Model;

            if (viewModel.Status == (int)Naming.GeneralStatus.Failed && !models.GetTable<ExerciseGameResult>().Any(u => u.UID == profile.UID))
            {
                models.ExecuteCommand("delete ExerciseGameContestant where UID = {0} ", profile.UID);
                models.RefreshExerciseGameContestant(null);
                return result;
            }

            ExerciseGameContestant item = profile.ExerciseGameContestant;
            if (item == null)
            {
                item = profile.ExerciseGameContestant = new ExerciseGameContestant
                {
                    UserProfile = profile
                };
            }

            item.Status = viewModel.Status;
            item.TotalScope = null;
            item.Rank = null;

            if (item.ExerciseGameRank.Count == 0)
            {
                var exerciseItem = models.GetTable<ExerciseGameItem>().FirstOrDefault();
                if (exerciseItem != null)
                {
                    item.ExerciseGameRank.Add(new ExerciseGameRank
                    {
                        ExerciseID = exerciseItem.ExerciseID
                    });
                }
            }
            models.SubmitChanges();

            models.RefreshExerciseGameContestant(item);

            return result;
        }

        public ActionResult EditExerciseResult(ExerciseGameViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var item = models.GetTable<ExerciseGameContestant>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "參賽者資料錯誤!!");
            }

            return View("~/Views/ExerciseGame/Module/EditExerciseResult.ascx", item);
        }

        public ActionResult CommitExerciseResult(ExerciseGameViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            if (!viewModel.ExerciseID.HasValue)
            {
                ModelState.AddModelError("ExerciseID", "請選擇測驗項目!!");
            }

            if (!viewModel.Score.HasValue)
            {
                ModelState.AddModelError("Score", "請輸入純數字!!");
            }

            if (!viewModel.TestDate.HasValue)
            {
                ModelState.AddModelError("TestDate", "請選擇測驗日期!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            ViewResult result = (ViewResult)EditExerciseResult(viewModel);
            ExerciseGameContestant contestant = result.Model as ExerciseGameContestant;
            if (contestant == null)
            {
                return result;
            }

            if (contestant.Status != (int)Naming.GeneralStatus.Successful)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "參賽者已退賽!!");
            }

            var item = new ExerciseGameResult
            {
                UID = contestant.UID,
                Score = viewModel.Score.Value,
                ExerciseID = viewModel.ExerciseID.Value,
                TestDate = viewModel.TestDate.Value
            };
            models.GetTable<ExerciseGameResult>()
                .InsertOnSubmit(item);

            models.SubmitChanges();

            item.CheckExerciseGameRank();

            return Json(new { result = true });
        }

        public ActionResult DeleteExerciseResult(ExerciseGameViewModel viewModel)
        {
            var item = models.GetTable<ExerciseGameResult>().Where(r => r.TestID == viewModel.TestID).FirstOrDefault();
            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            bool updateRank = item.ExerciseGameRank.Count(r => r.Rank.HasValue) > 0;
            models.ExecuteCommand(@"UPDATE ExerciseGameRank SET RecordID = NULL
                                    WHERE(RecordID = {0}) ", item.TestID);
            models.ExecuteCommand("delete ExerciseGameResult where TestID = {0}", item.TestID);

            if(updateRank)
            {
                item.ExerciseID.UpdateExerciseGameRank();
            }

            return Json(new { result = true });

        }

        public ActionResult RefreshExerciseGameRank()
        {
            ExerciseGameExtensionMethods.RefreshExerciseGameRank();
            return Json(new { result = true }, JsonRequestBehavior.AllowGet);
        }
    }
}