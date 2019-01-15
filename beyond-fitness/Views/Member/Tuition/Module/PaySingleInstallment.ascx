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
                <h4 class="modal-title" id="myModalLabel">新增維護付款紀錄</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <label class="text-warning font-md">
                    總金額：<%= _model.RegisterLesson.LessonPriceType.ListPrice  %>「<%= _model.RegisterLesson.LessonPriceType.Description %>」* <%= _model.RegisterLesson.Lessons %> <%= _model.RegisterLesson.GroupingMemberCount>1 ? " * " + _model.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount + "%" : null %>  = <%= String.Format("{0:##,###,###,###}",_model.RegisterLesson.Lessons * _model.RegisterLesson.LessonPriceType.ListPrice * _model.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount / 100) %>
                    <br />
                    目前已付金額：<%= String.Format("{0:##,###,###,###}",_model.TuitionInstallment.Sum(t=>t.PayoffAmount)) %></label>
                <form action="<%= Url.Action("CommitSinglePayment","Member",new { RegisterID = _model.RegisterID }) %>" id="payInstallmentForm" class="smart-form" method="post">
                    <fieldset>
                        <div class="row">
                            <section class="col col-6">
                                <label>付款金額</label>
                                <label class="input">
                                    <i class="icon-append fa fa-dollar-sign"></i>
                                    <input type="text" name="PayoffAmount" placeholder="請輸入付款總金額" value="" />
                                </label>
                            </section>
                            <section class="col col-6">
                                <label>付款日期</label>
                                <label class="input input-group">
                                    <i class="icon-append far fa-calendar-alt"></i>
                                    <input type="text" class="form-control date form_date" value="<%= String.Format("{0:yyyy/MM/dd}",DateTime.Today) %>" readonly="readonly" data-date-format="yyyy/mm/dd" placeholder="請輸入付款日期" name="PayoffDate" />
                                </label>
                            </section>
                        </div>
                    </fieldset>
                    <footer>
                        <button id="btnSend" type="button" class="btn btn-primary">
                            送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                        </button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">
                            取消
                        </button>
                    </footer>
                </form>
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
        
        $modal.modal('show');

        $('.form_date').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            clearBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 2,
            minView: 2,
            forceParse: 0
        });

        $('#btnSend').on('click', function (evt) {
            var event = event || window.event;
            var $form = $('#payInstallmentForm');
            $form.ajaxSubmit({
                beforeSubmit: function () {
                    showLoading();
                },
                success: function (data) {
                    hideLoading();
                    if (data.result) {
                        smartAlert("資料已儲存!!", function () {
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
                }
            });
        });

    });
</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    IntuitionCharge _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (IntuitionCharge)this.Model;
        ViewBag.ModalId = "payInstallment";
    }

</script>
