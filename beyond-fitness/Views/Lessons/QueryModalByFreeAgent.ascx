<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="modal-dialog">
    <div class="modal-content">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
            <h4 class="modal-title" id="searchildLabel"><span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span>搜尋</h4>
        </div>
        <div class="modal-body">
            <div class="form-group">
                <label for="exampleInputFile" class="col-md-2 control-label">起月：</label>
                <div class="col-md-10">
                    <div class="input-group date form_month" data-date="" data-date-format="yyyy/mm/dd" data-link-field="dtp_input1">
                        <input class="form-control" size="16" type="text" value="<%= DateTime.Today.ToString("yyyy/MM/01") %>" id="dateFrom" name="dateFrom" readonly />
                        <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label for="exampleInputFile" class="col-md-2 control-label">查詢區間：</label>
                <div class="col-md-10">
                    <select name="monthInterval" id="monthInterval" class="form-control">
                        <option value="1">1個月</option>
                        <option value="2">2個月</option>
                    </select>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-system btn-sm" id="btnQuery"><span class="glyphicon glyphicon-ok" aria-hidden="true"></span>確認</button>
                <button id="btnDismiss" type="button" class="btn btn-default btn-sm" data-dismiss="modal"><span class="glyphicon glyphicon-log-out" aria-hidden="true"></span>取消</button>
            </div>
        </div>
    </div>
</div>
<script>
    $(function () {

        $('#btnQuery').on('click', function (evt) {
            $('#loading').css('display', 'table');
            $('#dailyBooking').load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/DailyBookingQuery") %>',
                {
                    'dateFrom': $('#dateFrom').val(),
                    'dateTo': $('#dateTo').val(),
                    'monthInterval': $('#monthInterval').val()
                }, function () {
                    $('#queryModal').css('display', 'none');
                    $('#attendeeList').empty();
                    $('.stack-container').css('display', 'none');
                    $('#loading').css('display', 'none');
                });

        });

        $('#btnDismiss').on('click', function (evt) {
            $('#queryModal').css('display', 'none');
        });
    });

</script>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
