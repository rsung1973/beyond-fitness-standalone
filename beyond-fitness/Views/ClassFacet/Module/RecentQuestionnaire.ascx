<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_item != null)
    { %>
<div class="row">
    <div class="col-sm-12">
        <span class="font-md">最新一份階段性調整計劃已於 <%= String.Format("{0:yyyy/MM/dd}", _item.PDQTask.First().TaskDate) %> 回填！</span>
        <br />
        <span><a onclick="$global.editLearner(<%= _model.UID %>);"><u>更多階段性調整計劃 ...</u></a></span>
    </div>
    <%  foreach (var item in _item.PDQTask.OrderBy(t => t.PDQQuestion.QuestionNo))
        { %>
    <div class="col-xs-2 col-sm-1">
        <time datetime="" class="icon">
            <strong><%--<i class="fa-fw fa fa-quora"></i>--%></strong>
            <span><%= item.PDQQuestion.QuestionNo %></span>
        </time>
    </div>
    <div class="col-xs-10 col-sm-11">
        <h6 class="no-margin"><span class="text-warning"><%= item.PDQQuestion.Question %></span></h6>
        <p><i class="fa-fw fa fa-volume-up"></i><%= getAnswer(item) %></p>
    </div>
    <div class="col-sm-12">
        <hr>
    </div>
    <%  } %>
 </div>
<%  }
    else
    { %>
<div class="row">
    <div class="col-sm-12">
        尚未建立任何階段性調整計劃
        </div>
    </div>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    QuestionnaireRequest _item;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _item = _model.QuestionnaireRequest.Where(q => q.PDQTask.Any())
            .OrderByDescending(q => q.QuestionnaireID).FirstOrDefault();
    }

    String getAnswer(PDQTask task)
    {
        switch ((Naming.QuestionType)task.PDQQuestion.QuestionType)
        {
            case Naming.QuestionType.問答題:
                return task.PDQAnswer;
            case Naming.QuestionType.單選題:
                return task.SuggestionID.HasValue ? task.PDQSuggestion.Suggestion : null;
            case Naming.QuestionType.單選其他:
                return task.SuggestionID.HasValue ? task.PDQSuggestion.Suggestion + " " + task.PDQAnswer : task.PDQAnswer;
            case Naming.QuestionType.多重選:
                return null;
            case Naming.QuestionType.是非題:
                return task.YesOrNo == true ? "是" : "否";
            default:
                return null;
        }
    }


</script>
