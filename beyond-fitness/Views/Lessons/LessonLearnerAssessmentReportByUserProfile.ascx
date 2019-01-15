<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12 no-padding">
    <!-- new widget -->
    <%  Html.RenderAction("PersonalStrengthAssessment", "Fitness", new { uid = _model.UID, itemID = new int[] { 23, 24, 25, 26, 34, 35 } }); %>
    <!-- end widget -->
    <!-- new widget -->
    <div class="row">
        <%  Html.RenderAction("BodyEnergyAssessment", "Fitness", new { uid = _model.UID, itemID = new int[] { 16, 17 } }); %>
        <%  Html.RenderAction("MuscleStrengthAssessment", "Fitness", new { uid = _model.UID, itemID = new int[] { 52 } }); %>
    </div>
    <!-- end widget -->
</div>


<% Html.RenderPartial("~/Views/Shared/EasyPieView.ascx"); %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }

</script>
