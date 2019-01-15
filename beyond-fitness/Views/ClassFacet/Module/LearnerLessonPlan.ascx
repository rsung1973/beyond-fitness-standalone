<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="row">

    <div class="block">
        <%  //if (_model.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI)
            //{
            //    Html.RenderPartial("~/Views/ClassFacet/Module/CoachSelfLesson.ascx", _model.UserProfile);
            //}
            //else
            {
                ViewBag.RegisterLesson = _model;
                Html.RenderPartial("~/Views/ClassFacet/Module/LessonCount.ascx", _model.UserProfile);
            } %>        
    </div>
    <%  Html.RenderPartial("~/Views/Member/Module/MemberRecentStatus.ascx", _model.UserProfile); %>

    <script>

        function showLearnerAssessment(uid,lessonID) {
            showLoading();
            $.post('<%= Url.Action("LearnerAssessment","ClassFacet") %>', { 'uid': uid,'lessonID':lessonID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
            return false;
        }

        $('#healthlist_link').click(function () {
            showLoading();
            $.post('<%= Url.Action("HealthIndex","LearnerFacet",new { id = _model.UID }) %>', {}, function (data) {
                $(data).appendTo($('body'));
                hideLoading();
            });
            return false;
        });

        $('#diagnosisDialog_link').click(function () {
            diagnose();
            return false;
        });

    </script>
</div>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    RegisterLesson _model;
    LessonTime _item;
 
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (RegisterLesson)this.Model;
        _item = (LessonTime)ViewBag.LessonTime;

    }

</script>
