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
<div class="modal modal-mini fade" id="<%= _dialogID %>" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h6 class="title">請選擇執行功能</h6>
                <a class="closebutton" data-dismiss="modal"></a>
            </div>
            <div class="modal-popmenu-body">
                <div class="list-group">
                    <a href='javascript:showBarChart(<%= JsonConvert.SerializeObject(new { ClassTimeStart = _model.ClassTime.Value.Date }) %>);' class="list-group-item">查看直條圖</a>
                    <a href="javascript:approveLesson('<%= _viewModel.KeyID %>');" class="list-group-item">待審核</a>
                </div>
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
    LessonTimeBookingViewModel _viewModel;
    String _dialogID = $"pcb{DateTime.Now.Ticks}";
    LessonTime _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
        _viewModel = (LessonTimeBookingViewModel)ViewBag.ViewModel;
    }


</script>
