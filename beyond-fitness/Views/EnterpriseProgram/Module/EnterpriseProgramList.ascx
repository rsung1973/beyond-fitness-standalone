<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%">
    <thead>
        <tr>
            <th data-class="expand">分店</th>
            <th>合約編號</th>
            <th>企業名稱</th>
            <th>統一編號</th>
            <th>合作方案說明</th>
            <th data-hide="phone">生效日期</th>
            <th>人數</th>
            <th>狀態</th>
            <th data-hide="phone">功能</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <td><%= item.BranchID.HasValue ? item.BranchStore.BranchName : null %></td>
            <td><%= item.ContractNo %></td>
            <td><%= item.Organization.CompanyName %></td>
            <td><%= item.Organization.ReceiptNo %></td>
            <td><%= item.Subject %></td>
            <td><%= String.Format("{0:yyyy/MM/dd}",item.ValidFrom) %></td>
            <td><%= item.EnterpriseCourseMember.Count %></td>
            <td>
                已生效
            </td>
            <td nowrap="noWrap">
                <a onclick="editEnterpriseContract(<%= item.ContractID %>);" class="btn btn-circle bg-color-yellow"><i class="fa fa-fw fa fa-lg fa-edit" aria-hidden="true"></i></a>&nbsp;&nbsp;
                <a onclick="showEnterpriseMember(<%= item.ContractID %>);" class="btn btn-circle btn-primary listAttendantDialog_link"><i class="fa fa-fw fa fa-lg fa-user-plus" aria-hidden="true"></i></a>&nbsp;&nbsp;
                                         <%--<a href="#" class="btn btn-circle bg-color-green"><i class="far fa-fw fa-lg fa-copy" aria-hidden="true"></i></a>--%>
                <a href="<%= Url.Action("GetMemberLessonXlsxList","EnterpriseProgram",new { item.ContractID }) %>" class="btn btn-circle bg-color-green"><i class="far fa-fw fa-lg fa-file-excel" aria-hidden="true"></i></a>&nbsp;&nbsp;
                <a onclick="showEnterprisePayment(<%= item.ContractID %>);" class="btn btn-circle bg-color-pink listPaymentDialog_link"><i class="fa fa-fw fa fa-lg fa-hand-holding-usd" aria-hidden="true"></i></a>
                <%--<a href="<%= Url.Action("GetEnterpriseLessonReportXlsx","EnterpriseProgram",new { item.ContractID }) %>" class="btn btn-circle bg-color-green"><i class="far fa-fw fa-lg fa-file-excel" aria-hidden="true"></i></a>--%>
            </td>
        </tr>
        <%  } %>
    </tbody>
</table>

<script>
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
            "ordering": true,
            "order": [[4, "desc"]],
            "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l>r>" +
                "t" +
                "<'dt-toolbar-footer'<'col-sm-6 col-xs-12 hidden-xs'i><'col-xs-12 col-sm-6'p>>",
            "autoWidth": true,
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

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "programList" + DateTime.Now.Ticks;
    IQueryable<EnterpriseCourseContract> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<EnterpriseCourseContract>)this.Model;
    }

</script>
