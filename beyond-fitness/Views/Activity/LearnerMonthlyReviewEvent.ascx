<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>

<li>
    <div class="smart-timeline-icon bg-color-magenta">
        <i class="fa fa-bar-chart-o"></i>
    </div>
    <div class="smart-timeline-time">
        <small><%= String.Format("{0:yyyy/MM/dd}",_model.EventTime) %></small>
    </div>
    <div class="smart-timeline-content">
        <p>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Account/Vip") %>"><strong>快點來確認你的階段性調整計劃喔！</strong></a>
        </p>
        <div class="sparkline" data-sparkline-type="compositeline" data-sparkline-spotradius-top="5" data-sparkline-color-top="#3a6965" data-sparkline-line-width-top="3" data-sparkline-color-bottom="#2b5c59" data-sparkline-spot-color="#2b5c59" data-sparkline-minspot-color-top="#97bfbf"
            data-sparkline-maxspot-color-top="#c2cccc" data-sparkline-highlightline-color-top="#cce8e4" data-sparkline-highlightspot-color-top="#9dbdb9" data-sparkline-width="170px" data-sparkline-height="40px" data-sparkline-line-val="[6,4,7,8,4,3,2,2,5,6,7,4,1,5,7,9,9,8,7,6]"
            data-sparkline-bar-val="[4,1,5,7,9,9,8,7,6,6,4,7,8,4,3,2,2,5,6,7]">
        </div>
        <br>
    </div>
</li>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LearnerMonthlyReviewEvent _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LearnerMonthlyReviewEvent)this.Model;
    }

</script>
