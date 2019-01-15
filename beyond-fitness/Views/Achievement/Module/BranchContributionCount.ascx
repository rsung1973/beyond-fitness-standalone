<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%  
        var interval = _viewModel.AchievementDateTo - _viewModel.AchievementDateFrom;
        if (interval.HasValue)
        {
            if (interval.Value.TotalDays > 31)
            {
                Html.RenderPartial("~/Views/Achievement/Module/BranchContributionCountByMonth.ascx", _model);
            }
            else
            {
                Html.RenderPartial("~/Views/Achievement/Module/BranchContributionCountByDay.ascx", _model);
            }
        }

     %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "lesson" + DateTime.Now.Ticks;
    IQueryable<TuitionAchievement> _model;
    AchievementQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<TuitionAchievement>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }

</script>
