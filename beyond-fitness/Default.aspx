<%@ Page Language="C#" AutoEventWireup="true" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
<script runat="server">

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            Response.Redirect("Account/Index");
        }
</script>