using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
using System.Drawing;
using System.Drawing.Imaging;
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

using CommonLib.DataAccess;

using MessagingToolkit.QRCode.Codec;
using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.WebUtilities;

namespace WebHome.Controllers
{
    public class PublishedController : SampleController<UserProfile>
    {
        public PublishedController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        protected float _dpi = 600f;

        protected QRCodeEncoder.ERROR_CORRECTION _errorCorrect = QRCodeEncoder.ERROR_CORRECTION.L;

        // GET: Error
        public async Task<ActionResult> GetBarCode39Async(String code)
        {

            Response.ContentType = "image/Jpeg";
            //response.Buffer = true;
            //response.ExpiresAbsolute = System.DateTime.Now.AddMilliseconds(0);
            //response.Expires = 0;

            if (!String.IsNullOrEmpty(code))
            {
                try
                {
                    using (Bitmap img = code.GetCode39(false))
                    {
                        img.SetResolution(_dpi, _dpi);
                        using (FileBufferingWriteStream output = new FileBufferingWriteStream())
                        {
                            img.Save(output, ImageFormat.Jpeg);
                            //output.Seek(0, SeekOrigin.Begin);
                            await output.DrainBufferAsync(Response.Body);
                        }
                    }
                }
                catch (Exception ex)
                {
                    ApplicationLogging.CreateLogger<PublishedController>().LogError(ex, ex.Message);
                }
            }

            //context.Response.CacheControl = "no-cache";
            //context.Response.AppendHeader("Pragma", "No-Cache");

            return new EmptyResult();
        }

        public async Task<ActionResult> GetQRCodeAsync(String text, QRCodeEncoder.ENCODE_MODE? enc,int? scale,int? ver, QRCodeEncoder.ERROR_CORRECTION? ec,float? dpi)
        {
            Response.ContentType = "image/Jpeg";
            //response.Buffer = true;
            //response.ExpiresAbsolute = System.DateTime.Now.AddMilliseconds(0);
            //response.Expires = 0;

            if (!enc.HasValue)
            {
                enc = QRCodeEncoder.ENCODE_MODE.BYTE;
            }

            if (!scale.HasValue)
            {
                scale = 4;
            }

            if (!ver.HasValue)
            {
                ver = 6;
            }

            if (!ec.HasValue)
            {
                ec = QRCodeEncoder.ERROR_CORRECTION.L;
            }

            if (!dpi.HasValue)
            {
                dpi = 600f;
            }

            try
            {
                using (Bitmap img = text.CreateQRCode(enc.Value, scale.Value, ver.Value, ec.Value))
                {
                    img.SetResolution(_dpi, _dpi);
                    using (FileBufferingWriteStream output = new FileBufferingWriteStream())
                    {
                        img.Save(output, ImageFormat.Jpeg);
                        //output.Seek(0, SeekOrigin.Begin);
                        await output.DrainBufferAsync(Response.Body);
                    }
                }
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<PublishedController>().LogError(ex, ex.Message);
            }

            //context.Response.CacheControl = "no-cache";
            //context.Response.AppendHeader("Pragma", "No-Cache");

            return new EmptyResult();
        }


    }
}