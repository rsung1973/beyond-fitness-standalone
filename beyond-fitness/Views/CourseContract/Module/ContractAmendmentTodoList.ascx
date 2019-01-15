<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="待辦事項：服務申請(<%= _viewModel.Status==(int)Naming.CourseContractStatus.待確認 ? "待審核" : ((Naming.CourseContractStatus?)_viewModel.Status).ToString() %>)" class="bg-color-darken">
    <!-- content -->
    <table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%">
        <thead>
            <tr>
                <th data-hide="phone">體能顧問</th>
                <th data-class="expand">學員</th>
                <th>編輯日期</th>
                <th>申請項目</th>
            </tr>
        </thead>
        <tbody>
            <%  foreach (var r in _model)
                {
                    var item = r.CourseContract;%>
            <tr>
                <td><%= item.ServingCoach.UserProfile.FullName() %></td>
                <td>
                    <%  if (r.SourceContract.CourseContractType.IsGroup==true)
                        { %>
                <%= String.Join("/",r.SourceContract.CourseContractMember.Select(m=>m.UserProfile).ToArray().Select(u=>u.FullName())) %>
                    <%  }
                        else
                        { %>
                <%= r.SourceContract.ContractOwner.FullName() %>
                    <%  } %>
                </td>
                <td><%= String.Format("{0:yyyy/MM/dd}", item.ContractDate) %></td>
                <td>
                    <%  if(_viewModel.Status == (int)Naming.CourseContractStatus.待確認)
                        {   %>
                    <a onclick="$global.openToApproveAmendment(<%= r.RevisionID %>);" class="btn btn-circle bg-color-red"><i class="far fa-fw fa-lg fa-check-square" aria-hidden="true"></i></a>
                    <%  }
                        else if(_viewModel.Status == (int)Naming.CourseContractStatus.待簽名)
                        {   %>
                    <a onclick="$global.openToSignAmendment(<%= r.RevisionID %>);" class="btn btn-circle bg-color-green"><i class="fa fa-fw fa fa-lg fa-pencil-alt" aria-hidden="true"></i></a>
                    <%  }
                        else if(_viewModel.Status == (int)Naming.CourseContractStatus.待審核)
                        {   %>
                    <a href="<%= Url.Action("GetContractAmendmentPdf","CourseContract",new { r.RevisionID }) %>" target="_blank" class="btn btn-circle bg-color-green"><i class="far fa-fw fa-lg fa-copy" aria-hidden="true"></i></a>
                    <a onclick="$global.enableAmendment(<%= r.RevisionID %>);" class="btn btn-circle bg-color-red"><i class="far fa-fw fa-lg fa-check-square" aria-hidden="true"></i></a>
                    <%  } %>
                    <%= r.Reason %>
                </td>
            </tr>
            <%  } %>
        </tbody>
    </table>
    <!-- end content -->
    <script>

        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-list-ol'></i>  待辦事項：服務申請(<%= _viewModel.Status==(int)Naming.CourseContractStatus.待確認 ? "待審核" : ((Naming.CourseContractStatus?)_viewModel.Status).ToString() %>)</h4>",
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });

        $(function () {
            var responsiveHelper_<%= _tableId %> = undefined;

            var responsiveHelper_datatable_fixed_column = undefined;
            var responsiveHelper_datatable_col_reorder = undefined;
            var responsiveHelper_datatable_tabletools = undefined;

            var breakpointDefinition = {
                tablet: 1024,
                phone: 480
            };

            $('#<%= _tableId %>').dataTable({
                //"bPaginate": false,
                "pageLength": 30,
                "lengthMenu": [[30, 50, 100, -1], [30, 50, 100, "全部"]],
                "searching": true,
                "ordering": true,
                "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l>r>" +
                         "t" +
                         "<'dt-toolbar-footer'<'col-sm-6 col-xs-12 hidden-xs'i><'col-xs-12 col-sm-6'p>>",
                "autoWidth": true,
                "paging": true,
                "info": true,
                "order": [[3, "desc"]],
                "oLanguage": {
                    "sSearch": '<span class="input-group-addon"><i class="glyphicon glyphicon-search"></i></span>'
                },
                "preDrawCallback": function () {
                    // Initialize the responsive datatables helper once.
                    if (!responsiveHelper_<%= _tableId %>) {
                        responsiveHelper_<%= _tableId %> = new ResponsiveDatatablesHelper($('#<%= _tableId %>'), breakpointDefinition);
                    }
                },
                "rowCallback": function (nRow) {
                    responsiveHelper_<%= _tableId %>.createExpandIcon(nRow);
                },
                "drawCallback": function (oSettings) {
                    responsiveHelper_<%= _tableId %>.respond();
                }
            });

            $global.openToApproveAmendment = function (revisionID) {
                $('#<%= _dialog %>').dialog('close');
                window.open('<%= Url.Action("ContractAmendmentApprovalView","CourseContract") %>' + '?revisionID=' + revisionID, '_blank', 'fullscreen=yes');
                smartAlert('合約審核中...', function () {
                    //showLoading();
                    window.location.href = '<%= Url.Action("Index","CoachFacet",new { showTodoTab = true }) %>';
                });
            };

            $global.openToSignAmendment = function (revisionID) {
                $('#<%= _dialog %>').dialog('close');
                window.open('<%= Url.Action("ContractAmendmentSignatureView","CourseContract") %>' + '?revisionID=' + revisionID, '_blank', 'fullscreen=yes');
                smartAlert('簽名進行中...', function () {
                    //showLoading();
                    window.location.href = '<%= Url.Action("Index","CoachFacet",new { showTodoTab = true }) %>';
                });

            };

            $global.enableAmendment = function (revisionID) {
                var event = event || window.event;
                var $a = $(event.target);
                if (!$a.is('a')) {
                    $a = $a.closest('a');
                }
                showLoading();
                $.post('<%= Url.Action("EnableContractAmendment","CourseContract",new { Status = (int)Naming.CourseContractStatus.已生效 }) %>', { 'revisionID': revisionID }, function (data) {
                    hideLoading();
                    if (data.result) {
                        alert('合約已生效!!');
                        $a.closest('td').prev().text('已生效');
                        $a.remove();
                    } else {
                        $(data).appendTo($('body')).remove();
                    }
                });
            };

        });

    </script>
</div>



<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "dt_contractTodo" + DateTime.Now.Ticks;
    IQueryable<CourseContractRevision> _model;
    String _dialog = "draftContractlist" + DateTime.Now.Ticks;
    CourseContractViewModel _viewModel;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<CourseContractRevision>)this.Model;
        _viewModel = (CourseContractViewModel)ViewBag.ViewModel;

    }

</script>
