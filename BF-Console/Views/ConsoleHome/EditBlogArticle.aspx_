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
    <!-- SmartCalendar Datetimepick -->
    <link href="plugins/smartcalendar/css/bootstrap-datetimepicker.min.css" rel="stylesheet" />
    <link href="css/smartcalendar-2.css" rel="stylesheet" />
    <!-- Multi Select Css -->
    <link href="plugins/multi-select/css/multi-select.css" rel="stylesheet">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <script>
        $(function () {
            $global.viewModel = <%= JsonConvert.SerializeObject(_viewModel) %>;

            for (var i = 0; i < $global.onReady.length; i++) {
                $global.onReady[i]();
            }

        });
    </script>
    <!-- Main Content -->
    <section class="content blog-page">
        <%  ViewBag.BlockHeader = "部落格撰稿";
            ViewBag.InsertPartial = (Action)(() =>
            {
                Html.RenderPartial("~/Views/Blog/Module/CategoryIndication.ascx", _model); ;
            });
            Html.RenderPartial("~/Views/ConsoleHome/Module/BlockHeader.ascx", _model);
        %>
        <div class="container-fluid">
            <form enctype="multipart/form-data" method="post">
                <!--文章資訊-->
                <div class="container-fluid">
                    <h4 class="card-outbound-header">撰稿資訊</h4>
                    <div class="card">

                        <div class="header">
                            <h2><strong><%= _viewModel.Title %></strong> - <%= _blog?.UserProfile.FullName() %></h2>
                        </div>
                        <div class="body">
                                <div class="row clearfix">
                                    <div class="col-12">
                                        <div class="input-group">
                                            <input type="text" class="form-control form-control-danger" placeholder="撰稿標題" name="Title" value="<%= _viewModel.Title %>" />
                                            <span class="input-group-addon">
                                                <i class="zmdi zmdi-text-format"></i>
                                            </span>
                                        </div>
                                        <%--<label class="material-icons help-error-text">clear 請輸入撰稿標題</label>--%>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                                        <div class="input-group">
                                            <input type="text" class="form-control form-control-danger" id="searchCoach" name="AuthorName" placeholder="撰稿人員" readonly onclick="selectCoach();" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-account"></i>
                                            </span>
                                        </div>
                                        <%--<label class="material-icons help-error-text">clear 請選擇撰稿人員</label>--%>
                                    </div>
                                    <script>

                                        $(function () {
                                            $global.commitCoach = function (coachID, coachName) {
                                                $global.viewModel.AuthorID = coachID;
                                                $('#searchCoach').val(coachName);
                                            };
                                        });

                                        function selectCoach() {
                                            showLoading();
                                            $.post('<%= Url.Action("SelectCoach", "ContractConsole") %>', {}, function (data) {
                                                hideLoading();
                                                if ($.isPlainObject(data)) {
                                                    alert(data.message);
                                                } else {
                                                    $(data).appendTo($('body'));
                                                }
                                            });
                                        }
                                    </script>
                                    <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                                        <div class="input-group">
                                            <input type="text" class="form-control date" data-date-format="yyyy/mm/dd" readonly="readonly" placeholder="發佈時間" name="DocDate" value="<%= $"{_viewModel.DocDate:yyyy/MM/dd}" %>" />
                                            <span class="input-group-addon xl-slategray">
                                                <i class="zmdi zmdi-calendar"></i>
                                            </span>
                                        </div>
                                        <%--<label class="material-icons help-error-text">clear 請選擇發佈時間</label>--%>
                                    </div>
                                    <div class="col-md-12 m-t-20">
                                        <select class="ms group" multiple="multiple" name="TagID">
                                            <%  foreach (var c in models.GetTable<BlogCategoryDefinition>())
                                                {   %>
                                            <option value="<%= c.CategoryID %>"><%= c.Category %></option>
                                            <%  }   %>
                                        </select>
                                    </div>
                                    <input type="hidden" name="Category" />
                                    <script>
                                        $(function () {
                                            $('.group').multiSelect();
                            <%  if (_viewModel.TagID != null && _viewModel.TagID.Length > 0)
                                        {   %>
                                        $('.group').multiSelect('select',<%= JsonConvert.SerializeObject(_viewModel.TagID.Select(i => i.ToString()))  %>);
                                <%  }   %>
                                        });
                                    </script>
                                </div>
                                <div class="row clearfix">
                                    <div class="col-sm-12">
                                        <button type="button" class="btn bg-darkteal btn-round float-right next" onclick="commitArticle();">確定，不後悔</button>
                                        <button type="button" class="btn btn-danger btn-round btn-simple save" onclick="deleteArticle();" onclick="deleteArticle">刪除文章</button>
                                    </div>
                                </div>
                                <script>
                                    function commitArticle() {
                                        clearErrors();
                                        var viewModel = $('form').serializeObject();
                                        viewModel.DocID = $global.viewModel.DocID;
                                        viewModel.AuthorID = $global.viewModel.AuthorID;
                                        showLoading();
                                        $.post('<%= Url.Action("CommitArticle", "MainActivity") %>', viewModel, function (data) {
                                        hideLoading();
                                        if ($.isPlainObject(data)) {
                                            if (data.result) {

                                                $global.viewModel.DocID = data.DocID;
                                                swal('資料已儲存');
                                                if ($('#uploadContent').find(":first-child").length == 0) {
                                                    $.post('<%= Url.Action("DropifyUpload", "MainActivity") %>', {}, function (data) {
                                                            $(data).appendTo($('#uploadContent'));
                                                        });
                                                    }
                                                } else {
                                                    swal(data.message);
                                                }
                                            } else {
                                                $(data).appendTo($('body'));
                                            }
                                        });
                                    }

                                    function deleteArticle() {
                                        if ($global.viewModel.DocID) {
                                            swal({
                                                title: "確定刪除?",
                                                text: "文章刪除後無法復原!",
                                                type: "warning",
                                                showCancelButton: true,
                                                confirmButtonColor: "#DD6B55",
                                                confirmButtonText: "確定, 不後悔",
                                                cancelButtonText: "不, 點錯了",
                                                closeOnConfirm: true,
                                                closeOnCancel: true,
                                            }, function (isConfirm) {
                                                if (isConfirm) {
                                                    showLoading();
                                                    $.post('<%= Url.Action("DeleteArticle", "MainActivity") %>', {
                                                        'DocID': $global.viewModel.DocID
                                                    }, function(data) {
                                                        hideLoading();
                                                        if ($.isPlainObject(data)) {
                                                            if (data.result) {
                                                                $('').launchDownload('<%= Url.Action("BlogIndex","ConsoleHome") %>');
                                                            } else {
                                                                swal(data.message);
                                                            }
                                                        } else {
                                                            $(data).appendTo($('body'));
                                                        }
                                                    });
                                                    } else {
                                                    }
                                                });
                                        }
                                    }

                                </script>
                            
                        </div>
                    </div>
                </div>
                <!--上傳內容-->
                <div class="container-fluid" id="uploadContent">
                    <%  if (_blog != null)
                        {
                            Html.RenderPartial("~/Views/ConsoleHome/Shared/DropifyUpload.ascx");
                        }
                    %>
                </div>
            </form>
        </div>
    </section>

    <script>
        $(function () {
            $global.uploadFile = function ($file, done) {
                var postData = {
                    'DocID': $global.viewModel.DocID
                };

                $('form').ajaxForm({
                    url: '<%= Url.Action("CommitArticleContent","MainActivity") %>',
                    data: postData,
                    beforeSubmit: function () {
                        showLoading();
                    },
                    success: function (data) {
                        hideLoading();
                        if (data.result) {
                            swal({
                                title: "文章內容存檔完成",
                                text: "",
                                type: "success",
                                showCancelButton: false,
                                confirmButtonColor: "#DD6B55",
                                confirmButtonText: "確定",
                                closeOnConfirm: true
                            }, function () {
                                //$('#uploadContent').empty();
                                $('').launchDownload('<%= Url.Action("BlogSingle","MainActivity") %>', data, "_blank");
                            });
                        } else {
                            swal(data.message);
                        }
                    },
                    error: function () {
                        hideLoading();
                    }
                }).submit();

<%--                uploadFile($file, data, '<%= Url.Action("CommitArticleContent","MainActivity") %>',
                    function (data) {
                        if (data.result) {
                            swal({
                                title: "文章內容存檔完成",
                                text: "",
                                type: "success",
                                showCancelButton: false,
                                confirmButtonColor: "#DD6B55",
                                confirmButtonText: "確定",
                                closeOnConfirm: true
                            }, function () {
                                //$('#uploadContent').empty();
                                $('').launchDownload('<%= Url.Action("BlogSingle","MainActivity") %>', data, "_blank");
                            });
                        } else {
                            swal(data.message);
                        }
                        done();
                    }, function () {
                        done();
                    });--%>
            }
        });
    </script>

