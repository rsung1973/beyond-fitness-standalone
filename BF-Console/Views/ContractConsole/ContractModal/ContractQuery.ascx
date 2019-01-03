<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json"  %>
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog" aria-labelledby="exampleModalLongTitle" aria-hidden="true">
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
                                <form>
                                    <div class="row clearfix">
                                        <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                                            <div class="input-group">
                                                <input type="text" name="RealName" class="form-control form-control-danger" placeholder="學生姓名(暱稱)" />
                                                <span class="input-group-addon">
                                                    <i class="zmdi zmdi-search"></i>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                                            <div class="input-group">
                                                <input type="text" name="ContractNo" class="form-control form-control-danger" placeholder="合約編號" />
                                                <span class="input-group-addon">
                                                    <i class="zmdi zmdi-search"></i>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                                            <div class="input-group">
                                                <input type="text" class="form-control date" name="ContractDateFrom" data-date-format="yyyy/mm/dd" readonly="readonly" placeholder="合約起日" value="" />
                                                <span class="input-group-addon xl-slategray">
                                                    <i class="zmdi zmdi-time"></i>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="col-lg-6 col-md-6 col-sm-6 col-12">
                                            <div class="input-group">
                                                <input type="text" class="form-control date" name="ContractDateTo" data-date-format="yyyy/mm/dd" readonly="readonly" placeholder="合約迄日" value="" />
                                                <span class="input-group-addon xl-slategray">
                                                    <i class="zmdi zmdi-time"></i>
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-darkteal btn-round waves-effect"><i class="zmdi zmdi-search-for"></i></button>
            </div>
        </div>
    </div>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
    <script>
        $(function () {
            $('.date').datetimepicker({
                language: 'zh-TW',
                weekStart: 1,
                todayBtn: 1,
                clearBtn: 1,
                autoclose: 1,
                todayHighlight: 1,
                startView: 2,
                minView: 2,
                defaultView: 2,
                forceParse: 0,
                defaultDate: '<%= String.Format("{0:yyyy-MM-dd}",DateTime.Today) %>',
            });

            var viewModel = <%= JsonConvert.SerializeObject(_viewModel) %>;
            $('#<%= _dialogID %> button').on('click', function (event) {
                var $formData = $('#<%= _dialogID %> form').serializeObject();
                $global.queryCallback = function () {
                    $global.closeAllModal();
                };
                showContractList($.extend({}, viewModel, $formData), -1);
            });
        });
    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractQueryViewModel _viewModel;
    String _dialogID = $"contractQuery{DateTime.Now.Ticks}";
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (CourseContractQueryViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser();

        if (_profile.IsAssistant() || _profile.IsOfficer())
        {
            _viewModel.OfficerID = _profile.UID;
        }
        else if (_profile.IsManager() || _profile.IsViceManager())
        {
            _viewModel.ManagerID = _profile.UID;
        }
        else
        {
            _viewModel.FitnessConsultant = _profile.UID;
        }
    }


</script>
