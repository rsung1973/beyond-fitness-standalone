<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%  var prefix = "content" + _model.RegisterID + "_"; %>
<ul class="nav nav-tabs">
    <li class="active">
        <a href="#calendarTab" data-toggle="tab"><i class="fa fa-calendar-alt"></i> 行事曆</a>
    </li>
    <li>
        <a id="lgRow" data-toggle="tab" class="editLessonTab" href="#editLessonTab"><i class="fa fa-heartbeat"></i> <span>課表</span></a>
    </li>
    <li>
        <a data-toggle="tab" href="#contentChartTab"><i class="fa fa-chart-pie"></i><span>分析</span></a>
    </li>
    <li>
        <a data-toggle="tab" href="#exerciseGameTab"><i class="fa fa-trophy"></i><span>競賽</span>
            <%  var contestant = _model.UserProfile.ExerciseGameContestant;
                if (contestant != null && contestant.ExerciseGamePersonalRank != null)
                { %>
            <span class="badge bg-color-red txt-color-white">No. <%= contestant.ExerciseGamePersonalRank.Rank %></span>
            <%  }
                else
                { %>
            <span class="badge bg-color-red txt-color-white">Join</span>
            <%  } %>
        </a>
    </li>
    <li class="pull-right">
        <span class="margin-top-10 display-inline">
            <i class="fa fa-rss text-success"></i><span id="classTime"><%= String.Format("{0:yyyy/MM/dd H:mm}",_item.ClassTime) %>-<%= String.Format("{0:H:mm}",_item.ClassTime.Value.AddMinutes(_item.DurationInMinutes.Value)) %></span> <%= _item.AsAttendingCoach.UserProfile.FullName() %>
        </span>
    </li>
</ul>
<div class="tab-content padding-5" id="lgTabContainer">
    <!-- end s1 tab pane -->
    <div class="tab-pane fade in active" id="calendarTab">
        <!-- new widget -->
        <div class="jarviswidget" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
            <header>
                <span class="widget-icon"><i class="fa fa-calendar-alt"></i></span>
                <h2><%= _model.UserProfile.FullName() %>行事曆</h2>
                <div class="widget-toolbar">
                    <a href="#" class="btn  btn-primary" onclick="bookingByCoach('<%= DateTime.Today.ToString("yyyy-MM-dd") %>');">預約上課</a>
                </div>
            </header>
            <!-- widget div-->
            <div>
                <div class="widget-body bg-color-darken txt-color-white no-padding">
                    <!-- content goes here -->
                    <div class="widget-body-toolbar">

                        <div id="calendar-buttons">

                            <div class="btn-group">
                                <a href="javascript:void(0)" class="btn btn-default btn-xs" id="btn-prev"><i class="fa fa-chevron-left"></i></a>
                                <a href="javascript:void(0)" class="btn btn-default btn-xs" id="btn-next"><i class="fa fa-chevron-right"></i></a>
                            </div>
                        </div>
                    </div>
                    <% 
                        Html.RenderPartial("~/Views/ClassFacet/Module/VipCalendar.ascx", _model); %>
                    <!-- end content -->
                </div>
            </div>
            <!-- end widget div -->
        </div>
        <!-- end widget -->
    </div>
    <div class="tab-pane fade" id="editLessonTab">
        <%  if (ViewBag.HasContent != true)
            { %>
        <div id="editLesson">
            <%--<%  Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _item); %>--%>
<%--            <form action="<%= VirtualPathUtility.ToAbsolute("~/Lessons/UpdateTrainingItemSequence/") + _item.LessonID %>" method="post" id="updateSeq">
                <% Html.RenderAction("SingleTrainingExecutionPlan", "Lessons", new { LessonID = _item.LessonID }); %>
            </form>--%>
            <% Html.RenderAction("TrainingStagePlan", "Lessons", new { LessonID = _item.LessonID }); %>
        </div>
        <script>

            function loadTrainingStagePlan() {
                showLoading();
                $('#editLesson').load('<%= Url.Action("TrainingStagePlan", "Lessons", new { LessonID = _item.LessonID }) %>', {}, function (data) {
                    hideLoading();
                });

                if ($global.drawCurrentLessonPie) {
                    $global.drawCurrentLessonPie();
                }

                if ($global.drawLessonReviewPie) {
                    $global.drawLessonReviewPie();
                }

                if ($global.drawLessonReviewGraph) {
                    $global.drawLessonReviewGraph();
                }

                if ($global.drawTrainingAidsPie) {
                    $global.drawTrainingAidsPie();
                }
                
            }
        </script>
        <%  } %>
    </div>
    <div class="tab-pane fade" id="contentChartTab">
        <%--<%  var assessment = _item.LessonFitnessAssessment.Where(f => f.UID == _model.UID).FirstOrDefault();
            Html.RenderPartial("~/Views/Lessons/LessonLearnerAssessment.ascx", assessment); %>--%>
        <%  Html.RenderPartial("~/Views/Training/Module/LessonContentReview.ascx", _model); %>
    </div>
    <div class="tab-pane fade" id="exerciseGameTab">
        <%  Html.RenderPartial("~/Views/ExerciseGame/Module/GameWidgetGrid.ascx", _model.UserProfile); %>
    </div>
</div>

<%  Html.RenderPartial("~/Views/Shared/MorrisGraphView.ascx"); %>
<% Html.RenderPartial("~/Views/Shared/EasyPieView.ascx"); %>
<%  Html.RenderPartial("~/Views/Lessons/Module/TrainingItemScript.ascx"); %>

<script>
    function commitGameStatus(status) {
        var event = event || window.event;
        var $container = $('#exerciseGameTab');
        showLoading();
        $.post('<%= Url.Action("CommitGameStatus","ExerciseGame",new { _model.UID }) %>', { 'status': status }, function (data) {
            hideLoading();
            $container.html(data);
        });
    }

    function loadExerciseResult() {
        var $container = $('#exerciseGameTab');
        showLoading();
        $.post('<%= Url.Action("GameIndex", "ExerciseGame", new { _model.UID }) %>', {}, function (data) {
            hideLoading();
            $container.html(data);
        });
    }

    function deleteExerciseResult(testID) {
        var event = event || window.event;
        var $tr = $(event.target).closest('tr');
        if (confirm('確定刪除?')) {
            var event = event || window.event;
            showLoading();
            $.post('<%= Url.Action("DeleteExerciseResult","ExerciseGame") %>', { 'testID': testID }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        $(event.target).closest('tr').remove();
                    } else {
                        alert(data.message);
                    }
                } else {
                    $(data).appendTo($('body')).remove();
                }
            });
        }
    }
</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    RegisterLesson _model;
    LessonTime _item;
    LessonPlan _plan;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (RegisterLesson)this.Model;
        _item = (LessonTime)ViewBag.LessonTime;
        _plan = _item.LessonPlan ?? new LessonPlan { };
        ViewBag.CloneLesson = true;
    }

</script>
