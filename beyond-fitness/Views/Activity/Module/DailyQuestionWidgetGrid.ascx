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
                        <form action="<%= Url.Action("InquireDailyQuestion","Activity") %>" method="post" id="queryForm" class="smart-form">
                            <fieldset>
                                <div class="row">
                                    <section class="col col-4">
                                        <label class="label">依所屬體能顧問查詢</label>
                                        <label class="select">
                                            <select name="AskerID">
                                                <option value="">全部</option>
                                                <%  Html.RenderPartial("~/Views/SystemInfo/ServingCoachOptions.ascx", models.GetTable<ServingCoach>());   %>
                                            </select>
                                            <%  if (_viewModel.AskerID.HasValue)
                                                { %>
                                            <script>
                                                $('#queryForm select[name="AskerID"]').val('<%= _viewModel.AskerID %>');
                                            </script>
                                            <%  } %>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label class="label">狀態</label>
                                        <label class="select">
                                            <select class="input" name="Status">
                                                <option value="">全部</option>
                                                <option value="" selected>已生效</option>
                                                <option value="0">已停用</option>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label class="label">題目關鍵字</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-keyboard"></i>
                                            <input type="text" name="Keyword" class="form-control input" maxlength="20" placeholder="請輸入關鍵字" value="<%: _viewModel.Keyword %>" />
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <footer>
                                <button type="button" onclick="inquireDailyQuestion();" class="btn btn-primary">
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
                    <h2>問題列表</h2>
                    <div class="widget-toolbar">
                        <a onclick="editDailyQuestion();" class="btn btn-primary"><i class="fa fa-fw fa-plus"></i>新增題目</a>
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
                    <div class="widget-body bg-color-darken txt-color-white no-padding" id="questionList">
                        <%  Html.RenderPartial("~/Views/Activity/Module/DailyQuestionList.ascx", models.GetTable<PDQQuestion>().Where(c => false)); %>
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
    function inquireDailyQuestion(questionID) {
        var event = event || window.event;
        var $form = $('#queryForm');
        var $formData = $form.serializeObject();
        if(questionID)
            $formData.questionID = questionID;
        showLoading();
        $.post('<%= Url.Action("InquireDailyQuestion","Activity") %>',$formData,function (data) {
            hideLoading();
            $('#questionList').empty()
                .append($(data));
        });
    }

        function deleteItem(keyID) {
            var event = event || window.event;
            var $tr = $(event.target).closest('tr');
            confirmIt({ title: '刪除問與答', message: '確定刪除此問與答項目?' }, function (evt) {
                showLoading();
                $.post('<%= Url.Action("DeleteQuestion","Activity") %>', { 'keyID': keyID }, function (data) {
                    hideLoading();
                    if($.isPlainObject(data)) {
                        if (data.result) {
                            if(data.QuestionID) {
                                $.post('<%= Url.Action("LoadDailyQuestion","Activity") %>', { 'keyID': keyID }, function (html) {
                                    $tr.before($(html));
                                    $tr.remove();
                                });
                                alert('資料已停用!!');
                            } else {
                                $tr.remove();
                                alert('資料已刪除!!');
                            }
                        } else {
                            alert(data.message);
                        }
                    } else {
                        $(data).appendTo($('body'));
                    }
                });
            });
        }

    function disableItem(keyID) {
            var event = event || window.event;
            var $tr = $(event.target).closest('tr');

            confirmIt({ title: '停用問與答', message: '確定停用此問與答項目?' }, function (evt) {
                showLoading();
                $.post('<%= Url.Action("CommitQuestionStatus","Activity",new { status = (int)Naming.GeneralStatus.Failed }) %>', { 'keyID': keyID }, function (data) {
                    hideLoading();
                    if($.isPlainObject(data)) {
                        if (data.result) {
                            $.post('<%= Url.Action("LoadDailyQuestion","Activity") %>', { 'keyID': keyID }, function (html) {
                                $tr.before($(html));
                                $tr.remove();
                            });
                            alert('資料已停用!!');
                        } else {
                            alert(data.message);
                        }
                    } else {
                        $(data).appendTo($('body'));
                    }
                });
            });
        }

    function enableItem(keyID) {
        var event = event || window.event;
        var $tr = $(event.target).closest('tr');

        confirmIt({ title: '啟用問與答', message: '確定啟用此問與答項目?' }, function (evt) {
            showLoading();
            $.post('<%= Url.Action("CommitQuestionStatus","Activity") %>', { 'keyID': keyID }, function (data) {
                hideLoading();
                if($.isPlainObject(data)) {
                    if (data.result) {
                        $.post('<%= Url.Action("LoadDailyQuestion","Activity") %>', { 'keyID': keyID }, function (html) {
                            $tr.before($(html));
                            $tr.remove();
                        });
                        alert('資料已啟用!!');
                    } else {
                        alert(data.message);
                    }
                } else {
                    $(data).appendTo($('body'));
                }
            });
        });
    }

    function editDailyQuestion(questionID) {
        showLoading();
        $.post('<%= Url.Action("EditDailyQuestion", "Activity") %>', { 'questionID': questionID }, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $(data).appendTo($('body'));
            }
        });
    }


</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;
    DailyQuestionQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();
        _viewModel = (DailyQuestionQueryViewModel)ViewBag.ViewModel;
    }

</script>
