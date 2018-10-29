<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <uc1:PageBanner runat="server" ID="pageBanner" Title="會員專區" TitleInEng="VIP" />

    <!-- Start Content -->
    <div id="content">
        <div class="container">

            <div class="row">

                <div class="col-md-12">

                    <!-- Classic Heading -->
                    <h4 class="classic-title"><span class="glyphicon glyphicon-th-list" aria-hidden="true"> <%= _model.ClassTime.Value.ToString("yyyy/M/d HH:mm") %>~<%= _model.ClassTime.Value.AddMinutes(_model.DurationInMinutes.Value).ToString("HH:mm") %> 課程內容 - <%= String.IsNullOrEmpty(_model.AsAttendingCoach.UserProfile.UserName) ? _model.AsAttendingCoach.UserProfile.RealName : _model.AsAttendingCoach.UserProfile.UserName %></h4>
                    <!-- End Classic -->

                    <!-- Start Contact Form -->
                    <!-- Categories Widget -->
                    <!-- End Contact Form -->

                    <!-- Classic Heading -->

                    <!-- Start Contact Form -->

                    <div class="row">
                        <div class="col-md-12">
                            <div class="hr1" style="margin-top: 5px; margin-bottom: 5px;"></div>
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <table class="table">
                                        <tr class="info">
                                            <th>暖身</th>
                                        </tr>
                                        <tr>
                                            <td>
                                                <pre><%= _model.LessonPlan!=null ? _model.LessonPlan.Warming : null %></pre>
                                            </td>
                                        </tr>
                                    </table>
                                    <table class="table">
                                        <tr class="info">
                                            <th>排序</th>
                                            <th>肌力訓練</th>
                                            <th>實際/目標次數</th>
                                            <th>實際/目標強度</th>
                                            <th>組數</th>
                                        </tr>
                                        <%      if (_model.TrainingPlan.Count > 0)
                                            {
                                                int idx = 0;
                                                foreach (var item in _model.TrainingPlan)
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
                                            <td rowspan="<%= training.Count() + 3 %>" class="text-center"><%= idx %>
                                            </td>
                                            <td><%= tranItem.TrainingType.BodyParts %>・<%= tranItem.Description %></td>
                                            <td>
                                                <%= !String.IsNullOrEmpty(tranItem.ActualTurns) ? tranItem.ActualTurns : "--" %>/
                                                <%= !String.IsNullOrEmpty(tranItem.GoalTurns) ? tranItem.GoalTurns : "--" %>次
                                            </td>
                                            <td>
                                                <%= !String.IsNullOrEmpty(tranItem.ActualStrength) ? tranItem.GoalStrength : "--" %>/
                                                <%= !String.IsNullOrEmpty(tranItem.GoalStrength) ? tranItem.GoalStrength : "--" %>
                                            </td>
                                            <td rowspan="<%= training.Count() + 1 %>" class="text-center"><%= item.TrainingExecution.Repeats %></td>
                                        </tr>
                                        <%                  }
                                            else
                                            {   %>
                                        <tr>
                                            <td><%= tranItem.TrainingType.BodyParts %>・<%= tranItem.Description %></td>
                                            <td>
                                                <%= !String.IsNullOrEmpty(tranItem.ActualTurns) ? tranItem.ActualTurns : "--" %>/
                                                <%= !String.IsNullOrEmpty(tranItem.GoalTurns) ? tranItem.GoalTurns : "--" %>
                                            </td>
                                            <td>
                                                <%= !String.IsNullOrEmpty(tranItem.ActualStrength) ? tranItem.ActualStrength : "--" %>/
                                                <%= !String.IsNullOrEmpty(tranItem.GoalStrength) ? tranItem.GoalStrength : "--" %>
                                            </td>
                                        </tr>
                                        <%                  }
                                            }   %>
                                        <tr>
                                            <td colspan="3"><strong>休息時間：</strong><%= execution.BreakIntervalInSecond %>秒</td>
                                        </tr>
                                        <tr class="active">
                                            <td colspan="4">
                                                <li class="glyphicon glyphicon-info-sign"></li>
                                                <strong>小提示：</strong><%= execution.Conclusion %></td>
                                        </tr>
                                        <tr class="active">
                                            <td colspan="4">
                                                <li class="fa fa-commenting-o"></li>
                                                <strong>迴響：</strong>
                                                <a onclick="saveAll();"><i class="fa fa-refresh" aria-hidden="true"></i></a>
                                                <input class="form-control" name="executionFeedBack" value='<%= HttpUtility.HtmlEncode(execution.ExecutionFeedBack) %>' />
                                            </td>
                                        </tr>
                                        <%              }
                                            else
                                            {   %>
                                        <tr>
                                            <td rowspan="2" class="text-center"><%= idx %></td>
                                        </tr>
                                        <tr>
                                            <td colspan="3"><strong>休息時間：</strong><%= execution.BreakIntervalInSecond %>秒</td>
                                        </tr>
                                        <tr class="active">
                                            <td colspan="4">
                                                <li class="glyphicon glyphicon-info-sign"></li>
                                                <strong>小提示：</strong><%= execution.Conclusion %></td>
                                        </tr>
                                        <tr class="active">
                                            <td colspan="4">
                                                <li class="fa fa-commenting-o"></li>
                                                <li class="fa fa-commenting-o"></li>
                                                <strong>迴響：</strong>
                                                <a onclick="saveAll();"><i class="fa fa-refresh" aria-hidden="true"></i></a>
                                                <input class="form-control" name="executionFeedBack" value='<%= HttpUtility.HtmlEncode(execution.ExecutionFeedBack) %>' />
                                            </td>
                                        </tr>
                                        <%              }
                                                }
                                            }
                                            else
                                            {   %>
                                        <tr>
                                            <td colspan="5">未建立任何項目</td>
                                        </tr>
                                        <%  }%>
                                    </table>
                                    <table class="table">
                                        <tr class="info">
                                            <th>收操</th>
                                        </tr>
                                        <tr>
                                            <td>
                                                <pre><%= _model.LessonPlan!=null ?_model.LessonPlan.EndingOperation : null %></pre>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <h4><span class="glyphicon glyphicon-bookmark" aria-hidden="true"></span>著重方向：</h4>
                            <%  Html.RenderPartial("~/Views/Lessons/DailyTrendPieView.ascx", _lessonTime.LessonTime); %>
                        </div>
                        <div class="col-md-6">
                            <h4><span class="glyphicon glyphicon-heart-empty" aria-hidden="true"></span>體適能：</h4>
                            <%  Html.RenderPartial("~/Views/Lessons/DailyFitnessPieView.ascx", _lessonTime.LessonTime); %>
                        </div>
                    </div>

                    <%  if (_model.LessonPlan != null)
                        { %>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="hr1" style="margin-top: 20px; margin-bottom: 5px;"></div>
                            <h4><span class="fa fa-commenting" aria-hidden="true"></span>教練總評：</h4>
                            <div class="hr1" style="margin-top: 5px; margin-bottom: 5px;"></div>
                            <!-- Start Call Action -->
                            <pre class="call-action call-action-boxed call-action-style4 clearfix"><%= _model.LessonPlan == null || String.IsNullOrEmpty(_model.LessonPlan.Remark) ? "目前尚無總評" : _model.LessonPlan.Remark %></pre>
                            <!-- End Call Action -->
                            <div class="hr1" style="margin-top: 10px; margin-bottom: 5px;"></div>
                        </div>

                        <div class="col-md-6">
                            <div class="hr1" style="margin-top: 20px; margin-bottom: 5px;"></div>
                            <h4><span class="fa fa-comments-o" aria-hidden="true"></span>學員意見反饋：</h4>
                            <div class="hr1" style="margin-top: 5px; margin-bottom: 5px;"></div>
                            <!-- Start Call Action -->
                            <textarea class="form-control" name="feedBack" rows="4"><%= _model.LessonPlan != null ? _model.LessonPlan.FeedBack : null %></textarea>
                            <div class="text-right" style="margin-bottom: 5px;">
                                <a href="<%= VirtualPathUtility.ToAbsolute("~/Account/Vip") %>" class="btn-system btn-medium">回行事曆清單 <i class="fa fa-calendar-alt" aria-hidden="true"></i></a>
                                <a onclick="saveAll();" class="btn-system  btn-sm">更新 <i class="fa fa-refresh" aria-hidden="true"></i></a>
                            </div>
                            <!-- End Call Action -->
                        </div>
                    </div>
                    <%  }
                        else
                        { %>
                            <div class="text-right" style="margin-bottom: 5px;">
                                <a href="<%= VirtualPathUtility.ToAbsolute("~/Account/Vip") %>" class="btn-system btn-medium">回行事曆清單 <i class="fa fa-calendar-alt" aria-hidden="true"></i></a>
                            </div>
                    <%  } %>
                </div>


                <!-- End Contact Form -->

            </div>

        </div>
    </div>
    </div>
    <!-- End content -->
    
    <% Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>
    <% Html.RenderPartial("~/Views/Shared/PieView.ascx"); %>

    <script>
        $('#vip,#m_vip').addClass('active');
        $('#theForm').addClass('contact-form');

        function saveAll() {
            $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/Feedback/") + _model.LessonID %>', $('form').serialize(), function (data) {
                if (data.result) {
                    smartAlert("資已更新!!");
                } else {
                    smartAlert(data.message);
                }
            });
        }

    </script>
</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    LessonTime _model;
    LessonTimeExpansion _lessonTime;
    UserProfile _profile;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (LessonTime)this.Model;
        _lessonTime = (LessonTimeExpansion)ViewBag.LessonTimeExpansion;
        _profile = _model.RegisterLesson.UserProfile;
    }

</script>
