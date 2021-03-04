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

<div class="qa-content">
    <div class="personal-info">
        <div class="row valign-wrapper">
            <div class="col s4 m2">
                <%     ViewBag.ImgClass = "circle responsive-img valign";
                    Html.RenderPartial("~/Views/CornerKick/Module/ProfileImage.cshtml", _model.UserProfile); %>
            </div>
            <div class="col s8 m10 text-box"><span class="black-t18"><%= _model.UserProfile.UserName ?? _model.UserProfile.FullName() %></span> <span class="black-t12">Hi，來點腦力激盪，答對我出的題目可以獲得Beyond💰喔！</span></div>
        </div>
    </div>
    <!-- 問題 -->
    <p class="collection"><span class="gray-t16" id="question"><%= _model.Question %></span></p>
    <form action="<%= Url.Action("CommitAnswerDailyQuestion","CornerKick",new { keyID = _model.QuestionID.EncryptKey() }) %>" method="post" id="ansForm">
        <%  foreach (var quest in _model.PDQSuggestion)
            { %>
        <p>
            <input class="with-gap" name="suggestionID" value="<%= quest.SuggestionID %>" type="radio" id="ans<%= quest.SuggestionID %>" />
            <label for="ans<%= quest.SuggestionID %>"><%= quest.Suggestion %></label>
        </p>
        <%   } %>
    </form>
    <!-- Button -->
    <div class="content-area">
        <button class="btn waves-effect waves-light btn-send" type="button" name="action" onclick="commitAnswer();">我超聰明</button>
    </div>
    <!--// End of button-->
</div>
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
