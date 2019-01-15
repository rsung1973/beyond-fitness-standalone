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
<%@ Import Namespace="WebHome.Properties" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<!DOCTYPE html>
<html>
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      <title>The Project | Email Template</title>
   </head>
   <body style="margin: 0; padding: 0;">
      <table border="0" cellpadding="0" cellspacing="0" width="100%">
         <tr>
            <td>
               <!-- Header Start -->
               <table align="center" border="0" cellpadding="0" cellspacing="0" width="600" style="border-collapse: collapse;">
                  <tr>
                     <td style="padding:15px 0 0 0;">
                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="580" style="border-collapse: collapse;">
                           <tr>
                              <td>
                                 <table align="left" border="0" cellpadding="0" cellspacing="0" width="200" style="border-collapse: collapse;">
                                    <!-- logo -->
                                    <tr>
                                       <td align="left">
                                          <a href="https://www.beyond-fitness.com.tw">
                                          <img src="<%= $"{Settings.Default.HostDomain}{VirtualPathUtility.ToAbsolute("~/CornerKick/images/logo-black.png")}" %>" alt="Beyond Fitness" style="display: block;"/>
                                          </a>
                                       </td>
                                    </tr>
                                    <tr>
                                       <td style="font-size: 0; line-height: 0;" height="15">&nbsp;</td>
                                    </tr>
                                 </table>
                              </td>
                           </tr>
                        </table>
                     </td>
                  </tr>
               </table>
               <!-- Header End -->
               <!-- Section Start -->
               <table align="center" border="0" cellpadding="0" cellspacing="0" width="600" style="border-collapse: collapse;">
                  <tr>
                     <td>
                        <table bgcolor="#fafafa" align="center" border="0" cellpadding="0" cellspacing="0" width="580" style="border-collapse: collapse;">
                           <tr>
                              <td>
                                 <table align="center" border="0" cellpadding="0" width="100%" cellspacing="0" style="border-collapse: collapse;">
                                    <!-- Border -->
                                    <tr>
                                       <td bgcolor="#f5f5f5" style="font-size: 0; line-height: 0;" height="1">&nbsp;</td>
                                    </tr>
                                    <!-- Space -->
                                    <tr>
                                       <td style="font-size: 0; line-height: 0;" height="30">&nbsp;</td>
                                    </tr>
                                 </table>
                                 <table align="center" border="0" cellpadding="0" width="480" cellspacing="0" style="border-collapse: collapse;">
                                    <tr>
                                       <td>
                                          <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;">
                                             <tr>
                                                <td width="100%" align="left" style="font-size: 24px; line-height: 34px; font-family:helvetica, Arial, sans-serif; color:#343434; text-align: center;">
                                                   Hi，您好!
                                                </td>
                                             </tr>
                                             <!-- Space -->
                                             <tr>
                                                <td style="font-size: 0; line-height: 0;" height="20">&nbsp;</td>
                                             </tr>
                                          </table>
                                          <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;">
                                             <tr>
                                                <td align="center">
                                                   <img src="<%= $"{Settings.Default.HostDomain}{VirtualPathUtility.ToAbsolute("~/CornerKick/images/avatars/noname.png")}" %>" width="120" alt="Testimonial Image" style="display: block;"/>
                                                </td>
                                             </tr>
                                          </table>
                                          <table align="left" border="0" cellpadding="0" cellspacing="0" width="3%" style="border-collapse: collapse;">
                                             <tr>
                                                <td>
                                                   &nbsp;
                                                </td>
                                             </tr>
                                          </table>
                                          <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;">
                                             <tr>
                                                <td width="100%" align="left" style="font-size: 16px; line-height: 22px; font-family:helvetica, Arial, sans-serif; color:#777777; text-align: center;">
                                                  收到這封電子郵件，表示您嘗試透過忘記密碼功能重新設定密碼。<BR/><BR/><span style="color:#d0021b">若您並未使用此功能，表示可能有其他人嘗試變更您的密碼，建議您盡速到<a href="https://www.beyond-fitness.com.tw/">會員中心</a> 變更密碼，以保障您的帳號安全。</span>
                                                </td>
                                             </tr>
                                             <!-- Space -->
                                             <tr>
                                                <td style="font-size: 0; line-height: 0;" height="10">&nbsp;</td>
                                             </tr>
                                             <tr>
                                                <td width="100%" align="left" style="font-size: 12px; line-height: 18px; font-family:helvetica, Arial, sans-serif; color:#777777; text-align: center;">
                                                   * 此信件為系統自動寄出，請勿直接回覆。
                                                </td>
                                             </tr>
                                             <tr>
                                                <td width="100%" align="left" style="font-size: 12px; line-height: 18px; font-family:helvetica, Arial, sans-serif; color:#777777; font-weight:bold; text-align: center;">
                                                   
                                                </td>
                                             </tr>
                                          </table>
                                       </td>
                                    </tr>
                                 </table>
                                 <!-- Space -->
                                 <table align="center" border="0" cellpadding="0" width="100%" cellspacing="0" style="border-collapse: collapse;">
                                    <tr>
                                       <td style="font-size: 0; line-height: 0;" height="40">&nbsp;</td>
                                    </tr>
                                 </table>
                              </td>
                           </tr>
                        </table>
                     </td>
                  </tr>
               </table>
               <!-- Section End -->
               <!-- Section Start -->
               <table align="center" border="0" cellpadding="0" cellspacing="0" width="600" style="border-collapse: collapse;">
                  <tr>
                     <td>
                        <table align="center" bgcolor="#4a4a4a" border="0" cellpadding="0" cellspacing="0" width="580" style="border-collapse: collapse;">
                           <tr>
                              <td>
                                 <table width="100%" align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
                                    <!-- Space -->
                                    <tr>
                                       <td style="font-size: 0; line-height: 0;" height="30">&nbsp;</td>
                                    </tr>
                                 </table>
                                 <table width="100%" align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
                                    <tr>
                                       <td>
                                          <table align="left" border="0" cellpadding="0" cellspacing="0" width="430" style="border-collapse: collapse;">
                                             <!-- Space -->
                                             <tr>
                                                <td style="font-size: 0; line-height: 0;" height="3">&nbsp;</td>
                                             </tr>
                                             <tr>
                                                <td width="100%" align="center" style="font-size: 28px; line-height: 34px; font-family:helvetica, Arial, sans-serif; color:#ffffff;">
                                                   驗證並重新設定密碼 >>
                                                </td>
                                             </tr>
                                          </table>
                                          <table align="left" border="0" cellpadding="0" cellspacing="0" width="140" style="border-collapse: collapse;">
                                             <!-- Space -->
                                             <tr>
                                                <td style="font-size: 0; line-height: 0;" height="0">&nbsp;</td>
                                             </tr>
                                             <tr>
                                                <td width="100%" align="center" style="padding:12px 12px 12px 12px; text-align: center;border-radius:4px;" bgcolor="#f1f1f1">
                                                   <a href="<%= $"{WebHome.Properties.Settings.Default.HostDomain}{Url.Action("ResetPassword","CornerKick",new { UUID=this.Model })}" %>" style="color: #000000; font-size: 16px; font-weight: normal; text-decoration: none; font-family: helvetica, Arial, sans-serif;">立即重設</a>
                                                </td>
                                             </tr>
                                          </table>
                                       </td>
                                    </tr>
                                 </table>
                                 <table width="100%" align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
                                    <!-- Space -->
                                    <tr>
                                       <td style="font-size: 0; line-height: 0;" height="30">&nbsp;</td>
                                    </tr>
                                 </table>
                              </td>
                           </tr>
                        </table>
                     </td>
                  </tr>
               </table>
               <!-- Section End -->
               <!-- Footer Start -->
               <table align="center" border="0" cellpadding="0" cellspacing="0" width="600" style="border-collapse: collapse;">
                  <tr>
                     <td>
                        <table bgcolor="#ffffff" align="center" border="0" cellpadding="0" cellspacing="0" width="580" style="border-collapse: collapse;">
                           <tr>
                              <td>
                                 <!-- Space -->
                                 <table width="100%" align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
                                    <tr>
                                       <td style="font-size: 0; line-height: 0;" height="30">&nbsp;</td>
                                    </tr>
                                 </table>
                                 <!-- Space -->
                                 <table width="100%" align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
                                    <tr>
                                       <td style="font-size: 0; line-height: 0;" height="30">&nbsp;</td>
                                    </tr>
                                 </table>
                              </td>
                           </tr>
                        </table>
                     </td>
                  </tr>
               </table>
               <!-- Footer End -->
               <!-- Subfooter Start -->
               <table align="center" border="0" cellpadding="0" cellspacing="0" width="600" style="border-collapse: collapse;">
                  <tr>
                     <td>
                        <table bgcolor="#05232d" align="center" border="0" cellpadding="0" cellspacing="0" width="580" style="border-collapse: collapse;">
                           <tr>
                              <td>
                                 <!-- Space -->
                                 <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;">
                                    <tr>
                                       <td style="font-size: 0; line-height: 0;" bgcolor="#eaeaea" height="1">&nbsp;</td>
                                    </tr>
                                    <tr>
                                       <td style="font-size: 0; line-height: 0;" height="20">&nbsp;</td>
                                    </tr>
                                 </table>
                                 <table align="center" border="0" cellpadding="0" cellspacing="0" width="540" style="border-collapse: collapse;">
                                    <tr>
                                       <td align="center" style="color: #999999; font-size: 14px; line-height: 18px; font-weight: normal; font-family: helvetica, Arial, sans-serif;">
                                          Copyright © 2018 BEYOND FITNESS. All Rights Reserved / <a href="#" style="color: #dc5b5b; font-size: 14px; line-height: 18px; font-weight: normal; font-family: helvetica, Arial, sans-serif; text-decoration:none;"> Unsubscribe</a>
                                       </td>
                                    </tr>
                                 </table>
                                 <!-- Space -->
                                 <table width="100%" align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse;">
                                    <tr>
                                       <td style="font-size: 0; line-height: 0;" height="20">&nbsp;</td>
                                    </tr>
                                 </table>
                              </td>
                           </tr>
                        </table>
                     </td>
                  </tr>
               </table>
               <!-- Subfooter End -->
            </td>
         </tr>
      </table>
   </body>
</html>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (String)this.Model;
    }

</script>