<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="WebHome.Views.MainActivity.Resources" %>

    <section class="section-contact">
        <div class="container">
            <div class="row">
                <div class="col-md-12 text-center">
                    <h1><%: NamingItem.ContactTitle %></h1>
                    <p class="lead"><%: NamingItem.ContactSubTitle %></p>
                    <a href="<%= Url.Action("BookNow") %>" class="more"><%: NamingItem.ContactAskNow %><i class="pl-1 fa fa-angle-right"></i></a>
                    <ul class="contact_social">
                        <li><a href="https://www.facebook.com/beyond.fitness.pro/" target="_blank"><i class="zmdi zmdi-facebook"></i></a></li>
                        <li><a href="https://www.instagram.com/beyond_ft/" target="_blank"><i class="zmdi zmdi-instagram"></i></a></li>
                        <li><a href="https://www.youtube.com/channel/UCPIcjPGaFFB1o8cFDUrT-4g" target="_blank"><i class="zmdi zmdi-youtube-play"></i></a></li>
                        <li><a href="line://ti/p/@itj9410x" target="_blank"><i class="fab fa-line"></i></a></li>
                    </ul>
                    <div class="copyright">Copyright © 2018 Beyond Fitness. All Rights Reserved</div>
                </div>
            </div>
        </div>
    </section>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }


</script>
