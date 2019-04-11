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
<html>
<head>
    <meta charset="utf-8" />
    <!--<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">-->
    <title>BEYOND FITNESS</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <!-- Basic Styles -->
    <link rel="stylesheet" type="text/css" media="screen" href="../css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" media="screen" href="../fonts/fontawesome5.0/css/fontawesome-all.css">
    <!-- SmartAdmin Styles : Caution! DO NOT change the order -->
    <link rel="stylesheet" type="text/css" media="screen" href="../css/smartadmin-production-plugins-20180501.min.css">
    <link rel="stylesheet" type="text/css" media="screen" href="../css/smartadmin-production-20180501.min.css">
    <link rel="stylesheet" type="text/css" media="screen" href="../css/smartadmin-skins.min.css">
    <!-- SmartAdmin RTL Support -->
    <link rel="stylesheet" type="text/css" media="screen" href="../css/smartadmin-rtl.min.css">
    <!-- lockScreen CSS Styles  -->
    <link rel="stylesheet" type="text/css" media="screen" href="../css/app.css">
    <!-- We recommend you use "your_style.css" to override SmartAdmin
         specific styles this will also ensure you retrain your customization with each SmartAdmin update.-->
    <link rel="stylesheet" type="text/css" media="screen" href="../css/bootstrap-datetimepicker.min.css">
    <link rel="stylesheet" type="text/css" media="screen" href="../css/beyond_style.css">

    <!-- FAVICONS -->
    <link rel="shortcut icon" href="../img/favicon/favicon.ico" type="image/x-icon">
    <link rel="icon" href="../img/favicon/favicon.ico" type="image/x-icon">
    <!-- GOOGLE FONT -->
    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Open+Sans:400italic,700italic,300,400,700">
    <!-- Specifying a Webpage Icon for Web Clip 
         Ref: https://developer.apple.com/library/ios/documentation/AppleApplications/Reference/SafariWebContent/ConfiguringWebApplications/ConfiguringWebApplications.html -->
    <link rel="apple-touch-icon" href="../img/splash/sptouch-icon-iphone.png">
    <link rel="apple-touch-icon" sizes="76x76" href="../img/splash/touch-icon-ipad.png">
    <link rel="apple-touch-icon" sizes="120x120" href="../img/splash/touch-icon-iphone-retina.png">
    <link rel="apple-touch-icon" sizes="152x152" href="../img/splash/touch-icon-ipad-retina.png">
    <!-- iOS web-app metas : hides Safari UI Components and Changes Status Bar Appearance -->
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <!-- Startup image for web apps -->
    <link rel="apple-touch-startup-image" href="../img/splash/ipad-landscape.png" media="screen and (min-device-width: 481px) and (max-device-width: 1024px) and (orientation:landscape)">
    <link rel="apple-touch-startup-image" href="../img/splash/ipad-portrait.png" media="screen and (min-device-width: 481px) and (max-device-width: 1024px) and (orientation:portrait)">
    <link rel="apple-touch-startup-image" href="../img/splash/iphone.png" media="screen and (max-device-width: 320px)">
    <!--[if IE 9]>
      <style>
         .error-text {
         color: #333 !important;
         }
      </style>
      <![endif]-->
    <meta property="fb:app_id" content="1027299250717597" />
    <!-- PACE LOADER - turn this on if you want ajax loading to show (caution: uses lots of memory on iDevices)-->
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
                <img src="../img/logo.png" alt="Beyond-Fitness">
            </span>
            <!-- END LOGO PLACEHOLDER -->
        </div>
        <!-- pulled right: nav area -->
        <div class="pull-right">
            <!-- #MOBILE -->
            <!-- Top menu profile link : this shows only when top menu is active -->
            <ul id="mobile-profile-img" class="header-dropdown-list hidden-xs padding-5">
                <li class="">
                    <a href="<%= Url.Action("Logout","Account") %>" title="Sign Out" data-action="userLogout" data-logout-msg="為了安全起見，建議您登出後將網頁關閉！"><i class="fa fa-power-off"></i> Sign out</a>
                </li>
            </ul>
        </div>
        <!-- end pulled right: nav area -->
    </header>
    <!-- END HEADER -->
    <!-- MAIN PANEL -->
    <div id="main" role="main">
        <!-- MAIN CONTENT -->
        <div id="content">
            <!-- row -->
            <div class="row" id="lgRow">
                <article class="col-xs-12 col-sm-12 col-md-4 col-lg-4">
                    <div class="row">
                        <div class="col-sm-12 block block-drop-shadow">
                            <div class="head bg-dot30 np tac">
                                <%  Html.RenderPartial("~/Views/LearnerFacet/Module/SimpleMemberInfo.ascx", _profile); %>
                            </div>
                            <div class="list-group list-group-icons bg-color-darken">
                                <%  if (_profile.BodyDiagnosis.Where(d => d.LevelID == (int)Naming.DocumentLevelDefinition.正常).Count() > 0)
                                    {   %>
                                <a href="#" class="list-group-item" id="diagnosisDialog_link"><i class="fa fa-diagnoses"></i>&nbsp;&nbsp;Fitness Diagnosis<i class="fa fa-angle-right pull-right"></i></a>
                                <%  } %>
                                <a href="#" class="list-group-item" id="updateProfile_link"><i class="fa fa-cogs"></i>&nbsp;&nbsp;Profile<i class="fa fa-angle-right pull-right"></i></a>
                                <%--<a href="#" class="list-group-item" id="healthlist_link"><i class="fa fa-history"></i>&nbsp;&nbsp;Health<i class="fa fa-angle-right  pull-right"></i></a>
                                <a href="#calendar" class="list-group-item"><i class="fa fa-calendar-alt"></i>&nbsp;&nbsp;Calendar<i class="fa fa-angle-right pull-right"></i></a>--%>
                                <%--<%  if (models.GetQuestionnaireRequest(_profile).Count() > 0)
                                    { %>
                                <a href="#" class="list-group-item bg-color-redLight" id="questionnaire_link"><i class="fa fa-volume-up"></i>&nbsp;&nbsp;Questionnaire<i class="fa fa-angle-right pull-right"></i></a>
                                <%  } %>--%>
                            </div>
                        </div>
                    </div>
                    <div id="fitnessAssessment">
