<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<h2><strong>合約基本資料</strong> - <span id="fitnessConsultant"><%= _fitnessConsultant?.UserProfile.FullName() %></span></h2>
<ul class="header-dropdown">
    <li>
        <a href="javascript:selectCoach();"><i class="zmdi zmdi-swap"></i></a>
    </li>
</ul>
<script>

    $(function () {
        $global.commitCoach = function (coachID, coachName) {
            $global.viewModel.FitnessConsultant = coachID;
            $('#fitnessConsultant').text(coachName);
        };
    });

    function selectCoach() {
        showLoading();
        $.post('<%= Url.Action("SelectCoach", "ContractConsole") %>', {}, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $(data).appendTo($('body'));
            }
        });
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    String _viewID = $"consultant{DateTime.Now.Ticks}";
    CourseContractQueryViewModel _viewModel;
    ServingCoach _fitnessConsultant;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _viewModel = (CourseContractQueryViewModel)ViewBag.ViewModel;
        _fitnessConsultant = models.GetTable<ServingCoach>().Where(c => c.CoachID == _viewModel.FitnessConsultant).FirstOrDefault();

    }


</script>
