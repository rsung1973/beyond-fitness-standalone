<%@ Page Title="" Language="C#" AutoEventWireup="true" MasterPageFile="~/Views/ConsoleHome/Template/MainPage.Master"  Inherits="System.Web.Mvc.ViewPage" %>

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
    <!-- Morris Plugin Js -->
    <link rel="stylesheet" href="plugins/morrisjs/morris.min.css" />
    <!-- JQuery DataTable Css -->
    <link href="plugins/jquery-datatable/DataTables-1.10.18/css/dataTables.bootstrap4.min.css" rel="stylesheet">
    <link href="plugins/jquery-datatable/Responsive-2.2.2/css/responsive.bootstrap4.min.css" rel="stylesheet">
    <link href="plugins/jquery-datatable/FixedColumns-3.2.5/css/fixedColumns.bootstrap4.min.css" rel="stylesheet">

</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<section class="content">
    <%  ViewBag.BlockHeader = "本月運動時間";
        Html.RenderPartial("~/Views/ConsoleHome/Module/BlockHeader.ascx", _model); %>
    <!--本月排名-->
        <div class="container-fluid">
            <div class="row clearfix">
                <div class="col-md-7 col-sm-12 col-12">
                    <div class="card">
                        <div class="header">
                            <h2><strong class="col-red">即時</strong> 排行榜</h2>
                            <ul class="header-dropdown">
                                <li class="dropdown">
                                    <a href="javascript:void(0);" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="zmdi zmdi-more"></i></a>
                                    <ul class="dropdown-menu dropdown-menu-right slideUp float-right">
                                        <li><a href="javascript:inquireBillboard();">全部</a></li>
                                        <%  foreach (var b in models.GetTable<BranchStore>())
                                            {   %>
                                        <li><a href="javascript:inquireBillboard(<%= b.BranchID %>);"><%= b.BranchName %></a></li>
                                        <%  } %>
                                    </ul>
                                </li>
                            </ul>
                        </div>
                        <div class="body">
                            <div class="row clearfix" id="currentMonth">
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-5 col-sm-12 col-12">
                    <div class="card">
                        <div class="header">
                            <h2><strong>上月</strong> 排行榜</h2>
                        </div>
                        <div class="body" id="lastMonth">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!--本月排名清單-->
        <div class="container-fluid">
            <div class="row clearfix">
                <h4 class="card-outbound-header m-l-15">排行榜清單</h4>
                <div class="col-md-12">
                    <div class="card patients-list">
                        <div class="body">
                            <div class="p-15 xl-slategray">
                                <span class="m-r-20"><i class="zmdi zmdi-label col-amber m-r-5"></i>基本</span>
                                <span class="m-r-20"><i class="zmdi zmdi-label col-pink m-r-5"></i>運動技巧</span>
                                <span class="m-r-20"><i class="zmdi zmdi-label col-green m-r-5"></i>肌力</span>
                                <span class="m-r-20"><i class="zmdi zmdi-label col-blue m-r-5"></i>心肺</span>
                                <span class="m-r-20"><i class="zmdi zmdi-label col-yellow m-r-5"></i>恢復</span>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-striped table-custom m-b-0 nowrap dataTable-exerciserankList" style="width:100%">
                                    <thead class="bg-darkteal">
                                        <tr>
                                            <th>姓名</th>
                                            <th>分店</th>
                                            <th>本月運動 <small>小時:分鐘</small></th>
                                            <th>階段佔比</th>
                                            <th>排名</th>
                                        </tr>
                                    </thead>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">
    <!-- Jquery DataTable Plugin Js -->
    <script src="bundles/datatablescripts.bundle.js"></script>
    <script src="plugins/jquery-datatable/Responsive-2.2.2/js/dataTables.responsive.min.js"></script>
    <script src="plugins/jquery-datatable/FixedColumns-3.2.5/js/dataTables.fixedColumns.min.js"></script>
    <!-- Sparkline Plugin Js -->
    <script src="plugins/jquery-sparkline/jquery.sparkline.js"></script>

    <script>
        var dtExerciserankList;
        $(function () {

            dtExerciserankList = $('.dataTable-exerciserankList').DataTable({
                "ajax": '<%--<%= Url.Action("GetExerciseBillboardDetails","ConsoleHome") %>--%>',
                "order": [
                    [4, 'asc']
                ],
                "bPaginate": false, //翻頁功能
                "bInfo": true,//頁尾資訊
                "searching": false,  //搜尋框，不顯示
                "language": {
                    "lengthMenu": "每頁顯示 _MENU_ 筆資料",
                    "zeroRecords": "沒有資料也是種福氣",
                    "info": "共 _TOTAL_ 筆，目前顯示第 _START_ 至 _END_筆資料",
                    "infoEmpty": "顯示 0 到 0 筆的資料",
                    "infoFiltered": "(總共從 _MAX_ 筆資料過濾)",
                    "loadingRecords": "快馬加鞭處理中...",
                    "processing": "快馬加鞭處理中...",
                    "search": "快速搜尋：",
                    "paginate": {
                        "first": "第一頁",
                        "last": "最後一頁",
                        "next": "下一頁",
                        "previous": "前一頁"
                    },
                },
                scrollX: true,
                scrollCollapse: true,
                fixedColumns: {
                    leftColumns: 1,
                },
                "columnDefs": [
                    {
                        targets: [1, 2, 3],
                        className: "align-center"

                    }
                ],
                "initComplete": function () {
                    //$('.sparkline-pie').sparkline('html', {
                    //    type: 'pie',
                    //    offset: 90,
                    //    width: '50px',
                    //    height: '50px',
                    //    sliceColors: ['rgba(245, 166, 35, .8)', 'rgba(74, 144, 226, .8)', 'rgba(126, 211, 33, .8)', 'rgba(255, 78, 100, .8)', 'rgba(244, 237, 0, .8)']
                    //});
                }
            });

            dtExerciserankList.on('draw', function () {
                var $pie = $('.sparkline-pie')
                    .filter(function (idx, elment) {
                        return $('canvas', this).length === 0;
                    }).sparkline('html', {
                        type: 'pie',
                        offset: 90,
                        width: '50px',
                        height: '50px',
                        sliceColors: ['rgba(245, 166, 35, .8)', 'rgba(74, 144, 226, .8)', 'rgba(126, 211, 33, .8)', 'rgba(255, 78, 100, .8)', 'rgba(244, 237, 0, .8)']
                    });
            });

        });


        $(function () {
            inquireBillboard();
        });

        function inquireBillboard(branchID) {

            showLoading();
            $.post('<%= Url.Action("InquireExerciseBillboard", "ConsoleHome") %>', { 'branchID': branchID }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    alert(data.message);
                } else {
                    $('#currentMonth').empty()
                        .append(data);
                }
            });

            $.post('<%= Url.Action("InquireExerciseBillboardLastMonth", "ConsoleHome") %>', { 'branchID': branchID }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    alert(data.message);
                } else {
                    $('#lastMonth').empty()
                        .append(data);
                }
            });

            dtExerciserankList.ajax.url('<%= Url.Action("GetExerciseBillboardDetails","ConsoleHome") %>?branchID=' + branchID);
            dtExerciserankList.ajax.reload(function (jsonData) {
                dtExerciserankList.draw();
                $('div.btn-group.bootstrap-select.form-control.form-control-sm').after($('div.btn-group.bootstrap-select.form-control.form-control-sm select'));
                $('div.btn-group.bootstrap-select.form-control.form-control-sm').remove();
            }, true);

        }

    </script>
</asp:Content>


<script runat="server">
    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    IQueryable<LessonTime> _lessons;
    IQueryable<LessonTime> _learnerLessons;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        var items = models.GetTable<LessonTime>().Where(l => l.AttendingCoach == _model.UID);
        _lessons = items.PTLesson()
            .Union(items.Where(l => l.TrainingBySelf == 1))
            .Union(items.TrialLesson());

        _learnerLessons = items.PTLesson()
            .Union(items.Where(l => l.TrainingBySelf == 1));

    }

</script>
