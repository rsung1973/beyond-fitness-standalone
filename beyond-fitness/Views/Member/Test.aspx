<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>

<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>
<%@ Register Src="~/Views/Shared/LockScreen.ascx" TagPrefix="uc1" TagName="LockScreen" %>



<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <uc1:PageBanner runat="server" ID="PageBanner" Title="會員專區" TitleInEng="VIP" />

    <uc1:LockScreen runat="server" ID="LockScreen" />

    <% Html.RenderPartial("~/Views/Shared/HtmlInput.ascx",
               new InputViewModel
               {
                   ErrorMessage = String.Join("、", _modelState["realName"].Errors.Select(r => r.ErrorMessage)),
                   Id = "realName",
                   IsValid = _modelState.IsValid,
                   Label = "學員姓名：",
                   PlaceHolder = "請輸入姓名",
                   Name = "realName"
               }); %>

    
    <% Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>
    <script>
    $('#vip,#m_vip').addClass('active');
    </script>

</asp:Content>
<script runat="server">

    ModelStateDictionary _modelState;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
    }
</script>