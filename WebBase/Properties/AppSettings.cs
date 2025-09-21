using CommonLib.Core.Utility;
using CommonLib.Utility;
using CommonLib.Utility.Properties;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using WebHome.Models.ViewModel;

namespace WebHome.Properties
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

        [JsonIgnore]
        public String AuthorizationCode
        {
            get => EncAuthorizationCode != null ? EncAuthorizationCode.DecryptKey() : null;
            set => EncAuthorizationCode = value?.EncryptKey();
        }

        public String EncAuthorizationCode
        {
            get;
            set;
        }

        public String Language { get; set; } = "zh-TW";

        public SmtpSettings Smtp
        {
            get;
            set;
        } = new SmtpSettings { };

        public ReCaptchaSettings ReCaptcha { get; set; } 
            = new ReCaptchaSettings { };

        public String BFDbConnection { get; set; }

        public String GTM_Key { get; set; } = "GTM-MPFS89SL";

        public String BPointsGTM_Key { get; set; } = "GTM-PFN8CHCM";

        public String EIPGTM_Key { get; set; } = "GTM-PHVLDDJ8";

        public String TurnkeyCheckListPath { get; set; } = Path.Combine(FileLogger.Logger.LogPath, "TurnkeyCheckList").CheckStoredPath();
        public String TurnkeyCheckUrl { get; set; } = "https://egui.uxifs.com/eivohub/_Test/CheckTurnkeyResult";
        public LineAuthInfo LineAuth { get; set; } = new LineAuthInfo { };
        public String WebHomePage { get; set; } = "~/MainActivity/Main";
        public String CommonErrorView { get; set; } = "~/Views/Error/Error.cshtml";
        public bool EnableJobScheduler { get; set; } = true;
        public int[] SeniorityBonusAvailableLevel { get; set; } = [40,41,49,50];
    }

    public class Settings
    {
        static Settings _default = new Settings { };

        public static Settings Default => _default;
        public String BFDbConnection => WebApp.GlobalConfiguration.GetConnectionString("BFDbConnection") ?? AppSettings.Default.BFDbConnection;

    }

    public class SmtpSettings
    {
        public String Host { get; set; } = "localhost";
        public int Port { get; set; } = 25;
        public bool EnableSsl { get; set; } = false;
        public String UserName { get; set; }
        public String Password { get; set; }
    }

    public class ReCaptchaSettings
    {
        public String SiteKey { get; set; } = "6LdVot4jAAAAAH_ST-lvJBJLM3gdWAId2DnlLBz_";
        public String SecretKey { get; set; } = "6LdVot4jAAAAAKfJuBeP_35ZeNy7lvi0D3Pghdu1";
        public String UrlVerification { get; set; } = "https://www.google.com/recaptcha/api/siteverify";
    }

    public class LineAuthInfo
    {
        public string ChannelID { get; set; } = "2004831703";
        public string ChannelSecret { get; set; } = "1b36aa193695a91d6d6c2937f78f9a02";
        public string LineAuthUrl { get; set; } = "https://access.line.me/oauth2/v2.1/authorize";
        public string ReturnUrl { get; set; } = "https://test.beyond-fitness.com.tw/WebHome/LineEvents/Auth";
        public string CampaignUrl { get; set; } = "https://test.beyond-fitness.com.tw/WebHome/Official/tw/Campaign";
    }
}