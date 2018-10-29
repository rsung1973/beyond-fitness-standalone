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

<!DOCTYPE html>
<html lang="en-us">
<head>
    <meta charset="utf-8">
    <!--<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">-->
    <title>BEYOND FITNESS</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <!-- Basic Styles -->
    <link rel="stylesheet" type="text/css" media="screen" href="../../css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" media="screen" href="../../fonts/fontawesome5.0/css/fontawesome-all.css">
    <!-- SmartAdmin Styles : Caution! DO NOT change the order -->
    <link rel="stylesheet" type="text/css" media="screen" href="../../css/smartadmin-production-plugins-20180501.min.css">
    <link rel="stylesheet" type="text/css" media="screen" href="../../css/smartadmin-production-20180501.min.css">
    <link rel="stylesheet" type="text/css" media="screen" href="../../css/smartadmin-skins.min.css">
    <!-- SmartAdmin RTL Support -->
    <link rel="stylesheet" type="text/css" media="screen" href="../../css/smartadmin-rtl.min.css">
    <!-- lockScreen CSS Styles  -->
    <link rel="stylesheet" type="text/css" media="screen" href="../../css/app.css">
    <!-- We recommend you use "your_style.css" to override SmartAdmin
         specific styles this will also ensure you retrain your customization with each SmartAdmin update.-->
    <link rel="stylesheet" type="text/css" media="screen" href="../../css/beyond_style.css">
    <!-- FAVICONS -->
    <link rel="shortcut icon" href="../../img/favicon/favicon.ico" type="image/x-icon">
    <link rel="icon" href="../../img/favicon/favicon.ico" type="image/x-icon">
    <!-- GOOGLE FONT -->
    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Open+Sans:400italic,700italic,300,400,700">
    <!-- Specifying a Webpage Icon for Web Clip 
         Ref: https://developer.apple.com/library/ios/documentation/AppleApplications/Reference/SafariWebContent/ConfiguringWebApplications/ConfiguringWebApplications.html -->
    <link rel="apple-touch-icon" href="../../img/splash/sptouch-icon-iphone.png">
    <link rel="apple-touch-icon" sizes="76x76" href="../../img/splash/touch-icon-ipad.png">
    <link rel="apple-touch-icon" sizes="120x120" href="../../img/splash/touch-icon-iphone-retina.png">
    <link rel="apple-touch-icon" sizes="152x152" href="../../img/splash/touch-icon-ipad-retina.png">
    <!-- iOS web-app metas : hides Safari UI Components and Changes Status Bar Appearance -->
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <!-- Startup image for web apps -->
    <link rel="apple-touch-startup-image" href="../../img/splash/ipad-landscape.png" media="screen and (min-device-width: 481px) and (max-device-width: 1024px) and (orientation:landscape)">
    <link rel="apple-touch-startup-image" href="../../img/splash/ipad-portrait.png" media="screen and (min-device-width: 481px) and (max-device-width: 1024px) and (orientation:portrait)">
    <link rel="apple-touch-startup-image" href="../../img/splash/iphone.png" media="screen and (max-device-width: 320px)">
    <!--[if IE 9]>
      <style>
         .error-text {
         color: #333 !important;
         }
      </style>
      <![endif]-->
    <meta property="fb:app_id" content="1027299250717597">
    <% Html.RenderPartial("~/Module/Common/CommonScriptInclude.ascx"); %>
</head>
<!--
      TABLE OF CONTENTS.
      
      Use search to find needed section.
      
      ===================================================================
      
      |  01. #CSS Links                |  all CSS links and file paths  |
      |  02. #FAVICONS                 |  Favicon links and file paths  |
      |  03. #GOOGLE FONT              |  Google font link              |
      |  04. #APP SCREEN / ICONS       |  app icons, screen backdrops   |
      |  05. #BODY                     |  body tag                      |
      |  06. #HEADER                   |  header tag                    |
      |  07. #PROJECTS                 |  project lists                 |
      |  08. #TOGGLE LAYOUT BUTTONS    |  layout buttons and actions    |
      |  09. #MOBILE                   |  mobile view dropdown          |
      |  10. #SEARCH                   |  search field                  |
      |  11. #NAVIGATION               |  left panel & navigation       |
      |  12. #RIGHT PANEL              |  right panel userlist          |
      |  13. #MAIN PANEL               |  main panel                    |
      |  14. #MAIN CONTENT             |  content holder                |
      |  15. #PAGE FOOTER              |  page footer                   |
      |  16. #SHORTCUT AREA            |  dropdown shortcuts area       |
      |  17. #PLUGINS                  |  all scripts and plugins       |
      
      ===================================================================
      
      -->
<!-- #BODY -->
<!-- Possible Classes
      * 'smart-style-{SKIN#}'
      * 'smart-rtl'         - Switch theme mode to RTL
      * 'menu-on-top'       - Switch to top navigation (no DOM change required)
      * 'no-menu'             - Hides the menu completely
      * 'hidden-menu'       - Hides the main menu but still accessable by hovering over left edge
      * 'fixed-header'      - Fixes the header
      * 'fixed-navigation'  - Fixes the main menu
      * 'fixed-ribbon'      - Fixes breadcrumb
      * 'fixed-page-footer' - Fixes footer
      * 'container'         - boxed layout mode (non-responsive: will not work with fixed-navigation & fixed-ribbon)
      -->
<body class="smart-style-7 no-menu">
    <!-- HEADER -->
    <header id="header">
        <div id="logo-group">
            <!-- PLACE YOUR LOGO HERE -->
            <span id="logo">
                <img src="../../img/logo.png" alt="Beyond-Fitness">
            </span>
            <!-- END LOGO PLACEHOLDER -->
        </div>
        <!-- end pulled right: nav area -->
    </header>
    <!-- END HEADER -->
    <!-- MAIN PANEL -->
    <div role="main">
        <!-- MAIN CONTENT -->
        <div id="content">
            <div class="panel panel-default bg-color-darken">
                <%  ViewBag.FormAction = Url.Action("ResetPass", "Html", new { PID = _viewModel.PID });
                    Html.RenderPartial("~/Views/Account/Module/ResetPasswordForm.ascx"); %>
            </div>
        </div>

    </div>
    <!--================================================== -->
    <!-- PACE LOADER - turn this on if you want ajax loading to show (caution: uses lots of memory on iDevices)-->
    <% Html.RenderPartial("~/Module/Common/PageTailScriptInclude.ascx"); %>
    <% Html.RenderPartial("~/Views/Shared/ReportInputError.ascx"); %>
    <% Html.RenderPartial("~/Views/Shared/AlertMessage.ascx"); %>
    <% Html.RenderPartial("~/Views/Shared/GlobalScript.ascx"); %>
    <% Html.RenderPartial("~/Views/Shared/MorrisGraphView.ascx"); %>
    <% Html.RenderPartial("~/Views/Shared/EasyPieView.ascx"); %>

</body>
</html>


<script runat="server">

    ModelStateDictionary _modelState;
    PasswordViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _viewModel = (PasswordViewModel)ViewBag.ViewModel;
    }

</script>
