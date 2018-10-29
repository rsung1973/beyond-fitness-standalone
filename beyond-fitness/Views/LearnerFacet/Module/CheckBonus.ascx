<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="bonusDialog" title="點數兌換" class="bg-color-darken">
    <div id="awardDetails">
    <%  Html.RenderPartial("~/Views/LearnerFacet/Module/CheckBonusAward.ascx", _model); %>
    </div>
    <!-- dialog-message -->
    <!-- END MAIN CONTENT -->
    <script>

        $('#bonusDialog').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "100%",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-gift'></i>  點數兌換</h4>",
            close: function (event, ui) {
                $('#bonusDialog').remove();
            }
        });

        var bonusItemID;
        function awardingLessonGift(itemID) {
            bonusItemID = itemID;
            showLoading();
            $.post('<%= Url.Action("QueryRecipient","LearnerFacet") %>', {}, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        function exchangeBonus(itemID,recipientID) {
            if (confirm('確定兌換?')) {
                showLoading();
                $.post('<%= Url.Action("ExchangeBonusPoint","LearnerFacet",new { uid = _model.UID }) %>', { 'itemID': itemID,'recipientID':recipientID }, function (data) {
                    hideLoading();
                    if (data.result) {
                        $('#awardDetails').load('<%= Url.Action("CheckBonusAward","LearnerFacet",new { id = _model.UID }) %>', {}, function (d) { });
                        alert('兌換完成!!');
                    } else {
                        alert(data.message);
                    }
                });
            }
        }

    </script>
</div>

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
