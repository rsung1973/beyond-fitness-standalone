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
        var items = _model.PersonalExercisePurposeItem.Where(p => !p.CompleteDate.HasValue);

        foreach (var item in items)
        { %>
<tr>
    <td><%= item.PurposeItem %></td>
    <td>
        <a onclick="completePurposeItem(<%= item.ItemID %>);" class="btn btn-circle btn-success"><i class="fa fa-fw fa fa-lg fa-check" aria-hidden="true"></i></a>&nbsp;&nbsp;
        <a onclick="deletePurposeItem(<%= item.ItemID %>);" class="btn btn-circle bg-color-red delete"><i class="fa fa-fw fa fa-lg fa-trash-alt" aria-hidden="true"></i></a>&nbsp;&nbsp;
    </td>
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
