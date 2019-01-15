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
            <th>發票年度</th>
            <th>發票期別</th>
            <th>字軌</th>
            <th data-hide="phone">發票開始號碼（起）</th>
            <th data-hide="phone">發票結束號碼（迄）</th>
            <th data-hide="phone">功能</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <td><%= item.InvoiceTrackCodeAssignment.Organization.BranchStore.BranchName %></td>
            <td><%= item.InvoiceTrackCodeAssignment.InvoiceTrackCode.Year %></td>
            <td><%= String.Format("{0:00}",item.InvoiceTrackCodeAssignment.InvoiceTrackCode.PeriodNo*2-1) %>-<%= String.Format("{0:00}",item.InvoiceTrackCodeAssignment.InvoiceTrackCode.PeriodNo*2) %>月</td>
            <td><%= item.InvoiceTrackCodeAssignment.InvoiceTrackCode.TrackCode %></td>
            <td><%= String.Format("{0:00000000}", item.StartNo) %></td>
            <td><%= String.Format("{0:00000000}", item.EndNo) %></td>
            <td nowrap="noWrap">
                <%  if (item.InvoiceNoAssignment.Count == 0)
                    {
                        if (item.GroupID.HasValue)
                        {
                            if(!item.InvoiceNoIntervalGroup.InvoiceNoInterval.Any(i=>i.InvoiceNoAssignment.Count>0))
                            { %>
                <a onclick="editIntervalGroup(<%= item.GroupID %>);" class="btn btn-circle bg-color-yellow"><i class="fa fa-fw fa fa-lg fa-edit" aria-hidden="true"></i></a>&nbsp;&nbsp;
                <a onclick="deleteInterval(<%= item.IntervalID %>);" class="btn btn-circle bg-color-red delete"><i class="fa fa-fw fa fa-lg fa-trash-alt" aria-hidden="true"></i></a>
                    <%      }
                        }
                        else
                        { %>
                <a onclick="editInterval(<%= item.IntervalID %>);" class="btn btn-circle bg-color-yellow"><i class="fa fa-fw fa fa-lg fa-edit" aria-hidden="true"></i></a>&nbsp;&nbsp;
                <a onclick="deleteInterval(<%= item.IntervalID %>);" class="btn btn-circle bg-color-red delete"><i class="fa fa-fw fa fa-lg fa-trash-alt" aria-hidden="true"></i></a>
                <%      } %>
                <%  } %>
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

<%  if(_model.Count()>0)
    {  %>
        $('#btnDownloadInterval').css('display', 'inline');
<%  }  %>

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "trackCodeNo" + DateTime.Now.Ticks;
    IQueryable<InvoiceNoInterval> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<InvoiceNoInterval>)this.Model;
    }

</script>
