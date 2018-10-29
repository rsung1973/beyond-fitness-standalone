<%@ Page Title="" Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<!DOCTYPE html>
<html>
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <meta name="viewport" content="width=device-width, initial-scale=1"/>
      <title>BEYOND FITNESS - 運動小學堂</title>
      <!-- CSS  -->
      <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
      <!-- materialize  -->
      <link href="css/materialize.css" type="text/css" rel="stylesheet" media="screen,projection"/>
      <!-- livIconsevo  -->
      <link href='css/livIconsevo/LivIconsEvo.css' rel='stylesheet' type='text/css'>
      <link href="css/livIconsevo/LivIconsEvo.css" rel="stylesheet" type="text/css">
      <!-- scrollup-master  -->
    <link href="css/scrollup-master/themes/image.css?1.1" rel="stylesheet" id="scrollUpTheme">
             <!--ionicons -->
      <link href='css/ionicons/ionicons.min.css' rel="stylesheet" type="text/css" media="screen" />
                 <link rel="icon" href="favicons/favicon_96x96.png">
      <!-- Specifying a Webpage Icon for Web Clip -->
      <link rel="apple-touch-icon-precomposed" href="favicons/favicon_57x57.png">
      <link rel="apple-touch-icon-precomposed" sizes="72x72" href="favicons/favicon_72x72.png">
      <link rel="apple-touch-icon-precomposed" sizes="114x114" href="favicons/favicon_114x114.png">
      <link rel="apple-touch-icon-precomposed" sizes="144x144" href="favicons/favicon_144x144.png">
      <link rel="apple-touch-icon-precomposed" sizes="180x180" href="favicons/favicon_180x180.png">       

      <!-- STYLE 要放最下面  -->
      <link href="css/style.css?1.1" type="text/css" rel="stylesheet" media="screen,projection"/>
   </head>
   <body>
      <!--//預設值為藍色 / 若要設定女生 請加上 mode-girls /-->
      <div class="wrapper full-fixed">
         <div class="wrapper-fixed">
            <!--Header -->
            <nav class="white non-line" role="navigation">
               <div class="nav-wrapper container">
                  <!-- BACK --> 
                  <%  Html.RenderPartial("~/Views/CornerKick/Module/ReturnHome.ascx"); %>
                  <!-- // End of BACK --> 
                  <a id="logo-container" href="#" class="brand-logo toptitle center" >運動小學堂</a> 
               </div>
            </nav>
            <!-- // End of Header --> 
            <!-- main -->
            <div class="main">
               <div class="container">
                  <div class="qa-forms">
                     <!-- 切換頁籤 - TAB -->
                     <ul id="tabs-swipe-demo" class="tabs col s12">
                        <li class="tab col s6"><a class="active" onclick="gtag('event', '題目卷', {'event_category': '頁籤點擊','event_label': '運動小學堂'});" href="#test-swipe-1">題目卷</a></li>
                        <li class="tab col s6"><a onclick="gtag('event', '答案卷', {'event_category': '頁籤點擊','event_label': '運動小學堂'});" href="#test-swipe-2">答案卷</a></li>
                     </ul>
                     <div id="test-swipe-1" class="tab-content acc-content col s12">
                        <!-- QA info -->
                         <% if (_model != null)
                             {
                                 Html.RenderPartial("~/Views/CornerKick/Module/DailyQuestion.ascx", _model);
                             }
                             else
                             {
                                 Html.RenderPartial("~/Views/CornerKick/Module/DailyQuestionNotFound.ascx");
                             }  %>
                        <!--//End of QA info--> 
                     </div>
                    <div id="test-swipe-2" class="tab-content acc-content col s12">
                       <%   Html.RenderPartial("~/Views/CornerKick/Module/DailyQuestionHistory.ascx"); %>
                       <!--//End of Accordion--> 
                    </div>                      
                     <!-- //End of 登入 - TAB --> 
                  </div>
               </div>
            </div>
            <!-- // End of main --> 
         </div>
         <!--// End of wrapper-fixed--> 
      </div>
      <!--// End of wrapper--> 
      <!-- Footer --> 
      <!--<footer class="page-footer teal">
         <!-- // End of Footer --> 
      <!--  Scripts--> 
      <script src="js/libs/jquery-2.2.4.min.js"></script> 
      <script src="js/materialize.js"></script> 
      <script src="js/init.js"></script>
      <!-- LivIconsEvo  -->
      <script src="js/plugin/LivIconsEvo/tools/snap.svg-min.js"></script>
      <script src="js/plugin/LivIconsEvo/tools/TweenMax.min.js"></script>
      <script src="js/plugin/LivIconsEvo/tools/DrawSVGPlugin.min.js"></script>
      <script src="js/plugin/LivIconsEvo/tools/MorphSVGPlugin.min.js"></script>
      <script src="js/plugin/LivIconsEvo/tools/verge.min.js"></script>
      <script src="js/plugin/LivIconsEvo/LivIconsEvo.Tools.js"></script>
      <script src="js/plugin/LivIconsEvo/LivIconsEvo.defaults.js"></script>
      <script src="js/plugin/LivIconsEvo/LivIconsEvo.js"></script> 
      <!-- scrollup-master  -->
      <script src="js/plugin/scrollup-master/jquery.scrollUp.min.js"></script>
      <script>
         $(function () {
             $.scrollUp({
                 animation: 'fade',
                 scrollImg: {
                     active: true,
                     type: 'background',
                     src: '../images/top.png'
                 }
             });
             //countup
             $('.countuptime').each(function() {
                 // no need to specify options unless they differ from the defaults
                 var target = this;
                 var endVal = parseInt($(this).attr('data-endVal'));
                 theAnimation = new countUp(target, 0, endVal, 0, 2.5);
                 theAnimation.start();
             });   
         
         });
      </script> 
   </body>
</html>
<%  Html.RenderPartial("~/Views/Common/JQueryHelper.ascx"); %>
<%  Html.RenderPartial("~/Views/CornerKick/Module/ModeGirls.ascx",_profile); %>
<script>
    function commitAnswer() {
        var $form = $('#ansForm');
        var $formData = $form.serializeObject();
        $formData.question = $('#question').text().substring(0, 5);

        var $ans = $form.find('input:radio[name="suggestionID"]:checked');
        if ($ans.length == 0) {
            alert('請選擇!!');
            return;
        }

        showLoading();
        $form.submit();
    }

    <%  if(_viewModel!=null)
        {   %>
    $(function () {
        $('a[href="#test-swipe-2"]').click();
    });
    <%  }   %>
</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PDQQuestion _model;
    IQueryable<LessonTime> _items;
    UserProfile _profile;
    DailyQuestionViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (PDQQuestion)this.Model;
        _viewModel = (DailyQuestionViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser().LoadInstance(models);
    }

</script>
