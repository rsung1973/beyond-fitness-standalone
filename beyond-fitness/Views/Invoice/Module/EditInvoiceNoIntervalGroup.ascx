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

<div id="<%= _dialog %>" title="編輯發票號碼" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitInvoiceNoIntervalGroup","Invoice",new { _viewModel.IntervalID }) %>" method="post" class="smart-form" autofocus>
            <fieldset>
                <div class="row">
                    <section class="col col-6">
                        <label class="label">發票年度</label>
                        <label class="select">
                            <select class="input" name="Year">
                                <%  for (int year = DateTime.Today.Year; year >= 2017; year--)
                                    { %>
                                <option value="<%= year %>"><%= year %></option>
                                <%  } %>
                            </select>
                            <i class="icon-append far fa-clock"></i>
                        </label>
                        <%  if (_viewModel.Year.HasValue)
                            { %>
                        <script>
                            $('#<%= _dialog %> select[name="Year"]').val('<%= _viewModel.Year %>');
                        </script>
                        <%  } %>
                    </section>
                    <section class="col col-6">
                        <label class="label">發票期別</label>
                        <label class="select">
                            <select class="input" name="PeriodNo">
                                <option value="1">01-02月</option>
                                <option value="2">03-04月</option>
                                <option value="3">05-06月</option>
                                <option value="4">07-08月</option>
                                <option value="5">09-10月</option>
                                <option value="6">11-12月</option>
                            </select>
                            <i class="icon-append far fa-clock"></i>
                        </label>
                        <%  if (_viewModel.PeriodNo.HasValue)
                            { %>
                        <script>
                            $('#<%= _dialog %> select[name="PeriodNo"]').val('<%= _viewModel.PeriodNo %>');
                        </script>
                        <%  } %>
                    </section>
                </div>
            </fieldset>
            <fieldset>
                <div class="row">
                    <section class="col col-4">
                        <label class="label">字軌</label>
                        <label class="input">
                            <i class="icon-append fa fa-font"></i>
                            <input type="text" name="TrackCode" maxlength="2" placeholder="請輸入字軌" value="<%= _viewModel.TrackCode %>" />
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">發票開始號碼（起）</label>
                        <label class="input">
                            <i class="icon-append fa fa-sort-numeric-up"></i>
                            <input type="text" name="StartNo" maxlength="8" placeholder="請輸入發票開始號碼（起）" value="<%= String.Format("{0:00000000}",_viewModel.StartNo) %>" />
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">發票開始號碼（迄）</label>
                        <label class="input">
                            <i class="icon-append fa fa-sort-numeric-up"></i>
                            <input type="text" name="EndNo" maxlength="8" placeholder="請輸入發票開始號碼（迄）" value="<%= String.Format("{0:00000000}",_viewModel.EndNo) %>" />
                        </label>
                    </section>
                </div>
            </fieldset>
            <fieldset>
                <label class="label"><i class="fa fa-tags"></i>本數分配（1本50張）</label>
                <div class="row">
                    <section class="col col-4">
                        <label class="label">南京小巨蛋</label>
                        <label class="input">
                            <i class="icon-append fa fa-sort-numeric-up"></i>
                            <input type="hidden" name="BookletBranchID" value="<%= _viewModel.BookletBranchID!=null && _viewModel.BookletBranchID.Length>0 ? _viewModel.BookletBranchID[0] : 1 %>" />
                            <input type="number" name="BookletCount" maxlength="4" placeholder="請輸入本數" value="<%= _viewModel.BookletCount!=null && _viewModel.BookletCount.Length>0 ? _viewModel.BookletCount[0] : null %>" />
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">Enhanced 101</label>
                        <label class="input">
                            <i class="icon-append fa fa-sort-numeric-up"></i>
                            <input type="hidden" name="BookletBranchID" value="<%= _viewModel.BookletBranchID!=null && _viewModel.BookletBranchID.Length>1 ? _viewModel.BookletBranchID[1] : 2 %>" />
                            <input type="number" name="BookletCount" maxlength="4" placeholder="請輸入本數" value="<%= _viewModel.BookletCount!=null && _viewModel.BookletCount.Length>1 ? _viewModel.BookletCount[1] : null %>" />
                        </label>
                    </section>
                    <section class="col col-4">
                        <label class="label">忠孝</label>
                        <label class="input">
                            <i class="icon-append fa fa-sort-numeric-up"></i>
                            <input type="hidden" name="BookletBranchID" value="<%= _viewModel.BookletBranchID!=null && _viewModel.BookletBranchID.Length>2 ? _viewModel.BookletBranchID[2] : 3 %>" />
                            <input type="number" name="BookletCount" maxlength="4" placeholder="請輸入本數" value="<%= _viewModel.BookletCount!=null && _viewModel.BookletCount.Length>2 ? _viewModel.BookletCount[2] : null %>" />
                        </label>
                    </section>
                </div>
            </fieldset>
        </form>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i>  編輯發票號碼</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
                "class": "btn btn-primary",
                click: function () {
                    if (confirm("請再次確認字軌與號碼資料正確?")) {
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
                                        $('#<%= _dialog %>').dialog('close');
                                        inquireInterval(null, data.GroupID);
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
    String _dialog = "noInterval" + DateTime.Now.Ticks;
    InvoiceNoViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (InvoiceNoViewModel)ViewBag.ViewModel;
    }

</script>
