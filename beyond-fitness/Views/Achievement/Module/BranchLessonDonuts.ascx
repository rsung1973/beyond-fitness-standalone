<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  foreach (var b in models.GetTable<BranchStore>())
    {
        ViewBag.BranchStore = b;
%>
<div class="col col-xs-12 col-sm-6 col-md-4">
    <%  Html.RenderPartial("~/Views/Achievement/Module/LessonDonut.ascx"); %>
</div>
<%  } %>
<%  Html.RenderPartial("~/Views/Shared/InitBarChart.ascx"); %>
<script>
    $(function () {
        $global.updateBranchLessonDonuts = function (formData) {
<%  foreach (var b in models.GetTable<BranchStore>())
    {   %>
            $global.updateBranchDonut[<%= b.BranchID %>](formData);
            <%  } %>
        };
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonTime> _model;
    AchievementQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }

</script>
