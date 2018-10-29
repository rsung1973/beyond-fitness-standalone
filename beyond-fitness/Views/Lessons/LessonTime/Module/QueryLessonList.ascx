<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

    <!-- widget edit box -->
    <div class="jarviswidget-editbox">
    </div>
    <!-- end widget edit box -->

    <div class="widget-body">
        <!-- content -->
        <div id="myTabContent" class="tab-content">
            <div class="tab-pane fade active widget-body in no-padding-bottom" id="s1">
                <% Html.RenderAction("QueryBookingList", "Lessons", new { lessonDate = _lessonDate, category = (String)ViewBag.Category });%>
            </div>
            <!-- end s1 tab pane -->
            <div class="tab-pane fade" id="s2">
                <% Html.RenderPartial("~/Views/Lessons/DailyBarGraph.ascx", _lessonDate); %>
            </div>
            <!-- end s3 tab pane -->
        </div>
        <script>
                $('a[data-toggle="tab"]').on('shown.bs.tab', function (evt) {
                    if ($('#s2').css('display') == 'block') {
                        <%  if(_lessonDate.HasValue)
                            {             %>
                        plotData('<%= _lessonDate.Value.ToString("yyyy-MM-dd") %>');
                        <%  }
                            else
                            {   %>
                        plotQueryData();
                        <%  }   %>
                    }
                });
        </script>

        <!-- end content -->
    </div>


<script runat="server">

    ModelSource<UserProfile> models;
    DailyBookingQueryViewModel _viewModel;
    DateTime? _lessonDate;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (DailyBookingQueryViewModel)ViewBag.ViewModel;
        _lessonDate = (DateTime?)ViewBag.LessonDate;
    }

</script>
