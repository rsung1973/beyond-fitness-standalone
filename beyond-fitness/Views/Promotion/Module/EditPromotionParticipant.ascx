<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<div id="<%= _dialogID %>" title="設定贈送學員清單" class="bg-color-darken">
    <!-- Widget ID (each widget will need unique ID)-->
    <div class="jarviswidget jarviswidget-color-darken" id="wid-id-2" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
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
            <h2>贈送學員清單</h2>
            <div class="widget-toolbar">
                <%  if (_model.PDQQuestion.First().PDQQuestionExtension.AwardingAction != (int)Naming.BonusAwardingAction.程式連結)
                    {   %>
                <a href="#" onclick="selectParticipant();" class="btn btn-primary" id="modifyAttendantDialog_link"><i class="fa fa-fw fa-user-plus"></i>贈送學員</a>
                <%  } %>
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
            <div class="widget-body bg-color-darken txt-color-white no-padding participantList">
                <%  ViewBag.DataItem = _model;
                    Html.RenderPartial("~/Views/Promotion/Module/PromotionParticipantList.ascx", _items); %>
            </div>
            <!-- end widget content -->
        </div>
        <!-- end widget div -->
    </div>
    <!-- end widget -->
    <script>
        $('#<%= _dialogID %>').dialog({
            //autoOpen : false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 設定贈送學員清單</h4></div>",
            close: function () {
                $('#<%= _dialogID %>').remove();
                listPromotion();
            }
        });

        function deleteParticipant(keyID) {
            if (!confirm('確定刪除此贈送學員?')) {
                return;
            }
            showLoading();
            $.post('<%= Url.Action("DeletePromotionParticipant") %>', { 'keyID': keyID }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        alert('贈送學員已刪除!!');
                        listParticipant();
                    } else {
                        alert(data.message);
                    }
                } else {
                    $(data).appendTo($('body'));
                }
            });
        }

        function selectParticipant() {
            showLoading();
            $.post('<%= Url.Action("SelectPromotionParticipant","Promotion",new { KeyID = _model.GroupID.EncryptKey() }) %>', { }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    alert(data.message);
                } else {
                    $(data).appendTo($('body'));
                }
            });
        }

        function listParticipant() {
            showLoading();
            $.post('<%= Url.Action("ListPromotionParticipant","Promotion",new { KeyID = _model.GroupID.EncryptKey() }) %>', { }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    alert(data.message);
                } else {
                    $('#<%= _dialogID %> .participantList').empty()
                        .append(data);
                }
            });
        }

    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PromotionViewModel _viewModel;
    String _dialogID = "participant" + DateTime.Now.Ticks;
    IQueryable<PDQTask> _items;
    PDQGroup _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (PDQGroup)this.Model;
        _viewModel = (PromotionViewModel)ViewBag.ViewModel;

        var pdq = _model.PDQQuestion.First();
        _items = models.GetTable<PDQTask>().Where(t => t.QuestionID == pdq.QuestionID);
    }

</script>
