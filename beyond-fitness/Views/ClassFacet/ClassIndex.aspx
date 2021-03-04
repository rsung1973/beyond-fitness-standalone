<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage2017.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <span class="ribbon-button-alignment">
        <span id="refresh" class="btn btn-ribbon">
            <i class="fa fa-edit"></i>
        </span>
    </span>
    <!-- breadcrumb -->
    <ol class="breadcrumb">
        <li>課程管理></li>
        <li>編輯上課內容</li>
    </ol>
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">
    <section id="widget-grid" class="">
        <%  Html.RenderPartial("~/Views/ClassFacet/Module/WidgetGrid.ascx", _model); %>
    </section>
    <script>
        function showLessonWidget(lessonID, registerID) {
            showLoading();
            $('#lessonWidget').load('<%= Url.Action("ShowLessonWidget","ClassFacet") %>', { 'lessonID': lessonID, 'registerID': registerID }, function (data) {
                hideLoading();
            });
        }

        function showUndone(lessonID, direction) {
            showLoading();
            $.post('<%= Url.Action("ShowUndone","ClassFacet") %>', { 'lessonID': lessonID, 'direction': direction }, function (data) {
                hideLoading();
                if (data) {
                    $('#widget-grid').html(data);
                } else {
                    alert('已無下一筆資料!!');
                }
            });
        }

        function rebookingByCoach() {
<%--            showLoading();
            $.post('<%= Url.Action("RebookingByCoach","ClassFacet",new { id = _model.LessonID }) %>', {}, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });--%>
        }

        $(function () {
            if (!$global.editLearner) {
                $global.editLearner = function (uid) {
                    startLoading();
                    $.post('<%= Url.Action("EditLearner","Learner") %>', { 'uid': uid }, function (data) {
                        hideLoading();
                        $(data).appendTo($('body'));
                    });
                };
            }
        });
    </script>
    <% Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>
</asp:Content>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    DailyBookingQueryViewModel _viewModel;
    LessonTime _model;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _viewModel = (DailyBookingQueryViewModel)ViewBag.ViewModel;
        _model = (LessonTime)this.Model;
    }


</script>
