<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<!-- ui-dialog -->
<div id="<%= _dialog %>" title="登入" class="bg-color-darken">
    <div class="panel panel-default bg-color-darken">
        Test Dialog
    </div>
    <script>

        $('#<%= _dialog %>').dialog({
            //autoOpen: true,
            resizable: true,
            modal: true,
            width: "100%",
            height: "auto",
            modal: true,
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-power-off'></i>  Test</h4>",
            create: function (event, ui) {
                $('.ui-dialog-titlebar-close').on('click', function (evt) {
                    alert('click...');
                });
                $('<button>Click me...</button>').on('click', function (event) {
                    var event = event || window.event;
                    alert('you click the button...');
                }).appendTo($('.ui-dialog-titlebar'));
                $('.ui-dialog-titlebar').off('click')
                    .on('click', function (event) {
                        var event = event || window.event;
                        alert('you click title bar...');
                    });
            },
            close: function (event, ui) {
                alert('debug...');
                $('#<%= _dialog %>').remove();
            }
        });

        $('body').off('click')
            .on('click', function (event) {
            var event = event || window.event;
            alert($(event.target).html());
        });

    </script>
</div>

<!-- ui-dialog -->

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _dialog = "testDialog" + DateTime.Now.Ticks;
    }

</script>
