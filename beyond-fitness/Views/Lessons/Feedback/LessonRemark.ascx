<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="modal fade" id="lessonRemark" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    &times;
                </button>
                <h4 class="modal-title" id="myModalLabel"><i class="icon-append fa fa-commenting"></i> 學員悄悄話</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="panel panel-default bg-color-darken no-padding">
                    <div class="who clearfix">
                        <%  _model.RegisterLesson.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online", @style = "width:40px" }); %>
                        <span class="name font-lg"><b><%= _model.RegisterLesson.UserProfile.FullName() %></b></span><br />
                        <span class="from font-md"><%= _model.Remark %></span>
                    </div>
                    <form id="remarkForm" action="<%= Url.Action("CommitLessonRemark","Lessons",new { id = _model.LessonID }) %>" method="post" class="smart-form">
                        <fieldset>
                            <label class="label">回覆內容</label>
                            <label class="textarea">
                                <i class="icon-append fa fa-commenting-o"></i>
                                <textarea rows="10" name="remark"><%= _model.LessonTime.LessonPlan.Remark %></textarea>
                            </label>
                        </fieldset>
                    </form>
                </div>
                <!-- /.modal-content -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">
                    取消
                </button>
                <button id="btnSend" type="button" class="btn btn-primary">
                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                </button>
            </div>
        </div>
        <!-- /.modal-content -->
    </div>
    <!-- /.modal-dialog -->
    <script>

        $(function () {

            $('#btnSend').on('click', function (evt) {
                var event = event || window.event;
                var hasValue = false;
                var $form = $('#remarkForm');
                $form.ajaxSubmit({
                    success: function (data) {
                        if (data.result) {
                            smartAlert("資料已儲存!!");
                        } else {
                            smartAlert(data.message);
                        }
                        $modal.modal('hide');
                    }
                });

            });

<%--        $('#btnCancel').on('click', function (evt) {
            $modal.modal('hide');
        });--%>

            var $modal = $('#lessonRemark');
            $modal.on('hidden.bs.modal', function (evt) {
                $modal.remove();
            });

<%--        $modal.on('shown.bs.modal', function () {
            $(this).find('.modal-dialog').css({
                width: '100%',
                height: '100%',
                'max-height': '100%'
            });

        });--%>

            $modal.modal('show');

        });
    </script>

</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonFeedBack _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFeedBack)this.Model;
    }

</script>
