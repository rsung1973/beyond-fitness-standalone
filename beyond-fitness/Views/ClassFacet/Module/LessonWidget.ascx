<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>


<!-- widget content -->
<div class="widget-body txt-color-white no-padding">
    <div class="row no-padding">
        <!--profile-->
        <div class="col-xs-12 col-sm-12 col-md-4 col-lg-4">
            <%  ViewBag.LessonTime = _model;
                Html.RenderPartial("~/Views/ClassFacet/Module/LearnerLessonPlan.ascx", _lesson); %>
            <div class="row">
                <div class="col-sm-12">
                    <hr>
                    <div class="no-padding">
                        <ul class="nav nav-tabs">
                            <li class="active">
                                <a href="#exercisePurposeTab" data-toggle="tab"><i class="fa fa-flag"></i>近期目標 <span id="exercisePurpose" class="badge bg-color-teal txt-color-white"><%= _lesson.UserProfile.PersonalExercisePurpose!=null ? _lesson.UserProfile.PersonalExercisePurpose.Purpose : null %></span></a>
                            </li>
                            <li>
                                <a href="#completePurposeTab" data-toggle="tab"><i class="fa fa-flag-checkered"></i>已達成目標</a>
                            </li>
                            <li>
                                <a href="#calendarTab" data-toggle="tab" class="hidden-md hidden-lg"><i class="fa fa-calendar-alt"></i>行事曆</a>
                            </li>
                            <li>
                                <a id="smRow" href="#editLessonTab" data-toggle="tab" class="hidden-md hidden-lg"><i class="fa fa-heartbeat"></i><span>課表</span></a>
                            </li>
                            <li>
                                <a data-toggle="tab" href="#contentChartTab" class="hidden-md hidden-lg"><i class="fa fa-chart-pie"></i><span>分析</span></a>
                            </li>
                            <li>
                                <a data-toggle="tab" href="#exerciseGameTab" class="hidden-md hidden-lg"><i class="fa fa-trophy"></i><span>競賽</span>
                                    <%  var contestant = _lesson.UserProfile.ExerciseGameContestant;
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
                            <%--<li>
                                <a href="#pdq_tab" data-toggle="tab">PDQ</a>
                            </li>
                            <li>
                                <a href="#questionaire_tab" data-toggle="tab">階段性調整計劃</a>
                            </li>
                            <li>
                                <a href="#chatlist_tab" data-toggle="tab">運動留言板</a>
                            </li>--%>
                            <li class="pull-right hidden-md hidden-lg">
                                <span class="margin-top-10 display-inline">
                                    <i class="fa fa-rss text-success"></i><span id="classTime"><%= String.Format("{0:yyyy/MM/dd H:mm}",_model.ClassTime) %>-<%= String.Format("{0:H:mm}",_model.ClassTime.Value.AddMinutes(_model.DurationInMinutes.Value)) %></span> <%= _model.AsAttendingCoach.UserProfile.FullName() %>
                                </span>
                            </li>
                        </ul>
                        <div id="smTabContainer" class="tab-content padding-5">
                            <div class="tab-pane fade in active" id="exercisePurposeTab">
                                <%  Html.RenderPartial("~/Views/ClassFacet/Module/ExercisePurpose.ascx", _lesson.UserProfile); %>
                            </div>
                            <div class="tab-pane fade" id="completePurposeTab">
                                <table id="completePurposeList" class="table table-striped table-bordered table-hover" width="100%">
                                    <thead>
                                        <tr>
                                            <th>完成日</th>
                                            <th>目標</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%  Html.RenderPartial("~/Views/ClassFacet/Module/CompletePurposeItemList.ascx", _lesson.UserProfile.PersonalExercisePurpose); %>
                                    </tbody>
                                </table>                            
                            </div>
                            <%--                            <div class="tab-pane fade" id="pdq_tab">
                                <%  Html.RenderPartial("~/Views/ClassFacet/Module/ShowPAQPDQ.ascx", _lesson.UserProfile); %>
                            </div>
                            <div class="tab-pane fade" id="questionaire_tab">
                                <%  Html.RenderPartial("~/Views/ClassFacet/Module/RecentQuestionnaire.ascx", _lesson.UserProfile); %>
                            </div>
                            <div class="tab-pane fade" id="chatlist_tab">
                                <div class="col-md-12 block block-drop-shadow" id="chatboard">
                                    <%  Html.RenderPartial("~/Views/CoachFacet/Module/LessonCommentList.ascx",_lesson.UserProfile); %>
                                </div>
                            </div>--%>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!--end profile-->
        <!--content-->
        <div class="col-md-8 col-lg-8 hidden-xs hidden-sm">
            <div class="padding-5" id="currentContent">
                <%  ViewBag.LessonTime = _model; %>
                <%  Html.RenderPartial("~/Views/ClassFacet/Module/LessonContent.ascx", _lesson); %>
            </div>
        </div>
        <!--end content -->
    </div>
