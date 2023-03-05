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
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.Routing;
using Microsoft.Extensions.DependencyInjection;

using CommonLib.DataAccess;
using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Helper.BusinessOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;
using CommonLib.Core.Utility;
using Microsoft.AspNetCore.Http;
using System.Diagnostics.Contracts;

namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class LearnerConsoleController : SampleController<UserProfile>
    {
        public LearnerConsoleController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

        public async Task<ActionResult> ShowCoachPerformanceListAsync(CoachQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();
            if (viewModel.Employed == false)
            {
                return View("~/Views/CoachConsole/Module/LeavedCoachList.cshtml", profile.LoadInstance(models));
            }
            else
            {
                return View("~/Views/CoachConsole/Module/CoachMonthlyPerformance.cshtml", profile.LoadInstance(models));
            }
        }

        public ActionResult ProcessCoachLearner(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel = viewModel.Deserialize<CoachLearnerQueryViewModel>();
            }

            ViewBag.ViewModel = viewModel;

            if (!viewModel.CoachID.HasValue || !viewModel.UID.HasValue)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            return View("~/Views/LearnerConsole/Module/ProcessCoachLearner.cshtml");
        }

        public ActionResult ProcessPrimaryCoachReview(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel = viewModel.Deserialize<CoachLearnerQueryViewModel>();
            }

            ViewBag.ViewModel = viewModel;

            if (!viewModel.CoachID.HasValue || !viewModel.UID.HasValue)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            return View("~/Views/LearnerConsole/Module/ProcessPrimaryCoachReview.cshtml");
        }

        public ActionResult CommitPrimaryCoach(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel = viewModel.Deserialize<CoachLearnerQueryViewModel>();
            }

            ViewBag.ViewModel = viewModel;

            if (!viewModel.CoachID.HasValue || !viewModel.UID.HasValue)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            models.ExecuteCommand(@"DELETE  LearnerCoachProperty
                                    WHERE   (UID = {0}) AND (PropertyID = {1})",
                                viewModel.UID,
                                (int)LearnerCoachProperty.PropertyType.PrimaryCoach);

            var result = models.ExecuteCommand(@"INSERT INTO LearnerCoachProperty
                                                   (CoachID, UID, PropertyID)
                                    SELECT  {0} AS CoachID, {1} AS UID, {2} AS PropertyID
                                    WHERE   (NOT EXISTS
                                                       (SELECT  NULL
                                                       FROM     LearnerCoachProperty
                                                       WHERE   (CoachID = {0}) AND (UID = {1}) AND (PropertyID = {2})))",
                                    viewModel.CoachID, viewModel.UID, 
                                    (int)LearnerCoachProperty.PropertyType.PrimaryCoach);

            return Json(new { result = true, count = result });
        }

        public ActionResult BatchCommitPrimaryCoach(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            ViewBag.ViewModel = viewModel;

            if (!viewModel.CoachID.HasValue || viewModel.LearnerID == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            int result = 0;
            foreach(var id in viewModel.LearnerID)
            {
                models.ExecuteCommand(@"DELETE  LearnerCoachProperty
                                    WHERE   (UID = {0}) AND (PropertyID = {1})",
                                    id,
                                    (int)LearnerCoachProperty.PropertyType.PrimaryCoach);

                result += models.ExecuteCommand(@"INSERT INTO LearnerCoachProperty
                                                   (CoachID, UID, PropertyID)
                                    SELECT  {0} AS CoachID, {1} AS UID, {2} AS PropertyID
                                    WHERE   (NOT EXISTS
                                                       (SELECT  NULL
                                                       FROM     LearnerCoachProperty
                                                       WHERE   (CoachID = {0}) AND (UID = {1}) AND (PropertyID = {2})))",
                                        viewModel.CoachID, id,
                                        (int)LearnerCoachProperty.PropertyType.PrimaryCoach);
            }


            return Json(new { result = true, count = result });
        }

        public ActionResult DeletePrimaryCoach(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel = viewModel.Deserialize<CoachLearnerQueryViewModel>();
            }

            ViewBag.ViewModel = viewModel;

            var result = models.ExecuteCommand(@"DELETE  LearnerCoachProperty
                                                    WHERE   (CoachID = {0}) AND (UID = {1}) AND (PropertyID = {2})",
                                    viewModel.CoachID, viewModel.UID,
                                    (int)LearnerCoachProperty.PropertyType.PrimaryCoach);

            return Json(new { result = true, count = result });
        }

        public ActionResult DeleteAdvisor(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel = viewModel.Deserialize<CoachLearnerQueryViewModel>();
            }

            ViewBag.ViewModel = viewModel;

            var result = models.ExecuteCommand(@"DELETE  LearnerFitnessAdvisor
                                                    WHERE   (CoachID = {0}) AND (UID = {1})",
                                    viewModel.CoachID, viewModel.UID);

            models.ExecuteCommand(@"DELETE  LearnerCoachProperty
                                                    WHERE   (CoachID = {0}) AND (UID = {1}) AND (PropertyID = {2})",
                                               viewModel.CoachID, viewModel.UID,
                                               (int)LearnerCoachProperty.PropertyType.PrimaryCoach);

            return Json(new { result = true, count = result });
        }

        public ActionResult BatchDeleteAdvisor(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            ViewBag.ViewModel = viewModel;

            if (!viewModel.CoachID.HasValue || viewModel.LearnerID == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            int result = 0;
            foreach(var id in viewModel.LearnerID)
            {
                result += models.ExecuteCommand(@"DELETE  LearnerFitnessAdvisor
                                                    WHERE   (CoachID = {0}) AND (UID = {1})",
                                        viewModel.CoachID, id);

                models.ExecuteCommand(@"DELETE  LearnerCoachProperty
                                                    WHERE   (CoachID = {0}) AND (UID = {1}) AND (PropertyID = {2})",
                                                   viewModel.CoachID, id,
                                                   (int)LearnerCoachProperty.PropertyType.PrimaryCoach);
            }

            return Json(new { result = true, count = result });
        }

        public ActionResult BatchDeletePrimaryCoach(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            ViewBag.ViewModel = viewModel;

            if (!viewModel.CoachID.HasValue || viewModel.LearnerID == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            int result = 0;
            foreach (var id in viewModel.LearnerID)
            {
                result += models.ExecuteCommand(@"DELETE  LearnerCoachProperty
                                                    WHERE   (CoachID = {0}) AND (UID = {1}) AND (PropertyID = {2})",
                                                   viewModel.CoachID, id,
                                                   (int)LearnerCoachProperty.PropertyType.PrimaryCoach);
            }

            return Json(new { result = true, count = result });
        }

        public ActionResult ShowCoachLearnerList(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            ViewBag.ViewModel = viewModel;
            ServingCoach coach = models.GetTable<ServingCoach>().Where(s => s.CoachID == viewModel.CoachID).FirstOrDefault();

            if (coach == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            ViewBag.DataItem = coach;

            IQueryable<UserProfile> items = models.GetTable<UserProfile>();

            var effectiveItems = models.PromptEffectiveContract();
            var effectiveLearners = models.GetTable<CourseContractMember>()
                                        .Join(effectiveItems, m => m.ContractID, c => c.ContractID, (m, c) => m);
            if (viewModel.ForPrimary == true)
            {
                items = items.Join(
                    models.GetTable<LearnerCoachProperty>().Where(p => p.PropertyID == (int)LearnerCoachProperty.PropertyType.PrimaryCoach)
                        .Where(p => p.CoachID == coach.CoachID),
                                u => u.UID, p => p.UID, (u, p) => u)
                    .Where(u => effectiveLearners.Any(l => l.UID == u.UID));
            }
            else
            {
                items = items.Join(models.GetTable<LearnerFitnessAdvisor>().Where(a => a.CoachID == coach.CoachID),
                                u => u.UID, a => a.UID, (u, a) => u);
                if(!viewModel.WithContract.HasValue || viewModel.WithContract == true)
                {
                    items = items.Where(u => effectiveLearners.Any(l => l.UID == u.UID));
                }
                else
                {
                    items = items.Where(u => !effectiveLearners.Any(l => l.UID == u.UID));
                }
            }

            return View("~/Views/LearnerConsole/Module/CoachLearnerList.cshtml", items);
        }

        public async Task<ActionResult> CreateCoachLearnerXlsxAsync(CoachLearnerQueryViewModel viewModel)
        {
            ServingCoach coach = null;
            var contracts = models.PromptEffectiveContract();
            var contractMember = models.GetTable<CourseContractMember>();

            using (DataSet ds = new DataSet())
            {
                viewModel.WithContract = true;
                ViewResult result = (ViewResult)ShowCoachLearnerList(viewModel);
                IQueryable<UserProfile> items = result.Model as IQueryable<UserProfile>;
                if (items != null)
                {
                    coach = (ServingCoach)ViewBag.DataItem;
                    DataTable table = BuildLearnerList(items, contracts, contractMember, "已認領有合約");
                    ds.Tables.Add(table);
                }

                viewModel.WithContract = false;
                result = (ViewResult)ShowCoachLearnerList(viewModel);
                items = result.Model as IQueryable<UserProfile>;
                if (items != null)
                {
                    coach = (ServingCoach)ViewBag.DataItem;
                    DataTable table = BuildLearnerList(items, contracts, contractMember, "已認領無合約");
                    ds.Tables.Add(table);
                }

                viewModel.ForPrimary = true;
                result = (ViewResult)ShowCoachLearnerList(viewModel);
                items = result.Model as IQueryable<UserProfile>;
                if (items != null)
                {
                    coach = (ServingCoach)ViewBag.DataItem;
                    DataTable table = BuildLearnerList(items, contracts, contractMember, "主教練");
                    ds.Tables.Add(table);
                }

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode($"{coach?.UserProfile.Nickname}LeanerList"), DateTime.Now), viewModel.FileDownloadToken);
            }

            return new EmptyResult();
        }

        private DataTable BuildLearnerList(IQueryable<UserProfile> items, IQueryable<CourseContract> contracts, System.Data.Linq.Table<CourseContractMember> contractMember, string title)
        {
            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("編號", typeof(String)));
            table.Columns.Add(new DataColumn("學生", typeof(String)));
            table.Columns.Add(new DataColumn("狀態", typeof(String)));
            table.Columns.Add(new DataColumn("性別", typeof(String)));
            table.Columns.Add(new DataColumn("年齡", typeof(String)));
            table.Columns.Add(new DataColumn("所屬教練", typeof(String)));
            table.Columns.Add(new DataColumn("主教練", typeof(String)));
            table.Columns.Add(new DataColumn("建檔日", typeof(String)));
            table.Columns.Add(new DataColumn("生效中合約", typeof(int)));

            table.TableName = $"{title}";

            foreach (var item in items)
            {
                var r = table.NewRow();
                r[0] = item.MemberCode;
                r[1] = item.FullName();
                if (item.LevelID == (int)Naming.MemberStatusDefinition.Anonymous)
                {
                    r[2] = "幽靈";
                }
                else
                {
                    r[2] = "正式";
                }
                r[3] = item.UserProfileExtension.Gender == "F" ? "女" : "男";
                r[4] = item.YearsOld();
                r[5] = String.Join("、", item.LearnerFitnessAdvisor.ToList().Select(a => a.ServingCoach.UserProfile.FullName()));
                r[6] = String.Join("、", item.LearnerCoachProperty.Where(p => p.PropertyID == (int)LearnerCoachProperty.PropertyType.PrimaryCoach).ToList().Select(c => c.ServingCoach.UserProfile.FullName()));
                r[7] = item.CreateTime?.ToString("yyyy/MM/dd") ?? "";
                r[8] = contracts.Where(c => contractMember.Any(m => m.UID == item.UID && m.ContractID == c.ContractID)).Count();

                table.Rows.Add(r);
            }

            return table;
        }
    }
}
