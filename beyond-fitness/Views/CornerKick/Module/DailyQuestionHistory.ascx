<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<% if (_items.Count() > 0)
    {   %>
<div class="accordion js-accordion">
    <%  foreach (var item in _items)
        {
            Html.RenderPartial("~/Views/CornerKick/Module/AnsweredDailyQuestion.ascx", item);
        } %>
</div>
<%  }
    else
    {
        Html.RenderPartial("~/Views/CornerKick/Module/AnsweredQuestionNotFound.ascx");
    }  %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<PDQTask> _items;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();

        _items = models.GetTable<PDQTask>().Where(t => t.UID == _profile.UID)
                .Join(models.GetTable<PDQQuestion>().Where(q => q.GroupID == 6),
                    t => t.QuestionID, q => q.QuestionID, (t, q) => t)
                .OrderByDescending(t => t.TaskID)
                .Take(5);
    }

</script>
