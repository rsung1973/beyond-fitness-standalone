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

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <uc1:PageBanner runat="server" ID="PageBanner" Title="會員專區" TitleInEng="VIP" />

    <!-- Start Content -->
    <div id="content">
        <div class="container">

            <div class="row">

                <div class="col-md-8">

                    <!-- Classic Heading -->
                    <h4 class="classic-title"><span class="far fa-calendar-check"> 新增/刪除上課數完成</span></h4>
                    <!-- Stat Search -->
                    <!-- Start Post -->
                    <% Html.RenderPartial("~/Views/Member/MemberInfo.ascx", _model); %>
                    <!-- TABLE 1 -->
                    <%  ViewBag.ShowOnly = true;
                        Html.RenderPartial("~/Views/Member/LessonsList.ascx", _items); %>
                    <div class="hr1" style="margin-bottom: 10px;"></div>

                    <div class="tabs-section">

                        <div class="hr1" style="margin: 5px 0px;"></div>

                        <!--<div style="height:60px;border:1px solid #000;">驗證碼區塊</div>-->

                        <div class="hr1" style="margin: 5px 0px;"></div>
                        <a class="btn-system btn-medium" href="<%= VirtualPathUtility.ToAbsolute("~/Member/ListAll") %>">回清單頁 <i class="fa fa-th-list" aria-hidden="true"></i></a>

                        <!-- End Contact Form -->

                    </div>
                    <!-- End Post -->
                </div>
            </div>
        </div>
    </div>
    <!-- End content -->

    <script>
        $('#vip,#m_vip').addClass('active');
        $('#theForm').addClass('contact-form');

    </script>
</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    IQueryable<RegisterLesson> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;

        _items = models.GetTable<RegisterLesson>()
            .Where(r=>r.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
            .Where(r => r.UID == _model.UID)
            .OrderByDescending(r => r.RegisterID);
    }


</script>
