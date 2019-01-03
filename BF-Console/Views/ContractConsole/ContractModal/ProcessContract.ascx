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
                    <%  if (_model.IsEditable(models,_profile))
                        {   %>
                    <a href="contract-edit.html" class="list-group-item">編輯資料</a>
                    <a href="javascript:deleteData();" class="list-group-item">刪除資料</a>
                    <%  }
                        else if(_model.IsSignable(models,_profile))
                        {   %>
                    <a href="contract-sign.html" class="list-group-item">學生簽名</a>
                    <%  }
                        else if(_model.IsApprovable(models,_profile))
                        {   %>
                    <a href="contract-approve.html" class="list-group-item">主管審核</a>
                    <%  }
                        else if(_model.IsPayable(models))
                        {   %>
                    <a href="payment-edit-type1.html" class="list-group-item">新增收款</a>
                    <%  }
                        if (_model.CanApplyContractAmendment(models))
                        {   %>
                    <a href="contract-apply.html" class="list-group-item">服務申請</a>
                    <%  }   %>
                    <a href="javascript:showContractDetails('<%= _model.ContractID.EncryptKey() %>');" class="list-group-item">詳細資訊</a>
                    <a href="contract-pdf.html" target="_blank" class="list-group-item">列印電子合約</a>
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
    String _dialogID = $"contractProcess{DateTime.Now.Ticks}";
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
