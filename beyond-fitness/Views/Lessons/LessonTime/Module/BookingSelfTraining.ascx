<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="modal fade" id="bookingTraining" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    &times;
                </button>
                <h4 class="modal-title" id="myModalLabel"><i class="far fa-fw fa-check-square"></i>預約教練P.I</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="panel panel-default bg-color-darken no-padding">
                    <form action="<%= Url.Action("CommitBookingSelfTraining","Lessons",new { lessonID = _viewModel.LessonID }) %>" method="post" class="smart-form">
                        <fieldset>
                            <div class="row">
                                <section class="col col-6">
                                    <label>請選擇上課時段</label>
                                    <label class="input">
                                        <i class="icon-append far fa-calendar-alt"></i>
                                        <input type="text" name="classDate" readonly="readonly" id="classDate" class="form-control input-lg date form_time" data-date-format="yyyy/mm/dd hh:ii" value="<%= _viewModel.ClassDate.ToString("yyyy/MM/dd HH:mm") %>" placeholder="請輸入上課開始時間" />
                                    </label>
                                </section>
                                <section class="col col-6">
                                    <label>請選擇上課小時數</label>
                                    <label class="select">
                                        <select name="duration" class="input-lg">
                                            <option value="60" <%= _viewModel.Duration==60 ? "selected": null %>>60 分鐘</option>
                                            <option value="90" <%= _viewModel.Duration==90 ? "selected": null %>>90 分鐘</option>
                                        </select>
                                        <i class="icon-append far fa-keyboard"></i>
                                    </label>
                                </section>
                                <section class="col col-4" style="display:none;">
                                    <label>請選擇上課地點</label>
                                    <label class="select">
                                        <select class="input-lg" name="branchID">
                                            <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.cshtml", model: _viewModel.BranchID); %>
                                        </select>
                                        <i class="icon-append far fa-keyboard"></i>
                                    </label>
                                </section>
                            </div>
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

        $('.form_time').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 2,
            minView: 0,
            minuteStep: 30,
            forceParse: 0
        });

    $(function () {

        $('#btnSend').on('click', function (evt) {
            var event = event || window.event;
            var $form = $('#bookingTraining').find('form');
            $form.ajaxSubmit({
                beforeSubmit: function () {
                    showLoading();
                },
                success: function (data) {
                    if (data.result) {
                        smartAlert("預約完成!!", function () {
                            if ($global.reload) {
                                $global.reload();
                            }
                        });
                        $modal.modal('hide');
                    } else {
                        var $data = $(data);
                        $('body').append($data);
                        $data.remove();
                    }
                    hideLoading();
                }
            });
        });

<%--        $('#btnCancel').on('click', function (evt) {
            $modal.modal('hide');
        });--%>

        var $modal = $('#bookingTraining');
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
    LessonTimeViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (LessonTimeViewModel)this.Model;
    }

</script>
