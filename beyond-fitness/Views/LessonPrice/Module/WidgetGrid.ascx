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
                        <form id="queryForm" action="<%= Url.Action("InquireLessonPrice","LessonPrice") %>" method="post" class="smart-form">
                            <fieldset>
                                <div class="row">
                                    <section class="col col-4">
                                        <label class="label">請選擇分店</label>
                                        <label class="select">
                                            <select class="input" name="BranchID">
                                                <option value="">全部</option>
                                                <%  Html.RenderPartial("~/Views/SystemInfo/BranchStoreOptions.cshtml", model: -1);    %>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label class="label">請選擇價格適用年份</label>
                                        <label class="select">
                                            <select class="input" name="Year">
                                                <option value="">全部</option>
                                                <%  for (var year = DateTime.Today.Year + 1; year >= 2014; year--)
                                                    { %>
                                                <option><%= year %></option>
                                                <%  } %>
                                            </select>
                                            <i class="icon-append far fa-clock"></i>
                                        </label>
                                    </section>
                                    <section class="col col-4">
                                        <label class="label">狀態</label>
                                        <label class="select">
                                            <select class="input" name="Status">
                                                <option value="">全部</option>
                                                <option value="0">已停用</option>
                                                <option value="1">生效中</option>
                                            </select>
                                            <i class="icon-append far fa-clock"></i>
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <footer>
                                <button type="button" name="submit" class="btn btn-primary" onclick="inquirePrice();">
                                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
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
                    <h2>標準價目清單</h2>
                    <div class="widget-toolbar">
                        <a onclick="$global.editPriceSeries();" class="btn btn-primary"><i class="fa fa-fw fa-plus"></i>新增價目</a>
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
                    <div class="widget-body bg-color-darken txt-color-white no-padding" id="priceList">
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
                    <h2>專案價目清單</h2>
                    <div class="widget-toolbar">
                        <a onclick="$global.editProjectCourse();" class="btn btn-primary modifyProjectPriceDialog_link"><i class="fa fa-fw fa-plus"></i>新增價目</a>
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
                    <div class="widget-body bg-color-darken txt-color-white no-padding" id="courseList">
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

        $global.renderProjectCourse = function () {
            var $form = $('#queryForm');
            showLoading();
            $.post('<%= Url.Action("InquireProjectCourse","LessonPrice") %>', $form.serialize(), function (data) {
                hideLoading();
                $('#courseList').empty()
                    .append($(data));
            });
        };

        $global.editProjectCourse = function (priceID) {
            startLoading();
            $.post('<%= Url.Action("EditProjectCourse","LessonPrice") %>', { 'priceID': priceID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        };

        $global.renderPriceSeries = function () {
            var $form = $('#queryForm');
            showLoading();
            $.post('<%= Url.Action("InquirePriceSeries","LessonPrice") %>', $form.serialize(), function (data) {
                hideLoading();
                $('#priceList').empty()
                    .append($(data));
            });
        };

        $global.editPriceSeries = function (seriesID) {
            startLoading();
            $.post('<%= Url.Action("EditPriceSeries","LessonPrice") %>', { 'seriesID': seriesID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        };

        inquirePrice();
                
    });

    function inquirePrice() {
        //var event = event || window.event;
        //var $form = $(event.target).closest('form');
        var $form = $('#queryForm');

        showLoading();
        $.post('<%= Url.Action("InquirePriceSeries","LessonPrice") %>', $form.serialize(), function (data) {
            hideLoading();
            $('#priceList').empty()
                .append($(data));
        });

        $.post('<%= Url.Action("InquireProjectCourse","LessonPrice") %>', $form.serialize(), function (data) {
            hideLoading();
            $('#courseList').empty()
                .append($(data));
        });
    }

    function deletePrice(priceID) {
        if (confirm('確定刪除此價目項次?')) {
            var event = event || window.event;
            startLoading();
            $.post('<%= Url.Action("DeleteLessonPrice","LessonPrice") %>', { 'priceID': priceID }, function (data) {
                hideLoading();
                if (data.result) {
                    var $a = $(event.target).closest('a');
                    if (data.message) {
                        alert(data.message);
                        $a.closest('td').prev().text('已停用');
                        $a.remove();
                    } else {
                        alert('價目已刪除!!');
                        $a.closest('tr').remove();
                    }
                } else {
                    alert(data.message);
                }
            });
        }
    }

    function deletePriceSeries(seriesID) {
        if (confirm('確定刪除此標準價目?')) {
            var event = event || window.event;
            startLoading();
            $.post('<%= Url.Action("DeletePriceSeries","LessonPrice") %>', { 'seriesID': seriesID }, function (data) {
                hideLoading();
                if (data.result) {
                    var $a = $(event.target).closest('a');
                    if (data.message) {
                        alert(data.message);
                        $a.closest('td').prev().text('已停用');
                        $a.remove();
                    } else {
                        alert('價目已刪除!!');
                        $a.closest('tr').remove();
                    }
                } else {
                    alert(data.message);
                }
            });
        }
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();
    }

</script>
