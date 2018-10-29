<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="Sign Here" class="bg-color-darken">
    <div id="signatureparent">
        <div id="signature"></div>
    </div>
    <script>

        $(function () {

            var $sigdiv;

            $('#<%= _dialog %>').dialog({
                //autoOpen: false,
                width: "100%",
                resizable: false,
                modal: true,
                title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> Sign Here</h4></div>",
                buttons: [{
                    html: "<i class='far fa-save'></i>&nbsp; 清除",
                    "class": "btn bg-color-darken",
                    click: function () {
                        $sigdiv.jSignature('reset');
                    }
                }, {
                    html: "<i class='far fa-copy'></i>&nbsp; 確定",
                    "class": "btn btn-primary",
                    click: function () {
                        //showLoading();
                        var sigData = $sigdiv.jSignature("getData");
                        if (sigData) {
                            $.post('<%= Url.Action("CommitSignature","CourseContract",_viewModel) %>', { 'Signature': sigData }, function (data) {
                                //hideLoading();
                                if (data.result) {
                                    $signatureImage[0].src = sigData;
                                    $('#<%= _dialog %>').dialog("close");
                                }
                            });
                        }
                    }
                }],
                create: function (event, ui) {

                },
                open: function (event, ui) {
                    $("#signature").empty();
                    $sigdiv = $("#signature").jSignature({ 'UndoButton': true });
                },
                close: function () {
                    $('#<%= _dialog %>').remove();
                }
            });
        });
    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "signaturePanel" + DateTime.Now.Ticks;
    CourseContractSignatureViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (CourseContractSignatureViewModel)ViewBag.ViewModel;

    }

</script>
