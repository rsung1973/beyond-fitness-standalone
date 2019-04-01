<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Helper.DataOperation" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<div class="header">
    <h2><strong>原課程單價 <span class="badge bg-blue"><%= _model.LessonPriceType.PriceTypeBundle() %></span>：</strong> <span class="col-red"><%= $"{_model.LessonPriceType.ListPrice:##,###,###,###}" %></span></h2>
</div>
<div class="body">
    <div class="row clearfix">
        <div class="col-sm-3">
            <label class="fancy-checkbox custom-bgcolor-pink">
                <input id="checkbox14" type="checkbox" name="FitnessConsultant" value="<%= _model.FitnessConsultant %>" checked="checked" onclick="this.checked = true;" />
                <span class="col-red">終止</span>
            </label>
        </div>
        <div class="col-sm-6">
            <div class="input-group">
                <input type="text" class="form-control" placeholder="請輸入課程單堂價格" name="SettlementPrice" value="" />
                <span class="input-group-addon">
                    <i class="zmdi zmdi-money-box"></i>
                </span>
            </div>
            <script>
                $('input[name="SettlementPrice"]').on('change', function (evt) {
                    $('#refund').empty();
                    $('#refundUnit').empty();
                    var settlementPrice = parseInt($(this).val());
                    if (!isNaN(settlementPrice)) {
                        var remained = <%= _model.RemainedLessonCount() %>;
                        var lessons = <%= _model.Lessons %>;
                        var currPrice = <%= _model.LessonPriceType.ListPrice %>;
                        var totalPaid = <%= _model.TotalPaidAmount() %>;
                        var refund = totalPaid - (lessons - remained) * settlementPrice *<%= _model.CourseContractType.GroupingMemberCount %>*<%= _model.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount %>/100;
                        $('#refund').text(refund);
                        $('#refundUnit').text(settlementPrice);
                    }
                });
            </script>
        </div>
        <div class="col-12">
            <div class="alert xl-pink col-darkteal" role="alert">
                <div class="container">
                    <div class="alert-icon">
                        <i class="zmdi zmdi-notifications"></i>
                    </div>
                    終止時全部堂數以單堂 <span id="refundUnit"></span>元 計價，並扣除剩餘上課堂數：<%= _model.RemainedLessonCount() %>堂，計算退款差額 <span class="col-red" id="refund"></span>元。
                </div>
            </div>
        </div>
        <div class="col-12">
            <div class="form-group">
                <textarea rows="3" class="form-control no-resize" name="Remark" placeholder="請輸入任何想補充的事項..."></textarea>
            </div>
        </div>
    </div>
</div>

<script>

    $(function () {

        $('#<%= _viewID %> button.quit').on('click', function (event) {
            cancelTerminating();
        });

        $('#<%= _viewID %> button.finish').on('click', function (event) {
            commitTerminating();
        });

    });

    function cancelTerminating() {
        $('').launchDownload('<%= Url.Action("ApplyContractService","ConsoleHome") %>',
            <%= JsonConvert.SerializeObject(new CourseContractQueryViewModel
                {
                    KeyID = _model.ContractID.EncryptKey(),
                }) %>);
    }

    function commitTerminating() {
        var viewModel = $('#<%= _viewID %>').find('input,select,textArea').serializeObject();
        viewModel.Reason = '終止';
        viewModel.FitnessConsultant = <%= _model.FitnessConsultant %>;
        clearErrors();
        showLoading();
        $.post('<%= Url.Action("CommitContractService", "ContractConsole",new { KeyID = _model.ContractID.EncryptKey() }) %>', viewModel, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                swal(data.message);
            }
            else {
                $(data).appendTo($('body'));
            }
        });
    }

</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContract _model;
    UserProfile _profile;
    String _viewID;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
        _profile = Context.GetUser();
        _viewID = ViewBag.ViewID as String;
    }


</script>
