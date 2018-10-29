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
                <i class="fa fa-street-view"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>人員管理></li>
            <li>員工管理</li>
            <li>問卷調查表</li>
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
        <i class="fa-fw fa fa-street-view"></i> 學員管理
                            <span>>  
                                問卷調查表
                            </span>
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">
        <article class="col-xs-12 col-sm-12 col-md-9 col-lg-9">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget jarviswidget-color-blueDark" id="wid-id-6" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-editbutton="false" data-widget-fullscreenbutton="false" data-widget-deletebutton="false">
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
                    <h2><strong>方案設計工具結果</strong></h2>
                    <div class="widget-toolbar">

                        <div class="progress progress-striped active" rel="tooltip" data-original-title="100%" data-placement="bottom">
                            <div class="progress-bar progress-bar-success" role="progressbar" style="width: 100%">100%</div>
                        </div>

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
                    <div class="widget-body bg-color-darken txt-color-white no-padding">
                        <form action="<%= VirtualPathUtility.ToAbsolute("~/Member/UpdatePDQ/") + _model.UID %>" id="pageForm" class="smart-form" method="post">
                            <input type="hidden" name="groupID" value="0" />
                            <fieldset>
                                <div class="row">
                                    <section class="col col-4">
                                        <label>請選擇【目標】合適結果</label>
                                        <label class="select">
                                            <select class="input-lg" name="goalID">
                                                <%  foreach (var item in models.GetTable<GoalAboutPDQ>())
                                                { %>
                                                <option value="<%= item.GoalID %>"><%= item.Goal %></option>
                                                <%  } %>
                                            </select>
                                            <i></i>
                                            <%  if (_model.PDQUserAssessment != null)
                                            { %>
                                            <script>
                                            $('select[name="goalID"]').val(<%= _model.PDQUserAssessment.GoalID %>)
                                            </script>
                                            <%  } %>
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label>請選擇【風格】合適結果</label>
                                        <label class="select">
                                            <select class="input-lg" name="styleID">
                                                <%  foreach (var item in models.GetTable<StyleAboutPDQ>())
                                                { %>
                                                <option value="<%= item.StyleID %>"><%= item.Style %></option>
                                                <%  } %>
                                            </select>
                                            <i></i>
                                            <%  if (_model.PDQUserAssessment != null)
                                            { %>
                                            <script>
                                            $('select[name="styleID"]').val(<%= _model.PDQUserAssessment.StyleID %>)
                                            </script>
                                            <%  } %>
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label>請選擇【訓練水準】合適結果</label>
                                        <label class="select">
                                            <select class="input-lg" name="levelID">
                                                <%  foreach (var item in models.GetTable<TrainingLevelAboutPDQ>())
                                                { %>
                                                <option value="<%= item.LevelID %>"><%= item.TrainingLevel %></option>
                                                <%  } %>
                                            </select>
                                            <i></i>
                                            <%  if (_model.PDQUserAssessment != null)
                                            { %>
                                            <script>
                                            $('select[name="levelID"]').val(<%= _model.PDQUserAssessment.LevelID %>)
                                            </script>
                                            <%  } %>
                                        </label>
                                    </section>
                                </div>
                            </fieldset>

                            <div class="widget-footer">

                                <button class="btn btn-lg btn-success" type="button" onclick="saveAll(true);">
                                    完成問卷
                                </button>

                                <button class="btn btn-lg btn-danger pull-left" type="button" onclick="saveAll(false);">
                                    上一步
                                </button>

                            </div>


                        </form>

                    </div>
                    <!-- end widget content -->

                </div>
                <!-- end widget div -->

            </div>
            <!-- end widget -->
        </article>

        <!-- NEW COL START -->
        <article class="col-xs-12 col-sm-12 col-md-3 col-lg-3">
            <!-- /well -->
            <div class="well bg-color-darken txt-color-white padding-10">
                <h5 class="margin-top-0"><i class="fa fa-external-link"></i> 快速功能</h5>
                <ul class="no-padding no-margin">
                    <p class="no-margin">
                        <ul class="icons-list">
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ListLearners.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ViewLessons.ascx",_model); %>
                            <%--<%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/AddPDQ.ascx",_model); %>--%>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/LearnerFitness.ascx",_model); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ShowLearner.ascx",_model); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/EditLearner.ascx",_model); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/Overview.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ViewVip.ascx",_model); %>
                        </ul>
                    </p>
                </ul>
            </div>
            <!-- /well -->

        </article>
        <!-- END COL -->

    </div>
    
    <script>

        function saveAll(next) {
            $('#pageForm').ajaxForm({
                url: "<%= VirtualPathUtility.ToAbsolute("~/Member/UpdatePDQ/") + _model.UID %>",
                beforeSubmit: function () {
                },
                success: function (data) {
                    if (data.result) {
                        smartAlert("資料已儲存!!", function (message) {
                            if (next)
                                window.location.href = '<%= VirtualPathUtility.ToAbsolute("~/Member/ListLearners") %>';
                            else
                                window.location.href = '<%= VirtualPathUtility.ToAbsolute("~/Member/PDQ") + "?id=" + _model.UID  %>' + "&groupID=5";
                        });
                    } else {
                        smartAlert(data.message);
                    }
                },
                error: function () {
                }
            }).submit();
        }

    </script>
</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;

    }

</script>
