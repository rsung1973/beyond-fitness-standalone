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
            <div class="jarviswidget jarviswidget-color-darken" id="wid-id-1" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
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
                    <h2>草稿列表</h2>
                    <div class="widget-toolbar">
                        <a onclick="editContract();" class="btn btn-primary modifyPersonalContractDialog_link"><i class="fa fa-fw fa-plus"></i>新增合約</a>
                    </div>
                </header>
                <script>
                    function editContract(contractID) {
                        showLoading();
                        $.post('<%= Url.Action("EditCourseContract","CourseContract") %>', { 'contractID': contractID }, function (data) {
                            hideLoading();
                            $(data).appendTo($('body'));
                        });
                    }
                    function deleteContract(contractID) {
                        if (confirm('確定刪除?')) {
                            var event = event || window.event;
                            showLoading();
                            $.post('<%= Url.Action("DeleteCourseContract","CourseContract") %>', { 'contractID': contractID }, function (data) {
                                hideLoading();
                                if (data.result) {
                                    $(event.target).closest('tr').remove();
                                }
                            });
                        }
                    }
                </script>
                <!-- widget div-->
                <div>
                    <!-- widget edit box -->
                    <div class="jarviswidget-editbox">
                        <!-- This area used as dropdown edit box -->
                    </div>
                    <!-- end widget edit box -->
                    <!-- widget content -->
                    <div id="contractList" class="widget-body bg-color-darken txt-color-white no-padding">
                        <%  Html.RenderPartial("~/Views/CourseContract/Module/ContractList.ascx", models.GetContractInEditingByAgent(_model)); %>
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

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }

</script>
