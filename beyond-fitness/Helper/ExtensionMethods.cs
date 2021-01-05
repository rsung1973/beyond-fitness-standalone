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
using System.Web.Mvc;
using CommonLib.DataAccess;
using MessagingToolkit.QRCode.Codec;
using Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static partial class ExtensionMethods
    {
        public static void SetModelSource<TEntity>(this TempDataDictionary tempData, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            tempData["modelSource"] = models;
        }

        public static ModelSource<TEntity> GetModelSource<TEntity>(this TempDataDictionary tempData)
            where TEntity : class, new()
        {
            return (ModelSource<TEntity>)tempData["modelSource"];
        }

        public static GenericManager<BFDataContext> GetGenericModelSource(this TempDataDictionary tempData)
        {
            return (GenericManager<BFDataContext>)tempData["modelSource"];
        }


        public static ModelSource<TEntity> InvokeModelSource<TEntity>(this TempDataDictionary tempData)
            where TEntity : class, new()
        {
            GenericManager<BFDataContext> models = tempData.GetGenericModelSource();
            if (models == null)
            {
                models = new ModelSource<TEntity>();
                tempData.SetModelSource<TEntity>((ModelSource<TEntity>)models);
                return (ModelSource<TEntity>)models;
            }
            else if (models is ModelSource<TEntity>)
            {
                return (ModelSource<TEntity>)models;
            }
            else
            {
                return new ModelSource<TEntity>(models);
            }
        }

        public static IQueryable<Article> GetNormalArticles<TEntity>(this ModelSource<TEntity> models)
            where TEntity : class, new()
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
                    message.ReplyToList.Add(Settings.Default.WebMaster);
                    message.From = new MailAddress(Settings.Default.WebMaster);
                    message.To.Add(item.UserProfile.PID);
                    message.Subject = "Beyond-fitness會員密碼重設通知";
                    message.IsBodyHtml = true;

                    //body.Append("您好，請由下列連結重設您的密碼，謝謝。<br/>")
                    //    .Append("<a href=").Append(Settings.Default.HostDomain).Append(VirtualPathUtility.ToAbsolute("~/Account/ResetPass"))
                    //    .Append("/").Append(item.ResetID)
                    //    .Append(">會員重設密碼</a>");

                    using (WebClient client = new WebClient())
                    {
                        client.Encoding = Encoding.UTF8;
                        message.Body = client.DownloadString((notifyUrl ?? Settings.Default.HostDomain + VirtualPathUtility.ToAbsolute("~/Account/NotifyResetPassword")) + "?resetID=" + item.ResetID);
                    }

                        //message.Body = body.ToString();

                    SmtpClient smtpclient = new SmtpClient(Settings.Default.SmtpServer);
                    //smtpclient.Credentials = CredentialCache.DefaultNetworkCredentials;
                    smtpclient.Send(message);
                }
                catch(Exception ex)
                {
                    Logger.Error(ex);
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


    }
}