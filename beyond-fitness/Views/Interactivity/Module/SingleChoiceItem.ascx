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
            <select name='<%= "_" + _model.QuestionID %>'>
            <%  foreach (var item in _model.PDQSuggestion)
                { %>
                    <option value="<%= item.SuggestionID %>"><%= item.Suggestion %></option>
            <%  } %>
            </select><i></i>
        </label>
<%      PDQSuggestion defaultItem;
        if (_item != null && _item.SuggestionID.HasValue)
        {   %>
            <script>
                $('select[name="<%= "_" + _model.QuestionID %>"]').val(<%= _item.SuggestionID %>);
            </script>
<%      }
        else if((defaultItem=_model.PDQSuggestion.Where(q=>q.RightAnswer==true).FirstOrDefault())!=null)
        { %>
            <script>
                $('select[name="<%= "_" + _model.QuestionID %>"]').val(<%= defaultItem.SuggestionID %>);
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
        <label class="textarea">
            <i class="icon-append fa fa-comments"></i>
            <textarea rows="4" name="<%= "_" + _model.QuestionID %>" placeholder="請輸入100以內的中英文字" maxlength="100"><%= _answer!=null ? _answer.PDQAnswer : null %></textarea>
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
