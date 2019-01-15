<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialogID %>" title="編輯休息時間與總組數" class="bg-color-darken">
    <div class="panel panel-default bg-color-darken">
        <form action="<%= VirtualPathUtility.ToAbsolute("~/Lessons/CommitTrainingBreakInterval") %>" method="post">
            <input type="hidden" name="executionID" value="<%= _model.ExecutionID %>" />
            <input type="hidden" name="itemID" value="<%= _viewModel.ItemID %>" />
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon">休息時間</span>
                                <div class="icon-addon">
                                    <input type="text" placeholder="" class="form-control" name="breakInterval" value="<%= _viewModel.BreakInterval %>" />
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
                                    <input type="text" placeholder="" class="form-control" name="repeats" value="<%= _viewModel.Repeats %>">
                                </div>
                                <span class="input-group-addon">組數</span>
                            </div>
                        </div>
                    </div>
                </div>
                <fieldset>
                    <div class="form-group">
                        <textarea class="form-control" placeholder="請輸入評論" rows="3" name="remark"><%= _viewModel.Remark %></textarea>
                    </div>
                </fieldset>
            </div>
        </form>
    </div>
    <script>

        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-edit'></i>  編輯休息時間與總組數</h4>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {
                    commitTrainingItem($('#<%= _dialogID %> form'));
                $(this).dialog("close");
            }
        }],
        close: function (event, ui) {
            $('#<%= _dialogID %>').remove();
        }
    });

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    TrainingExecution _model;
    TrainingItemViewModel _viewModel;
    String _dialogID = "addItem" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (TrainingExecution)this.Model;
        _viewModel = (TrainingItemViewModel)ViewBag.ViewModel;
    }

</script>
