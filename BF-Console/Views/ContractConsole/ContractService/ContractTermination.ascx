<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Helper.DataOperation" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%  CourseContract currentItem = models.GetTable<CourseContractRevision>()
                                    .Where(c => c.OriginalContract == _model.ContractID)
                                    .Where(r => r.Reason == "終止")
                                    .Select(r => r.CourseContract)
                                    .Where(c => c.Status < (int)Naming.CourseContractStatus.已生效)
                                    .FirstOrDefault();
    var bookingCount = _model.CourseContractType.ContractCode == "CFA"
            ? _model.RegisterLessonContract.Sum(c => c.RegisterLesson.GroupingLesson.LessonTime.Count())
            : _model.RegisterLessonContract.First().RegisterLesson.GroupingLesson.LessonTime.Count;
    var contractCost = _model.TotalCost / _model.Lessons * bookingCount;
    var totalPaid = _model.TotalPaidAmount();
    var applicable = true;  %>
<div class="body">
    <div class="row">
        <div class="col-8">
            <h5 class="m-t-0">終止</h5>
            <%  if (_model.Status == (int)Naming.CourseContractStatus.已終止)
                {   
                    applicable = false; %>
            <span class="col-red"><i class="zmdi zmdi-block"></i>合約<%= (Naming.CourseContractStatus)_model.Status %></span><br />
            <%  }
                if (_model.IsContractServiceInProgress(models))
                {   
                    applicable = false; %>
            <span class="col-red"><i class="zmdi zmdi-block"></i>服務申請進行中</span><br />
            <%  }   %>
            <%  if (contractCost > totalPaid)
                { 
                    applicable = false; %>
            <span class="col-red"><i class="zmdi zmdi-block"></i>合約繳款餘額不足！（不足：<%= String.Format("{0:##,###,###,###}", contractCost - totalPaid) %>元）</span>
            <%  } %>
        </div>
        <div class="col-4 text-right">
            <a href="javascript:void();">
                <h2><%= _model.RevisionList.Where(r=>r.Reason=="終止").Count() %></h2>
            </a>
            <%  if (currentItem != null)
                {   %>
            <small class="info"><%= (Naming.ContractServiceStatus)currentItem.Status %></small>
            <%  }
                else if(applicable)
                {   %>
            <p>
                <button class="btn btn-darkteal btn-icon btn-icon-mini btn-round waves-effect float-right" onclick="terminateContract();"><i class="zmdi zmdi-plus"></i></button>
            </p>
            <%  } %>
        </div>
    </div>
</div>
<script>
    function terminateContract() {
        $('').launchDownload('<%= Url.Action("TerminateContract", "ConsoleHome") %>',
            <%= JsonConvert.SerializeObject(new 
            {
                KeyID = _model.ContractID.EncryptKey()
            }) %>);
    }
</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContract _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
    }


</script>
