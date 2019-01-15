<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="input-group">
    <input type="text" class="form-control form-control-danger" onclick="listPrice();" placeholder="課程單價" name="PriceID" id="searchPrice" readonly />
    <span class="input-group-addon xl-slategray">
        <i class="zmdi zmdi-money-box"></i>
    </span>
</div>
<%--<label class="material-icons help-error-text">clear 請選擇課程單價</label>--%>

<script>

    $(function () {
        $global.commitPrice = function (priceID, priceName) {
            $global.viewModel.PriceID = priceID;
            $('#searchPrice').attr('placeholder', priceName);
            calcTotalCost();
        };
    });

    function listPrice() {
        clearErrors();
        showLoading();
        $.post('<%= Url.Action("ListLessonPrice", "ContractConsole") %>', $global.viewModel, function (data) {
            hideLoading();
            if ($.isPlainObject(data)) {
                alert(data.message);
            } else {
                $(data).appendTo($('body'));
            }
        });
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    String _viewID = $"lessonPrice{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
    }


</script>
