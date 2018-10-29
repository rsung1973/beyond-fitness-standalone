<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="modal-dialog">
    <div class="modal-content">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                &times;
            </button>
            <h4 class="modal-title" id="myModalLabel">查詢學員</h4>
        </div>
        <div class="modal-body bg-color-darken txt-color-white">
            <form class="smart-form">
                <fieldset>
                    <div class="row">
                        <section class="col col-8">
                            <label class="input">
                                <i class="icon-append fa fa-search"></i>
                                <input type="text" name="userName" maxlength="20" placeholder="請輸入學員姓名" />
                            </label>
                        </section>
                        <section class="col col-4">
                            <button id="btnQuery" class="btn bg-color-blue btn-sm" type="button">查詢</button>
                        </section>
                    </div>
                </fieldset>
                <fieldset id="userList">
                </fieldset>

                <footer>
                    <button id="btnAttending" type="button" class="btn btn-primary">
                        送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                    </button>
                    <button id="btnDismiss" type="button" class="btn btn-default" data-dismiss="modal">
                        取消
                    </button>
                </footer>
            </form>
        </div>
    </div>
</div>
<script>
    $('#btnAttending').on('click', function (evt) {
        var $items = $('input[name="UID"]:checked');
        if ($items.length <= 0) {
            smartAlert('請勾選上課學員!!');
            return;
        }
        $('#attendee').empty();
        $('#queryAttendee').val($items.parent().text().replace(/./g,function(x) { return x.charCodeAt(0)==32 ? '' : x; }));
        $items.prop('type', 'hidden')
            .appendTo($('#attendee'));
        $('#btnDismiss').trigger('click');

<%--        $('form').prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Member/ApplyGroupLessons") %>')
            .submit();--%>
    });

    $('#btnQuery').on('click', function (evt) {
        //$('#loading').css('display', 'table');
        showLoading(true);
        var userName = $('input[name="userName"]').val();
        $('#userList').load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/VipSelector") %>', { 'userName': userName }, function () {
            //$('#loading').css('display', 'none');
            hideLoading();
        });
    });

</script>


<script runat="server">

    ModelStateDictionary _modelState;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        var models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
