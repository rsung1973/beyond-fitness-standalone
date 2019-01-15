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
      <title>BEYOND FITNESS - 兌換我的裝備</title>
      <!-- CSS  -->
      <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
      <!-- materialize  -->
      <link href="css/materialize.css" type="text/css" rel="stylesheet" media="screen,projection"/>
      <!-- livIconsevo  -->
      <link href='css/livIconsevo/LivIconsEvo.css' rel='stylesheet' type='text/css'>
      <link href="css/livIconsevo/LivIconsEvo.css" rel="stylesheet" type="text/css">
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
                  <a id="logo-container" href="#" class="brand-logo toptitle center" >兌換我的裝備</a> 
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
                     <ul id="tabs-swipe-demo" class="tabs col s12">
                        <li class="tab col s6"><a class="active" onclick="gtag('event', '裝備目錄', { 'event_category': '頁籤點擊', 'event_label': '兌換我的裝備'});"  href="#test-swipe-1">裝備目錄</a></li>
                        <li class="tab col s6"><a onclick="gtag('event', '已兌換裝備', {  'event_category': '頁籤點擊', 'event_label': '兌換我的裝備'});" href="#test-swipe-2">已兌換裝備</a></li>
                     </ul>
                     <div id="test-swipe-1" class="tab-content acc-content col s12">
                        <!-- QA info -->
                        <div class="point-content">
                           <div class="personal-info">
                              <div class="row valign-wrapper">
                                 <div class="col s4 m2">
                                     <%  var lesson = _model.RegisterLesson.OrderByDescending(r => r.RegisterID).First();
                                        var currentBonusPoint = _model.BonusPoint(models) ?? 0; %>
                                     <%   ViewBag.ImgClass = "circle responsive-img valign";
                                            Html.RenderPartial("~/Views/CornerKick/Module/ProfileImage.ascx", lesson.ServingCoach.UserProfile); %>
                                 </div>
                                 <div class="col s8 m10 text-box">
