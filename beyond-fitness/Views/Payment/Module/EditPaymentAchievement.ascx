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

<div id="<%= _dialog %>" title="編輯業績分潤金額" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
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
                <h2>分潤清單</h2>
                <div class="widget-toolbar">
                    <a onclick="$global.applyAchievement();" class="btn btn-primary"><i class="fa fa-fw fa-plus"></i>新增業績分潤金額</a>
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
                <div class="widget-body bg-color-darken txt-color-white no-padding" id="coachAchievement">
                    <%  Html.RenderPartial("~/Views/Payment/Module/PaymentCoachAchievement.ascx", _model); %>
                </div>
                <!-- end widget content -->
            </div>
            <!-- end widget div -->
        </div>
        <!-- end widget -->
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i>  編輯業績分潤金額</h4></div>",
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });

        $(function () {

            $global.deleteAchievement = function (coachID) {
                var event = event || window.event;
                var $tr = $(event.target).closest('tr');
                if (confirm('確定刪除?')) {
                    showLoading();
                    $.post('<%= Url.Action("DeleteCoachAchievement","Payment",new { _model.PaymentID }) %>', { 'coachID': coachID }, function (data) {
                        hideLoading();
                        if ($.isPlainObject(data)) {
                            if (data.result) {
                                alert('資料已刪除!!')
                                $tr.remove();
                            } else {
                                alert(data.message);
                            }
                        } else {
                            $(data).appendTo($('body'));
                        }
                    });
                }
            };

            $global.applyAchievement = function () {
                showLoading();
                $.post('<%= Url.Action("ApplyPaymentAchievement","Payment",new { _model.PaymentID }) %>', {}, function (data) {
                    hideLoading();
                    $(data).appendTo($('body'));
                });
            };

            $global.loadCoachAchievement = function () {
                showLoading();
                $('#coachAchievement').load('<%= Url.Action("LoadCoachAchievement","Payment",new { _model.PaymentID }) %>', {}, function (data) {
                    hideLoading();
                });
            };

        });

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "achievement" + DateTime.Now.Ticks;
    Payment _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (Payment)this.Model;
    }

</script>
