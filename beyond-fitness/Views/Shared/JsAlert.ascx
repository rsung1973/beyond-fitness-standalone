<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<% if (_message != null)
    { %>
    <script>
        alert('<%= HttpUtility.JavaScriptStringEncode(_message) %>');
    </script>
<%  }
    if (ViewBag.GoBack == true)
    { %>
    <script>
        window.history.go(-1);
    </script>
<%  } %>
<script runat="server">
    String _message;
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _message = (String)this.Model ?? (String)ViewBag.Message ?? Request["Message"];
    }

</script>
