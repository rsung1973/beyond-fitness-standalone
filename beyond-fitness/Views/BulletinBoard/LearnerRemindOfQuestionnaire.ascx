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
<h5 class="todo-group-title"><i class="fa fa-volume-up"></i> 階段性調整計劃 (<small class="num-of-tasks"><%= _items.Count() %></small>)</h5>
    <%  if (_items.Count() > 0)
        { %>
        <ul id="sortable4" class="todo">
            <%  foreach (var item in _items)
                { %>
                    <li>
                        <span class="handle"><a href="<%= Url.Action("ViewProfile","Account") %>">
                            <%  item.UserProfile.RenderUserPicture(Writer, new { @class = "air air-top-left margin-top-5", @style = "width:40px" }); %></a></span>
                        <p>
                            <strong>為了讓您的體能顧問做出更優化的階段性調整，下方提供
                &lt;六個小問題&gt;
                請您回答補充，資料僅提供訓練使用，不會外洩，敬請放心填寫！<span class="news_msg"></span></strong>
                            <span>
                                <button class="btn btn-xs bg-color-teal" onclick="javascript:(window.location.href='<%= Url.Action("Questionnaire","Interactivity",new { id = item.QuestionnaireID }) %>');"><i class="fa fa-volume-up"></i>說出您的想法</button>
                            </span>
                        </p>
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

        _items = models.GetTable<QuestionnaireRequest>()
                .Where(q => q.UID == _profile.UID && q.PDQTask.Count == 0);

    }

</script>
