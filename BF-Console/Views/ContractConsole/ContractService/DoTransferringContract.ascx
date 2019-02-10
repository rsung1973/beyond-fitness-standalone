<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Helper.DataOperation" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<div class="header">
    <h2><strong>轉讓資料</strong></h2>
</div>
<div class="body">
    <div class="row clearfix">
        <div class="col-sm-6">
            <div class="checkbox">
                <input id="checkbox14" type="checkbox" name="FitnessConsultant" <%= _model.FitnessConsultant %> checked="checked" onclick="this.checked = true;" />
                <label for="checkbox14">
                    <span class="col-red">轉讓剩餘<%= _model.RemainedLessonCount() %>堂</span>
                </label>
            </div>
        </div>
        <div class="col-sm-6">
            <div class="input-group">
                <%  ViewBag.SearchAction = Url.Action("SearchContractOwner", "ContractConsole");
                    Html.RenderPartial("~/Views/ConsoleEvent/Module/SearchLearner.ascx"); %>
                <input type="hidden" name="UID" />
            </div>
        </div>
        <div class="col-12">
            <div class="form-group">
                <textarea rows="3" class="form-control no-resize" name="Remark" placeholder="請輸入任何想補充的事項..."></textarea>
            </div>
        </div>
    </div>
</div>

<script>

    $(function () {

        $('#<%= _viewID %> button.quit').on('click', function (event) {
            cancelTransferring();
        });

        $('#<%= _viewID %> button.finish').on('click', function (event) {
            commitTransferring();
        });

    });

    function cancelTransferring() {
        $('').launchDownload('<%= Url.Action("ApplyContractService","ConsoleHome") %>',
            <%= JsonConvert.SerializeObject(new CourseContractQueryViewModel
                {
                    KeyID = _model.ContractID.EncryptKey(),
                }) %>);
    }

    function commitTransferring() {
        var viewModel = $('#<%= _viewID %>').find('input,select,textArea').serializeObject();
        viewModel.Reason = '轉讓';
        viewModel.FitnessConsultant = <%= _model.FitnessConsultant %>;
        clearErrors();
        showLoading();
        $.post('<%= Url.Action("CommitContractService", "ContractConsole",new { KeyID = _model.ContractID.EncryptKey() }) %>', viewModel, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                swal(data.message);
            }
            else {
                $(data).appendTo($('body'));
            }
        });
    }

</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContract _model;
    UserProfile _profile;
    String _viewID;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
        _profile = Context.GetUser();
        _viewID = ViewBag.ViewID as String;
    }


</script>
