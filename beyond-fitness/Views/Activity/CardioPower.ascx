<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="col col-sm-12 col-md-10">
    <p>
        <% decimal? achievement = null;
            var item17 = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 17).FirstOrDefault();
            var item16 = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 16).FirstOrDefault();
            if(_model.UserProfile.Birthday.HasValue && item16!=null && item17!=null
                && item16.TotalAssessment>0 && item17.TotalAssessment>0)
            {
                achievement = (item17.TotalAssessment - item16.TotalAssessment) / (206.9m - (0.67m * (DateTime.Today.Year - _model.UserProfile.Birthday.Value.Year)) - item16.TotalAssessment) * 100;
            }
              %>
        <span class="label label-info">Info!</span> 能量系統訓練強度 = (能量系統訓練當下心跳率 - 安靜心跳率 ) / (206.9 - (0.67 ＊ 年齡) - 安靜心跳率)
                                                                                            <span class="text-warning pull-right"><i class="fa fa-heartbeat"></i><%= String.Format("{0:.}",achievement) %>% Achieve</span>
    </p>
    <div class="progress">
        <div class="progress progress-striped">
            <div class="progress-bar txt-color-pink" role="progressbar" style="width: <%= String.Format("{0:.}",achievement) %>%"></div>
        </div>
    </div>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonFitnessAssessment _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFitnessAssessment)this.Model;
    }

</script>
