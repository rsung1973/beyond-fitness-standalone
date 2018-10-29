<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<!-- Start Page Banner -->
<div class="page-banner" style="padding: 20px 0; background: url(<%= VirtualPathUtility.ToAbsolute("~/images/page_banner_bg.gif") %>);">
    <div class="container">
        <div class="row">
            <div class="col-md-6">
                <h2><%: Title %></h2>
                <p><%: TitleInEng %></p>
            </div>
            <div class="col-md-6">
                <ul class="breadcrumbs">
                    <li><a href="<%= VirtualPathUtility.ToAbsolute("~/Account/Index") %>">首頁</a></li>
                    <li>專業知識</li>
                </ul>
            </div>
        </div>
    </div>
</div>
<!-- End Page Banner -->

<script runat="server">

    [System.ComponentModel.Bindable(true)]
    public String Title
    {
        get; set;
    }

    [System.ComponentModel.Bindable(true)]
    public String TitleInEng
    {
        get; set;
    }


</script>
