<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>


<article class="col-xs-12 col-sm-12 col-md-9 col-lg-9">
    <div class="well well-sm bg-color-darken txt-color-white">
        <div class="row">

<%--            <%  Html.RenderPartial("~/Views/Layout/Carousel.ascx"); %>--%>

            <div class="col-sm-12">

                <div class="row">

                    <%  Html.RenderPartial("~/Views/Member/LessonCount.ascx", _model); %>
                    <%  Html.RenderPartial("~/Views/Member/LearnerInfo.ascx", _model); %>
                </div>
            </div>
        </div>
        <div class="row">
            <hr />
        </div>
        <div class="row no-padding">
            <div class="col-sm-12">
                <ul class="nav nav-tabs tabs-pull-right">
                    <%  if(ViewBag.ShowOnly!=true)
                        { %>
                            <button type="button" class="btn btn-labeled btn-success bg-color-blueLight" onclick="registerLessons();">
                                <span class="btn-label">
                                    <i class="fa fa-calendar-alt-plus-o"></i>
                                </span>新增課堂數
                            </button>
                    <%  }
                        if (ViewBag.ShowPDQ != false)
                        { %>
                    <li>
                        <a data-toggle="tab" href="#s3"><i class="fa fa-heart"></i><span> 體能檢測</span></a>
                    </li>
                    <li>
                        <a data-toggle="tab" href="#s4"><i class="fa fa-volume-up"></i><span> 階段性調整計劃</span></a>
                    </li>
                    <li>
                        <a data-toggle="tab" href="#s2"><i class="fa fa-street-view"></i><span> PAQ&PDQ</span></a>
                    </li>
                    <%  } %>
                    <li class="active">
                        <a data-toggle="tab" href="#s1"><i class="fa fa-credit-card"></i><span> 購買上課記錄</span></a>
                    </li>
                </ul>
                <div class="tab-content padding-top-10">
                    <div class="tab-pane fade in active" id="s1">
                        <div class="row ">
                            <div class="col-xs-12 col-sm-12">
                                <% Html.RenderPartial("~/Views/Member/LessonsList.ascx", _items); %>
                            </div>
                        </div>
                    </div>
                    <%  if (ViewBag.ShowPDQ != false)
                        { %>
                    <div class="tab-pane fade in" id="s2">
                        <div class="row">
                            <%  Html.RenderPartial("~/Views/Member/PDQInfoByLearner.ascx", _model); %>
                        </div>
                    </div>
                    <div class="tab-pane fade in" id="s3">
                        <div class="row ">
                            <div class="col-xs-12 col-sm-12">
                                <%  Html.RenderAction("FitnessAssessmentList", "Activity", new { uid = _model.UID }); %>
                            </div>
                        </div>
                    </div>
                    <div class="tab-pane fade in" id="s4">
                        <div class="row ">
                            <div class="col-xs-12 col-sm-12">
                                <%  var questItems = models.GetTable<QuestionnaireRequest>().Where(q => q.PDQTask.Count > 0 && q.UID == _model.UID);
                                    Html.RenderPartial("~/Views/Interactivity/Questionnaire/LearnerQuestionnaireList.ascx", questItems); %>
                            </div>
                        </div>
                    </div>
                    <%  } %>
                </div>
            </div>
        </div>

        <%  if (ViewBag.ShowOnly != true)
            {
                if (_modelState!=null && !_modelState.IsValid)
                { %>
                    <div class="modal fade" id="registerLesson" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                        <% Html.RenderPartial("~/Views/Member/RegisterLessonForm.ascx", _viewModel); %>
                    </div>
                    <script>
                            $(function () {
                                $('#registerLesson').modal('toggle');
                            });
                    </script>
        <%      }
            } %>
    </div>

</article>

<script>
    $(function () {
        $('.carousel.slide').carousel({
            interval: 3000,
            cycle: true
        });
        $('.carousel.fade').carousel({
            interval: 3000,
            cycle: true
        });

        $('#registerLesson').on('shown.bs.modal', function (evt) {
            $(this).find('select').first().focus();
        });
    });

    function registerLessons(registerID) {
        $('#registerLesson').remove();
        var $modal = $('<div class="modal fade" id="registerLesson" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" />');
        $('#loading').css('display', 'table');
        $modal.appendTo($('#content'))
            .load('<%= VirtualPathUtility.ToAbsolute("~/Member/RegisterLessonForm") %>', { 'registerID': registerID }, function () {
                $('#loading').css('display', 'none');
                $modal.on('hidden.bs.modal', function (evt) {
                    $('body').scrollTop(screen.height);
                });
                $modal.modal('show');
            });
    }
</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    LessonViewModel _viewModel;

    IQueryable<RegisterLesson> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _viewModel = (LessonViewModel)ViewBag.ViewModel;

        _items = models.GetTable<RegisterLesson>()
            .Where(r=>r.ClassLevel.HasValue && r.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
            .Where(r => r.UID == _model.UID)
            .OrderByDescending(r => r.RegisterID);
    }


</script>
