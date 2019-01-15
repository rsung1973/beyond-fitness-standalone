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
    <%  if (_items.Count() > 0)
        { %>
            <ul class="notification-body">
                <%  foreach (var item in _items)
                    { %>
                        <li>
                            <span class="unread">
                                <a onclick="learnerQuestionnaireActivity(event,<%= item.QuestionnaireID %>);" class="msg">
                                    <%  item.UserProfile.RenderUserPicture(Writer, new { @class = "air air-top-left margin-top-5", @style = "width:40px" }); %>
                                    <span class="from"><%= item.UserProfile.FullName() %><i class="icon-paperclip"></i></span>
                                    <time><%= String.Format("{0}",item.PDQTask.First().TaskDate) %>
                                        <%  if (item.Status == (int)Naming.IncommingMessageStatus.未讀)
                                            { %>
                                        <span class="news_msg"></span>
                                        <%  } %>
                                    </time>
                                    <span class="msg-body">已填寫階段性調整計劃</span>
                                </a>
                            </span>
                        </li>
                <%  } %>
            </ul>
    <%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;

    IQueryable<QuestionnaireRequest> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();

        IQueryable<QuestionnaireRequest> questItems = models.GetTable<QuestionnaireRequest>().Where(q => q.PDQTask.Count > 0);

        if (_profile.IsSysAdmin())
        {
            _items = questItems.Where(q => q.Status == (int)Naming.IncommingMessageStatus.未讀)
                .OrderByDescending(q => q.PDQTask.First().TaskDate);
        }
        else
        {
            var uid = models.GetTable<LearnerFitnessAdvisor>().Where(l => l.CoachID == _profile.UID).Select(l => l.UID);
            questItems = questItems.Where(q => uid.Contains(q.UID));

            _items = questItems.Where(q => q.Status == (int)Naming.IncommingMessageStatus.未讀)
                .OrderByDescending(q => q.PDQTask.First().TaskDate);
        }

    }

</script>
