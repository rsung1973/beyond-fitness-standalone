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
<html lang="en">
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <meta name="viewport" content="width=device-width, initial-scale=1"/>
      <title>BEYOND FITNESS - 首次設定</title>
      <!-- CSS  -->
      <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
      <!-- materialize  -->
      <link href="css/materialize.css" type="text/css" rel="stylesheet" media="screen,projection"/>
      <!-- livIconsevo  -->
      <link href='css/livIconsevo/LivIconsEvo.css' rel='stylesheet' type='text/css'>
      <link href="css/livIconsevo/LivIconsEvo.css" rel="stylesheet" type="text/css">
      <!-- patternLock  -->
      <link href='css/patternLock/patternLock.css?1' rel='stylesheet' type='text/css'>
      <!-- scrollup-master  -->
      <link href="css/scrollup-master/themes/image.css?1.1" rel="stylesheet" id="scrollUpTheme">
      
      <!-- STYLE 要放最下面  -->
      <link href="css/style.css?1.1" type="text/css" rel="stylesheet" media="screen,projection"/>
                 <link rel="icon" href="favicons/favicon_96x96.png">
      <!-- Specifying a Webpage Icon for Web Clip -->
      <link rel="apple-touch-icon-precomposed" href="favicons/favicon_57x57.png">
      <link rel="apple-touch-icon-precomposed" sizes="72x72" href="favicons/favicon_72x72.png">
      <link rel="apple-touch-icon-precomposed" sizes="114x114" href="favicons/favicon_114x114.png">
      <link rel="apple-touch-icon-precomposed" sizes="144x144" href="favicons/favicon_144x144.png">
      <link rel="apple-touch-icon-precomposed" sizes="180x180" href="favicons/favicon_180x180.png">       

   </head>
   <body>
      <!--//預設值為藍色 / 若要設定女生 請加上 mode-girls /-->
      <div class="wrapper mode-default">
         <div class="wrapper-fixed login-wrap">
            <!--Header -->
            <!--<nav class="white" role="navigation">
               <div class="nav-wrapper container"> <a id="logo-container" href="#" class="brand-logo center">BEYOND FITNESS</a>
               </div>
               </nav>-->
            <!-- // End of Header -->
            <!-- main-->
            <div class="main">
               <div class="container">
                  <!--品牌LOGO -->
                  <div class="brand-wrapper">
                     <div class="brand-area">
                        <img src="images/logo-black.png" alt="BEYOND FITNESS" class="responsive-img">
                     </div>
                  </div>
                  <!-- // End of 品牌LOGO -->
                  <!-- 表單 -->
                  <div class="registered-forms">
                     <div class="row">
                        <form id="queryForm" class="col s12" method="post">
                           <div class="row">
                              <!--1-->
                              <div class="input-field col s12">
                                 <i class="livicon-evo prefix" data-options="name: tag.svg; size: 30px; style: lines; strokeColor:#05232d; autoPlay:true"></i>
                                 <textarea id="icon_prefix1" name="MemberCode" class="materialize-textarea" maxlength="10" data-length="10"></textarea>
                                 <label for="icon_prefix1">請輸入會員編號<br />
                                 ex：GN38949093</label>
                              </div>
                              <!--2-->
                              <div class="input-field col s12">
                                 <i class="livicon-evo prefix" data-options="name: envelope-put.svg; size: 30px; style: lines; strokeColor:#05232d; autoPlay:true"></i>
                                 <textarea id="icon_prefix2" name="PID" class="materialize-textarea" maxlength="48" data-length="48"></textarea>
                                 <label for="icon_prefix2">請輸入電子郵件信箱<br />
                                 ex：info@beyond-fitness.tw</label>
                              </div>
                              <!-- Radio -->
                              <div class="col s12 registered-radio">
                                 <ul>
                                    <li>
                                       <input class="with-gap" name="group1" type="radio" id="pattern" value="graph" checked/>
                                       <label for="pattern">快速登入</label>
                                    </li>
                                    <li>
                                       <input class="with-gap" name="group1" type="radio" id="alpha" value="alpha"/>
                                       <label for="alpha">一般登入</label>
                                    </li>
                                 </ul>
                              </div>
                              <!--3-->
                              <div id="type-swipe-alpha" class="input-field col s12"> 
                                 <i class="livicon-evo prefix" data-options="name: lock.svg; size: 30px; style: lines; strokeColor:#05232d; autoPlay:true"></i>
                                 <input id="passwd" type="password" maxlength="10" name="Password" data-length="10"/>
                                 <label for="passwd">請設定6-10位英數字密碼</label>
                              </div>
                               <!-- Botton -->
                               <div class="content-area">
                                  <button class="btn waves-effect waves-light btn-send" type="button" name="action" onclick="bindUser();">下一步</button>
                               </div>
                               <!-- // End of Botton -->          
                              <!--4-->
                              <div id="type-swipe-pattern" class="input-field col s12">
                                 <p class="memo-text center">請設定圖形密碼</p>
                                 <div id="patternContainer"></div>
                              </div>
                           </div>
                        </form>
                     </div>
                  </div>
                  <!-- // End of 表單 -->
               </div>
            </div>
            <!-- // End of main -->
         </div>
         <!--// End of wrapper-fixed-->
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
      <!-- patternLock  -->
      <script src="js/plugin/patternLock/patternLock.min.js"></script>        
      <!-- scrollup-master  -->
      <script src="js/plugin/scrollup-master/jquery.scrollUp.min.js"></script>
      <script>
          var lock = new PatternLock("#patternContainer", {
              onDraw: function (pattern) {
                  clearErrors();
                  if (pattern.length < 6 || pattern.length > 12) {
                      alert('圖形密碼長度須為6~12個連續點位');
                      lock.reset();
                      $('input[name="Password"]').val('');
                  } else {
                      //alert(pattern);
                      var pwd = [];
                      pattern.split('').forEach(function(n){
                          pwd.push(Number(n)-1);
                      });
                      bindUser(pwd.join('-'));
                      //window.location.href = 'personal-settings-line.html';
                  }
              },
              allowRepeat: true
          });
         $(function () {
             $.scrollUp({
                 animation: 'fade',
                 
                 scrollImg: {
                     active: true,
                     type: 'background',
                     src: '../images/top.png'
                 }
             });
         });
         
         
          
         $("#type-swipe-alpha").hide();
         $("#type-swipe-pattern").show();  
         $('.content-area').hide();
         $('input:radio[name="group1"]').click(function() {
              if ($(this).val() =='alpha') {
                  $("#type-swipe-alpha").show();
                  $("#type-swipe-pattern").hide();   
                  $('.content-area').show();
              } else {
                  $("#ttype-swipe-alpha").hide();
                   $("#type-swipe-pattern").show();
                  $('.content-area').hide();
              }
           });
      </script>
   </body>
