<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-tasks"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>顧問費用表</li>
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
        <i class="fa-fw fa fa-lg fa-tasks"></i>顧問費用表
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <!-- start row -->
    <div class="row">

        <!-- NEW WIDGET START -->
        <article class="col-sm-12">

            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget well" id="wid-id-0">
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
                    <span class="widget-icon"><i class="fa fa-comments"></i></span>
                    <h2>My Data </h2>

                </header>

                <!-- widget div-->
                <div>

                    <!-- widget edit box -->
                    <div class="jarviswidget-editbox">
                        <!-- This area used as dropdown edit box -->

                    </div>
                    <!-- end widget edit box -->

                    <!-- widget content -->
                    <div class="widget-body">
                        <div class="row">
                            <div id="myCarousel" class="carousel fade profile-carousel">
                                <ol class="carousel-indicators">
                                    <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
                                    <li data-target="#myCarousel" data-slide-to="1" class=""></li>
                                    <li data-target="#myCarousel" data-slide-to="2" class=""></li>
                                </ol>
                                <div class="carousel-inner">
                                    <!-- Slide 1 -->
                                    <div class="item active">
                                        <img runat="server" src="~/img/slider/bg1.jpg" alt="">
                                    </div>
                                    <!-- Slide 2 -->
                                    <div class="item">
                                        <img runat="server" src="~/img/slider/bg2.jpg" alt="">
                                    </div>
                                    <!-- Slide 3 -->
                                    <div class="item">
                                        <img runat="server" src="~/img/slider/bg3.jpg" alt="">
                                    </div>
                                </div>
                            </div>

                        </div>
                        <div class="row">
                            <div class="col-sm-0 col-md-2 col-lg-2">
                            </div>

                            <div class="col-sm-6 col-md-4 col-lg-4">
                                <div class="panel panel-pinkDark pricing-big">
                                    <img runat="server" src="~/img/ribbon.png" class="ribbon" alt="">
                                    <div class="panel-heading text-align-center">
                                        <h1 class="panel-title">1 小時
                                        </h1>
                                        <span>多人優惠（下方價格優待計算）</span>
                                    </div>
                                    <div class="panel-body no-padding text-align-center">
                                        <div class="price-features">
                                            <h1>
                                                <ul class="list-unstyled">
                                                    <li><i class="fa fa-tasks text-danger"></i><strong>單堂 / 2,100</strong></li>
                                                    <li><i class="fa fa-tasks text-danger"></i><strong>25堂 / 1,700</strong></li>
                                                    <li><i class="fa fa-tasks text-danger"></i><strong>50堂 / 1,500</strong></li>
                                                    <li><i class="fa fa-tasks text-danger"></i><strong>75堂 / 1,400</strong></li>
                                                </ul>
                                            </h1>
                                        </div>
                                    </div>
                                    <div class="panel-footer text-align-center">
                                        <div>
                                            <li class="fa fa-bell">
                                                <a href="javascript:void(0);" rel="popover-hover" data-placement="top" data-original-title="<i class='fa fa-fw fa-dollar'></i> 2人同行 7 折優待" data-content="<div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>單堂 / 1,470(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>25堂 / 1,190(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>50堂 / 1,050(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>75堂 / 980(每人)</span></label></div>" data-html="true"><i>2人同行 &nbsp;7&nbsp; 折優待</i></a>
                                            </li>
                                            <br />
                                            <li class="fa fa-bell">
                                                <a href="javascript:void(0);" rel="popover-hover" data-placement="top" data-original-title="<i class='fa fa-fw fa-dollar'></i> 3人同行 6.5 折優待" data-content="<div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>單堂 / 1,365(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>25堂 / 1,105(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>50堂 / 975(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>75堂 / 910(每人)</span></label></div>" data-html="true"><i>3人同行 6.5 折優待</i></a>
                                            </li>
                                            <br />
                                            <li class="fa fa-bell">
                                                <a href="javascript:void(0);" rel="popover-hover" data-placement="top" data-original-title="<i class='fa fa-fw fa-dollar'></i> 4人同行 6 折優待" data-content="<div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>單堂 / 1,260(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>25堂 / 1,020(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>50堂 / 900(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>75堂 / 840(每人)</span></label></div>" data-html="true"><i>4人同行 &nbsp;6&nbsp; 折優待</i></a>
                                            </li>
                                            <br />
                                        </div>
                                    </div>
                                </div>

                            </div>
                            <div class="col-sm-6 col-md-4 col-lg-4">
                                <div class="panel panel-pinkDark pricing-big">
                                    <div class="panel-heading text-align-center">
                                        <h1 class="panel-title">1.5 小時
                                        </h1>
                                        <span>多人優惠（下方價格優待計算）</span>
                                    </div>
                                    <div class="panel-body no-padding text-align-center">
                                        <div class="price-features">
                                            <h1>
                                                <ul class="list-unstyled">
                                                    <li><i class="fa fa-tasks text-danger"></i><strong>單堂 / 2,800</strong></li>
                                                    <li><i class="fa fa-tasks text-danger"></i><strong>25堂 / 2,300</strong></li>
                                                    <li><i class="fa fa-tasks text-danger"></i><strong>50堂 / 2,000</strong></li>
                                                    <li><i class="fa fa-tasks text-danger"></i><strong>75堂 / 1,900</strong></li>
                                                </ul>
                                            </h1>
                                        </div>
                                    </div>
                                    <div class="panel-footer text-align-center">
                                        <div>
                                            <li class="fa fa-bell">
                                                <a href="javascript:void(0);" rel="popover-hover" data-placement="top" data-original-title="<i class='fa fa-fw fa-dollar'></i> 2人同行 7 折優待" data-content="<div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>單堂 / 1,960(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>25堂 / 1,610(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>50堂 / 1,400(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>75堂 / 1,330(每人)</span></label></div>" data-html="true"><i>2人同行 &nbsp;7&nbsp; 折優待</i></a>
                                            </li>
                                            <br />
                                            <li class="fa fa-bell">
                                                <a href="javascript:void(0);" rel="popover-hover" data-placement="top" data-original-title="<i class='fa fa-fw fa-dollar'></i> 3人同行 6.5 折優待" data-content="<div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>單堂 / 1,820(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>25堂 / 1,495(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>50堂 / 1,300(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>75堂 / 1,235(每人)</span></label></div>" data-html="true"><i>3人同行 6.5 折優待</i></a>
                                            </li>
                                            <br />
                                            <li class="fa fa-bell">
                                                <a href="javascript:void(0);" rel="popover-hover" data-placement="top" data-original-title="<i class='fa fa-fw fa-dollar'></i> 4人同行 6 折優待" data-content="<div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>單堂 / 1,680(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>25堂 / 1,380(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>50堂 / 1,200(每人)</span></label></div><div class='checkbox'><label><input type='checkbox' class='checkbox style-0' checked='checked'><span>75堂 / 1,140(每人)</span></label></div>" data-html="true"><i>4人同行 &nbsp;6&nbsp; 折優待</i></a>
                                            </li>
                                            <br />
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-sm-0 col-lg-2">
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
    <!-- end row -->

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
