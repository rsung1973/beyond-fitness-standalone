<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialogID %>" title="每日小提問" class="bg-color-darken">
    <form action="<%= Url.Action("AnswerDailyQuestion","Activity",new { _model.QuestionID }) %>" method="post" class="smart-form">
        <div class="panel-body status smart-form vote">
            <div class="who clearfix">
                <% _model.UserProfile.RenderUserPicture(Writer, new { @class = "busy" }); %>
                <span class="name font-lg"><b><%= _model.UserProfile.UserName ?? _model.UserProfile.FullName() %></b></span>
                <span class="from font-md"><b>Hi, <%= _userProfile.UserName ?? _userProfile.FullName() %></b> 請試試回答以下問的答案，答對會有意想不到的驚喜喔！</span>
            </div>
            <div class="image font-md">
                <strong><%= _model.Question %></strong>
            </div>
            <ul class="comments">
                <%  foreach (var quest in _model.PDQSuggestion)
                    { %>
                <li>
                    <label class="radio font-md">
                        <input type="radio" name="suggestionID" value="<%= quest.SuggestionID %>" />
                        <i></i><%= quest.Suggestion %></label>
                </li>
                <%  } %>
            </ul>
            <footer>
                <button type="button" class="btn btn-primary">
                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                </button>
                <button type="button" class="btn btn-default" data-dismiss="modal">
                    取消
                </button>
            </footer>

            <div class="message">
                <i class="fa fa-check fa-lg"></i>
                <p class="text-center">
                </p>
            </div>
            <div class="errormessage">
                <i class="fa fa-times fa-lg"></i>
                <p class="text-center">
                    非常可惜答錯囉！試著再次請教<%= _lesson.ServingCoach.UserProfile.FullName() %>正確答案吧！
                </p>
            </div>
        </div>
    </form>

    <script>

        $(function () {
            $('#<%= _dialogID %>').dialog({
                //autoOpen: false,
                resizable: true,
                modal: true,
                width: "auto",
                height: "auto",
                title: "<h4 class='modal-title'><i class='fa fa-fw fa-calendar'></i>  每日小提問</h4>",
                close: function () {
                    $('#<%= _dialogID %>').remove();
                }
            });

            $btnAnswer = $('#<%= _dialogID %> button.btn-primary');
            $dailyAns = $('#<%= _dialogID %> form');

            $btnAnswer.on('click', function (evt) {
                $dailyAns.ajaxForm({
                    beforeSubmit: function () {
                        showLoading(true);
                    },
                    success: function (data) {
                        hideLoading();
                        $dailyAns.find('footer').remove();
                        if (data.result) {
                            $dailyAns.find('.message').css('display', 'block')
                            .find('p').text('恭喜你答對囉，可獲得點數' + data.message + '點，集滿一定點數後有意想不到的驚喜喔！');
                        } else {
                            //$modal.modal('hide');
                            $dailyAns.find('.errormessage').css('display', 'block');
                        }
                        $('.modal-body').scrollTop(300);
                    },
                    error: function () {
                    }
                }).submit();
            });

        });

    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PDQQuestion _model;
    UserProfile _userProfile;
    RegisterLesson _lesson;
    String _dialogID = "learnerQuest" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (PDQQuestion)this.Model;
        _userProfile = Context.GetUser();
        _lesson = models.GetTable<RegisterLesson>().Where(r => r.UID == _userProfile.UID)
            .OrderByDescending(r => r.RegisterID).FirstOrDefault();
    }

</script>
