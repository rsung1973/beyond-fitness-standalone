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
    <h2><strong>原負責體能顧問</strong> - <strong><%= _model.ServingCoach.UserProfile.FullName() %></strong></h2>
</div>
<div class="body">
    <div class="row clearfix">
        <div class="col-lg-6 col-md-6 col-sm-6 col-12 m-b-20">
            <label class="fancy-checkbox custom-bgcolor-pink">
                <input id="checkbox14" type="checkbox" checked="checked" name="FitnessConsultant" value="<%= _profile.UID %>" onclick="this.checked = true;" />
                <span class="col-red">轉換為自己</span>
            </label>
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
            cancelAssignment();
        });

        $('#<%= _viewID %> button.finish').on('click', function (event) {
            commitAssignment();
        });

    });

    function cancelAssignment() {
        $('').launchDownload('<%= Url.Action("ApplyContractService","ConsoleHome") %>',
            <%= JsonConvert.SerializeObject(new CourseContractQueryViewModel
                {
                    KeyID = _model.ContractID.EncryptKey(),
                }) %>);
    }

    function commitAssignment() {
        var viewModel = $('#<%= _viewID %>').find('input,select,textArea').serializeObject();
        viewModel.Reason = '轉換體能顧問';
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
