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

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-dollar-sign"></i>
            </span>
        </span>
        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>人員管理></li>
            <li>學員管理</li>
            <li>維護付款紀錄</li>
        </ol>
        <!-- end breadcrumb -->

        <!-- You can also add more buttons to the
                ribbon for further usability

                Example below:

                <span class="ribbon-button-alignment pull-right">
                <span id="search" class="btn btn-ribbon hidden-xs" data-title="search"><i class="fa-grid"></i> Change Grid</span>
                <span id="add" class="btn btn-ribbon hidden-xs" data-title="add"><i class="fa-plus"></i> Add</span>
                <span id="search" class="btn btn-ribbon" data-title="search"><i class="fa-search"></i> <span class="hidden-mobile">Search</span></span>
                </span> -->

    </div>
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-dollar-sign"></i>學員管理
               <span>>  
               維護付款紀錄
               </span>
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">

        <article class="col-xs-12 col-sm-12 col-md-9 col-lg-9">
            <div class="jarviswidget jarviswidget-color-darken" id="wid-id-1" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
                <!-- widget options:
                                usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">

                                data-widget-colorbutton="false"
                                data-widget-editbutton="false"
                                data-widget-togglebutton="false"
                                data-widget-deletebutton="false"
                                data-widget-fullscreenbutton="false"
                                data-widget-custombutton="false"
                                data-widget-collapsed="true"
                                data-widget-sortable="false"

                                -->
                <header>
                    <span class="widget-icon"><i class="fa fa-table"></i></span>
                    <h2>付款紀錄列表</h2>
                    <div class="widget-toolbar">
                        <a onclick="javascript:payInstallment(<%= _item.RegisterID %>);" class="btn btn-primary" data-toggle="modal" data-target="#addPay"><i class="fa fa-fw fa-plus"></i> 新增付款紀錄</a>
                    </div>                
                </header>

                <!-- widget div-->
                <div>
                    <!-- widget edit box -->
                    <div class="jarviswidget-editbox">
                        <!-- This area used as dropdown edit box -->
                    </div>
                    <!-- end widget edit box -->

                    <!-- widget content -->
                    <div id="tuitionChargeItem" class="widget-body no-padding">
                        <%  Html.RenderPartial("~/Views/Member/Tuition/Module/TuitionCharge.ascx", _item); %>
                    </div>
                </div>
                <!-- end widget div -->

            </div>

        </article>

        <article class="col-xs-12 col-sm-12 col-md-3 col-lg-3">
            <!-- /well -->
            <div class="well bg-color-darken txt-color-white padding-10">
                <h5 class="margin-top-0"><i class="fa fa-external-link"></i>快速功能</h5>
                <ul class="no-padding no-margin">
                    <ul class="icons-list">
                        <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ListLearners.ascx"); %>
                        <%--<%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ViewLessons.ascx",_model); %>--%>
                        <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/AddPDQ.ascx",_model); %>
                        <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/LearnerFitness.ascx",_model); %>
                        <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ShowLearner.ascx",_model); %>
                        <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/EditLearner.ascx",_model); %>
                        <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/Overview.ascx"); %>
                        <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ViewVip.ascx",_model); %>
                    </ul>
                </ul>
            </div>
        </article>

    </div>


    <script>

        function payInstallment(registerID) {
            $.post('<%= Url.Action("PaySingleInstallment","Member") %>', { 'registerID': registerID }, function (data) {
                $(data).appendTo($('#content'));
            });
        }

        function shareInstallment(id) {
            $.post('<%= Url.Action("TuitionAchievementShare","Member") %>', { 'installmentID': id }, function (data) {
                $(data).appendTo($('#content'));
            });
        }

        function deletePayment(id) {
            var event = event || window.event;
            confirmIt({ title: '刪除付款記錄', message: '確定刪除此刪除付款記錄?' }, function (evt) {
                showLoading();
                $.post('<%= Url.Action("DeleteTuitionPayment","Member") %>', { 'installmentID': id }, function (data) {
                    hideLoading();
                    if (data.result) {
                        $(event.target).closest('tr').remove();
                    } else {
                        smartAlert(data.message);
                    }
                });
            });
        }

        function deleteAchievementShare(installmentID,coachID) {
            var event = event || window.event;
            confirmIt({ title: '刪除業績所屬體能顧問', message: '確定刪除此業績所屬體能顧問?' }, function (evt) {
                showLoading();
                $.post('<%= Url.Action("DeleteAchievementShare","Member") %>', { 'installmentID': installmentID,'coachID':coachID }, function (data) {
                    hideLoading();
                    if (data.result) {
                            if ($global.reload) {
                                $global.reload();
                            }
                        //smartAlert("資料已刪除!!", function () {
                        //});
                    } else {
                        smartAlert(data.message);
                    }
                });
            });
        }

        $(function () {

            $global.reload = function () {
                showLoading(true);
                $('#tuitionChargeItem').load('<%= Url.Action("TuitionCharge","Member",new { id = _item.RegisterID }) %>', function () {
                    hideLoading();
                });
            };

            $('body').scrollTop(screen.height);

        });

    </script>
    <% Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>
</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    IntuitionCharge _item;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _item = (IntuitionCharge)ViewBag.DataItem;

    }

</script>
