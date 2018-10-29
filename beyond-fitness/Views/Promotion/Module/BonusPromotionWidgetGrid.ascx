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
                    <span class="widget-icon"><i class="fa fa-table"></i></span>
                    <h2>活動方案列表</h2>
                    <div class="widget-toolbar">
                        <a href="#" id="btnDownloadPromotion" onclick="downloadPromotion();" class="btn bg-color-green"><i class="fa fa-fw fa-cloud-download-alt"></i>下載檔案</a>
                        <a href="#" onclick="editPromotion();" class="btn btn-primary"><i class="fa fa-fw fa-plus"></i>新增</a>
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
                    <div id="promotionList" class="widget-body bg-color-darken txt-color-white no-padding">
                        <%  var items = models.GetTable<PDQGroup>().Join(
                                models.GetTable<PDQQuestion>().Join(
                                        models.GetTable<PDQQuestionExtension>()
                                            .Where(x => x.AwardingAction.HasValue),
                                        q => q.QuestionID, x => x.QuestionID, (q, x) => q),
                                    g => g.GroupID, q => q.GroupID, (g, q) => g);

                            Html.RenderPartial("~/Views/Promotion/Module/BonusPromotionList.ascx", items); %>
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
    function editPromotion(keyID) {
        var event = event || window.event;
        var $form = $(event.target).closest('form');
        var formData = $form.serializeObject();

        showLoading();
        $.post('<%= Url.Action("EditBonusPromotion", "Promotion") %>', { 'keyID': keyID }, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $(data).appendTo($('body'));
            }
        });
    }

    function deletePromotion(keyID) {
        if (!confirm('確定刪除此活動方案?')) {
            return;
        }
        showLoading();
        $.post('<%= Url.Action("UpdateBonusPromotionStatus", "Promotion",new { Status = Naming.LessonSeriesStatus.已停用, TryToDelete = true }) %>', { 'keyID': keyID }, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                if (data.result) {
                    alert('活動方案已刪除!!');
                } else {
                    alert('活動方案已停用!!');
                }
                listPromotion();
            } else {
                $(data).appendTo($('body'));
            }
        });
    }

    function enablePromotion(keyID) {

        showLoading();
        $.post('<%= Url.Action("UpdateBonusPromotionStatus", "Promotion",new { Status = Naming.LessonSeriesStatus.已啟用 }) %>', { 'keyID': keyID }, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                if (data.result) {
                    alert('活動方案已啟用!!');
                } else {
                    alert(data.message);
                }
                listPromotion();
            } else {
                $(data).appendTo($('body'));
            }
        });
    }

    function editParticipant(keyID) {
        var event = event || window.event;
        var $form = $(event.target).closest('form');
        var formData = $form.serializeObject();

        showLoading();
        $.post('<%= Url.Action("EditPromotionParticipant", "Promotion") %>', { 'keyID': keyID }, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $(data).appendTo($('body'));
            }
        });
    }

    function listPromotion() {
        showLoading();
        $.post('<%= Url.Action("ListBonusPromotion", "Promotion") %>', { }, function (data) {
            hideLoading();
            $('#promotionList').empty().append(data);
        });
    }

    function downloadPromotion(keyID) {
        $('').launchDownload('<%= Url.Action("CreateBonusPromotionXlsx","Promotion") %>', { 'keyID': keyID });
    }

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;
    PromotionQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();
        _viewModel = (PromotionQueryViewModel)ViewBag.ViewModel;
    }

</script>
