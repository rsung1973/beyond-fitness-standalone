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
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog" aria-labelledby="exampleModalLongTitle" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <a class="closebutton" data-dismiss="modal"></a>
            <div id="signatureparent">
                <div id="signature"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-darkteal btn-round waves-effect" onclick="commitSignature();">確定，不後悔</button>
                <button type="button" class="btn btn-danger btn-round btn-simple btn-round waves-effect waves-red resign">重新簽名</button>
            </div>
        </div>
    </div>
    <script>

        $(function () {
            $('#<%= _dialogID %>').on('shown.bs.modal', function (e) {
                $("#signature").empty();
                $("#signature").jSignature({ 'UndoButton': true });
            });

            $("#<%= _dialogID %> button.resign").on('click', function (event) {
                $("#signature").jSignature('reset');
            });

        });

        function commitSignature() {
            var sigData = $("#signature").jSignature("getData");
            if (sigData) {
                $.post('<%= Url.Action("CommitSignature","CourseContract",_viewModel) %>', { 'Signature': sigData }, function (data) {
                    //hideLoading();
                    if (data.result) {
                        if ($global.commitSignature) {
                            $global.commitSignature(sigData);
                        }
                        $('#<%= _dialogID %>').modal('hide');
                    }
                });
            }
        }
        
    </script>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialogID = $"signature{DateTime.Now.Ticks}";
    CourseContractSignatureViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (CourseContractSignatureViewModel)ViewBag.ViewModel;
    }


</script>
