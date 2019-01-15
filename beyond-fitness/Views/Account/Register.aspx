<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <!-- RIBBON -->
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-user"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>會員註冊</li>
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
        <i class="fa-fw fa fa-user"></i>會員註冊
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">

        <!-- NEW COL START -->
        <article class="col-xs-12 col-sm-12 col-md-8 col-lg-8">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget" id="wid-id-6" data-widget-editbutton="false" data-widget-custombutton="false" data-widget-colorbutton="false" data-widget-editbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
                <!-- widget options:
									usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">
									
									data-widget-colorbutton="false"	
									data-widget-editbutton="false"
									data-widget-togglebutton="false"
									data-widget-deletebutton="false"
									data-widget-fullscreenbutton="false"
									data-widget-custombutton="false"
									data-widget-collapsed="true" 
									data-widget-sortable="false"
									
								-->
                <header>
                    <span class="widget-icon"><i class="fa fa-edit"></i></span>
                    <h2>Step1.輸入會員編號 </h2>

                </header>

                <!-- widget div-->
                <div>

                    <!-- widget edit box -->
                    <div class="jarviswidget-editbox">
                        <!-- This area used as dropdown edit box -->

                    </div>
                    <!-- end widget edit box -->

                    <!-- widget content -->
                    <div class="widget-body no-padding bg-color-darken txt-color-white">
                        <%  Html.RenderPartial("~/Views/Account/Module/RegisterForm.ascx"); %>
                    </div>
                    <!-- end widget content -->

                </div>
                <!-- end widget div -->

            </div>
            <!-- end widget -->
        </article>
        <!-- END COL -->

        <!-- NEW COL START -->
        <%  Html.RenderPartial("~/Views/Layout/QuickLink.ascx"); %>
        <!-- END COL -->
    </div>
    <script>

        $('#btnSend').on('click', function (evt) {

            var form = $(this)[0].form;
            form.submit();

        });

    </script>
    <script>
        $('#vip,#m_vip').addClass('active');
        $('#theForm').addClass('contact-form');

        var fbLogined = false;
        var memberCodeChecked = false;
        var fbLogoutRequired = false;

        function checkMemberCode(channel) {

            var $memberCode = $('#memberCode').val();
            if ($memberCode == '') {
                $('#memberCode-error').css('display', 'block');
                $('#memberCode-error').text('請輸入學員編號!!');
                return;
            }

            $.post('<%= VirtualPathUtility.ToAbsolute("~/Account/CheckMemberCode") %>', { 'memberCode': $memberCode }, function (data) {
                if (data.result) {
                    memberCodeChecked = true;
                    if (channel == 'fb') {
                        if (!fbLogined) {
                            fbSignOn();
                        } else {
                            registerByFB();
                        }
                    } else {
                        registerByMail();
                    }
                } else {
                    $('#memberCode-error').css('display', 'block');
                    $('#memberCode-error').text(data.message);
                }
            });
        }

        function fbSignOn() {
            FB.login(function (response) {
                statusChangeCallback(response);
                if (fbLogined) {
                    if (memberCodeChecked) {
                        registerByFB();
                    }
                }
            }, { scope: 'public_profile,email' });
        }

        $('#btnFB').on('click', function (evt) {

            if (!memberCodeChecked) {
                checkMemberCode('fb');
            } else if (fbLogined) {
                registerByFB();
            } else {
                fbSignOn();
            }
        });

        $('#btnMail').on('click', function (evt) {
            if (!memberCodeChecked) {
                checkMemberCode('mail');
            } else {
                registerByMail();
            }
        });

        function registerByMail() {
            $('#loading').css('display', 'table');
            $('#theForm').prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Account/RegisterByMail") %>')
              .submit();
        }


    </script>
    <% if (ViewBag.Message != null)
        { %>
    <script>
        $(function () {
            $('#memberCode-error').css('display', 'block');
            $('#memberCode-error').text('<%= ViewBag.Message %>');
            fbLogoutRequired = true;
        });
    </script>
    <%  } %>

    <script>
        // This is called with the results from from FB.getLoginStatus().
        function statusChangeCallback(response) {
            console.log('statusChangeCallback');
            console.log(JSON.stringify(response));
            // The response object is returned with a status field that lets the
            // app know the current login status of the person.
            // Full docs on the response object can be found in the documentation
            // for FB.getLoginStatus().
            if (response.status === 'connected') {
                // Logged into your app and Facebook.
                if (fbLogoutRequired) {
                    logoutFB();
                    fbLogoutRequired = false;
                } else {
                    fbLogined = true;
                }
            } else if (response.status === 'not_authorized') {
                // The person is logged into Facebook, but not your app.
                //document.getElementById('status').innerHTML = 'Please log ' +
                //  'into this app.';
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

            FB.getLoginStatus(function (response) {
                statusChangeCallback(response);
            });

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
        function registerByFB() {
            startLoading();
            console.log('Welcome!  Fetching your information.... ');
            FB.api('/me/picture', function (response) {
                $.post('<%= VirtualPathUtility.ToAbsolute("~/Account/FetchPicture") %>', { 'imgUrl': response.data.url }, function (data) {
                    if (data.result) {
                        $('#pictureID').val(data.pictureID);
                    }

                    FB.api('/me?fields=id,name,email', function (response) {
                        $('#userName').val(response.name);
                        $('#userID').val(response.id);
                        $('#email').val(response.email);
                        $('form').prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Account/RegisterByFB") %>')
                          .submit();
                        //console.log('Successful login for: ' + response.name);
                        //document.getElementById('status').innerHTML =
                        //  'Thanks for logging in, ' + response.name + '!';
                    });
                });
            });
        }

        function logoutFB() {
            FB.logout(function (response) {
                console.log(response);
            });
        }
    </script>

</asp:Content>
<script runat="server">

    ModelStateDictionary _modelState;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
    }
</script>
