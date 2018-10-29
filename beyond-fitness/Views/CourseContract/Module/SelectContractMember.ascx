<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="編輯學員資料" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("InquireContractMember","CourseContract",new { referenceUID = (int?)ViewBag.ReferenceUID }) %>" class="smart-form" method="post" autofocus>
            <fieldset class="fieldQuery">
                <div class="row">
                    <section class="col col-8">
                        <label class="input">
                            <i class="icon-append fa fa-search"></i>
                            <input type="text" name="userName" maxlength="20" placeholder="請輸入學員姓名" />
                        </label>
                    </section>
                    <section class="col col-4">
                        <button class="btn bg-color-blue btn-sm" name="btnQuery" type="button">查詢</button>
                    </section>
                </div>
                <div class="row learnerSelector">
                </div>
            </fieldset>
        </form>
    </div>
    <script>

        $(function () {

            $('#<%= _dialog %>').dialog({
                //autoOpen: false,
                width: "auto",
                resizable: false,
                modal: true,
                title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 編輯學員資料</h4></div>",
                close: function () {
                    $('#<%= _dialog %>').remove();
                }
            });

            function prepareLearner() {

                $('#<%= _dialog %> input[name="UID"]').on('click', function (evt) {
                    var event = event || window.event;
                    showLoading();
                    $.post('<%= Url.Action("EditContractMember","CourseContract",new { _viewModel.ContractType }) %>', { 'uid': $(event.target).val() }, function (data) {
                        hideLoading();
                        $('#<%= _dialog %>').dialog('close');
                        $(data).appendTo($('body'));
                    });
                });

                $('#<%= _dialog %> input[name="referenceUID"]').on('click', function (evt) {
                    var event = event || window.event;
                    showLoading();
                    $.post('<%= Url.Action("EditContractMember","CourseContract") %>', { 'referenceUID': $(event.target).val() }, function (data) {
                        hideLoading();
                        $('#<%= _dialog %>').dialog('close');
                        $(data).appendTo($('body'));
                    });
                });
            }

            $('#<%= _dialog %> button[name="btnQuery"]').on('click', function (evt) {
                var $form = $('#<%= _dialog %> form');
                $form.ajaxSubmit({
                    success: function (data) {
                        $('#<%= _dialog %> div.learnerSelector').html(data);
                        prepareLearner();
                    }
                });
            });

        });

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "contractMember" + DateTime.Now.Ticks;
    CourseContractViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (CourseContractViewModel)ViewBag.ViewModel;
    }

</script>
