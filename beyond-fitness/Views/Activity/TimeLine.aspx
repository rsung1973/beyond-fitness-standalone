<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>
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

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-paw"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>我的足印</li>
        </ol>
        <!-- end breadcrumb -->

        <!-- You can also add more buttons to the
                ribbon for further usability

                Example below:

                <span class="ribbon-button-alignment pull-right">
                <span id="search" class="btn btn-ribbon hidden-xs" data-title="search"><i class="fa-grid"></i> Change Grid</span>
                <span id="add" class="btn btn-ribbon hidden-xs" data-title="add"><i class="fa-plus"></i> Add</span>
                <span id="search" class="btn btn-ribbon" data-title="search"><i class="fa-search"></i> <span class="hidden-mobile">Search</span></span>
                </span> -->

    </div>
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <h1 class="txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-paw"></i>我的足印
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">
        <article class="col-xs-12 col-sm-12 col-md-9 col-lg-9">

            <div class="well well-sm bg-color-darken txt-color-white">
                <!-- Timeline Content -->
                <div class="smart-timeline">
                    <ul class="smart-timeline-list">
                        <li class="text-center">
                            <a href="<%= VirtualPathUtility.ToAbsolute("~/Account/Vip") %>" class="btn btn-sm btn-default"><i class="fa fa-dashboard text-muted"></i> 更多資料</a>
                        </li>
                        <%  var items = _model.OrderByDescending(t => t.EventTime).ToArray();
                            var questEvt = items.Where(t => t is QuestionnaireRequestEvent).FirstOrDefault();
                            if(questEvt!=null)
                            {
                                Html.RenderPartial("~/Views/Activity/QuestionnaireRequestEvent.ascx", questEvt);
                            }
                            for (int idx = 0; idx < items.Length; idx++)
                            {
                                var item = items[idx];
                                if (item is LessonEvent)
                                {
                                    if (((LessonEvent)item).Lesson.LessonAttendance == null)
                                    {
                                        if (((LessonEvent)item).Lesson.ClassTime < DateTime.Today)
                                        {
                                            Html.RenderPartial("~/Views/Activity/PastReservedLessonEvent.ascx", item);
                                        }
                                        else
                                        {
                                            Html.RenderPartial("~/Views/Activity/ReservedLessonEvent.ascx", item);
                                        }
                                    }
                                    else
                                    {
                                        Html.RenderPartial("~/Views/Activity/AttendedLessonEvent.ascx", item);
                                    }
                                }
                                else if (item is LearnerMonthlyReviewEvent)
                                {
                                    Html.RenderPartial("~/Views/Activity/LearnerMonthlyReviewEvent.ascx", item);
                                }
                                else if(item is BirthdayEvent)
                                {
                                    Html.RenderPartial("~/Views/Activity/BirthdayEvent.ascx", item);
                                }
                            } %>
                    </ul>
                </div>
                <!-- END Timeline Content -->

            </div>

        </article>

        <article class="col-xs-12 col-sm-12 col-md-3 col-lg-3">
            <!-- /well -->
            <div class="well bg-color-darken txt-color-white padding-10 ">
                <h5 class="margin-top-0 "><i class="fa fa-external-link "></i> 快速功能</h5>
                <ul class="no-padding no-margin ">
                    <p class="no-margin ">
                        <ul class="icons-list ">
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/VipOverview.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ViewProfile.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/Logout.ascx"); %>
                        </ul>
                    </p>
                </ul>
            </div>
            <%  Html.RenderPartial("~/Views/Layout/SNS.ascx"); %>
            <!-- /well -->
        </article>
        <!-- end row -->
        <!-- Modal -->
        <!-- END MAIN CONTENT -->
    </div>
    <script>
        $.post('<%= Url.Action("LearnerPrompt","Interactivity") %>', {}, function (data) {
            if (data) {
                $(data).appendTo($('#content'));
            }
        });
    </script>
    <%  Html.RenderPartial("~/Views/Shared/MorrisGraphView.ascx"); %>
</asp:Content>
<script runat="server">

    ModelStateDictionary _modelState;
    List<TimelineEvent> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (List<TimelineEvent>)this.Model;
    }

</script>
