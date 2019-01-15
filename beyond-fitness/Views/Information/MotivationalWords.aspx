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
            <i class="fa fa-lightbulb"></i>
        </span>
    </span>

    <!-- breadcrumb -->
    <ol class="breadcrumb">
        <li>上稿管理</li>
        <li>每日激勵小語</li>
    </ol>

</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <section id="widget-grid" class="">
        <div class="row">
            <!-- NEW WIDGET START -->
            <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">

                <!-- Widget ID (each widget will need unique ID)-->
                <div class="jarviswidget" id="wid-id-0" data-widget-togglebutton="false" data-widget-editbutton="false" data-widget-fullscreenbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false">
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
                        <span class="widget-icon"><i class="fa fa-table"></i></span>
                        <h2>每日激勵小語列表</h2>
                        <div class="widget-toolbar">
                            <a href="<%= Url.Action("EditMotivationalWords","Information") %>" class="btn btn-primary"><i class="fa fa-fw fa-pencil-alt"></i>新增激勵小語</a>
                        </div>
                    </header>

                    <!-- widget div-->
                    <div>

                        <!-- widget edit box -->
                        <div class="jarviswidget-editbox">
                            <!-- This area used as dropdown edit box -->
                        </div>
                        <!-- end widget edit box -->

                        <!-- widget content -->
                        <div class="widget-body no-padding">
                            <!-- content -->
                            <%  Html.RenderPartial("~/Views/Information/Module/MotivationalWordsList.ascx", _model); %>

                            <!-- end content -->
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

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    IQueryable<Article> _model;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (IQueryable<Article>)this.Model;

    }



</script>
