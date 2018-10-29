<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-heart"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>人員管理></li>
            <li>學員管理</li>
            <li>檢測體能</li>
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
        <i class="fa-fw fa fa-heart"></i>學員管理
                            <span>>  
                                檢測體能
                            </span>
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">

        <!-- NEW COL START -->
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
                    <span class="widget-icon"><i class="fa fa-heart"></i></span>
                    <h2><%= _profile.FullName() %>的體能檢測表 </h2>
                    <div class="widget-toolbar">
                        <a onclick="addAssessment(<%= _profile.UID %>)" class="btn btn-primary"><i class="fa fa-fw fa-plus"></i>新增測試項目</a>
                    </div>
                </header>

                <!-- widget div-->
                <div>

                    <!-- widget content -->
                    <div id="assessmentList" class="widget-body bg-color-darken txt-color-white no-padding">
                        <%  Html.RenderPartial("~/Views/Activity/FitnessAssessmentList.ascx", _model); %>
                    </div>
                    <!-- end widget content -->

                </div>
                <!-- end widget div -->

            </div>
            <!-- end widget -->

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
                    <span class="widget-icon"><i class="fa fa-bar-chart"></i></span>
                    <h2>平均檢測數據 </h2>
                </header>

                <!-- widget div-->
                <div>

                    <!-- widget content -->
                    <div id="avgList" class="widget-body bg-color-darken txt-color-white no-padding">
                        <%  Html.RenderAction("AverageFitnessAssessment", "Activity", new { uid = _profile.UID }); %>
                    </div>
                    <!-- end widget content -->

                </div>
                <!-- end widget div -->

            </div>
            <!-- end widget -->
        </article>
        <!-- END COL -->

    </div>

    <%  Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>

    <script>

        function addAssessment(uid) {
            showLoading();
            $.post('<%= Url.Action("LearnerFitnessItem","Activity") %>', { 'uid': uid }, function (data) {
                $(data).appendTo($('#content'));
                hideLoading();
            });
        }

        function editAssessment(assessmentID) {
            showLoading();
            $.post('<%= Url.Action("EditFitnessAssessment","Activity") %>', { 'assessmentID': assessmentID }, function (data) {
                $(data).appendTo($('#content'));
                hideLoading();
            });
        }

        function deleteAssessment(assessmentID) {
            showLoading();
            $.post('<%= Url.Action("DeleteFitnessAssessment","Activity") %>', { 'assessmentID': assessmentID }, function (data) {
                $(data).appendTo($('#content'));
                hideLoading();
            });
        }

        function updateFitnessAssessment(itemID,assessmentDate,assessment) {
            showLoading(true);
            $.post('<%= Url.Action("UpdateFitnessAssessment","Activity") %>',
                { 
                    'uid': <%= _profile.UID %>,
                    'itemID': itemID,
                    'assessmentDate':assessmentDate,
                    'assessment':assessment 
                },
                function(data) {
                    hideLoading();
                    if(data.result) {
                        smartAlert('資料已儲存!!',function(){
                            showLoading(true);
                            $('#assessmentList').load('<%= Url.Action("FitnessAssessmentList","Activity",new { uid = _profile.UID }) %>',function(){
                            });
                            $('#avgList').load('<%= Url.Action("AverageFitnessAssessment","Activity",new { uid = _profile.UID }) %>',function(){
                                hideLoading();
                            });

                        });
                    }
                });
        }

        function commitFitnessAssessment(assessmentID,fitnessItem) {
            showLoading(true);
            $.post('<%= Url.Action("CommitFitnessAssessment","Activity") %>',
                { 
                    'assessmentID': assessmentID,
                    'fitnessItem': fitnessItem
                },
                function(data) {
                    hideLoading();
                    if(data.result) {
                        smartAlert('資料已儲存!!',function(){
                            showLoading(true);
                            $('#assessmentList').load('<%= Url.Action("FitnessAssessmentList","Activity",new { uid = _profile.UID }) %>',function(){
                            });
                            $('#avgList').load('<%= Url.Action("AverageFitnessAssessment","Activity",new { uid = _profile.UID }) %>',function(){
                                hideLoading();
                            });
                        });
                    }
                });
        }

        function deleteFitnessAssessment(assessmentID,itemID) {
            showLoading(true);
            $.post('<%= Url.Action("DeleteFitnessAssessment","Activity") %>',
                { 
                    'assessmentID': assessmentID,
                    'itemID': itemID
                },
                function(data) {
                    hideLoading();
                    if(data.result) {
                        smartAlert('資料已刪除!!',function(){
                            showLoading(true);
                            $('#assessmentList').load('<%= Url.Action("FitnessAssessmentList","Activity",new { uid = _profile.UID }) %>',function(){
                            });
                            $('#avgList').load('<%= Url.Action("AverageFitnessAssessment","Activity",new { uid = _profile.UID }) %>',function(){
                                hideLoading();
                            });
                        });
                    }
                });
        }

    </script>

</asp:Content>
<script runat="server">

    ModelStateDictionary _modelState;
    IQueryable<LearnerFitnessAssessment> _model;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (IQueryable<LearnerFitnessAssessment>)this.Model;
        _profile = (UserProfile)ViewBag.Profile;
    }

</script>
