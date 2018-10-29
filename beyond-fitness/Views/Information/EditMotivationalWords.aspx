<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage2017.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">

    <span class="ribbon-button-alignment">
        <span id="refresh" class="btn btn-ribbon">
            <i class="fa fa-pencil-alt"></i>
        </span>
    </span>

    <!-- breadcrumb -->
    <ol class="breadcrumb">
        <li>上稿管理></li>
        <li>每日激勵小語</li>
        <li><%= _viewModel.DocID.HasValue ? "修改" : "新增" %>問題</li>
    </ol>
    <!-- end breadcrumb -->

</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <%--    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-pencil-alt"></i>每日激勵小語
                            <span>>  
                                <%= _viewModel.DocID.HasValue ? "修改" : "新增" %>問題
                            </span>
    </h1>--%>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <section id="widget-grid" class="">
        <div class="row">
            <!-- NEW WIDGET START -->
            <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
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
                        <h2>填寫激勵小語 </h2>

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

                            <form action="<%= Url.Action("CommitMotivationalWords","Information",new { docID = _viewModel.DocID }) %>" method="post" class="smart-form">
                                <fieldset>
                                    <section>
                                        <label class="input">
                                            <i class="icon-append far fa-keyboard"></i>
                                            <input type="text" class="input-lg" name="Title" maxlength="ˇ15" placeholder="請輸入激勵小語" value="<%= _viewModel.Title %>" />
                                        </label>
                                        <p class="note"><strong>Note:</strong> 最多僅能輸入15個中英文字</p>
                                    </section>
                                </fieldset>
                                <fieldset>
                                    <div class="row">
                                        <section class="col col-6">
                                            <label class="label">請輸入開始時間</label>
                                            <label class="input input-group">
                                                <i class="icon-append far fa-calendar-alt"></i>
                                                <input type="text" name="StartDate" id="StartDate" readonly="readonly" class="form-control input-lg date form_date" data-date-format="yyyy/mm/dd" placeholder="請輸入開始時間" value="<%= String.Format("{0:yyyy/MM/dd}", _viewModel.StartDate) %>" />
                                            </label>
                                        </section>
                                        <section class="col col-6">
                                            <label class="label">請輸入結束時間</label>
                                            <label class="input input-group">
                                                <i class="icon-append far fa-calendar-alt"></i>
                                                <input type="text" name="EndDate" id="EndDate" readonly="readonly" class="form-control input-lg date form_date" data-date-format="yyyy/mm/dd" placeholder="請輸入開始時間" value="<%= String.Format("{0:yyyy/MM/dd}", _viewModel.EndDate) %>" />
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
            <!-- WIDGET END -->


        </div>

    </section>
    <!-- row -->



    <script>

    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    MotivationalWordsViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _viewModel = (MotivationalWordsViewModel)ViewBag.ViewModel;

    }



</script>
