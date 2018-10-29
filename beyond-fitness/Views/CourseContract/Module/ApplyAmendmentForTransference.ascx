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

<div>
    <fieldset>
        <div class="row">
            <section class="col col-8">
                <label class="input">
                    <i class="icon-append fa fa-search"></i>
                    <input type="text" name="userName" maxlength="20" placeholder="請輸入學員姓名" />
                </label>
            </section>
            <section class="col col-2">
                <button onclick="inquireContractMember();" class="btn bg-color-blue btn-sm" type="button">查詢</button>
            </section>
            <script>
                function inquireContractMember() {
                    showLoading();
                    $.post('<%= Url.Action("InquireContractMember","CourseContract") %>', { 'userName': $('input[name="userName"]').val() }, function (data) {
                        hideLoading();
                        $('div.learnerSelector').html(data);
                        prepareLearner();
                    });
                }

                function prepareLearner() {
                    $('input[name="UID"]').on('click', function (evt) {
                        var event = event || window.event;
                        showLoading();
                        $.post('<%= Url.Action("EditContractMember","CourseContract",new { _model.ContractType }) %>', { 'uid': $(event.target).val() }, function (data) {
                            hideLoading();
                            $(data).appendTo($('body'));
                        });
                    });
                }

                $(function () {
                    $global.addContractMember = function (uid, ownerID, realName) {
                        var $item = $('input[name="UID"]:checked');
                        if ($item.val() == '') {
                            $item.val(uid);
                        }
                        $('#transference').text('，全部轉讓至 ' + realName);
                    };
                });
            </script>
        </div>
        <div class="row learnerSelector">
        </div>
    </fieldset>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractViewModel _viewModel;
    CourseContract _model;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
    }

</script>
