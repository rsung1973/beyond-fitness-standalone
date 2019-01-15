<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="head bg-dot30 np tac">
    <div class="user_taurus">
        <div class="info">
            <a href="<%= Url.Action("EditCoach","Member",new { id = _model.UID }) %>" class="informer informer-one">
                <span class="fa fa-birthday-cake fa-2x">&nbsp;<u><%= _model.YearsOld() %></u></span>
            </a>
            <a href="#" class="informer informer-two" onclick="showLearnerAssessment(<%= _model.UID %>,<%= _item.LessonID %>);">
                <u><span class="fa fa-line-chart"></span></u>
            </a>
            <a onclick="$global.editLearner(<%= _model.UID %>);">
                <%  _model.RenderUserPicture(Writer, new { @class = "img-circle img-thumbnail", @style = "width:100px" }); %>

            </a>
        </div>
    </div>
</div>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    LessonTime _item;

    IQueryable<RegisterLesson> _items;
    IQueryable<RegisterLesson> _currentLessons;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
         _item = (LessonTime)ViewBag.LessonTime;

        _items = models.GetTable<RegisterLesson>().Where(r => r.UID == _model.UID)
            .Where(l => l.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
            .OrderByDescending(r => r.RegisterID);
        _currentLessons = _items.Where(i => i.Attended != (int)Naming.LessonStatus.課程結束);
    }

</script>
