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

<div id="<%= _dialog %>" title="新增業績分潤金額" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitToApplyCoachAchievement","Payment",new { _model.PaymentID }) %>" class="smart-form" method="post" autofocus>
            <fieldset>
                <div class="row">
                    <section class="col col-6">
                        <label class="label">體能顧問</label>
                        <label class="select">
                            <select name="CoachID">
                                <option value="">請選擇體能顧問</option>
                                <%  var assignedItems = models.GetTable<TuitionAchievement>().Where(p => p.InstallmentID == _model.PaymentID)
                                        .Select(i => i.CoachID);
                                    Html.RenderPartial("~/Views/SystemInfo/ServingCoachOptions.cshtml", models.GetTable<ServingCoach>().Where(s => !assignedItems.Contains(s.CoachID))); %>
                            </select>
                            <i class="icon-append far fa-keyboard"></i>
                        </label>
                    </section>
                    <section class="col col-6">
                        <label class="label">業績分潤金額</label>
                        <label class="input">
                            <i class="icon-append fa fa-dollar-sign"></i>
                            <input type="number" name="ShareAmount" maxlength="10" placeholder="請輸入業績分潤金額" value="<%= _viewModel.ShareAmount %>"/>
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
            title: "<div class='modal-title'><h4><i class='fa fa-add'></i>  新增業績分潤金額</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
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
                                    alert('業績分潤金額已新增!!');
                                    $('#<%= _dialog %>').dialog('close');
                                    $global.loadCoachAchievement();
                                } else {
                                    alert(data.message);
                                }
                            } else {
                                $(data).appendTo($('body')).remove();
                            }
                        }
                    });
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
    String _dialog = "acheivement" + DateTime.Now.Ticks;
    Payment _model;
    PaymentViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (Payment)this.Model;
        _viewModel = (PaymentViewModel)ViewBag.ViewModel;
    }

</script>
