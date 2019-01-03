using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Html;
using System.Web.UI;
using WebHome.Models.DataEntity;
using WebHome.Models.ViewModel;

namespace WebHome.Helper
{
    public static class MvcExtensions
    {
        public static void RenderInput(this HtmlHelper Html, String label, String id, String name, String placeHolder, ModelStateDictionary modelState, String inputType = "text", String defaultValue = null)
        {
            bool? isValid = modelState == null ? (bool?)null : modelState[name] == null || modelState[name].Errors.Count <= 0;
            Html.RenderPartial("~/Views/Shared/HtmlInput.ascx",
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

        public static void RenderPassword(this HtmlHelper Html, String label, String id, String name, String placeHolder, ModelStateDictionary modelState)
        {
            bool? isValid = modelState == null ? (bool?)null : modelState[name] == null || modelState[name].Errors.Count <= 0;
            Html.RenderPartial("~/Views/Shared/HtmlInput.ascx",
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

    }
}