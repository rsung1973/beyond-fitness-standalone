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

<div id="contractAction" class="row text-center">
    <button type="button" name="btnReject" class="btn bg-color-red" onclick="rejectSignature();">
        刪除 <i class='far fa-trash-alt' aria-hidden='true'></i>
    </button>
    <button type="button" name="btnConfirm" class="btn btn-primary" onclick="approveContract();">
        確認審核 <i class="far fa-copy" aria-hidden="true"></i>
    </button>
</div>
<script>
    function approveContract() {
        showLoading();
        $.post('<%= Url.Action("ExecuteContractStatus","CourseContract",new { _model.CourseContract.ContractID, Status = (int)Naming.CourseContractStatus.待簽名 }) %>', {}, function (data) {
            hideLoading();
            if (data.result) {
                done = true;
                $('#contractAction').remove();
                alert('服務已審核!!');
                window.close();
            } else {
                $(data).appendTo($('body')).remove();
            }
        });
    }

    function rejectSignature() {
        if (confirm('確定刪除?')) {
            showLoading();
            $.post('<%= Url.Action("DeleteCourseContract","CourseContract",new { _model.CourseContract.ContractID }) %>', {}, function (data) {
                hideLoading();
                if (data.result) {
                    done = true;
                    $('#contractAction').remove();
                    alert('服務已刪除!!');
                    window.close();
                } else {
                    $(data).appendTo($('body')).remove();
                }
            });
        }
    }

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractRevision _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContractRevision)this.Model;
    }

</script>
