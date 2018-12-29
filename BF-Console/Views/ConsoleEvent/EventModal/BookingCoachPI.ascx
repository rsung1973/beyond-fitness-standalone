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
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-body">
                <a class="closebutton" data-dismiss="modal"></a>
                <div class="row clearfix">
                    <div class="col-12">
                        <div class="card action_bar">
                            <div class="header">
                                <h2>預約教練 <%--<span class="col-red"><%= _profile.FullName() %></span>--%> P.I session</h2>
                            </div>
                            <div class="body">
                                <div class="row clearfix">
<%--                                    <div class="col-lg-4 col-md-6 col-sm-6 col-12">
                                        <div class="checkbox">
                                            <input id="repeate_checkbox5" type="checkbox">
                                            <label for="repeate_checkbox5">
                                                週期性
                                            </label>
                                        </div>
                                    </div>
                                    <div class="col-lg-8 col-md-6 col-sm-6 col-12">
                                        <select class="form-control show-tick repeate">
                                            <option value="0">-- 請選擇重複頻率 --</option>
                                            <option value="1">每週一</option>
                                            <option value="2">每週二</option>
                                            <option value="3">每週三</option>
                                            <option value="4">每週四</option>
                                            <option value="5">每週五</option>
                                            <option value="6">每週六</option>
                                            <option value="7">每週日</option>
                                        </select>
                                        <label class="material-icons help-error-text repeate">clear 請選擇重複頻率</label>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12 repeate">
                                        <div class="input-group">
                                            <input type="text" class="form-control date" data-date-format="yyyy/mm/dd" readonly="readonly" placeholder="週期開始日期" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-calendar"></i>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12 repeate">
                                        <div class="input-group">
                                            <input type="text" class="form-control date" data-date-format="yyyy/mm/dd" readonly="readonly" placeholder="週期結束日期" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-calendar"></i>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12 repeate">
                                        <div class="input-group">
                                            <input type="text" class="form-control time" data-date-format="hh:ii" readonly="readonly" placeholder="開始時間" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-time"></i>
                                            </span>
                                        </div>
                                    </div>--%>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12 single">
                                        <div class="input-group">
                                            <input type="text" class="form-control datetime" data-date-format="yyyy/mm/dd hh:ii" readonly="readonly" placeholder="開始時間" name="ClassDate" value="<%= $"{_viewModel.ClassDate:yyyy/MM/dd HH:mm}" %>" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-time"></i>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12" single>
                                        <div>
                                            <select class="form-control show-tick" name="BranchID">
                                                <option value="">-- 請選擇地點 --</option>
                                                <%  var workPlace = models.GetTable<CoachWorkplace>().Where(c => c.CoachID == _profile.UID); %>
                                                <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: _viewModel.BranchID ?? (workPlace.Count()==1 ? workPlace.First().BranchID : -1));    %>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-12">
                                        <label>與誰同行?</label>
                                        <div class="row clearfix">
                                            <div class="col-sm-12">
                                                <%  Html.RenderPartial("~/Views/ConsoleEvent/Module/CoachPIAttendeeSelector.ascx", _viewModel.AttendeeID); %>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-darkteal btn-round waves-effect" onclick="javascript:commitBooking();">確定</button>
            </div>
        </div>
    </div>


    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
    <script>

        function commitBooking() {

            var $formData = $('#<%= _dialogID %> input,select,textarea').serializeObject();
            clearErrors();
            showLoading();
            $.post('<%= _viewModel.LessonID.HasValue
                ? Url.Action("UpdateBookingByCoach","ClassFacet",new { _viewModel.KeyID,_viewModel.CoachID })
                : Url.Action("CommitBookingSelfTraining","Lessons") %>', $formData, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        $global.closeAllModal();
                        refreshEvents();
                        refetchCalendarEvents();
                    }
                    smartAlert(data.message);
                } else {
                    $(data).appendTo('body').remove();
                }
            });
        }

        $(function () {
            equipDatetimePicker();
        });
    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTimeViewModel _viewModel;
    String _dialogID = $"coachPI{DateTime.Now.Ticks}";
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (LessonTimeViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser();
    }


</script>
