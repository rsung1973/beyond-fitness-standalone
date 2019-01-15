<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialogID %>" title="編輯項目" class="bg-color-darken">
    <div class="panel panel-default bg-color-darken">
        <form action="<%= VirtualPathUtility.ToAbsolute("~/Lessons/CommitTrainingItem") %>" method="post">
            <input type="hidden" name="executionID" value="<%= _model.ExecutionID %>" />
            <input type="hidden" name="itemID" value="<%= _viewModel.ItemID %>" />
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <div class="icon-addon">
                                <% Html.RenderPartial("~/Views/Lessons/BodyPartsSelector.ascx", _viewModel.TrainingID); %>
                            </div>

                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <input class="form-control" placeholder="請輸入動作內容" type="text" maxlength="15" name="description" value="<%= _viewModel.Description %>" />

                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <%  if (ViewBag.Edit == true)
                                { %>
                            <div class="input-group">
                                <span class="input-group-addon">實際</span>
                                <div class="icon-addon">
                                    <input type="text" placeholder="" class="form-control" name="actualTurns" value="<%= _viewModel.ActualTurns %>" />
                                </div>
                                <span class="input-group-addon">次數</span>
                            </div>
                            <%  } %>
                            <div class="input-group">
                                <span class="input-group-addon">目標</span>
                                <div class="icon-addon">
                                    <input type="text" placeholder="" class="form-control" name="goalTurns" value="<%= _viewModel.GoalTurns %>" />
                                </div>
                                <span class="input-group-addon">次數</span>
                            </div>

                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <%  if (ViewBag.Edit == true)
                                { %>
                            <div class="input-group">
                                <span class="input-group-addon">實際</span>
                                <div class="icon-addon">
                                    <input type="text" placeholder="" class="form-control" name="actualStrength" value="<%= _viewModel.ActualStrength %>" />
                                </div>
                                <span class="input-group-addon">強度</span>
                            </div>
                            <%  } %>
                            <div class="input-group">
                                <span class="input-group-addon">目標</span>
                                <div class="icon-addon">
                                    <input type="text" placeholder="" class="form-control" name="goalStrength" value="<%= _viewModel.GoalStrength %>" />
                                </div>
                                <span class="input-group-addon">強度</span>
                            </div>
                        </div>
                    </div>
                </div>

                <fieldset>

                    <div class="form-group">
                        <textarea class="form-control" placeholder="請輸入加強說明" name="remark" rows="3"><%= _viewModel.Remark %></textarea>
                    </div>

                </fieldset>
            </div>
        </form>
        <!-- /.modal-content -->
    </div>
    <script>

        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-edit'></i>  編輯項目</h4>",
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
