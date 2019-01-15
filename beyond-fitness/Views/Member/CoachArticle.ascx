<%@  Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<article class="col-xs-12 col-sm-12 col-md-9 col-lg-9">
    <div class="well well-sm bg-color-darken txt-color-white">
        <div class="row">

            <%--<%  Html.RenderPartial("~/Views/Layout/Carousel.ascx"); %>--%>

            <div class="col-sm-12">

                <div class="row">

                    <div class="col-xs-6 col-sm-3 profile-pic">
                        <% _model.RenderUserPicture(Writer, "profileImg"); %>
                        <div class="padding-10">
                            <h4 class="font-md"><small><%= _model.IsFreeAgent() ? "自由教練" : _userProfile!=null && _userProfile.IsOfficer() && _model.ServingCoach.ProfessionalLevel!=null ? _model.ServingCoach.ProfessionalLevel.LevelName : "" %></small></h4>
                        </div>
                    </div>
                    <%  Html.RenderPartial("~/Views/Member/CoachInfo.ascx", _model); %>
                </div>
            </div>
        </div>
    </div>
</article>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    UserProfile _userProfile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _userProfile = Context.GetUser();
    }


</script>
