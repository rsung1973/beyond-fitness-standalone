<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>
<%@ Register Src="~/Views/Shared/LockScreen.ascx" TagPrefix="uc1" TagName="LockScreen" %>



<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="formContent" runat="server">

    <div class="progress">
        <div class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width: 40%">
            <span class="sr-only">40% Complete (success)</span>
        </div>
    </div>
    <div class="widget-toolbar">

        <div class="progress progress-striped active" rel="tooltip" data-original-title="20%" data-placement="bottom">
            <div class="progress-bar progress-bar-success" role="progressbar" style="width: 20%">20%</div>
        </div>

    </div>

    <%  ViewBag.DataTableId = "my_table";
        Html.RenderPartial("~/Views/Sample/DataTable.ascx"); %>

    <uc1:LockScreen runat="server" ID="LockScreen" />

    <% Html.RenderPartial("~/Views/Shared/HtmlInput.ascx",
               new InputViewModel
               {
                   ErrorMessage = "error",
                   Id = "realName",
                   IsValid = true,
                   Label = "學員姓名：",
                   PlaceHolder = "請輸入姓名",
                   Name = "realName"
               }); %>

    <div class="row">
        <div class="col-md-5">
            <div class="input-group date form_date" data-date="" data-date-format="yyyy/mm/dd" data-link-field="dtp_input1">
                <input class="form-control" size="16" type="text" value="" id="dateFrom" name="dateFrom" readonly />
                <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
            </div>

            <div class="input-group date form_month" id="testDate" data-date-format="yyyy/mm" data-link-field="dtp_input1">
                <input class="form-control" size="16" type="text" value="" id="dateTo" name="dateFrom" readonly />
                <span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
            </div>
        </div>
    </div>

    <% Html.RenderPartial("~/Views/Shared/PieView.ascx"); %>
    <h3>Popover Example</h3>
    <a data-toggle="popover" title="Popover Header" data-content="Some content inside the popover">Toggle popover</a>
    <a tabindex="0" id="test1" data-placement="bottom" class="btn btn-lg btn-danger" role="button" data-toggle="popover" data-trigger="focus" title="Dismissible popover" data-content="And here's some amazing content. It's very engaging. Right?">Dismissible popover</a>
    <a tabindex="0" id="test2" data-placement="bottom" class="btn btn-lg btn-danger" role="button" data-toggle="popover" data-trigger="focus" title="Dismissible popover" data-content="And here's some amazing content. It's very engaging. Right?">Dismissible popover</a>
    <div id="test3" style="display:none;">
        <a onclick="smartAlert('...');">test</a>
    </div>

    <fieldset>
        <section>
            <label class="input">
                <i class="icon-append fa fa-tag"></i>
                <input type="text" name="memberCode" id="memberCode" class="input-lg" maxlength="20" placeholder="請輸入會員編號" />
            </label>
        </section>
    </fieldset>
    <button type="button" id="btnSend" name="submit" class="btn btn-primary">
        送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
    </button>

    <%  ViewBag.Loading = false;    
        Html.RenderPartial("~/Views/Shared/Loading.ascx");
         %>

    <script>
        $('#vip,#m_vip').addClass('active');

        $('#btnSend').on('click', function (evt) {
            $('#theForm')
                .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/MyTest/TestError") %>')
                .submit();
        });

        $(function () {
            //$('#testDate').datetimepicker({
            //    viewMode: 'years',
            //    format: 'YYYY/MM'
            //});
            $('[data-toggle="popover"]').popover();
            //$('#test1').popover('toggle');
            //$('#test2').popover('toggle');
            $('#test3').on('click', function (evt) {
                $(this).css('display', 'none');
            }).css('display', 'block');
        });

    </script>

</asp:Content>
<script runat="server">




    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
    }


</script>
