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

    <% if (_items != null && _items.Count() > 0)
        {   %>
            <label class="label">點數兌換課學員，搜尋結果如下：</label>
        <%  foreach (var item in _items)
            {
                bool pdqStatus = completePDQ(item);

                %>
                <label class="<%= pdqStatus ? "radio" : "radio state-disabled" %>">
                <input type="radio" name="registerID" value="<%= item.RegisterID %>" <%= pdqStatus ? null : "disabled" %> />
                <i></i>
                        <%= item.UserProfile.FullName() %>「<%= item.Lessons %>堂-<%= item.LessonPriceType.Description %>」
                            <li class="fa fa-child"></li>
                    <%  if (item.AwardingLessonGift.Count > 0)
                        { %>
                    （由<%= item.AwardingLessonGift.First().LearnerAward.UserProfile.FullName() %>贈與禮物包1堂）
                    <%  } %>
                    <%  if (!pdqStatus)
                        { %>
                    <span class="label label-danger">
                        <li class="fa fa-exclamation-triangle"></li> PDQ尚未登打或登打不完全！</span>
                    <%  }   %>
                </label>

    <%      }
        }
        else
        { %>
            <span>查無相符條件的上課資料！</span>
    <%  } %>


<script runat="server">

    ModelStateDictionary _modelState;
    IQueryable<RegisterLesson> _items;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _items = (IQueryable<RegisterLesson>)this.Model;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

    bool completePDQ(RegisterLesson lesson)
    {
        return lesson.UserProfile.PDQTask
            .Select(t => t.PDQQuestion)
            .Where(q => q.PDQQuestionExtension == null).Count() >= 20;
    }


</script>
