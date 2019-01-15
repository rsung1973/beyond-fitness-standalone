<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<section id="widget-grid" class="">
    <!-- row -->
    <div class="row">
        <!-- NEW WIDGET START -->
        <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget jarviswidget-color-darken" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
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
                    <span class="widget-icon"><i class="fa fa-search"></i></span>
                    <h2>查詢條件</h2>
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
                        <form method="post" id="queryForm" class="smart-form">
                            <div class="inline-group">
                                <fieldset>
                                    <section class="col col-xs-12">
                                        <label class="radio">
                                            <input type="radio" name="QueryInterval" checked="checked" value="<%= (int)Naming.QueryIntervalDefinition.今日 %>" />
                                            <i></i>今天</label>
                                        <label class="radio">
                                            <input type="radio" name="QueryInterval" value="<%= (int)Naming.QueryIntervalDefinition.本週 %>" />
                                            <i></i>本週</label>
                                        <label class="radio">
                                            <input type="radio" name="QueryInterval" value="<%= (int)Naming.QueryIntervalDefinition.本月 %>" />
                                            <i></i>本月</label>
                                        <label class="radio">
                                            <input type="radio" name="QueryInterval" value="<%= (int)Naming.QueryIntervalDefinition.本季 %>" />
                                            <i></i>本季</label>
                                        <label class="radio">
                                            <input type="radio" name="QueryInterval" value="<%= (int)Naming.QueryIntervalDefinition.近半年 %>" />
                                            <i></i>近半年</label>
                                        <label class="radio">
                                            <input type="radio" name="QueryInterval" value="<%= (int)Naming.QueryIntervalDefinition.近一年 %>" />
                                            <i></i>近一年</label>
                                    </section>
                                </fieldset>
                                <fieldset>
                                    <section class="col col-xs-12 col-sm-12 col-md-12">
                                        <label class="radio">
                                            <input type="radio" name="QueryInterval" value="" />
                                            <i></i>自訂區間</label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-6 col-md-6">
                                        <label class="label">請選擇上課起日</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="AchievementDateFrom" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請輸入查詢起日" value='<%= String.Format("{0:yyyy/MM/dd}",_viewModel.AchievementDateFrom) %>' />
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-6 col-md-6">
                                        <label class="label">請選擇上課迄日</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="AchievementDateTo" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請輸入查詢迄日" value='<%= String.Format("{0:yyyy/MM/dd}",_viewModel.AchievementDateTo) %>' />
                                        </label>
                                    </section>
                                </fieldset>
                                <script>
                                    $('#queryForm input:radio[name="QueryInterval"]').on('click', function (evt) {
                                        showLoading();
                                        $.post('<%= Url.Action("LoadQueryInterval", "Achievement") %>', { 'queryInterval': $(this).val() }, function (data) {
                                            hideLoading();
                                            $(data).appendTo($('body'));
                                        });
                                    });
                                </script>
                            </div>
                            <footer>
                                <button type="button" name="btnSend" class="btn btn-primary" onclick="inquireLesson();">
                                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                                </button>
                                <button type="reset" name="btnCancel" class="btn btn-default">
                                    清除 <i class="fa fa-undo" aria-hidden="true"></i>
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
        <!-- WIDGET END -->
    </div>
    <!-- end row -->
    <!-- row -->
    <div class="row">
        <!-- NEW WIDGET START -->
        <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget jarviswidget-color-darken" id="wid-id-1" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
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
                    <span class="widget-icon"><i class="fa fa-table"></i></span>
                    <h2 class="achievement"><%= _viewModel.QueryInterval %>課程總覽</h2>
                    <div class="widget-toolbar">
                        <a href="#" class="btn btn-primary" id="btnDownloadLessons" onclick="downloadLesson();" style="display: none;"><i class="fa fa-fw fa-cloud-download-alt"></i>下載檔案</a>
                    </div>
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
                        <div class="row">
                            <div class="col col-xs-12 col-sm-12 col-md-12">
                                <%  Html.RenderPartial("~/Views/Achievement/Module/BranchLessonBarChart.ascx", models.GetTable<LessonTime>().Where(c => false)); %>
                            </div>
                            <div id="lessonCount" class="col col-xs-12 col-sm-12 col-md-12">
                                <%  Html.RenderPartial("~/Views/Achievement/Module/BranchLessonCount.ascx", models.GetTable<LessonTime>().Where(c => false)); %>
                            </div>
                        </div>
                        <div class="row">
                            <%  Html.RenderPartial("~/Views/Achievement/Module/BranchLessonDonuts.ascx", models.GetTable<LessonTime>().Where(c => false)); %>
                            <div id="lessonList" class="col col-xs-12 col-sm-6 col-md-12">
                                <%  Html.RenderPartial("~/Views/Achievement/Module/BranchLessonList.ascx", models.GetTable<LessonTime>().Where(c => false)); %>
                            </div>
                        </div>
                    </div>
                    <!-- end widget content -->
                </div>
                <!-- end widget div -->
            </div>
            <!-- end widget -->
        </article>
        <!-- WIDGET END -->
    </div>
    <!-- end row -->

</section>

<script>
    //debugger;
    function inquireLesson() {
        var event = event || window.event;
        var $form = $(event.target).closest('form');
        var formData = $form.serializeObject();

        $('#btnDownloadLessons').css('display', 'none');
        clearErrors();
        showLoading();
        $.post('<%= Url.Action("InquireBranchLessonList","Achievement") %>', formData, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $('#lessonList').empty();
                $(data).appendTo($('#lessonList'));
            }
        });

        $global.updateBranchLessonDonuts(formData);

        $.post('<%= Url.Action("InquireBranchLessonCount","Achievement") %>', formData, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $('#lessonCount').empty();
                $(data).appendTo($('#lessonCount'));
            }
        });

        $global.updateBranchBarChart(formData);

    }

    function downloadLesson() {
        $('#queryForm').launchDownload('<%= Url.Action("CreateBranchLessonListXlsx","Achievement") %>');
    }

    //debugger;
    function showBranchLessonList(params) {
        var formData = $('#queryForm').serializeObject();
        if (params) {
            $.extend(formData, params);
        }
        showLoading();
        $.post('<%= Url.Action("ShowBranchLessonList","Achievement") %>', formData, function (data) {
            hideLoading();
            if (data) {
                var $dialog = $(data);
                $dialog.dialog({
                    width: "auto",
                    height: "auto",
                    resizable: true,
                    modal: true,
                    closeText: "關閉",
                    title: "<h4 class='modal-title'><i class='icon-append fa fa-list-ol'></i> 上課明細資料</h4>",
                    close: function (evt, ui) {
                        $dialog.remove();
                    }
                });
            }
        });
    }

    function showLearnerToComplete() {
        var formData = $('#queryForm').serializeObject();
        showLoading();
        $.post('<%= Url.Action("ShowLearnerToComplete","Achievement") %>', formData, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;
    AchievementQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }

</script>
