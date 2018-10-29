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
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-edit"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>基本資料維護作業></li>
            <li>課程類別維護</li>
            <li>新增類別</li>
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
        <i class="fa-fw fa fa-edit"></i>基本資料維護作業
							<span>>  
								課程類別維護
                            </span>
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">

        <!-- NEW COL START -->
        <article class="col-xs-12 col-sm-12 col-md-8 col-lg-8">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget" id="wid-id-6" data-widget-editbutton="false" data-widget-custombutton="false" data-widget-editbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false" data-widget-colorbutton="false">
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
                    <h2>填寫相關資 </h2>

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

                        <form action="<%= VirtualPathUtility.ToAbsolute("~/SystemInfo/CommitLessonPrice") %>" id="pageForm" class="smart-form" method="post">
                            <input type="hidden" name="priceID" value="<%= _viewModel.PriceID %>" />
                            <fieldset>
                                <div class="row">
                                    <section class="col col-6">
                                        <label class="label">課程類別</label>
                                        <label class="input">
                                            <i class="icon-append fa fa-bars"></i>
                                            <input type="text" name="description" id="description" maxlength="20" value="<%= _viewModel.Description %>" class="input-lg" placeholder="請輸入課程類別" />
                                        </label>
                                    </section>
                                    <section class="col col-6">
                                        <label class="label">是否開放全員使用</label>
                                        <div class="inline-group">
                                            <label class="radio">
                                                <input type="radio" name="usageType" <%= _viewModel.UsageType!=0 ? "checked" : null %> value="1" />
                                                <i></i>是</label>
                                            <label class="radio">
                                                <input type="radio" name="usageType" <%= _viewModel.UsageType==0 ? "checked" : null %> value="0"/>
                                                <i></i>否</label>
                                        </div>
                                    </section>
                                </div>
                            </fieldset>
                            <fieldset>
                                <div class="row">
                                    <section class="col col-4">
                                        <label class="label">原價金額</label>
                                        <label class="input">
                                            <i class="icon-append fa fa-money"></i>
                                            <input type="text" name="listPrice" id="listPrice" value="<%= _viewModel.ListPrice %>" maxlength="20" class="input-lg" placeholder="請輸入原價金額" />
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label class="label">鐘點費用(現金)</label>
                                        <label class="input">
                                            <i class="icon-append fa fa-money"></i>
                                            <input type="text" name="coachPayoff" id="coachPayoff" value="<%= _viewModel.CoachPayoff %>" maxlength="20" class="input-lg" placeholder="請輸入鐘點費用(現金)" />
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label class="label">鐘點費用(信用卡)</label>
                                        <label class="input">
                                            <i class="icon-append fa fa-credit-card"></i>
                                            <input type="text" name="coachPayoffCreditCard" id="coachPayoffCreditCard" value="<%= _viewModel.CoachPayoffCreditCard %>" maxlength="20" class="input-lg" placeholder="請輸入鐘點費用(信用卡)" />
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <footer>
                                <button type="submit" name="submit" class="btn btn-primary">
                                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                                </button>
                            </footer>
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
                <h5 class="margin-top-0"><i class="fa fa-external-link"></i> 快速功能</h5>
                <ul class="no-padding no-margin">
                    <p class="no-margin">
                        <ul class="icons-list">
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/Overview.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/VipOverview.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ListLearners.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ListCoaches.ascx"); %>
                        </ul>
                    </p>
                </ul>
            </div>
            <!-- /well -->


        </article>
        <!-- END COL -->

    </div>
    <script>

        $(function () {
            $('#description').rules('add', {
                'required': true,
                messages: {
                    'required': '請輸入類別名稱'
                }
            });

            $('#listPrice').rules('add', {
                'required': true,
                messages: {
                    'required': '請輸入金額'
                }
            });

            $('#coachPayoff').rules('add', {
                'required': true,
                messages: {
                    'required': '請輸入金額'
                }
            });

            $('#coachPayoffCreditCard').rules('add', {
                'required': true,
                messages: {
                    'required': '請輸入金額'
                }
            });

        });
    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    LessonPriceViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _viewModel = (LessonPriceViewModel)ViewBag.ViewModel;
    }



</script>
