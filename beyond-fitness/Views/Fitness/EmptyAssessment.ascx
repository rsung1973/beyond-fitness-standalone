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


<%  if (ViewBag.Header != null)
    { %>
<header>
    <span class="widget-icon"><i class="fa fa-line-chart text-success"></i></span>
    <h2><%= ViewBag.Header %></h2>
</header>
<%  } %>
<!-- widget div-->
<div class="no-padding">
    <!-- widget edit box -->
    <div class="jarviswidget-editbox">
    </div>
    <!-- end widget edit box -->

    <div class="widget-body">
        <!-- content -->
        <div class="row">
            <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
                <div class="caption text-center"><%= ViewBag.Subject ?? "資料未建立" %></div>
                <div class="chart no-padding"></div>
            </div>
        </div>
        <!-- end content -->
    </div>

</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;

    }

</script>
