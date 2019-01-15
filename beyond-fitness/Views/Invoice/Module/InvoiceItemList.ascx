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
            <%  Html.RenderPartial("~/Views/Payment/Section/PaymentInvoiceList/TH.ascx"); %>
            <th data-hide="phone">列印次數</th>
            <th>功能</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <%  Html.RenderPartial("~/Views/Payment/Section/PaymentInvoiceList/TD.ascx",item); %>
            <td nowrap="noWrap" class="text-right">
                <%  if (item.InvoiceItem.InvoiceType == (byte)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
                    { %>
                <%= item.InvoiceItem.Document.DocumentPrintLog.Count %>
                <%  } %>
            </td>
            <td>
                <%  if (item.InvoiceItem.InvoiceType == (byte)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
                    {
                        if (ViewBag.DataAction == "CommitAllowance")
                        {   %>
                    <a onclick="prepareAllowance(<%= item.InvoiceID %>);" class="btn btn-circle bg-color-yellow"><i class="fa fa-fw fa fa-lg fa-edit" aria-hidden="true"></i></a>
                    <%  }
                        else if (item.InvoiceItem.PrintMark == "Y")
                        {
                            if (item.InvoiceItem.InvoiceCancellation == null
                                && (item.InvoiceItem.Document.DocumentPrintLog.Count == 0
                                    || _profile.IsAssistant() || _profile.IsManager() || _profile.IsViceManager()))
                            { %>
                    <%--<a href="<%= Url.Action("GetInvoicePDF", "Invoice", new { item.InvoiceID }) %>" target="_blank" class="btn btn-circle bg-color-pink"><i class="fa fa-fw fa fa-lg fa-print" aria-hidden="true"></i></a>--%>
                    <a onclick="printInvoice(<%= item.InvoiceID %>);" class="btn btn-circle bg-color-pink"><i class="fa fa-fw fa fa-lg fa-print" aria-hidden="true"></i></a>
                    <%      }
                        }
                    } %>
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
            "order": [[0, "asc"]],
            "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l C>r>" +
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
            },
            "columnDefs": [
                    {
                        "targets": [1],
                        "visible": false
                    },
                    {
                        "targets": [4],
                        "visible": false
                    },
                    {
                        "targets": [6],
                        "visible": false
                    },
                    {
                        "targets": [13],
                        "visible": false
                    },
                    {
                        "targets": [14],
                        "visible": false
                    },
                    {
                        "targets": [17],
                        "visible": false
                    },
                    {
                        "targets": [18],
                        "visible": false
                    },
                    {
                        "targets": [19],
                        "visible": false
                    },
                    {
                        "targets": [20],
                        "visible": false
                    },
            ]
        });

<%  if(_model.Count()>0)
    {  %>
        $('#btnDownload').css('display', 'inline');
<%  }  %>

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "invoiceList" + DateTime.Now.Ticks;
    IQueryable<Payment> _model;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = ((IQueryable<Payment>)this.Model).Where(p => p.TransactionType.HasValue)
            .OrderBy(p => p.InvoiceID);
        _profile = Context.GetUser();
    }

</script>
