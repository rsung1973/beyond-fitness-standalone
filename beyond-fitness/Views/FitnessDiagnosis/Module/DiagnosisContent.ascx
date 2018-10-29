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
    <h2><%= ViewBag.IsFirst==true ? "首次" : null %>診斷日期：<%= _model!=null ? _model.DiagnosisDate.ToString("yyyy/MM/dd") : null %></h2>
    <div class="widget-toolbar">
        <%  if (_model==null || !models.GetTable<BodyDiagnosis>().Any(b => b.LearnerID == _model.LearnerID && b.LevelID == (int)Naming.DocumentLevelDefinition.暫存))
            { %>
        <a onclick="createDiagnosis();" class="btn  btn-primary"><i class="fa fa-plus"></i>新增診斷</a>
        <%  } %>
        <div class="btn-group">
            <button class="btn dropdown-toggle btn-xs btn-warning" data-toggle="dropdown">
                診斷日期 <i class="fa fa-caret-down"></i>
            </button>
            <ul class="dropdown-menu pull-right">
                <%  if (_model != null)
                    {
                        foreach (var d in _model.UserProfile.BodyDiagnosis)
                        { %>
                            <li>
                                <a onclick="diagnosisContent(<%= d.DiagnosisID %>);"><%= d.DiagnosisDate.ToString("yyyy/MM/dd") %></a>
                            </li>
                    <%  }
                    }%>
            </ul>
        </div>
    </div>
</header>
<!-- widget div-->
<div>
    <%  if (_viewModel.DiagnosisID.HasValue)
        {
            Html.RenderPartial("~/Views/FitnessDiagnosis/Module/DiagnosisItem.ascx", _model);
        } %>
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
