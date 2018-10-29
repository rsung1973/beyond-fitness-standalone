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
                            <%  if (_profile.IsAssistant() || _profile.IsSysAdmin() || _profile.IsOfficer() || _profile.IsViceManager() || _profile.IsManager())
                                { %>
                            <fieldset>
                                <%  Html.RenderPartial("~/Views/Common/CoachSelector.ascx"); %>
                            </fieldset>
                            <%  }
                                else
                                { %>
                            <input type="hidden" name="ByCoachID" value="<%= _profile.UID %>" />
                            <%  } %>
                            <fieldset>
                                     <div class="row">
                                          <section class="col col-xs-12 col-sm-3 col-md-3">
                                            <label class="label">或依真實姓名(暱稱)查詢</label>
                                              <label class="input input-group" >
                                                <i class="icon-append fa fa-user"></i>
                                                <input type="text" name="UserName" class="form-control input" maxlength="20" placeholder="請輸入學員姓名"/>
                                               </label>
                                          </section>
                                          <section class="col col-xs-12 col-sm-3 col-md-3">
                                            <label class="label">狀態</label>
                                            <label class="select">
                                               <select name="Status" class="input">
                                                  <option value="">全部</option>
                                                  <option value="1">待填寫</option>
                                                  <option value="2">已填寫</option>
                                                  <option value="3">我超強不用了解學生</option>
                                                  <option value="4">不方便填寫</option>
                                               </select>
                                               <i class="icon-append far fa-keyboard"></i>
                                            </label>
                                         </section>
                                         <section class="col col-xs-12 col-sm-3 col-md-3">
                                        <label class="label">請選擇問卷起日</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="AchievementDateFrom" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請輸入查詢起日" value='<%= String.Format("{0:yyyy/MM/dd}",_viewModel.AchievementDateFrom) %>' />
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-3 col-md-3">
                                        <label class="label">請選擇問卷迄日</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="AchievementDateTo" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請輸入查詢迄日" value='<%= String.Format("{0:yyyy/MM/dd}",_viewModel.AchievementDateTo) %>' />
                                        </label>
                                    </section>
                                      </div>
                                  </fieldset>
                            <footer>
                                <button type="button" name="btnSend" class="btn btn-primary" onclick="inquireQuestionnaire();">
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
                    <h2>清單列表</h2>
                    <div class="widget-toolbar">
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
                    <div id="questionnaireList" class="widget-body bg-color-darken txt-color-white no-padding">
                        <%  Html.RenderPartial("~/Views/Report/Module/QuestionnaireList.ascx", models.GetTable<QuestionnaireRequest>().Where(c => false)); %>
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
<%  Html.RenderPartial("~/Views/ClassFacet/Module/PromptQuestionnaire.ascx"); %>

<script>
    //debugger;
    function inquireQuestionnaire() {
        var event = event || window.event;
        var $form = $(event.target).closest('form');
        var formData = $form.serializeObject();

        clearErrors();
        showLoading();
        $.post('<%= Url.Action("InquireQuestionnaire","Report") %>', formData, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $('#questionnaireList').empty();
                $(data).appendTo($('#questionnaireList'));
            }
        });

    }

    function downloadLesson() {
        $('#queryForm').launchDownload('<%= Url.Action("CreateLessonListXlsx","Achievement") %>');
    }

    //debugger;
    function showLessonList(params) {
        var formData = $('#queryForm').serializeObject();
        if (params) {
            $.extend(formData, params);
        }
        showLoading();
        $.post('<%= Url.Action("ShowLessonList","Achievement") %>', formData, function (data) {
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
