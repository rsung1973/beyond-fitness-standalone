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
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <a class="closebutton" data-dismiss="modal"></a>
            <div class="modal-body">
                <div class="row clearfix">
                    <div class="col-12">
                        <div class="card action_bar">
                            <div class="header">
                                <h2>自訂個人行事曆</h2>
                            </div>
                            <div class="body">
                                <div class="row clearfix">
<%--                                    <div class="col-lg-4 col-md-6 col-sm-6 col-12">
                                        <div class="checkbox">
                                            <input id="repeate_checkbox4" type="checkbox">
                                            <label for="repeate_checkbox4">
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
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12 repeate">
                                        <div class="input-group">
                                            <input type="text" class="form-control time" data-date-format="hh:ii" readonly="readonly" placeholder="結束時間" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-time"></i>
                                            </span>
                                        </div>
                                    </div>--%>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12 single">
                                        <div class="input-group">
                                            <input type="text" class="form-control datetime" data-date-format="yyyy/mm/dd hh:ii" readonly="readonly" placeholder="開始時間" name="StartDate" value="<%= $"{_viewModel.StartDate:yyyy/MM/dd HH:mm}" %>" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-time"></i>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12 single">
                                        <div class="input-group">
                                            <input type="text" class="form-control datetime" data-date-format="yyyy/mm/dd hh:ii" readonly="readonly" placeholder="結束時間" name="EndDate" value="<%= $"{_viewModel.EndDate:yyyy/MM/dd HH:mm}" %>" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-time"></i>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                                        <select class="form-control show-tick" name="Title">
                                            <option value="請選擇">--請選擇個人行程類別--</option>
                                            <option <%= _viewModel.Title=="會議" ? "selected": null %>>會議</option>
                                            <%--<option <%= _viewModel.Title=="團練" ? "selected": null %>>團練</option>--%>
                                            <option <%= _viewModel.Title=="其他" ? "selected": null %>>其他</option>
                                        </select>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                                        <div>
                                            <select class="form-control show-tick" name="BranchID">
                                                <option value="<%= Naming.BranchName.請選擇 %>">-- 請選擇地點 --</option>
                                                <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: (int?)_viewModel.BranchID);    %>
                                                <option value="<%= Naming.BranchName.璞真 %>" <%= _viewModel.Place == Naming.BranchName.璞真.ToString() ? "selected" : null %>>璞真</option>
                                                <option value="<%= Naming.BranchName.其他 %>" <%= _viewModel.Place == Naming.BranchName.其他.ToString() ? "selected" : null %>>其他</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-12">
                                        <div class="form-group<%-- has-danger--%>">
                                            <div class="form-line">
                                                <textarea rows="1" name="ActivityProgram" class="form-control no-resize" placeholder="輸入任何你想輸入的自訂行程..."><%= _viewModel.ActivityProgram %></textarea>
                                                <%--<label class="material-icons help-error-text">clear 此欄位一定要輸入喔！</label>--%>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-12">
                                        <label>與誰同行?</label>
                                        <div class="row clearfix">
                                            <div class="col-sm-12">
                                                <select name="MemberID" class="ms employeegroup" multiple="multiple">
                                                    <optgroup label="其他">
                                                        <%  var roles = models.GetTable<UserRoleAuthorization>().Where(r => r.RoleID == (int)Naming.RoleID.Assistant);
                                                            var users = models.GetTable<UserProfile>()
                                                                    .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                                                                    .Where(u => roles.Any(r => r.UID == u.UID));
                                                            foreach (var u in users)
                                                            {   %>
                                                        <option value="<%= u.UID %>"><%= u.FullName() %></option>
                                                        <%  }   %>
                                                    </optgroup>                                                    
                                                    <%  foreach (var branch in models.GetTable<BranchStore>())
                                                        {   %>
                                                    <optgroup label="<%= branch.BranchName %>">
                                                        <%  var items = models.GetTable<CoachWorkplace>().Where(w => w.BranchID == branch.BranchID)
                                                                .Select(w => w.ServingCoach)
                                                                .Where(s => s.CoachID != _profile.UID)
                                                                .Where(s => s.UserProfile.LevelID == (int)Naming.MemberStatusDefinition.Checked);
                                                            Html.RenderPartial("~/Views/SystemInfo/ServingCoachOptions.ascx",items);
                                                            %>
                                                    </optgroup>
                                                    <%  }   %>
                                                </select>
                                            </div>
                                            <div class="col-sm-12">
                                                <div class="form-line">
                                                    <textarea rows="1" name="Accompanist" class="form-control no-resize" placeholder="或輸入其他玩伴..." maxlength="20"><%= _viewModel.Accompanist %></textarea>
                                                </div>
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
            $.post('<%= Url.Action("CommitCoachEvent","CoachFacet",new { UID = _viewModel.UID,EventID = _viewModel.EventID }) %>', $formData, function (data) {
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
            $('.employeegroup').multiSelect();

    <%  if (_viewModel.MemberID != null && _viewModel.MemberID.Length > 0)
        {   %>
            $('.employeegroup').multiSelect('select',<%= JsonConvert.SerializeObject(_viewModel.MemberID.Select(m=>m.ToString())) %>);
    <%  }   %>
        });
    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserEventViewModel _viewModel;
    String _dialogID = $"customEvent{DateTime.Now.Ticks}";
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (UserEventViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser();
    }


</script>
