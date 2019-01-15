<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<script>

    $(function () {
        $('#<%= _dialogID %>').modal('show');

        $('#<%= _dialogID %>').on('hidden.bs.modal', function () {
            $('#<%= _dialogID %>').remove();
        });

        var closeModal = $global.closeAllModal;
        $global.closeAllModal = function () {
            $('#<%= _dialogID %>').modal('hide');
            if (closeModal) {
                closeModal();
                $global.closeAllModal = null;
            }
        };

        $('#<%= _dialogID %> select.form-control').selectpicker();
    });
</script>
<script runat="server">

    String _dialogID;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _dialogID = (String)this.Model;
    }

</script>
