<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="col-12 align-left">
    <p class="col-red">課表重點：</p>
    <div class="form-line">
        <textarea rows="1" id="<%= _fieldID %>" class="form-control no-resize" placeholder="重點一片空，學生要來踹你了..." maxlength="10"><%= _model.TrainingPlan.FirstOrDefault()?.TrainingExecution.Emphasis %></textarea>
    </div>
</div>
<script>
    function commitEmphasis(keyID) {
        showLoading();
        $.post('<%= Url.Action("CommitEmphasis", "Training") %>', { 'keyID': keyID, 'emphasis': $('#<%= _fieldID %>').val() }, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                if (data.result) {
                    swal('課表重點已更新!!');
                    refreshEvents();
                    $global.closeAllModal();
                } else {
                    swal({
                        title: "Opps！",
                        text: data.message,
                        type: "warning",
                        showCancelButton: false,
                        confirmButtonColor: "#DD6B55",
                        confirmButtonText: "重新輸入!",
                        closeOnConfirm: true
                    }, function () {

                    });
                }
            } else {
                $(data).appendTo($('body'));
            }
        });
    }
</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;
    String _fieldID = $"emphasis{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
    }


</script>
