<%@ Control Language="C#" AutoEventWireup="true" %>
<%  if (_token != null)
    { %>
<script>
        $(function () {
            $.post('<%= VirtualPathUtility.ToAbsolute("~/_test/CheckToken.ashx") %>', { 'token':'<%= _token %>' }, function (data) {
                alert(data);
            });
        });
</script>
<%  } %>
<script runat="server">

    String _token;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
    }

    public void PutToken(object obj)
    {
        _token = obj.GetType().GetHashCode().ToString();
    }

</script>
