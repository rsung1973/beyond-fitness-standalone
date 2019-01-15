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
                    <div class="col-12 align-left">
                        <p class="col-red">課表重點：</p>
                        <div class="form-line">
                            <textarea rows="1" class="form-control no-resize" placeholder="重點一片空，學生要來踹你了..." maxlength="10"><%= _model.TrainingPlan.FirstOrDefault()?.TrainingExecution.Emphasis %></textarea>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-darkteal btn-round waves-effect"><i class="zmdi zmdi-edit"></i></button>
                <button type="button" class="btn btn-simple btn-round waves-effect">更新重點</button>
                <button type="button" class="btn btn-danger btn-round btn-simple btn-round waves-effect waves-red" onclick="javascript:deleteData();"><i class="zmdi zmdi-delete"></i></button>
            </div>
        </div>
    </div>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;
    CalendarEventQueryViewModel _viewModel;
    String _dialogID = $"boy{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
        _viewModel = (CalendarEventQueryViewModel)ViewBag.ViewModel;
    }


</script>
