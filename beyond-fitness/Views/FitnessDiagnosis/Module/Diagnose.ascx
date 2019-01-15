<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="Fitness Diagnosis" class="bg-color-darken no-padding">
    <!-- new widget -->
    <div id="diagnosisContent" class="jarviswidget" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
        <%  Html.RenderPartial("~/Views/FitnessDiagnosis/Module/DiagnosisContent.ascx",_item); %>
    </div>
    <!-- end widget -->
    <script>

        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-diagnoses'></i> Fitness Diagnosis</h4></div>",
            buttons: [
    <%  if (_item!=null && _item.LevelID == (int)Naming.DocumentLevelDefinition.暫存)
        {   %>
                {
                    html: "<i class='fa fa-check'></i>&nbsp; 診斷完成",
                    "class": "btn btn-primary",
                    click: function () {
                        $.post('<%= Url.Action("ConfirmDiagnosis","FitnessDiagnosis",new { diagnosisID = _item.DiagnosisID }) %>', {}, function (data) {
                            if (data.result) {
                                $('#<%= _dialog %>').dialog("close");
                                diagnose(<%= _item.DiagnosisID %>);
                            } else {
                                alert(data.message);
                            }
                        });
                    }
                },
    <%  }
        if (_item != null)
        {   %>
                {
                    html: "<i class='fa fa-trash'></i>&nbsp; 刪除",
                    "class": "btn bg-color-red",
                    click: function () {
                        if (confirm('確認刪除?')) {
                            $.post('<%= Url.Action("DeleteDiagnosis", "FitnessDiagnosis", new { diagnosisID = _item.DiagnosisID }) %>', {}, function (data) {
                                if (data.result) {
                                    alert('資料已刪除');
                                    $('#<%= _dialog %>').dialog("close");
                                } else {
                                    alert(data.message);
                                }
                            });
                        }
                    }
                }
    <%  }   %>
            ],
            close: function (event, ui) {
                $('#<%= _dialog %>').remove();
            }
        });

        function createDiagnosis() {
            showLoading();
            $.post('<%= Url.Action("CreateDiagnosis","FitnessDiagnosis",new { uid = _viewModel.UID }) %>', {}, function (data) {
                hideLoading();
                if (data.result) {
                    $('#<%= _dialog %>').dialog("close");
                    diagnose(data.message);
                } else {
                    alert(data.message);
                }
            });
        }

        function editDiagnosisGoal(diagnosisID) {
            showLoading();
            $.post('<%= Url.Action("EditDiagnosisGoal","FitnessDiagnosis",new { uid = _viewModel.UID }) %>', { 'diagnosisID': diagnosisID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        function editDiagnosisAssessment(diagnosisID,itemID) {
            showLoading();
            $.post('<%= Url.Action("EditDiagnosisAssessment","FitnessDiagnosis",new { uid = _viewModel.UID }) %>', { 'diagnosisID': diagnosisID, 'itemID': itemID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        function deleteDiagnosisAssessment(diagnosisID, itemID) {
            var event = event || window.event;
            var $tr = $(event.target).closest('tr');
            if (confirm('確定刪除?')) {
                showLoading();
                $.post('<%= Url.Action("DeleteDiagnosisAssessment","FitnessDiagnosis",new { uid = _viewModel.UID }) %>', { 'diagnosisID': diagnosisID, 'itemID': itemID }, function (data) {
                    hideLoading();
                    if (data.result) {
                        $tr.remove();
                        alert('資料已刪除!!');
                    } else {
                        alert(data.message);
                    }
                });
            }
        }

        function checkSuffering(diagnosisID) {

            var event = event || window.event;
            var $a = $(event.target);

            if ($a.hasClass('warning')) {
                $a.removeClass('warning');
            showLoading();
                $.post('<%= Url.Action("DisableBodySuffering", "FitnessDiagnosis", new { uid = _viewModel.UID }) %>', { 'diagnosisID': diagnosisID,'part':$a.attr('class') }, function (data) {
                    hideLoading();
                });
            } else {
                showLoading();
                $.post('<%= Url.Action("EnableBodySuffering", "FitnessDiagnosis", new { uid = _viewModel.UID }) %>', { 'diagnosisID': diagnosisID,'part':$a.attr('class') }, function (data) {
                    hideLoading();
                });
                $a.addClass('warning');
            }
        }

        function diagnosisContent(diagnosisID) {
            $('#<%= _dialog %>').dialog("close");
            diagnose(diagnosisID);
        }

        function diagnosisRule(diagnosisID, itemID) {
            showLoading();
            $.post('<%= Url.Action("DiagnosisRule","FitnessDiagnosis",new { uid = _viewModel.UID }) %>', { 'diagnosisID': diagnosisID, 'itemID': itemID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String  _dialog = "diagnosis" + DateTime.Now.Ticks;
    BodyDiagnosis _item;
    UserProfile _model;
    FitnessDiagnosisViewModel _viewModel;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _item = (BodyDiagnosis)ViewBag.DataItem;
        _model = (UserProfile)this.Model;
        _viewModel = (FitnessDiagnosisViewModel)ViewBag.ViewModel;
    }

</script>
