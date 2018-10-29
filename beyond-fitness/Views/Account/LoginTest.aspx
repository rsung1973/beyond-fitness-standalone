<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="mainContent" runat="server">
    <div class="container">
        <div class="form-signin">
            <h2 class="form-signin-heading">beyond-fitness</h2>
            <%: Html.LabelForModel("使用者ID",new { @class = "sr-only", @for="PID"}) %>
            <%: Html.ValidationMessage("PID",new { @class = "text-danger" }) %>
            <%--<label for="PID" class="sr-only">使用者ID</label>--%>
            <input type="text" name="PID" class="form-control" placeholder="使用者ID" required autofocus />
            <%: Html.LabelForModel("密碼",new { @class = "sr-only", @for="PWD"}) %>
            <input type="password" name="PWD" placeholder="密碼" class="form-control" required />
<%--            <uc1:captchaimg runat="server" id="CaptchaImg" />
            <%: Html.ValidationMessage("ValidCode",new { @class = "text-danger" }) %>--%>
            <div class="checkbox">
                <label>
                    <input type="checkbox" value="remember-me" />
                    Remember me
                </label>
            </div>
            <button name="btnLogin" class="btn btn-lg btn-primary btn-block">登入</button>
            <script>
                $(function () {
                    $('button[name="btnLogin"]').on('click', function (evt) {
                        $('[data-valmsg-for]').empty();
                        $.post('<%= Url.Action("Login","Account") %>', $('form').serializeArray(), function (data) {
                            if (!data.result) {
                                for (var idx = 0; idx < data.errors.length; idx++) {
                                    $('[data-valmsg-for="' + data.errors[idx].name + '"]').text(data.errors[idx].message);
                                }
                            }
                        });
                        return false;
                    });
                });
            </script>
        </div>
    </div>

</asp:Content>
