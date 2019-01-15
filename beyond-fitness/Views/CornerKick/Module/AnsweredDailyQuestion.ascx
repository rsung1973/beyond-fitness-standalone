<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<div class="accordion__item js-accordion-item">
    <div class="accordion-header js-accordion-header">
        <ul class="lesson-box">
            <li class="qa-item"><%= _question.Question %>（
                <%  if (_model.PDQSuggestion.RightAnswer == true)
                    { %>
                <span class="bingo">答對</span>
                <%  }
                    else
                    { %>
                <span class="wrong">答錯</span>
                <%  } %>）</li>
        </ul>
    </div>
    <div class="accordion-body js-accordion-body">
        <div class="accordion-body__contents">
            <form action="#">
                <%  foreach (var quest in _question.PDQSuggestion)
                    { %>
                <p>
                    <input class="with-gap" name="suggestionID" type="radio" id="test<%= quest.SuggestionID %>" disabled="disabled" <%= quest.SuggestionID==_model.SuggestionID ? "checked" : null %> />
                    <label for="test<%= quest.SuggestionID %>"><%= quest.Suggestion %></label>
                    <%  if (quest.SuggestionID == _model.SuggestionID && quest.RightAnswer!=true)
                        { %>
                    （<span class="wrong">失誤了！😱</span>）
                    <%  } %>
                </p>
                <%  } %>
            </form>
        </div>
    </div>
    <!-- end of accordion body -->
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PDQTask _model;
    PDQQuestion _question;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (PDQTask)this.Model;
        _question = _model.PDQQuestion;
    }

</script>
