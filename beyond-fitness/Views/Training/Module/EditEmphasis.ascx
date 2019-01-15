<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<script>

    $.SmartMessageBox({
        title: "課表重點（至多30個中英文字）",
        content: "",
        buttons: "[取消][確定]",
        input: "text",
        placeholder: "請輸入本次上課課表重點（至多30個中英文字）",
        inputValue: "<%= _model.Emphasis %>"
    }, function (ButtonPress, Value) {
        if (ButtonPress == "確定") {
            showLoading();
            $.post('<%= Url.Action("CommitEmphasis", "Training", new { _model.ExecutionID }) %>', { 'emphasis': Value }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        $('#emphasis').text('重點：' + Value);
                    } else {
                        alert(data.message);
                    }
                } else {
                    $(data).appendTo($('body'));
                }
            });
            return 0;
        }
    });

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    TrainingExecution _model;
    String _dialogID = "emphasis" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (TrainingExecution)this.Model;
    }

</script>
