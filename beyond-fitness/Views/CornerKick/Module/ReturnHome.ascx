<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<a href="#" class="button-collapse" onclick="gtag('event', '<%= _gaEvent %>', {'event_category': '連結點擊','event_label': '返回'});window.location.href = '<%= _model ?? Url.Action("LearnerIndex","CornerKick") %>';">
    <i class="livicon-evo" data-options="name: angle-wide-left.svg; size: 40px; style: original; strokeWidth:2px; autoPlay:true"></i>
</a>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _model;
    String _gaEvent = "卡片總覽";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = this.Model as String;
        if(_model!=null)
        {
            if(_model.Contains("Settings"))
            {
                _gaEvent = "我的設定";
            }
            else if(_model.Contains("LearnerCalendar"))
            {
                _gaEvent = "我的行事曆";
            }
        }
    }

</script>
