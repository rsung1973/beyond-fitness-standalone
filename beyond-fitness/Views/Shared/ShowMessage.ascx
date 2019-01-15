<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<script>
    $(function () {
        smartAlert('<%= ViewBag.Message %>');
    });
</script>

