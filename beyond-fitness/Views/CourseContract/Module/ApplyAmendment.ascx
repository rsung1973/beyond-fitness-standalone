<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<div id="<%= _dialog %>" title="學員服務申請" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitAmendment", "CourseContract", new { _model.ContractID }) %>" class="smart-form" method="post" autofocus>
            <fieldset>
                <%  var bookingCount = _model.CourseContractType.ContractCode == "CFA"
        ? _model.RegisterLessonContract.Sum(c => c.RegisterLesson.GroupingLesson.LessonTime.Count())
        : _model.RegisterLessonContract.First().RegisterLesson.GroupingLesson.LessonTime.Count;
                    var contractCost = _model.TotalCost / _model.Lessons * bookingCount;
                    var totalPaid = _model.TotalPaidAmount();
                    if (_model.Expiration.Value < DateTime.Today)
                    { %>
                <span class="label label-danger">
                    <li class="fa fa-exclamation-triangle"></li>
                    合約尚未生效或已過期，不可進行展延、轉讓、轉點申請！
                </span>
                <%  }
                    if (_model.CourseContractExtension.RevisionTrackingID.HasValue
                            && _model.CourseContractExtension.CourseContractRevision.Reason=="轉讓")
                    { %>
                <span class="label label-danger">
                    <li class="fa fa-exclamation-triangle"></li>
                    本合約屬轉讓，不可進行終止申請！
                </span>
                <%  } %>
                <%  if (_model.ContractType != 1)
                    { %>
                <span class="label label-danger">
                    <li class="fa fa-exclamation-triangle"></li>
                    合約非1對1體能顧問課程，不可進行轉讓申請！
                </span>
                <%  } %>
                <%  if (totalPaid < _model.TotalCost)
                    { %>
                <span class="label label-danger">
                    <li class="fa fa-exclamation-triangle"></li>
                    合約尚未繳清!（未繳清：<%= String.Format("{0:##,###,###,###}", _model.TotalCost - totalPaid) %>元），不可進行轉讓申請！
                </span>
                <%  } %>
                <%  if (contractCost > totalPaid)
                    { %>
                <span class="label label-danger">
                    <li class="fa fa-exclamation-triangle"></li>
                    合約繳款餘額不足！（不足：<%= String.Format("{0:##,###,###,###}", contractCost - totalPaid) %>元），不可進行轉點、終止申請，請繳清至已上課堂數之金額！
                </span>
                <%  } %>
                <%  if (_model.CourseContractExtension.BranchID == 2)
                    { %>
                <span class="label label-danger">
                    <li class="fa fa-exclamation-triangle"></li>
                    轉點申請只能是非Enhance 101店！
                </span>
                <%  } %>
                <div class="row">
                    <section class="col col-4">
                        <label class="label">申請項目</label>
                        <label class="select" id="applyContractItem">
                            <select name="Reason">
                                <option value="">請選擇</option>
                                <%  if (_model.Expiration.Value >= DateTime.Today)
                                    { %>
                                <option value="展延">展延</option>
                                    <%  if(_profile.IsAssistant() || _profile.IsManager() || _profile.IsViceManager())
                                        { 
                                            if (_model.ContractType == 1
                                                && totalPaid >= _model.TotalCost)
                                            { %>
                                    <%--<option value="轉讓">轉讓</option>--%>
                                        <%  }
                                            if (_model.CourseContractExtension.BranchID != 2
                                                && totalPaid >= contractCost)
                                            { %>
                                    <%--<option value="轉點">轉點</option>--%>
                                    <%      }
                                        }
                                    } %>
                                <%  if (_profile.IsAssistant() || _profile.IsManager() || _profile.IsViceManager())
                                    {
                                        if (contractCost <= totalPaid && !_model.CourseContractExtension.RevisionTrackingID.HasValue)
                                        { %>
                                <option value="終止">終止</option>
                                <%      }
                                    } %>
                                <%--<option value="其他">其他</option>--%>
                            </select>
                            <i class="icon-append far fa-keyboard"></i>
                            <script>
                                $(function(){
                                    $('select[name="Reason"]').val('<%= _viewModel.Reason %>');
                                });

                                $('select[name="Reason"]').on('change', function (evt) {
                                    var reason = $(this).val();
                                    var allChange = <%= _viewModel.Reason == "展延" || _viewModel.Reason == "轉讓" || _viewModel.Reason == "轉點" || _viewModel.Reason == "終止" ? "true" : "false" %>;
                                    if (reason == "展延" || reason == "轉讓" || reason == "轉點" || reason == "終止" || allChange) {
                                        showLoading();
                                        $.post('<%= Url.Action("AmendContract", "CourseContract", new { _model.ContractID }) %>',{'reason':reason},function(data){
                                            hideLoading();
                                            if ($.isPlainObject(data)) {
                                                alert(data.message);
                                            } else {
                                                $(data).appendTo($('body'));
                                                $('#<%= _dialog %>').dialog('close');
                                            }
                                        });
                                    }
                                });
                            </script>
                        </label>
                    </section>
                    <%  if (_viewModel.Reason == "展延")
                        {
                            Html.RenderPartial("~/Views/CourseContract/Module/ApplyAmendmentForExtension.ascx");
                        } %>
                    <section class="col col-4">
                        <%  if (_profile.IsAssistant() || _profile.IsManager() || _profile.IsViceManager())
                            { %>
                        <label class="label">簽約體能顧問</label>
                        <label class="select">
                            <select name="FitnessConsultant">
                                <option value="">請選擇體能顧問</option>
                                <%  IQueryable<ServingCoach> items = _profile.IsAssistant()
                    ? models.GetTable<ServingCoach>()
                    : _profile.GetServingCoachInSameStore(models);
                                    Html.RenderPartial("~/Views/SystemInfo/ServingCoachOptions.ascx", items); %>
                            </select>
                            <i class="icon-append far fa-keyboard"></i>
                        </label>
                        <script>
                            $(function(){
                                $('#<%= _dialog %> select[name="FitnessConsultant"]').val('<%= _viewModel.FitnessConsultant %>');
                            });
                        </script>
                        <%  }
                            else
                            { %>
                        <input type="hidden" name="FitnessConsultant" value="<%= _profile.UID %>" />
                        <%  } %>
                    </section>
                </div>
                <%  if (_viewModel.Reason == "轉點")
                    {
                        Html.RenderPartial("~/Views/CourseContract/Module/ApplyAmendmentForMigration.ascx");
                    }
                    else if (_viewModel.Reason == "終止")
                    { %>
                <div class="row">
                    <section class="col col-6">
                        <label class="label">課程單價 <span class="label-warning"><i class="fa fa-info-circle"></i>原購買堂數：<%= _model.Lessons %>堂 / <%= String.Format("{0:##,###,###,###}",_model.LessonPriceType.ListPrice) %>元</span></label>
                        <label class="input">
                            <i class="icon-append fa fa-dollar-sign"></i>
                            <input type="number" name="SettlementPrice" maxlength="20" placeholder="請輸入單堂折算價格" />
                        </label>
                    </section>
                    <script>
                        $('#<%= _dialog %> input[name="SettlementPrice"]').on('change',function(evt) {

                            var settlementPrice = parseInt($(this).val());
                            var remained = <%= _model.RemainedLessonCount() %>;
                            var lessons = <%= _model.Lessons %>;
                            var currPrice = <%= _model.LessonPriceType.ListPrice %>;
                            var totalPaid = <%= _model.TotalPaidAmount() %>;
                            var refund = totalPaid-(lessons-remained)*settlementPrice*<%= _model.CourseContractType.GroupingMemberCount %>*<%= _model.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount %>/100;
                            $('#clearoff').empty();
                            if(!isNaN(settlementPrice)) {
                                $('#clearoff').text('，終止時全部堂數以單堂 / '+settlementPrice
                                    +'元 計價，並扣除剩餘上課堂數：'+remained+'堂，計算退款差額 ' + refund + '元');
                            }
                        });
                    </script>
                </div>
                <%  } %>
            </fieldset>
            <%  if (_viewModel.Reason == "轉讓")
                    {
                        Html.RenderPartial("~/Views/CourseContract/Module/ApplyAmendmentForTransference.ascx");
                    } %>
            <fieldset>
                <section>
                    <%  if (_viewModel.Reason == "展延")
                        {   %>
                    <label class="label label-info">原合約編號 <%= _model.ContractNo() %> 使用截止日為 <%= String.Format("{0:yyyy/MM/dd}",_model.Expiration) %> 展延至 <span id="expiration"><%= String.Format("{0:yyyy/MM/dd}",_model.Expiration.Value.AddMonths(3)) %></span> 止。</label>
                    <%  }
                        else if (_viewModel.Reason == "轉點")
                        {   %>
                    <label class="label label-info">原合約編號 <%= _model.ContractNo() %> 上課地點為 <%= _model.CourseContractExtension.BranchStore.BranchName %> 轉點至 <span id="location"></span>。</label>
                    <%  }
                        else if (_viewModel.Reason == "轉讓")
                        {   %>
                    <label class="label label-info">原合約編號 <%= _model.ContractNo() %> 剩餘上課堂數：<%= _model.RegisterLessonContract.Count>0 ? _model.RegisterLessonContract.First().RegisterLesson.RemainedLessonCount() : _model.Lessons %>堂<span id="transference"></span>。</label>
                    <%  }
                        else if (_viewModel.Reason == "終止")
                        {   %>
                    <label class="label label-info">原合約編號 <%= _model.ContractNo() %> 原購買堂數：<%= _model.Lessons %>堂 / <%= String.Format("{0:##,###,###,###}",_model.LessonPriceType.ListPrice) %>元<span id="clearoff"></span>。</label>
                    <%  } %>
                    <label class="label">備註</label>
                    <textarea class="form-control" placeholder="請輸入備註" rows="3" name="Remark"></textarea>
                </section>
            </fieldset>
        </form>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "600",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-cogs'></i> 學員服務申請</h4></div>",
            buttons: [<%--{
                html: "<i class='far fa-save'></i>&nbsp; 暫存",
                "class": "btn bg-color-darken",
                click: function () {
                    $(this).dialog("close");
                }
            },--%> {
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 送交審核",
                "class": "btn btn-primary",
                click: function () {
                    if (confirm("請再次確認合約內容資料正確")) {
                        var $form = $('#<%= _dialog %> form');
                        clearErrors();
                        $form.ajaxSubmit({
                            beforeSubmit: function () {
                                showLoading();
                            },
                            success: function (data) {
                                hideLoading();
                                if ($.isPlainObject(data)) {
                                    if (data.result) {
                                        alert('服務申請已送交審核!!');
                                        $('#<%= _dialog %>').dialog('close');
                                    } else {
                                        alert(data.message);
                                    }
                                } else {
                                    $(data).appendTo($('body')).remove();
                                }
                            }
                        });
                    }
                }
            }],
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractViewModel _viewModel;
    String _dialog = "amendment" + DateTime.Now.Ticks;
    CourseContract _model;
    bool _useLearnerDiscount;
    UserProfile _profile;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
        _useLearnerDiscount = models.CheckLearnerDiscount(_model.CourseContractMember.Select(m => m.UID));
        _viewModel = (CourseContractViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser();
    }

</script>
