<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
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
<%@ Import Namespace="Newtonsoft.Json" %>

<div class="lesson-wrap">
    <!-- 登入 - TAB -->
    <ul id="tabs-swipe-demo" class="tabs col s12">
        <li class="tab col s6"><a class="active" onclick="gtag('event', '課表', { 'event_category': '頁籤點擊', 'event_label': '課表內容'});" href="#test-swipe-1">課表</a></li>
        <li class="tab col s6"><a onclick="gtag('event', '分析', { 'event_category': '頁籤點擊', 'event_label': '課表內容'});" href="#test-swipe-2">分析</a></li>
    </ul>
    <div id="test-swipe-1" class="tab-content acc-content col s12">
        <!--  Accordion -->
        <div class="accordion js-accordion">
            <div class="accordion__item js-accordion-item active">
                <div class="accordion-header js-accordion-header light-gray">
                    <ul class="lesson-box">
                        <li class="lesson-spot"><%= $"{_model.ClassTime:yyyy/MM/dd}" %> - <%= _model.RegisterLesson.LessonPriceType.Status.LessonTypeStatus().Replace(".session","").Replace("課程","") %> <%= _model.AsAttendingCoach.UserProfile.FullName() %></li>
                        <%  if (_training != null)
                            { %>
                        <li class="lesson-item"><%= _training.Emphasis ?? "課程預約好囉，但是教練忘記打上課重點，提醒他一下！（或踹他一下）" %></li>
                        <%  } %>
                    </ul>
                </div>
                <%  if (_training != null)
                    { %>
                <div class="accordion-body js-accordion-body">
                    <div class="accordion-body__contents"></div>
                    <div class="accordion js-accordion">
                        <%  foreach (var stage in models.GetTable<TrainingStage>())
                            {
                                var items = models.GetTable<TrainingItem>()
                                    .Where(t => t.ExecutionID == _training.ExecutionID)
                                    .Where(t => t.TrainingType.TrainingStageItem.StageID == stage.StageID)
                                    .OrderBy(t => t.Sequence);  %>
                        <!--1-->
                        <div class="accordion__item js-accordion-item">
                            <div class="accordion-header js-accordion-header s-box">
                                <div class="row valign-wrapper">
                                    <div class="col s4 m2">
                                        <img src="images/lesson/stage<%= stage.StageID %>-<%= _profile.UserProfileExtension.Gender=="F" ? "girl" : "boy" %>.png" alt="" class="circle responsive-img valign" />
                                    </div>
                                    <%  var duration = _training.TrainingExecutionStage.Where(s => s.StageID == stage.StageID).Select(t => t.TotalMinutes).FirstOrDefault() ?? 0; %>
                                    <div class="col s8 m10 text-box">
                                        <span class="black-t18">STAGE <%= stage.StageID %>. </span>
                                        <span class="black-t12">
                                            <%= stage.Stage %> - <%= $"{duration:0.#}" %> min
                                        </span>
                                    </div>
                                </div>
                            </div>
                            <div class="accordion-body js-accordion-body">
                                <div class="accordion-body__contents">
                                    <!-- 清單項目1 -->
                                    <ul class="lesson-list">
                                        <%
                                            foreach (var item in items)
                                            {
                                                if (item.TrainingType.BreakMark != true)
                                                {   %>
                                        <li class="list-item">
                                            <span class="tag-blue badge"><%= item.TrainingType.BodyParts %></span>
                                            <%      foreach (var aids in item.TrainingItemAids)
                                                {   %>
                                            <span class="tag-equipment badge"><%= aids.TrainingAids.ItemName %></span>
                                                <%  } %>
                                            <%= item.Description %>
                                        </li>
                                                <%  if (item.GoalStrength != null)
                                                    {
                                                        if (item.GoalTurns != null)
                                                        { %>
                                                <li class="list-item"><span class="tag-line badge"><%: item.GoalStrength %></span> X <span class="tag-line badge"><%: item.GoalTurns %></span></li>
                                                    <%  }
                                                        else
                                                        { %>
                                                <li class="list-item"><span class="tag-line badge"><%: item.GoalStrength %></span></li>
                                                <%      }
                                                    }
                                                    else if (item.GoalTurns != null)
                                                    { %>
                                                <li class="list-item"><span class="tag-line badge"><%: item.GoalTurns %></span></li>
                                                <%  } %>
                                                <li class="list-intro"><%= item.Remark %></li>
                                        <%      }
                                            else
                                            {   %>
                                                <%  if (item.Repeats != null)
                                                    {
                                                        if (item.BreakIntervalInSecond != null)
                                                        {%>
                                                <li class="list-line">
                                                    <span class="tag-repet badge">Break <%= item.BreakIntervalInSecond %> sec. / Repeat * <%= item.Repeats %></span>
                                                </li>
                                                <%      }
                                                    else
                                                    {   %>
                                                <li class="list-line">
                                                    <span class="tag-repet badge">Repeat * <%= item.Repeats %></span>
                                                </li>
                                                    <%  }
                                                        }
                                                        else if (item.BreakIntervalInSecond != null)
                                                        { %>
                                                <li class="list-line"><span class="tag-repet badge">Break <%= item.BreakIntervalInSecond %> sec. </span></li>
                                                <%  } %>
                                        <%      }
                                            } %>
                                    </ul>
                                </div>
                                <!-- end of sub accordion item body contents -->
                            </div>
                            <!-- end of sub accordion item body -->
                        </div>
                        <!-- end of sub accordion item -->
                        <%  } %>
                    </div>
                    <!-- end of sub accordion -->
                </div>
                <!-- end of accordion body -->
                <%  }   %>
            </div>
            <!-- end of accordion item -->
            <%  if (_training == null)
                { %>
            <img class="responsive-img nodata" src="images/nodata.png" />
            <p class="collection center">
                <span class="gray-t16">課程預約好囉，但是教練忘記打課表，提醒他一下！（或踹他一下）</span>
            </p>
            <%  } %>
        </div>
        <!--//End of Accordion-->
    </div>
    <div id="test-swipe-2" class="tab-content acc-content grey-bg col s12">
        <!-- Ｃards -->
        <div class="chart-wrap">
            <!-- Ｃhart -->
            <ul class="collection">
                <!-- Card 2-->
                <li class="collection-item avatar">
                    <!-- 上 -->
                    <div class="row">
                        <ul class="chart-card">
                            <li class="chart-top">
                                <span class="title">本次訓練時間比例</span>
                                <%  if (_training != null && _training.TrainingExecutionStage.Sum(t => t.TotalMinutes) > 0)
                                    { %>
                                <%  Html.RenderPartial("~/Views/CornerKick/Module/LessonContentPieChart.ascx", _training); %>
                                <%  }
                                    else
                                    { %>
                                <div class="pie">
                                    <div class="pie_light">
                                        您沒有<br />
                                        <span>相關累計運動時間</span>
                                    </div>
                                </div>
                                <%  } %>
                            </li>
                            <!-- 下-->
                            <li class="chart-bottom" id="pieChartBottom">
                                <div class="col s6">
                                    <ul class="list-2">
                                        <li>基本  --</li>
                                        <li>運動技巧  --</li>
                                        <li>肌力  --</li>
                                    </ul>
                                </div>
                                <div class="col s6">
                                    <ul class="list-3">
                                        <li>心肺  --</li>
                                        <li>恢復  --</li>
                                    </ul>
                                </div>
                            </li>
                        </ul>
                    </div>
                </li>
            </ul>
            <!-- //End of Card  -->
        </div>
        <!--//End of Chart-->
    </div>
</div>
<script>
    $global.showPieChartBottom = function () {
        var data = window.myPieChart.chart.data;
        var $bottom = $('#pieChartBottom li');
        $bottom.each(function (idx, element) {
            if (idx < data.labels.length) {
                $(this).text(data.labels[idx] + ' ' + (data.datasets[0].data[idx] ? data.datasets[0].data[idx] + '%' : '--'));
            }
        });
    };
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;
    TrainingExecution _training;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
        _training = _model.TrainingPlan.Select(p => p.TrainingExecution).FirstOrDefault();
        _profile = Context.GetUser().LoadInstance(models);
    }

</script>
