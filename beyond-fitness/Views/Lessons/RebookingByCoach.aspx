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
            <li>預約上課時間</li>
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
								預約上課時間
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

                <header role="heading">
                    <div class="jarviswidget-ctrls" role="menu"><a href="javascript:void(0);" class="button-icon jarviswidget-fullscreen-btn" rel="tooltip" title="" data-placement="bottom" data-original-title="Fullscreen"><i class="fa fa-expand"></i></a></div>
                    <span class="widget-icon"><i class="fa fa-edit"></i></span>
                    <h2>填寫登記資訊 </h2>
                    <span class="jarviswidget-loader" style="display: none;"><i class="fa fa-refresh fa-spin"></i></span>
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

                        <form action="<%= VirtualPathUtility.ToAbsolute("~/Lessons/RebookingByCoach/") + _model.LessonID %>" id="pageForm" class="smart-form" method="post">

                            <fieldset>
                                <div class="row">
                                    <section class="col col-6">
                                        <span class="font-lg">
                                            <%  if( _model.RegisterLesson.GroupingMemberCount>1)
                                                {   %>
                                            <li class="fa fa-group"></li>
                                            團體《<%= String.Join("·", models.GetTable<GroupingLesson>().Where(g => g.GroupID == _model.RegisterLesson.RegisterGroupID)
                                                    .Join(models.GetTable<RegisterLesson>().Where(r => r.RegisterID != _model.RegisterLesson.RegisterID),
                                                        g => g.GroupID, r => r.RegisterGroupID, (g, r) => r)
                                                    .Select(r => r.UserProfile.RealName)) %>》
                                            <%  }
                                                else
                                                {   %>
                                                    <li class="fa fa-child"></li>
                                                    <%= _model.RegisterLesson.UserProfile.FullName() %>
                                                <%  if (_model.TrainingBySelf == 1)
                                                    {   %>
                                                            (P.I session)
                                                <%  }
                                                    else
                                                    { %>
                                                        「<%= _model.RegisterLesson.Lessons %>堂-<%= _model.RegisterLesson.LessonPriceType.Description %>」
                                                <%  }
                                                } %>
                                        </span>
                                    </section>
                                    <section class="col col-6">
                                        <label class="select">
                                            <%  var inputItem = new InputViewModel { Id = "coachID", Name = "coachID", DefaultValue = _viewModel.CoachID };
                                                Html.RenderPartial("~/Views/Lessons/SimpleCoachSelector.ascx", inputItem); %>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <fieldset>
                                <div class="row" class="col col-6">
                                    <section class="col col-4">
                                        <label>請選擇上課時段</label>
                                        <label class="input">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="classDate" readonly="readonly" id="classDate" class="form-control input-lg date form_time" data-date-format="yyyy/mm/dd hh:ii" value="<%= _viewModel.ClassDate.ToString("yyyy/MM/dd HH:mm") %>" placeholder="請輸入上課開始時間" />
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label>請選擇上課小時數</label>
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
                                                <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: _viewModel.BranchID); %>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <%--<fieldset>
                                <section>
                                    <label>是否為自主訓練</label>
                                    <label class="select">
                                        <select class="input-lg" name="trainingBySelf">
                                            <option value="0">否</option>
                                            <option value="1" <%= _viewModel.TrainingBySelf==1 ? "selected": null %>>是</option>
                                        </select>
                                        <i class="icon-append far fa-keyboard"></i>
                                    </label>
                                </section>
                            </fieldset>--%>

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
                <h5 class="margin-top-0"><i class="fa fa-external-link"></i> 快速功能</h5>
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
        $('#vip,#m_vip').addClass('active');
        //$('#theForm').addClass('contact-form');

        $('#coachID').on('change', function (evt) {
            if ($('#coachID option:selected').text().indexOf('自由教練') > 0) {
                window.location.href = '<%= VirtualPathUtility.ToAbsolute("~/Lessons/BookingByFreeAgent") %>' + '?coachID=' + $('#coachID').val();
            }
        });

        $(function () {

            $pageFormValidator.settings.submitHandler = function (form) {

                //var $items = $('input[name="registerID"]');
                //if ($items.length <= 0) {
                //    $('#registerID-error').css('display', 'block');
                //    $('#registerID-error').text('請選擇上課學員!!');
                //    return;
                //}


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


        $('#nextStep').on('click', function (evt) {
            startLoading();
            $('form').prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Lessons/BookingByCoach") %>')
          .submit();
        });

        function addUser() {
            $('#content').find('#addUserItem').remove();
            var $modal = $('<div class="modal fade" id="addUserItem" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" />');
            $modal.on('hidden.bs.modal', function (evt) {
                $modal.remove();
            });
            $('#loading').css('display', 'table');
            $modal.appendTo($('#content'))
                .load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/Attendee") %>', null, function () {
                    $modal.modal('show');
                    $('#loading').css('display', 'none');
                });
        }
    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    LessonTime _model;
    LessonTimeViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (LessonTime)this.Model;
        _viewModel = (LessonTimeViewModel)ViewBag.ViewModel;
    }



</script>
