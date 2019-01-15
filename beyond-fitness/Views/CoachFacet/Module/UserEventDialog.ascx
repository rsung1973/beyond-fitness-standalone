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

<div id="<%= _dialogID %>" title="行事曆" class="bg-color-darken">
    <div class="panel panel-default bg-color-darken">
        <div class="panel-body status smart-form vote">
            <div class="who clearfix">
                <span class="name font-lg"><b><%= _model.Title %></b></span><br />
                <span class="from font-md text-warning">時間：<%= String.Format("{0:yyyy/MM/dd HH:mm}",_model.StartDate) %>~<%= String.Format("{0:yyyy/MM/dd HH:mm}",_model.EndDate) %></span><br />
                <span class="from font-md text-warning">地點：<% ViewBag.Other = "其他";
                                                               Html.RenderPartial("~/Views/SystemInfo/BranchStoreText.ascx", _model.BranchID); %></span><br />
                <span class="from font-md text-warning">參與人員：<%= String.Join("、",_model.UserProfile.RealName,String.Join("、",_model.GroupEvent.Select(g=>g.UserProfile.RealName)),_model.Accompanist) %></span>
            </div>
        </div>
    </div>
    <script>
        $('#<%= _dialogID %>').dialog({
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-calendar'></i>  行事曆</h4>",
    <%  if (_model.UID == ViewBag.ModeratorID || _profile.IsAssistant())
        {   %>
            buttons: [
            {
                html: "<i class='fa fa-edit'></i>&nbsp;編輯",
                "class": "btn btn-primary",
                click: function () {
                    showLoading();
                    $.post('<%= Url.Action("EditCoachEventDialog", "CoachFacet", new { eventID = _model.EventID, uid = _model.UID }) %>', { }, function (data) {
                        hideLoading();
                        if (data) {
                            var $dialog = $(data);
                            $dialog.appendTo('body');
                            $('#<%= _dialogID %>').dialog('close');
                        }
                    });
                }
            },
            {
                html: "<i class='far fa-trash-alt'></i>&nbsp;刪除",
                "class": "btn bg-color-red",
                click: function () {
                    if (confirm('確定刪除此行事曆?')) {
                        showLoading();
                        $.post('<%= Url.Action("RevokeCoachEvent", "CoachFacet", new { eventID = _model.EventID, uid = _model.UID }) %>', null, function (data) {
                            hideLoading();
                            $(data).appendTo('body').remove();
                            $('#<%= _dialogID %>').dialog("close");
                            $global.renderFullCalendar();
                        });
                    }
                }
            }
            ],
    <%  }   %>
            close: function () {
                $('#<%= _dialogID %>').remove();
            }
        });
    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserEvent _model;
    UserProfile _profile;
    String _dialogID;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserEvent)this.Model;
        _profile = Context.GetUser();
        _dialogID = "modifyUserEventDialog" + DateTime.Now.Ticks;
    }

</script>
