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
                $('[name="<%= key %>"]').closest('div').append(
                    $('<span class="help-error-text" for="<%= key%>"></span>')
                        .text('<%= HttpUtility.JavaScriptStringEncode(_singleError 
                            ? _modelState[key].Errors[0].ErrorMessage
                            : String.Join("、", _modelState[key].Errors.Select(r => r.ErrorMessage))) %>')
                    );
                <%      if (_singleError)
                            break;
                    }  %>
            });
        </script>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    bool _singleError;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _singleError = ViewBag.SingleError == true;
    }

</script>
