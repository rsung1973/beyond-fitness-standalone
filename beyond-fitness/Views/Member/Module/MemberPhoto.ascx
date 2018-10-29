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

<div class="head-panel nm text-center">
    <%  if (ViewBag.IsLearner == true)
        { %>
    <a href="javascript:editLearner(<%= _model.UID %>);"><% _model.RenderUserPicture(Writer, new { @class = "img-circle img-thumbnail", @style = "width:130px" }); %></a>
    <%  }
        else
        { %>
    <a href="javascript:editProfile(<%= _model.UID %>);"><% _model.RenderUserPicture(Writer, new { @class = "img-circle img-thumbnail", @style = "width:130px" }); %></a>
    <%  } %>
</div>

<script>

    function editProfile(uid) {
        showLoading();
        $.post('<%= Url.Action("EditMySelf","Html") %>', { 'uid': uid }, function (data) {
                $(data).appendTo($('body'));
                hideLoading();
            });
    }

    function editLearner(uid) {
        showLoading();
        $.post('<%= Url.Action("EditLearner","Learner") %>', { 'uid': uid }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }

</script>


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
