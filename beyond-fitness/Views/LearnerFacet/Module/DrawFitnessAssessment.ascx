<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  Html.RenderAction("PersonalStrengthAssessment", "LearnerFacet", new { uid = _model, itemID = new int[] { 23, 24, 25, 26, 34, 35 } }); %>
<%  Html.RenderAction("MuscleStrengthAssessment", "LearnerFacet", new { uid = _model, itemID = new int[] { 16,17,52 } }); %>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    int _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (int)this.Model;
    }

</script>
