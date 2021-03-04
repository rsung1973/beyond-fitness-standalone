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

<div class="row">
    <div class="col-12 col-md-12">
        <div class="jarviswidget" id="wid-id-0" data-widget-togglebutton="false" data-widget-editbutton="false" data-widget-fullscreenbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false">

            <header>
                <span class="widget-icon"><i class="fa fa-rss text-success"></i></span>
                <h2><%= String.Format("{0:yyyy/MM/dd H:mm}",_item.ClassTime) %>-<%= String.Format("{0:H:mm}",_item.ClassTime.Value.AddMinutes(_item.DurationInMinutes.Value)) %> 課表</h2>
                <div class="widget-toolbar">
                    <%  if ((_item.TrainingBySelf==1 || models.CouldMarkToAttendLesson(_item)) && _item.LessonAttendance == null)
                            { %>
                    <%--<a onclick="attendLesson(<%= _item.LessonID %>);" class="btn btn-success"><i class="far fa-fw fa-check-square"></i>完成上課</a>--%>
                    <%  } %>
                    <a onclick="cloneLesson(<%= _item.LessonID %>);" class="btn bg-color-orange"><i class="fa fa-fw fa-files-o"></i>複製課表</a>
                    <a onclick='previewLesson(<%= JsonConvert.SerializeObject(new
                            {
                                classDate = _item.ClassTime.Value.ToString("yyyy-MM-dd"),
                                hour = _item.LessonTimeExpansion.First().Hour,
                                registerID = _model.RegisterID,
                                lessonID = _item.LessonID
                            }) %>);'
                        class="btn bg-color-orange"><i class="fa fa-fw fa-eye"></i>檢視課表</a>
                </div>
                <%  var prefix = "content" + _model.RegisterID + "_"; %>
                <ul id="widget-tab-1" class="nav nav-tabs pull-right">
                    <%  if (_item.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI)
                        { %>
                    <%--<li class="active contentTab">
                        <a data-toggle="tab" href="#<%= prefix %>5"><i class="fa fa-commenting-o"></i><span>教練悄悄話</span></a>
                    </li>--%>
                    <%  } %>
                    <%  if (_item.TrainingBySelf != 1)
                            { %>
                    <li class="contentTab">
                        <a data-toggle="tab" href="#<%= prefix %>7"><i class="fa fa-history"></i><span>身體健康指數</span></a>
                    </li>
                    <%  } %>
                    <%--<li class="contentTab">
                        <a data-toggle="tab" href="#<%= prefix %>1"><i class="fa fa-child"></i><span>暖身</span></a>
                    </li>--%>
                    <li class="active contentTab">
                        <a data-toggle="tab" class="editLessonTab" href="#<%= prefix %>2"><i class="fa fa-heartbeat"></i><span>訓練內容</span></a>
                    </li>
                    <%  if (_item.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI)
                        { %>
                    <%--<li class="contentTab">
                        <a data-toggle="tab" href="#<%= prefix %>3"><i class="fa fa-comments-o"></i><span>課後提醒</span></a>
                    </li>--%>
                    <%  } %>
                    <%  if (_item.TrainingBySelf != 1)
                        { %>
                    <li class="contentTab">
                        <a data-toggle="tab" href="#<%= prefix %>4"><i class="fa fa-chart-pie"></i><span>評量指數</span></a>
                    </li>
                    <li class="contentTab">
                        <a data-toggle="tab" href="#<%= prefix %>6"><i class="fa fa-line-chart"></i><span>體能分析表</span></a>
                    </li>
                    <%  } %>
                </ul>

            </header>
            <!-- widget div-->
            <div class="no-padding">
                <div class="widget-body no-padding">
                    <!-- content -->
                    <div id="myTabContent" class="tab-content padding-10">
                        <%--<div class="tab-pane fade" id="<%= prefix %>1">
                            <div class="panel-body status">
                                <div class="chat-body custom-scroll">
                                    <%  Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _item); %>
                                    <ul>
                                        <li class="message">
                                            <% _item.AsAttendingCoach.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online", @style = "width:95px" }); %>
                                            <div class="message-text">
                                                <time><%= String.Format("{0:yyyy-MM-dd HH:mm}",_item.ClassTime) %></time>
                                                <a class="username"><%= _item.AsAttendingCoach.UserProfile.FullName() %></a>
                                                <div id="msgWarming"><%= _plan.Warming %></div>
                                            </div>
                                        </li>
                                    </ul>
                                </div>
                                <div class="chat-footer">
                                    <!-- CHAT TEXTAREA -->
                                    <div class="textarea-div">
                                        <div class="typearea">
                                            <textarea id="warming" name="warming" placeholder="請輸入100個中英文字" class="custom-scroll" maxlength="100" rows="20"><%= _plan.Warming %></textarea>
                                        </div>
                                    </div>

                                    <!-- CHAT REPLY/SEND -->
                                    <span class="textarea-controls">
                                        <button id="btnUpdateWarming" onclick="commitPlan();" class="btn btn-sm btn-primary pull-right">
                                            更新
                                        </button>
                                    </span>
                                </div>
                            </div>
                        </div>--%>
                        <!-- end s1 tab pane -->
                        <div class="tab-pane fade in active widget-body no-padding-bottom" id="<%= prefix %>2">
                        <%  if (ViewBag.HasContent != true)
                            { %>
                            <div id="editLesson">
                                <%--<%  Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _item); %>--%>
                                <form action="<%= VirtualPathUtility.ToAbsolute("~/Lessons/UpdateTrainingItemSequence/") + _item.LessonID %>" method="post" id="updateSeq">
                                    <% Html.RenderAction("SingleTrainingExecutionPlan", "Lessons", new { LessonID = _item.LessonID }); %>
                                </form>
                            </div>
                        <%  } %>
                        </div>
                        <!-- end s2 tab pane -->
                        <%  if (_item.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI)
                            { %>
                        <%--<div class="tab-pane fade widget-body no-padding-bottom" id="<%= prefix %>3">
                            <div class="panel-body status">
                                <div class="chat-body custom-scroll">
                                    <%  Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _item); %>
                                    <ul>
                                        <li class="message">
                                            <% _item.AsAttendingCoach.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online", @style = "width:95px" }); %>
                                            <div class="message-text">
                                                <time><%= String.Format("{0:yyyy-MM-dd HH:mm}", _item.ClassTime) %></time>
                                                <a class="username"><%= _item.AsAttendingCoach.UserProfile.FullName() %></a>
                                                <div id="msgEndingOperation">
                                                    <%= _plan.EndingOperation %>
                                                </div>
                                            </div>
                                        </li>
                                    </ul>
                                </div>
                                <div class="chat-footer">
                                    <!-- CHAT TEXTAREA -->
                                    <div class="textarea-div">
                                        <div class="typearea">
                                            <textarea id="endingOperation" name="endingOperation" placeholder="請輸入100個中英文字" class="custom-scroll" maxlength="100" rows="20"><%= _plan.EndingOperation %></textarea>
                                        </div>
                                    </div>

                                    <!-- CHAT REPLY/SEND -->
                                    <span class="textarea-controls">
                                        <button onclick="commitPlan();" class="btn btn-sm btn-primary pull-right">
                                            更新
                                        </button>
                                    </span>
                                </div>
                            </div>
                        </div>--%>
                        <%  } %>
                        <!-- end s3 tab pane -->
                        <%  if (_item.TrainingBySelf != 1)
                                { %>
                        <div class="tab-pane fade widget-body no-padding-bottom" id="<%= prefix %>4">
                            <%  var assessment = _item.LessonFitnessAssessment.Where(f => f.UID == _model.UID).FirstOrDefault();
                                Html.RenderPartial("~/Views/Lessons/LessonLearnerAssessment.ascx", assessment); %>
                        </div>
                        <div class="tab-pane fade widget-body no-padding-bottom" id="<%= prefix %>6">
                            <%  Html.RenderPartial("~/Views/Lessons/LessonLearnerAssessmentReport.ascx", assessment); %>
                        </div>
                        <div class="tab-pane fade widget-body no-padding-bottom" id="<%= prefix %>7">
                            <%  Html.RenderPartial("~/Views/Lessons/LearnerHealthAssessment.ascx", assessment); %>
                        </div>
                        <%  } %>
                        <!-- end s4 tab pane -->
                        <%  if(_item.RegisterLesson.LessonPriceType.Status!=(int)Naming.DocumentLevelDefinition.教練PI)
                            { %>
                        <%--<div class="tab-pane fade active widget-body in no-padding-bottom" id="<%= prefix %>5">
                            <div class="panel-body status">
                                <div class="chat-body custom-scroll">
                                    <%  Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _item); %>
                                    <ul>
                                        <li class="message">
                                            <% _item.AsAttendingCoach.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online", @style = "width:95px" }); %>
                                            <div class="message-text">
                                                <time><%= String.Format("{0:yyyy-MM-dd HH:mm}",_item.ClassTime) %></time>
                                                <a class="username"><%= _item.AsAttendingCoach.UserProfile.FullName() %></a>
                                                <div id="msgRemark"><%= _plan.Remark %></div>
                                            </div>
                                        </li>
                                    </ul>
                                </div>
                                <%  Html.RenderPartial("~/Views/Lessons/Feedback/LearnerLessonRemarkItem.ascx", _item); %>
                                <div class="chat-footer">
                                    <!-- CHAT TEXTAREA -->
                                    <div class="textarea-div">
                                        <div class="typearea">
                                            <textarea id="remark" name="remark" placeholder="請輸入100個中英文字" class="custom-scroll" maxlength="100" rows="20"><%= _plan.Remark %></textarea>
                                        </div>
                                    </div>

                                    <!-- CHAT REPLY/SEND -->
                                    <span class="textarea-controls">
                                        <button onclick="commitPlan();" class="btn btn-sm btn-primary pull-right">
                                            更新
                                        </button>
                                    </span>
                                </div>
                            </div>
                        </div>--%>
                        <%  } %>
                        <!-- end s5 tab pane -->
                    </div>

                    <!-- end content -->
                </div>

            </div>
            <!-- end widget div -->
        </div>

    </div>
</div>

<%  Html.RenderPartial("~/Views/Shared/MorrisGraphView.ascx"); %>

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
