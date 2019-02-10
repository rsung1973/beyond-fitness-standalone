<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  ViewBag.SelectMember = (Func<UserProfile, String>)(item =>
        {
            return $"commitContractOwner({item.UID},'{item.FullName()}');";
        });
    Html.RenderPartial("~/Views/ConsoleEvent/EventModal/MemberSelector.ascx", _model); %>
    <script>
        function commitContractOwner(uid, fullName) {
            $('input[name="UID"]').val(uid);
            $('input[name="userName"]').attr('placeholder', fullName)
                .val('');
            $global.closeAllModal();
        }
    </script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<UserProfile> _model;
    CalendarEventQueryViewModel _viewModel;
    String _dialogID = $"owner{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<UserProfile>)this.Model;
        _viewModel = (CalendarEventQueryViewModel)ViewBag.ViewModel;
    }


</script>
