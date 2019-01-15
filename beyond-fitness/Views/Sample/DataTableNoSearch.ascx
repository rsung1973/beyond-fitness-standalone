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

<label class="label">依您輸入的發票號碼，搜尋結果如下：</label>
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
            <th data-hide="phone,tablet">狀態</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <td><%  if (item.InvoiceID.HasValue)
                    {   %>
                <%= item.InvoiceItem.TrackCode %><%= item.InvoiceItem.No %>
                <%      if(item.TransactionType==(int)Naming.PaymentTransactionType.自主訓練
                            || item.TransactionType==(int)Naming.PaymentTransactionType.體能顧問費)
                        { %>
                            <input type="hidden" name="VoidID" value="<%= item.PaymentID %>" />
                <%      }
                    } %>
            </td>
            <td><%= item.PaymentTransaction.BranchStore.BranchName %></td>
            <td><%= item.UserProfile.RealName %></td>
            <td><%= item.TuitionInstallment!=null
                        ? item.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName()
                        : item.ContractPayment!=null
                            ? item.ContractPayment.CourseContract.ContractOwner.FullName()
                            : "--" %></td>
            <td><%= String.Format("{0:yyyy/MM/dd}",item.PayoffDate) %></td>
            <td><%= ((Naming.PaymentTransactionType)item.TransactionType).ToString() %>
                <%  if(item.TransactionType==(int)Naming.PaymentTransactionType.運動商品
                        || item.TransactionType==(int)Naming.PaymentTransactionType.飲品)
                    { %>
                (<%= String.Join("、", item.PaymentTransaction.PaymentOrder.Select(p=>p.MerchandiseWindow.ProductName)) %>)
                <%  } %>
            </td>
            <td><%= String.Format("{0:##,###,###,###}",item.PayoffAmount) %></td>
            <td><%= item.PaymentType %></td>
            <td><%= item.InvoiceID.HasValue
                        ? item.InvoiceItem.InvoiceType==(int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                            ? "電子發票"
                            : "紙本" 
                        : "--" %></td>
            <td><%= item.InvoiceID.HasValue 
                        ? item.InvoiceItem.InvoiceCancellation==null 
                            ? "已開立" : "已作廢"
                        : "--" %></td>
            <td><%= item.InvoiceID.HasValue 
                        ? item.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : item.InvoiceItem.InvoiceBuyer.ReceiptNo 
                        : "--" %></td>
            <td nowrap="noWrap">
                <%  if (item.ContractPayment != null)
                    { %>
                <%= item.ContractPayment.CourseContract.ContractNo() %>
                <%  } %>
            </td>
            <td><%= ((Naming.CourseContractStatus)item.Status).ToString() %></td>
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
            //"pageLength": 30,
            //"lengthMenu": [[30, 50, 100, -1], [30, 50, 100, "全部"]],
            "searching": false,
            "ordering": true,
            "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l>r>" +
                     "t" +
                     "<'dt-toolbar-footer'<'col-sm-6 col-xs-12 hidden-xs'i><'col-xs-12 col-sm-6'p>>",
            "autoWidth": true,
            "paging": false,
            "info": true,
            "order": [3],
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
    String _tableId = "paymentList" + DateTime.Now.Ticks;
    IQueryable<Payment> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<Payment>)this.Model;
    }

</script>
