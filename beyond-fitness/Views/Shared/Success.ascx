<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (ViewBag.Success != null)
    { %>
        <div class="message" style="display: block;" id="successMsg">
            <i class="fa fa-check fa-lg"></i>
            <p class="text-center">
                <%= ViewBag.Success %>
            </p>
        </div>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        if(ViewBag.Success==null)
        {
            ViewBag.Success = this.Model;
        }
    }

</script>
