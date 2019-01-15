<%@  Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

    <div class="col-xs-6 col-sm-6">
        <div class="panel panel-default">
            <div class="panel-body status">
                <div class="who clearfix">
                    <img runat="server" src="~/img/avatars/female.png" alt="img" class="busy" />
                    <span class="from"><b><%= _pdqGroups[0].GroupName %></b> </span>
                </div>
                <ol>
                    <%  foreach (var item in _pdqGroups[0].PDQQuestion.OrderBy(q => q.QuestionNo))
                        {
                            renderItem(item);
                        } %>
                </ol>
            </div>
        </div>
    </div>
    <div class="col-xs-6 col-sm-6">
        <%  for(int i=1;i<_pdqGroups.Length;i++)
            {
                var g = _pdqGroups[i]; %>
                <div class="panel panel-default">
                    <div class="panel-body status">
                        <div class="who clearfix">
                            <img alt="img" class="busy" src="<%= VirtualPathUtility.ToAbsolute("~/img/avatars/female.png") %>" />
                            <span class="from"><b><%= g.GroupName %></b> </span>
                        </div>

                        <ol>
                            <%  foreach (var item in g.PDQQuestion.OrderBy(q => q.QuestionNo))
                                {
                                    renderItem(item);
                                } %>
                        </ol>
                    </div>
                </div>
        <%  } %>
    </div>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    PDQGroup[] _pdqGroups;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _pdqGroups = models.GetTable<PDQGroup>()
            .Where(g => g.GroupID < 6)
            .OrderBy(g => g.GroupID).ToArray();

    }

    void renderItem(PDQQuestion item)
    {
        ViewBag.PDQTask = item.PDQTask.Where(p => p.UID == _model.UID).FirstOrDefault();
        ViewBag.Answer = item.PDQTask.Where(p => p.UID == _model.UID && !p.SuggestionID.HasValue).FirstOrDefault();
        Html.RenderPartial("~/Views/Member/PDQItemInfo.ascx", item);
    }

</script>
