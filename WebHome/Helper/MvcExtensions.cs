using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using System.Web.UI;
using WebHome.Models.DataEntity;
using WebHome.Models.ViewModel;
using System.Threading.Tasks;
using System.IO;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using System.Data;
using Microsoft.AspNetCore.Http;
using CommonLib.Core.Utility;

namespace WebHome.Helper
{
    public static class MvcExtensions
    {
        public static async Task RenderInputAsync(this HtmlHelper Html, String label, String id, String name, String placeHolder, ModelStateDictionary modelState, String inputType = "text", String defaultValue = null)
        {
            bool? isValid = modelState == null ? (bool?)null : modelState[name] == null || modelState[name].Errors.Count <= 0;
            await Html.RenderPartialAsync("~/Views/Shared/HtmlInput.ascx",
                new InputViewModel
                {
                    ErrorMessage = isValid == false ? String.Join("、", modelState[name].Errors.Select(r => r.ErrorMessage)) : null,
                    Id = id,
                    IsValid = isValid,
                    Label = label,
                    PlaceHolder = placeHolder,
                    Name = name,
                    InputType = inputType,
                    Value = defaultValue
                });
        }

        public static async Task RenderPasswordAsync(this HtmlHelper Html, String label, String id, String name, String placeHolder, ModelStateDictionary modelState)
        {
            bool? isValid = modelState == null ? (bool?)null : modelState[name] == null || modelState[name].Errors.Count <= 0;
            await Html.RenderPartialAsync("~/Views/Shared/HtmlInput.ascx",
                new InputViewModel
                {
                    ErrorMessage = isValid == false ? String.Join("、", modelState[name].Errors.Select(r => r.ErrorMessage)) : null,
                    Id = id,
                    IsValid = isValid,
                    Label = label,
                    PlaceHolder = placeHolder,
                    Name = name,
                    InputType = "password"
                });
        }


        public static void RenderUserPicture(this UserProfile profile, HtmlTextWriter writer, String tagId)
        {
            profile.PictureID.RenderUserPicture(writer, tagId);
        }

        public static void RenderUserPicture(this int? pictureID, HtmlTextWriter writer, String tagId)
        {
            writer.WriteLine(
                String.Concat("<img id=\"", tagId,
                "\" src=\"",
                pictureID.HasValue ? VirtualPathUtility.ToAbsolute("~/Information/GetResource/") + pictureID + "?stretch=true" : VirtualPathUtility.ToAbsolute("~/img/avatars/male.png"),
                "\" />"));
        }

        public static void RenderUserPicture(this UserProfile profile, HtmlTextWriter writer, Object htmlAttributes)
        {
            profile.PictureID.RenderUserPicture(writer, htmlAttributes);
        }


        public static void RenderUserPicture(this int? pictureID, HtmlTextWriter writer, Object htmlAttributes,String noName = null)
        {
            if (htmlAttributes != null)
            {
                foreach (var item in HtmlHelper.AnonymousObjectToHtmlAttributes(htmlAttributes))
                {
                    writer.AddAttribute(item.Key, (String)item.Value);
                }
            }

            writer.AddAttribute("src", pictureID.HasValue 
                ? VirtualPathUtility.ToAbsolute("~/Information/GetResource/") + pictureID + "?stretch=true" 
                : (noName ?? VirtualPathUtility.ToAbsolute("~/img/avatars/male.png")));
            writer.RenderBeginTag(HtmlTextWriterTag.Img);
            writer.RenderEndTag();

        }

        public static String GetVipName(this UserProfile profile)
        {
            return profile.UserName ?? profile.RealName;
        }

        public static String ErrorMessage(this ModelStateDictionary modelState)
        {
            return String.Join("、", modelState.Keys.Where(k => modelState[k].Errors.Count > 0)
                    .Select(k => /*k + " : " +*/ String.Join("/", modelState[k].Errors.Select(r => r.ErrorMessage))));
        }

        public static String HtmlBreakLine(this String strVal)
        {
            if(strVal != null)
            {
                return strVal.Replace("\r\n", "<br/>").Replace("\n", "<br/>");
            }
            return null;
        }

        public static async Task SaveAsExcelAsync(this DataSet ds,HttpResponse response,String disposition,String fileDownloadToken = null)
        {
            response.Cookies.Append("fileDownloadToken", fileDownloadToken);
            response.Headers.Add("Cache-control", "max-age=1");
            response.ContentType = "application/vnd.ms-excel";
            response.Headers.Add("Content-Disposition", disposition);

            using (var xls = ds.ConvertToExcel())
            {
                String tmpPath = Path.Combine(FileLogger.Logger.LogDailyPath, $"{DateTime.Now.Ticks}.tmp");
                using (FileStream tmp = System.IO.File.Create(tmpPath))
                {
                    xls.SaveAs(tmp);
                    tmp.Flush();
                    tmp.Position = 0;

                    await tmp.CopyToAsync(response.Body);
                }
                await response.Body.FlushAsync();

                System.IO.File.Delete(tmpPath);
            }

        }

    }
}