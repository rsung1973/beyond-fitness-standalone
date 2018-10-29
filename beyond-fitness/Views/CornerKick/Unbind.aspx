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
<html>
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <meta name="viewport" content="width=device-width, initial-scale=1"/>
      <title>BEYOND FITNESS - 解除設定</title>
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
      <div class="wrapper">
         <div class="wrapper-fixed login-wrap">
            <!--Header -->
            <nav class="non-line dark-bg" role="navigation">
               <div class="nav-wrapper container">
                  <a id="logo-container" href="#" class="brand-logo toptitle center" >解除設定</a>
                  <div class="user-photo">
                      <%  Html.RenderPartial("~/Views/CornerKick/Module/ProfileImage.ascx", _model); %>
                     <input type="file" id="uplodfile" style="display:none;"/>
                  </div>
               </div>
            </nav>
            <!-- // End of Header --> 
            <!-- main-->
            <div class="main">
               <div class="container">
                  <!--品牌LOGO -->
                  <!-- // End of 品牌LOGO --> 
                  <!-- 表單 -->
                  <div class="setting-forms">
                     <div class="row">
                        <form class="col s12">
                           <div class="row">
                              <!--1-->
                              <div class="input-field col s12">
                                 <i class="livicon-evo prefix" data-options="name: user.svg; size: 30px; style: lines; strokeColor:#05232d; autoPlay:true"></i>
                                 <input value="<%= _model.UserName %>" id="nickname" type="text" readonly/>
                                 <label class="active" for="nickname">請輸入暱稱</label> 
                              </div>
                              <!--2-->
                              <div class="input-field col s12">
                                 <i class="livicon-evo prefix" data-options="name: envelope-put.svg; size: 30px; style: lines; strokeColor:#05232d; autoPlay:true"></i>
                                 <input value="<%= _model.PID %>" id="email" type="email" readonly/>
                                 <label class="active" for="email">電子郵件</label> 
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
         <!-- Botton -->
         <div class="bottom-area">
            <button class="btn waves-effect waves-light btn-send" type="button" name="action" onclick="commitUnbound();">解除設定</button>
         </div>
         <!-- // End of Botton -->          
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
        });
        
        

        $("#myimage").click(function () {
            $("#uplodfile").click();
        });

        $("#uplodfile").change(function () {

        });              
      </script>       
   </body>
</html>
<%  Html.RenderPartial("~/Views/Common/JQueryHelper.ascx"); %>
<script>
    function commitUnbound() {
        showLoading();
        gtag('event', '解除設定', {
            'event_category': '按鈕點擊',
            'event_label': 'LINE設定'
        });
        $('').launchDownload('<%= Url.Action("CommitUnbound","CornerKick") %>', { 'keyID': '<%= _model.UID.EncryptKey() %>','lineID':'<%= _model.UserProfileExtension.LineID %>' });
    }
    <%  if (_model.UserProfileExtension.Gender == "F")
        { %>
    $(function () {
        $('.wrapper').addClass('mode-girls');
    });
    <%  } %>
</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }

</script>