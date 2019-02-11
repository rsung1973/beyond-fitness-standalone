using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Web;
using System.Web.Mvc;

using CommonLib.DataAccess;
using MessagingToolkit.QRCode.Codec;
using Utility;
using WebHome.Controllers;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Helper.BusinessOperation
{
    public static class DataQueryExtensions
    {
        public static IQueryable<CourseContract> InquireContractByCustom<TEntity>(this CourseContractQueryViewModel viewModel, SampleController<TEntity> controller, out String alertMessage)
                where TEntity : class, new()
        {
            alertMessage = null;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();
            bool hasConditon = false;

            IQueryable<CourseContract> items;

            if (viewModel.ContractQueryMode == Naming.ContractServiceMode.ContractOnly)
            {
                items = models.PromptContract();
            }
            else if (viewModel.ContractQueryMode == Naming.ContractServiceMode.ServiceOnly)
            {
                items = models.PromptContractService();
            }
            else
            {
                items = models.GetTable<CourseContract>();
            }

            if (viewModel.ContractDateFrom.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.ContractDate >= viewModel.ContractDateFrom);
            }

            if (viewModel.ContractDateTo.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.ContractDate < viewModel.ContractDateTo.Value);
            }

            Expression<Func<CourseContract, bool>> queryExpr = c => false;
            bool subCondition = false;

            viewModel.ContractNo = viewModel.ContractNo.GetEfficientString();
            if (viewModel.ContractNo != null)
            {
                subCondition = true;
                var no = viewModel.ContractNo.Split('-');
                if (no.Length > 1)
                {
                    int.TryParse(no[1], out int seqNo);
                    queryExpr = queryExpr.Or(c => c.ContractNo.StartsWith(no[0])
                        && c.SequenceNo == seqNo);
                }
                else
                {
                    queryExpr = queryExpr.Or(c => c.ContractNo.StartsWith(viewModel.ContractNo));
                }
            }

            viewModel.RealName = viewModel.RealName.GetEfficientString();
            if (viewModel.RealName != null)
            {
                subCondition = true;
                queryExpr = queryExpr.Or(c => c.CourseContractMember.Any(m => m.UserProfile.RealName.Contains(viewModel.RealName) || m.UserProfile.Nickname.Contains(viewModel.RealName)));
            }

            if (hasConditon)
            {
                if (subCondition)
                {
                    items = items.Where(queryExpr);
                }
                else
                {
                    if (viewModel.FitnessConsultant.HasValue)
                    {
                        hasConditon = true;
                        items = items.Where(c => c.FitnessConsultant == viewModel.FitnessConsultant);
                    }

                    if (viewModel.ManagerID.HasValue)
                    {
                        hasConditon = true;
                        items = items.FilterByBranchStoreManager(models, viewModel.ManagerID);
                    }

                    if (viewModel.OfficerID.HasValue)
                    {
                        hasConditon = true;
                    }
                }
            }
            else
            {
                if (subCondition)
                {
                    items = items.Where(queryExpr);
                }
                else
                {
                    //items = items.Where(c => false);
                    //return Json(new { result = false, message = "請設定查詢條件!!" });
                    ModelState.AddModelError("RealName", "請輸入查詢學生姓名(暱稱)!!");
                    ModelState.AddModelError("ContractNo", "請輸入查詢合約編號!!");
                    ModelState.AddModelError("ContractDateFrom", "請輸入查詢合約起日!!");
                    ModelState.AddModelError("ContractDateTo", "請輸入查詢合約迄日!!");
                    ViewBag.ModelState = ModelState;
                    return null;
                }
            }

            return items;
        }

    }
}