<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_model.PDQSuggestion.Count > 5)
    {   %>
        <label class="select">
            <select class="input-lg" name='<%= "_" + _model.QuestionID %>'>
            <%  foreach (var item in _model.PDQSuggestion)
                { %>
                    <option value="<%= item.SuggestionID %>"><%= item.Suggestion %></option>
            <%  } %>
            </select><i></i>
        </label>
<%      if (_item != null && _item.SuggestionID.HasValue)
        {   %>
            <script>
                $('select[name="<%= "_" + _model.QuestionID %>"]').val(<%= _item.SuggestionID %>);
            </script>
<%      }
    }
    else
    {   %>
        <div class="<%= ViewBag.InlineGroup!=false ? "inline-group" : null %>">
<%      foreach (var item in _model.PDQSuggestion)
        { %>
            <label class="radio font-md">
            <input type="radio" name='<%= "_" + _model.QuestionID %>' value="<%= item.SuggestionID %>"><%= item.Suggestion %>
                <i></i>
            </label>
<%      }   %>
        </div>
<%      if(_item!=null && _item.SuggestionID.HasValue)
        {   %>
            <script>
                $('input[name="<%= "_" + _model.QuestionID %>"][value="<%= _item.SuggestionID %>"]').prop('checked',true);
            </script>
<%      }
    }
    if (_model.QuestionType == (int)Naming.QuestionType.單選其他)
    {%>
        <label class="input font-md">
            <i class="icon-append fa fa-comment-o"></i>
            <input type="text" name='<%= "_" + _model.QuestionID %>' class="input-lg" placeholder="最多僅輸入50個中英文字" maxlength="50" value="<%= _answer!=null ? _answer.PDQAnswer : null %>" />
        </label>
<%  } %>

<script runat="server">

ModelStateDictionary _modelState;
ModelSource<UserProfile> models;
PDQQuestion _model;
PDQTask _item;
PDQTask _answer;

protected override void OnInit(EventArgs e)
{
    base.OnInit(e);
    _modelState = (ModelStateDictionary)ViewBag.ModelState;
    models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    _model = (PDQQuestion)this.Model;
    _item = (PDQTask)ViewBag.PDQTask;
    _answer = (PDQTask)ViewBag.Answer;

}

</script>
