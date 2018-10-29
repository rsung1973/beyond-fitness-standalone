<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="修改行事曆" class="bg-color-darken">
    <div class="row padding-10">
        <%  Html.RenderPartial("~/Views/CoachFacet/Module/EditCoachEvent.ascx"); %>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "600",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-calendar'></i>  行事曆</h4>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {
                    var f = function () {
                        $global.renderFullCalendar();
                        $('#<%= _dialog %>').dialog("close");
                    };
                    $global.commitCoachEvent(f);
                }
            }],
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });
    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserEventViewModel _viewModel;
    String _dialog = "modifyEventDialog" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (UserEventViewModel)ViewBag.ViewModel;
    }

</script>
