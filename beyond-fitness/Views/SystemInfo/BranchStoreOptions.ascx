<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  IQueryable<BranchStore> items= (IQueryable<BranchStore>)ViewBag.DataItems ?? models.GetTable<BranchStore>();
    if (ViewBag.IntentStore!=null)
    {
        int[] branchID = (int[])ViewBag.IntentStore;
        items = items.Where(b => branchID.Contains(b.BranchID));
    }

    foreach (var b in items)
    { %>
<option value="<%= b.BranchID %>" <%= _model == b.BranchID ? "selected": null %>><%= b.BranchName %></option>
<%  } %>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    int? _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (int?)this.Model;
    }

</script>
