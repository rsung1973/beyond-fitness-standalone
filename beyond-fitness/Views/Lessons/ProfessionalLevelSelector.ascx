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

<select name="<%= _model.Name ?? "coachLevel" %>" id="<%= _model.Id ?? "coachLevel" %>" class='<%= ViewBag.Inline==true ? "" : "input-lg" %>'>
    <%  if (ViewBag.SelectAll == true)
        { %>
            <option value="">全部</option>
    <%  } %>
    <%  if (ViewBag.SelectIndication != null)
        {
            Writer.WriteLine(ViewBag.SelectIndication);
        } %>
    <% foreach (var item in _items)
        { %>
            <option value="<%= item.LevelID %>" <%= item.LevelID == (int?)_model.DefaultValue ? "selected" : null %> ><%= item.LevelName %></option>
    <%  } %>
</select>
<script runat="server">

    InputViewModel _model;
    IQueryable<ProfessionalLevel> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _model = (InputViewModel)this.Model;
        var models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _items = models.GetTable<ProfessionalLevel>();
    }
</script>
