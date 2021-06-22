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
                        <form action="<%= Url.Action("ListBonusAward","Report") %>" method="post" id="search-form" class="smart-form">
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
                                                  <option value="<%= Url.Action("BonusPromotionIndex","Report") %>">累積紀錄</option>
                                                  <option value="<%= Url.Action("BonusAwardList","Report") %>" selected="selected">兌換紀錄</option>
                                               </select>
                                               <i class="icon-append fa fa-gift"></i>
                                            </label>
                                    </section>   
                                </div>
                            </fieldset>
                            <fieldset>
                                <label class="label"><i class="fa fa-tags"></i>更多查詢條件</label>
                                <div class="row">
                                    <section class="col col-xs-12 col-sm-4 col-md-4">
                                        <label class="label">或依兌換商品查詢</label>
                                        <label class="select">
                                            <select name="ItemID" class="input">
                                                <option value="">全部</option>
                                                <%  foreach (var item in models.GetTable<BonusAwardingItem>().OrderBy(b => b.OrderIndex))
                                                    { %>
                                                <option value="<%= item.ItemID %>"><%= item.ItemName %></option>
                                                <%  } %>                                                
                                            </select>
                                            <i class="icon-append fa fa-gift"></i>
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-6 col-md-4">
                                        <label class="label">請選擇兌換起日</label>
                                        <label class="input">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <%  var dateFrom = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1); %>
                                            <input type="text" name="DateFrom" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value="<%= String.Format("{0:yyyy/MM/dd}",dateFrom) %>" />
                                        </label>
                                    </section>
                                    <section class="col col-xs-12 col-sm-6 col-md-4">
                                        <label class="label">請選擇兌換迄日</label>
                                        <label class="input">
                                            <i class="icon-append far fa-calendar-alt"></i>
                                            <input type="text" name="DateTo" readonly="readonly" class="form-control date form_date" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" value="<%= String.Format("{0:yyyy/MM/dd}",dateFrom.AddMonths(1).AddDays(-1)) %>" />
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

            var form = $(this)[0].form;

            clearErrors();
            showLoading();
            $($(this)[0].form).ajaxSubmit({
                success: function (data) {
                    hideLoading();
                    $('#bonusList').empty();
                    $(data).appendTo($('#bonusList'));
                }
            });
        });

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
