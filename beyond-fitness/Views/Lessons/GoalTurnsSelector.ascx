<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<select class="form-control" name="goalTurns">
    <option value="0">--</option>
    <%  for (int i = 1; i <= 100;)
               { %>
            <option <%= i == _goalTurns ? "selected" : null %>><%= i %></option>
    <%      if (i < 20)
                i++;
            else if (i < 50)
                i += 5;
            else
                i += 10;
        } %>
</select>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    int? _goalTurns;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _goalTurns = (int?)this.Model;
    }

</script>
