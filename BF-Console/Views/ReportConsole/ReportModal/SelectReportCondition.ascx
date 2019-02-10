<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5>更多查詢條件</h5>
                <a class="closebutton" data-dismiss="modal"></a>
            </div>
            <div class="modal-body">
                <div class="row clearfix">
                    <div class="col-12">
                        <div class="card action_bar">
                            <div class="body">
                                <div class="row clearfix">
                                    <div class="col-12">
                                        <div class="input-group">
                                            <%  Html.RenderPartial((String)ViewBag.ConditionView, model:_dialogID); %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-darkteal btn-round waves-effect"><i class="zmdi zmdi-download"></i></button>
            </div>
        </div>
    </div>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
    <script>
        var <%= _dialogID %> = (function () {
            var _checkInputChain = function (inputData) {
                return true;
            };
            return {
                appendCheck: function (checkInput) {
                    var currentCheck = _checkInputChain;
                    _checkInputChain = function (inputData) {
                        return checkInput(inputData) && currentCheck(inputData);
                    };
                    this._checkInputChain = _checkInputChain;
                },
            };
        })();
        $(function () {
            var queryObject = <%= _dialogID %>;
            $('#<%= _dialogID %> button').on('click', function (event) {
                var inputData = $('#<%= _dialogID %> input,textarea,select').serializeObject();
                if ($global.doQuery) {
                    if (!queryObject._checkInputChain || queryObject._checkInputChain(inputData)) {
                        $('#<%= _dialogID %>').modal('hide');
                        $global.doQuery(inputData);
                    }
                }
            });
        });
    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialogID = $"reportQuery{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }


</script>
