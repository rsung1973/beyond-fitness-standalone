<%@ Page Title="" Language="C#" AutoEventWireup="true" MasterPageFile="~/Views/ConsoleHome/Template/MainPage.Master" Inherits="System.Web.Mvc.ViewPage" %>

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

<asp:Content ID="CustomHeader" ContentPlaceHolderID="CustomHeader" runat="server">
    <!-- Blog Css -->
    <link href="css/blog.css?1.0" rel="stylesheet" />

</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <script>
        $(function () {
            $global.viewModel = <%= JsonConvert.SerializeObject(_viewModel) %>;

            for (var i = 0; i < $global.onReady.length; i++) {
                $global.onReady[i]();
            }

            $global.onPaging = function (pageModel) {
                $.extend($global.viewModel, pageModel);
                showLoading();
                $('').launchDownload('<%= Url.Action("BlogArticleList","ConsoleHome") %>', $global.viewModel);
            };
        });
    </script>
    <!-- Main Content -->
    <section class="content blog-page">
        <%  ViewBag.BlockHeader = "我的部落格";
            ViewBag.InsertPartial = (Action)(() =>
            {
                Html.RenderPartial("~/Views/Blog/Module/CategoryIndication.ascx", _model); ;
            });
            Html.RenderPartial("~/Views/ConsoleHome/Module/BlockHeader.ascx", _model);
        %>
        <div class="container-fluid">            
                        <div class="row clearfix">
                <div class="col-sm-12">
                    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/PagingControl.ascx"); %>       
                </div>
                <%  var skipCount = _viewModel.CurrentIndex * _viewModel.PageSize;
                    if(skipCount.HasValue)
                    {
                        _items = _items.OrderByDescending(i => i.BlogID)
                            .Skip(skipCount.Value).Take(_viewModel.PageSize.Value);
                    }

                    foreach (var item in _items)
                    {   %>
                <div class="col-lg-4 col-md-6 col-sm-12">
                    <div class="card single_post">
                        <div class="body">
                            <h3 class="m-t-0 m-b-5"><a href="javascript:viewArticle(<%= item.DocID %>);"><%= item.Title %></a></h3>
                            <ul class="meta">  
                                <li><a><i class="zmdi zmdi-account col-blue"></i><%= item.UserProfile.FullName() %></a></li>
                                <li><a><i class="zmdi zmdi-calendar col-green"></i><%= $"{item.Document.DocDate:yyyy-MM-dd}" %></a></li>
                            </ul>
                            <ul class="meta">                                
                                <%  foreach (var t in item.BlogTag)
                                    {   %>
                                <li><a href="<%= Url.Action("BlogArticleList","ConsoleHome",new { t.CategoryID }) %>"><i class="zmdi zmdi-label col-pink"></i><%= t.BlogCategoryDefinition.Category %></a></li>
                                <%  }   %>
                            </ul>
                        </div>
                        <div class="body">
                            <div class="img-post">
                                <div id="carouselExampleControls" class="carousel slide" data-ride="carousel">
                                    <div class="img-post m-b-15">
                                        <%  var imgUrl = $"Blog/{item.BlogID}/images/Title.jpg"; %>
                                        <a href="javascript:editArticle(<%= item.DocID %>);"><img src="images/blog/DefaultTitle.jpg" onload="<%= System.IO.File.Exists(Server.MapPath(imgUrl)) ? $"this.onload = null;this.src = '{imgUrl}';" : null %>" /></a>
                                        <div class="social_share">
                                            <button class="btn btn-danger btn-icon btn-icon-mini btn-round" onclick="viewArticle(<%= item.DocID %>);"><i class="zmdi zmdi-eye"></i></button>
                                            <button class="btn btn-danger btn-icon btn-icon-mini btn-round" onclick="editArticle(<%= item.DocID %>);"><i class="zmdi zmdi-edit"></i></button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <%  }   %>
            </div>
           
        </div>
    </section>

    <script>
        function editArticle(docID) {
            showLoading();
            $('').launchDownload('<%= Url.Action("EditBlogArticle","ConsoleHome") %>', { 'docID': docID });
        }

        function viewArticle(docID) {
            $('').launchDownload('<%= Url.Action("BlogSingle","MainActivity") %>', { 'docID': docID }, "_blank");
        }
    </script>
    
</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">
    <!--Sparkline Plugin Js-->
    <script src="plugins/jquery-sparkline/jquery.sparkline.js"></script>
    <!-- SweetAlert Plugin Js -->
    <script src="plugins/sweetalert/sweetalert.min.js"></script>
    <!-- Jquery DataTable Plugin Js -->
    <script src="bundles/datatablescripts.bundle.js"></script>
    <script src="plugins/jquery-datatable/Responsive-2.2.2/js/dataTables.responsive.min.js"></script>
    <script src="plugins/jquery-datatable/FixedColumns-3.2.5/js/dataTables.fixedColumns.min.js"></script>
    <!-- Bootstrap datetimepicker Plugin Js -->
    <%--    <script src="plugins/bootstrap-datetimepicker/js/bootstrap-datetimepicker.min.js"></script>
    <script src="plugins/bootstrap-datetimepicker/js/locales/bootstrap-datetimepicker.zh-TW.js"></script>--%>
    <script src="plugins/smartcalendar/js/bootstrap-datetimepicker.min.js"></script>
    <script src="plugins/smartcalendar/js/locales-datetimepicker/bootstrap-datetimepicker.zh-TW.js"></script>

    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/KnobJS.ascx"); %>

    <script type="text/javascript">

    </script>

</asp:Content>

<script runat="server">
    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    IQueryable<BlogArticle> _items;
    UserProfile _model;
    BlogArticleQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _items = ViewBag.DataItems as IQueryable<BlogArticle>;
        _viewModel = (BlogArticleQueryViewModel)ViewBag.ViewModel;
    }

</script>
