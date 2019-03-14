<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table id="<%= _tableId %>" class="table table-striped table-custom nowrap bg-white col-charcoal dataTable dataTable-learner" width="100%">
    <thead>
        <tr>
            <th>發票號碼</th>
            <th>狀態</th>            
            <th>日期</th>
            <th>發票金額</th>
            <th>作廢/折讓金額</th>
            <th>折讓稅額</th>
            <th>收款類型</th>            
            <th>經手人</th>
            <th>買受人</th>
            <th>其他增補說明</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <td><%= item.InvoiceID.HasValue ? $"{item.InvoiceItem.TrackCode}{item.InvoiceItem.No}" : null %></td>
            <td><%= item.InvoiceID.HasValue
                    ? item.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                        ? "電子開立"
                        : "紙本開立"
                    : "" %></td>            
            <td><%= $"{item.PayoffDate:yyyy/MM/dd}" %></td>
            <td><%= $"{item.PayoffAmount:##,###,###,###}" %></td>
            <td></td>
            <td></td>
            <td><%= item.PaymentType %></td>
            <td><%= item.UserProfile.FullName() %></td>
            <td><%= item.InvoiceID.HasValue
                    ? item.InvoiceItem.InvoiceBuyer.IsB2C() ? "" : item.InvoiceItem.InvoiceBuyer.ReceiptNo
                    : "" %></td>            
            <td>
                <%= item.Remark %>
            </td>
        </tr>
        <%      if(item.AllowanceID.HasValue)
                {
                    var allowance = item.InvoiceAllowance;  %>
        <tr>
            <td><%= item.InvoiceID.HasValue ? $"{item.InvoiceItem.TrackCode}{item.InvoiceItem.No}" : null %></td>
            <td><%= item.InvoiceID.HasValue
                    ? item.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                        ? "電子折讓"
                        : "紙本折讓"
                    : "" %>
            </td>            
            <td><%= $"{allowance.AllowanceDate:yyyy/MM/dd}" %></td>
            <td><%= item.InvoiceID.HasValue ? $"{item.InvoiceItem.InvoiceAmountType.TotalAmount:##,###,###,###}" : null %></td>
            <td><%= $"{allowance.TotalAmount:##,###,###,###}" %></td>
            <td><%= $"{allowance.TaxAmount:##,###,###,###}" %></td>
            <td></td>
            <td><%= item.VoidPayment.UserProfile?.FullName() %></td>
            <td><%= item.InvoiceID.HasValue
                    ? item.InvoiceItem.InvoiceBuyer.IsB2C() ? "" : item.InvoiceItem.InvoiceBuyer.ReceiptNo
                    : "" %></td>            
            <td>                
                <%= item.InvoiceAllowance.InvoiceAllowanceDetails.First().InvoiceAllowanceItem.Remark %>
            </td>
        </tr>
            <%  } 
                else if (item.VoidPayment != null)
                {   %>
        <tr>
            <td><%= item.InvoiceID.HasValue ? $"{item.InvoiceItem.TrackCode}{item.InvoiceItem.No}" : null %></td>
            <td><%= item.InvoiceID.HasValue
                    ? item.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                        ? "電子作廢"
                        : "紙本作廢"
                    : "" %>
            </td>            
            <td><%= $"{item.VoidPayment.VoidDate:yyyy/MM/dd}" %></td>
            <td></td>
            <td><%= item.InvoiceID.HasValue ? $"{item.InvoiceItem.InvoiceAmountType.TotalAmount:##,###,###,###}" : null %></td>
            <td></td>
            <td></td>
            <td><%= item.VoidPayment.UserProfile.FullName() %></td>
            <td><%= item.InvoiceID.HasValue
                    ? item.InvoiceItem.InvoiceBuyer.IsB2C() ? "" : item.InvoiceItem.InvoiceBuyer.ReceiptNo
                    : "" %></td>            
            <td><%= item.VoidPayment.Remark %></td>
        </tr>
        <%      }   %>
        <%  } %>
    </tbody>
</table>

<script>
    $(function () {

        var theDataTable = null;
        function buildDataTable() {
            theDataTable = $('#<%= _tableId %>').dataTable({
                "filter": false,
                "bPaginate": false,
                "info": false,
                "order": [
                    [2, 'asc'],
                ],
                "language": {
                    "lengthMenu": "每頁顯示 _MENU_ 筆資料",
                    "zeroRecords": "沒有資料也是種福氣",
                    "info": "共 _TOTAL_ 筆，目前顯示第 _START_ 至 _END_筆資料",
                    "infoEmpty": "顯示 0 筆的資料",
                    "infoFiltered": "(總共從 _MAX_ 筆資料過濾)",
                    "loadingRecords": "快馬加鞭處理中...",
                    "processing": "快馬加鞭處理中...",
                    "search": "快速搜尋：",
                    "paginate": {
                        "first": "第一頁",
                        "last": "最後一頁",
                        "next": "下一頁",
                        "previous": "前一頁"
                    },
                },
                scrollX: true,
                scrollCollapse: true,
                fixedColumns: {
                    leftColumns: 1,
                },
                "columnDefs": [{
                    targets: [0, 1, 2, 6, 8],
                    className: "align-center"
                },
                {
                    targets: [3, 4, 5],
                    className: "align-right"
                }],
            });
        }

        var $collapse = $('#<%= _tableId %>').closest('.panel-collapse');
        if ($collapse) {
            $collapse.on('shown.bs.collapse', function (event) {
                if (!theDataTable) {
                    buildDataTable();
                }
            });
        } else {
            buildDataTable();
        }
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "dt_payment" + DateTime.Now.Ticks;
    IQueryable<Payment> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<Payment>)this.Model;
    }

</script>
