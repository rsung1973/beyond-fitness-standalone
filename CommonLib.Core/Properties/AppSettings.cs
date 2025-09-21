using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CommonLib.Utility.Properties;

namespace CommonLib.Core.Properties
{
    public partial class AppSettings : AppSettingsBase
    {
        static AppSettings()
        {
            _default = Initialize<AppSettings>(typeof(AppSettings).Namespace);
        }

        public AppSettings() : base()
        {

        }

        static AppSettings _default;
        public static AppSettings Default
        {
            get
            {
                return _default;
            }
        }
        public static void Reload()
        {
            Reload<AppSettings>(ref _default, typeof(AppSettings).Namespace);
        }

        public String IPdfUtilityImpl { get; set; } = "ExternalPdfWrapper.PdfUtility, ExternalPdfWrapper, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null";
        public String IPdfUtilityImplAssembly { get; set; } = "ExternalPdfWrapper, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null";
        public bool SqlLog { get; set; } = true;
        public bool EnableJobScheduler { get; set; } = true;
        public bool IgnoreCertificateRevoked { get; set; } = true;
        public bool SqlLogIgnoreSelect { get; internal set; } = true;
    }

}
