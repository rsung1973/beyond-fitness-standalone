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
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h6 class="title">請選擇執行功能</h6>
                <a class="closebutton" data-dismiss="modal"></a>
            </div>
            <div class="modal-popmenu-body">
                <div class="list-group">
                    <%  var revision = _model.CourseContractRevision;
                        if (_model.IsServiceApprovable(models, _profile))
                        {   %>
                            <a href="<%= Url.Action("SignContractService","ConsoleHome",new { KeyID = _model.ContractID.EncryptKey() }) %>" class="list-group-item">主管審核（<%= revision.Reason %>）</a>
                    <%  }
                        else if (_model.IsServiceSignable(models, _profile))
                        {   %>
                            <a href="<%= Url.Action("SignContractService","ConsoleHome",new { KeyID = _model.ContractID.EncryptKey() }) %>" class="list-group-item">學生簽名（展延）</a>
                    <%  }
                        if (_model.Status == (int)Naming.CourseContractStatus.已生效)
                        {   %>
                            <a href="contract-pdf-end.html" target="_blank" class="list-group-item">查看電子合約（終止）</a>
                    <%  }   %>
                </div>
            </div>
        </div>
    </div>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
    <script>
        $(function () {

        });
    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContract _model;
    String _dialogID = $"serviceProcess{DateTime.Now.Ticks}";
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
        _profile = Context.GetUser();
    }


</script>
