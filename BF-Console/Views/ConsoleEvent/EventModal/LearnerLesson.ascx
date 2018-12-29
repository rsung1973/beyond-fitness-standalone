<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <div class="member-card">
                <a class="closebutton" data-dismiss="modal"></a>
                <div class="<%= "header " + (_model.RegisterLesson.UserProfile.UserProfileExtension.Gender == "M"
                                            ? "l-cyan-2"
                                            : _model.RegisterLesson.UserProfile.UserProfileExtension.Gender == "F"
                                                ? "l-blush"
                                                : "g-bg-darkteal") %>">
                    <h4 class="m-t-0 p-t-10"><%= _model.RegisterLesson.UserProfile.FullName() %></h4>
                </div>
                <div class="member-img">
                    <a href="profile.html" class="">
                        <% _model.RegisterLesson.UserProfile.PictureID.RenderUserPicture(this.Writer, new { @class = "rounded-circle popfit" }, "images/avatar/noname.png"); %>
                    </a>
                </div>
                <div class="body">
                    <div class="col-12">
                        <p class="text-muted"><%= _model.FullLessonDuration() %></p>
                        <address><%= _model.LessonTypeStatus() %> <i class="zmdi zmdi-pin"></i><%= _model.BranchID.HasValue ? _model.BranchStore.BranchName : _model.Place %></address>
                    </div>
                    <hr>
                    <%  Html.RenderPartial("~/Views/ConsoleEvent/Module/LessonEmphasis.ascx", _model); %>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-darkteal btn-round waves-effect"><i class="zmdi zmdi-edit"></i></button>
                <button type="button" class="btn btn-simple btn-round waves-effect" onclick="commitEmphasis('<%= plan.ExecutionID.EncryptKey() %>');">更新重點</button>
                <%  Html.RenderPartial("~/Views/ConsoleEvent/Module/RevokeLesson.ascx", _model); %>
            </div>
        </div>
    </div>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
    <script>

    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;
    CalendarEventQueryViewModel _viewModel;
    String _dialogID = $"boy{DateTime.Now.Ticks}";
    TrainingPlan plan;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
        _viewModel = (CalendarEventQueryViewModel)ViewBag.ViewModel;
        plan = _model.AssertTrainingPlan(models);
    }


</script>
