<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<tr>
    <td>
        <%= _model.Description %>
        <input type="hidden" name="EnterprisePriceID" value="<%= _model.TypeID %>" />
    </td>
    <td>
        <%= _viewModel.DurationInMinutes %>分鐘
        <input type="hidden" name="EnterpriseDurationInMinutes" value="<%= _viewModel.DurationInMinutes %>" />
    </td>
    <td>
        <%= _viewModel.Lessons %>堂
        <input type="hidden" name="EnterpriseLessons" value="<%= _viewModel.Lessons %>" />
    </td>
    <td>
        <%= _viewModel.ListPrice %>
        <input type="hidden" name="EnterpriseListPrice" value="<%= _viewModel.ListPrice %>" />
    </td>
    <td>
        <a onclick="$global.deleteItem();" class="btn btn-circle bg-color-red delete"><i class="fa fa-fw fa fa-lg fa-trash-alt" aria-hidden="true"></i></a>
    </td>
</tr>



<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "program" + DateTime.Now.Ticks;
    EnterpriseProgramItemViewModel _viewModel;
    EnterpriseLessonType _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (EnterpriseProgramItemViewModel)ViewBag.ViewModel;
        _model = (EnterpriseLessonType)this.Model;
    }

</script>
