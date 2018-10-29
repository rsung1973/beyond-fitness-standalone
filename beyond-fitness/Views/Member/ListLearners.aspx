<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <div id="ribbon">
        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-user"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>人員管理></li>
            <li>學員管理</li>
            <li>學員列表</li>
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
        <i class="fa-fw fa fa-user"></i>學員管理
                            <span>>  
                                學員列表
                            </span>
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">

        <!-- NEW WIDGET START -->
        <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">

            <!-- Widget ID (each widget will need unique ID)-->
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
                    <ul id="learnerListTab" class="nav nav-tabs pull-right">
                        <li class="<%= ViewBag.TabIndex!=1 ? "active" : null %>">
                            <a data-toggle="tab" href="#learnerListTab_0"><span class="badge bg-color-blue txt-color-white"><i class="fa fa-user"></i></span>正式學員</a>
                        </li>
                        <li class="<%= ViewBag.TabIndex==1 ? "active" : null %>">
                            <a data-toggle="tab" href="#learnerListTab_1"><span class="badge bg-color-blue txt-color-white"><i class="fa fa-magic"></i></span>體驗學員</a>
                        </li>
                    </ul>
                    <span class="widget-icon"><i class="fa fa-table"></i></span>
                    <h2>學員列表</h2>
                    <div class="widget-toolbar">
                        <a href="<%= Url.Action("AddLearner","Member") %>" class="btn btn-primary"><i class="fa fa-fw fa-user-plus"></i>新增正式學員</a>
                        <a href="<%= Url.Action("AddLearner","Member",new { currentTrial = 1 }) %>" class="btn bg-color-pink"><i class="fa fa-fw fa-user-plus"></i>新增體驗學員</a>
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
                    <div class="widget-body no-padding">
                        <div id="learnerListTabContent" class="tab-content padding-10">
                            <div class="tab-pane fade <%= ViewBag.TabIndex!=1 ? "active in" : null %> " id="learnerListTab_0">
                                <%   Html.RenderPartial("~/Views/Member/Module/NormalLearnerList.ascx", _items); %>
                            </div>
                            <div class="tab-pane fade <%= ViewBag.TabIndex==1 ? "active in" : null %> " id="learnerListTab_1">
                                <%   Html.RenderPartial("~/Views/Member/Module/TrialLearnerList.ascx", _items); %>
                            </div>
                        </div>
                    </div>
                    <!-- end widget content -->
                </div>
                <!-- end widget div -->
            </div>
            <!-- end widget -->
        </article>
        <!-- WIDGET END -->

    </div>

    <script>

        function deleteLearner(uid) {
            $.SmartMessageBox({
                title: "<i class=\"fa fa-fw far fa-trash-alt\" aria-hidden=\"true\"></i> 刪除學員",
                content: "確定刪除此學員資料?",
                buttons: '[刪除][取消]'
            }, function (ButtonPressed) {
                if (ButtonPressed == "刪除") {
                    $('<form method="post"/>').appendTo($('body'))
                        .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Member/Delete") %>' + '?uid=' + uid)
                        .submit();
                }
            });
        }

        function applyToFormal(uid) {

            var event = event || window.event;
            var $tr = $(event.target).closest('tr');

            $.SmartMessageBox({
                title: "<i class=\"fa fa-fw fa fa-reply-all\" aria-hidden=\"true\"></i> 轉至正式學員",
                content: "確定轉至此學員資料?",
                buttons: '[確定][取消]'
            }, function (ButtonPressed) {
                if (ButtonPressed == "確定") {
                    $('<form method="post"/>').appendTo($('body'))
                        .prop('action', '<%= Url.Action("ApplyToFormal","Member") %>' + '?uid=' + uid)
                        .submit();
                }
            });
        }

        $('.nav-tabs').on('shown.bs.tab', function (evt) {
            //console.log(evt.target);
            //console.log(evt.relatedTarget);
            startLoading();
            if ($(evt.target).prop('id') == 'toggleLearner') {
                $.post('<%= VirtualPathUtility.ToAbsolute("~/Member/ChangeRoleList") %>', { 'roleID' : <%= (int)Naming.RoleID.Coach  %>},function(data) {
                    $('#loading').css('display', 'none');
                    $('#searchdil').modal('show');
                });
            } else if ($(evt.target).prop('id') == 'toggleCoach') {
                $.post('<%= VirtualPathUtility.ToAbsolute("~/Member/ChangeRoleList") %>', { 'roleID' : <%= (int)Naming.RoleID.Coach  %>},function(data) {
                    $('#loading').css('display', 'none');
                });
            }
        });

    $('#btnQuery').on('click', function (evt) {
        $('#loading').css('display', 'table');
        $('#tab-learner').load('<%= VirtualPathUtility.ToAbsolute("~/Member/ListLearners") %>', { 'byName': $('input[name="byName"]').val() }, function () {
            $('#searchdil').modal('hide');
            $('#loading').css('display', 'none');
        });
    });

    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    IQueryable<UserProfile> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _items = (IQueryable<UserProfile>)this.Model;
    }




</script>
