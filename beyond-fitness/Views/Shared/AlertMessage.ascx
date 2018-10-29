<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<% if (_message != null)
    { %>
<script>
    $(function () {
        smartAlert('<%= _message %>');
    });
</script>
<%  } %>
<script>
    function smartAlert(message, hander) {
        $.SmartMessageBox({
            title: "<i class=\"fa fa-fw fa fa-check\" aria-hidden=\"true\"></i> " + message,
            content: "",
            buttons: '[關閉]'
        }, hander);
    }
</script>
<script runat="server">
    String _message;
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _message = (String)ViewBag.Message ?? Request["Message"];
    }

</script>
