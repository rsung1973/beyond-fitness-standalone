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
                <h4 class="modal-title" id="myModalLabel">檢視上課記錄</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="row">
                    <%  if (ViewBag.ShowCalendar != false)
                        { %>
                    <article class="col-sm-12 col-md-4 col-lg-4">
                        <!-- new widget -->
                        <div class="jarviswidget jarviswidget-color-darken" id="wid-id-3" data-widget-colorbutton="false" data-widget-colorbutton="false" data-widget-editbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
                            <!-- widget options:
                                       usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">
                                       
                                       data-widget-colorbutton="false"
                                       data-widget-editbutton="false"
                                       data-widget-togglebutton="false"
                                       data-widget-deletebutton="false"
                                       data-widget-fullscreenbutton="false"
                                       data-widget-custombutton="false"
                                       data-widget-collapsed="true"
                                       data-widget-sortable="false"
                                       
                                       -->
                            <header>
                                <span class="widget-icon"><i class="fa fa-calendar-alt"></i></span>
                                <h2><%= _model.FullName() %>的上課日曆 </h2>
                            </header>
                            <!-- widget div-->
                            <div>
                                <!-- widget edit box -->
                                <div class="jarviswidget-editbox">
                                    <input class="form-control" type="text">
                                </div>
                                <!-- end widget edit box -->
                                <div class="widget-body bg-color-darken txt-color-white no-padding">
                                    <!-- content goes here -->
                                    <div class="widget-body-toolbar">
                                        <div id="calendar-buttons">
                                            <div class="btn-group">
                                                <a href="javascript:void(0)" class="btn btn-default btn-xs" id="btn-prev"><i class="fa fa-chevron-left"></i></a>
                                                <a href="javascript:void(0)" class="btn btn-default btn-xs" id="btn-next"><i class="fa fa-chevron-right"></i></a>
                                            </div>
                                        </div>
                                    </div>
                                    <%  Html.RenderAction("RecentLessonsCalendar", new { uid = _model.UID, lessonID = ViewBag.LessonID }); %>
                                    <!-- end content -->
                                </div>
                            </div>
                            <!-- end widget div -->
                        </div>
                        <!-- end widget -->
                    </article>
                    <%  } %>
                    <article class="<%= ViewBag.ShowCalendar == false ? "col-sm-12 col-md-12 col-lg-12" : "col-sm-12 col-md-8 col-lg-8" %>">
                        <div class="jarviswidget" id="lessonContent" data-widget-togglebutton="false" data-widget-editbutton="false" data-widget-fullscreenbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false">
                            <%  Html.RenderAction("RecentLessons", new { uid = _model.UID, lessonID = ViewBag.LessonID, edit = true }); %>
                        </div>
                    </article>
                </div>
                <!-- end row -->
            </div>
            <%  if (ViewBag.CloneLesson == true)
                { %>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">
                    取消
                </button>
                <button type="button" class="btn btn-primary" id="btnModalClone">
                    確定複製 <i class="fa fa-files-o" aria-hidden="true"></i>
                </button>
            </div>
            <%  } %>
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
                width: 'auto',
                height: 'auto',
                'max-height': '100%'
            });

            $('#calendar').fullCalendar('render');

        });

        $modal.modal('show');

        calendarEventHandler = {
            dayClick: function (calEvent) {
            },
            eventClick: function (calEvent) {
                $global.lessonID = calEvent.lessonID;
                $('#lessonContent').load('<%= Url.Action("LessonContent","Report") %>', { lessonID: calEvent.lessonID, byCalendar: true, edit: true }, function () { });
            }
        };

        $('#btnModalClone').on('click', function (evt) {
            if ($global.cloneLesson) {
                $global.cloneLesson($global.lessonID);
            }
        });

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }

</script>
