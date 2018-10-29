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

<table class="table table-striped table-bordered table-hover" width="100%">
    <thead>
        <tr>
            <th>合約項目</th>
            <th class="text-center">草稿</th>
            <%--<th class="text-center">待確認</th>--%>
            <th class="text-center">待客戶簽名</th>
            <th class="text-center">待審核</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td nowrap="noWrap"><%  var items = models.GetApplyingContractByAgent(_model);
                    var editingItems = models.GetContractInEditingByAgent(_model);
                    var toConfirmItems = models.GetContractToConfirmByAgent(_model);
                    var toSignItems = models.GetContractToSignByAgent(_model);
                    //var toAllowItems = models.GetContractToAllowByAgent(_model);
                %>
                新合約(<%= editingItems.Count() + toSignItems.Count() + toConfirmItems.Count() %>)</td>
            <td nowrap="noWrap" class="text-center">
                <%  
                    if (editingItems.Count() > 0)
                    {   %>
                <a onclick="showContractTodoList(<%= (int)Naming.CourseContractStatus.草稿 %>);" ><u>(<%= editingItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                    --
                <%  } %>
            </td>
            <%--<td class="text-center">
                <%  
                    if (toAllowItems.Count() > 0)
                    {   %>
                <a onclick="showContractTodoList(<%= (int)Naming.CourseContractStatus.待確認 %>);"><u>(<%= toAllowItems.Count() %>)</u></a>
            <%      }
                    else
                    { %>
                    --
                <%  } %>
            </td>--%>
            <td nowrap="noWrap" class="text-center">
                <%  
                    if (toSignItems.Count() > 0)
                    {   %>
                <a onclick="showContractTodoList(<%= (int)Naming.CourseContractStatus.待簽名 %>);" ><u>(<%= toSignItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                    --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-center">
                <%  
                    if (toConfirmItems.Count() > 0)
                    {   %>
                <a onclick="showContractTodoList(<%= (int)Naming.CourseContractStatus.待審核 %>);" ><u>(<%= toConfirmItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                    --
                <%  } %>
            </td>
        </tr>
        <tr>
            <td nowrap="noWrap">
                <%  var revisions = models.GetApplyingAmendmentByAgent(_model);
                    var toConfirmRevisions = models.GetAmendmentToAllowByAgent(_model);
                    var toSignRevisions = models.GetAmendmentToSignByAgent(_model);
                     %>
                服務申請(<%= toSignRevisions.Count() + toConfirmRevisions.Count() %>)</td>
            <td nowrap="noWrap" class="text-center">--</td>
            <%--<td class="text-center">
                <%  revisions = models.GetAmendmentToAllowByAgent(_model);
                    if (revisions.Count() > 0)
                    {   %>
                <a onclick="showAmendmentTodoList(<%= (int)Naming.CourseContractStatus.待確認 %>);"><u>(<%= revisions.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                    --
                <%  } %>            
            </td>--%>
            <td nowrap="noWrap" class="text-center">
                <%  
                    if (toSignRevisions.Count() > 0)
                    {   %>
                <a onclick="showAmendmentTodoList(<%= (int)Naming.CourseContractStatus.待簽名 %>);"><u>(<%= toSignRevisions.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                    --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-center">
                <%  
                    if (toConfirmRevisions.Count() > 0)
                    {   %>
                <a onclick="showAmendmentTodoList(<%= (int)Naming.CourseContractStatus.待確認 %>);"><u>(<%= toConfirmRevisions.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                    --
                <%  } %>
            </td>
        </tr>
    </tbody>
</table>

<script>
    function showContractTodoList(status) {
        showLoading();
        $.post('<%= Url.Action("ContractTodoList","CourseContract",new { agentID = _model.UID }) %>', { 'status': status }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }

    function showAmendmentTodoList(status) {
        showLoading();
        $.post('<%= Url.Action("ContractAmendmentTodoList","CourseContract",new { agentID = _model.UID }) %>', { 'status': status }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }
</script>

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
