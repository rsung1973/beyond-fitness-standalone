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
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <a href="#" class="list-group-item" id="testDialog_link"><i class="fa fa-key"></i>&nbsp;&nbsp;Test Dialog<i class="fa fa-angle-right pull-right"></i></a>

    <script>

        $('#testDialog_link').click(function () {
            showLoading();
            $.post('<%= Url.Action("Test","MyTest",new { view = "~/Views/MyTest/Module/TestDialog.ascx" }) %>', {}, function (data) {
                hideLoading();
                if (data) {
                    $(data).appendTo($('body'));
                }
            });
            return false;
        });
    </script>

</asp:Content>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;

        var item = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == 2470).First();
        models.CheckLearnerQuestionnaireRequest(item);
    }

</script>
