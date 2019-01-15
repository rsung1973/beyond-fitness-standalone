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


<div id="<%= _dialogID %>" title="編輯項目" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form autofocus>
            <fieldset>
                <div class="row">
                    <div class="col col-md-6">
                        <div class="form-group">
                            <div class="icon-addon">
                                <select name="TrainingID" class="form-control">
                                    <%  foreach (var item in models.GetTable<TrainingStageItem>().Where(t => t.StageID == _stage.StageID)
                                            .Select(t => t.TrainingType)
                                            .Where(t=>!t.BreakMark.HasValue || t.BreakMark==false)
                                            .Where(t=>t.TrainingID>=8)
                                            .OrderByDescending(t=>t.OrderIndex))
                                        { %>
                                    <option value="<%= item.TrainingID %>"><%= item.BodyParts %></option>
                                    <%  } %>
                                </select>
                                <%  if (_viewModel.TrainingID.HasValue)
                                    { %>
                                <script>
                                    $('select[name="TrainingID"]').val('<%= _viewModel.TrainingID %>');
                                </script>
                                <%  } %>
                            </div>
                        </div>
                    </div>
                    <div class="col col-md-6">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon">動作名稱</span>
                                <div class="icon-addon">
                                    <input class="form-control" name="Description" placeholder="請輸入動作內容" type="text" maxlength="15" value="<%= _viewModel.Description %>" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </fieldset>
            <fieldset>
                <div class="row">
                    <div class="col col-md-3">
                        <label class="label">
                            使用器材
                            <a onclick="$global.editTrainingAids(<%= _stage.StageID %>);" class="btn bg-color-yellow btn-xs btn-circle"><i class="fa fa-plus"></i></a>
                        </label>
                    </div>
                    <div class="col col-9" id="trainingAids">
                        <%  Html.RenderPartial("~/Views/Training/Module/ShowTrainingAids.ascx"); %>
                    </div>
                </div>
            </fieldset>
            <hr />
            <fieldset>
                <div class="row">
                    <div class="col col-md-4">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon">強度</span>
                                <div class="icon-addon">
                                    <input type="text" placeholder="" class="form-control" value="<%= _viewModel.GoalStrength %>" name="GoalStrength" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col col-md-4">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon">次數</span>
                                <div class="icon-addon">
                                    <input type="text" placeholder="" class="form-control" value="<%: _viewModel.GoalTurns %>" name="GoalTurns"/>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col col-md-4">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon">時間</span>
                                <div class="icon-addon">
                                    <input class="form-control" maxlength="3" placeholder="請輸入數字" type="number" name="DurationInSeconds" value="<%: String.Format("{0:.}",_viewModel.DurationInSeconds) %>">
                                </div>
                                <span class="input-group-addon">秒</span>
                            </div>
                        </div>
                    </div>
                </div>
            </fieldset>
            <fieldset>
                <div class="form-group">
                    <textarea class="form-control" placeholder="請輸入加強說明" rows="3" width="200" name="Remark"><%= _viewModel.Remark %></textarea>
                </div>
            </fieldset>
        </form>
    </div>
    <script>

        $(function () {
            $global.aidID = <%= JsonConvert.SerializeObject(_viewModel.AidID) %>;
            if(!$global.editTrainingAids) {
                $global.editTrainingAids = function(stageID) {
                    showLoading();
                    $.post('<%= Url.Action("SelectTrainingAids", "Training") %>', {'stageID':stageID}, function (data) {
                        hideLoading();
                        if ($.isPlainObject(data)) {
                            alert(data.message);
                        } else {
                            $(data).appendTo($('body'));
                        }
                    });
                };
            }
        });

        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            width: 600,
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 編輯項目</h4></div>",
            buttons: [
    <%  if (_model != null)
        {   %>
            {
                html: "<i class='far fa-trash-alt'></i>&nbsp; 刪除",
                "class": "btn bg-color-red",
                click: function () {
                    if (confirm('確定刪除此項目?')) {
                        showLoading();
                        $.post('<%= Url.Action("DeleteTrainingItem", "Training", new {_stage.StageID, _model.ItemID }) %>', {}, function (data) {
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
                    if ($global.aidID) {
                        $formData.aidID = $global.aidID;
                    }
                    showLoading();
                    $.post('<%= Url.Action("CommitTrainingItem", "Training", new { _viewModel.ExecutionID,_stage.StageID,_viewModel.ItemID }) %>', $formData, function (data) {
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
