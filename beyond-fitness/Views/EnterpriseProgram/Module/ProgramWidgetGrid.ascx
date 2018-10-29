<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<section id="widget-grid" class="">
    <!-- row -->
    <div class="row">
        <!-- NEW WIDGET START -->
        <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget jarviswidget-color-darken" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
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
                    <h2>合作方案列表</h2>
                    <div class="widget-toolbar">
                        <a onclick="$global.editEnterpriseContract();" class="btn btn-primary listProjectDialog_link"><i class="fa fa-fw fa-plus"></i>新增合作方案</a>
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
                        <%  Html.RenderPartial("~/Views/EnterpriseProgram/Module/EnterpriseProgramList.ascx", models.GetTable<EnterpriseCourseContract>()); %>
                    </div>
                    <!-- end widget content -->
                </div>
                <!-- end widget div -->
            </div>
            <!-- end widget -->
        </article>
        <!-- WIDGET END -->
    </div>
    <!-- end row -->
</section>

<script>

    $(function () {

        $global.editEnterpriseContract = function (contractID) {
            showLoading();
            $.post('<%= Url.Action("EditEnterpriseContract","EnterpriseProgram") %>', { 'contractID': contractID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        };
    });

    function showEnterpriseMember(contractID) {
        showLoading();
        $.post('<%= Url.Action("ListMember","EnterpriseProgram") %>', { 'contractID': contractID }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }

    function showEnterprisePayment(contractID) {
        showLoading();
        $.post('<%= Url.Action("EnterprisePaymentList","EnterpriseProgram") %>', { 'contractID': contractID }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }

    function editEnterpriseContract(contractID) {
        showLoading();
        $.post('<%= Url.Action("EditEnterpriseContract","EnterpriseProgram") %>', { 'contractID': contractID }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;
    CourseContractQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();
        _viewModel = (CourseContractQueryViewModel)ViewBag.ViewModel;
    }

</script>
