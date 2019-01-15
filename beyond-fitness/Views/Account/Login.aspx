<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>


<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <!-- RIBBON -->
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-sign-in"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>登入</li>
        </ol>
        <!-- end breadcrumb -->

        <!-- You can also add more buttons to the
				ribbon for further usability

				Example below:

				<span class="ribbon-button-alignment pull-right">
				<span id="search" class="btn btn-ribbon hidden-xs" data-title="search"><i class="fa-grid"></i> Change Grid</span>
				<span id="add" class="btn btn-ribbon hidden-xs" data-title="add"><i class="fa-plus"></i> Add</span>
				<span id="search" class="btn btn-ribbon" data-title="search"><i class="fa-search"></i> <span class="hidden-mobile">Search</span></span>
				</span> -->

    </div>
    <!-- END RIBBON -->
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-sign-in"></i>登入
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">

        <!-- NEW COL START -->
        <article class="col-xs-12 col-sm-12 col-md-8 col-lg-8">
            <!-- well -->
            <div class="well well-sm bg-color-darken txt-color-white">
                <h3>若您已有會員編號，第一次登入請先 
					<button type="button" name="submit" class="btn bg-color-blueDark" onclick="javascript:(window.location.href='<%= VirtualPathUtility.ToAbsolute("~/Account/Register") %>');">註冊 <i class="fa fa-user" aria-hidden="true" onclick="javascript:(window.location.href='<%= VirtualPathUtility.ToAbsolute("~/Account/Register") %>');"></i></button>
                </h3>
                <%--<p>
                    <button type="button" id="btnFB" name="fblogin" class="btn bg-color-blue btn-lg btn-block">
                        使用 Facebook 登入 <i class="fa fa-facebook" aria-hidden="true"></i>
                    </button>
                </p>--%>
                <p>
                    <button type="button" name="fblogin" class="btn bg-color-yellow btn-lg btn-block" onclick="javascript:(window.location.href='<%= VirtualPathUtility.ToAbsolute("~/Account/LoginByMail") %>');">
                        使用 Email 登入 <i class="fa fa-envelope-o" aria-hidden="true"></i>
                    </button>
                </p>

            </div>
            <!-- end well -->
        </article>
        <!-- END COL -->
        <!-- NEW COL START -->
        <% Html.RenderPartial("~/Views/Layout/QuickLink.ascx"); %>
        <!-- END COL -->

    </div>
    <br />
    <br />

    <script>

        function fbSignOn() {
            FB.login(function (response) {
                statusChangeCallback(response);
            }, { scope: 'public_profile,email' });
        }

        $('#btnFB').on('click', function (evt) {
            startLoading();
            fbSignOn();
        });
    </script>

    <script>

        function statusChangeCallback(response) {

            console.log('statusChangeCallback');
            console.log(JSON.stringify(response));

            if (response.status === 'connected') {
                // Logged into your app and Facebook.
                loginByFB(response.authResponse);

            } else if (response.status === 'not_authorized') {
                // The person is logged into Facebook, but not your app.
                loginByFB(response.authResponse);

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

            // Now that we've initialized the JavaScript SDK, we call
            // FB.getLoginStatus().  This function gets the state of the
            // person visiting this page and can return one of three states to
            // the callback you provide.  They can be:
            //
            // 1. Logged into your app ('connected')
            // 2. Logged into Facebook, but not your app ('not_authorized')
            // 3. Not logged into Facebook and can't tell if they are logged into
            //    your app or not.
            //
            // These three cases are handled in the callback function.

            //FB.getLoginStatus(function (response) {
            //    statusChangeCallback(response);
            //});

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
        function loginByFB(auth) {

            $.post('<%= VirtualPathUtility.ToAbsolute("~/Account/LoginByFB") %>', auth, function (data) {
                if (data.result) {
                    window.location.href = data.url;
                } else {
                    $('#btnFB-error').css('display', 'block');
                    $('#btnFB-error').text(data.message);
                    FB.logout(function (response) {
                        console.log(response);
                    });
                }
            });

        }
    </script>


</asp:Content>

<script runat="server">

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        //Response.Redirect("~/html/login.html");
        Response.Redirect("~/CornerKick/Index");
    }

</script>