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
    if (_viewModel.AchievementDateFrom == _viewModel.AchievementDateTo)
    {
        Html.RenderPartial("~/Views/Achievement/Module/BranchLessonCountByHour.ascx", _model);
    }
    else
    {
        var interval = _viewModel.AchievementDateTo - _viewModel.AchievementDateFrom;
        if (interval.HasValue)
        {
            if (interval.Value.TotalDays > 31)
            {
                Html.RenderPartial("~/Views/Achievement/Module/BranchLessonCountByMonth.ascx", _model);
            }
            else
            {
                Html.RenderPartial("~/Views/Achievement/Module/BranchLessonCountByDay.ascx", _model);
            }
        }
    }
     %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "lesson" + DateTime.Now.Ticks;
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
