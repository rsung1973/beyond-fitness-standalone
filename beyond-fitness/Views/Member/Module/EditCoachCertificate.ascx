<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="證照清單" class="bg-color-darken">
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
            <h2>證照列表</h2>
            <div class="widget-toolbar">
                <a onclick="addCertificate();" class="btn btn-primary"><i class="fa fa-fw fa-plus"></i>新增證照</a>
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
            <div class="widget-body bg-color-darken txt-color-white no-padding" id="certList">
                <%  Html.RenderPartial("~/Views/Member/Module/CoachCertificateList.ascx", _model.CoachCertificate); %>
            </div>
            <!-- end widget content -->
        </div>
        <!-- end widget div -->
    </div>
    <!-- end widget -->
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 編輯證照資料</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
                "class": "btn btn-primary",
                click: function () {
                    $(this).dialog("close");
                }
            }],
            close: function (event, ui) {
                $('#<%= _dialog %>').remove();
            }
        });

        function addCertificate() {
            showLoading();
            $.post('<%= Url.Action("AddCoachCertificate","Member",new { uid = _model.CoachID }) %>', {}, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        function loadCertificate() {
            showLoading();
            $('#certList').load('<%= Url.Action("CoachCertificateList","Member",new { uid = _model.CoachID }) %>', {}, function (data) {
                hideLoading();
            });
        }

        function deleteCertificate(certID) {
            var event = event || window.event;
            var $tr = $(event.target).closest('tr');
            $.SmartMessageBox({
                title: "<i class=\"fa fa-fw far fa-trash-alt\" aria-hidden=\"true\"></i> 刪除證照",
                content: "確定刪除此資料?",
                buttons: '[刪除][取消]'
            }, function (ButtonPressed) {
                if (ButtonPressed == "刪除") {
                    showLoading();
                    $.post('<%= Url.Action("DeleteCoachCertificate","Member",new { uid = _model.CoachID }) %>', { 'CertificateID': certID }, function (data) {
                        hideLoading();
                        $tr.remove();
                    });
                }
            });
        }
        
    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "editCoachCert" + DateTime.Now.Ticks;
    ServingCoach _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (ServingCoach)this.Model;
    }

</script>
