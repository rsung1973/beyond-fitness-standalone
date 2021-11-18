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

namespace WebHome.Components
{
    public class EditPaymentForContractViewComponent : ContractConsoleViewComponent
    {

        public EditPaymentForContractViewComponent() : base()
        {

        }

        public IViewComponentResult Invoke(PaymentViewModel viewModel)
        {
            return EditPaymentForContract(viewModel);
        }

    }
}
