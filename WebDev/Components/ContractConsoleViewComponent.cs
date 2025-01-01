using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CommonLib.DataAccess;
using CommonLib.Core.Utility;
using CommonLib.Utility;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.DependencyInjection;
using System.Globalization;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web;
using WebHome.Models.DataEntity;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using WebHome.Models.ViewModel;
using WebHome.Models.Locale;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using WebHome.Helper;
using WebHome.Helper.BusinessOperation;

namespace WebHome.Components
{
    public class ContractConsoleViewComponent : ViewComponent
    {
        protected ModelSource<UserProfile> models;
        protected ModelStateDictionary _modelState;

        public ContractConsoleViewComponent()
        {

        }

        public IViewComponentResult EditPaymentForContract(PaymentViewModel viewModel)
        {
            Payment item = viewModel.EditPaymentForContract(this.HttpContext);
            return View("~/Views/ContractConsole/Module/EditPaymentForContract.cshtml", item);
        }

        public IViewComponentResult Invoke(PaymentViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            models = (ModelSource<UserProfile>)HttpContext.Items["Models"];
            _modelState = ViewContext.ModelState;

            return EditPaymentForContract(viewModel);
        }

    }
}
