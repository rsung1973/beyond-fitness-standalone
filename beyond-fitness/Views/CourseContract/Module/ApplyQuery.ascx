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
                    <span class="widget-icon"><i class="fa fa-search"></i></span>
                    <h2>查詢條件</h2>
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
                        <form action="<%= Url.Action("InquireContractForAmendment","CourseContract") %>" method="post" id="search-form" class="smart-form">
                            <fieldset>
                                <div class="row">
                                    <section class="col col-6">
                                        <label class="label">依學員姓名(暱稱)查詢</label>
                                        <label class="input input-group">
                                            <i class="icon-append fa fa-user"></i>
                                            <input type="text" name="RealName" class="form-control input" maxlength="20" placeholder="請輸入學員姓名"/>
                                        </label>
                                    </section>
                                    <section class="col col-6">
                                        <label class="label">或依合約編號查詢</label>
                                        <label class="input input-group">
                                            <i class="icon-append far fa-copy"></i>
                                            <input type="text" name="ContractNo" class="form-control input" maxlength="20" placeholder="請輸入合約編號"/>
                                        </label>
                                    </section>                                
                                </div>
                            </fieldset>
                            <footer>
                                <button onclick="inquireContract();" type="button" name="btnSend" class="btn btn-primary">
                                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                                </button>
                                <button type="reset" name="cancel" class="btn btn-default">
                                    清除 <i class="fa fa-undo" aria-hidden="true"></i>
                                </button>
                            </footer>
                        </form>
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
                    <h2>合約列表</h2>
                </header>
                <!-- widget div-->
                <div>
                    <!-- widget edit box -->
                    <div class="jarviswidget-editbox">
                        <!-- This area used as dropdown edit box -->
                    </div>
                    <!-- end widget edit box -->
                    <!-- widget content -->
                    <div class="widget-body bg-color-darken txt-color-white no-padding" id="contractList">
                        <%  Html.RenderPartial("~/Views/CourseContract/Module/ContractQueryAmendmentList.ascx", models.GetTable<CourseContract>().Where(f => false)); %>
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
    function inquireContract() {
        var event = event || window.event;
        var $form = $(event.target).closest('form');
        $form.ajaxSubmit({
            beforeSubmit: function () {
                showLoading();
            },
            success: function (data) {
                hideLoading();
                $('#contractList').empty()
                    .append($(data));
            }
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
