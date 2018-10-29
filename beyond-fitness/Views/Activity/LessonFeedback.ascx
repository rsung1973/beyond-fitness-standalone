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
        <tr>
            <td>
                <div class="chat-body custom-scroll" style="height: 150px">
                    <ul>
                        <li class="message">
                            <% _model.RegisterLesson.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online", @style = "width:80px" }); %>
                            <div class="message-text feedback-item">
                                <time><%= String.Format("{0:yyyy/MM/dd HH:mm}",_item!=null ? _item.FeedBackDate : null) %></time>
                                <a class="username"><%= _model.RegisterLesson.UserProfile.FullName() %></a> 
                                <%= _item!=null ? _item.FeedBack : null %>
                            </div>
                        </li>
                    </ul>
                </div>
                <div class="chat-footer">
                    <!-- CHAT TEXTAREA -->
                    <div class="textarea-div">
                        <div class="typearea">
                            <textarea id="lessonFeedBack" placeholder="請輸入100個中英文字" class="custom-scroll" maxlength="100" rows="20"></textarea>
                        </div>
                    </div>

                    <!-- CHAT REPLY/SEND -->
                    <span class="textarea-controls">
                        <button onclick="updateLessonFeedBack(<%= _model.LessonID %>);" class="btn btn-sm btn-primary pull-right">
                            更新
                        </button>
                    </span>
                </div>
            </td>
        </tr>
    </tbody>
</table>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;
    UserProfile _profile;
    LessonFeedBack _item;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;

        _profile = Context.GetUser();
        if (_profile == null)
        {
            Response.Redirect(FormsAuthentication.LoginUrl);
        }
        else
        {
            _item = _model.LessonFeedBack.Where(f => f.RegisterLesson.UID == _profile.UID).FirstOrDefault();
        }

    }

</script>
