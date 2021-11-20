using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Text;
using Utility;

namespace CommonLib.Web
{
    public static partial class WebMessageBox
    {
        public static void Alert(Page page, string alertMsg)
        {
            if (alertMsg != null)
            {
                String msg = HttpUtility.JavaScriptStringEncode(alertMsg);
                page.ClientScript.RegisterStartupScript(typeof(WebMessageBox), "alertMsg", String.Format("alert('{0}');", msg), true);
            }
        }

        public static void AjaxAlert(this Control control, string alertMsg)
        {
            if (alertMsg != null)
            {
                String msg = HttpUtility.JavaScriptStringEncode(alertMsg);
                if (ScriptManager.GetCurrent(control.Page) != null)
                {
                    ScriptManager.RegisterStartupScript(control, typeof(WebMessageBox), "alertMsg", String.Format("alert('{0}');", msg), true);
                }
                else
                {
                    control.Page.ClientScript.RegisterStartupScript(typeof(WebMessageBox), "alertMsg", String.Format("alert('{0}');", msg), true);
                }
            }
        }

        public static void AjaxAlertAndRedirect(this Control control, string alertMsg, String url)
        {
            if (alertMsg != null)
            {
                String msg = HttpUtility.JavaScriptStringEncode(alertMsg);
                if (ScriptManager.GetCurrent(control.Page) != null)
                {
                    ScriptManager.RegisterStartupScript(control, typeof(WebMessageBox), "alertMsg", String.Format("alert('{0}');window.location.href='{1}';", msg, url), true);
                }
                else
                {
                    control.Page.ClientScript.RegisterStartupScript(typeof(WebMessageBox), "alertMsg", String.Format("alert('{0}');window.location.href='{1}';", msg, url), true);
                }
            }
        }

        public static void Confirm(Page page, string alertMsg, string yesUrl, string noUrl)
        {
            if (!String.IsNullOrEmpty(yesUrl))
            {
                if (!String.IsNullOrEmpty(noUrl))
                {
                    page.ClientScript.RegisterStartupScript(typeof(WebMessageBox), "confirmMsg", String.Format("if (confirm('{0}')) {{window.location.href='{1}';}} else {{window.location.href='{2}';}}",
                        alertMsg, yesUrl, noUrl), true);
                }
                else
                {
                    page.ClientScript.RegisterStartupScript(typeof(WebMessageBox), "confirmMsg", String.Format("if (confirm('{0}')) {{window.location.href='{1}';}} ",
                        alertMsg, yesUrl), true);
                }
            }
            else
            {
                if (!String.IsNullOrEmpty(noUrl))
                    page.ClientScript.RegisterStartupScript(typeof(WebMessageBox), "confirmMsg", String.Format("if (confirm('{0}')) {{}} else {{window.location.href='{1}';}}",
                        alertMsg, noUrl), true);
                else
                    page.ClientScript.RegisterStartupScript(typeof(WebMessageBox), "confirmMsg", String.Format("if (confirm('{0}')) {{}} else {{}}",
                        alertMsg), true);
            }
        }

        public static void AlertOnly(this Page page, string alertMsg)
        {
            page.Response.Clear();
            page.Response.Write("<script>alert('" + HttpUtility.JavaScriptStringEncode(alertMsg) + "');</script>");
            page.Response.End();
        }


    }

    public partial class WebInputTool
    {
        public static void ResetAllServerInputFields(Control control)
        {
            if (control.HasControls())
            {
                foreach (Control ctrl in control.Controls)
                {
                    ResetAllServerInputFields(ctrl);
                }
            }
            else
            {
                if (control is TextBox)
                {
                    ((TextBox)control).Text = "";
                }
                else if (control is HtmlInputText)
                {
                    ((HtmlInputText)control).Value = "";
                }
                else if (control is HtmlInputPassword)
                {
                    ((HtmlInputPassword)control).Value = "";
                }
                else if (control is HtmlTextArea)
                {
                    ((HtmlTextArea)control).Value = "";
                }
            }
        }

        public static void ResetAllServerInputFieldsToUpperCase(Control control)
        {
            if (control.HasControls())
            {
                foreach (Control ctrl in control.Controls)
                {
                    ResetAllServerInputFieldsToUpperCase(ctrl);
                }
            }
            else
            {
                if (control is TextBox)
                {
                    ((TextBox)control).Text = ((TextBox)control).Text.ToUpper();
                }
                else if (control is HtmlInputText)
                {
                    ((HtmlInputText)control).Value = ((HtmlInputText)control).Value.ToUpper();
                }
                else if (control is HtmlTextArea)
                {
                    ((HtmlTextArea)control).Value = ((HtmlTextArea)control).Value.ToUpper();
                }
            }
        }


        public static void ResetAllClientInputFields(Page page)
        {
            if (!page.ClientScript.IsClientScriptBlockRegistered(typeof(WebInputTool), "resetAllInput"))
            {
                page.ClientScript.RegisterClientScriptBlock(typeof(WebInputTool), "resetAllInput", @"
                        function resetAllField() {
                            if (document.forms != null) {
                                var formLength = document.forms.length;
                                for (var f_index = 0; f_index < formLength; f_index++) {
                                    var theForm = document.forms[f_index];
                                    if (theForm.elements != null && theForm.elements.length > 0) {
                                        var elementsLength = theForm.elements.length;
                                        for (var e_index = 0; e_index < elementsLength; e_index++) {
                                            var element = theForm.elements[e_index];
                                            if (element.type == 'text' || element.type == 'password' || element.type=='textarea') {
                                                element.value = '';
                                            }
                                        }
                                    }
                                }
                            }
                        }
                ", true);
            }

            if (!page.ClientScript.IsStartupScriptRegistered(typeof(WebInputTool), "onStart"))
            {
                page.ClientScript.RegisterStartupScript(typeof(WebInputTool), "onStart", "resetAllField();", true);
            }

        }
    }

    public static partial class ExtensionMethods
    {
        public static void AlertFailToDelete(this Control ctrl, Exception ex)
        {
            Logger.Error(ex);
            WebMessageBox.Alert(ctrl.Page, "刪除資料失敗!!");
        }
    }

    public partial class JsonResult 
    {
        public bool result { get; set; }
        public String message { get; set; }
    }

}
