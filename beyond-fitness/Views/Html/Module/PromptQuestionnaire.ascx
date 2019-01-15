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
        <div class="panel-body status smart-form vote no-padding">
            <div class="alert alert-warning">
                <i class="fa fa-info-circle">為了讓您的體能顧問做出更優化的階段性調整，下方提供
                                &lt;六個小問題&gt;
                    請您回答補充，資料僅提供訓練使用，不會外洩，敬請放心填寫！
                </i>
            </div>
            <form action="<%= Url.Action("CommitQuestionnaire","Interactivity",new { id = _model.QuestionnaireID }) %>" method="post" class="smart-form">
                <fieldset>
                    <%  Html.RenderPartial("~/Views/Html/Module/Questionnaire.ascx", _model); %>
                </fieldset>
                <footer>
                    <button type="button" name="btnSend" class="btn btn-primary">
                        填寫完成並送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                    </button>
                    <button type="button" name="btnCancel" class="btn bg-color-blueDark">
                        <%= (bool?)ViewBag.ByCoach==true ? "我超強不用了解學生" : "不方便作答"  %>
                    </button>
                </footer>
                <div class="message">
                    <i class="fa fa-check fa-lg"></i>
                    <p>
                        Your comment was successfully added!
                    </p>
                </div>
                <div class="errormessage">
                    <i class="fa fa-times fa-lg"></i>
                    <p class="text-center"></p>
                </div>
            </form>
        </div>
    </div>
    <script>

        //debugger;
        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-volume-up'></i>  階段性調整計劃</h4>",
            close: function (event, ui) {
                $('#<%= _dialogID %>').remove();
            }
        });

        $('#<%= _dialogID %> button[name="btnSend"]').on('click', function (evt) {

            var $form = $('#<%= _dialogID %> form');
            if (!validateForm($form[0]))
                return false;

            $('#<%= _dialogID %> button').prop('disabled', true);
            $('#<%= _dialogID %> .errormessage').css('display', 'none');

            showLoading();
            $form.ajaxSubmit({
                success: function (data) {
                    hideLoading();
                    if (data.result) {
                        $('#<%= _dialogID %> footer').remove();
                        $('#<%= _dialogID %> .message').css('display', 'block');
                        if (data.result && !data.message) {
                            if ($global.removeQuestionnairePrompt) {
                                $global.removeQuestionnairePrompt();
                            }
                        } else {
                            $('#<%= _dialogID %> button').prop('disabled', false);
                        }
                    } else {
                        $('#<%= _dialogID %> .errormessage').css('display', 'block')
                            .find('p').text(data.message);
                        $('#<%= _dialogID %> button').prop('disabled', false);
                    }
                }
            });
        });

        $('#<%= _dialogID %> button[name="btnCancel"]').on('click', function (evt) {
            $('#<%= _dialogID %> button').prop('disabled', true);
            showLoading();
            $.post('<%= Url.Action("RejectQuestionnaire","Interactivity",new { id = _model.QuestionnaireID, status = _profile.UID!=_model.UID ? (int)Naming.IncommingMessageStatus.教練代答 : (int)Naming.IncommingMessageStatus.拒答 }) %>', {}, function (data) {
                hideLoading();
                if (data.result && !data.message) {
                    if ($global.removeQuestionnairePrompt) {
                        $global.removeQuestionnairePrompt();
                    }
                }
                $('#<%= _dialogID %>').dialog('close');
            });
        });

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    QuestionnaireRequest _model;
    String _dialogID = "questionnaireDialog" + DateTime.Now.Ticks;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (QuestionnaireRequest)this.Model;
        _profile = Context.GetUser();
    }

</script>
