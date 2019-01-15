<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="jarviswidget" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
    <header class="bg-color-yellow">
        <span class="widget-icon"><i class="fa fa-bell"></i></span>
        <h2>尚有<%= _absentItems.Count() %>個學員已超過7天無上課記錄!</h2>
    </header>
    <!-- widget div-->
    <div>
        <!-- widget content -->
        <div class="widget-body txt-color-white padding-5">
            <!-- content -->
            <%  foreach (var item in _absentItems)
                {
                    var profile = item;%>
                    <div class="user" title="<%= profile.PID %>">
                        <a onclick="$global.editLearner(<%= item.UID %>);">
                            <%  profile.RenderUserPicture(Writer, new { @class = "", @style = "width:40px" }); %><i class="fa fa-bell text-warning"> <%= profile.FullName() %></i></a>
                        <%--<div class="email">
                            <a href="http://line.me/R/msg/text/?ξ( ✿＞◡❛)" target="_blank"><span class="label label-success">Line it! <i class="fa fa-fw fa fa-paper-plane"></i></span></a>
                        </div>--%>
                    </div>
            <%  } %>
            <%  foreach (var item in _items)
                {
                    var profile = item;%>
            <div class="user" title="<%= profile.PID %>">
                <a onclick="$global.editLearner(<%= item.UID %>);">
                    <%  profile.RenderUserPicture(Writer, new { @class = "", @style = "width:40px" }); %> <%= profile.FullName() %></a>
                <%--<div class="email">
                    <a href="http://line.me/R/msg/text/?ξ( ✿＞◡❛)" target="_blank"><span class="label label-success">Line it! <i class="fa fa-fw fa fa-paper-plane"></i></span></a>
                </div>--%>
            </div>
            <%  } %>
            <!-- end content -->
        </div>
        <!-- end widget content -->
    </div>
    <!-- end widget div -->
</div>
<script>
    $(function () {
        if (!$global.editLearner) {
            $global.editLearner = function (uid) {
                startLoading();
                $.post('<%= Url.Action("EditLearner","Learner") %>', { 'uid': uid }, function (data) {
                    hideLoading();
                    $(data).appendTo($('body'));
                });
            };
        }
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<UserProfile> _absentItems;
    IQueryable<UserProfile> _items;
    ServingCoach _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (ServingCoach)this.Model;

        //var attendingItems = models.GetTable<LessonTime>().Where(l => l.ClassTime >= DateTime.Today.AddDays(-7))
        //        .GroupBy(l => l.GroupID).Select(g => g.OrderByDescending(t => t.ClassTime).First())
        //        .Select(l => l.GroupingLesson.RegisterLesson)
        //        .SelectMany(r => r.Select(u => u.UserProfile));

        var attendingItems = models.GetTable<UserProfile>()
            .Where(u => u.RegisterLesson
                .Any(r => r.GroupingLesson.LessonTime
                    .Any(l => l.ClassTime >= DateTime.Today.AddDays(-7))))
            .Select(u => u.UID);

        //IQueryable<UserProfile> items = models.GetTable<RegisterLesson>()
        //        .Where(u => !u.UserProfile.UserProfileExtension.CurrentTrial.HasValue)
        //        .Where(u => u.LessonPriceType.Status != (int)Naming.LessonPriceStatus.自主訓練)
        //        .Where(u => u.AdvisorID == _model.CoachID && u.UID != _model.CoachID)
        //        .GroupBy(r => r.UID).Select(g => g.OrderByDescending(r => r.RegisterID).First())
        //        .Select(r => r.UserProfile);

        IQueryable<UserProfile> items = models.GetTable<LearnerFitnessAdvisor>()
            .Where(u => u.CoachID == _model.CoachID)
            .Select(u => u.UserProfile);

        //_absentItems = items.Except(attendingItems);
        _absentItems = items.Where(u => !attendingItems.Any(d => u.UID == d));

        //_items = items.Except(_absentItems);
        _items = items.Where(u => attendingItems.Any(d => u.UID == d));

    }

</script>
