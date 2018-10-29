<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialogID %>" title="階段性調整計劃" class="bg-color-darken">
    <div class="panel panel-default bg-color-darken">
        <div class="panel-body status smart-form vote">
            <div class="who clearfix">
                <%  _model.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg busy", @style = "width:40px" }); %>
                <span class="name font-lg"><b><%= _model.UserProfile.FullName() %></b></span><br />
                <span class="from font-md">已於 <%= String.Format("{0:yyyy/MM/dd}",_model.PDQTask.First().TaskDate) %> 回填階段性調整計劃！</span>
            </div>
            <%  foreach (var item in _model.PDQTask.OrderBy(t=>t.PDQQuestion.QuestionNo))
                                { %>
            <div class="image font-md">
                <span class="text-warning"><i class="fa-fw fa fa-quora"></i><%= item.PDQQuestion.QuestionNo %>. <%= item.PDQQuestion.Question %></span><br />
                <i class="fa-fw fa fa-hand-o-right"></i>&nbsp;&nbsp;&nbsp;<%= getAnswer(item) %>
            </div>
            <%  } %>
        </div>
    </div>
    <script>
        $('#<%= _dialogID %>').dialog({
            width: "auto",
            height: "auto",
            resizable: true,
            modal: true,
            closeText: "關閉",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-volume-up'></i>  階段性調整計劃</h4>",
            close: function (evt, ui) {
                $('#<%= _dialogID %>').remove();
            }
        });
    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    QuestionnaireRequest _model;
    UserProfile _profile;
    String _dialogID = "questionnaireDialog" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (QuestionnaireRequest)this.Model;

        _profile = Context.GetUser();
        if (!_profile.IsSysAdmin())
        {
            _model.Status = (int)Naming.IncommingMessageStatus.已讀;
            models.SubmitChanges();
        }

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
