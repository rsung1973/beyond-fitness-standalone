<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <uc1:PageBanner runat="server" ID="PageBanner" Title="會員專區" TitleInEng="VIP" />

    <!-- Start Content -->
    <div id="content">
        <div class="container">

            <div class="row">

                <div class="col-md-12">

                    <!-- Classic Heading -->
                    <h4 class="classic-title"><span class="fa fa-heartbeat"> 上課囉</span></h4>

                    <%  if (_model.LessonTime.GroupID.HasValue)
                        {
                            Html.RenderPartial("~/Views/Member/GroupingLessonInfo.ascx", _model.LessonTime.GroupingLesson);
                        }
                        else
                        {
                            ViewBag.ShowPerson = true; ViewBag.Argument = new ArgumentModel { Model = _model.LessonTime, PartialViewName = "~/Views/Lessons/LessonGoal.ascx" };
                            Html.RenderPartial("~/Views/Member/MemberInfo.ascx", _model.LessonTime.RegisterLesson.UserProfile);
                        }   %>

                    <!-- Start Contact Form -->
                    <div class="col-md-10">
                        <h4><span class="glyphicon glyphicon-th-list" aria-hidden="true"></span><%= _model.LessonTime.ClassTime.Value.ToString("yyyy/M/d HH:mm") %>~<%= _model.LessonTime.ClassTime.Value.AddMinutes(_model.LessonTime.DurationInMinutes.Value).ToString("HH:mm") %> 課程內容 - <% ViewBag.Inline = true; Html.RenderPartial("~/Views/Lessons/SimpleCoachSelector.ascx", new InputViewModel { Id = "coachID", Name = "coachID", DefaultValue = _model.LessonTime.AttendingCoach }); %></h4>
                    </div>
                    <div class="col-md-2 text-right">
                        <a class="btn-system btn-small" onclick="addTraining();">新增項目組 <i class="fa fa-cart-plus" aria-hidden="true"></i></a>
                    </div>                    
                    <div class="panel panel-default">
                        <table class="table">
                            <tr class="info">
                                <th>暖身</th>
                            </tr>
                            <tr>
                                <td>
                                    <textarea name="warming" class="form-control" rows="5"><%= _plan.Warming %></textarea>
                                </td>
                            </tr>
                        </table>
                        <table class="table">
                            <tr class="info">
                                <th rowspan="2" width="25"></th>
                                <th rowspan="2" class="col-xs-3 col-md-2">肌力訓練</th>
                                <th class="col-xs-2 col-md-2 text-center">實際次數</th>
                                <th class="col-xs-2 col-md-2 text-center">實際強度</th>
                                <th rowspan="2" class="col-xs-2 col-md-2 text-center">備註</th>
                                <th rowspan="2" class="col-xs-1 col-md-1 text-center">組數</th>
                                <th rowspan="2" class="col-xs-2 col-md-3">
                                    <li class="glyphicon glyphicon-info-sign"></li>
                                    小提示：
                                </th>
                            </tr>
                            <tr class="info">
                                <th class=" text-center">目標次數</th>
                                <th class=" text-center">目標強度</th>
                            </tr>
                            <tr>
                            <%      if (_model.LessonTime.TrainingPlan.Count > 0)
                                    {
                                        int idx = 0;
                                        foreach (var item in _model.LessonTime.TrainingPlan)
                                        {
                                            idx++;
                                            var execution = item.TrainingExecution;
                                            var training = execution.TrainingItem;
                                            if (training.Count > 0)
                                            {
                                                for (int i = 0; i < training.Count; i++)
                                                {
                                                    var tranItem = training[i];
                                                    if (i == 0)
                                                    {%>
                            <tr>
                                <td rowspan="<%= training.Count() + 1 %>" class="text-center">
                                    <%= idx %><br />
                                    <a onclick="deleteTraining(<%= execution.ExecutionID %>);" class="red-text fa fa-minus-circle fa-2x"></a>
                                </td>
                                <td><%= tranItem.TrainingType.BodyParts %>・<%= tranItem.Description %></td>
                                <td>
                                    <input type="text" class="form-control" name="actualTurns" value="<%= tranItem.ActualTurns %>">
                                    <%= !String.IsNullOrEmpty(tranItem.GoalTurns) ? tranItem.GoalTurns : "--" %>
                                </td>
                                <td>
                                    <input type="text" class="form-control" name="actualStrength" value="<%= tranItem.ActualStrength %>">
                                    <%= !String.IsNullOrEmpty(tranItem.GoalStrength) ? tranItem.GoalStrength : "--" %>
                                </td>
                                <td>
                                    <textarea class="form-control" name="remark" rows="3"><%= tranItem.Remark %></textarea>
                                </td>
                                <td rowspan="<%= training.Count() + 1 %>" class="text-center"><%= item.TrainingExecution.Repeats %></td>
                                <td rowspan="<%= training.Count() + 1 %>">
                                    <textarea class="form-control" rows="3" name="conclusion"><%= execution.Conclusion %></textarea>
                                </td>
                            </tr>
                            <%                  }
                                    else
                                    {   %>
                            <tr>
                                <td><%= tranItem.TrainingType.BodyParts %>・<%= tranItem.Description %></td>
                                <td>
                                    <input type="text" class="form-control" name="actualTurns" value="<%= tranItem.ActualTurns %>">
                                    <%= !String.IsNullOrEmpty(tranItem.GoalTurns) ? tranItem.GoalTurns : "--" %>
                                </td>
                                <td>
                                    <input type="text" class="form-control" name="actualStrength" value="<%= tranItem.ActualStrength %>">
                                    <%= !String.IsNullOrEmpty(tranItem.GoalStrength) ? tranItem.GoalStrength : "--" %>
                                </td>
                                <td>
                                    <textarea class="form-control" name="remark" rows="3"><%= tranItem.Remark %></textarea>
                                </td>
                            </tr>
                            <%                  }
                                    }   %>
                            <tr class="active">
                                <td colspan="4"><strong>休息時間：</strong><%= execution.BreakIntervalInSecond %>秒</td>
                            </tr>
                            <%              }
                                    else
                                    {   %>
                            <tr>
                                <td class="text-center"><%= idx %></td>
                                <td colspan="5"><strong>休息時間：</strong><%= execution.BreakIntervalInSecond %>秒</td>
                                <td>
                                    <textarea class="form-control" rows="3" name="conclusion" value><%= execution.Conclusion %></textarea>
                                </td>
                            </tr>
                            <%              }
                                        }
                                    }
                                    else
                                    {   %>
                            <tr>
                                <td colspan="7">未建立任何項目</td>
                            </tr>
                            <%  }%>
                        </table>
                        <table class="table">
                            <tr class="info">
                                <th>收操</th>
                            </tr>
                            <tr>
                                <td>
                                    <textarea class="form-control" name="endingOperation" rows="5"><%= _plan.EndingOperation %></textarea>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="row">

                        <div class="col-md-6">
                            <h4 ><span class="glyphicon glyphicon-bookmark" aria-hidden="true"></span>著重方向：</h4>

                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <div class="hr1" style="margin-bottom: 15px;"></div>

                                        <div class="form-group">
                                            <label for="actionLearning" class="col-sm-3 control-label text-right">動作學習</label>
                                            <div class="col-sm-9 input-group">
                                                <input type="number" class="form-control" id="actionLearning" name="actionLearning" value="<%: _model.LessonTime.LessonTrend.ActionLearning %>" />
                                                <span class="input-group-addon">%</span>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="postureRedress" class="col-sm-3 control-label text-right">姿勢矯正</label>
                                            <div class="col-sm-9 input-group">
                                                <input type="number" class="form-control" id="postureRedress" name="postureRedress" value="<%: _model.LessonTime.LessonTrend.PostureRedress %>"/>
                                                <span class="input-group-addon">%</span>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="training" class="col-sm-3 control-label text-right">訓練</label>
                                            <div class="col-sm-9 input-group">
                                                <input type="number" class="form-control" id="training" name="training" value="<%: _model.LessonTime.LessonTrend.Training %>" />
                                                <span class="input-group-addon">%</span>
                                            </div>
                                        </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <h4 ><span class="glyphicon glyphicon-heart-empty" aria-hidden="true"></span>體適能：</h4>

                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <div class="hr1" style="margin-bottom: 15px;"></div>
                                        <div class="form-group">
                                            <label for="flexibility" class="col-sm-3 control-label text-right">柔軟度</label>
                                            <div class="col-sm-9 input-group">
                                                <input type="number" class="form-control" id="flexibility" name="flexibility" value="<%: _model.LessonTime.FitnessAssessment.Flexibility %>" />
                                                <span class="input-group-addon">%</span>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="cardiopulmonary" class="col-sm-3 control-label text-right">心肺</label>
                                            <div class="col-sm-9 input-group">
                                                <input type="number" class="form-control" id="cardiopulmonary" name="cardiopulmonary" value="<%: _model.LessonTime.FitnessAssessment.Cardiopulmonary %>" />
                                                <span class="input-group-addon">%</span>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="strength" class="col-sm-3 control-label text-right">肌力</label>
                                            <div class="col-sm-9 input-group">
                                                <input type="number" class="form-control" id="strength" name="strength" value="<%: _model.LessonTime.FitnessAssessment.Strength %>" />
                                                <span class="input-group-addon">%</span>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="endurance" class="col-sm-3 control-label text-right">肌耐力</label>
                                            <div class="col-sm-9 input-group">
                                                <input type="number" class="form-control" id="endurance" name="endurance" value="<%: _model.LessonTime.FitnessAssessment.Endurance %>" />
                                                <span class="input-group-addon">%</span>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="explosiveForce" class="col-sm-3 control-label text-right">爆發力</label>
                                            <div class="col-sm-9 input-group">
                                                <input type="number" class="form-control" id="explosiveForce" name="explosiveForce" value="<%: _model.LessonTime.FitnessAssessment.ExplosiveForce %>" />
                                                <span class="input-group-addon">%</span>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="sportsPerformance" class="col-sm-3 control-label text-right">運動表現</label>
                                            <div class="col-sm-9 input-group">
                                                <input type="number" class="form-control" id="sportsPerformance" name="sportsPerformance" value="<%: _model.LessonTime.FitnessAssessment.SportsPerformance %>" />
                                                <span class="input-group-addon">%</span>
                                            </div>
                                        </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <h4 class="orange-text classic-title"><span class="fa fa-commenting" aria-hidden="true">教練總評：</span></h4>
                    <div class="form-group has-feedback">
                        <textarea class="form-control" name="remark" rows="5"><%= _plan.Remark %></textarea>
                    </div>


                    <div class="hr2" style="margin-bottom: 10px;"></div>
                    <a class="btn-system btn-medium" href="<%= VirtualPathUtility.ToAbsolute("~/Attendance/EndAssessment") %>">回行事曆清單 <i class="fa fa-calendar" aria-hidden="true"></i></a>
                    <a id="btnSave" class="btn-system btn-medium"><span class="glyphicon glyphicon-save" aria-hidden="true"></span>暫存</a>
                    <a id="nextStep" class="btn-system btn-medium"><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span>上完課了</a>
                    

                    <div class="hr1" style="margin-top: 5px; margin-bottom: 10px;"></div>


                    <!-- End Contact Form -->

                </div>
            </div>

        </div>
    </div>

    <!-- End content -->
    <% Html.RenderPartial("~/Views/Shared/AlertMessage.ascx"); %>
    <% Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>

    <script>
        $('#vip,#m_vip').addClass('active');
        //$('#theForm').addClass('contact-form');

        $('#nextStep').on('click', function (evt) {
            startLoading();
            $('form').prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Attendance/CommitAssessment") %>')
          .submit();
        });

        $('#btnSave').on('click', function (evt) {
            startLoading();
            $('form').prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Attendance/SaveAssessment") %>')
          .submit();
        });

        function addTraining() {
            $('form').prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Attendance/SaveThenAddTraining") %>')
                .submit();
        }

        function deleteTraining(itemID) {
            confirmIt({ title: '刪除訓練組數', message: '確定刪除此訓練組數?' }, function (evt) {
                startLoading();
                $('<form method="post"/>').appendTo($('body'))
                    .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Attendance/DeleteTraining/") %>' + itemID)
                    .submit();
            });
        }

    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    LessonTimeExpansion _model;
    LessonPlan _plan;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (LessonTimeExpansion)this.Model;
        _plan = _model.LessonTime.LessonPlan ?? new LessonPlan { };
        if (_model.LessonTime.FitnessAssessment == null)
        {
            _model.LessonTime.FitnessAssessment = new FitnessAssessment { };
        }
        if (_model.LessonTime.LessonTrend == null)
        {
            _model.LessonTime.LessonTrend = new LessonTrend { };
        }

    }



</script>
