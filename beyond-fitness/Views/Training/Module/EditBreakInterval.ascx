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


<div id="<%= _dialogID %>" title="編輯休息時間與總組數" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form autofocus>
            <fieldset>
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon">休息時間</span>
                                <div class="icon-addon">
                                    <input class="form-control" placeholder="" type="text" value="<%: _viewModel.BreakInterval %>" name="BreakInterval" />
                                </div>
                                <span class="input-group-addon">秒</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon">總</span>
                                <div class="icon-addon">
                                    <input class="form-control" placeholder="" type="text" value="<%: _viewModel.Repeats ?? "1" %>" name="Repeats">
                                </div>
                                <span class="input-group-addon">組數</span>
                            </div>
                        </div>
                    </div>
                </div>
            </fieldset>
            <fieldset>
                <div class="form-group">
                    <textarea class="form-control" placeholder="請輸入評論" rows="3" name="Remark"><%: _viewModel.Remark %></textarea>
                </div>
            </fieldset>
        </form>
    </div>
    <script>

        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            width: 600,
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='far fa-clock'></i> 新增休息時間與總組數</h4></div>",
            buttons: [
    <%  if (_model != null)
        {   %>
            {
                html: "<i class='far fa-trash-alt'></i>&nbsp; 刪除",
                "class": "btn bg-color-red",
                click: function () {
                    if (confirm('確定刪除此項目?')) {
                        showLoading();
                        $.post('<%= Url.Action("DeleteTrainingItem", "Training", new { _stage.StageID, _model.ItemID }) %>', {}, function (data) {
                            hideLoading();
                            if ($.isPlainObject(data)) {
                                if (data.result) {
                                    alert('資料已刪除');
                                    loadTrainingStagePlan();
                                    $('#<%= _dialogID %>').dialog('close');
                                } else {
                                    alert(data.message);
                                }
                            } else {
                                $(data).appendTo($('body'));
                            }
                        });
                    }
                }
            },
        <% }   %>
            {
                html: "<i class='fa fa-edit'></i>&nbsp; 修改",
                "class": "btn bg-color-yellow",
                click: function () {
                    var $formData = $('#<%= _dialogID %> form').serializeObject();
                    showLoading();
                    $.post('<%= Url.Action("CommitBreakInterval", "Training", new { _viewModel.ExecutionID,_stage.StageID,_viewModel.ItemID }) %>', $formData, function (data) {
                        hideLoading();
                        if ($.isPlainObject(data)) {
                            if (data.result) {
                                loadTrainingStagePlan();
                                $('#<%= _dialogID %>').dialog('close');
                            } else {
                                alert(data.message);
                            }
                        } else {
                            $(data).appendTo($('body'));
                        }
                    });
                }
            },
            ],
            close: function (event, ui) {
                $('#<%= _dialogID %>').remove();
            }
        });

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    TrainingItem _model;
    TrainingItemViewModel _viewModel;
    TrainingStage _stage;
    String _dialogID = "editItem" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (TrainingItem)this.Model;
        _viewModel = (TrainingItemViewModel)ViewBag.ViewModel;
        _stage = (TrainingStage)ViewBag.TrainingStage;
    }

</script>
