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
    <h2><strong>展延資料</strong></h2>
</div>
<div class="body">
    <div class="row clearfix">
        <div class="col-12 m-b-20">
            <div class="checkbox">
                <input id="checkbox14" type="checkbox" checked="checked" name="MonthExtension" value="3" onclick="this.checked = true;" />
                <label for="checkbox14">
                    <span class="col-red">展延3個月 - <%= $"{_model.Expiration.Value.AddMonths(3):yyyy/MM/dd}" %></span>
                </label>
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
            cancelPostponing();
        });

        $('#<%= _viewID %> button.finish').on('click', function (event) {
            commitPostponing();
        });

    });

    function cancelPostponing() {
        $('').launchDownload('<%= Url.Action("ApplyContractService","ConsoleHome") %>',
            <%= JsonConvert.SerializeObject(new CourseContractQueryViewModel
                {
                    KeyID = _model.ContractID.EncryptKey(),
                }) %>);
    }

    function commitPostponing() {
        var viewModel = $('#<%= _viewID %>').find('input,select,textArea').serializeObject();
        viewModel.Reason = '展延';
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
