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
            <th data-hide="phone">統一編號</th>
            <th>年度</th>
            <th>期別</th>
            <th data-hide="phone">字軌</th>
            <th data-hide="phone">發票號碼起</th>
            <th data-hide="phone">發票號碼迄</th>
            <th>總數量</th>
            <th>功能</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var seller in _model)
            {
                var items = models.GetDataContext().InquireVacantNo(seller.BranchID, _viewModel.Year, _viewModel.PeriodNo).ToList();
                foreach (var item in items.Where(r=>!r.CheckPrev.HasValue))
                {
                    InquireVacantNoResult tailItem;
                    if (item.CheckNext.HasValue)
                    {
                        var index = items.IndexOf(item);
                        tailItem = items[index + 1];
                    }
                    else
                        tailItem = item;
        %>
        <tr>
            <td><%= seller.BranchName %></td>
            <td><%= seller.Organization.ReceiptNo %></td>
            <td><%= _viewModel.Year %></td>
            <td><%= String.Format("{0:00}-{1:00}",_viewModel.PeriodNo*2-1,_viewModel.PeriodNo*2) %>月</td>
            <td><%= item.TrackCode %></td>
            <td><%= String.Format("{0:00000000}",item.InvoiceNo) %></td>
            <td><%= String.Format("{0:00000000}",tailItem.InvoiceNo) %></td>
            <td><%= tailItem.InvoiceNo-item.InvoiceNo+1 %></td>
            <td>
                <a onclick="downloadCsv(<%= seller.BranchID %>);" class="btn btn-circle bg-color-green"><i class="far fa-fw fa-lg fa-file-excel" aria-hidden="true"></i></a>&nbsp;&nbsp;
                <a onclick="processE0402(<%= seller.BranchID %>);" class="btn btn-circle bg-color-red"><i class="far fa-fw fa-lg fa-upload" aria-hidden="true"></i></a>
            </td>
        </tr>
        <%      }
            } %>
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
    String _tableId = "vacantNo" + DateTime.Now.Ticks;
    InvoiceNoViewModel _viewModel;
    IQueryable<BranchStore> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<BranchStore>)this.Model;
        _viewModel = (InvoiceNoViewModel)ViewBag.ViewModel;
    }

</script>