<!--                                    <span class="black-t18">劉加菲</span>-->
                                    <span class="black-t12">每一枚金幣都是汗水與淚水的結晶，目前已累積 <span class="point"><%= currentBonusPoint %>枚</span> Beyond💰！ <%= currentBonusPoint>35 ? "繼續努力累積，集滿100枚有神秘大禮喔！" : null %></span>
                                 </div>
                              </div>
                           </div>
                           <!-- 點數選擇 -->
                           <div class="input-field col s12">
                              <select name="awarding">
                                 <option value="1" selected>線上兌換</option>
                                 <option value="2">現場兌換</option>
                              </select>
                               <script>
                                   function award() {
                                       if ($('select[name="awarding"]').val() == '1') {
                                           $('div.img-block.col.s12.m6.l6:has(span.online)').css('display', 'block');
                                           $('div.img-block.col.s12.m6.l6:has(span.offline)').css('display', 'none');
                                       } else {
                                           $('div.img-block.col.s12.m6.l6:has(span.online)').css('display', 'none');
                                           $('div.img-block.col.s12.m6.l6:has(span.offline)').css('display', 'block');
                                       }
                                   }

                                   $(function () {
                                       $('select[name="awarding"]').on('change', function (event) {
                                           award();
                                       });

                                       award();

                                   });
                               </script>
                           </div>
                           <!-- //End of 點數選擇 -->
                           <div class="row">
                               <%  foreach (var item in models.GetTable<BonusAwardingItem>().Where(b=>!b.Status.HasValue || b.Status!=0)
                                       .OrderBy(b => b.PointValue))
                                   {
                                        %>
                              <!-- ＩＭＧ -->
                              <div class="img-block col s12 m6 l6">
                                 <div class="parallax-container">
                                    <div class="section no-pad-bot">
                                       <div class="container">
                                          <ul class="text-area">
                                             <li class="white-text left"><%= item.ItemName %></li>
                                             <li class="right">
                                                 
                                                     <%  if (item.ExchangeableOnline == true)
                                                         {
                                                            if(currentBonusPoint>=item.PointValue)
                                                            { 
                                                                 if (item.BonusAwardingIndication != null && item.BonusAwardingIndication.Indication == "AwardingLessonGift")
                                                                 { %>
                                                                <span class="point-tag online" onclick="awardingLessonGift(<%= item.ItemID %>);"><%= item.PointValue %>點 / 立即兌換</span>
                                                        <%      }
                                                                else
                                                                {   %>
                                                                <span class="point-tag online" onclick="exchangeBonus(<%= item.ItemID %>);"><%= item.PointValue %>點 / 立即兌換</span>
                                                        <%      }
                                                            }
                                                            else
                                                            {   %>
                                                         <span class="point-tag online"><%= item.PointValue %>點</span>
                                                         <%  }
                                                        }
                                                        else
                                                        { %>
                                                     <span class="point-tag offline"><%= item.PointValue %>點</span>
                                                     <% } %>
                                             </li>
                                          </ul>
                                       </div>
                                    </div>
                                    <div class="parallax"><img src="<%= item.SampleUrl!=null ? VirtualPathUtility.ToAbsolute(item.SampleUrl) : null %>" alt="Unsplashed background img 1"/></div>
                                 </div>
                              </div>
                              <!-- // End of ＩＭＧ -->  
                               <%   } %> 
                           </div>
                           <!-- 商品 -->
                        </div>
                        <!--//End of QA info--> 
                     </div>
                     <div id="test-swipe-2" class="tab-content acc-content col s12">
                        <!-- QA info -->
                        <div class="point-content">
                            <%  if (_model.LearnerAward.Count > 0)
                                { %>
                           <div class="personal-info">
                              <div class="row valign-wrapper">
                                 <div class="col s4 m2">
                                    <%  ViewBag.ImgClass = "circle responsive-img valign";
                                      Html.RenderPartial("~/Views/CornerKick/Module/ProfileImage.ascx", _model); %>
                                 </div>
                                 <div class="col s8 m10 text-box">
                                    <span class="black-t12">您截至為止已兌換的裝備如下，繼續努力累積Beyond💰，蒐集裝備吧！</span>
                                 </div>
                              </div>
                           </div>       
                                <%  foreach (var item in _model.LearnerAward)
                                    { %>
                            <!-- ＩＭＧ -->
                           <div class="img-block">
                              <div class="parallax-container">
                                 <div class="section no-pad-bot">
                                    <div class="container">
                                       <ul class="text-area">
                                          <li class="white-text left"><%= item.BonusAwardingItem.ItemName %></li>
                                          <li class="right"></li>
                                       </ul>
                                    </div>
                                 </div>
                                 <div class="parallax"><img src="<%= item.BonusAwardingItem.SampleUrl != null ? VirtualPathUtility.ToAbsolute(item.BonusAwardingItem.SampleUrl) : null %>" alt="Unsplashed background img 1"></div>
                              </div>
                           </div>
                           <!-- // End of ＩＭＧ -->
                            <%      }
                                }
                                else
                                { %> 
                            <img class="responsive-img nodata" src="images/nodata.png">
                            <p class="collection center">
                                <span class="gray-t16">Oooops！！裝備等著你來換喔！</span>
                            <%  } %>
                           <!-- 問題 -->
                        </div>
                        <!--//End of QA info--> 
                     </div>
                  </div>
                  <!-- //End of 登入 - TAB --> 
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
<script>
        var bonusItemID;
        function awardingLessonGift(itemID) {
            bonusItemID = itemID;
            showLoading();
            $.post('<%= Url.Action("QueryRecipient","LearnerFacet") %>', {}, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        function exchangeBonus(itemID,recipientID) {
            if (confirm('確定兌換?')) {
                showLoading();
                $.post('<%= Url.Action("ExchangeBonusPoint","LearnerFacet",new { uid = _model.UID }) %>', { 'itemID': itemID,'recipientID':recipientID }, function (data) {
                    hideLoading();
                    if (data.result) {
                        alert('兌換完成!!');
                        window.location.href = '<%= Url.Action("CheckBonusPoint","CornerKick") %>';
                    } else {
                        alert(data.message);
                    }
                });
            }
        }
</script>
<%  Html.RenderPartial("~/Views/Common/JQueryHelper.ascx"); %>
<%  Html.RenderPartial("~/Views/CornerKick/Module/ModeGirls.ascx",_model); %>
<%  if (_viewModel?.LineID != null)
    { %>
<script>
    gtag('event', '已兌換裝備', {
        'event_category': '卡片點擊',
        'event_label': 'LINE圖文選單'
    });
</script>
<%  } %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    RegisterViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _viewModel = ViewBag.ViewModel as RegisterViewModel;
    }

</script>