<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<tr class="warning">
    <td>
        <span class="fa fa-commenting"><%= _model.Question %>：        
            <%  
                if (_task != null)
                {
                    switch ((Naming.QuestionType)_model.QuestionType)
                    {
                        case Naming.QuestionType.問答題:
                            Writer.Write(_task.PDQAnswer);
                            break;
                        case Naming.QuestionType.單選題:
                        case Naming.QuestionType.單選其他:
                            Writer.Write(_task.SuggestionID.HasValue ? _task.PDQSuggestion.Suggestion : _task.PDQAnswer);
                            break;
                        case Naming.QuestionType.多重選:
                            break;
                        case Naming.QuestionType.是非題:
                            Writer.Write(_task.YesOrNo == true ? "是" : "否");
                            break;
                    }
                }
                else
                {
                    Writer.Write("N/A");
                } %></span>
    </td>
</tr>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PDQQuestion _model;
    PDQTask _task;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (PDQQuestion)this.Model;
        _task = (PDQTask)ViewBag.PDQTask;
    }

</script>
