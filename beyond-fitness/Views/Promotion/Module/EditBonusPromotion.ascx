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

<div id="<%= _dialogID %>" title="設定活動" class="bg-color-darken">
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
            <h2>活動詳細內容</h2>
            <div class="widget-toolbar">
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
                <form action="#" class="smart-form" autofocus>
                    <fieldset>
                        <section>
                            <label class="label">活動名稱</label>
                            <label class="input">
                                <i class="icon-append fa fa-font"></i>
                                <input type="text" name="GroupName" maxlength="200" value="<%: _viewModel.GroupName %>" placeholder="請輸入活動名稱" />
                            </label>
                        </section>
                    </fieldset>
                    <fieldset>
                        <div class="row">
                            <section class="col col-6">
                                <label class="label">活動起日</label>
                                <label class="input input-group">
                                    <i class="icon-append far fa-calendar-alt"></i>
                                    <input type="text" class="form-control date form_date" value="<%= String.Format("{0:yyyy/MM/dd}", _viewModel.StartDate??DateTime.Today) %>" readonly="readonly" data-date-format="yyyy/mm/dd" placeholder="請選擇活動起日" name="StartDate" />
                                </label>
                            </section>
                            <section class="col col-6">
                                <label class="label">活動迄日</label>
                                <label class="input input-group">
                                    <i class="icon-append far fa-calendar-alt"></i>
                                    <input type="text" class="form-control date form_date" value="<%= String.Format("{0:yyyy/MM/dd}", _viewModel.EndDate) %>" readonly="readonly" data-date-format="yyyy/mm/dd" placeholder="請選擇活動迄日" name="EndDate" />
                                </label>
                            </section>
                        </div>
                    </fieldset>
                    <fieldset>
                        <section>
                            <label class="label">活動說明</label>
                            <label class="input">
                                <textarea class="form-control" placeholder="請輸入活動說明" rows="3" name="Question"><%: _viewModel.Question %></textarea>
                            </label>
                        </section>
                    </fieldset>
                    <fieldset>
                        <section>
                            <label class="label">贈送點數</label>
                            <label class="input">
                                <i class="icon-append fa fa-gift"></i>
                                <input type="number" name="BonusPoint" maxlength="3" placeholder="請輸入點數" value="<%: _viewModel.BonusPoint %>" />
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
        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 設定活動方案內容</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {
                    var $form = $('#<%= _dialogID %> form');
                    var $formData = $form.serializeObject();
                    clearErrors();
                    showLoading();
                    $.post('<%= Url.Action("CommitBonusPromotion", "Promotion", new { KeyID = _viewModel.GroupID.HasValue ? _viewModel.GroupID.Value.EncryptKey() : null }) %>', $formData, function (data) {
                        hideLoading();
                        if ($.isPlainObject(data)) {
                            if (data.result) {
                                alert('設定完成!!');
                                $('#<%= _dialogID %>').dialog('close');
                                listPromotion();
                            } else {
                                alert(data.message);
                            }
                        } else {
                            $(data).appendTo($('body'));
                        }
                    });
                }
            }],
            close: function () {
                $('#<%= _dialogID %>').remove();
            },
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

    </script>
</div>



<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PromotionViewModel _viewModel;
    String _dialogID = "promotion" + DateTime.Now.Ticks;
    UserProfile _profile;
    PDQGroup _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (PDQGroup)this.Model;
        _viewModel = (PromotionViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser().LoadInstance(models);
    }

</script>
