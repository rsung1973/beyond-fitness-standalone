<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<div class="jarviswidget" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
    <header>
        <span class="widget-icon"><i class="fa fa-check"></i></span>
        <h2><span id="inspectedCoachName"><%= _coach==null ? "全部練教" : _coach.CoachID==_model.UID ? "我" : _coach.UserProfile.FullName() %></span>的待辦事項：<span id="queryInterval"><%= _viewModel.QueryStart.HasValue ? String.Format("{0:yyyy/MM}",_viewModel.QueryStart) : "全部" %></span></h2>
        <div class="widget-toolbar">
            <div class="btn-group">
                <button class="btn dropdown-toggle btn-xs btn-warning" data-toggle="dropdown">
                    查詢月份 <i class="fa fa-caret-down"></i>
                </button>
                <ul class="dropdown-menu pull-right">
                    <li>
                        <a href="javascript:selectQueryInterval(null,'全部');">全部</a>
                    </li>
                    <%  var currentMonth = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1); %>
                    <li>
                        <a href="javascript:selectQueryInterval('<%= currentMonth.ToString("yyyy/MM/dd") %>','<%= currentMonth.ToString("yyyy/MM") %>');"><%= currentMonth.ToString("yyyy/MM") %></a>
                    </li>
                    <%  DateTime endDate = new DateTime(2018, 2, 1);
                        //for (int i = 0; i < 5; i++)
                        while(currentMonth > endDate)
                        {
                            currentMonth = currentMonth.AddMonths(-1);%>
                    <li>
                        <a href="javascript:selectQueryInterval('<%= currentMonth.ToString("yyyy/MM/dd") %>','<%= currentMonth.ToString("yyyy/MM") %>');"><%= currentMonth.ToString("yyyy/MM") %></a>
                    </li>
                    <%  } %>
                </ul>
            </div>
<%--            <div class="btn-group">
                <button class="btn dropdown-toggle btn-xs bg-color-pinkDark" data-toggle="dropdown">
                    體能顧問 <i class="fa fa-caret-down"></i>
                </button>
                <ul class="dropdown-menu pull-right">
                    <li>
                        <a href="javascript:selectInspectedCoach(null,'全部');">全部</a>
                    </li>
                    <%  if (_model.IsAssistant() || _model.IsManager() || _model.IsViceManager())
                        {
                            IQueryable<ServingCoach> items;
                            if(_model.IsManager() || _model.IsViceManager())
                            {
                                items = _model.GetServingCoachInSameStore(models);
                            }
                            else
                            {
                                items = models.GetTable<ServingCoach>();
                            }
                            foreach (var item in items)
                            { %>
                    <li>
                        <a href="javascript:selectInspectedCoach(<%= item.CoachID %>,'<%= item.CoachID == _model.UID ? "我" : item.UserProfile.FullName() %>');"><%= item.UserProfile.FullName() %></a>
                    </li>
                    <%      }
                        }
                        else
                        {   %>
                    <li>
                        <a href="javascript:selectInspectedCoach(<%= _model.UID %>,'我');"><%= _model.FullName() %></a>
                    </li>
                    <%  } %>
                </ul>
            </div>--%>
        </div>
    </header>
    <!-- widget div-->
    <div>
        <!-- widget content -->
        <div class="row padding-5">
            <div class="widget-body txt-color-white" id="querySummary">
                <!-- content -->
                <%  Html.RenderAction("QueryLesson", "CoachFacet", _viewModel); %>
                <!-- end content -->
            </div>
            <!-- end widget content -->
        </div>
        <div class="row padding-5">
            <div class="widget-body txt-color-white">
                <%  Html.RenderAction("CourseContractSummary", "CourseContract"); %>
            </div>
        </div>
        <div class="row padding-5">
            <!-- widget content -->
            <div class="widget-body txt-color-white">
                <%  Html.RenderAction("PaymentAuditSummary", "Payment"); %>
            </div>
            <!-- end widget content -->
        </div>
    </div>
    <!-- end widget div -->
</div>
<script>

    $(function () {
        $global.lessonQueryViewModel = <%= JsonConvert.SerializeObject(_viewModel) %>;
        $global.queryLessons = function() {
            showLoading();
            $('#querySummary').load('<%= Url.Action("QueryLesson","CoachFacet") %>',$global.lessonQueryViewModel,function(data){
                    hideLoading();
                });
        };
    });

        function selectInspectedCoach(coachID, coachName) {
            $('#inspectedCoachName').text(coachName);
            $global.lessonQueryViewModel.CoachID = coachID;
            $global.queryLessons();
        }

        function selectQueryInterval(queryStart, queryInterval) {
            $('#queryInterval').text(queryInterval);
            $global.lessonQueryViewModel.QueryStart = queryStart;
            $global.queryLessons();
        }

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonQueryViewModel _viewModel;
    UserProfile _model;
    ServingCoach _coach;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _viewModel = (LessonQueryViewModel)ViewBag.ViewModel;
        _coach = (ServingCoach)ViewBag.CurrentCoach;

    }

</script>
