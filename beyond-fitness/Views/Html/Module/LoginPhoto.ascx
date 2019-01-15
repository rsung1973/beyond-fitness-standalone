<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%  if (_profile != null)
    {
        _profile.RenderUserPicture(Writer, new { @class = "img-circle img-thumbnail", @style = "width:100px" });
    }
    else
    { %>
        <img src="<%= VirtualPathUtility.ToAbsolute("~/img/avatars/male.png") %>" class="img-circle img-thumbnail" width="100px"/>
<%  }

    Html.RenderAction("AutoLogin", "Html", new { timeTicks = DateTime.Now.Ticks });

     %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;

        HttpCookie cookie = Context.Request.Cookies["userID"];
        if (cookie != null)
        {
            _profile = models.GetTable<UserProfile>().Where(u => u.PID == cookie.Value).FirstOrDefault();
        }
    }

</script>
