<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<!-- content goes here -->
<h5 class="todo-group-title"><i class="fa fa-commenting"></i>學員悄悄話 (<small class="num-of-tasks"><%= _items.Count() %></small>)</h5>
<%  if (_items.Count() > 0)
    { %>
<div class="custom-scroll" style="height: 350px; overflow-y: scroll;">
    <ul class="notification-body">
        <%  foreach (var item in _items)
            { %>
        <li>
            <span>
                <a href="<%= Url.Action("ShowLearner","Member", new { id = item.RegisterLesson.UID }) %>" class="msg">
                    <%  item.RegisterLesson.UserProfile.RenderUserPicture(Writer, new { @class = "air air-top-left margin-top-5", @style = "width:40px" }); %>
                    <span class="from"><%= item.RegisterLesson.UserProfile.FullName() %> <i class="icon-paperclip"></i><i class="icon-paperclip"></i>
                        <button class="btn btn-xs txt-color-white bg-color-blueLight" onclick="javascript:lessonRemark(<%= item.LessonID %>,<%= item.RegisterID %>);return false;"><i class="fa fa-commenting-o"></i>回覆</button>
                        <button class="btn btn-primary btn-xs" onclick="showRecentLessons(<%= item.RegisterLesson.UID %>, <%= item.LessonID %>, false);return false;"><i class="fa fa-fw fa-eye"></i>檢視上課記錄</button>
                    </span>
                    <time><%= item.RemarkDate %>
                        <%  if (item.Status == (int)Naming.IncommingMessageStatus.未讀)
                            { %>
                        <span class="news_msg"></span>
                        <%  
                                if (!_profile.IsSysAdmin())
                                {
                                    item.Status = (int)Naming.IncommingMessageStatus.已讀;
                                    models.SubmitChanges();
                                }
                            } %>
                    </time>
                    <span class="msg-body"><%= item.Remark %></span>
                </a>
            </span>
        </li>
        <%  } %>
    </ul>
</div>
<%  } %>

<script>
    function lessonRemark(lessonID, registerID) {
        showLoading();
        $.post('<%= Url.Action("LessonRemark","Lessons") %>', { 'lessonID': lessonID, 'registerID': registerID }, function (data) {
            $(data).appendTo($('#content'));
            hideLoading();
        });
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;

    IQueryable<LessonFeedBack> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();

        if (_profile.IsSysAdmin())
        {
            _items = models.GetTable<LessonFeedBack>()
                .Where(u => u.Remark != null)
                .Where(u => u.RemarkDate.HasValue)
                .OrderByDescending(u => u.RemarkDate).Take(60);
        }
        else
        {
            _items = models.GetTable<LessonFeedBack>().Where(u => u.LessonTime.AttendingCoach == _profile.UID)
                .Where(u => u.Remark != null)
                .Where(u => u.RemarkDate.HasValue)
                .OrderByDescending(u => u.RemarkDate).Take(30);
        }

    }

</script>
