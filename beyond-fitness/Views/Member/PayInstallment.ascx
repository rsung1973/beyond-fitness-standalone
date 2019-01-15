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

<div class="modal-dialog">
    <div class="modal-content">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                &times;
            </button>
            <h4 class="modal-title" id="myModalLabel">維護付款紀錄</h4>
            <label class="text-danger font-md">總金額：<%= _model.LessonPriceType.ListPrice  %>「<%= _model.LessonPriceType.Description %>」* <%= _model.Lessons %> <%= _model.GroupingMemberCount>1 ? " * " + _model.GroupingLessonDiscount.PercentageOfDiscount + "%" : null %>  = <%= String.Format("{0:##,###,###,###}",_model.Lessons * _model.LessonPriceType.ListPrice * _model.GroupingLessonDiscount.PercentageOfDiscount / 100) %></label>
        </div>
        <div class="modal-body bg-color-darken txt-color-white">
            <form id="paymentForm" action="<%= VirtualPathUtility.ToAbsolute("~/Member/CommitPayment") %>" class="smart-form" method="post">
                <input type="hidden" name="registerID" value="<%= _viewModel.RegisterID %>" />
                <%  for (int idx = 0; idx < _viewModel.PayoffAmount.Length; idx++)
                    { %>
                        <fieldset>
                            <div class="row">
                                <section class="col col-6">
                                    <label>第 <%= idx+1 %> 期付款金額</label>
                                    <label class="input">
                                        <i class="icon-append fa fa-dollar-sign"></i>
                                        <input type="text" id="<%= "payoffAmount_"+idx %>" name="payoffAmount" placeholder="請輸入付款總金額" value="<%= _viewModel.PayoffAmount[idx] %>" />
                                    </label>
                                </section>
<%--                                <section class="col col-4">
                                    <label>是否已付款</label>
                                    <label class="select">
                                        <select id="<%= "_"+idx %>">
                                            <option value="Y">是</option>
                                            <option value="N" <%= !_viewModel.PayoffDate[idx].HasValue ? "selected" : null %>>否</option>
                                        </select>
                                        <i></i>
                                    </label>
                                </section>--%>
                                <section class="col col-6">
                                    <label>付款日期</label>
                                    <label class="input input-group">
                                        <i class="icon-append far fa-calendar-alt"></i>
                                        <input type="text" class="form-control date form_date" value="<%= String.Format("{0:yyyy/MM/dd}",_viewModel.PayoffDate[idx]) %>" readonly="readonly" data-date-format="yyyy/mm/dd" placeholder="請輸入付款日期" name="payoffDate" id="<%= "payoffDate_"+idx %>" />
                                    </label>
                                </section>
                            </div>
                        </fieldset>
                <%  } %>
                <footer>
                    <button type="submit" id="btnSend" name="submit" class="btn btn-primary">
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
    <!-- /.modal-dialog -->
</div>

<script>

    $(function () {

            var validator = $("#paymentForm").validate({

                // Do not change code below
                errorPlacement: function (error, element) {
                    error.insertAfter(element.parent());
                }
            });

            validator.settings.submitHandler = function (form) {
                var result = true;
<%--                var $items = $('select').filter(function (index) { return $(this).val() == 'Y'; })
                    .each(function (index) {
                        var id = 'payoffDate' + $(this).prop('id');
                        alert(id);
                        if ($('#' + id).val() == '') {
                            validator.showErrors({
                                "payoffDate": "I know that your firstname is Pete, Pete!"
                            }, {
                                "payoffDate": "I know that your firstname is Pete, Pete!"
                            });

                            $('#' + id + '-error').css('display', 'block');
                            $('#' + id + '-error').text('請輸入付款日期!!');
                            result = false;
                        }
                    });

                alert('hhhhh');--%>
                return result;
            };

            $('[id^="payoffAmount"]').each(function (idx) {
                $(this).rules('add', {
                    'number': true,
                    messages: {
                        'number': '請輸入付款總金額'
                    }
                });
            });

            $('[id^="payoffDate"]').each(function(idx) {
                $(this).rules('add', {
                    //'required': true,
                    'date': true,
                    messages: {
                        //'required': '請輸入付款日期',
                        'date': '請輸入付款日期'
                    }
                });
            });

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

    });


    $('#btnSend').on('click', function (evt) {

    });

</script>


<script runat="server">

    ModelStateDictionary _modelState;
    RegisterLesson _model;
    InstallmentViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (RegisterLesson)this.Model;
        var models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (InstallmentViewModel)ViewBag.ViewModel;
    }

</script>
