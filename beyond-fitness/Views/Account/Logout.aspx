<%@ Page Title="" Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

    <script>

        function statusChangeCallback(response) {

            console.log('statusChangeCallback');
            console.log(JSON.stringify(response));

            if (response.status === 'connected') {
                // Logged into your app and Facebook.
                logoutFB();

            } else if (response.status === 'not_authorized') {
                // The person is logged into Facebook, but not your app.
                logoutFB();

            } else {
                // The person is not logged into Facebook, so we're not sure if
                // they are logged into this app or not.
                //document.getElementById('status').innerHTML = 'Please log ' +
                //  'into Facebook.';
            }
        }

        // This function is called when someone finishes with the Login
        // Button.  See the onlogin handler attached to it in the sample
        // code below.
        function checkLoginState() {
            FB.getLoginStatus(function (response) {
                statusChangeCallback(response);
            });
        }

        window.fbAsyncInit = function () {
            FB.init({
                appId: '1027299250717597', //'1552642415030511',
                cookie: true,  // enable cookies to allow the server to access
                // the session
                xfbml: true,  // parse social plugins on this page
                version: 'v2.2' // use version 2.2
            });

            FB.getLoginStatus(function (response) {
                statusChangeCallback(response);
            });

            window.location.href = '<%= FormsAuthentication.LoginUrl %>';

        };

        // Load the SDK asynchronously
        (function (d, s, id) {
            var js, fjs = d.getElementsByTagName(s)[0];
            if (d.getElementById(id)) return;
            js = d.createElement(s); js.id = id;
            js.src = "//connect.facebook.net/en_US/sdk.js";
            fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));

        // Here we run a very simple test of the Graph API after login is
        // successful.  See statusChangeCallback() for when this call is made.
        function logoutFB() {
            FB.logout(function (response) {
                console.log(response);
            });
        }
    </script>

<script runat="server">

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        Context.ClearCache();
        //Response.Redirect("~/Account/Login");
        //Response.Redirect("/front-end/index.html");
        Response.Redirect("~/CornerKick/Index");
    }
</script>
