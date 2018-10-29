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
            <div class="jarviswidget jarviswidget-color-darken" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false" data-widget-fullscreenbutton="false">
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
                    <span class="widget-icon"><i class="fa fa-search txt-color-white"></i></span>
                    <h2>查詢條件 </h2>
                    <!-- <div class="widget-toolbar">
                           add: non-hidden - to disable auto hide
                           
                           </div>-->
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
                                        <label class="label">請選擇查詢起日</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="AchievementDateFrom" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請輸入查詢起日" value='<%= String.Format("{0:yyyy/MM/dd}",_viewModel.AchievementDateFrom) %>' />
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-6 col-md-6">
                                        <label class="label">請選擇查詢迄日</label>
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
                                <button onclick="inquireAchievement();" type="button" name="btnSend" class="btn btn-primary">
                                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                                </button>
                                <button type="reset" name="cancel" class="btn btn-default">
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
                    <span class="widget-icon"><i class="fa fa-table"></i></span>
                    <h2>業績統計<span class="achievement"></span>
                    </h2>
                    <div class="widget-toolbar">
                        <a onclick="downloadAchievement();" id="btnDownloadAchievement" style="display: none;" class="btn btn-primary"><i class="fa fa-fw fa-cloud-download-alt"></i>下載檔案</a>
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
                                <%  Html.RenderPartial("~/Views/Achievement/Module/BranchContributionBarChart.ascx", models.GetTable<TuitionAchievement>().Where(c => false)); %>
                            </div>
                            <div id="contributionCount" class="col col-xs-12 col-sm-12 col-md-12">
                                <%  Html.RenderPartial("~/Views/Achievement/Module/BranchContributionCount.ascx", models.GetTable<TuitionAchievement>().Where(c => false)); %>
                            </div>
                        </div>
                        <div class="row">
                            <%  Html.RenderPartial("~/Views/Achievement/Module/BranchContributionDonuts.ascx", models.GetTable<TuitionAchievement>().Where(c => false)); %>
                            <div id="achievementList" class="col col-xs-12 col-sm-6 col-md-12">
                                <%  Html.RenderPartial("~/Views/Achievement/Module/BranchContributionList.ascx", models.GetTable<TuitionAchievement>().Where(c => false)); %>
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
    function inquireAchievement() {
        var event = event || window.event;
        var $form = $(event.target).closest('form');
        var formData = $form.serializeObject();
        $('#btnDownloadAchievement').css('display', 'none');
        clearErrors();
        showLoading();

        $.post('<%= Url.Action("InquireBranchContribution","Achievement") %>', formData, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $('#achievementList').empty();
                $(data).appendTo($('#achievementList'));
            }
        });

        $global.updateBranchContributionDonuts(formData);

        $.post('<%= Url.Action("InquireBranchContributionCount","Achievement") %>', formData, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $('#contributionCount').empty();
                $(data).appendTo($('#contributionCount'));
            }
        });

        $global.updateBranchBarChart(formData);
    }

    function downloadAchievement() {
        $('#queryForm').launchDownload('<%= Url.Action("CreateBranchContributionXlsx","Achievement") %>');
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
