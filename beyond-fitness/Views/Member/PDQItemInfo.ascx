<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<li><strong><%= _model.Question %></strong>
    <ul class="list-unstyled">
        <%  if (_task != null)
            {
                switch ((Naming.QuestionType)_model.QuestionType)
                {
                    case Naming.QuestionType.問答題:
                        if(!String.IsNullOrEmpty(_task.PDQAnswer))
                        { %>
                            <li class="text-warning"><i class="fa fa-commenting-o"></i><strong><%= _task.PDQAnswer %></strong></li>
                <%      }
                        break;
                    case Naming.QuestionType.單選題:
                    case Naming.QuestionType.單選其他:
                        if(_task.SuggestionID.HasValue)
                        {   %>
                            <li class="text-success"><i class="fa fa-check"></i><strong><%= _task.PDQSuggestion.Suggestion %></strong></li>
                        <%  if(!String.IsNullOrEmpty(_task.PDQAnswer))
                            { %>
                                <li class="text-warning"><i class="fa fa-commenting-o"></i><strong><%= _task.PDQAnswer %></strong></li>
                    <%      }
                        }
                        if (_answer != null)
                        {         %>
                            <li class="text-warning"><i class="fa fa-commenting-o"></i><strong><%= _answer.PDQAnswer %></strong></li>
        <%              } 
                        break;
                    case Naming.QuestionType.多重選:
                        break;
                    case Naming.QuestionType.是非題:
                        if (_task.YesOrNo == true)
                        {  %>
                            <li class="text-danger"><i class="fa fa-check"></i><strong>是</strong></li>
                    <%  }
                        else
                        { %>
                            <li class="text-success"><i class="fa fa-times"></i><strong>否</strong></li>
                    <%  } 
                        break;
                }
            }
            else
            {
                Writer.Write("N/A");
            } %>
    </ul>
</li>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PDQQuestion _model;
    PDQTask _task;
    PDQTask _answer;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (PDQQuestion)this.Model;
        _task = (PDQTask)ViewBag.PDQTask;
        _answer = (PDQTask)ViewBag.Answer;
    }

</script>
