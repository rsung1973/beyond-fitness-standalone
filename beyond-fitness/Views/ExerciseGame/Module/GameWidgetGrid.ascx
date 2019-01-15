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

<div class="well well-sm bg-color-darken">
    <%  if (_item == null || _item.Status != (int)Naming.GeneralStatus.Successful)
        { %>
    <button class="btn btn-xs btn-info" onclick="commitGameStatus(<%= (int)Naming.GeneralStatus.Successful %>);"><i class="fa fa-fw fa-gamepad"></i>參賽</button>
    <%  }
        else
        { %>
    <button class="btn btn-xs btn-danger" onclick="commitGameStatus(<%= (int)Naming.GeneralStatus.Failed %>);"><i class="fa fa-fw fa-h-square"></i>退賽</button>
    <%  } %>
</div>
<div class="jarviswidget jarviswidget-color-darken" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false" data-widget-fullscreenbutton="false">
    <header class="bg-color-redLight">
        <span class="widget-icon"><i class="fa fa-list-ol"></i></span>
        <h2>紀錄列表</h2>
        <div class="widget-toolbar">
            <%  if (_item != null && _item.Status == (int)Naming.GeneralStatus.Successful)
                { %>
            <a onclick="editExerciseResult();" class="btn btn-primary"><i class="fa fa-fw fa-plus"></i>新增紀錄</a>
            <%  } %>
            <a onclick="showGameResult();" class="btn bg-color-pink" id="gameListDialog_link"><i class="fa fa-fw fa-road"></i>查看戰況</a>
        </div>
    </header>
    <div>
        <!-- widget content -->
        <div class="widget-body bg-color-darken txt-color-white no-padding">
            <%  if (_item != null)
                {
                    Html.RenderPartial("~/Views/ExerciseGame/Module/GameRankRadarChart.ascx", _item);
                } %>
            <%  var items = _item != null
                    ? models.GetTable<ExerciseGameResult>().Where(x => x.UID == _item.UID)
                    : models.GetTable<ExerciseGameResult>().Where(x => false);
                Html.RenderPartial("~/Views/ExerciseGame/Module/TestRecordList.ascx", items); %>
        </div>
        <!-- end widget content -->
    </div>
    <!-- end widget div -->
</div>
<script>
    function editExerciseResult() {
        showLoading();
        $.post('<%= Url.Action("EditExerciseResult", "ExerciseGame",new { _model.UID }) %>', {}, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $(data).appendTo($('body'));
            }
        });
    }

    function showGameResult() {
        showLoading();
        $.post('<%= Url.Action("ShowGameResult", "ExerciseGame",new { _model.UID }) %>', {}, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $(data).appendTo($('body'));
            }
        });
    }

    function showContestantRecord(uid) {
        showLoading();
        $.post('<%= Url.Action("ShowContestantRecord", "ExerciseGame") %>', { 'uid': uid }, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $(data).appendTo($('body'));
            }
        });
    }

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    ExerciseGameContestant _item;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _item = _model.ExerciseGameContestant;
    }

</script>
