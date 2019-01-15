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

<div class="panel-group smart-accordion-default padding-10" id="accordion2">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h6 class="panel-title"><a data-toggle="collapse" data-parent="#accordion2" href="#collapseAbout"><i class="fa fa-lg fa-angle-down pull-right"></i><i class="fa fa-lg fa-angle-up pull-right"></i>About </a></h6>
        </div>
        <div id="collapseAbout" class="panel-collapse collapse in">
            <div class="panel-body padding-5">
                <span class="text-warning" onclick="editRecentStatus(<%= _model.UID %>,$(this));"><%= !String.IsNullOrEmpty(_model.RecentStatus) ? _model.RecentStatus.HtmlBreakLine() : "點此新增個人近況" %></span>
            </div>
        </div>
    </div>
    <div class="panel panel-default">
        <div class="panel-heading">
            <h6 class="panel-title"><a data-toggle="collapse" data-parent="#accordion2" href="#collapsePDQ" class="collapsed"><i class="fa fa-lg fa-angle-down pull-right"></i><i class="fa fa-lg fa-angle-up pull-right"></i>PDQ </a></h6>
        </div>
        <div id="collapsePDQ" class="panel-collapse collapse">
            <div class="panel-body padding-5">
                <%  Html.RenderPartial("~/Views/ClassFacet/Module/ShowPAQPDQ.ascx", _model); %>
            </div>
        </div>
    </div>
</div>


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
