using System;
using System.Collections.Generic;
using System.Data;

using System.IO;
using System.IO.Compression;
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

using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc.Filters;
using WebHome.Properties;
using System.Net.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Http;
using CommonLib.Core.Utility;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Newtonsoft.Json.Linq;
using System.Text.Json.Nodes;

namespace WebHome.Controllers
{
    [Authorize]
    public class LearnerActivityController : ActivityBaseController
    {
        public LearnerActivityController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

        [HttpPost]
        public async Task<ActionResult> UpdateProfileImageAsync([FromBody]LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null || !(viewModel.DataContent?.Length > 0))
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            var idx = viewModel.DataContent.IndexOf(',');
            if (!(idx > 0))
            {
                return Json(new { result = false, message = "請選擇圖像檔!!" });
            }


            String storePath = Path.Combine(FileLogger.Logger.LogDailyPath, Guid.NewGuid().ToString() + ".dat");
            System.IO.File.WriteAllBytes(storePath, Convert.FromBase64String(viewModel.DataContent.Substring(idx + 1)));

            item = item.LoadInstance(models);
            if (item.Attachment == null)
            {
                item.Attachment = new Attachment
                {

                };
            }

            item.Attachment.StoredPath = storePath;
            models.SubmitChanges();

            return Json(new { result = true, pictureID = item.PictureID });
        }

        [HttpPost]
        public async Task<ActionResult> CommitUserNameAsync([FromBody] LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName == null)
            {
                return Json(new { result = false, message = "請輸入暱稱!!" });
            }

            item = item.LoadInstance(models);
            item.UserName = viewModel.UserName;
            models.SubmitChanges();

            return Json(new { result = true });
        }

        [HttpPost]
        public async Task<ActionResult> CommitCarrierNoAsync([FromBody] LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            viewModel.CarrierNo = viewModel.CarrierNo.GetEfficientString();
            if (viewModel.CarrierNo == null || !Regex.IsMatch(viewModel.CarrierNo, "^/[A-Z0-9+-\\.]{7}$"))
            {
                return Json(new { result = false, message = "請輸入正確手機載具條碼!!" });
            }

            item = item.LoadInstance(models);
            item.UserProfileExtension.CarrierNo = viewModel.CarrierNo;
            models.SubmitChanges();

            return Json(new { result = true });
        }

        [HttpPost]
        public async Task<ActionResult> UnbindLineAsync([FromBody] LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            item = item.LoadInstance(models);
            item.UserProfileExtension.LineID = null;
            models.SubmitChanges();

            return Json(new { result = true });
        }


        [HttpPost]
        public async Task<ActionResult> CommitUserProfileAsync([FromBody] JsonObject viewModel)
        {
            ViewBag.ViewModel = viewModel;
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            String itemName = ((String)viewModel["ItemName"]).GetEfficientString();
            if (itemName == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }


            //viewModel.UserName = viewModel.UserName.GetEfficientString();
            //if (viewModel.UserName == null)
            //{
            //    return Json(new { result = false, message = "請輸入暱稱!!" });
            //}

            //item = item.LoadInstance(models);
            //item.UserName = viewModel.UserName;
            //models.SubmitChanges();

            return Json(new { result = true });
        }


    }
}