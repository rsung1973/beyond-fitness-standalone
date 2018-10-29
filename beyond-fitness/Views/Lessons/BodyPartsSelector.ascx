<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<select class="form-control" name="trainingID">
    <%  foreach (var item in _items)
        { %>
            <option value='<%= item.TrainingID %>' <%= item.TrainingID==_trainingID ? "selected" : null %>><%= item.BodyParts %></option>
    <%  } %>
</select>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<TrainingType> _items;
    int? _trainingID;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _items = models.GetTable<TrainingType>().Where(t => t.TrainingID < 8);
        _trainingID = this.Model as int?;
    }

</script>
