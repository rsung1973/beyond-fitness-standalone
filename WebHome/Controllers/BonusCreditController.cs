using System;
using System.Collections.Generic;
using System.Data;

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
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class BonusCreditController : SampleController<UserProfile>
    {
        public BonusCreditController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: BonusCredit
        public ActionResult SelectCoachBonus(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.AchievementDateFrom.HasValue)
            {
                viewModel.AchievementDateFrom = DateTime.Today.FirstDayOfMonth();
            }
            viewModel.AchievementDateTo = viewModel.AchievementDateFrom.Value.AddMonths(1);

            IQueryable<CoachMonthlySalary> items = viewModel.InquireMonthlySalary(models);

            return View("~/Views/BonusCredit/BonusModal/GiveBonusToCoach.cshtml", items);
        }

        public ActionResult CommitCoachBonus(MonthlyBonusViewModel viewModel)
        {
            ViewResult result = (ViewResult)SelectCoachBonus(viewModel);
            IQueryable<CoachMonthlySalary> items = (IQueryable<CoachMonthlySalary>)result.Model;

            if (viewModel.ByCoachID == null || viewModel.ByCoachID.Length == 0)
            {
                ModelState.AddModelError("ByCoachID", "請選擇教練");
            }

            if(!viewModel.SpecialBonus.HasValue && !viewModel.ManagerBonus.HasValue)
            {
                ModelState.AddModelError("ManagerBonus", "請輸入管理獎金");
                ModelState.AddModelError("SpecialBonus", "請輸特別獎金");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            foreach (var coachID in viewModel.ByCoachID)
            {
                var item = items.Where(t => t.CoachID == coachID).FirstOrDefault();
                if (item == null)
                    continue;
                item.SpecialBonus = viewModel.SpecialBonus;
                item.ManagerBonus = viewModel.ManagerBonus;
                models.SubmitChanges();
            }

            return Json(new { result = true });

        }

        public ActionResult ShowCoachBonusList(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)SelectCoachBonus(viewModel);
            IQueryable<CoachMonthlySalary> items = (IQueryable<CoachMonthlySalary>)result.Model;

            return View("~/Views/BonusCredit/Module/MonthlyBonusList.cshtml", items);
        }

        public ActionResult ProcessBonus(CoachBonusViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<CoachMonthlySalary>()
                        .Where(c => c.SettlementID == viewModel.SettlementID)
                        .Where(c => c.CoachID == viewModel.CoachID)
                        .FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "獎金資料錯誤!!");
            }

            return View("~/Views/BonusCredit/Module/ProcessBonus.cshtml", item);
        }

        public ActionResult CommitSingleCoachBonus(CoachBonusViewModel viewModel)
        {
            ViewResult result = (ViewResult)ProcessBonus(viewModel);
            CoachMonthlySalary item = result.Model as CoachMonthlySalary;
            if (item == null)
                return result;

            if (!viewModel.SpecialBonus.HasValue && !viewModel.ManagerBonus.HasValue)
            {
                ModelState.AddModelError("ManagerBonus", "請輸入管理獎金");
                ModelState.AddModelError("SpecialBonus", "請輸特別獎金");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            item.SpecialBonus = viewModel.SpecialBonus;
            item.ManagerBonus = viewModel.ManagerBonus;

            models.SubmitChanges();

            return Json(new { result = true });

        }


        public ActionResult ClearCoachBonus(CoachBonusViewModel viewModel)
        {
            ViewResult result = (ViewResult)ProcessBonus(viewModel);
            CoachMonthlySalary item = result.Model as CoachMonthlySalary;
            if (item == null)
                return result;

            item.SpecialBonus = (int?)null;
            item.ManagerBonus = (int?)null;

            models.SubmitChanges();

            return Json(new { result = true });

        }

        public ActionResult EditCoachBonus(CoachBonusViewModel viewModel)
        {
            ViewResult result = (ViewResult)ProcessBonus(viewModel);
            CoachMonthlySalary item = result.Model as CoachMonthlySalary;
            if (item == null)
                return result;

            viewModel.SpecialBonus = item.SpecialBonus;
            viewModel.ManagerBonus = item.ManagerBonus;

            return View("~/Views/BonusCredit/BonusModal/EditCoachBonus.cshtml", item);

        }


    }
}