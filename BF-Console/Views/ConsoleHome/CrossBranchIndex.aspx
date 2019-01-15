<%@ Page Title="" Language="C#" AutoEventWireup="true" MasterPageFile="~/Views/ConsoleHome/Template/MainPage.Master" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<asp:Content ID="CustomHeader" ContentPlaceHolderID="CustomHeader" runat="server">
    <!-- JQuery DataTable Css -->
    <link href="plugins/jquery-datatable/DataTables-1.10.18/css/dataTables.bootstrap4.min.css" rel="stylesheet">
    <link href="plugins/jquery-datatable/Responsive-2.2.2/css/responsive.bootstrap4.min.css" rel="stylesheet">
    <link href="plugins/jquery-datatable/FixedColumns-3.2.5/css/fixedColumns.bootstrap4.min.css" rel="stylesheet">
    <!-- charts-c3 -->
    <link href="plugins/charts-c3/plugin.css?1.1" rel="stylesheet" />
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Jquery DataTable Plugin Js -->
    <script src="bundles/datatablescripts.bundle.js"></script>
    <script src="plugins/jquery-datatable/Responsive-2.2.2/js/dataTables.responsive.min.js"></script>
    <script src="plugins/jquery-datatable/FixedColumns-3.2.5/js/dataTables.fixedColumns.min.js"></script>
    <!-- ChartC3 Js -->
    <script src="bundles/c3.bundle.js"></script>

    <!--Sparkline Plugin Js-->
    <script src="plugins/jquery-sparkline/jquery.sparkline.js"></script>
    <section class="content">

        <%  ViewBag.BlockHeader = "跨店審核";
            Html.RenderPartial("~/Views/ConsoleHome/Module/BlockHeader.ascx", _model); %>
        <!--清單資料-->
        <div class="container-fluid">
            <div class="row clearfix">
                <div class="col-12">
                    <div class="card patients-list">
                        <div class="body">
                            <div class="p-15 xl-slategray">
                                <span class="m-r-20"><i class="zmdi zmdi-label col-amber m-r-5"></i>P.T session</span>
                                <span class="m-r-20"><i class="zmdi zmdi-label col-pink m-r-5"></i>P.I session</span>
                                <span class="m-r-20"><i class="zmdi zmdi-label col-purple m-r-5"></i>體驗 session</span>
                            </div>
                            <div class="table-responsive">
                                <%  
                                    Html.RenderPartial("~/Views/LessonConsole/Module/CrossBranchLessonList.ascx", _model.PreferredLessonTimeToApprove(models)); %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- #END# Basic Examples -->
        </div>
    </section>
</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">

    <script>

        $(function() {
            $.scrollUp({
                animation: 'fade',
                scrollImg: {
                    active: true,
                    type: 'background',
                    src: 'images/top.png'
                }
            });
            //$(".ls-toggle-btn").click();
        });

        function processCrossBranch(keyID) {
            //showLoading();
            $.post('<%= Url.Action("ProcessCrossBranch", "LessonConsole") %>', { 'keyID': keyID }, function (data) {
                //hideLoading();
                if ($.isPlainObject(data)) {
                    alert(data.message);
                } else {
                    $(data).appendTo($('body'));
                }
            });
        }

        function showBarChart() {
            //showLoading();
            $.post('<%= Url.Action("ShowTodayLessons", "LessonConsole") %>', { }, function (data) {
                //hideLoading();
                if ($.isPlainObject(data)) {
                    alert(data.message);
                } else {
                    $(data).appendTo($('body'));
                }
            });
        }

        //點選審核
        this.approveLesson = function (keyID) {
            deleteData(function (onSuccess) {
                showLoading();
                $.post('<%= Url.Action("CommitCrossBranch", "LessonConsole") %>', { 'keyID': keyID }, function (data) {
                    hideLoading();
                    if ($.isPlainObject(data)) {
                        if (data.result) {
                            onSuccess();
                        } else {
                            swal(data.message);
                        }
                    } else {
                        $(data).appendTo($('body'));
                    }
                });
            },
                {
                    text: "完成審核後資料將無法回覆!",
                    confirmButtonText: "確定, 審核通過",
                    cancelButtonText: "不, 點錯了",
                    confirmed: ['已審核成功!', '資料已經更新 Bye!', 'success'],
                    cancelled: ['取消成功', '你的資料現在非常安全 :)', 'error'],
                    afterConfirmed: function () {
                        window.location.href = '<%= VirtualPathUtility.ToAbsolute("~/ConsoleHome/Index") %>';
                    },
                });
        };

        // MINI LINE CHARTS
        var paramsBar = {
            type: 'bar',
            barWidth: 10,
            barSpacing: 5,
            width: '500px',
            height: '50px',
            barColor: '#18ce0f',
            stackedBarColor: ["#FFC107", "#ba3bd0", "#F15F79"]
        };

    </script>
</asp:Content>

<script runat="server">
    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    IQueryable<LessonTime> _lessons;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;

        IQueryable<LessonTime> items = models.GetTable<LessonTime>().FilterByUserRoleScope(models, _model);
        ViewBag.LessonTimeItems = items;

        _lessons = items.PTLesson()
            .Union(items.Where(l => l.TrainingBySelf == 1))
            .Union(items.TrialLesson());

        //items = models.GetTable<LessonTime>().FilterByUserRoleScope(models, _model);
    }

</script>
