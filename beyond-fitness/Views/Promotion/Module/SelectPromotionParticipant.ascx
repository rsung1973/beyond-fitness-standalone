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

<div id="<%= _dialogID %>" title="新增贈送學員" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="#" class="smart-form" autofocus>
            <div>
                <fieldset>
                    <div class="row">
                        <section class="col col-8">
                            <label class="input">
                                <i class="icon-append fa fa-search"></i>
                                <input type="text" name="UserName" maxlength="20" id="searchStudentInput" placeholder="請輸入學員姓名" />
                            </label>
                        </section>
                        <section class="col col-2">
                            <button class="btn bg-color-blue btn-sm" onclick="<%= _dialogID %>.inquire();" type="button">查詢</button>
                        </section>
                    </div>
                    <div class="row">
                        <section class="col col-12 vipSelector">
                        </section>
                    </div>
                </fieldset>
            </div>
        </form>
    </div>
    <script>
        $('#<%= _dialogID %>').dialog({
            //autoOpen : false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 新增贈送學員</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {
                    var $formData = $('#<%= _dialogID %> form').serializeObject();
                    if (!$formData.UID) {
                        alert('請選擇贈送學員!!');
                        return;
                    }
                    clearErrors();
                    showLoading();
                    $.post('<%= Url.Action("CommitPromotionParticipant", "Promotion", new { KeyID = _model.GroupID.EncryptKey() }) %>', $formData, function (data) {
                        hideLoading();
                        if ($.isPlainObject(data)) {
                            if (data.result) {
                                alert('贈送學員新增完成!!');
                                $('#<%= _dialogID %>').dialog('close');
                                listParticipant();
                            } else {
                                alert(data.message);
                            }
                        } else {
                            $(data).appendTo($('body'));
                        }
                    });
                }
            }],
            close: function (event, ui) {
                $('#<%= _dialogID %>').remove();
            }
        });

        var <%= _dialogID %>;
        $(function () {
            var $form = $('#<%= _dialogID %> form');
            var viewModule = {
                inquire: function () {
                    var $formData = $form.serializeObject();
                    clearErrors();
                    showLoading();
                    $.post('<%= Url.Action("InquirePromotionParticipant", "Promotion", new { KeyID = _model.GroupID.EncryptKey() }) %>', $formData, function (data) {
                        hideLoading();
                        if ($.isPlainObject(data)) {
                            alert(data.message);
                        } else {
                            $('#<%= _dialogID %> .vipSelector').empty()
                                .append(data);
                        }
                    });
                },
            };
            <%= _dialogID %> = viewModule;
        });

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PromotionViewModel _viewModel;
    String _dialogID = $"user{DateTime.Now.Ticks}";
    PDQGroup _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (PDQGroup)this.Model;
        _viewModel = (PromotionViewModel)ViewBag.ViewModel;
    }

</script>
