<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<tr>
    <td><i class="fa fa-minus-square text-danger" onclick="deleteItem(<%= _model.ExecutionID %>,<%= _model.ItemID %>);"></i>
    </td>
    <td>
        <div class="form-group">
            <div class="icon-addon">
                <% Html.RenderPartial("~/Views/Lessons/BodyPartsSelector.ascx", _model.TrainingID); %>
            </div>
        </div>
        <div class="form-group">
            <input class="form-control" type="text" name="description" value="<%= _model.Description %>" maxlength="15" />
            <p class="note"><strong>Note:</strong> 最多僅能輸入15個中英文字</p>
        </div>
    </td>
    <td>
        <div class="form-group">
            <div class="input-group">
                <span class="input-group-addon">實際</span>
                <div class="icon-addon">
                    <input type="text" class="form-control" maxlength="50" name="actualTurns" value="<%= _model.ActualTurns %>" />
                </div>
                <span class="input-group-addon">次數</span>
            </div>
        </div>
        <div class="form-group">
            <div class="input-group">
                <span class="input-group-addon">目標</span>
                <div class="icon-addon">
                    <input type="text" class="form-control" maxlength="50" name="goalTurns" value="<%= _model.GoalTurns %>" />
                </div>
                <span class="input-group-addon">次數</span>
            </div>
            <p class="note"><strong>Note:</strong> 輸入15或10-12</p>
        </div>
    </td>
    <td>
        <div class="form-group">
            <div class="input-group">
                <span class="input-group-addon">實際</span>
                <div class="icon-addon">
                    <input type="text" class="form-control" maxlength="50" name="actualStrength" value="<%= _model.ActualStrength %>" />
                </div>
                <span class="input-group-addon">強度</span>
            </div>
        </div>
        <div class="form-group">
            <div class="input-group">
                <span class="input-group-addon">目標</span>
                <div class="icon-addon">
                    <input type="text" class="form-control" maxlength="50" name="goalStrength" value="<%= _model.GoalStrength %>">
                </div>
                <span class="input-group-addon">強度</span>
            </div>
            <p class="note"><strong>Note:</strong> 輸入15磅 或10-12 KG 或30秒</p>
        </div>
    </td>
    <td>
        <div class="form-group">
            <textarea class="form-control" placeholder="請輸入加強說明" rows="4" name="remark"><%= _model.Remark %></textarea>
            <p class="note"><strong>Note:</strong> 最多輸入250個中英文字</p>
        </div>
        <div class="text-right">
            <a onclick="commitTraining();"><i class="fa fa-refresh fa-2x text-success"></i></a>
        </div>
    </td>
</tr>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    TrainingItem _model;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (TrainingItem)this.Model;
    }

</script>
