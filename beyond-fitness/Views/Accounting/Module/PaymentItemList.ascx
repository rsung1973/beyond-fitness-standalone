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

            <th data-class="expand">發票號碼</th>
            <th>分店</th>
            <th>收款日期</th>
            <th>金額</th>
            <th data-hide="phone">收款方式</th>
            <th data-hide="phone">發票類型</th>
            <th data-hide="phone">發票狀態</th>
            <th data-hide="phone">買受人統編</th>
        </tr>
    </thead>
    <tbody>
        <%  var items = _model.ContractPayment.Select(p => p.Payment);
            foreach(var item in items)
            {
                     %>
                <tr>
                    <td nowrap="noWrap"><%  if (item.InvoiceID.HasValue)
                    {   %>
                        <%= item.InvoiceItem.TrackCode %><%= item.InvoiceItem.No %>
                        <%  } %>
                    </td>
                    <td><%= item.PaymentTransaction.BranchStore.BranchName %></td>
                    <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}",item.PayoffDate) %></td>
                    <td nowrap="noWrap" class="text-right">
                        <%= String.Format("{0:##,###,###,###}",item.PayoffAmount) %>
                    </td>
                    <td><%= item.PaymentType %></td>
                    <td><%= item.InvoiceID.HasValue
                        ? item.InvoiceItem.InvoiceType==(int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                            ? "電子發票"
                            : "紙本" 
                        : "--" %></td>
                    <td><%= item.VoidPayment == null
                        ? "已開立"
                        : item.VoidPayment.Status==(int)Naming.CourseContractStatus.已生效
                            ? item.InvoiceItem.InvoiceAllowance.Any() 
                                ? "已折讓"
                                : "已作廢"
                            : "已開立" %></td>
                    <td nowrap="noWrap">
                        <%= item.InvoiceID.HasValue 
                            ? item.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : item.InvoiceItem.InvoiceBuyer.ReceiptNo 
                            : "--" %>
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
            "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l>r>" +
                                     "t" +
                                     "<'dt-toolbar-footer'<'col-sm-6 col-xs-12 hidden-xs'i><'col-xs-12 col-sm-6'p>>",
            "autoWidth": true,
            "order": [],
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
    String _tableId = "paymentItem" + DateTime.Now.Ticks;
    CourseContract _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
    }

</script>
