<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="modal fade" id="recentLessons" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    &times;
                </button>
                <h4 class="modal-title" id="myModalLabel"><i class="fa-fw fa fa-book"></i> 我的運動日誌</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="row">
                    <article class="col-sm-12 col-md-12 col-lg-12">
                        <div class="jarviswidget" id="lessonContent" data-widget-togglebutton="false" data-widget-editbutton="false" data-widget-fullscreenbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false">
                            <%  ViewBag.Learner = true;
                                ViewBag.TabIndex = 0;
                                Html.RenderPartial("~/Views/Lessons/LessonContent.ascx",_model); %>
                        </div>
                    </article>
                </div>
                <!-- end row -->
            </div>
        </div>
        <!-- /.modal-content -->
    </div>
    <!-- /.modal-dialog -->
</div>

<script>

    $(function () {

        var $modal = $('#recentLessons');
        $modal.on('hidden.bs.modal', function (evt) {
            $modal.remove();
        });

        $modal.on('shown.bs.modal', function () {
            $(this).find('.modal-dialog').css({
                width: '100%',
                height: '100%',
                'max-height': '100%'
            });

        });

        $modal.modal('show');

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTime _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTime)this.Model;
    }

</script>
