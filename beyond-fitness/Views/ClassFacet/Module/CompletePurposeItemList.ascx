<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_model != null)
    {
        var items = _model.PersonalExercisePurposeItem.Where(p => p.CompleteDate.HasValue);

        foreach (var item in items)
        { %>
<tr>
    <td><%= String.Format("{0:yyyy/MM/dd}",item.CompleteDate) %></td>
    <td><i class="fa fa-check"></i><%= item.PurposeItem %></td>
</tr>
<%      } %>
<%  } %>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PersonalExercisePurpose _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = this.Model as PersonalExercisePurpose;
    }


</script>
