<%@ Page Title="" Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewPage" %>

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

<!DOCTYPE html>
<html lang="zh-TW">

<head>
    <meta charset="utf-8">
    <meta name="description" content="Beyond Fitness | 專業與科學化的私人教練">
    <meta HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">    
    <title>Beyond Fitness | 專業與科學化的私人教練</title>
    <!-- Favicon-->
    <link rel="icon" href="favicons/favicon_96x96.png">
    <!-- Specifying a Webpage Icon for Web Clip -->
    <link rel="apple-touch-icon-precomposed" href="favicons/favicon_57x57.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="favicons/favicon_72x72.png">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="favicons/favicon_114x114.png">
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="favicons/favicon_144x144.png">
    <link rel="apple-touch-icon-precomposed" sizes="180x180" href="favicons/favicon_180x180.png">    
    <!-- IE可能不見得有效 -->
    <meta HTTP-EQUIV="EXPIRES" CONTENT="0">
    <!-- 設定成馬上就過期 -->
    <meta HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
    <!-- Mobile Meta -->
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <!-- Favicon -->
    <link rel="shortcut icon" href="images/favicon.ico">
    <!-- Font Awesome CSS -->
    <link href="fonts/fontawesome-v5.3.1/css/all.css" rel="stylesheet">
    <link href="fonts/fontawesome-v5.3.1/css/v4-shims.css" rel="stylesheet">
    <!-- CSS reset -->
    <link rel="stylesheet" href="css/normalize.css" type="text/css">
    <!-- Font Icon -->
    <link rel="stylesheet" href="css/material-font.min.css" type="text/css">
    <!-- Animate -->
    <link rel="stylesheet" href="css/animate.css" type="text/css">
    <!-- Slick -->
    <link href="plugins/slick/slick.css" rel="stylesheet" type="text/css">
    <link href="plugins/slick/slick-theme.css" rel="stylesheet" type="text/css">
    <!-- Magnific Popup -->
    <link href="plugins/magnific-popup/magnific-popup.css" rel="stylesheet" type="text/css">
    <!-- Magnific Popup -->    
    <link href="css/main-landing.css?1.0" type="text/css" rel="stylesheet">
</head>

<body>
    <!-- //Main Nav -->
    <header id="main-nav">
        <div class="container">
            <a id="navigation" href="javascript:void(0);" class="hidden-md-up"><i class="zmdi zmdi-apps"></i></a>
            <div id="slide_out_menu">
                <a href="javascript:void(0);" class="menu-close"><i class="zmdi zmdi-close"></i></a>
                <div class="logo"><a href="<%= VirtualPathUtility.ToAbsolute("~/MainActivity/Index") %>"><img src="images/logo.png" alt="BeyondFitness"></a></div>
                <ul>
                    <li><a href="<%= Url.Action("BlogList") %>">知識分享</a></li>
                </ul>
                <div class="slide_out_menu_footer">
                    <ul class="socials">
                        <li><a href="javascript:void(0);"><i class="zmdi zmdi-facebook"></i></a></li>
                        <li><a href="javascript:void(0);"><i class="zmdi zmdi-instagram"></i></a></li>
                        <li><a href="javascript:void(0);"><i class="zmdi zmdi-youtube-play"></i></a></li>
                        <li><a href="javascript:void(0);"><i class="fab fa-line"></i></a></li>
                    </ul>
                </div>
            </div>
            <div class="row">
                <div class="col-md-2 col-sm-2 col-xs-12 text-center">
                    <a href="<%= VirtualPathUtility.ToAbsolute("~/MainActivity/Index") %>" class="logo"><img src="images/logo.png" alt="BeyondFitness"></a>
                </div>
                <div class="col-md-10 col-sm-10 col-xs-12">
                    <ul class="left nav-active">
                        <li class="pull-right">
                            <a href="<%= Url.Action("BlogGrid") %>" class="btn btn-default btn-round">知識分享首頁</a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </header>
    <div id="content"/>

    <script src="bundles/libscripts.bundle.js"></script>
    <script src="bundles/vendorscripts.bundle.js"></script>
    <!-- Slick carousel javascript -->
    <script src="plugins/slick/slick.min.js"></script>
    <!-- Magnific Popup -->
    <script src="plugins/magnific-popup/jquery.magnific-popup.min.js"></script>
    <!-- WOW Plugin -->
    <script src="js/wow.js"></script>
    <script src="js/main-landing.js"></script>
    <script>
        $("#content").load("<%= $"blog/{_model.BlogID}/content.html" %>"); 
    </script>

</body>

</html>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    BlogArticle _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (BlogArticle)this.Model;
    }

</script>
