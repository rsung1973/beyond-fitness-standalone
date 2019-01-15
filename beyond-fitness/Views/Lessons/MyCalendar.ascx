<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="calendarView" class="jarviswidget" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
    <header>
        <span class="widget-icon"><i class="fa fa-calendar-alt"></i></span>
        <h2><span id="coachName"><%= _coach==null ? "全部練教" : _coach.CoachID==_model.UID ? "我" : _coach.UserProfile.FullName() %></span>的行事曆：<span id="branchName"><%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreText.ascx", _viewModel.BranchID); %></span></h2>
        <div class="widget-toolbar">
<%--            <div class="btn-group">
                <button class="btn dropdown-toggle btn-xs bg-color-blue" data-toggle="dropdown">
                    新增行事曆 <i class="fa fa-caret-down"></i>
                </button>
                <ul class="dropdown-menu pull-right">
                    <li>
                        <a href="addBeyondFitnessEvent.html"><i class="fa fa-fw fa-users"></i>BeyondFitness的行事曆</a>
                    </li>
                    <li>
                        <a href="addPersonalEvent.html"><i class="fa fa-fw fa-user-o"></i>自己的行事曆</a>
                    </li>
                </ul>
            </div>--%>
            <div class="btn-group">
                <button class="btn dropdown-toggle btn-xs btn-warning" data-toggle="dropdown">
                    上課地點 <i class="fa fa-caret-down"></i>
                </button>
                <ul class="dropdown-menu pull-right">
                    <li>
                        <a href="javascript:selectBranch(null,'全部');">全部</a>
                    </li>
                    <%  foreach (var b in models.GetTable<BranchStore>())
                        { %>
                    <li>
                        <a href="javascript:selectBranch(<%= b.BranchID %>,'<%= b.BranchName %>');"><%= b.BranchName %></a>
                    </li>
                    <%  } %>
                </ul>
            </div>
            <div class="btn-group">
                <button class="btn dropdown-toggle btn-xs bg-color-pinkDark" data-toggle="dropdown">
                    體能顧問 <i class="fa fa-caret-down"></i>
                </button>
                <ul class="dropdown-menu pull-right">
                    <li>
                        <a href="javascript:selectCoach(null,'全部');">全部</a>
                    </li>
                    <%  if (_model.IsAssistant())
                        {
                            var items = models.GetTable<ServingCoach>();
                            foreach (var item in items)
                            { %>
                                <li>
                                    <a href="javascript:selectCoach(<%= item.CoachID %>,'<%= item.CoachID == _model.UID ? "我" : item.UserProfile.FullName() %>');"><%= item.UserProfile.FullName() %></a>
                                </li>
                    <%      }
                        }
                        else
                        {   %>
                            <li>
                                <a href="javascript:selectCoach(<%= _model.UID %>,'我');"><%= _model.FullName() %></a>
                            </li>
                    <%  } %>
                </ul>
            </div>
        </div>
    </header>
    <!-- widget div-->
    <%  Html.RenderAction("CoachCalendar","CoachFacet",new FullCalendarViewModel { DefaultDate = DateTime.Today,DefaultView = "agendaWeek" }); %>
    <!-- end widget div -->
</div>
<script>
    function selectCoach(coachID, coachName) {
        $('#coachName').text(coachName);
        $global.viewModel.CoachID = coachID;
        showLoading();
        //window.location.href = '<%= Url.Action("Index","CoachFacet") %>' + "?" + $.param($global.viewModel);
        $global.renderFullCalendar();
    }

    function selectBranch(branchID, branchName) {
        $('#branchName').text(branchName);
        $global.viewModel.BranchID = branchID;
        $global.renderFullCalendar();
    }
</script>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    DailyBookingQueryViewModel _viewModel;
    UserProfile _model;
    ServingCoach _coach;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (DailyBookingQueryViewModel)ViewBag.ViewModel;
        _model = (UserProfile)this.Model;
        _coach = (ServingCoach)ViewBag.CurrentCoach;
    }

</script>
