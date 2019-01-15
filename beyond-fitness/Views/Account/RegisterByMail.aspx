<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>
<%@ Register Src="~/Views/Shared/LockScreen.ascx" TagPrefix="uc1" TagName="LockScreen" %>


<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
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
                    <h2>Step2.輸入資本資料 </h2>

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
                        <%  Html.RenderPartial("~/Views/Account/Module/RegisterByMailForm.ascx"); %>
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

        $('#nextStep').on('click', function (evt) {
            startLoading();
            $('form').prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Account/CompleteRegister") %>')
              .submit();

        });

        $('#EMail').rules('add', {
            'required': true,
            'email': true,
            messages: {
                'required': '請輸入您的 email address',
                'email': '請輸入合法的 email address'
            }
        });

        $('#UserName').rules('add', {
            'required': true,
            messages: {
                'required': '請輸入您的暱稱'
            }
        });

    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
    }



</script>
