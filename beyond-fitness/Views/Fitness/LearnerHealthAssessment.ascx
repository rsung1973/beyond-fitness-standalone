<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="modal fade" id="learnerHealthModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                    &times;
                </button>
                <h4 class="modal-title" id="myModalLabel"><i class="fa-fw fa fa-history"></i>新增修改健康指數</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="panel panel-default bg-color-darken no-padding">
                    <form action="<%= Url.Action("CommitLearnerHealthAssessment","Activity",new { assessmentID = _model.AssessmentID,groupID = 2 }) %>" method="post" class="smart-form">
                        <div class="panel-body status smart-form vote">
                            <div class="who clearfix">
                                <%  _model.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online" }); %>
                                <span class="from font-md"><b>Hi, <%= _model.UserProfile.FullName() %></b> 請填寫相關健康指數</span>
                            </div>
                            <fieldset>
                                <div class="form-group no-padding">
                                    <div class="col col-sm-12 col-md-4">
                                        <div class="input-group">
                                            <span class="input-group-addon">疲勞指數</span>
                                            <% var item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 10).FirstOrDefault(); %>
                                            <input class="form-control" type="number" placeholder="請輸入1-10" name="_10" value="<%= item!=null ? item.TotalAssessment : null %>" />
                                            <span class="input-group-addon">指數</span>
                                        </div>
                                    </div>
                                    <div class="col col-sm-12 col-md-4">
                                        <div class="input-group">
                                            <span class="input-group-addon">睡眠時間</span>
                                            <% item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 12).FirstOrDefault(); %>
                                            <input class="form-control" type="number" placeholder="請輸入純數字" name="_12" value="<%= item!=null ? item.TotalAssessment : null %>" />
                                            <span class="input-group-addon">小時</span>
                                        </div>
                                    </div>
                                    <div class="col col-sm-12 col-md-4">
                                        <div class="input-group">
                                            <span class="input-group-addon">體重</span>
                                            <% item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 49).FirstOrDefault(); %>
                                            <input class="form-control" type="number" placeholder="請輸入純數字" name="_49" value="<%= item!=null ? item.TotalAssessment : null %>" />
                                            <span class="input-group-addon">KG</span>
                                        </div>
                                    </div>
                                </div>
                            </fieldset>
                            <fieldset>
                                <div class="form-group">
                                    <div class="col col-sm-12 col-md-4">
                                        <div class="input-group">
                                            <span class="input-group-addon">腰</span>
                                            <% item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 13).FirstOrDefault(); %>
                                            <input class="form-control" type="number" placeholder="請輸入純數字" name="_13" value="<%= item!=null ? item.TotalAssessment : null %>" />
                                            <span class="input-group-addon">CM</span>
                                        </div>
                                    </div>
                                    <div class="col col-sm-12 col-md-4">
                                        <div class="input-group">
                                            <span class="input-group-addon">腿</span>
                                            <% item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 14).FirstOrDefault(); %>
                                            <input class="form-control" type="number" placeholder="請輸入純數字" name="_14" value="<%= item!=null ? item.TotalAssessment : null %>" />
                                            <span class="input-group-addon">CM</span>
                                        </div>
                                    </div>
                                    <div class="col col-sm-12 col-md-4">
                                        <div class="input-group">
                                            <span class="input-group-addon">臀</span>
                                            <% item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 15).FirstOrDefault(); %>
                                            <input class="form-control" type="number" placeholder="請輸入純數字" name="_14" value="<%= item!=null ? item.TotalAssessment : null %>" />
                                            <span class="input-group-addon">CM</span>
                                        </div>
                                    </div>
                                </div>
                            </fieldset>
                        </div>
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
            var $form = $('#learnerHealthModal').find('form');
            $form.find('input').each(function (idx) {
                if ($(this).val() != '') {
                    hasValue = true;
                }
            });
            if (hasValue) {
                $form.ajaxSubmit({
                    success: function (data) {
                        if (data.result) {
                            smartAlert("資料已儲存!!", function () {
                                window.location.href = '<%= Url.Action("ViewProfile","Account",new { id = _model.UID }) %>';
                            });
                        } else {
                            smartAlert(data.message);
                        }
                        $modal.modal('hide');
                    }
                });
            } else {
                smartAlert("請輸入至少一個項目!!");
            }
        });

        $('#btnCancel').on('click', function (evt) {
            $modal.modal('hide');
        });

        var $modal = $('#learnerHealthModal');
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
    LessonFitnessAssessment _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFitnessAssessment)this.Model;
    }

</script>
