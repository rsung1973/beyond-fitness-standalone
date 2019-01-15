<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <a class="closebutton" data-dismiss="modal"></a>
            </div>
            <div class="modal-body">
                <div class="card">
                    <div class="header">
                        <h2>訊息</h2>
                        <p><%= DateTime.Now %></p>
                    </div>
                    <div class="body">
                        <%= _message %>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">關閉</button>
            </div>
        </div>
    </div>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
</div>
<script runat="server">

    String _message;
    String _dialogID = $"alert{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _message = (String)this.Model ?? (String)ViewBag.Message ?? Request["Message"];
    }

</script>
