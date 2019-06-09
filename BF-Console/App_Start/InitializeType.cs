using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebHome.Helper;
using WebHome.Properties;

namespace WebHome.App_Start
{
    public static class InitializeType
    {
        public static void InitializeApp()
        {
            BusinessExtensionMethods.ContractViewUrl = item =>
            {
                return $"{Settings.Default.HostDomain}{VirtualPathUtility.ToAbsolute("~/CommonHelper/ViewContract")}?pdf=1&contractID={item.ContractID}&t={DateTime.Now.Ticks}";
            };

            BusinessExtensionMethods.ContractServiceViewUrl = item =>
            {
                return $"{Settings.Default.HostDomain}{VirtualPathUtility.ToAbsolute("~/CommonHelper/ViewContractService")}?pdf=1&revisionID={item.RevisionID}&t={DateTime.Now.Ticks}";
            };

            Settings.Default["ReportInputError"] = "~/Views/ConsoleHome/Shared/ReportInputError.cshtml";
        }
    }
}