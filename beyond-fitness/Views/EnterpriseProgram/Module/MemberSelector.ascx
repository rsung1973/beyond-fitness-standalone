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

<div id="<%= _dialog %>" title="新增上課人員" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitMember","EnterpriseProgram", _viewModel) %>" method="post" class="smart-form" autofocus>
            <div>
                <fieldset>
                    <div class="row">
                        <section class="col col-8">
                            <label class="input">
                                <i class="icon-append fa fa-search"></i>
                                <input type="text" name="userName" maxlength="20" placeholder="請輸入學員姓名(暱稱)" />
                            </label>
                        </section>
                        <section class="col col-2">
                            <button id="btnAttendeeQuery" class="btn bg-color-blue btn-sm" type="button">查詢</button>
                        </section>
                    </div>
                    <div class="row">
                        <section id="attendeeSelector" class="col col-12">
                        </section>
                    </div>
                </fieldset>
            </div>
        </form>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-user-plus'></i> 新增上課學員</h4></div>",
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
                                    $('#<%= _dialog %>').dialog('close');
                                    listMember();
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

        $('#btnAttendeeQuery').on('click', function (evt) {
            var userName = $('input[name="userName"]').val();
            console.log('debug...');

            clearErrors();
            showLoading();

            $('#attendeeSelector').load('<%= Url.Action("VipSelector","CoachFacet") %>', { 'userName': userName,'forCalendar':true }, function (data) {
                hideLoading();
            });
            
        });
    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "memberSelector" + DateTime.Now.Ticks;
    EnterpriseGroupMemberViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (EnterpriseGroupMemberViewModel)ViewBag.ViewModel;
    }

</script>
