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


<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-key"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>變更密碼</li>
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
        <i class="fa-fw fa fa-key"></i>變更密碼
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
                    <h2>填寫相關資訊 </h2>

                </header>

                <!-- widget div-->
                <div>

                    <!-- widget edit box -->
                    <div class="jarviswidget-editbox">
                        <!-- This area used as dropdown edit box -->

                    </div>
                    <!-- end widget edit box -->

                    <!-- widget content -->
                    <div class="widget-body bg-color-darken txt-color-white no-padding">

                        <form action="<%= VirtualPathUtility.ToAbsolute("~/Account/ResetPass") %>" id="pageForm" class="smart-form">

                            <fieldset>
                                <section>
                                    <label class="input state-disabled">
                                        <i class="icon-append fa fa-envelope-o"></i>
                                        <input class="form-control input-lg" disabled="disabled" value="<%= _item.PID %>" type="email" name="email" id="email">
                                    </label>
                                </section>

                            </fieldset>
                            <fieldset>
                                <section>
                                    <%  ViewBag.Success = "密碼設定完成，請重新登入。";
                                        Html.RenderPartial("~/Views/Shared/Success.ascx"); %>
                                </section>
                            </fieldset>
                        </form>

                    </div>
                    <!-- end widget content -->

                </div>
                <!-- end widget div -->
            </div>
            <!-- end widget -->
        </article>
        <!-- END COL -->

        <!-- NEW COL START -->
        <article class="col-xs-12 col-sm-12 col-md-4 col-lg-4">
            <!-- /well -->
            <div class="well bg-color-darken txt-color-white padding-10">
                <h5 class="margin-top-0"><i class="fa fa-envelope"></i>聯絡我們</h5>
                <ul class="no-padding no-margin">
                    <ul class="icons-list">
                        <li>
                            <a title="電話" href="tel:+886227152733"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-phone fa-stack-1x"></i></span>(02)2715-2733</a>
                        </li>
                        <li>
                            <a title="地址"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-map-marker fa-stack-1x"></i></span>台北市松山區南京東路四段17號B1</a>
                        </li>
                        <li>
                            <a title="Email" href="mailto:info@beyond-fitness.tw"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-envelope-o fa-stack-1x"></i></span>info@beyond-fitness.tw</a>
                        </li>
                    </ul>
                </ul>
            </div>
            <!-- /well -->
            <!-- /well -->
            <div class="well bg-color-darken txt-color-white padding-10">
                <h5 class="margin-top-0"><i class="fa fa-external-link"></i> 快速功能</h5>
                <ul class="no-padding no-margin">
                    <p class="no-margin">
                        <ul class="icons-list">
                            <li>
                                <a href="<%= VirtualPathUtility.ToAbsolute("~/Information/ContactUs") %>" title="聯絡我們"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-sign-in fa-stack-1x"></i></span>登入</a>
                            </li>
                            <li>
                                <a href="<%= VirtualPathUtility.ToAbsolute("~/Account/Register") %>" title="註冊"><span class="fa-stack fa-lg"><i class="fa fa-square-o fa-stack-2x"></i><i class="fa fa-user fa-stack-1x"></i></span>會員註冊</a>
                            </li>
                        </ul>
                    </p>
                </ul>
            </div>
            <!-- /well -->
        </article>
        <!-- END COL -->

    </div>

    <script>
        $('#vip,#m_vip').addClass('active');
        $('#theForm').addClass('contact-form');

        $('#nextStep').on('click', function (evt) {
            startLoading();
            $('form').prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Account/ForgetPassword") %>')
              .submit();

        });
    </script>


</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _item;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _item = (UserProfile)this.Model;
    }

</script>