</html>
<%  Html.RenderPartial("~/Views/Common/JQueryHelper.ascx"); %>
<script>
   function bindUser(lockPattern) {
       var $formData = $('#queryForm').serializeObject();
       if (lockPattern != null)
           $formData.Password = lockPattern;
       clearErrors();
       gtag('event', '我的設定', {
           'event_category': '按鈕點擊',
           'event_label': '註冊'
       });
       showLoading();
       $.post('<%= Url.Action(_viewModel.LineID!=null ? "BindUser" : "CommitToRegister", "CornerKick",new { _viewModel.LineID }) %>', $formData, function (data) {
           hideLoading();
           if ($.isPlainObject(data)) {
               if (data.result) {
                   var url = '<%= Url.Action("Settings","CornerKick") %>';
                   if (data.bonus) {
                       url = url + '?bonus='+data.bonus;
                   } 
                   window.location.href = url;
               } else {
                   lock.reset();
                   $('input[name="Password"]').val('');
               }
           } else {
               $(data).appendTo($('body'));
               lock.reset();
               $('input[name="Password"]').val('');
           }
       });
   }
</script>
<script runat="server">
   ModelSource<UserProfile> models;
   ModelStateDictionary _modelState;
   UserProfile _model;
   RegisterViewModel _viewModel;
   
   protected override void OnInit(EventArgs e)
   {
       base.OnInit(e);
       models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
       _modelState = (ModelStateDictionary)ViewBag.ModelState;
       _model = (UserProfile)this.Model;
       _viewModel = (RegisterViewModel)ViewBag.ViewModel;
   }
   
</script>