<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<article class="col-xs-12 col-sm-12 col-md-9 col-lg-9">
    <div class="well well-sm bg-color-darken txt-color-white">
        <div class="row">

            <%--<%  Html.RenderPartial("~/Views/Layout/Carousel.ascx"); %>--%>

            <div class="col-sm-12">


                <div class="row">

                    <div class="col-sm-3 profile-pic">
                        <% _model.RenderUserPicture(Writer, "profileImg"); %>
                        <div class="padding-10">
                            <%--<i class="fa fa-birthday-cake"></i>&nbsp;&nbsp;<span class="txt-color-darken"> <%= _model.YearsOld() %>歲</span>--%>
                            <br />
                            <h4 class="font-md"><strong><% var totalLessons = _currentLessons.Sum(c => c.Lessons); %>
                                <%= totalLessons
                                        - _currentLessons.Sum(c=>c.AttendedLessons)
                                        - _currentLessons.Sum(c=>c.GroupingLesson.LessonTime.Count(/*l=>l.LessonAttendance!= null*/)) %> / 
                                <%= totalLessons %></strong>
                                <br/>
                                <small>剩餘/購買上課次數</small>
                                <br />
                                <strong>
                                    <%= _currentLessons.Sum(c=>c.GroupingLesson.LessonTime.Count(l=>l.LessonAttendance== null && l.ClassTime<DateTime.Today.AddDays(1))) %> / 
                                    <%= _currentLessons.Sum(c=>c.GroupingLesson.LessonTime.Count(l=> l.ClassTime>=DateTime.Today)) %></strong>
                                <br />
                                <small>未完成/已預約 上課數</small>
                                <br />
                            </h4>
                        </div>
                    </div>
                    <div class="col-sm-9">
                        <h1><span class="semi-bold"><%= _model.FullName() %></span>
                            <br>
                            <small></small></h1>

                        <ul class="list-unstyled">
                            <li>
                                <p class="text-muted">
                                    <i class="fa fa-phone"></i>&nbsp;&nbsp;(<span class="txt-color-darken">886) <%= _model.Phone %> </span>
                                </p>
                            </li>
                            <li>
                                <p class="text-muted">
                                    <i class="fa fa-envelope"></i>&nbsp;&nbsp;<a href="mailto:<%= _model.PID.Contains("@") ? _model.PID : null %>"><%= _model.PID.Contains("@") ? _model.PID : null %></a>
                                </p>
                            </li>
                            <li>
                                <p class="text-muted">
                                    <i class="fa fa-gift"></i>&nbsp;&nbsp;每日小提問答題已得<%= _model.BonusPoint(models) ?? 0 %>點
                                </p>
                            </li>
                        </ul>
                    </div>

                </div>
            </div>
        </div>

    </div>

    <div class="row no-pading">
        <div class="col-xs-12">
            <ul class="nav nav-tabs tabs-pull-right">
                <li class="active">
                    <a data-toggle="tab" href="#health01"><i class="fa fa-history"></i><span>身體健康指數</span></a>
                </li>
                <li>
            </ul>
            <div class="tab-content padding-top-10">
                <div class="tab-pane fade in active" id="health01">
                    <div class="row ">
                        <div class="col-xs-12 col-sm-12">
                            <%  Html.RenderAction("HealthIndex", "Activity", new { id = _model.UID }); %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
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

    });
</script>


<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    LessonViewModel _viewModel;

    IQueryable<RegisterLesson> _items;
    IQueryable<RegisterLesson> _currentLessons;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _viewModel = (LessonViewModel)ViewBag.ViewModel;

        _items = models.GetTable<RegisterLesson>()
            .Where(l => l.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
            .Where(r => r.UID == _model.UID)
            .OrderByDescending(r => r.RegisterID);
        _currentLessons = _items.Where(i => i.Attended != (int)Naming.LessonStatus.課程結束);
    }

</script>