</div>
<!-- end widget content -->
<script>
    $(function () {
        $global.cloneLesson = function(sourceID) {
            showLoading();
            $.post('<%= Url.Action("CloneTrainingPlan","Lessons") %>',{'sourceID': sourceID,'lessonID':<%= _model.LessonID %>},function(data){
                hideLoading();
                if(data.result) {
                    alert("資料已複製!!");
                    loadTrainingStagePlan();

                    var $tab = $('#lgTabContainer .in.active');
                    if ($tab.length == 0) { //小版
                        $tab = $('#smTabContainer .in.active');
                        $('li.active').removeClass('active');
                        $('#smRow').closest('li').addClass('active');
                    } else {
                        $('#currentContent li.active').removeClass('active');
                        $('#lgRow').closest('li').addClass('active');
                    }
                    $tab.removeClass('in').removeClass('active');
                    $('#editLessonTab').addClass('in active');

<%--                    showLoading();
                    $('#currentContent').load('<%= Url.Action("LessonContent","ClassFacet",new { lessonID = _model.LessonID, registerID = _lesson.RegisterID }) %>',{},function(data){
                        hideLoading();

                    });--%>
                } else {
                    alert(data.message);
                }
            });
        };

        if ($('#smRow').css('display') == 'block') {
            <%--            $('ul.nav-tabs.tabs-pull-right li.active').removeClass('active');
            $('ul.nav-tabs.tabs-pull-right li:eq(4)').addClass('active');
            $('#smTabContainer div.active.in').removeClass('active in');
            $('#smTabContainer div:eq(4)').addClass('active in');--%>


            $('#exerciseGameTab').appendTo($('#smTabContainer'));
            $('#calendarTab').appendTo($('#smTabContainer'));
            $('#editLessonTab').appendTo($('#smTabContainer'));
            $('#contentChartTab').appendTo($('#smTabContainer'));
            console.log($('#currentContent').css('display'));

            drawLessonCalender();
            $('#calendarTab').removeClass('in').removeClass('active');

        } else if ($('#lgRow').css('display') == 'block') {

        }

        $(window).resize(function () {
            if ($('#smRow').css('display') == 'block') {

                $('#lgTabContainer .in.active').removeClass('in').removeClass('active');
                $('#currentContent li.active').removeClass('active');

                $('#exerciseGameTab').appendTo($('#smTabContainer'));
                $('#calendarTab').appendTo($('#smTabContainer'));
                $('#editLessonTab').appendTo($('#smTabContainer'));
                $('#contentChartTab').appendTo($('#smTabContainer'));

            } else if ($('#lgRow').css('display') == 'block') {

                $('#exerciseGameTab').appendTo($('#lgTabContainer'));
                $('#calendarTab').appendTo($('#lgTabContainer'));
                $('#editLessonTab').appendTo($('#lgTabContainer'));
                $('#contentChartTab').appendTo($('#lgTabContainer'));
                //if($('#lgRow').find('#currentContent').length==0) {
                //    $('#currentContent').appendTo($('#lgRow'));
                //    $('ul.nav-tabs.tabs-pull-right li.active').removeClass('active');
                //    $('ul.nav-tabs.tabs-pull-right li:eq(0)').addClass('active');
                //    $('#smTabContainer div.active.in').removeClass('active in');
                //    $('#smTabContainer div:eq(0)').addClass('active in');
                //}

                var $tabs = $('.in.active');
                if($tabs.length==1) {
                    var $lgTabs = $('#lgTabContainer .in.active');
                    if($lgTabs.length==1) {
                        $('a[href="#exercisePurposeTab"]').closest('li').addClass('active');
                        $('#exercisePurposeTab').addClass('in active');

                        $('#currentContent a[href="#' + $lgTabs.attr('id') + '"]').closest('li').addClass('active');
                    } else {
                        $('#calendarTab').addClass('in active');
                        $('#currentContent a[href="#calendarTab"]').closest('li').addClass('active');
                    }
                } 
            }
        });

    });

    function bookingByCoach(lessonDate) {
        showLoading();
        $.post('<%= Url.Action("BookingByCoach","ClassFacet",new { UID = _lesson.UID, CoachID= _profile.IsCoach() ? _profile.UID : _lesson.AdvisorID }) %>',{'lessonDate':lessonDate},function(data){
            hideLoading();
            if(data) {
                var $dialog = $(data);
                $dialog.dialog({
                    width: "80%",
                    height: "auto",
                    resizable : true,
                    modal : true,
                    closeText: "關閉",
                    title : "<div class='modal-title'><h4><i class='fa fa-warning'></i> 預約課程</h4></div>",
                    buttons : [{
                        html : "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                        "class" : "btn btn-primary",
                        click : function() {
                            var f = function() {  
                                $('#calendar').fullCalendar('refetchEvents');
                                $dialog.dialog("close");
                            };
                            $global.commitBooking(f);
                        }
                    }],
                    close: function (evt, ui) {
                        $dialog.remove();
                    }
                });
            }
        });
    }
</script>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;
    RegisterLesson _lesson;
    String _tabContent = "tabContent" + DateTime.Now.Ticks;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
        if (ViewBag.RegisterID != null)
        {
            _lesson = _model.GroupingLesson.RegisterLesson.Where(r => r.RegisterID == (int?)ViewBag.RegisterID).First();
        }
        else
        {
            _lesson = _model.GroupingLesson.RegisterLesson.First();
        }
        _profile = Context.GetUser();
    }

</script>
