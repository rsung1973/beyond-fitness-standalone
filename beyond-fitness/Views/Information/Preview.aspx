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

            <div class="navbar" style="min-height: 30px;">
                <div class="search-side">
                    <a href="<%= Request.UrlReferrer %>" class="btn-system btn-small">回上頁 <i class="fa fa-reply" aria-hidden="true"></i></a>
                </div>
            </div>

            <div class="hr1" style="margin-top: 5px; margin-bottom: 10px;"></div>

            <div class="row blog-page">

                <!-- Start Blog Posts -->
                <div class="col-md-12">

                    <!-- Start Big Heading -->
                    <p class="title-desc"><span class="accent-color"><%= _item.Document.DocDate.ToString("yyyy-MM-dd") %> <%: _item.AuthorID.HasValue ? _item.UserProfile.UserName : ""  %></span></p>
                    <h4 class="classic-title"><span><%= _item.Title  %></span></h4>
                    <!-- End Big Heading -->

                    <!-- Some Text -->
                    <p><%= _item.ArticleContent %></p>

                </div>
                <!-- End Blog Posts -->

            </div>

        </div>
    </div>
    <!-- End content -->
    <script>
        $('#vip,#m_vip').addClass('active');
    </script>
</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    Article _item;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _item = (Article)this.Model;
    }


</script>