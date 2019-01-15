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
<h5 class="todo-group-title"><i class="fa fa-volume-up"></i> 已填寫階段性調整計劃 (<small class="num-of-tasks"><%= _items.Count() %></small>)</h5>
    <%  if (_items.Count() > 0)
        { %>
        <div>
            <ul class="notification-body">
                <%  foreach (var item in _items)
                    { %>
                <li>
                    <span class="padding-10">
                        <em class="badge padding-5 no-border-radius bg-color-darken pull-left margin-right-5">
                            <a href="<%= Url.Action("ShowLearner","Member", new { id = item.UID }) %>">
                                <%  item.UserProfile.RenderUserPicture(Writer, new { @class = "", @style = "width:40px" }); %></a>
                        </em>
                        <span><%= item.UserProfile.FullName() %>已填寫階段性調整計劃囉！
                            <button class="btn btn-xs bg-color-red margin-top-5" onclick="learnerQuestionnaire(<%= item.QuestionnaireID %>);"><i class="fa fa-unlock-alt"></i>讀取</button></span>
                        <time><%= String.Format("{0:yyyy/MM/dd}",item.PDQTask.First().TaskDate) %>
                            <%  if (item.Status == (int)Naming.IncommingMessageStatus.未讀)
                                { %>
                                    <span class="news_msg"></span>
                            <%  
                                    //if (!_profile.IsSysAdmin())
                                    //{
                                    //    item.Status = (int)Naming.IncommingMessageStatus.已讀;
                                    //    models.SubmitChanges();
                                    //}
                                } %>
                        </time>
                    </span>
                </li>
                <%  } %>
            </ul>
        </div>
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
            _items = questItems.Where(q => q.Status == (int)Naming.IncommingMessageStatus.未讀
                    || q.PDQTask.First().TaskDate >= DateTime.Today.AddDays(-7))
                .OrderByDescending(q => q.PDQTask.First().TaskDate)
                .Take(60);
        }
        else
        {
            questItems = questItems.Where(q => q.RegisterLesson.AdvisorID == _profile.UID);
            _items = questItems.Where(q => q.Status == (int)Naming.IncommingMessageStatus.未讀
                    || q.PDQTask.First().TaskDate >= DateTime.Today.AddDays(-7))
                .OrderByDescending(q => q.PDQTask.First().TaskDate);
        }

    }

</script>
