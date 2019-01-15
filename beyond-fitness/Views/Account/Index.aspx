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
                <i class="fa fa-graduation-cap"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>關於 BEYOND FITNESS</li>
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
        <i class="fa-fw fa fa-graduation-cap"></i>關於 BEYOND FITNESS
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <!-- start row -->
    <div class="row">
        <div class="col-sm-12">

            <div class="row">

                <div class="col-sm-12 col-md-12 col-lg-12">

                    <!-- well -->
                    <div class="well well-sm bg-color-darken txt-color-white">
                        <p>
                            運動科學是一門對於人類體能運動進行科學化分析的綜合性科學，其研究領域包含早期的人體基礎學理以及運動生理學、運動心理學、運動生物力學、動作控制等方面。 同時包括了營養學以及各種運動科技、人動靜態測量、身體形態測量學、動作功能性分析等。</code>
                        </p>

                        <div class="alert alert-warning fade in">
                            <h4><strong>BEYOND FITNESS</strong>秉持著科學化訓練的原則，有系統、有計畫、有科學實證根據地進行專業訓練。並結合本公司專業體能團隊的訓練實務經驗，以藝術般的手法設計課程活動，提供給客戶最優的訓練品質與體能顧問水準。</h4>
                        </div>

                        <div id="myCarousel" class="carousel fade">
                            <ol class="carousel-indicators">
                                <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
                                <li data-target="#myCarousel" data-slide-to="1" class=""></li>
                                <li data-target="#myCarousel" data-slide-to="2" class=""></li>
                            </ol>
                            <div class="carousel-inner">
                                <!-- Slide 1 -->
                                <div class="item active">
                                    <img src="~/img/slider/bg1.jpg" alt="" runat="server" />
                                    <div class="carousel-caption caption-right">
                                        <h4>高端專業訓練品質</h4>
                                        <p class="hidden-sm hidden-xs">針對不同年齡及需求提供多種體適能課程，以高端專業訓練品質，提供您全方位的服務。</p>
                                        <br>
                                        <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/Blog") %>" class="btn btn-info btn-sm">Read more</a>
                                    </div>
                                </div>
                                <!-- Slide 2 -->
                                <div class="item">
                                    <img src="~/img/slider/bg2.jpg" alt="" runat="server" />
                                    <div class="carousel-caption caption-left">
                                        <h4>專業量身訂做規劃</h4>
                                        <p class="hidden-sm hidden-xs">了解或許您想一個人、三五好友，或公司團體，都能為您量身訂做規劃，讓您無後顧之憂。</p>
                                        <br>
                                        <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/ContactUs") %>" class="btn btn-danger btn-sm">Contact Us</a>
                                    </div>
                                </div>
                                <!-- Slide 3 -->
                                <div class="item">
                                    <img src="~/img/slider/bg3.jpg" alt="" runat="server" />
                                    <div class="carousel-caption">
                                        <h4>專業以及貼心服務</h4>
                                        <p class="hidden-sm hidden-xs">
                                            深入每位學員的體能狀況，提供運動前後的諮詢建議，貼心的服務，做的永遠比您想得更多。
                                        </p>
                                        <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/ContactUs") %>" class="btn btn-danger btn-sm">Contact Us</a>
                                    </div>
                                </div>
                            </div>
                            <a class="left carousel-control" href="#myCarousel" data-slide="prev"><span class="glyphicon glyphicon-chevron-left"></span></a>
                            <a class="right carousel-control" href="#myCarousel" data-slide="next"><span class="glyphicon glyphicon-chevron-right"></span></a>
                        </div>
                        <div>
                            抬頭名稱：超越體能顧問有限公司信義門市<br />
                            <%--信義店發票號碼：42457825<br />--%>
                            地址：11049台北市信義區信義路五段16號2樓之2<br />
                            TEL: 02-27200530
                        </div>
                        <div>
                            抬頭名稱：超越體能顧問有限公司南京門市<br />
                            地址：台北市松山區南京東路四段17號B1<br />
                            TEL: 02-2715-2733
                        </div>

                    </div>
                    <!-- end well -->

                </div>

            </div>

        </div>

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
        //Response.Redirect("~/front-end/index.html");
    }


</script>
