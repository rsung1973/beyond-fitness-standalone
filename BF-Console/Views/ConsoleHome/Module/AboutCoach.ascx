<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="container-fluid">
    <div class="row clearfix">
        <div class="col-lg-12 col-md-12">
            <div class="row clearfix">
                <div class="col-sm-6 col-12 achivement">
                    <h4 class="card-outbound-header">我的業績</h4>
                    <div class="parallax-img-card">
                        <div class="body">
                            <h4><%= _model.UserRoleAuthorization.Any(r=>r.RoleID==(int)Naming.RoleID.Officer )
                            ? "CEO"
                            : _model.UserRoleAuthorization.Any(r=> r.RoleID==(int)Naming.RoleID.Manager)
                                ? "FM"
                                : _model.UserRoleAuthorization.Any(r=> r.RoleID==(int)Naming.RoleID.ViceManager)
                                    ? "AFM"
                                    : _model.ServingCoach.ProfessionalLevel.LevelName %>
                                <%= _model.UserRoleAuthorization.Any(r=> r.RoleID==(int)Naming.RoleID.ViceManager) && (int)Naming.ProfessionalCategory.AFM!=_model.ServingCoach.ProfessionalLevel.CategoryID.Value ? $" / {_model.ServingCoach.ProfessionalLevel.LevelName}" : null %>
                                <br />
                                <%= _model.ServingCoach.CoachCertificate.Count %> 張證照</h4>
                        </div>
                        <div class="parallax">
                            <img src="images/carousel/level-background.jpg"></div>
                    </div>
                </div>
                <%  Html.RenderPartial("~/Views/ConsoleHome/Module/AboutContest.ascx", _model); %>
            </div>
        </div>
    </div>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }


</script>
