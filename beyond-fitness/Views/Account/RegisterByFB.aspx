<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <uc1:PageBanner runat="server" ID="PageBanner" Title="會員專區" TitleInEng="VIP" />

    <!-- Start Content -->
    <div id="content">
        <div class="container">

            <div class="row">

                <div class="col-md-5">

                    <!-- Classic Heading -->
                    <h4 class="classic-title"><span class="fa fa-facebook-square"> 註冊 - Step 2</span></h4>

                    <!-- Start Post -->
                    <div class="blog-post quote-post">
                        <!-- Post Content -->
                        <div class="author-info clearfix">
                            <div class="author-image">
                                <% _item.RenderUserPicture(this.Writer, "userImg"); %>
                            </div>
                            <div class="author-bio">
                                <h2 class="text-primary"><%= _item.UserName %> <span class="subtext">您好</span></h2>

                                <div class="hr1" style="margin-top: 10px; margin-bottom: 10px;"></div>

                                <p><strong>會員編號：</strong><%= _item.MemberCode %></p>

                                <div class="form-group has-feedback">
                                    <% Html.RenderInput("Email：", "email", "email", "請輸入Email", _modelState, defaultValue: _item.PID); %>
                                </div>

                                <div class="hr1" style="margin-top: 10px; margin-bottom: 10px;"></div>
                            </div>
                        </div>
                    </div>
                    <!-- End Post -->

                    <div class="hr1" style="margin: 5px 0px;"></div>
                    <a  id="nextStep" class="btn-system btn-medium">下一步</a>
                    <a href="<%= VirtualPathUtility.ToAbsolute("~/Account/Register") %>" class="btn-system btn-medium border-btn">取消</a>

                    <!-- End Contact Form -->

                </div>
            </div>

        </div>
    </div>
    <!-- End content -->


    <script>
        $('#vip,#m_vip').addClass('active');
        $('#theForm').addClass('contact-form');
        $('#nextStep').on('click', function (evt) {
            startLoading();
          $('form').prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Account/FBCompleteRegister") %>')
            .submit();

        });

        $(function () {
            $('#email').rules('add', {
                'required': true,
                'email': true
            });
        });


    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    UserProfile _item;
    ModelStateDictionary _modelState;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _item = (UserProfile)this.Model;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
    }


</script>
