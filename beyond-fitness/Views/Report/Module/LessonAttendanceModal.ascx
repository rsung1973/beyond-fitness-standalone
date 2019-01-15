<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="modal fade" id="<%= ViewBag.ModalId ?? "theModal" %>" tabindex="-1" role="dialog" aria-labelledby="confirmLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    &times;
                </button>
                <h4 class="modal-title" id="myModalLabel"><i class="icon-append fa fa-list-ol"></i> 上課明細：<%= _item.AsAttendingCoach.UserProfile.FullName() %></h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <%  Html.RenderPartial("~/Views/Report/Module/LessonAttendanceList.ascx", _model); %>
            </div>
            <!-- /.modal-content -->
        </div>
    </div>
</div>
<script>

    $(function () {
        var $modal = $('#<%= ViewBag.ModalId ?? "theModal" %>');

        $modal.on('hidden.bs.modal', function (evt) {
            $modal.remove();
        });

        $modal.on('shown.bs.modal', function () {
            $(this).find('.modal-dialog').css({
                width: '80%',
                //height: '100%',
                'max-height': '100%'
            });

        });
        
        $modal.modal('show');

    });
</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    IQueryable<LessonTime> _model;
    LessonTime _item;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (IQueryable<LessonTime>)this.Model;
        _item = _model.First();
        ViewBag.ModalId = "lessonAttendanceModal";
    }

</script>