</asp:Content>

<asp:Content ID="TailPageJavaScriptInclude" ContentPlaceHolderID="TailPageJavaScriptInclude" runat="server">
    <!-- Bootstrap datetimepicker Plugin Js -->
    <%--    <script src="plugins/bootstrap-datetimepicker/js/bootstrap-datetimepicker.min.js"></script>
    <script src="plugins/bootstrap-datetimepicker/js/locales/bootstrap-datetimepicker.zh-TW.js"></script>--%>
    <script src="plugins/smartcalendar/js/bootstrap-datetimepicker.min.js"></script>
    <script src="plugins/smartcalendar/js/locales-datetimepicker/bootstrap-datetimepicker.zh-TW.js"></script>
    <!-- Multi Select Plugin Js -->
    <script src="plugins/multi-select/js/jquery.multi-select.js"></script>
    <script type="text/javascript">
        $(function () {
            $('.date').datetimepicker({
                language: 'zh-TW',
                weekStart: 1,
                todayBtn: 1,
                clearBtn: 1,
                autoclose: 1,
                todayHighlight: 1,
                startView: 2,
                minView: 2,
                defaultView: 2,
                forceParse: 0,
                defaultDate: '<%= String.Format("{0:yyyy-MM-dd}",DateTime.Today) %>',
            });
        });
    </script>

</asp:Content>

<script runat="server">
    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    BlogArticle _blog;
    UserProfile _model;
    BlogArticleQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _blog = ViewBag.BlogArticle as BlogArticle;
        _viewModel = (BlogArticleQueryViewModel)ViewBag.ViewModel;
    }

</script>
