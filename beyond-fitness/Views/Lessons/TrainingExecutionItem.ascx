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

<form action="<%= VirtualPathUtility.ToAbsolute("~/Lessons/CommitTraining") %>" method="post">
    <input type="hidden" value="<%= _model.ExecutionID %>" name="executionID" />
    <div class="row">
        <div class="col-xs-2 col-sm-1">
            <i class="fa fa-minus-circle text-danger fa-2x" onclick="deleteTraining(<%= _model.ExecutionID %>);"></i>
        </div>

        <div class="col-xs-10 col-sm-11">
            <table id="dt_basic" class="table table-forum bg-color-blueDark" width="100%">
                <thead>
                    <tr>
                        <th data-hide="phone" style="width: 20px"></th>
                        <th data-class="expand" class="col-xs-3 col-sm-3">動作</th>
                        <th data-hide="phone" class="col-xs-3 col-sm-3">實際/目標次數</th>
                        <th data-hide="phone" class="col-xs-3 col-sm-3">實際/目標強度</th>
                        <th data-hide="phone" class="col-xs-3 col-sm-3">加強說明</th>
                    </tr>
                </thead>
                <tbody>
                    <% foreach (var item in _model.TrainingItem)
                        {
                            Html.RenderPartial("~/Views/Lessons/EditTrainingItem.ascx", item);
                        } %>
                </tbody>
            </table>
        </div>
        <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1"></div>
        <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11">
            <a onclick="addTrainingItem(<%= _model.ExecutionID %>);"><i class="fa fa-plus-square text-success"></i>請點選 <i class="fa fa-plus-square text-success"></i>新增項目 </a> / <a onclick="commitTraining();"><i class="fa fa-refresh text-success"></i>請點選 <i class="fa fa-refresh text-success"></i>更新項目內容</a>
        </div>
        <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1"></div>
        <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11">
            <hr />
        </div>
        <div class="col-xs-12 col-sm-12 col-md-1 col-lg-1"></div>
        <div class="col-xs-12 col-sm-12 col-md-11 col-lg-11">
            <div class="col-xs-12 col-sm-12 col-md-6 col-lg-6">
                <div class="form-group">
                    <div class="input-group">
                        <span class="input-group-addon">休息時間</span>
                        <div class="icon-addon">
                            <input type="text" placeholder="請輸入90 或 90-120" class="form-control" name="BreakInterval" value="<%= _model.BreakIntervalInSecond %>">
                        </div>
                        <span class="input-group-addon">秒</span>
                        <span class="input-group-btn">
                            <button class="btn btn-primary" type="button" onclick="commitTraining();">
                                <i class="fa fa-reply"></i>更新
                            </button>
                        </span>
                    </div>
                    <p class="note"><strong>Note:</strong> 輸入90 或 90-120</p>
                </div>
            </div>
            <div class="col-xs-12 col-sm-12 col-md-6 col-lg-6">
                <div class="form-group">
                    <div class="input-group">
                        <span class="input-group-addon">總</span>
                        <div class="icon-addon">
                            <input type="text" placeholder="輸入3 或 3-5" class="form-control" name="Repeats" value="<%= _model.Repeats %>" />
                        </div>
                        <span class="input-group-addon">組數</span>
                        <span class="input-group-btn">
                            <button class="btn btn-primary" type="button" onclick="commitTraining();">
                                <i class="fa fa-reply"></i>更新
                            </button>
                        </span>
                    </div>
                    <p class="note"><strong>Note:</strong> 輸入3 或 3-5</p>
                </div>
            </div>
        </div>

        <div class="col-xs-2 col-sm-1"></div>
        <div class="cols-sm-11">
            <div class="chat-body no-padding profile-message">
                <ul>
                    <li class="message">
                        <% _model.TrainingPlan.LessonTime.AsAttendingCoach.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online" }); %>
                        <span class="message-text">
                            <a class="username" href="<%= VirtualPathUtility.ToAbsolute("~/Account/ViewProfile/") + _model.TrainingPlan.LessonTime.AttendingCoach %>"><%= _model.TrainingPlan.LessonTime.AsAttendingCoach.UserProfile.FullName() %></a>
                            <%= _model.Conclusion %>
                        </span>
                    </li>
                    <li>
                        <div class="input-group wall-comment-reply">
                            <input id="btn-input" type="text" class="form-control" placeholder="請輸入50個中英文字" name="Conclusion" value="<%= _model.Conclusion %>" />
                            <span class="input-group-btn">
                                <button class="btn btn-primary" type="button" onclick="commitTraining();">
                                    <i class="fa fa-reply"></i>更新
                                </button>
                            </span>
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</form>


<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    TrainingExecution _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (TrainingExecution)this.Model;
    }





</script>