<%--                        <%  Html.RenderAction("PersonalStrengthAssessment", "LearnerFacet", new { uid = _profile.UID, itemID = new int[] { 23, 24, 25, 26, 34, 35 } }); %>
                        <%  Html.RenderAction("MuscleStrengthAssessment", "LearnerFacet", new { uid = _profile.UID, itemID = new int[] { 16,17,52 } }); %>--%>
                    </div>
                </article>
                <article class="col-xs-12 col-sm-12 col-md-8 col-lg-8">
                    <div class="row">
                        <div class="col-md-12">
                            <!-- Widget ID (each widget will need unique ID)-->
                            <div class="jarviswidget" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
                                <header>
                                    <span class="widget-icon"><i class="fa fa-calendar-alt"></i></span>
                                    <h2>Calendar</h2>
                                    <div class="widget-toolbar">
                                    </div>
                                </header>
                                <!-- widget div-->
                                <div>
                                    <div class="widget-body bg-color-darken txt-color-white no-padding">
                                        <!-- content goes here -->
                                        <div class="widget-body-toolbar">
                                            <div id="calendar-buttons">
                                                <div class="btn-group">
                                                    <a href="#" class="btn btn-default btn-xs" id="addEventDialog_link"><i class="fa fa-plus"></i>Event</a>
                                                </div>
                                                <div class="btn-group">
                                                    <a href="javascript:void(0)" class="btn btn-default btn-xs" id="btn-prev"><i class="fa fa-chevron-left"></i>Previous</a>
                                                    <a href="javascript:void(0)" class="btn btn-default btn-xs" id="btn-next">Next <i class="fa fa-chevron-right"></i></a>
                                                </div>
                                            </div>
                                        </div>
                                        <% Html.RenderPartial("~/Views/LearnerFacet/Module/VipCalendar.ascx", _profile); %>
                                        <!-- end content -->
                                    </div>
                                </div>
                                <!-- end widget div -->
                            </div>
                            <%--<%  Html.RenderPartial("~/Views/LearnerFacet/Module/LessonComments.ascx",_profile); %>--%>
                        </div>
                    </div>
                </article>
            </div>
            <div class="row hidden-md hidden-lg" id="smRow">
                <article class="col-xs-12 col-sm-12 col-md-4 col-lg-4">
                </article>
            </div>
            <!-- end row -->
            <!-- ui-dialog -->
            
        <!-- dialog-message -->
        <!-- ui-dialog -->
        
        <!-- dialog-message -->
        <!-- ui-dialog -->
    </div>
    <!-- END MAIN PANEL -->
    <!-- PAGE FOOTER -->
    <div class="page-footer">
        <div class="row">
            <div class="col-xs-12 col-sm-6">
                <span class="txt-color-white">BEYOND FITNESS <span class="hidden-xs">- ALL RIGHTS RESERVED</span> © 2017</span>
            </div>
            <div class="col-xs-6 col-sm-6 text-right hidden-xs">
                <div class="txt-color-white inline-block">
                    <i class="txt-color-blueLight hidden-mobile">Last update time <i class="far fa-clock"></i><strong>2016/07/23 PM 20:03 &nbsp;</strong>
                    </i>
                </div>
            </div>
        </div>
    </div>
    <!-- END PAGE FOOTER -->
    <!--================================================== -->

    <!-- PAGE RELATED PLUGIN(S) 
         <script src="..."></script>-->
    <script type="text/javascript">
        // DO NOT REMOVE : GLOBAL FUNCTIONS!

        function diagnose(diagnosisID) {
            showLoading();
            $.post('<%= Url.Action("DiagnoseByLearner","FitnessDiagnosis",new { uid = _profile.UID }) %>', { 'diagnosisID': diagnosisID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        $(document).ready(function () {
            pageSetUp();

            // initialize sortable
            $(function () {

                $.scrollUp({
                    //animation: 'slide',
                    //activeOverlay: '#00FFFF',
                    scrollText: '',
                    scrollImg: true,
                });

            });

            //var breakpointDefinition = {
            //    tablet: 1024,
            //    phone: 480
            //};

            // Modal Link
            $('#healthlist_link').click(function () {
                showLoading();
                $.post('<%= Url.Action("HealthIndex","LearnerFacet",new { id = _profile.UID }) %>', {}, function (data) {
                    $(data).appendTo($('body'));
                    hideLoading();
                });
                return false;
            });

            $('#diagnosisDialog_link').click(function () {
                diagnose();
                return false;
            });

            $('#questionnaire_link').click(function () {
                showLoading();
                $.post('<%= Url.Action("PromptQuestionnaire","Html") %>', {}, function (data) {
                    $(data).appendTo($('body'));
                    hideLoading();
                });
                return false;
            });


            $('#updateProfile_link').click(function () {
                showLoading();
                $.post('<%= Url.Action("EditMySelf","Html") %>', {}, function (data) {
                    $(data).appendTo($('body'));
                    hideLoading();
                });
                return false;
            });


            $('#addEventDialog_link').click(function () {
                showLoading();
                $.post('<%= Url.Action("CreateUserEvent","LearnerFacet",new { UID = _profile.UID,StartDate = DateTime.Today,EndDate=DateTime.Today }) %>', {}, function (data) {
                    $(data).appendTo($('body'));
                    hideLoading();
                });
                return false;
            });


        })
    </script>
    <script>
        /*
         * CONVERT DIALOG TITLE TO HTML
         * REF: http://stackoverflow.com/questions/14488774/using-html-in-a-dialogs-title-in-jquery-ui-1-10
         */
        $.widget("ui.dialog", $.extend({}, $.ui.dialog.prototype, {
            _title: function (title) {
                if (!this.options.title) {
                    title.html("&#160;");
                } else {
                    title.html(this.options.title);
                }
            }
        }));

    </script>
    <div id="fb-root"></div>
    <script>
        window.fbAsyncInit = function () {
            FB.init({
                appId: '1027299250717597',
                xfbml: true,
                version: 'v2.8'
            });
            FB.AppEvents.logPageView();
        };

        (function (d, s, id) {
            var js, fjs = d.getElementsByTagName(s)[0];
            if (d.getElementById(id)) { return; }
            js = d.createElement(s); js.id = id;
            js.src = "//connect.facebook.net/en_US/sdk.js";
            fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));
    </script>
    <!-- Your GOOGLE ANALYTICS CODE Below -->
    <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', '<%= WebHome.Properties.Settings.Default.GA_ID_Backend %>']);
        _gaq.push(['_trackPageview']);

        (function () {
            var ga = document.createElement('script');
            ga.type = 'text/javascript';
            ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0];
            s.parentNode.insertBefore(ga, s);
        })();

    $(function () {
        console.log($('#lgRow').css('display'));
        console.log($('#smRow').css('display'));

        function drawAssessment($element) {
            <%--$element.load('<%= Url.Action("DrawFitnessAssessment","LearnerFacet",new { uid = _profile.UID }) %>');--%>
        }

        if ($('#smRow').css('display') == 'block') {
            $('#fitnessAssessment').appendTo($('#smRow article').eq(0));
            drawAssessment($('#fitnessAssessment'));
        } else if ($('#lgRow').css('display') == 'block') {
            drawAssessment($('#fitnessAssessment'));
        }

        $(window).resize(function () {
            if ($('#smRow').css('display') == 'block') {
                if ($('#smRow').find('#fitnessAssessment').length == 0)
                    $('#fitnessAssessment').appendTo($('#smRow article').eq(0));
            } else if ($('#lgRow').css('display') == 'block') {
                if ($('#lgRow').find('#fitnessAssessment').length == 0)
                    $('#fitnessAssessment').appendTo($('#lgRow article').eq(0));
            }
        });

        showLoading();
        $.post('<%= Url.Action("LearnerPrompt","Html") %>', {}, function (data) {
            hideLoading();
            if (data) {
                $(data).appendTo($('body'));
            }
        });

    });

    </script>

</body>

</html>
<% Html.RenderPartial("~/Module/Common/PageTailScriptInclude.ascx"); %>
<% Html.RenderPartial("~/Views/Shared/ReportInputError.ascx"); %>
<% Html.RenderPartial("~/Views/Shared/AlertMessage.ascx"); %>
<% Html.RenderPartial("~/Views/Shared/GlobalScript.ascx"); %>
<% Html.RenderPartial("~/Views/Shared/MorrisGraphView.ascx"); %>
<% Html.RenderPartial("~/Views/Shared/EasyPieView.ascx"); %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;

        _profile = (UserProfile)this.Model;
        Response.Redirect("~/CornerKick/Index");
    }

</script>
