<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table id="purposeList" class="table table-striped table-bordered table-hover" width="100%">
    <thead>
        <tr>
            <th colspan="2" class="text-right">週期性目標
                <a onclick="commitExercisePurpose('輔助');" class="badge bg-color-blue">輔助</a>&nbsp;&nbsp;
                <a onclick="commitExercisePurpose('耐力');" class="badge bg-color-blue">耐力</a>&nbsp;&nbsp;
                <a onclick="commitExercisePurpose('增肌');" class="badge bg-color-blue">增肌</a>&nbsp;&nbsp;
                <a onclick="commitExercisePurpose('力量');" class="badge bg-color-blue">力量</a>&nbsp;&nbsp;
                <a onclick="commitExercisePurpose('運能');" class="badge bg-color-blue">運能</a>&nbsp;&nbsp;
                <a onclick="commitExercisePurpose('目標');" class="badge bg-color-blue">目標</a>&nbsp;&nbsp;
            </th>
        </tr>
    </thead>
    <tbody>
        <%  Html.RenderPartial("~/Views/ClassFacet/Module/ExercisePurposeItemList.ascx", _model.PersonalExercisePurpose); %>
    </tbody>
    <tfoot>
        <tr>
            <td></td>
            <td><a onclick="addPurposeItem();" class="btn btn-circle bg-color-yellow"><i class="fa fa-plus"></i></a></td>
        </tr>
    </tfoot>
</table>

<script>
    function commitExercisePurpose(purpose) {
        var event = event || window.event;

        showLoading();
        $.post('<%= Url.Action("CommitExercisePurpose","ClassFacet",new { _model.UID }) %>', { 'purpose': purpose }, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                if (data.result) {
                    $('#exercisePurpose').text(purpose);
                } else {
                    alert(data.message);
                }
            } else {
                $(data).appendTo($('body')).remove();
            }
        });
    }

    function deletePurposeItem(itemID) {

        if (confirm('確認刪除?')) {
            var event = event || window.event;
            var $tr = $(event.target).closest('tr');

            showLoading();
            $.post('<%= Url.Action("DeletePurposeItem","ClassFacet",new { _model.UID }) %>', { 'itemID': itemID }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        $tr.remove();
                    } else {
                        alert(data.message);
                    }
                } else {
                    $(data).appendTo($('body')).remove();
                }
            });
        }
    }

    function completePurposeItem(itemID) {

        if (confirm('確定完成此項目?')) {
            var event = event || window.event;
            var $tr = $(event.target).closest('tr');

            showLoading();
            $.post('<%= Url.Action("CompletePurposeItem","ClassFacet",new { _model.UID }) %>', { 'itemID': itemID }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        $tr.remove();
                        $('#completePurposeList > tbody').load('<%= Url.Action("ExercisePurposeItemList","ClassFacet",new { _model.UID, IsComplete = true }) %>', {}, function (data) { });
                    } else {
                        alert(data.message);
                    }
                } else {
                    $(data).appendTo($('body')).remove();
                }
            });
        }
    }

    function addPurposeItem() {

        var event = event || window.event;
        event.preventDefault();

        $.SmartMessageBox({
            title: "近期目標",
            content: "",
            buttons: "[取消][確定]",
            input: "text",
            placeholder: "請輸入目標（至多20個中英文字）",
            inputValue: ""
        }, function (buttonPress, value) {
            if (buttonPress == "確定") {
                $.post('<%= Url.Action("CommitPurposeItem","ClassFacet",new { _model.UID }) %>', { 'purposeItem': value }, function (data) {
                    if ($.isPlainObject(data)) {
                        if (data.result) {
                            $('#purposeList > tbody').load('<%= Url.Action("ExercisePurposeItemList","ClassFacet",new { _model.UID, IsComplete = false }) %>', {}, function (data) { });
                        } else {
                            alert(data.message);
                        }
                    } else {
                        $(data).appendTo($('body')).remove();
                    }
                });
                return 0;
            }
        });
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }


</script>
