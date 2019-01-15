<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<div class="col-sm-12">
    <div class="block">
        <div class="head" style="bottom center no-repeat;">
            <div class="head-panel nm text-center">
                <%  if (_model.CoachID == _profile.UID)
                    { %>
                <a href="javascript:editProfile(<%= _model.CoachID %>);"><% _model.UserProfile.RenderUserPicture(Writer, new { @class = "img-circle img-thumbnail", @style = "width:130px" }); %></a>
                <%  }
                    else
                    { %>
                <% _model.UserProfile.RenderUserPicture(Writer, new { @class = "img-circle img-thumbnail", @style = "width:130px" }); %>
                <%  } %>
            </div>
            <div class="head-panel nm">
                <div class="hp-info pull-left" onclick="showCoachPerformance(<%= _model.CoachID %>);">
                    <div class="hp-icon">
                        <span class="fa fa-trophy"></span>
                    </div>
                    <span class="hp-main">
                        <%= _model.UserProfile.UserRoleAuthorization.Any(r=>r.RoleID==(int)Naming.RoleID.Officer )
                            ? "CEO"
                            : _model.UserProfile.UserRoleAuthorization.Any(r=> r.RoleID==(int)Naming.RoleID.Manager)
                                ? "FM"
                                : _model.UserProfile.UserRoleAuthorization.Any(r=> r.RoleID==(int)Naming.RoleID.ViceManager)
                                    ? "AFM"
                                    : _model.ProfessionalLevel.LevelName %>
                    </span>
                    <span class="hp-sm">
                        <%= _model.UserProfile.UserRoleAuthorization.Any(r=> r.RoleID==(int)Naming.RoleID.ViceManager) && (int)Naming.ProfessionalCategory.AFM!=_model.ProfessionalLevel.CategoryID.Value ? _model.ProfessionalLevel.LevelName : null %>
                    </span>
                </div>
                <div class="hp-info pull-left" onclick="showAttenderListByCoach(<%= _model.CoachID %>);">
                    <div class="hp-icon">
                        <span class="fa fa-address-card"></span>
                    </div>
                    <span class="hp-main"><%= _learners.Count() %></span>
                    <span class="hp-sm">VIP</span>
                </div>
                <div class="hp-info pull-left" onclick="showCoachCert(<%= _model.CoachID %>);">
                    <div class="hp-icon">
                        <span class="fa fa-certificate"></span>
                    </div>
                    <span class="hp-main"><%= _model.CoachCertificate.Count %></span>
                    <span class="hp-sm">Cert</span>
                </div>
                <div class="hp-info pull-right" onclick="showGameWidget(<%= _model.CoachID %>);">
                    <div class="hp-icon">
                        <span class="fa fa-gamepad text-success"></span>
                    </div>
                    <span class="hp-main text-success">
                        <%  var contestant = _model.UserProfile.ExerciseGameContestant;
                            if (contestant != null && contestant.ExerciseGamePersonalRank != null)
                            {
                                Writer.Write(contestant.ExerciseGamePersonalRank.Rank);
                            }   %>
                    </span>
                    <span class="hp-sm text-success">Rank</span>
                </div>
            </div>
        </div>
    </div>
    <script>
        $(function () {
            $('span[rel="tooltip"]').tooltip();
        });

        function showCoachCert(coachID) {
            showLoading();
            $.post('<%= Url.Action("ShowCoachCertificate","Member") %>', { 'coachID': coachID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        function showCoachPerformance(coachID) {
            showLoading();
            $.post('<%= Url.Action("GetCoachCurrentQuarterPerformance","Achievement") %>', { 'coachID': coachID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        function showGameWidget(uid) {
            showLoading();
            $.post('<%= Url.Action("ShowGameWidget","ExerciseGame") %>', { 'uid': uid }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        function showAttenderListByCoach(coachID) {
            showLoading();
            $.post('<%= Url.Action("ShowAttenderListByCoach","CoachFacet") %>', { 'coachID': coachID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        function showAttendanceAchievement(monthFrom) {
            showLoading();
            $.post('<%= Url.Action("ListAttendanceAchievement","Accounting",new { _model.CoachID }) %>', {
                'AchievementYearMonthFrom': monthFrom,
                'AchievementYearMonthTo': null,
            }, function (data) {
                hideLoading();
                $(data).appendTo($('#content'));
            });
        }

        function showTuitionShares(monthFrom) {
            showLoading();
            $.post('<%= Url.Action("ListTuitionShares","Accounting",new { _model.CoachID }) %>', {
                'AchievementYearMonthFrom': monthFrom,
                'AchievementYearMonthTo': null,
            }, function (data) {
                hideLoading();
                $(data).appendTo($('#content'));
            });
        }

        <%  if (_model.CoachID == _profile.UID)
        { %>
        function editProfile(uid) {
            showLoading();
            $.post('<%= Url.Action("EditMySelf","Html") %>', { 'uid': uid }, function (data) {
                $(data).appendTo($('body'));
                hideLoading();
            });
        }
        <%  } %>

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    ServingCoach _model;
    //IQueryable<LessonTime> _items;
    //IQueryable<LessonTime> _PISession;
    //IQueryable<TuitionAchievement> _tuition;
    IQueryable<UserProfile> _learners;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (ServingCoach)this.Model;

        _profile = Context.GetUser();

        //DateTime quarterStart = new DateTime(DateTime.Today.Year, (DateTime.Today.Month - 1) / 3 * 3 + 1, 1);
        //DateTime? dateTo = null;
        //_items = models.GetLessonAttendance(_model.CoachID, quarterStart, ref dateTo, 3, null);
        //_PISession = models.GetPISessionAttendance(_model.CoachID, quarterStart, ref dateTo, 3, null);
        //_tuition = models.GetTuitionAchievement(_model.CoachID, quarterStart, ref dateTo, 3);

        _learners = models.GetTable<LearnerFitnessAdvisor>()
            .Where(u => u.CoachID == _model.CoachID)
            .Select(u => u.UserProfile);


    }

</script>
