<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<form action="<%= Url.Action("CommitCoachEvent","CoachFacet",new { UID = _viewModel.UID,EventID = _viewModel.EventID }) %>" method="post" class="smart-form" id="coachEventForm">
    <fieldset>
        <div class="row">
            <section class="col col-6">
                <label class="label">請選擇個人行程類別</label>
                <label class="select">
                    <select name="Title">
                        <option <%= _viewModel.Title=="會議" ? "selected": null %>>會議</option>
                        <option <%= _viewModel.Title=="團練" ? "selected": null %>>團練</option>
                        <option <%= String.IsNullOrEmpty(_viewModel.Title) ? "selected": null %> value="">其他</option>
                    </select>
                    <i class="icon-append far fa-clock"></i>
                </label>
            </section>
            <section class="col col-6">
                <label class="label">請選擇地點</label>
                <label class="select">
                    <select name="BranchID">
                        <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.cshtml", model: _viewModel.BranchID); %>
                        <option value="" <%= !_viewModel.BranchID.HasValue ? "selected": null %>>其他</option>
                    </select>
                    <i class="icon-append far fa-keyboard"></i>
                </label>
            </section>
        </div>
        <div>
            <section>
                <label class="label">請輸入行事曆內容</label>
                <label class="input">
                    <i class="icon-append far fa-keyboard"></i>
                    <input type="text" name="ActivityProgram" maxlength="10" placeholder="請輸入行事曆內容" value="<%= _viewModel.ActivityProgram %>" />
                </label>
            </section>
        </div>
    </fieldset>
    <fieldset>
        <div class="row">
            <section class="col col-6">
                <label class="label">請選擇開始時間</label>
                <label class="input">
                    <input type="text" name="StartDate" class="form-control date input_time" data-date-format="yyyy/mm/dd hh:ii" value="<%= String.Format("{0:yyyy/MM/dd HH:mm}",_viewModel.StartDate) %>" placeholder="請選擇開始時間" />
                    <i class="icon-append far fa-clock"></i>
                </label>
            </section>
            <section class="col col-6">
                <label class="label">請選擇結束時間</label>
                <label class="input">
                    <input type="text" name="EndDate" class="form-control date input_time" data-date-format="yyyy/mm/dd hh:ii" value="<%= String.Format("{0:yyyy/MM/dd HH:mm}",_viewModel.EndDate) %>" placeholder="請選擇結束時間" />
                    <i class="icon-append far fa-clock"></i>
                </label>
            </section>
        </div>
    </fieldset>
    <fieldset>
        <div class="row">
            <label class="label">請選擇與會人員：</label>
        </div>
        <%
            var items = models.GetTable<UserProfile>()
                .Where(s => s.UID != _viewModel.UID)
                .Where(s => s.ServingCoach != null
                    || s.UserRole.Any(r => r.RoleID == (int)Naming.RoleID.Administrator)
                    || s.UserRole.Any(r => r.RoleID == (int)Naming.RoleID.Accounting)
                    || s.UserRole.Any(r => r.RoleID == (int)Naming.RoleID.Assistant)
                    || s.UserRole.Any(r => r.RoleID == (int)Naming.RoleID.Officer)
                    || s.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Administrator)
                    || s.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Accounting)
                    || s.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Assistant)
                    || s.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Officer))
                .ToArray();
            int idx = 0;
            for (int row = 0; row < (items.Length + 2) / 3; row++)
            {
                %>
                <div class="row">
        <%
                for (int col = 0; col < 3 && idx<items.Length; col++)
                {
                %>
                    <div class="col col-4">
                        <label class="checkbox">
                            <input type="checkbox" name="MemberID" value="<%= items[idx].UID %>" <%= _viewModel.MemberID!=null && _viewModel.MemberID.Contains(items[idx].UID) ? "checked" : null %> />
                            <i></i><%= items[idx].FullName() %></label>
                    </div>
                    <%
                    idx++;
                }   %>
                </div>
            <%
            }
             %>
        <div class="row">
            <div class="col col-2">
                <label class="label">其他</label>
            </div>
            <div class="col col-8">
                <label class="input">
                    <input type="text" name="Accompanist" maxlength="100" placeholder="請輸入與會人員" value="<%= _viewModel.Accompanist %>" />
                </label>
            </div>
        </div>
    </fieldset>
    <script>

        $(function () {
            $global.commitCoachEvent = function (callback) {

                $('#coachEventForm').ajaxSubmit({
                    success: function (data) {
                        if (data.result) {
                            smartAlert(data.message);
                            callback();
                        } else {
                            $(data).appendTo('body').remove();
                        }
                    }
                });
            };
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
            forceParse: 0
        });
    </script>
</form>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserEventViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (UserEventViewModel)ViewBag.ViewModel;

    }

</script>
