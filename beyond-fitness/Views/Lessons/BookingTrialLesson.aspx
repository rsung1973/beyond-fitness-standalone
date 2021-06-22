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

<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>


<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <div id="ribbon">

        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-bookmark"></i>
            </span>
        </span>

        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>課程管理></li>
            <li>預約體驗課程</li>
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
        <i class="fa-fw fa fa-bookmark"></i>課程管理
							<span>>  
								預約體驗課程
                            </span>
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">

        <!-- NEW COL START -->
        <article class="col-xs-12 col-sm-12 col-md-8 col-lg-8">
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
                    <h2>填寫登記資訊 </h2>

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

                        <form action="<%= Url.Action("CommitTrialLesson","Lessons") %>" id="pageForm" class="smart-form" method="post">
                            <fieldset class="freeAgentexclusive">
                                <div class="row">
                                    <section class="col col-6">
                                        <label>請選擇體能顧問</label>
                                        <label class="select">
                                            <%  var inputItem = new InputViewModel { Id = "coachID", Name = "coachID", DefaultValue = _model.UID };
                                            if (ViewBag.DefaultCoach != null)
                                                inputItem.DefaultValue = ViewBag.DefaultCoach;
                                            Html.RenderPartial("~/Views/Lessons/SimpleCoachSelector.ascx", inputItem); %>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <section class="col col-6">
                                        <label>請選擇學生</label>
                                        <label class="input">
                                            <i class="icon-append fa fa-user"></i>
                                            <input type="text" onclick="javascript: addUser();" name="queryAttendee" id="queryAttendee" class="input-lg" placeholder="請選擇學員" readonly="readonly" />
                                        </label>
                                        <div id="attendee"></div>
                                        <label id="registerID-error" class="error" for="registerID" style="display: none;"></label>
                                    </section>
                                </div>
                            </fieldset>
                            <fieldset>
                                <div class="row">
                                    <section class="col col-4">
                                        <label>請選擇上課時段</label>
                                        <label class="input">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="classDate" id="classDate" class="form-control input-lg date form_time" data-date-format="yyyy/mm/dd hh:ii" readonly="readonly" value="<%= _viewModel.ClassDate.ToString("yyyy/MM/dd HH:mm") %>" placeholder="請輸入上課開始時間" />
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label>請選擇上課分鐘數</label>
                                        <label class="select">
                                            <select name="duration" class="input-lg">
                                                <option value="60" <%= _viewModel.Duration==60 ? "selected": null %>>60 分鐘</option>
                                                <option value="90" <%= _viewModel.Duration==90 ? "selected": null %>>90 分鐘</option>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label>請選擇上課地點</label>
                                        <label class="select">
                                            <select class="input-lg" name="branchID">
                                                <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.cshtml", model: _viewModel.BranchID); %>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <footer>
                                <button type="submit" name="submit" class="btn btn-primary">
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

        <!-- NEW COL START -->
        <article class="col-xs-12 col-sm-12 col-md-4 col-lg-4">
            <!-- /well -->
            <div class="well bg-color-darken txt-color-white padding-10">
                <h5 class="margin-top-0"><i class="fa fa-external-link"></i>快速功能</h5>
                <ul class="no-padding no-margin">
                    <p class="no-margin">
                        <ul class="icons-list">
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/Overview.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/VipOverview.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ListLearners.ascx"); %>
                            <%  Html.RenderPartial("~/Views/Layout/QuickLinkItem/ListCoaches.ascx"); %>
                        </ul>
                    </p>
                </ul>
            </div>
            <!-- /well -->


        </article>
        <!-- END COL -->

    </div>


    <script>

        $('#coachID').on('change', function (evt) {
            if ($('#coachID option:selected').text().indexOf('自由教練') >= 0) {
                <%--window.location.href = '<%= VirtualPathUtility.ToAbsolute("~/Lessons/BookingByFreeAgent") %>' + '?coachID=' + $('#coachID').val();--%>
                $('.freeAgentexclusive').css('display', 'none');
            } else {
                $('.freeAgentexclusive').css('display', 'block');
            }
        });

        $(function () {


            $pageFormValidator.settings.submitHandler = function (form) {

                <%--                var $items = $('input[name="registerID"]:checked');
                if ($items.length <= 0 && $('input[name="UID"]:checked').length<=0) {
                    $('#registerID-error').css('display', 'block');
                    $('#registerID-error').text('請選擇上課學員!!');
                    return;
                }
--%>
                if ($('#coachID option:selected').text().indexOf('自由教練') < 0) {
                    if ($('input[name="registerID"]').length <= 0
                        && $('input[name="UID"]').length <= 0) {
                        $('#registerID-error').css('display', 'block');
                        $('#registerID-error').text('請選擇上課學員!!');
                        return;
                    }
                }


                $('#pageForm button[type="submit"]').prop('disabled', true);
                //$(form).submit();
                return true;
            };

            $('#coachID').rules('add', {
                'required': true
            });

            $('#classDate').rules('add', {
                'required': true,
                'date': true
            });

            //$('#classTime').rules('add', {
            //    'required': true
            //});
        });


        function addUser() {
            showLoading(true);
            $('#content').find('#addUserItem').remove();
            var $modal = $('<div class="modal fade" id="addUserItem" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" />');
            $modal.on('hidden.bs.modal', function (evt) {
                $modal.remove();
            });

            $modal.appendTo($('#content'))
                .load('<%= Url.Action("TrialLearner","Lessons") %>', null, function () {
                    $modal.modal('show');
                    hideLoading();
                });

        }
    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    LessonTimeViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _viewModel = (LessonTimeViewModel)ViewBag.ViewModel;
    }



</script>
