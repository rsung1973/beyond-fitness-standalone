<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table class="table" id="itemList">
    <tr class="info">
        <th class="text-center" width="25"></th>
        <th class="col-xs-3 col-md-3 text-center">肌力訓練</th>
        <th class="col-xs-2 col-md-2 text-center">目標次數</th>
        <th class="col-xs-2 col-md-2 text-center">目標強度</th>
        <th class="col-xs-5 col-md-5 text-center">備註</th>
    </tr>
    <%  foreach (var item in _item.TrainingItem)
        {
            Html.RenderPartial("~/Views/Lessons/EditTrainingItem.ascx", item);
        } %>
    <tr id="newItem">
        <td><a onclick="addTraining();" class="green-text fa fa-plus-circle fa-2x"></a></td>
        <td colspan="4">請點選<span class="green-text fa fa-plus-circle"></span>可新增項目</td>
    </tr>
</table>



<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    TrainingExecution _item;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _item = (TrainingExecution)this.Model;
    }

</script>
