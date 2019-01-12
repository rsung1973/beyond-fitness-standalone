<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<input type="text" id="<%= _viewID %>" class="form-control" name="userName" placeholder="搜尋學生..." />
<span class="input-group-addon">
    <i class="zmdi zmdi-search"></i>
</span>

<script>
    $('#<%= _viewID %>').keypress(function (event) {
        var event = event || window.event;
        var userName = $(event.target).val();
        var keycode = (event.keyCode ? event.keyCode : event.which);
        if (keycode == '13') {
            clearErrors();
            if (userName.length < 2) {
                swal({
                    title: "Opps！",
                    text: "你忘了學生的姓名嗎？!(至少2個中、英文字)",
                    type: "warning",
                    showCancelButton: false,
                    confirmButtonColor: "#DD6B55",
                    confirmButtonText: "重新輸入!",
                    closeOnConfirm: true
                }, function () {

                });
            } else {
                showLoading();
                $.post('<%= (String)ViewBag.SearchAction %>', { 'userName': userName }, function (data) {
                    hideLoading();
                    if ($.isPlainObject(data)) {
                        if (data.result) {
                            swal(data.message);
                        } else {
                            swal({
                                title: "Opps！",
                                text: "你確定有這個學生？!",
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
        }
    });

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _viewID = $"searchLearner{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
