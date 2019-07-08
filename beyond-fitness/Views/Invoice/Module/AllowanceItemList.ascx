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
            <th data-hide="phone">收款人</th>
            <th>學員</th>
            <th>收款日期</th>
            <th data-hide="phone">收款品項</th>
            <th>金額</th>
            <th data-hide="phone">收款方式</th>
            <th data-hide="phone">發票類型</th>
            <th data-hide="phone">發票狀態</th>
            <th data-hide="phone,tablet">買受人統編</th>
            <th data-hide="phone,tablet">合約編號</th>
            <th data-hide="phone">列印次數</th>
            <th>功能</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <td nowrap="noWrap"><%  if (item.InvoiceID.HasValue)
                                    {   %>
                        <%= item.InvoiceItem.TrackCode %><%= item.InvoiceItem.No %>
                <%  } %>
            </td>
            <td><%= item.PaymentTransaction.BranchStore.BranchName %></td>
            <td ><%= item.UserProfile.FullName() %></td>
            <td ><%= item.TuitionInstallment != null
                        ? item.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName()
                        : item.ContractPayment != null
                            ? item.ContractPayment.CourseContract.ContractOwner.FullName()
                            : "--" %></td>
            <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", item.PayoffDate) %></td>
            <td><%= ((Naming.PaymentTransactionType)item.TransactionType).ToString() %>
                <%  if (item.TransactionType == (int)Naming.PaymentTransactionType.運動商品
|| item.TransactionType == (int)Naming.PaymentTransactionType.食飲品)
                    { %>
                (<%= String.Join("、", item.PaymentTransaction.PaymentOrder.Select(p => p.MerchandiseWindow.ProductName)) %>)
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-right"><%= item.PayoffAmount >= 0 ? String.Format("{0:##,###,###,###}", item.PayoffAmount) : String.Format("({0:##,###,###,###})", -item.PayoffAmount) %></td>
            <td><%= item.PaymentType %></td>
            <td><%= item.InvoiceID.HasValue
                        ? item.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                            ? "電子發票"
                            : "紙本"
                        : "--" %></td>
            <td><%= item.VoidPayment == null
                        ? "已開立"
                        : item.VoidPayment.Status == (int)Naming.CourseContractStatus.已生效
                            ? item.InvoiceItem.InvoiceAllowance.Any() 
                                ? "已折讓"
                                : "已作廢"
                            : "已開立" %></td>
            <td><%= item.InvoiceID.HasValue
                        ? item.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : item.InvoiceItem.InvoiceBuyer.ReceiptNo
                        : "--" %></td>
            <td nowrap="noWrap">
                <%  if (item.ContractPayment != null)
                    { %>
                        <%= item.ContractPayment.CourseContract.ContractNo() %>
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  var allowance = item.InvoiceItem.InvoiceAllowance.First();
                    if (item.InvoiceItem.InvoiceType == (byte)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
                    { %>
                        <%= allowance.Document.DocumentPrintLog.Count %>
                <%  } %>
            </td>
            <td>
                <%  if (item.InvoiceItem.InvoiceType == (byte)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
                    {
                        if (item.InvoiceItem.InvoiceCancellation == null)
                        { %>
                <%--<a href="<%= Url.Action("GetAllowancePDF", "Invoice", new { allowance.AllowanceID }) %>" target="_blank" class="btn btn-circle bg-color-pink"><i class="fa fa-fw fa fa-lg fa-print" aria-hidden="true"></i></a>--%>
                <a onclick="printAllowance(<%= allowance.AllowanceID %>);" class="btn btn-circle bg-color-pink"><i class="fa fa-fw fa fa-lg fa-print" aria-hidden="true"></i></a>
                <%      }
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
        $('#btnDownload').css('display', 'inline');
<%  }  %>

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "allowanceList" + DateTime.Now.Ticks;
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
