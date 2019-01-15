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
                <i class="fa fa-database"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>基本資料維護作業</li>
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
        <i class="fa-fw fa fa-database"></i>基本資料維護作業
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
                    <span class="widget-icon"><i class="fa fa-table"></i></span>
                    <h2>課程類別列表</h2>
                    <div class="widget-toolbar">
                        <a class="btn btn-primary" href="<%= VirtualPathUtility.ToAbsolute("~/SystemInfo/EditLessonPrice") %>"><i class="fa fa-fw fa-pencil-alt"></i>新增課程類別</a>
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
                        <%  Html.RenderAction("LessonPriceTypeList"); %>
                    </div>
                    <!-- end widget content -->

                </div>
                <!-- end widget div -->

            </div>
            <!-- end widget -->
        </article>
        <!-- WIDGET END -->

    </div>

    <!-- end row -->

    <%--<div class="row">
        <!-- NEW WIDGET START -->
        <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12s">

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
                    <h2>相關商品列表</h2>
                    <div class="widget-toolbar">
                        <a href="productmaintain.html" class="btn btn-primary"><i class="fa fa-fw fa-pencil-alt"></i>相關商品產品</a>
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

                        <table id="dt_basic2" class="table table-striped table-bordered table-hover" width="100%">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th data-class="expand">商品名稱</th>
                                    <th data-hide="phone"><i class="fa fa-fw fa-dollar-sign text-muted hidden-md hidden-sm hidden-xs"></i>售價金額</th>
                                    <th><i class="fa fa-fw fa-picture-o  text-muted hidden-md hidden-sm hidden-xs"></i>商品圖片</th>
                                    <th>功能</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>1</td>
                                    <td>HYPERICE振動滾筒</td>
                                    <td>7480元</td>
                                    <td>
                                        <img src="img/superbox/product_01.jpg" width="100" height="60"></td>
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
                                                    <a href="classtypemaintain.html"><i class="fa fa-fw fa fa-edit" aria-hidden="true"></i>修改資料</a>
                                                </li>
                                                <li>
                                                    <a href="#"><i class="fa fa-fw far fa-trash-alt" aria-hidden="true"></i>刪除資料</a>
                                                </li>
                                            </ul>
                                        </div>
                                    </td>
                                </tr>

                                <tr>
                                    <td>2</td>
                                    <td>HYPERICE 冰敷袋（通用部件：膝、肘、腕及小腿）</td>
                                    <td>3280元</td>
                                    <td>
                                        <img src="img/superbox/product_02.jpg" width="100" height="60"></td>
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
                                                    <a href="classtypemaintain.html"><i class="fa fa-fw fa fa-edit" aria-hidden="true"></i>修改資料</a>
                                                </li>
                                                <li>
                                                    <a href="#"><i class="fa fa-fw far fa-trash-alt" aria-hidden="true"></i>刪除資料</a>
                                                </li>
                                            </ul>
                                        </div>
                                    </td>
                                </tr>
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
    </div>--%>
    <% Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>
    <script>

    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
    }



</script>
