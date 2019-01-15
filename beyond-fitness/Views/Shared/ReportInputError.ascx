<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_modelState != null && !_modelState.IsValid)
    {  %>
        <script>
            $(function () {
                <%  foreach(var key in _modelState.Keys.Where(k => _modelState[k].Errors.Count > 0))
                    {   %>
                $('[name="<%= key %>"]').addClass('error').parent().after(
                    $('<label id="<%= key%>-error" class="error" for="<%= key%>"></label>')
                        .text('<%= HttpUtility.JavaScriptStringEncode(String.Join("、", _modelState[key].Errors.Select(r => r.ErrorMessage))) %>')
                    );
                <%  }  %>
            });
        </script>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
