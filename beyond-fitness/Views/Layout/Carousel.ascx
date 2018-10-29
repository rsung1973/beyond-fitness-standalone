<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="col-sm-12">
    <div id="myCarousel" class="carousel fade profile-carousel">
        <ol class="carousel-indicators">
            <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
            <li data-target="#myCarousel" data-slide-to="1" class=""></li>
            <li data-target="#myCarousel" data-slide-to="2" class=""></li>
        </ol>
        <div class="carousel-inner">
            <!-- Slide 1 -->
            <div class="item active">
                <img alt="demo user" src="<%= VirtualPathUtility.ToAbsolute("~/img/slider/bg8.jpg") %>">
            </div>
            <!-- Slide 2 -->
            <div class="item">
                <img alt="demo user" src="<%= VirtualPathUtility.ToAbsolute("~/img/slider/bg5.jpg") %>">
            </div>
            <!-- Slide 3 -->
            <div class="item">
                <img alt="demo user" src="<%= VirtualPathUtility.ToAbsolute("~/img/slider/bg6.jpg") %>">
            </div>
        </div>
    </div>
</div>

<%--<script>
        $(function () {
            $('.carousel.slide').carousel({
                interval: 3000,
                cycle: true
            });
            $('.carousel.fade').carousel({
                interval: 3000,
                cycle: true
            });
        });
</script>--%>

<script runat="server">

    ModelStateDictionary _modelState;
    UserProfile _userProfile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _userProfile = Context.GetUser();
    }

</script>
