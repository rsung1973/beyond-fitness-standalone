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

<div id="<%= _dialog %>" title="設定上課學員清單" class="bg-color-darken">
    <!-- Widget ID (each widget will need unique ID)-->
    <div class="jarviswidget jarviswidget-color-darken" id="wid-id-2" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
        <!-- widget options:
                  usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">

                  data-widget-colorbutton="false"
                  data-widget-editbutton="false"
                  data-widget-togglebutton="false"
                  data-widget-deletebutton="false"
                  data-widget-fullscreenbutton="false"
                  data-widget-custombutton="false"
                  data-widget-collapsed="true"
                  data-widget-sortable="false"

                  -->
        <header>
            <span class="widget-icon"><i class="fa fa-table"></i></span>
            <h2>上課學員清單</h2>
            <div class="widget-toolbar">
                <a onclick="addGroupMember(<%= _model.ContractID %>);" class="btn btn-primary"><i class="fa fa-fw fa-user-plus"></i>新增上課學員</a>
            </div>
        </header>
        <!-- widget div-->
        <div>
            <!-- widget edit box -->
            <div class="jarviswidget-editbox">
                <!-- This area used as dropdown edit box -->
            </div>
            <!-- end widget edit box -->
            <!-- widget content -->
            <div class="widget-body bg-color-darken txt-color-white no-padding itemList">
                <%  Html.RenderPartial("~/Views/EnterpriseProgram/Module/MemberItemList.ascx", _model); %>
            </div>
            <!-- end widget content -->
        </div>
        <!-- end widget div -->
    </div>
    <!-- end widget -->
    <script>

        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "640",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 設定上課人員清單</h4></div>",
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });

        function addGroupMember(contractID, uid) {
            showLoading();
            $.post('<%= Url.Action("AddMember","EnterpriseProgram") %>', { 'contractID': contractID, 'groupUID': uid }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        function listMember() {
            showLoading();
            var $itemList = $('#<%= _dialog %> .itemList');
            $itemList.empty();
            $itemList.load('<%= Url.Action("ListMember","EnterpriseProgram",new { _model.ContractID, itemsOnly = true }) %>', { }, function (data) {
                hideLoading();
            });
        }

        function takeGroupApart(groupID) {
            showLoading();
            $.post('<%= Url.Action("TakeGroupApart","EnterpriseProgram") %>', { 'groupID': groupID }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        listMember();
                    } else {
                        alert(data.message);
                    }
                } else {
                    $(data).appendTo($('body')).remove();
                }
            });
        }

        function removeProgramMember(contractID, uid) {
            var event = event || window.event;
            if (confirm('確定刪除此企業方案學員?')) {
                showLoading();
                $.post('<%= Url.Action("RemoveMember","EnterpriseProgram") %>', { 'contractID': contractID,'uid':uid }, function (data) {
                    hideLoading();
                    if (data.result) {
                        $(event.target).closest('tr').remove();
                    } else {
                        alert(data.message);
                    }
                });
            }
        }

    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "enterpriseMember" + DateTime.Now.Ticks;
    EnterpriseCourseContract _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (EnterpriseCourseContract)this.Model;

    }

</script>
