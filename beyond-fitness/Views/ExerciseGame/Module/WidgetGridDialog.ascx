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

<div id="<%= _dialog %>" title="競賽" class="bg-color-darken">
    <%  ViewBag.CurrentDialog = true;
        Html.RenderPartial("~/Views/ExerciseGame/Module/GameWidgetGrid.ascx", _model); %>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            height: "auto",
            resizable: true,
            modal: true,
            closeText: "關閉",
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-edit'></i>  競賽</h4>",
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });

        function commitGameStatus(status) {
            var event = event || window.event;
            var $container = $('#<%= _dialog %>');
            showLoading();
            $.post('<%= Url.Action("CommitGameStatus","ExerciseGame",new { _model.UID }) %>', { 'status': status }, function (data) {
                hideLoading();
                $container.html(data);
            });
        }

    function loadExerciseResult() {
        var $container = $('#<%= _dialog %>');
        showLoading();
        $.post('<%= Url.Action("GameIndex", "ExerciseGame", new { _model.UID }) %>', {}, function (data) {
            hideLoading();
            $container.html(data);
        });
    }

    function deleteExerciseResult(testID) {
        var event = event || window.event;
        var $tr = $(event.target).closest('tr');
        if (confirm('確定刪除?')) {
            var event = event || window.event;
            showLoading();
            $.post('<%= Url.Action("DeleteExerciseResult","ExerciseGame") %>', { 'testID': testID }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        //$(event.target).closest('tr').remove();
                        loadExerciseResult();
                    } else {
                        alert(data.message);
                    }
                } else {
                    $(data).appendTo($('body')).remove();
                }
            });
        }
    }


    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "gameWidget" + DateTime.Now.Ticks;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }

</script>
