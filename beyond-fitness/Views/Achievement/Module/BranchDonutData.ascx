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
<%= JsonConvert.SerializeObject(result) %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonTime> _model;
    AchievementQueryViewModel _viewModel;
    decimal[] result;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;

        List<decimal> items = new List<decimal>();

        var PTCount = _model.PTLesson().Count();
        var PICount = _model.Where(l => l.TrainingBySelf == 1).Count();
        var trialCount = _model.TrialLesson().Count();

        var totalCount = PTCount + PICount + trialCount;

        if (totalCount > 0)
        {
            items.Add(Math.Round(PTCount * 100m / totalCount));
            items.Add(Math.Round(PICount * 100m / totalCount));
            items.Add(Math.Round(trialCount * 100m / totalCount));

            result = items.ToArray();
        }
    }

</script>
