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
<%@ Register Src="~/Views/CornerKick/Module/UserGuideNotice.ascx" TagPrefix="uc1" TagName="UserGuideNotice" %>
<!DOCTYPE html>
<html>
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <meta name="viewport" content="width=device-width, initial-scale=1"/>
      <title>BEYOND FITNESS - 新增行事曆</title>
      <!-- CSS  -->
      <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
      <!-- materialize  -->
      <link href="css/materialize.css" type="text/css" rel="stylesheet" media="screen,projection"/>
      <!-- livIconsevo  -->
      <link href='css/livIconsevo/LivIconsEvo.css' rel='stylesheet' type='text/css'>
      <link href="css/livIconsevo/LivIconsEvo.css" rel="stylesheet" type="text/css">
      <!-- scrollup-master  -->
      <link href="css/scrollup-master/themes/image.css?1.1" rel="stylesheet" id="scrollUpTheme">
      
      <!-- datedropper  -->
      <link href='css/datedropper/datedropper.min.css' rel='stylesheet' type='text/css'>
      <link href='css/datedropper/datedropper.theme.css?1' rel='stylesheet' type='text/css'>      
      <!-- timedropper  -->
      <link href='css/timedropper/timedropper.min.css' rel='stylesheet' type='text/css'>      
      <!-- STYLE 要放最下面  -->
      <link href="css/style.css?1.1" type="text/css" rel="stylesheet" media="screen,projection"/>
                 <link rel="icon" href="favicons/favicon_96x96.png">
      <!-- Specifying a Webpage Icon for Web Clip -->
      <link rel="apple-touch-icon-precomposed" href="favicons/favicon_57x57.png">
      <link rel="apple-touch-icon-precomposed" sizes="72x72" href="favicons/favicon_72x72.png">
      <link rel="apple-touch-icon-precomposed" sizes="114x114" href="favicons/favicon_114x114.png">
      <link rel="apple-touch-icon-precomposed" sizes="144x144" href="favicons/favicon_144x144.png">
      <link rel="apple-touch-icon-precomposed" sizes="180x180" href="favicons/favicon_180x180.png">       

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
      <!--datedropper-->
      <script src="js/plugin/datedropper/datedropper.js"></script> 
      <!--timedropper-->
      <script src="js/plugin/timedropper/timedropper.js"></script>     </head>
   <body>
      <!--//預設值為藍色 / 若要設定女生 請加上 mode-girls /--> 
      <div class="wrapper">
         <div class="wrapper-fixed">
            <!--Header -->
            <nav class="white non-line" role="navigation">
               <div class="nav-wrapper container">
                  <!-- BACK --> 
                  <%  Html.RenderPartial("~/Views/CornerKick/Module/ReturnHome.ascx",model:Url.Action("LearnerCalendar","CornerKick")); %>
                  <!-- // End of BACK --> 
                  <a id="logo-container" href="#" class="brand-logo toptitle center" >編輯行事曆</a>
               </div>
            </nav>
            <!-- // End of Header --> 
            <!-- main -->
            <div class="main">
               <div class="container">
                  <!--品牌LOGO -->
                  <!-- // End of 品牌LOGO -->
                  <div class="registered-forms">
                     <!-- 登入 - TAB -->
                     <!--
                        <ul id="tabs-swipe-demo" class="tabs col s12">
                           <li class="tab col s6"><a class="active"  href="#test-swipe-1">個人行事曆</a></li>
                           <li class="tab col s6"><a href="#test-swipe-2">ＳＴ排課</a></li>
                        </ul>
                        -->
                     <div id="test-swipe-1" class="tab-content col s12">
                        <form class="" id="queryForm">
                           <div class="row">
                              <!--1-->
                              <div class="input-field col s12"> 
                                 <i class="livicon-evo prefix" data-options="name: calendar.svg; size: 30px; style: lines; strokeColor:#05232d; autoPlay:true"></i>
                                 <label for="">開始日期</label>
                                 <input type="text" class="pickdate" name="StartDate" data-format="Y/m/d" data-lang="zh" data-modal="true" data-large-default="true" data-large-mode="true" data-theme="<%= _model.UserProfileExtension.Gender=="F" ? "teal-momo" : "teal-navy" %>" value="<%= $"{_viewModel.StartDate:yyyy/M/d}" %>" data-default-date="<%= $"{_viewModel.StartDate:MM-dd-yyyy}" %>"/>
                              </div>
                              <!--2-->
                              <div class="input-field col s12"> 
                                 <i class="livicon-evo prefix" data-options="name: alarm.svg; size: 30px; style: lines; strokeColor:#05232d; autoPlay:true"></i>
                                 <label for="">開始時間</label>
                                 <input type="text" class="picktime" name="StartTime" value="<%= $"{_viewModel.StartDate ?? DateTime.Now:HH:mm}" %>"/>
                              </div>                               
                              <!--3-->
                              <div class="input-field col s12"> 
                                 <i class="livicon-evo prefix" data-options="name: calendar.svg; size: 30px; style: lines; strokeColor:#05232d; autoPlay:true"></i>
                                 <label for="">結束日期</label>
                                 <input type="text" class="pickdate" name="EndDate" data-format="Y/m/d" data-lang="zh" data-modal="true" data-large-default="true" data-large-mode="true" data-theme="<%= _model.UserProfileExtension.Gender=="F" ? "teal-momo" : "teal-navy" %>" value="<%= $"{_viewModel.EndDate:yyyy/M/d}" %>"  data-default-date="<%= $"{_viewModel.EndDate:MM-dd-yyyy}" %>"/>
                              </div>							   							   							   
                              <!--4-->
                              <div class="input-field col s12"> 
                                 <i class="livicon-evo prefix" data-options="name: alarm.svg; size: 30px; style: lines; strokeColor:#05232d; autoPlay:true"></i>
                                 <label for="">結束時間</label>
                                 <input type="text" class="picktime" name="EndTime" value="<%= $"{_viewModel.EndDate ?? DateTime.Now:HH:mm}" %>" />
                              </div>								   
                               <!--4-->
                              <div class="input-field col s12">
                                 <i class="livicon-evo prefix" data-options="name: pen.svg; size: 30px; style: lines; strokeColor:#05232d; autoPlay:true"></i>
                                 <textarea id="icon_prefix2" class="materialize-textarea" name="Title"><%= _viewModel.Title %></textarea>
                                 <label for="icon_prefix2">請輸入行事曆內容</label>
                              </div>
                           </div>
                        </form>
                     </div>
                     <!--                     <div id="test-swipe-2" class="tab-content col s12">內容區</div>-->
                  </div>
                  <!-- //End of 登入 - TAB --> 
               </div>
            </div>
            <!-- // End of main --> 
         </div>
         <!--// End of wrapper-fixed--> 
         <!-- Button -->
         <div class="bottom-area">
             <% if (_viewModel.EventID.HasValue)
                 { %>
            <button class="btn waves-effect waves-light btn-cancel" type="button" name="cancel" onclick="gtag('event', '刪除', { 'event_category': '按鈕點擊','event_label': '編輯行事曆'});deleteUserEvent();">刪  除</button>
             <% }
                else
                { %>
            <button class="btn waves-effect waves-light btn-cancel" type="button" name="cancel" onclick="gtag('event', '取消', { 'event_category': '按鈕點擊','event_label': '編輯行事曆'});window.location.href='<%= Url.Action("LearnerCalendar","CornerKick") %>';">取  消</button>
             <% } %>
            <button class="btn waves-effect waves-light btn-confirm" type="button" name="confirm" onclick="commitUserEvent();">確  認</button>
         </div>
         <!--// End of button--> 
      </div>
      <!--// End of wrapper--> 
      <!-- Footer --> 
      <!--<footer class="page-footer teal">
         <div class="footer-copyright">
           <div class="container"><a class="brown-text text-lighten-3" href="#">BEYOND FITNESS</a> </div>
         </div>
         </footer>--> 
      <!-- // End of Footer --> 
      <!--  Scripts--> 
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
                      
                $(".pickdate").dateDropper({
                });
             
                $(".picktime").timeDropper({
                    meridians: true,
                    format: 'HH:mm',
                    primaryColor: '<%= _model.UserProfileExtension.Gender=="F" ? "#fd5c63" : "#0061d2" %>',
                    borderColor: '#4a4a4a',
                    setCurrentTime: false
                });
         });
         
                                        
             
      </script>
   </body>
</html>
<script>

    function commitUserEvent() {
        var $formData = $('#queryForm').serializeObject();
        clearErrors();
        showLoading();
        $.post('<%= Url.Action("CommitUserEvent", "CornerKick",new {_viewModel.EventID }) %>', $formData, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                if (data.result) {
                    //window.location.href = '';
                }
            } else {
                $(data).appendTo($('body'));
            }
        });
    }

    function deleteUserEvent() {
        var event = event || window.event;
        if (confirm('確定刪除?')) {
            showLoading();
            $('').launchDownload('<%= Url.Action("DeleteLearnerEvent","CornerKick",new { _viewModel.EventID}) %>');
        }
    }

</script>
<%  Html.RenderPartial("~/Views/Common/JQueryHelper.ascx"); %>
<%  Html.RenderPartial("~/Views/CornerKick/Module/ModeGirls.ascx",_model); %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    UserEventViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _viewModel = (UserEventViewModel)ViewBag.ViewModel;
    }

</script>