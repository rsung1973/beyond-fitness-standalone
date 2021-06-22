<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="編輯題目資料" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitDailyQuestion","Activity",new { _viewModel.QuestionID }) %>" class="smart-form" method="post" autofocus>
            <fieldset>
                <section class="col col-6">
                    <label class="label">出題者</label>
                    <label class="select">
                        <select name="AskerID" class="input">
                            <option value="">請選擇體能顧問</option>
                            <%  Html.RenderPartial("~/Views/SystemInfo/ServingCoachOptions.cshtml", models.GetTable<ServingCoach>()); %>
                        </select>
                        <i class="icon-append far fa-keyboard"></i>
                    </label>
                    <%  if (_viewModel.AskerID.HasValue)
                        {%>
                    <script>
                        $('#<%= _dialog %> select[name="AskerID"]').val('<%= _viewModel.AskerID %>');
                    </script>
                    <%  } %>
                </section>
                <section class="col col-6">
                    <label class="label">問題</label>
                    <textarea name="Question" class="form-control" placeholder="最多100個字(不斷行)" rows="3"><%= _viewModel.Question %></textarea>
                </section>
            </fieldset>
            <fieldset>
                <div class="row">
                    <section class="col col-6">
                        <label class="radio">
                            <input type="radio" name="RightAnswerIndex"  value="0" <%= _viewModel.RightAnswerIndex==0 ? "checked" : null %> />
                            <i></i>A</label>
                        <label class="input">
                            <i class="icon-append fa fa-question-circle-o"></i>
                            <textarea class="form-control" name="Suggestion" placeholder="最多僅能輸入60個中英文字(不斷行)" rows="3"><%= _viewModel.Suggestion!=null && _viewModel.Suggestion.Length>0 ? _viewModel.Suggestion[0] : null %></textarea>
                        </label>
                    </section>
                    <section class="col col-6">
                        <label class="radio">
                            <input type="radio" name="RightAnswerIndex" value="1" <%= _viewModel.RightAnswerIndex==1 ? "checked" : null %> />
                            <i></i>B</label>
                        <label class="input">
                            <i class="icon-append fa fa-question-circle-o"></i>
                            <textarea class="form-control" name="Suggestion" placeholder="最多僅能輸入60個中英文字(不斷行)" rows="3"><%= _viewModel.Suggestion!=null && _viewModel.Suggestion.Length>1 ? _viewModel.Suggestion[1] : null %></textarea>
                        </label>
                    </section>
                    <section class="col col-6">
                        <label class="radio">
                            <input type="radio" name="RightAnswerIndex" value="2" <%= _viewModel.RightAnswerIndex==2 ? "checked" : null %> />
                            <i></i>C</label>
                        <label class="input">
                            <i class="icon-append fa fa-question-circle-o"></i>
                            <textarea class="form-control" name="Suggestion" placeholder="最多僅能輸入60個中英文字(不斷行)" rows="3"><%= _viewModel.Suggestion!=null && _viewModel.Suggestion.Length>2 ? _viewModel.Suggestion[2] : null %></textarea>
                        </label>
                    </section>
                    <section class="col col-6">
                        <label class="radio">
                            <input type="radio" name="RightAnswerIndex" value="3" <%= _viewModel.RightAnswerIndex==3 ? "checked" : null %> />
                            <i></i>D</label>
                        <label class="input">
                            <i class="icon-append fa fa-question-circle-o"></i>
                            <textarea class="form-control" name="Suggestion" placeholder="最多僅能輸入60個中英文字(不斷行)" rows="3"><%= _viewModel.Suggestion!=null && _viewModel.Suggestion.Length>3 ? _viewModel.Suggestion[3] : null %></textarea>
                        </label>
                    </section>
                </div>
            </fieldset>
        </form>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 編輯問題</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {
                    var $form = $('#<%= _dialog %> form');
                    clearErrors();
                    $form.ajaxSubmit({
                        beforeSubmit: function () {
                            showLoading();
                        },
                        success: function (data) {
                            hideLoading();
                            if ($.isPlainObject(data)) {
                                if (data.result) {
                                    alert('資料已更新!!');
                                    $('#<%= _dialog %>').dialog('close');
                                    inquireDailyQuestion(data.QuestionID);
                                } else {
                                    alert(data.message);
                                }
                            } else {
                                $(data).appendTo($('body')).remove();
                            }
                        }
                    });
                }
            }],
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });
    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PDQQuestionViewModel _viewModel;
    String _dialog = "modifyEventDialog" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (PDQQuestionViewModel)ViewBag.ViewModel;
    }

</script>
