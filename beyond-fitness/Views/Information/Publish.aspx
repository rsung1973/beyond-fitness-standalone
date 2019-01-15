<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage2017.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>
<%@ Register Src="~/Views/Shared/PagingControl.ascx" TagPrefix="uc1" TagName="PagingControl" %>



<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">

    <span class="ribbon-button-alignment">
        <span id="refresh" class="btn btn-ribbon">
            <i class="fa fa-puzzle-piece"></i>
        </span>
    </span>

    <!-- breadcrumb -->
    <ol class="breadcrumb">
        <li>上稿管理></li>
        <li>專業知識</li>
        <li>專業知識列表</li>
    </ol>
    <!-- end breadcrumb -->

</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <section id="widget-grid" class="">
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
                        <span class="widget-icon"><i class="fa fa-table"></i></span>
                        <h2>文章列表</h2>
                        <div class="widget-toolbar">
                            <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/CreateNew") %>" class="btn btn-primary"><i class="fa fa-fw fa-pencil-alt"></i>新增文章</a>
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

                            <table id="dt_basic" class="table table-striped table-bordered table-hover" width="100%">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th data-class="expand">時間</th>
                                        <th>標題</th>
                                        <th data-hide="phone"><i class="fa fa-fw fa-user text-muted hidden-md hidden-sm hidden-xs"></i>作者</th>
                                        <th data-hide="phone">功能</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rpList" runat="server" ItemType="WebHome.Models.DataEntity.Article">
                                        <ItemTemplate>
                                            <tr>
                                                <td><%# Container.ItemIndex+1 %></td>
                                                <td><%# Item.Document.DocDate.ToString("yyyy/MM/dd") %></td>
                                                <td>《<%# Item.Title %>》</td>
                                                <td><%# Item.AuthorID.HasValue ? Item.UserProfile.RealName : null %></td>
                                                <td>
                                                    <div class="btn-group dropup">
                                                        <button class="btn bg-color-blueLight" data-toggle="dropdown">
                                                            請選擇功能
                                                        </button>
                                                        <button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                                                            <span class="caret"></span>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a href="<%# VirtualPathUtility.ToAbsolute("~/Information/EditBlog/"+Item.DocID) %>"><i class="fa fa-fw fa fa-edit" aria-hidden="true"></i>修改</a>
                                                            </li>
                                                            <li>
                                                                <a onclick='<%# "javascript:deleteArticle(" + Item.DocID + ");" %>' class="deletedata"><i class="fa fa-fw far fa-trash-alt" aria-hidden="true"></i>刪除</a>
                                                            </li>
                                                            <li>
                                                                <%--<a href="<%# VirtualPathUtility.ToAbsolute("~/Information/BlogDetail/"+Item.DocID) %>" target="_blank"><i class="fa fa-fw fa fa-eye" aria-hidden="true"></i>檢視資料</a>--%>
                                                                <a href="<%# "../../../front-end/single-post.html?id=" + Item.DocID %>" target="_blank"><i class="fa fa-fw fa fa-eye" aria-hidden="true"></i>檢視資料</a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                        <!-- end widget content -->

                    </div>
                    <!-- end widget div -->

                </div>
                <!-- end widget -->
            </article>
            <!-- WIDGET END -->

        </div>

    </section>



    <!-- PAGE RELATED PLUGIN(S) -->

    <script>
        $('#vip,#m_vip').addClass('active');

        $(function () {
            /* // DOM Position key index //
        
            l - Length changing (dropdown)
            f - Filtering input (search)
            t - The Table! (datatable)
            i - Information (records)
            p - Pagination (paging)
            r - pRocessing 
            < and > - div elements
            <"#id" and > - div with an id
            <"class" and > - div with a class
            <"#id.class" and > - div with an id and class
            
            Also see: http://legacy.datatables.net/usage/features
            */

            /* BASIC ;*/
            var responsiveHelper_dt_basic = undefined;
            var responsiveHelper_datatable_fixed_column = undefined;
            var responsiveHelper_datatable_col_reorder = undefined;
            var responsiveHelper_datatable_tabletools = undefined;

            var breakpointDefinition = {
                tablet: 1024,
                phone: 480
            };

            $('#dt_basic').dataTable({
                "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l>r>" +
                    "t" +
                    "<'dt-toolbar-footer'<'col-sm-6 col-xs-12 hidden-xs'i><'col-xs-12 col-sm-6'p>>",
                "autoWidth": true,
                "oLanguage": {
                    "sSearch": '<span class="input-group-addon"><i class="glyphicon glyphicon-search"></i></span>'
                },
                "preDrawCallback": function () {
                    // Initialize the responsive datatables helper once.
                    if (!responsiveHelper_dt_basic) {
                        responsiveHelper_dt_basic = new ResponsiveDatatablesHelper($('#dt_basic'), breakpointDefinition);
                    }
                },
                "rowCallback": function (nRow) {
                    responsiveHelper_dt_basic.createExpandIcon(nRow);
                },
                "drawCallback": function (oSettings) {
                    responsiveHelper_dt_basic.respond();
                }
            });
            /* END BASIC */
        });

        function deleteArticle(docID) {

            $.SmartMessageBox({
                title: "<i class=\"fa fa-fw far fa-trash-alt\" aria-hidden=\"true\"></i> 刪除專業知識",
                content: "確定刪除此文章?",
                buttons: '[刪除][取消]'
            }, function (ButtonPressed) {
                if (ButtonPressed == "刪除") {
                    $('<form method="post"/>').appendTo($('body'))
                        .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Information/DeleteBlog") %>' + '?docID=' + docID)
                        .submit();

                    <%--                    $.post('<%= VirtualPathUtility.ToAbsolute("~/Information/DeleteBlog")%>', { 'docID': docID }, function (data) {
                        smartAlert(data.message);
                        if (data.result) {
                            window.location.reload();
                        }
                    });--%>
                }
            });
        }
    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        rpList.DataSource = this.Model;
        rpList.DataBind();
        //pagingControl.Item = (PagingIndexViewModel)ViewBag.PagingModel;
        //pagingControl.RecordCount = models.EntityList.Count();
    }


</script>
