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

<table class="table" width="100%">
    <tbody>
        <%  foreach (var item in _model.LessonFeedBack)
            { %>
                <tr>
                    <td colspan="4">
                        <div class="chat-body custom-scroll">
                            <ul>
                                <li class="message">
                                    <% item.RegisterLesson.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online", @style = "width:80px" }); %>
                                    <div class="message-text">
                                        <time><%= String.Format("{0:yyyy/MM/dd HH:mm}",item.FeedBackDate) %></time>
                                        <a href="#" class="username"><%= item.RegisterLesson.UserProfile.UserName ?? item.RegisterLesson.UserProfile.FullName() %></a> 
                                        <%= item.FeedBack %>
                                    </div>
                                </li>
                            </ul>
                        </div>
                    </td>
                </tr>
        <%  } %>
    </tbody>
</table>

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
