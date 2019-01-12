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

<div class="table-responsive">
    <%  ViewBag.OwnerID = _viewModel.OwnerID;
        Html.RenderPartial("~/Views/ContractConsole/Module/ContractMemberList.ascx", _viewModel.UID.PromptContractMembers(models)); %>
</div>

<script>

    $(function () {
        $global.viewModel.UID = <%= JsonConvert.SerializeObject(_viewModel.UID) %>;
        $global.contractMemberInitComplete = function (dt) {
            var api = dt.api();
            api.$('tr').click(function () {
                var id = $(this).data('id');
                processMember(id);
            });
        };

        function processMember(uid) {
            showLoading();
            $.post('<%= Url.Action("ProcessContractMember", "ContractConsole") %>', { 'uid': uid }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    alert(data.message);
                } else {
                    $(data).appendTo($('body'));
                }
            });
        }

    });

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (CourseContractQueryViewModel)ViewBag.ViewModel;
    }


</script>
