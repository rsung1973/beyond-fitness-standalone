<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>
<%@ Register Src="~/Views/Shared/UploadResource.ascx" TagPrefix="uc1" TagName="UploadResource" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript" src="<%= VirtualPathUtility.ToAbsolute("~/js/plugin/ckeditor/ckeditor.js") %>"></script>
</asp:Content>
<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-pencil-alt"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>上稿管理></li>
            <li>專業知識</li>
            <li>新增文章</li>
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
        <i class="fa-fw fa fa-pencil-alt"></i>專業知識
							<span>>  
								新增文章
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
                    <span class="widget-icon"><i class="fa fa-edit"></i></span>
                    <h2>填寫文章資訊 </h2>

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

                        <form id="pageForm" class="smart-form">

                            <fieldset>
                                <div class="row">
                                    <section class="col col-6">
                                        <label class="input input-group">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" class="form-control input-lg date form_date" data-date="<%= _item.Document.DocDate.ToString("yyyy/MM/dd") %>" readonly="readonly" data-date-format="yyyy/mm/dd" placeholder="請輸入發佈時間" value="<%= _item.Document.DocDate.ToString("yyyy/MM/dd") %>" name="docDate" id="docDate" />
                                        </label>
                                    </section>
                                    <section class="col col-6">
                                        <label class="select">
                                            <% ViewBag.SelectIndication = "<option value='1'>請選擇撰文者</option>";
                                                Html.RenderPartial("~/Views/Lessons/SimpleCoachSelector.ascx", new InputViewModel { Id = "authorID", Name = "authorID", DefaultValue = _item.AuthorID }); %>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                </div>

                                <section>
                                    <label class="input">
                                        <i class="icon-append far fa-keyboard"></i>
                                        <input type="text" class="input-lg" name="title" id="title" maxlength="50" placeholder="請輸入文章主要標題" value="<%= _item.Title %>" />
                                    </label>
                                </section>
                                <%--<section>
                                    <label class="input">
                                        <i class="icon-append far fa-keyboard"></i>
                                        <input type="text" class="input-lg" name="subtitle" maxlength="50" placeholder="請輸入文章次要標題" value="<%= _item.Subtitle %>">
                                    </label>
                                </section>--%>
                                <section>
                                    <label class="label">請選擇文章類別</label>
                                    <div class="row">
                                    <%  for (int r = 0; r < (_categories.Length + 2) / 3; r++)
                                        { %>
                                        <div class="col col-4">
                                            <%  for (int c = 0; c < 3; c++)
                                                {
                                                    var idx = r * 3 + c;
                                                    if (idx >= _categories.Length)
                                                        break; %>
                                                    <label class="checkbox">
                                                        <input type="checkbox" name="articleCategory" value="<%= _categories[idx].Category %>" <%= _item.ArticleCategory.Any(a=>a.Category==_categories[idx].Category) ? "checked" : null %> />
                                                        <i></i><%= _categories[idx].Description %></label>
                                            <%  } %>
                                        </div>
                                    <%  } %>
                                    </div>
                                </section>
                                <section>
                                    <uc1:UploadResource runat="server" ID="uploadResource" />
                                </section>
                                <section>
                                    <div id="resource">
                                    </div>
                                </section>
                                <section>
                                    <textarea class="form-control" id="articleContent" rows="20"><%= _item.ArticleContent %></textarea>
                                </section>
                            </fieldset>

                            <footer>
                                <button type="button" name="btnUpdate" class="btn btn-primary" onclick="javascript:updateArticle();">
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
        <!-- END COL -->

    </div>

    <script>
        $('#vip,#m_vip').addClass('active');
        //$('#theForm').addClass('contact-form');
        $(function() {
            loadResource(<%= _item.DocID %>);
            CKEDITOR.config.height = 380;
            CKEDITOR.config.width = 'auto';
            CKEDITOR.replace( 'articleContent' );

            $('#title').rules('add', {
                'required': true,
                'messages': {
                    'required': '請輸入您的標題'
                }
            });

        });

        function updateArticle() {
            var category=[];
            $('input[name="articleCategory"]:checked')
                    .serializeArray()
                    .forEach(function(element) { 
                        category.push(element.value)});

            $.post('<%= VirtualPathUtility.ToAbsolute("~/Information/UpdateArticle")%>', 
                { 
                    'docID': <%= _item.DocID %>, 
                    'docType': 2, //$('select[name="docType"]').val(),
                    'docDate': $('input[name="docDate"]').val(),
                    'title': $('input[name="title"]').val(),
                    //'subtitle': $('input[name="subtitle"]').val(),
                    'authorID': $('select[name="authorID"]').val(),
                    'category': category,
                    'content': $('<div>').text(CKEDITOR.instances.articleContent.getData()).html()
                }, function (data) {
                    smartAlert(data.message);
                    if(data.result) {
                        window.location.href = '<%= Request.UrlReferrer %>';
                    }
                });
        }

        function deleteResource(attachmentID) {
            if (confirm('確定刪除此圖片?')) {
                $.post('<%= VirtualPathUtility.ToAbsolute("~/Information/DeleteResource")%>', { 'docID': <%= _item.DocID %>, 'attachmentID': attachmentID }, function (data) {
                    if(data.result) {
                        loadResource(<%= _item.DocID %>);
                    }
                    smartAlert(data.message);
                });
            }
        }

        function loadResource(docID) {
            $('#loading').css('display', 'table');
            $('#resource').load('<%= VirtualPathUtility.ToAbsolute("~/Information/Resource") %>' + '/' + docID, function () {
                $('input[name="rbTitleImg"]:radio').on('change', function (evt) {
                    var $this = $(this);
                    if ($this.val() != '') {
                        $.post('<%= VirtualPathUtility.ToAbsolute("~/Information/MakeTheme")%>', { 'docID':docID , 'attachmentID':$this.val() } , function (data) {
                            smartAlert(data.message);
                        });
                    }
                });
                $('#loading').css('display', 'none');
            });
        }

    </script>
<%--    <% if (_item.Document.DocType.HasValue)
        { %>
    <script>
        $(function(){
            $('select[name="docType"]').val(<%= _item.Document.DocType %>);
        });
    </script>
    <%  } %>--%>
</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    Article _item;
    ModelStateDictionary _modelState;
    ArticleCategoryDefinition[] _categories;
    
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _item = (Article)this.Model;
        uploadResource.DocID = _item.DocID;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _categories = models.GetTable<ArticleCategoryDefinition>().ToArray();
    }


</script>
