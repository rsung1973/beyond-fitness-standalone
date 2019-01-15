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
                <h4 class="modal-title" id="myModalLabel"><i class="fa-fw fa fa-history"></i>功能標題</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="panel panel-default bg-color-darken no-padding">
                    <form action="" method="post" class="smart-form">
                        <div class="panel-body status smart-form vote">
                            <div class="who clearfix">
                                <span class="from font-md"> 動作提示</span>
                            </div>
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
            var $form = $(event.target).closest('form');
            $form.find('input').each(function (idx) {
                if ($(this).val() != '') {
                    hasValue = true;
                }
            });
            if (hasValue) {
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
            } else {
                smartAlert("請輸入至少一個項目!!");
            }
        });

<%--        $('#btnCancel').on('click', function (evt) {
            $modal.modal('hide');
        });--%>

        var $modal = $('#recentLessons');
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

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
