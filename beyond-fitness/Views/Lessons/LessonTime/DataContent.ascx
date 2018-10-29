<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<header>
    <span class="widget-icon"><i class="fa fa-rss text-success"></i></span>
    <h2><%= String.Format("{0:yyyy/MM/dd HH:mm}",_item.ClassTime) %>-<%= String.Format("{0:HH:mm}",_item.ClassTime.Value.AddMinutes(_item.DurationInMinutes.Value)) %> 課程表 </h2>
    <div class="widget-toolbar">
    <%  if (ViewBag.Edit == true)
        { %>
        <a onclick="makeTrainingPlan(<%= _item.LessonID %>);" class="btn btn-primary"><i class="fa fa-fw fa-files-o"></i>編輯課表</a>
    <%  }
        if (ViewBag.LearnerAttendance == true && !_item.LessonPlan.CommitAttendance.HasValue && _item.ClassTime<DateTime.Today.AddDays(1))
        { %>
        <button class="btn btn-xs btn-success" onclick="learnerAttendLesson(<%= _item.LessonID %>);"><i class="fa fa-check"></i>上課打卡</button>
    <%  } %>
    </div>
    <ul id="introduction_<%= _ticks %>" class="nav nav-tabs pull-right">
        <%  if (_model.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI)
            { %>
        <%--<li class="active">
            <a data-toggle="tab" href="#os1_<%= _ticks %>"><i class="fa fa-commenting-o"></i><span>教練悄悄話</span></a>
        </li>--%>
        <%  } %>
        <%  if (_item.TrainingBySelf != 1 && ViewBag.LearnerAttendance != true)
            { %>
        <li>
            <a data-toggle="tab" href="#os7_<%= _ticks %>"><i class="fa fa-chart-pie"></i><span>身體健康指數</span></a>
        </li>
        <%  } %>
        <%--<li>
            <a data-toggle="tab" href="#os2_<%= _ticks %>"><i class="fa fa-child"></i><span>暖身</span></a>
        </li>--%>
        <li class="active">
            <a data-toggle="tab" href="#os3_<%= _ticks %>"><i class="fa fa-heartbeat"></i><span>訓練內容</span></a>
        </li>
        <%  if (_model.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI)
            { %>
        <%--<li>
            <a data-toggle="tab" href="#os4_<%= _ticks %>"><i class="fa fa-comments-o"></i><span>課後提醒</span></a>
        </li>--%>
        <%  } %>
        <%  if (_item.TrainingBySelf != 1)
            { %>
        <li>
            <a data-toggle="tab" href="#os5_<%= _ticks %>"><i class="fa fa-chart-pie"></i><span>評量指數</span></a>
        </li>
        <%      if (ViewBag.ByCalendar != true && ViewBag.LearnerAttendance != true)
                {%>
                    <li>
                        <a data-toggle="tab" href="#os6_<%= _ticks %>"><i class="fa fa-line-chart"></i><span>體能分析表</span></a>
                    </li>
            <%  }
            } %>
    </ul>

</header>
<!-- widget div-->
<div class="no-padding">
    <div class="widget-body no-padding">
        <!-- content -->
        <div id="tabContent_<%= _ticks %>" class="tab-content padding-10">
            <%  if (_model.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI)
                { %>
            <%--<div class="tab-pane fade widget-body no-padding-bottom active in" id="os1_<%= _ticks %>">
                <div class="chat-body no-padding profile-message">
                    <%  if (ViewBag.Edit == true)
    {
        Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _item);
    }%>
                </div>
                <div class="panel-body status">
                    <div class="chat-body custom-scroll" style="height: 150px">
                        <ul>
                            <li class="message">
                                <% _item.AsAttendingCoach.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online", @style = "width:95px" }); %>
                                <span class="message-text">
                                    <a class="username" href="<%= VirtualPathUtility.ToAbsolute("~/Account/ViewProfile/") + _item.AttendingCoach %>"><%= _item.AsAttendingCoach.UserProfile.FullName() %></a>
                                    <%= _item.LessonPlan != null ? _item.LessonPlan.Remark : null %>
                                </span>
                            </li>
                        </ul>
                    </div>

                    <%  if (ViewBag.Learner == true)
    { %>
                            <span class="msg-remark"></span>
                            <%  Html.RenderPartial("~/Views/Lessons/Feedback/LearnerLessonRemarkItem.ascx", _item); %>
                            <div class="chat-footer">
                                <!-- CHAT TEXTAREA -->
                                <div class="textarea-div">
                                    <div class="typearea">
                                        <textarea id="feedBack" name="feedBack" placeholder="請輸入100個中英文字" class="custom-scroll" maxlength="100" rows="20"></textarea>
                                    </div>
                                </div>

                                <!-- CHAT REPLY/SEND -->
                                <span class="textarea-controls">
                                    <button onclick="feedback();" class="btn btn-sm btn-primary pull-right">
                                        更新
                                    </button>
                                </span>
                            </div>
                    <%  } %>
                </div>

            </div>--%>
            <%  } %>
            <!-- end s1 tab pane -->
            <%--<div class="tab-pane fade widget-body no-padding-bottom" id="os2_<%= _ticks %>">
                <div class="panel-body status">
                    <%  if (ViewBag.Edit == true)
                        {
                            Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _item);
                        }%>

                    <div class="chat-body custom-scroll">
                        <ul>
                            <li class="message">
                                <% _item.AsAttendingCoach.UserProfile.RenderUserPicture(Writer,new { @class = "profileImg online" ,@style = "width:95px" }); %>
                                <div class="message-text">
                                    <time></time>
                                    <a class="username"><%= _item.AsAttendingCoach.UserProfile.FullName() %></a> <%= _item.LessonPlan!=null ? _item.LessonPlan.Warming : null %>
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>--%>
            <!-- end s2 tab pane -->
            <div class="tab-pane fade in active widget-body no-padding-bottom" id="os3_<%= _ticks %>">
                <%  
