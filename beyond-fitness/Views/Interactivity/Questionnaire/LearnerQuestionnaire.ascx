<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="modal fade" id="learnerQuestionnaire" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    &times;
                </button>
                <h4 class="modal-title" id="myModalLabel"><i class="fa-fw fa fa-volume-up"></i> 滿意度問卷</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="panel panel-default bg-color-darken">
                    <form id="questionnaireForm" method="post" class="smart-form">
                        <div class="panel-body status vote">
                            <div class="who clearfix">
                                <%  _model.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg busy", @style = "width:40px" }); %>
                                <span class="name font-lg"><b><%= _model.UserProfile.FullName() %></b></span><br />
                                <span class="from font-md">已於 <%= String.Format("{0:yyyy/MM/dd}",_model.PDQTask.First().TaskDate) %> 回填上課滿意度問卷！</span>
                            </div>
                            <%  foreach (var item in _model.PDQTask.OrderBy(t=>t.PDQQuestion.QuestionNo))
                                { %>
                                    <div class="image font-md">
                                        <span class="text-warning"><%--<i class="fa-fw fa fa-quora"></i>--%><%= item.PDQQuestion.QuestionNo %>. <%= item.PDQQuestion.Question %></span><br />
                                        <i class="fa-fw fa fa-hand-o-right"></i>&nbsp;&nbsp;&nbsp;<%= getAnswer(item) %>
                                    </div>
                            <%  } %>
                        </div>
                    </form>
                </div>
                <!-- /.modal-content -->
            </div>
        </div>
        <!-- /.modal-content -->
    </div>
    <!-- /.modal-dialog -->
    <script>

        $(function () {

            var $modal = $('#learnerQuestionnaire');
            $modal.on('hidden.bs.modal', function (evt) {
                $modal.remove();
            });

<%--        $modal.on('shown.bs.modal', function () {
            $(this).find('.modal-dialog').css({
                width: '100%',
                height: '100%',
                'max-height': '100%'
            });

        });--%>

            $modal.modal('show');
        });
    </script>

</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    QuestionnaireRequest _model;
    UserProfile _profile;


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
