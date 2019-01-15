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

<%
    var answers = _model.PDQTask.Where(t => t.PDQQuestion.GroupID == 6);
    var answerCount = answers.Count();
    var rightAns = answers.Where(t => t.SuggestionID.HasValue && t.PDQSuggestion.RightAnswer == true);
%>
<div class="points-block">
    <h3>運動小學堂</h3>
    <div class="parallax-container parallax-min" onclick="javascript:gtag('event', '運動小學堂', {  'event_category': '卡片點擊',  'event_label': '卡片總覽'});window.location.assign('<%= Url.Action("AnswerDailyQuestion","CornerKick") %>');">
        <div class="section no-pad-bot">
            <div class="container">
                <div class="points-text-area">
                    <h5>目前已參加運動小學堂<span class="f-green"> <%= answerCount %> </span>次囉！</h5>
                    <%  if (answerCount > 0)
                        {
                            var accuracy = rightAns.Count() * 100 / answerCount;
                            if (accuracy > 80)
                            {  %>
                    <p class="white-text">答題正確率已達 <span class="f-green"><%= accuracy %>%</span>，博士等級，非常厲害！維持下去喔！</p>
                    <%        }
                        else if (accuracy > 60)
                        { %>
                    <p class="white-text">答題正確率已達 <span class="f-green"><%= accuracy %>%</span>，大學等級，離成功不遠囉！</p>
                    <%    }
                        else if (accuracy > 40)
                        { %>
                    <p class="white-text">答題正確率已達 <span class="f-green"><%= accuracy %>%</span>，國高中等級，越來越上手喔！</p>
                    <%    }
                        else if (accuracy > 20)
                        { %>
                    <p class="white-text">答題正確率已達 <span class="f-green"><%= accuracy %>%</span>，國小等級，越來越進步囉！</p>
                    <%    }
                        else
                        { %>
                    <p class="white-text">答題正確率已達 <span class="f-green"><%= accuracy %>%</span>，就讀運動幼幼班，再接再厲！</p>
                    <%  }
                        }
                        else
                        {   %>
                    <p class="white-text">答題正確率已達 <span class="f-green">0%</span>，就讀運動幼幼班，再接再厲！</p>
                    <%  } %>
                </div>
            </div>
        </div>
        <div class="parallax bgcolor"></div>
    </div>
</div>


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
