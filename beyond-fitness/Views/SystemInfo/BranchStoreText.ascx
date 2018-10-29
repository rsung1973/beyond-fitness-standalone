<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%= _item!=null ? _item.BranchName : _other %>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    int? _model;
    String _other;
    BranchStore _item;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        if (this.Model is Nullable<int>)
            _model = (int?)this.Model;

        _item = models.GetTable<BranchStore>().Where(b => b.BranchID == _model).FirstOrDefault();
        _other = ViewBag.Other ?? "全部";
    }

</script>
