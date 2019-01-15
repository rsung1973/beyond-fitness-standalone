<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>


<%  Html.RenderPartial("~/Views/Payment/Section/PaymentInvoiceList/TD.ascx",_model); %>
<td>
    <%= String.Format("{0:##,###,###,##0}", _model.EffectiveAchievement()) %>
</td>
<td nowrap="noWrap">
    <%= String.Join("<br/>", _model.TuitionAchievement.Select(a=> String.Format("{0} 【${1:##,###,###,###}】",a.ServingCoach.UserProfile.RealName,a.ShareAmount)))   %>
</td>
<td>
    <a onclick="$global.editAchievement(<%= _model.PaymentID %>);" class="btn btn-circle bg-color-yellow" id="modifyBenefitDialog_link"><i class="fa fa-fw fa fa-lg fa-edit" aria-hidden="true"></i></a>
</td>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    Payment _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (Payment)this.Model;
    }

</script>
