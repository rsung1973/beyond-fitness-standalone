<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>


<div class="modal-dialog">
    <div class="modal-content">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                &times;
            </button>
            <h4 class="modal-title" id="myModalLabel">複製課表</h4>
        </div>
        <div class="modal-body bg-color-darken txt-color-white">
            <form action="<%= VirtualPathUtility.ToAbsolute("~/Lessons/CloneTrainingPlan") %>" method="post" class="smart-form">
                <input type="hidden" name="lessonID" value="<%= _viewModel.LessonID %>" />
                <input type="hidden" name="registerID" value="<%= _timeModel.RegisterID %>" />
                <input type="hidden" name="hour" value="<%= _timeModel.Hour %>" />
                <input type="hidden" name="classDate" value="<%= _timeModel.ClassDate %>" />
                <fieldset>
                    <div class="row">
                        <section class="col col-5">
                            <label class="select">
                                <%  var inputItem = new InputViewModel { Id = "coachID", Name = "coachID", DefaultValue = _viewModel.CoachID };
                                    ViewBag.Inline = true;
                                    ViewBag.SelectAll = true;
                                    Html.RenderPartial("~/Views/Lessons/SimpleCoachSelector.ascx", inputItem); %>
                                <i class="icon-append far fa-keyboard"></i>
                            </label>
                        </section>
                        <section class="col col-5">
                            <label class="input">
                                <i class="icon-append fa fa-search"></i>
                                <input type="text" name="userName" maxlength="20" placeholder="請輸入學員姓名" value="<%= _viewModel.UserName %>" />
                            </label>
                        </section>
                        <section class="col col-2">
                            <button type="button" onclick="queryLessonTime();" class="btn bg-color-blue btn-sm" type="button">查詢</button>
                        </section>
                    </div>
                </fieldset>
                <%--<fieldset>
                    <div class="row">
                        <section class="col col-6">
                            <label class="select">
                                <select name="trainingBySelf">
                                    <option value="">查詢全部課程</option>
                                    <option value="1">自主訓練</option>
                                    <option value="0">一般課程</option>
                                </select>
                                <i class="icon-append far fa-keyboard"></i>
                                <%  if (_viewModel.TrainingBySelf.HasValue)
                                    { %>
                                        <script>
                                            $('select[name="trainingBySelf"]').val(<%= _viewModel.TrainingBySelf %>);
                                        </script>
                                <%  } %>
                            </label>
                        </section>
                        <section class="col col-6">
                            
                        </section>
                    </div>
                </fieldset>--%>
                <fieldset id="queryResult">
                    <% Html.RenderAction("QueryLessonTimeList", _viewModel); %>
                </fieldset>

                <footer>
                    <button type="button" onclick="commitCloneLesson();" name="submit" class="btn btn-primary">
                        確定複製 <i class="fa fa-files-o" aria-hidden="true"></i>
                    </button>
                    <button type="button" class="btn btn-default" data-dismiss="modal">
                        取消
                    </button>
                </footer>
            </form>
        </div>
    </div>
    <!-- /.modal-content -->
</div>

<script>
    function queryLessonTime() {
        $('#queryResult').load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/QueryLessonTimeList") %>',
            {
                'coachID': $('select[name="coachID"]').val(),
                'userName': $('input[name="userName"]').val(),
                'trainingBySelf': $('select[name="trainingBySelf"]').val(),
            }, function () {
            });
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    DailyBookingQueryViewModel _viewModel;
    LessonTimeExpansionViewModel _timeModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (DailyBookingQueryViewModel)ViewBag.ViewModel;
        _timeModel = (LessonTimeExpansionViewModel)ViewBag.LessonTimeExpansion;
    }

</script>
