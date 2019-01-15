<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" EnableViewState="false" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Register Src="~/Views/Shared/PagingControl.ascx" TagPrefix="uc1" TagName="PagingControl" %>


<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <!-- RIBBON -->
    <div id="ribbon">
        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-puzzle-piece"></i>
            </span>
        </span>
        <ol class="breadcrumb">
            <li>專業知識</li>
        </ol>
    </div>
    <!-- END RIBBON -->
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-puzzle-piece"></i>專業知識
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">

        <div class="col-sm-9">

            <div class="well well-sm bg-color-darken txt-color-white padding-10">

                <asp:Repeater ID="rpList" runat="server" ItemType="WebHome.Models.DataEntity.Article">
                    <ItemTemplate>
                        <div class="row">
                            <div class="col-md-4">
                                <img runat="server" class="img-responsive" alt="img" src='<%# Item.Illustration.HasValue ? VirtualPathUtility.ToAbsolute("~/Information/GetResource/")+Item.Attachment.AttachmentID.ToString()+"?stretch=true" : VirtualPathUtility.ToAbsolute("~/images/blog_pic.png") %>' />
                                <ul class="list-inline padding-10">
                                    <li>
                                        <i class="fa fa-calendar-alt"></i>
                                        <a><%# Item.Document.DocDate.ToString("yyyy-MM-dd") %></a>
                                    </li>
                                </ul>
                            </div>

                            <div class="col-md-8 padding-left-0">
                                <h3 class="margin-top-0"><a href="<%# VirtualPathUtility.ToAbsolute("~/Information/BlogDetail/"+ Item.DocID.ToString())  %>">《<%# Item.Title %>》 </a>
                                    <br>
                                    <small class="font-xs"><i>撰文者： <a href="<%# VirtualPathUtility.ToAbsolute("~/Account/ViewProfile/") + Item.AuthorID %>"><%# Item.AuthorID.HasValue ? Item.UserProfile.RealName : null %></a></i></small></h3>
                                <p>
                                    <%# getBrief(Item.ArticleContent) %>
                                </p>
                                <a class="btn btn-primary" href="<%# VirtualPathUtility.ToAbsolute("~/Information/BlogDetail/"+ Item.DocID.ToString())  %>">Read more </a>
                            </div>
                        </div>
                        <hr />
                    </ItemTemplate>
                </asp:Repeater>
                <!-- Start Pagination -->
                <uc1:PagingControl runat="server" ID="pagingControl" ControllerName="Information" ActionName="Blog" />
                <!-- End Pagination -->

            </div>

        </div>

        <div class="col-sm-3">
            <!-- /well -->
            <div class="well well-sm bg-color-darken txt-color-white padding-10">
                <h5 class="margin-top-0"><i class="fa fa-tags"></i>熱門關鍵字:</h5>
                <div class="row">
                    <div class="col-md-6 col-lg-6">
                        <ul class="list-unstyled">
                            <li>
                                <a href=""><span class="badge badge-info">啞鈴訓練</span></a>
                            </li>
                            <li>
                                <a href=""><span class="badge badge-info">單邊訓練</span></a>
                            </li>
                            <li>
                                <a href=""><span class="badge badge-info">團體課程</span></a>
                            </li>
                            <li>
                                <a href=""><span class="badge badge-info">均衡訓練</span></a>
                            </li>
                            <li>
                                <a href=""><span class="badge badge-info">奧林匹克槓片</span></a>
                            </li>
                        </ul>
                    </div>
                    <div class="col-md-6 col-lg-6">
                        <ul class="list-unstyled">
                            <li>
                                <a href=""><span class="badge badge-info">增強式訓練</span></a>
                            </li>
                            <li>
                                <a href=""><span class="badge badge-info">壺鈴</span></a>
                            </li>
                            <li>
                                <a href=""><span class="badge badge-info">多關節活動</span></a>
                            </li>
                            <li>
                                <a href=""><span class="badge badge-info">孕婦運動</span></a>
                            </li>
                            <li>
                                <a href=""><span class="badge badge-info">女性減脂</span></a>
                            </li>
                            <li>
                                <a href=""><span class="badge badge-info">女性運動</span></a>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
            <!-- /well -->
            <%  Html.RenderPartial("~/Views/Layout/SNS.ascx"); %>
            <!-- /well -->

            <!-- /well -->
            <div class="well well-sm bg-color-darken txt-color-white padding-10">
                <h5 class="margin-top-0"><i class="fa fa-video-camera"></i>Featured Videos:</h5>
                <div class="row">

                    <div class="col-lg-12">
                        <div class="margin-top-10">
                            <iframe allowfullscreen="" frameborder="0" height="210" mozallowfullscreen="" src="https://www.youtube.com/embed/UJAL4myl3c8" webkitallowfullscreen="" width="100%"></iframe>
                        </div>
                    </div>
                </div>

            </div>
            <!-- /well -->
        </div>
    </div>
    <script>
        $('#blog,#m_blog').addClass('active');
    </script>
</asp:Content>

<script runat="server">

    ModelSource<UserProfile> models;
    IQueryable<Article> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _items = (IQueryable<Article>)this.Model;
        rpList.DataSource = _items;
        rpList.DataBind();
        pagingControl.Item = (PagingIndexViewModel)ViewBag.PagingModel;
        pagingControl.RecordCount = models.GetDataContext().GetNormalArticles(models.GetTable<Article>()).Count();
    }

    String getBrief(String content)
    {
        if (content == null)
            return null;
        String result = Regex.Replace(content.Substring(0, Math.Min(500, content.Length)), "<\\s*[Bb][Rr]\\s*/?\\s*>", "\r\n").Trim();
        result = Regex.Replace(result, @"<[^>]+>|&nbsp;", String.Empty);
        result = Regex.Replace(result, "(\\r\\n){2,}", "\r\n");
        return result.Length > 100 ? (result.Substring(0, 100) + "...").Replace("\r\n", "<br/>") : result.Replace("\r\n", "<br/>");
    }

</script>
