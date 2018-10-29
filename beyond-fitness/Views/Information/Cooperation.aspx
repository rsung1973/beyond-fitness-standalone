<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <!-- RIBBON -->
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa fa-link"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>相關合作</li>
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
    <!-- END RIBBON -->
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-link"></i>相關合作
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <!-- row -->
    <div class="row">

        <article class="col-xs-12 col-sm-12 col-md-8 col-lg-8">
            <div class="well well-sm bg-color-darken txt-color-white">
                <p>
                    <strong>BEYOND FITNESS</strong>提供您有關健康減重、運動、營養、體適能、健康生活及相關講座及演講邀約服務。若您有以上相關需求，歡迎您與我們聯繫，我們也提供以下諮詢服務：
                </p>
                <div class="alert alert-warning">
                    <ul>
                        <li>企業合作顧問服務</li>
                        <li>相關產業管理及顧問服務</li>
                        <li>產業人才培育</li>
                    </ul>
                </div>
                <p class="text-center">
                    <img class="img-thumbnail" src="../img/professional//COOPERATION-01.png" alt="相關合作" />
                </p>
            </div>
        </article>
        <article class="col-xs-12 col-sm-12 col-md-4 col-lg-4">
            <!-- /well -->
            <div class="well bg-color-darken txt-color-white padding-10">
                <h5 class="margin-top-0"><i class="fa fa-link"></i>合作夥伴:</h5>
                <div class="row">
                    <div class="col-lg-12">
                        <ul class="list-unstyled">
                            <li>
                                <a href="https://www.facebook.com/BOOMFitPro" target="_blank" class="facebook"><i>
                                    <img src="../img/partnerbox/partner-BOOM.png" alt="" /></i></a>
                            </li>
                            <li>
                                <a class="twitter" href="https://www.facebook.com/xrevolutionfitness" target="_blank"><i>
                                    <img src="../img/partnerbox/partner-X-Revolution.png" alt="" /></i></a>
                            </li>
                            <li>
                                <a class="google" href="https://www.facebook.com/AkrofitnessTheGym" target="_blank"><i>
                                    <img src="../img/partnerbox/partner-Akrofitness.png" alt="" /></i></a>
                            </li>
                            <li>
                                <a class="dribbble" href="https://www.facebook.com/LIGHTFITNESS" target="_blank"><i>
                                    <img src="../img/partnerbox/partner-lightfitness.png" alt="" /></i></a>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
            <!-- /well -->
            <%  Html.RenderPartial("~/Views/Layout/SNS.ascx"); %>
            <!-- /well -->
        </article>

    </div>
    <script src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/superbox/superbox.min.js") %>"></script>

    <!-- end row -->
</asp:Content>
