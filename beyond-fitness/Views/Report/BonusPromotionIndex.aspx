<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage2017.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <span class="ribbon-button-alignment">
        <span id="refresh" class="btn btn-ribbon">
            <i class="fa fa-gift"></i>
        </span>
    </span>
    <!-- breadcrumb -->
    <ol class="breadcrumb">
        <li>Beyond幣累積兌換表</li>
    </ol>
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">
        <article class="col-sm-12 col-md-12 col-lg-12">
            <!-- new widget -->
            <div class="jarviswidget jarviswidget-color-darken" id="wid-id-4" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false" data-widget-fullscreenbutton="false">
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
                    <span class="widget-icon"><i class="fa fa-search txt-color-white"></i></span>
                    <h2>查詢條件 </h2>
                    <!-- <div class="widget-toolbar">
                                  add: non-hidden - to disable auto hide
                                  
                                  </div>-->
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
                        <form action="<%= Url.Action("ListBonusPromotion","Report") %>" method="post" id="queryForm" class="smart-form">
                            <fieldset>
                                <div class="row">
                                    <section class="col col-xs-12 col-sm-4 col-md-4">
                                        <label class="label">依體能顧問查詢</label>
                                        <label class="select">
                                            <select name="ActorID" class="input">
                                                <option value="">全部</option>
                                                <%  Html.RenderPartial("~/Views/SystemInfo/ServingCoachOptions.cshtml", models.GetTable<ServingCoach>()); %>
                                            </select>
                                            <i class="icon-append far fa-keyboard"></i>
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-4 col-md-4">
                                        <label class="label">或依學員姓名(暱稱)查詢</label>
                                        <label class="input input-group">
                                            <i class="icon-append fa fa-user"></i>
                                            <input type="text" name="UserName" class="form-control input" maxlength="20" placeholder="請輸入學員姓名"/>
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-4 col-md-4">
                                            <label class="label">類別</label>
                                            <label class="select">
                                               <select class="input" name="queryType" onchange="window.location.href = $(this).val();">
                                                  <option value="<%= Url.Action("BonusPromotionIndex","Report") %>" selected="selected">累積紀錄</option>
                                                  <option value="<%= Url.Action("BonusAwardList","Report") %>">兌換紀錄</option>
                                               </select>
                                               <i class="icon-append fa fa-gift"></i>
                                            </label>
                                    </section>   
                                </div>
                            </fieldset>
                            <fieldset>
                                <label class="label"><i class="fa fa-tags"></i>更多查詢條件</label>
                                <div class="row">
                                    <section class="col col-xs-12 col-sm-12 col-md-12">
                                        <label class="label">依Beyond幣區間查詢</label>
                                        <label class="select">
                                            <select class="input" name="PointRange">
                                                <option value="">全部</option>
                                                <option value="1,20" data-lower="1" data-upper="20">1-20</option>
                                                <option value="21,40" data-lower="21" data-upper="40">21-40</option>
                                                <option value="41,60" data-lower="41" data-upper="60">41-60</option>
                                                <option value="61,80" data-lower="61" data-upper="80">61-80</option>
                                                <option value="81,100" data-lower="81" data-upper="100">81-100</option>
                                                <option value="101,-1" data-lower="101" >101以上</option>
                                            </select>
                                            <i class="icon-append fa fa-gift"></i>
                                        </label>
                                    </section>
                                </div>
                            </fieldset>
                            <footer>
                                <button type="button" id="btnSend" class="btn btn-primary">
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
    </div>
    <!-- row -->
    <div class="row" id="bonusList">
    </div>

    <script>

        $('#btnSend').on('click', function (evt) {

            var $formData = $('#queryForm').serializeObject();
            var $opt = $('#queryForm select[name="PointRange"] option:selected');
            $formData.lower = $opt.attr('data-lower');
            $formData.upper = $opt.attr('data-upper');
            
            clearErrors();
            showLoading();
            $.post('<%= Url.Action("ListBonusPromotion","Report") %>', $formData, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    alert(data.message);
                } else {
                    $('#bonusList').empty()
                        .append(data);
                }
            });
        });

    function listLearnerBonus(keyID) {
        showLoading();
        $.post('<%= Url.Action("ListLearnerBonus", "Report") %>', { 'keyID': keyID }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }

    </script>

</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _userProfile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _userProfile = Context.GetUser();
    }

</script>
