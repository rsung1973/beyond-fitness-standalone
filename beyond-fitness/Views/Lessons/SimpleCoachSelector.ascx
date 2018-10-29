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

<select name="<%= _model.Name ?? "coach" %>" id="<%= _model.Id ?? "coach" %>">
    <%  if (ViewBag.SelectAll == true)
        { %>
            <option value="">全部</option>
    <%  } %>
    <%  if (ViewBag.SelectIndication != null && _items.Count() > 1)
        {
            Writer.WriteLine(ViewBag.SelectIndication);
        } %>
    <% foreach (var item in _items)
        { %>
            <option value="<%= item.CoachID %>" <%= item.CoachID == (int?)_model.DefaultValue ? "selected" : null %> ><%= item.UserProfile.FullName() %><%= item.UserProfile.IsFreeAgent() ? "(自由教練)" : null %></option>
    <%  } %>
</select>
<script runat="server">

    InputViewModel _model;
    IQueryable<ServingCoach> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _model = (InputViewModel)this.Model;
        var models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _items = models.GetTable<ServingCoach>();
        if (ViewBag.ByFreeAgent != null)
        {
            int? freeAgent = (int?)ViewBag.ByFreeAgent;
            _items = _items.Where(c => c.CoachID == freeAgent);
        }
        else if(ViewBag.ByAuthorization==true)
        {
            var profile = Context.GetUser();
            if (!profile.IsAssistant() && !profile.IsAccounting())
            {
                _items = _items.Where(c => c.CoachID == profile.UID);
            }
        }
    }
</script>
