<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<header>
    <h2>日期：<%= _model.DiagnosisDate.ToString("yyyy/MM/dd") %></h2>
    <div class="widget-toolbar">
        <div class="btn-group">
            <button class="btn dropdown-toggle btn-xs btn-warning" data-toggle="dropdown">
                診斷日期 <i class="fa fa-caret-down"></i>
            </button>
            <ul class="dropdown-menu pull-right">
                <%  if (_model != null)
                    {
                        foreach (var d in _model.UserProfile.BodyDiagnosis.Where(d=>d.LevelID==(int)Naming.DocumentLevelDefinition.正常))
                        { %>
                            <li>
                                <a onclick="diagnosisContentByLearner(<%= d.DiagnosisID %>);"><%= d.DiagnosisDate.ToString("yyyy/MM/dd") %></a>
                            </li>
                    <%  }
                    }%>
            </ul>
        </div>
    </div>
</header>
<!-- widget div-->
<div>
    <%  Html.RenderPartial("~/Views/FitnessDiagnosis/Module/DiagnosisItem.ascx", _model); %>
</div>
<!-- end widget div -->


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "diagnosis" + DateTime.Now.Ticks;
    BodyDiagnosis _model;
    FitnessDiagnosisViewModel _viewModel;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = this.Model as BodyDiagnosis;
        _viewModel = (FitnessDiagnosisViewModel)ViewBag.ViewModel;
    }

</script>
