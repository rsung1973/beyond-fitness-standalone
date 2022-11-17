using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading;
using System.Web;
using Microsoft.AspNetCore.Mvc;
using CommonLib.DataAccess;
//using MessagingToolkit.QRCode.Codec;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Logging;
using MessagingToolkit.QRCode.Codec;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static partial class ExtensionMethods
    {
        public static void SetModelSource(this TempDataDictionary tempData, GenericManager<BFDataContext> models)
            
        {
            tempData["modelSource"] = models;
        }

        public static GenericManager<BFDataContext> GetModelSource(this TempDataDictionary tempData)
            
        {
            return (GenericManager<BFDataContext>)tempData["modelSource"];
        }

        public static GenericManager<BFDataContext> GetGenericModelSource(this TempDataDictionary tempData)
        {
            return (GenericManager<BFDataContext>)tempData["modelSource"];
        }

        public static IQueryable<Article> GetNormalArticles(this GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<Article>()
                .Where(a => a.Document.CurrentStep == (int)Naming.DocumentLevelDefinition.正常);
        }

        public static void NotifyResetPassword(this ResetPassword item,String notifyUrl = null)
        {
            ThreadPool.QueueUserWorkItem(t => {

                try
                {

                    //StringBuilder body = new StringBuilder();
                    MailMessage message = new MailMessage();
                    message.ReplyToList.Add(Startup.Properties["WebMaster"]);
                    message.From = new MailAddress(Startup.Properties["WebMaster"]);
                    message.To.Add(item.UserProfile.PID);
                    message.Subject = "Beyond-fitness會員密碼重設通知";
                    message.IsBodyHtml = true;

                    //body.Append("您好，請由下列連結重設您的密碼，謝謝。<br/>")
                    //    .Append("<a href=").Append(Startup.Properties["HostDomain"]).Append(VirtualPathUtility.ToAbsolute("~/Account/ResetPass"))
                    //    .Append("/").Append(item.ResetID)
                    //    .Append(">會員重設密碼</a>");

                    using (WebClient client = new WebClient())
                    {
                        client.Encoding = Encoding.UTF8;
                        message.Body = client.DownloadString((notifyUrl ?? Startup.Properties["HostDomain"] + VirtualPathUtility.ToAbsolute("~/Account/NotifyResetPassword")) + "?resetID=" + item.ResetID);
                    }

                    //message.Body = body.ToString();

                    using SmtpClient smtpclient = new SmtpClient(AppSettings.Default.Smtp.Host, AppSettings.Default.Smtp.Port);
                    smtpclient.EnableSsl = AppSettings.Default.Smtp.EnableSsl;
                    //smtpclient.UseDefaultCredentials = false;
                    if(AppSettings.Default.Smtp.UserName != null)
                    {
                        smtpclient.Credentials = new NetworkCredential(AppSettings.Default.Smtp.UserName, AppSettings.Default.Smtp.Password);
                    }
                    //smtpclient.Credentials = CredentialCache.DefaultNetworkCredentials;
                    smtpclient.Send(message);
                }
                catch(Exception ex)
                {
                    ApplicationLogging.LoggerFactory.CreateLogger(typeof(ExtensionMethods))
                        .LogError(ex, ex.Message);
                }
            });
        }

        public static Bitmap CreateQRCode(this String content, QRCodeEncoder.ENCODE_MODE encoding, int scale, int version, QRCodeEncoder.ERROR_CORRECTION errorCorrect)
        {
            if (String.IsNullOrEmpty(content))
            {
                return null;
            }

            QRCodeEncoder qrCodeEncoder = new QRCodeEncoder();

            qrCodeEncoder.QRCodeScale = scale;
            qrCodeEncoder.QRCodeVersion = version;
            qrCodeEncoder.QRCodeErrorCorrect = errorCorrect;
            qrCodeEncoder.CharacterSet = "UTF-8";

            return qrCodeEncoder.Encode(content);

        }

        public static String CreateQRCodeImageSrc(this String content, QRCodeEncoder.ENCODE_MODE encoding = QRCodeEncoder.ENCODE_MODE.BYTE, int scale = 4, int version = 8, QRCodeEncoder.ERROR_CORRECTION errorCorrect = QRCodeEncoder.ERROR_CORRECTION.L,float dpi = 600f)
        {
            using (Bitmap img = content.CreateQRCode(encoding, scale, version, errorCorrect))
            {
                using (MemoryStream buffer = new MemoryStream())
                {
                    img.SetResolution(dpi, dpi);
                    img.Save(buffer, ImageFormat.Png);
                    StringBuilder sb = new StringBuilder("data:image/png;base64,");
                    sb.Append(Convert.ToBase64String(buffer.ToArray()));
                    return sb.ToString();
                }
            }
        }

        public static int AdjustTrustAmount(this int? amount)
        {
            return amount.HasValue 
                ? amount>=0
                    ? (amount.Value * 2 + 5) / 10
                    : (amount.Value * 2 - 5) / 10
                : 0;
        }

        public static int AdjustTrustAmount(this int amount)
        {
            return amount >= 0
                    ? (amount * 2 + 5) / 10
                    : (amount * 2 - 5) / 10;
        }

        public static String TruthValue(this bool? value)
        {
            return value == true
                    ? "是"
                    : value == false
                        ? "否"
                        : null;
        }

    }
}