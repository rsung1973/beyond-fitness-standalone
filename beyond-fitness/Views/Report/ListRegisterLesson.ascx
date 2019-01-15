<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%--<article class="col-xs-12 col-sm-12 col-md-6 col-lg-6">

    <!-- Widget ID (each widget will need unique ID)-->
    <div class="jarviswidget jarviswidget-color-darken" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
        <!-- widget options:
                                usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">

                                data-widget-colorbutton="false"
                                data-widget-editbutton="false"
                                data-widget-togglebutton="false"
                                data-widget-deletebutton="false"
                                data-widget-fullscreenbutton="false"
                                data-widget-custombutton="false"
                                data-widget-collapsed="true"
                                data-widget-sortable="false"

                                -->
        <header>
            <span class="widget-icon"><i class="fa fa-table"></i></span>
            <h2>業績統計表 - 課程類別 (<%= String.Format("{0:yyyy/MM/dd}",(DateTime?)ViewBag.DateFrom) %>~<%= String.Format("{0:yyyy/MM/dd}",(DateTime?)ViewBag.DateTo) %>)</h2>
        </header>

        <!-- widget div-->
        <div>

            <!-- widget edit box -->
            <div class="jarviswidget-editbox">
                <!-- This area used as dropdown edit box -->
            </div>
            <!-- end widget edit box -->

            <!-- widget content -->
            <div class="widget-body no-padding">

                <%  Html.RenderPartial("~/Views/Report/RegisterLessonTypeGroup.ascx", _model); %>
            </div>
            <!-- end widget content -->

        </div>
        <!-- end widget div -->

    </div>
    <!-- end widget -->
</article>--%>

<article class="col-xs-12 col-sm-6 col-md-5 col-lg-5">

    <!-- Widget ID (each widget will need unique ID)-->
    <div class="jarviswidget jarviswidget-color-darken" id="wid-id-1" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
        <!-- widget options:
                                usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">

                                data-widget-colorbutton="false"
                                data-widget-editbutton="false"
                                data-widget-togglebutton="false"
                                data-widget-deletebutton="false"
                                data-widget-fullscreenbutton="false"
                                data-widget-custombutton="false"
                                data-widget-collapsed="true"
                                data-widget-sortable="false"

                                -->
        <header>
            <span class="widget-icon"><i class="fa fa-table"></i></span>
            <h2>業績統計表 - 人員 (<%= String.Format("{0:yyyy/MM/dd}",(DateTime?)ViewBag.DateFrom) %>~<%= String.Format("{0:yyyy/MM/dd}",(DateTime?)ViewBag.DateTo) %>)</h2>
        </header>

        <!-- widget div-->
        <div>

            <!-- widget edit box -->
            <div class="jarviswidget-editbox">
                <!-- This area used as dropdown edit box -->
            </div>
            <!-- end widget edit box -->

            <!-- widget content -->
            <div class="widget-body no-padding">

                <%  Html.RenderPartial("~/Views/Report/RegisterLessonAchievement.ascx", _model); %>
            </div>
            <!-- end widget content -->

        </div>
        <!-- end widget div -->

    </div>
    <!-- end widget -->
</article>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<TuitionAchievement> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<TuitionAchievement>)this.Model;
    }

</script>
