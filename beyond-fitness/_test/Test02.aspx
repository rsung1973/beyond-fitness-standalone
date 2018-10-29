<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Register Src="~/_test/PageToken.ascx" TagPrefix="uc1" TagName="PageToken" %>


<!DOCTYPE html>

<html>
<head runat="server">
    <title></title>
    <script type="text/javascript" src="../scripts/jquery-3.0.0.js"></script>
    <script type="text/javascript" src="../scripts/moment.js"></script>
    <script type="text/javascript" src="../scripts/bootstrap.js"></script>
    <script type="text/javascript" src="../js/bootstrap-datetimepicker.js"></script>
    <!-- include your less or built css files  -->
    <!-- 
  bootstrap-datetimepicker-build.less will pull in "../bootstrap/variables.less" and "bootstrap-datetimepicker.less";
  or
  -->
    <link rel="stylesheet" href="../Content/bootstrap-datetimepicker.css" />
    <%--    <script type="text/javascript" src="<%=VirtualPathUtility.ToAbsolute("~/js/jquery-2.1.4.min.js") %>"></script>
    <script type="text/javascript" src="<%=VirtualPathUtility.ToAbsolute("~/js/moment.js") %>"></script>
    <script type="text/javascript" src="<%=VirtualPathUtility.ToAbsolute("~/asset/js/bootstrap.min.js") %>"></script>
    <script type="text/javascript" src="<%=VirtualPathUtility.ToAbsolute("~/js/bootstrap-datetimepicker.js") %>"></script>
    <link rel="stylesheet" href="~/asset/css/bootstrap.min.css" type="text/css" media="screen" />
    <link rel="stylesheet" type="text/css" href="~/css/bootstrap-datetimepicker.min.css">--%>
</head>
<body>
    <form id="form1" runat="server">
        <uc1:PageToken runat="server" ID="pageToken" />
    </form>

</body>
</html>
<script runat="server">

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        ((ASP._test_pagetoken_ascx)pageToken).PutToken(this);
    }
</script>
