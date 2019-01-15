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

<div id="<%= _dialogID %>" title="分潤明細" class="bg-color-darken">
    <!-- content -->
    <%  Html.RenderPartial("~/Views/Accounting/Module/TuitionAchievementShareList.ascx", _model); %>
    <%  Html.RenderPartial("~/Views/Achievement/Module/StaticContributionDonut.ascx", _model); %>
    <!-- end content -->
    <script>
        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-table'></i>  <%= _viewModel.AchievementYearMonthFrom %>分潤明細：<%= models.GetTable<UserProfile>().Where(u=>u.UID==_viewModel.CoachID).Select(u=>u.RealName).FirstOrDefault() %></h4>",
            close: function (event, ui) {
                $('#<%= _dialogID %>').remove();
            }
        });
    </script>
</div>



<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialogID = "tuition" + DateTime.Now.Ticks;
    IQueryable<TuitionAchievement> _model;
    AchievementQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<TuitionAchievement>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }

</script>
