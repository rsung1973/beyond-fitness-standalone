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

<div id="<%= _dialog %>" title="設定企業合作方案項目" class="bg-color-darken">
    <!-- Widget ID (each widget will need unique ID)-->
    <div class="jarviswidget jarviswidget-color-darken" id="wid-id-2" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
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
            <span class="widget-icon"><i class="fa fa-table"></i></span>
            <h2>企業合作方案項目清單</h2>
            <div class="widget-toolbar">
                <a onclick="$global.editProgramItem();" class="btn btn-primary"><i class="fa fa-fw fa-plus"></i>新增項目</a>
            </div>
        </header>
        <!-- widget div-->
        <div>
            <!-- widget edit box -->
            <div class="jarviswidget-editbox">
                <!-- This area used as dropdown edit box -->
            </div>
            <!-- end widget edit box -->
            <!-- widget content -->
            <div class="widget-body bg-color-darken txt-color-white no-padding">
                <form action="<%= Url.Action("CommitEnterpriseContract","EnterpriseProgram",new { _viewModel.ContractID }) %>" class="smart-form" method="post" autofocus>
                    <fieldset>
                        <div class="row">
                            <section class="col col-8">
                                <label class="label">企業名稱</label>
                                <label class="input">
                                    <i class="icon-append fa fa-font"></i>
                                    <input type="text" name="CompanyName" maxlength="200" placeholder="請輸入企業名稱" value="<%= _viewModel.CompanyName %>" />
                                </label>
                            </section>
                            <section class="col col-4">
                                <label class="label">統一編號</label>
                                <label class="input">
                                    <i class="icon-append fa fa-font"></i>
                                    <input type="tel" name="ReceiptNo" maxlength="20" placeholder="請輸入統一編號" value="<%= _viewModel.ReceiptNo %>" />
                                </label>
                            </section>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="row">
                            <section class="col col-4">
                                <label class="label">請選擇分店</label>
                                <label class="select">
                                    <select class="input" name="BranchID">
                                        <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.ascx", model: _viewModel.BranchID ?? -1);    %>
                                    </select>
                                    <i class="icon-append far fa-keyboard"></i>
                                </label>
                            </section>
                            <section class="col col-4">
                                <label class="label">合約起日</label>
                                <label class="input">
                                    <i class="icon-append far fa-calendar-alt"></i>
                                    <input type="text" name="ValidFrom" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請選擇合約起日" value='<%= _viewModel.ValidFrom.HasValue ? _viewModel.ValidFrom.Value.ToString("yyyy/MM/dd") : "" %>' />
                                </label>
                            </section>
                            <section class="col col-4">
                                <label class="label">合約迄日</label>
                                <label class="input">
                                    <i class="icon-append far fa-calendar-alt"></i>
                                    <input type="text" name="Expiration" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請選擇合約迄日" value='<%= _viewModel.Expiration.HasValue ? _viewModel.Expiration.Value.ToString("yyyy/MM/dd") : "" %>' />
                                </label>
                            </section>
                        </div>
                    </fieldset>
                    <fieldset>
                        <section>
                            <label class="label">合作方案說明</label>
                            <label class="input">
                                <i class="icon-append fa fa-font"></i>
                                <input type="text" name="Subject" maxlength="200" placeholder="請輸入合作方案說明" value="<%= _viewModel.Subject %>" />
                            </label>
                        </section>
                    </fieldset>
                    <fieldset>
                        <table id="courseItems" class="table table-striped table-bordered table-hover" width="100%">
                            <thead>
                                <tr>
                                    <th>項目</th>
                                    <th>上課時間長度</th>
                                    <th>購買堂數</th>
                                    <th>體能顧問終點費用</th>
                                    <th>功能</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%  if (_viewModel.EnterprisePriceID != null && _viewModel.EnterprisePriceID.Length > 0)
                                    {
                                        for (int i = 0; i < _viewModel.EnterprisePriceID.Length; i++)
                                        {
                                            var item = models.GetTable<EnterpriseLessonType>().Where(p => p.TypeID == _viewModel.EnterprisePriceID[i]).First(); %>
                                <tr>
                                    <td>
                                        <%= item.Description %>
                                        <input type="hidden" name="EnterprisePriceID" value="<%= _viewModel.EnterprisePriceID[i] %>" />
                                    </td>
                                    <td>
                                        <%= _viewModel.EnterpriseDurationInMinutes[i] %>分鐘
                                        <input type="hidden" name="EnterpriseDurationInMinutes" value="<%= _viewModel.EnterpriseDurationInMinutes[i] %>" />
                                    </td>
                                    <td>
                                        <%= _viewModel.EnterpriseLessons[i] %>堂
                                        <input type="hidden" name="EnterpriseLessons" value="<%= _viewModel.EnterpriseLessons[i] %>" />
                                    </td>
                                    <td>
                                        <%= _viewModel.EnterpriseListPrice[i] %>
                                        <input type="hidden" name="EnterpriseListPrice" value="<%= _viewModel.EnterpriseListPrice[i] %>" />
                                    </td>
                                    <td>
                                        <a onclick="$global.deleteItem();" class="btn btn-circle bg-color-red delete"><i class="fa fa-fw fa fa-lg fa-trash-alt" aria-hidden="true"></i></a>
                                    </td>
                                </tr>
                                <%      }
                                    } %>
                            </tbody>
                        </table>
                    </fieldset>
                    <fieldset>
                        <section>
                            <label class="label">備註</label>
                            <textarea class="form-control" placeholder="請輸入備註" name="remark" rows="3"><%= _viewModel.Remark %></textarea>
                        </section>
                    </fieldset>
                    <fieldset>
                        <section>
                            <label class="label">以上項目套裝價格為每人</label>
                            <label class="input">
                                <i class="icon-append fa fa-dollar-sign"></i>
                                <input type="tel" name="TotalCost" maxlength="10" placeholder="請輸入價格" value="<%= _viewModel.TotalCost %>" />
                            </label>
                        </section>
                    </fieldset>
                </form>
            </div>
            <!-- end widget content -->
        </div>
        <!-- end widget div -->
    </div>
    <!-- end widget -->
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen : false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 設定企業合作方案項目</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {
                    clearErrors();
                    var $form = $('#<%= _dialog %> form');
                    $form.ajaxSubmit({
                        beforeSubmit: function () {
                            showLoading();
                        },
                        success: function (data) {
                            hideLoading();
                            if ($.isPlainObject(data)) {
                                if (data.result) {
                                    alert('資料已儲存!!');
                                    showLoading();
                                    window.location.href = '<%= Url.Action("ProgramIndex","EnterpriseProgram") %>';
                                } else {
                                    alert(data.message);
                                }
                            } else {
                                $(data).appendTo($('body')).remove();
                            }
                        }
                    });
                    <%--$('#<%= _dialog %>').dialog("close");--%>
                }
            }],
            close: function () {
                $('#<%= _dialog %>').remove();
            }
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

        $(function () {
            $global.appendProgramItem = function ($data) {
                $('#courseItems > tbody').append($data);
            };

            $global.editProgramItem = function () {
                showLoading();
                $.post('<%= Url.Action("EditProgramDataItem","EnterpriseProgram") %>', {}, function (data) {
                    hideLoading();
                    $(data).appendTo($('body'));
                });
            };

            $global.deleteItem = function () {
                var event = event || window.event;
                $(event.target).closest('tr').remove();
            };

        });

    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    EnterpriseContractViewModel _viewModel;
    String _dialog = "enterpriseContract" + DateTime.Now.Ticks;
    UserProfile _profile;
    bool _useLearnerDiscount;
    EnterpriseCourseContract _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (EnterpriseCourseContract)this.Model;
        _viewModel = (EnterpriseContractViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser().LoadInstance(models);
    }

</script>
