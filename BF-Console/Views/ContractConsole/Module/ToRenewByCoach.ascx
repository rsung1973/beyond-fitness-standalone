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

<%
    CourseContractQueryViewModel queryModel = new CourseContractQueryViewModel
    {
        AlarmCount = 4,
        Status = (int)Naming.CourseContractStatus.已生效,
    };
    var tobeContinued = models.PromptEffectiveContract();
    tobeContinued = tobeContinued.Where(c => c.FitnessConsultant == _model.UID);
    queryModel.FitnessConsultant = _model.UID;
    tobeContinued = tobeContinued.FilterByAlarmedContract(models, 4);
%>
<div class="body top_counter">
    <div class="icon">
        <i class="zmdi livicon-evo" data-options="name:users.svg; size: 40px; style: solid; strokeWidth:2px; autoPlay:true"></i>
    </div>
    <div class="content">
        <div class="text">待續約 <span class="col-grey float-right">人</span></div>
        <h5 class="number"><%= tobeContinued.Select(c => c.OwnerID).Distinct().Count() %></h5>
    </div>
    <hr>
    <div class="icon">
        <i class="zmdi livicon-evo" data-options="name:battery-charge.svg; size: 40px; style: solid; strokeWidth:2px; autoPlay:true"></i>
    </div>
    <div class="content">
        <div class="text">待續約 <span class="col-grey float-right">合約</span></div>
        <h5 class="number"><a onclick='showContractList(<%= JsonConvert.SerializeObject(
                                    new
                                    {
                                        Status = queryModel.Status,
                                        ManagerID = queryModel.ManagerID,
                                        FitnessConsultant = queryModel.FitnessConsultant,
                                        AlarmCount = queryModel.AlarmCount,
                                        ContractQueryMode = (int)Naming.ContractServiceMode.ContractOnly,
                                    }) %>,<%= tobeContinued.Count() %>);'><%= tobeContinued.Count() %></a></h5>
    </div>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }


</script>
