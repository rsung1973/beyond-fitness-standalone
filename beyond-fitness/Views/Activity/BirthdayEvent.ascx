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
    <div class="smart-timeline-icon bg-color-red">
        <i class="fa fa-birthday-cake"></i>
    </div>
    <div class="smart-timeline-time">
        <small><%= String.Format("{0:yyyy/MM/dd}",_model.EventTime) %></small>
    </div>
    <div class="smart-timeline-content">
        <p>
            在這美好的一天 - 很開心的祝您生日快樂！
        </p>
    </div>
</li>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    BirthdayEvent _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (BirthdayEvent)this.Model;
    }

</script>