//if (ViewBag.Edit == true)
//{
//    Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _item);
//}
            %>
                <%  if (_item.TrainingPlan.Count > 0)
                    {
                        ViewBag.ShowOnly = true;
                        ViewBag.DataTableId = "itemList" + _ticks;
                        Html.RenderPartial("~/Views/Lessons/Module/TrainingStagePlanView.ascx", _item.TrainingPlan.First().TrainingExecution);
                    }
                    //if (ViewBag.Learner == true)
                    //    Html.RenderPartial("~/Views/Activity/LessonFeedBack.ascx", _item);
                    //else 
                    //    Html.RenderPartial("~/Views/Activity/ShowLessonFeedBack.ascx", _item); %>
            </div>
            <!-- end s3 tab pane -->
            <%  if (_model.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI)
                { %>
<%--            <div class="tab-pane fade widget-body no-padding-bottom" id="os4_<%= _ticks %>">
                <div class="panel-body status">
                    <%  if (ViewBag.Edit == true)
    {
        Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _item);
    }%>

                    <div class="chat-body custom-scroll">
                        <ul>
                            <li class="message">
                                <% _item.AsAttendingCoach.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online", @style = "width:95px" }); %>
                                <div class="message-text">
                                    <time></time>
                                    <a class="username"><%= _item.AsAttendingCoach.UserProfile.FullName() %></a> <%= _item.LessonPlan != null ? _item.LessonPlan.EndingOperation : null %>
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>--%>
            <%  } %>
            <!-- end s4 tab pane -->
            <%  var assessment = _item.LessonFitnessAssessment.Where(f => f.UID == _model.UID).FirstOrDefault();
                if (_item.TrainingBySelf != 1)
                { %>
                    <div class="tab-pane fade widget-body no-padding-bottom" id="os5_<%= _ticks %>">
                        <%--<div class="row">
                            <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
                                <%  Html.RenderPartial("~/Views/Lessons/DailyTrendPieView.ascx", _model); %>
                            </div>
                            <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
                                <%  Html.RenderPartial("~/Views/Lessons/DailyFitnessPieView.ascx", _model); %>
                            </div>
                        </div>--%>
                        <%--<%  ViewBag.ShowOnly = true;
                            ViewBag.Index = DateTime.Now.Ticks;
                            Html.RenderPartial("~/Views/Lessons/LessonLearnerAssessment.ascx", assessment); %>--%>
                        <%  Html.RenderPartial("~/Views/Training/Module/LessonContentReview.ascx", _model); %>
                    </div>
                <%  if (ViewBag.LearnerAttendance != true)
                    { %>
                    <div class="tab-pane fade widget-body no-padding-bottom" id="os7_<%= _ticks %>">
                        <%  Html.RenderPartial("~/Views/Lessons/LearnerHealthAssessment.ascx", assessment); %>
                    </div>
                <%  }
                    if (ViewBag.ByCalendar != true)
                    { %>
                        <div class="tab-pane fade widget-body no-padding-bottom" id="os6_<%= _ticks %>">
                            <% Html.RenderPartial("~/Views/Lessons/LessonLearnerAssessmentReport.ascx", assessment); %>
                        </div>
                <%  }
                } %>
        </div>
        <!-- end s5 tab pane -->
    </div>

    <!-- end content -->
</div>

<%  Html.RenderPartial("~/Views/Shared/EasyPieView.ascx"); %>
<%  Html.RenderPartial("~/Views/Shared/MorrisGraphView.ascx"); %>

<%  if (ViewBag.Learner == true)
    { %>
    <script>
        function feedback() {
            showLoading(true);
            $.post('<%= Url.Action("LearnerLessonRemark","Lessons",new { id = _item.LessonID }) %>',
                {
                    'feedBack': $('#feedBack').val()
                }, function (data) {
                    hideLoading();
                    smartAlert('資料已更新!!');
                    $('#os1_<%= _ticks %> .remark-item').remove();
                    if (data) {
                        $('#os1_<%= _ticks %> .msg-remark').after($(data));
                    }
                });
        }
    </script>
<%  } %>

<%  if (ViewBag.TabIndex != null)
    { %>
    <script>
        $(function () {
            $('#introduction_<%= _ticks %> li.active').removeClass('active');
            $('#introduction_<%= _ticks %> li:eq(<%= (int?)ViewBag.TabIndex %>)').addClass('active');
            $('#tabContent_<%= _ticks %> div.active.in').removeClass('active in');
            $('#tabContent_<%= _ticks %> div:eq(<%= (int?)ViewBag.TabIndex %>)').addClass('active in');
        });
    </script>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    RegisterLesson _model;
    LessonTime _item;
    long _ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (RegisterLesson)this.Model;
        _item = (LessonTime)ViewBag.LessonTime;
        _ticks = DateTime.Now.Ticks;
    }

</script>
