<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h6 class="title">請選擇預約項目</h6>
                <a class="closebutton" data-dismiss="modal"></a>
            </div>
            <div class="modal-popmenu-body">
                <div class="list-group">
                    <div class="list-group-item input-group m-b-0">
                        <input type="text" class="form-control searchLearner" name="userName" placeholder="搜尋學生..." />
                        <span class="input-group-addon">
                            <i class="zmdi zmdi-search"></i>
                        </span>
                    </div>
                    <a href="javascript:bookingCoachPI();" class="list-group-item">教練P.I</a>
                    <a href="javascript:bookingCustomEvent({ 'startDate':'<%= $"{_viewModel.StartDate:yyyy-MM-dd HH:mm:ss}" %>' });" class="list-group-item">個人行事曆</a>
                </div>
            </div>
        </div>
    </div>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
    <script>
        $('#<%= _dialogID %> .searchLearner').keypress(function (event) {
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
                    $.post('<%= Url.Action("AttendeeSelector", "ConsoleEvent", new { _viewModel.StartDate }) %>', { 'userName': userName }, function (data) {
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

        function bookingCoachPI() {
            showLoading();
            $.post('<%= Url.Action("BookingCoachPI", "ConsoleEvent", new { ClassDate = _viewModel.StartDate }) %>', {}, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    swal(data.message);
                } else {
                    $(data).appendTo($('body'));
                }
            });
        }

    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserEvent _model;
    CalendarEventQueryViewModel _viewModel;
    String _dialogID = $"userEvent{DateTime.Now.Ticks}";
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserEvent)this.Model;
        _viewModel = (CalendarEventQueryViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser();
    }


</script>
