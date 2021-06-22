<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="修改課程" class="bg-color-darken">
    <form class="smart-form" id="bookingForm" autofocus>
        <fieldset>
            <div class="row">
                <section class="col col-4">
                    <label class="label">體能顧問</label>
                    <label class="select">
                        <%  if (_model.IsCoachPISession())
                            {   %>
                        <select name="coachID" id="coachID">
                            <option value="<%= _model.AttendingCoach %>"><%= _model.AsAttendingCoach.UserProfile.FullName() %></option>
                        </select>
                        <%  }
                            else
                            {
                                Html.RenderPartial("~/Views/Lessons/SimpleCoachSelector.ascx", new InputViewModel { Id = "CoachID", Name = "CoachID", DefaultValue = _viewModel.CoachID }); 
                            }   %>
                        <i class="icon-append fa fa-user"></i>
                    </label>
                </section>
                <section class="col col-4">
                    <label class="label">請選擇開始時間</label>
                    <label class="input">
                        <i class="icon-append far fa-calendar-alt"></i>
                        <input type="text" name="ClassDate" id="classDate" class="form-control date input_time" data-date-format="yyyy/mm/dd hh:ii" readonly="readonly" value="<%= String.Format("{0:yyyy/MM/dd HH:mm}",_viewModel.ClassDate) %>" placeholder="請輸入上課開始時間" />
                    </label>
                </section>
                <section class="col col-4">
                    <label class="label">請選擇上課地點</label>
                    <label class="select">
                        <select name="BranchID">
                            <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.cshtml", model: _viewModel.BranchID); %>
                        </select>
                        <i class="icon-append far fa-keyboard"></i>
                    </label>
                </section>
            </div>
        </fieldset>
        <%--<fieldset>
            <div class="row">
                <section class="col col-6">
                    <label class="label">請選擇上課長度</label>
                    <label class="select">
                        <select name="Duration" class="input-lg">
                            <option value="60" <%= _viewModel.Duration==60 ? "selected": null %>>60 分鐘</option>
                            <option value="90" <%= _viewModel.Duration==90 ? "selected": null %>>90 分鐘</option>
                        </select>
                        <i class="icon-append far fa-keyboard"></i>
                    </label>
                </section>
            </div>
        </fieldset>--%>
        <input type="hidden" name="LessonID" value="<%= _viewModel.LessonID %>" />
    </form>
    <script>

        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-warning'></i> 修改課程</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
                "class": "btn btn-primary",
                click: function () {
                    var $this = $(this);
                    showLoading();
                    $.post('<%= Url.Action("UpdateBookingByCoach","ClassFacet") %>', $('#bookingForm').serialize(), function (data) {
                        hideLoading();
                        if (data.result) {
                            alert(data.message);
                            if (data.changeCoach) {
                                showLoading();
                                window.location.href = '<%= Url.Action("Index","CoachFacet") %>';
                            } else {
                                $('#classTime').text(data.classTime);
                            }
                            $this.dialog("close");
                        } else {
                            $(data).appendTo($('body')).remove();
                        }
                    });
                }
            }],
            close: function (event, ui) {
                $('#<%= _dialog %>').remove();
            }
        });

        $('.input_time').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            clearBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 1,
            minView: 0,
            minuteStep: 30,
            forceParse: 0,
            startDate: '<%= String.Format("{0:yyyy-MM-dd}",DateTime.Today) %>'
        });
    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTimeViewModel _viewModel;
    LessonTime _model;
    String _dialog;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (LessonTimeViewModel)ViewBag.ViewModel;
        _model = (LessonTime)this.Model;
        _dialog = "bookingDialog" + DateTime.Now.Ticks;
    }

</script>
