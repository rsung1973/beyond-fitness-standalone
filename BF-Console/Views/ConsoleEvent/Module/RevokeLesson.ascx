<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%  if (_model.CouldBeCancelled(_userProfile))
    {%>
<button type="button" class="btn btn-danger btn-round btn-simple btn-round waves-effect waves-red" onclick="javascript:deleteLesson('<%= _model.LessonID.EncryptKey() %>');"><i class="zmdi zmdi-delete"></i></button>
<%  } %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;
    UserProfile _userProfile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
        _userProfile = Context.GetUser();
    }


</script>
