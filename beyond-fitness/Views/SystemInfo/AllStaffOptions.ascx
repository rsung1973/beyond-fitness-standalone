<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<% foreach (var item in _items)
    { %>
<option value="<%= item.UID %>"><%= item.RealName %></option>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<UserProfile> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;

        _items = models.GetTable<UserProfile>()
            .Join(models.GetTable<UserRole>()
                    .Where(r=>r.RoleID==(int)Naming.RoleID.Accounting
                        || r.RoleID==(int)Naming.RoleID.Administrator
                        || r.RoleID==(int)Naming.RoleID.Assistant
                        || r.RoleID==(int)Naming.RoleID.Coach
                        || r.RoleID==(int)Naming.RoleID.Manager
                        || r.RoleID==(int)Naming.RoleID.Officer
                        || r.RoleID==(int)Naming.RoleID.ViceManager),
                u => u.UID, r => r.UID, (u, r) => u);
    }

</script>
