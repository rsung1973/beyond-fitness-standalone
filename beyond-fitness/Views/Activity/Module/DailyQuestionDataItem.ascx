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

<tr>
    <td><%= _model.Question %></td>
    <td>
        <%  var items = _model.PDQSuggestion.ToList();
            var rightAns = items.Where(a => a.RightAnswer == true).FirstOrDefault();
            if (rightAns != null)
            {  %>
        <%= (char)(items.IndexOf(rightAns)+'A') %> <%= rightAns.Suggestion %>
        <%  } %>
    </td>
    <td nowrap="noWrap"><%= _model.UserProfile.FullName() %></td>
    <td nowrap="noWrap"><%= _model.PDQQuestionExtension.Status==(int)Naming.GeneralStatus.Failed ? "已停用": "已生效" %></td>
    <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", _model.PDQQuestionExtension.CreationTime) %></td>
    <td nowrap="noWrap">
        <a onclick="editDailyQuestion(<%= _model.QuestionID %>);" class="btn btn-circle bg-color-yellow modifyQuestionDialog_link"><i class="fa fa-fw fa fa-lg fa-edit" aria-hidden="true"></i></a>&nbsp;&nbsp; 
    <%  if (_model.PDQQuestionExtension.Status.HasValue)
        { %>
        <a onclick="enableItem('<%= _model.QuestionID.EncryptKey() %>');" class="btn btn-circle bg-color-red"><i class="far fa-fw fa-lg fa-check-square" aria-hidden="true"></i> </a>&nbsp;&nbsp;
        <%  }
            else
            {
                if (!_model.PDQTask.Any())
                {%>
        <a onclick="deleteItem('<%= _model.QuestionID.EncryptKey() %>');" class="btn btn-circle bg-color-red delete"><i class="fa fa-fw fa fa-lg fa-trash-alt" aria-hidden="true"></i></a>&nbsp;&nbsp;
            <%  }
                else
                { %>
        <a onclick="disableItem('<%= _model.QuestionID.EncryptKey() %>');" class="btn btn-circle bg-color-red delete"><i class="fa fa-fw fa fa-lg fa-trash-alt" aria-hidden="true"></i></a>&nbsp;&nbsp;
            <%  } %>
        <%  } %>
    </td>
</tr>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PDQQuestion _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (PDQQuestion)this.Model;
    }

</script>
