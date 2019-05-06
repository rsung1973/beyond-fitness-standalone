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
        public static IQueryable<CourseContract> InquireContract<TEntity>(this CourseContractQueryViewModel viewModel, SampleController<TEntity> controller, out String alertMessage)
            where TEntity : class, new()
        {
            alertMessage = null;
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();

            ViewBag.ViewModel = viewModel;

            bool hasConditon = false;
            ViewBag.ViewModel = viewModel;

            IQueryable<CourseContract> items;

            if (viewModel.ContractQueryMode == Naming.ContractServiceMode.ContractOnly)
            {
                if (viewModel.Status >= (int)Naming.CourseContractStatus.已生效)
                {
                    items = models.PromptOriginalContract();
                }
                else if (viewModel.PayoffMode.HasValue)
                {
                    items = models.PromptAccountingContract();
                }
                else
                {
                    items = models.PromptContract();
                }
            }
            else if (viewModel.ContractQueryMode == Naming.ContractServiceMode.ServiceOnly)
            {
                items = models.PromptContractService();
            }
            else
            {
                items = models.GetTable<CourseContract>();
            }

            if (viewModel.PayoffMode == Naming.ContractPayoffMode.Unpaid)
            {
                hasConditon = true;
                items = items
                    .FilterByToPay(models);
            }
            else if (viewModel.PayoffMode == Naming.ContractPayoffMode.Paid)
            {
                hasConditon = true;
                items = items.Where(c => c.ContractPayment.Any());
            }

            if (viewModel.IncludeTotalUnpaid == true)
            {
                Expression<Func<CourseContract, bool>> expr = c => true;
                Expression<Func<CourseContract, bool>> defaultExpr = expr;
                if (viewModel.PayoffDueFrom.HasValue)
                {
                    hasConditon = true;
                    expr = expr.And(c => c.PayoffDue >= viewModel.PayoffDueFrom);
                }

                if (viewModel.PayoffDueTo.HasValue)
                {
                    hasConditon = true;
                    expr = expr.And(c => c.PayoffDue < viewModel.PayoffDueTo);
                }

                if (defaultExpr != expr)
                {
                    expr = expr.Or(c => !c.PayoffDue.HasValue);
                    items = items.Where(expr);
                }
            }
            else
            {
                if (viewModel.PayoffDueFrom.HasValue)
                {
                    hasConditon = true;
                    items = items.Where(c => c.PayoffDue >= viewModel.PayoffDueFrom);
                }

                if (viewModel.PayoffDueTo.HasValue)
                {
                    hasConditon = true;
                    items = items.Where(c => c.PayoffDue < viewModel.PayoffDueTo);
                }
            }

            if (viewModel.Status.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.Status == viewModel.Status);
            }

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

            if (viewModel.IsExpired == true)
            {
                hasConditon = true;
                items = items.FilterByExpired(models);
            }
            else if (viewModel.IsExpired == false)
            {
                hasConditon = true;
                items = items.Where(c => c.Expiration >= DateTime.Today);
            }

            if (viewModel.EffectiveDateFrom.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.EffectiveDate >= viewModel.EffectiveDateFrom);
            }

            if (viewModel.EffectiveDateTo.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.EffectiveDate < viewModel.EffectiveDateTo);
            }

            if (viewModel.ExpirationFrom.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.Expiration >= viewModel.ExpirationFrom);
            }

            if (viewModel.ExpirationTo.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.Expiration < viewModel.ExpirationTo.Value);
            }

            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            if (viewModel.ContractID.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.ContractID == viewModel.ContractID);
            }

            if (viewModel.AlarmCount.HasValue)
            {
                hasConditon = true;
                items = items.FilterByAlarmedContract(models, viewModel.AlarmCount.Value);
            }

            if (viewModel.InstallmentID.HasValue)
            {
                hasConditon = true;
                items = items.Where(c => c.InstallmentID == viewModel.InstallmentID);
            }

            if (hasConditon)
            {

            }
            else
            {
                items = items.Where(c => false);
            }

            //if (viewModel.ContractType.HasValue)
            //    items = items.Where(c => c.ContractType == viewModel.ContractType);
            return items;
        }

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