<%@  Page Title="" Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewPage" %>
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
      <title>BEYOND FITNESS - 我的設定</title>
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

      <script src="js/libs/jquery-2.2.4.min.js"></script> 
      <%  Html.RenderPartial("~/Views/Common/JQueryHelper.ascx"); %>
   </head>
   <body>
      <!--//預設值為藍色 / 若要設定女生 請加上 mode-girls /--> 
      <div class="wrapper">
         <div class="wrapper-fixed login-wrap">
            <!--Header -->
            <nav class="non-line dark-bg" role="navigation">
               <div class="nav-wrapper container">
                   <%   if (ViewBag.LearnerSettings == true)
                        { %>
                   <%  Html.RenderPartial("~/Views/CornerKick/Module/ReturnHome.ascx"); %>
                   <%   } %>
                  <a id="logo-container" href="#" class="brand-logo toptitle center" >我的設定</a>
                  <div class="user-photo">
                      <%  ViewBag.NoNameImg = "images/avatars/noname-edit.jpg";
                          Html.RenderPartial("~/Views/CornerKick/Module/ProfileImage.ascx", _profile); %>
                      <input type="file" id="photopic" name="photopic" style="display:none;"/>
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
                        <form id="queryForm" class="col s12">
                           <div class="row">
                              <!--1-->
                              <div class="input-field col s12">
                                 <i class="livicon-evo prefix" data-options="name: user.svg; size: 30px; style: lines; strokeColor:#05232d; autoPlay:true"></i>
                                 <input value="<%= _profile.UserName %>" id="nickname" name="UserName" type="text" class="validate"/>
                                 <label class="active" for="nickname">請輸入暱稱</label>  
                              </div>
                              <!--2-->
                              <div class="input-field col s12">
                                 <i class="livicon-evo prefix" data-options="name: envelope-put.svg; size: 30px; style: lines; strokeColor:#05232d; autoPlay:true"></i>
                                 <input value="<%= _profile.PID %>" id="PID" name="PID" type="text" maxlength="48" <%= ViewBag.LearnerSettings == true ? null : "disabled" %> />
                                 <label class="active" for="email">電子郵件</label> 
                                  <%   if (ViewBag.LearnerSettings == true)
                                        { %>
                                  <p> <a href="javascript:gtag('event', '重設密碼', {  'event_category': '連結點擊',  'event_label': '我的設定'});window.location.href = '<%= Url.Action("ResetPassword","CornerKick") %>';">修改密碼</a></p>
                                    <%   } %>
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
            <button class="btn waves-effect waves-light btn-send" type="button" name="action" onclick="commitSettings();">設定完成</button>
            </div>
         <!-- // End of Botton -->          
      </div>
       <%   if (ViewBag.LineBonus == true)
           { %>
       <div id="lineactiveModal" class="modal bottom-sheet">
        <div class="modal-content">
          <h4 class="navy-blue-t16">Beyond Fitness X Line@活動</h4>
          <p>恭喜您！帳號串連已成功立即獲得Beyond💰一枚！<br/>設定完成後可進入我的裝備確認是否領取成功</p>
        </div>
        <div class="modal-footer">
          <a href="#" class="modal-action modal-close waves-effect waves-green btn-flat">我瞭解了</a>
        </div>
      </div>  
       <%   } %>
      <!--// End of wrapper--> 
      <!-- Footer --> 
      <!--<footer class="page-footer teal">
         <div class="footer-copyright">
           <div class="container"><a class="brown-text text-lighten-3" href="#">BEYOND FITNESS</a> </div>
         </div>
         </footer>--> 
      <!-- // End of Footer --> 
      <!--  Scripts--> 
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
        
        

        $("#profileImg").click(function () {
            $("#photopic").click();
        });

        $("#photopic").change(function () {

        });
          <% if(ViewBag.LineBonus==true)
            {   %>
          $('#lineactiveModal').modal({
              dismissible: true, // Modal can be dismissed by clicking outside of the modal
              opacity: .5, // Opacity of modal background
              inDuration: 300, // Transition in duration
              outDuration: 200, // Transition out duration
              startingTop: '4%', // Starting top style attribute
              endingTop: '10%', // Ending top style attribute
              ready: function (modal, trigger) { // Callback for Modal open. Modal and trigger parameters available.
              },
              complete: function () { } // Callback for Modal close
          });
          $(function () {
              $('#lineactiveModal').modal('open');
          });
          <%    }   %>
      </script>
   </body>
</html>
<%  Html.RenderPartial("~/Views/Common/JQueryHelper.ascx"); %>
<%  Html.RenderPartial("~/Views/CornerKick/Module/ModeGirls.ascx",_profile); %>
<script>

    $(function () {
        var fileUpload = $('#photopic');
        var elmt = fileUpload.parent();

        fileUpload.off('click').on('change', function () {

            $('<form method="post" id="myForm" enctype="multipart/form-data"></form>')
            .append(fileUpload).ajaxForm({
                url: "<%= VirtualPathUtility.ToAbsolute("~/Account/UpdateMemberPicture") %>",
                data: { 'memberCode': '<%= _profile.MemberCode %>' },
                beforeSubmit: function () {
                    //status.show();
                    //btn.hide();
                    //console.log('提交時');
                },
                success: function (data) {
                    elmt.append(fileUpload);
                    if (data.result) {
                        $('#profileImg').prop('src', '<%= VirtualPathUtility.ToAbsolute("~/Information/GetResource/") %>' + data.pictureID + "?stretch=true");
                    } else {
                        alert(data.message);
                    }
                    //status.hide();
                    //console.log('提交成功');
                },
                error: function () {
                    elmt.after(fileUpload);
                    //status.hide();
                    //btn.show();
                    //console.log('提交失败');
                }
            }).submit();
        });
    });

   function commitSettings() {
       var $formData = $('#queryForm').serializeObject();
       clearErrors();
       gtag('event', '我的設定', {
           'event_category': '按鈕點擊',
           'event_label': 'LINE設定'
       });
       showLoading();
       $.post('<%= Url.Action("CommitSettings", "CornerKick",new { LearnerSettings = (bool?)ViewBag.LearnerSettings }) %>', $formData, function (data) {
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

</script>
<%  Html.RenderPartial("~/Views/Common/JQueryHelper.ascx"); %>
<%  Html.RenderPartial("~/Views/CornerKick/Module/ModeGirls.ascx",_profile); %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser().LoadInstance(models);
    }

</script>