<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  foreach (var item in _model.LessonFeedBack.Where(f => f.Remark != null))
    { %>
        <div class="chat-body custom-scroll remark-item" style="height: 150px">
            <ul>
                <li class="message">
                    <% item.RegisterLesson.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online", @style = "width:80px" }); %>
                    <div class="message-text">
                        <time><%= String.Format("{0:yyyy/MM/dd HH:mm}",item.RemarkDate) %>
                        </time><a class="username"><%= item.RegisterLesson.UserProfile.FullName() %></a>
                        <%= item.Remark %>
                    </div>
                </li>
            </ul>
        </div>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
    }

</script>
