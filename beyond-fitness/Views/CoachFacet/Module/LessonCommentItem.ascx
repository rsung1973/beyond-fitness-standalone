<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%    
    if (_model.Speaker.ServingCoach == null)
    {
        //left side   %>
<div class="messages-item">
    <%  _model.Speaker.RenderUserPicture(Writer, new { @class = "img-circle img-thumbnail", @style = "width:50px" }); %>
    <div class="messages-item-text"><%= _model.Comment %></div>
    <div class="messages-item-date"><%= _model.CommentDate %></div>
</div>
<%      }
    else
    { 
        //right side    %>
<div class="messages-item inbox">
    <%  _model.Speaker.RenderUserPicture(Writer, new { @class = "img-circle img-thumbnail", @style = "width:50px" }); %>
    <div class="messages-item-text"><%= _model.Comment %></div>
    <div class="messages-item-date"><%= _model.CommentDate %></div>
</div>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonComment _model;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonComment)this.Model;

    }

</script>
