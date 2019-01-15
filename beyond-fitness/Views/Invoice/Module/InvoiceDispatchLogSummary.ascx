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
    <%
        IQueryable<InvoiceItem> items = models.GetTable<InvoiceItem>().Where(i => i.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票);
        IQueryable<InvoiceItem> invoiceItems = items;

        if (_model.DateFrom.HasValue)
            invoiceItems = invoiceItems.Where(c => c.InvoiceDate >= _model.DateFrom);

        if (_model.DateTo.HasValue)
            invoiceItems = invoiceItems.Where(c => c.InvoiceDate < _model.DateTo.Value.AddDays(1));
 %>
    <thead>
        <tr>
            <th>分店</th>
            <th>實際新增發票筆數</th>
            <th>Turnkey待上傳筆數(<%=  Directory.GetFiles(TaskExtensionMethods.C0401Outbound).Length %>)</th>
            <th>Turnkey上傳成功筆數</th>
            <th>Turnkey上傳失敗筆數</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>小巨蛋</td>
            <%  var branchItems = invoiceItems.Where(i => i.SellerID == 1); %>
            <td><%= branchItems.Count() %></td>
            <td><%= branchItems.Join(models.GetTable<InvoiceItemDispatch>(),i=>i.InvoiceID,d=>d.InvoiceID,(i,d)=>i).Count() %></td>
            <td><%  var invTurnkeyLogs = branchItems.Join(models.GetTable<InvoiceItemDispatchLog>(), i => i.InvoiceID, d => d.InvoiceID, (i, d) => d); %>
                <%= invTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Successful).Count() %>
            </td>
            <td><%= invTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Failed).Count() %></td>
        </tr>
        <tr>
            <td>Enhanced 101</td>
            <%  branchItems = invoiceItems.Where(i => i.SellerID == 2); %>
            <td><%= branchItems.Count() %></td>
            <td><%= branchItems.Join(models.GetTable<InvoiceItemDispatch>(),i=>i.InvoiceID,d=>d.InvoiceID,(i,d)=>i).Count() %></td>
            <td><%  invTurnkeyLogs = branchItems.Join(models.GetTable<InvoiceItemDispatchLog>(), i => i.InvoiceID, d => d.InvoiceID, (i, d) => d); %>
                <%= invTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Successful).Count() %>
            </td>
            <td><%= invTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Failed).Count() %></td>
        </tr>
        <tr>
            <td>忠孝</td>
            <%  branchItems = invoiceItems.Where(i => i.SellerID == 3); %>
            <td><%= branchItems.Count() %></td>
            <td><%= branchItems.Join(models.GetTable<InvoiceItemDispatch>(),i=>i.InvoiceID,d=>d.InvoiceID,(i,d)=>i).Count() %></td>
            <td><%  invTurnkeyLogs = branchItems.Join(models.GetTable<InvoiceItemDispatchLog>(), i => i.InvoiceID, d => d.InvoiceID, (i, d) => d); %>
                <%= invTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Successful).Count() %>
            </td>
            <td><%= invTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Failed).Count() %></td>
        </tr>
    </tbody>
    <thead>
        <tr>
            <th></th>
            <th>實際作廢發票筆數</th>
            <th>Turnkey待上傳筆數(<%=  Directory.GetFiles(TaskExtensionMethods.C0501Outbound).Length %>)</th>
            <th>Turnkey上傳成功筆數</th>
            <th>Turnkey上傳失敗筆數</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>小巨蛋</td>
            <%  IQueryable<InvoiceCancellation> cancellationItems = models.GetTable<InvoiceCancellation>();
                items = items
                    .Join(models.GetTable<Payment>()
                            .Join(models.GetTable<VoidPayment>().Where(v => v.Status == (int)Naming.CourseContractStatus.已生效),
                                p => p.PaymentID, v => v.VoidID, (p, v) => p),
                        i => i.InvoiceID, p => p.InvoiceID, (i, p) => i);
                if (_model.DateFrom.HasValue)
                    cancellationItems = cancellationItems.Where(c => c.CancelDate >= _model.DateFrom);

                if (_model.DateTo.HasValue)
                    cancellationItems = cancellationItems.Where(c => c.CancelDate < _model.DateTo.Value.AddDays(1));

                var branchCancellationItems = items.Where(i => i.SellerID == 1)
                        .Join(cancellationItems, i => i.InvoiceID, c => c.InvoiceID, (i, c) => c);
                %>
            <td><%= branchCancellationItems.Count() %></td>
            <td><%= branchCancellationItems.Join(models.GetTable<InvoiceCancellationDispatch>(),i=>i.InvoiceID,d=>d.InvoiceID,(i,d)=>i).Count() %></td>
            <td><%  var cancellationTurnkeyLogs = branchCancellationItems.Join(models.GetTable<InvoiceCancellationDispatchLog>(), i => i.InvoiceID, d => d.InvoiceID, (i, d) => d); %>
                <%= cancellationTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Successful).Count() %>
            </td>
            <td><%= cancellationTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Failed).Count() %></td>
        </tr>
        <tr>
            <td>Enhanced 101</td>
            <%  branchCancellationItems = items.Where(i => i.SellerID == 2)
                        .Join(cancellationItems, i => i.InvoiceID, c => c.InvoiceID, (i, c) => c); %>
            <td><%= branchCancellationItems.Count() %></td>
            <td><%= branchCancellationItems.Join(models.GetTable<InvoiceCancellationDispatch>(),i=>i.InvoiceID,d=>d.InvoiceID,(i,d)=>i).Count() %></td>
            <td><%  cancellationTurnkeyLogs = branchCancellationItems.Join(models.GetTable<InvoiceCancellationDispatchLog>(), i => i.InvoiceID, d => d.InvoiceID, (i, d) => d); %>
                <%= cancellationTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Successful).Count() %>
            </td>
            <td><%= cancellationTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Failed).Count() %></td>
        </tr>
        <tr>
            <td>忠孝</td>
            <%  branchCancellationItems = items.Where(i => i.SellerID == 3)
                        .Join(cancellationItems, i => i.InvoiceID, c => c.InvoiceID, (i, c) => c); %>
            <td><%= branchCancellationItems.Count() %></td>
            <td><%= branchCancellationItems.Join(models.GetTable<InvoiceCancellationDispatch>(),i=>i.InvoiceID,d=>d.InvoiceID,(i,d)=>i).Count() %></td>
            <td><%  cancellationTurnkeyLogs = branchCancellationItems.Join(models.GetTable<InvoiceCancellationDispatchLog>(), i => i.InvoiceID, d => d.InvoiceID, (i, d) => d); %>
                <%= cancellationTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Successful).Count() %>
            </td>
            <td><%= cancellationTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Failed).Count() %></td>
        </tr>
    </tbody>
    <thead>
        <tr>
            <th></th>
            <th>實際折讓發票筆數</th>
            <th>Turnkey待上傳筆數(<%=  Directory.GetFiles(TaskExtensionMethods.D0401Outbound).Length %>)</th>
            <th>Turnkey上傳成功筆數</th>
            <th>Turnkey上傳失敗筆數</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>小巨蛋</td>
            <%  IQueryable<InvoiceAllowance> allowanceItems = models.GetTable<InvoiceAllowance>();

                if (_model.DateFrom.HasValue)
                    allowanceItems = allowanceItems.Where(c => c.AllowanceDate >= _model.DateFrom);

                if (_model.DateTo.HasValue)
                    allowanceItems = allowanceItems.Where(c => c.AllowanceDate < _model.DateTo.Value.AddDays(1)); 

                var branchAllowanceItems = items.Where(i => i.SellerID == 1)
                        .Join(allowanceItems, i => i.InvoiceID, c => c.InvoiceID, (i, c) => c);    %>

            <td><%= branchAllowanceItems.Count() %></td>
            <td><%= branchAllowanceItems.Join(models.GetTable<InvoiceAllowanceDispatch>(),i=>i.AllowanceID,d=>d.AllowanceID,(i,d)=>i).Count() %></td>
            <td><%  var allowanceTurnkeyLogs = branchAllowanceItems.Join(models.GetTable<InvoiceAllowanceDispatchLog>(), i => i.AllowanceID, d => d.AllowanceID, (i, d) => d); %>
                <%= allowanceTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Successful).Count() %>
            </td>
            <td><%= allowanceTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Failed).Count() %></td>
        </tr>
        <tr>
            <td>Enhanced 101</td>
            <%  branchAllowanceItems = items.Where(i => i.SellerID == 2)
                        .Join(allowanceItems, i => i.InvoiceID, c => c.InvoiceID, (i, c) => c);    %>
            <td><%= branchAllowanceItems.Count() %></td>
            <td><%= branchAllowanceItems.Join(models.GetTable<InvoiceAllowanceDispatch>(),i=>i.AllowanceID,d=>d.AllowanceID,(i,d)=>i).Count() %></td>
            <td><%  allowanceTurnkeyLogs = branchAllowanceItems.Join(models.GetTable<InvoiceAllowanceDispatchLog>(), i => i.AllowanceID, d => d.AllowanceID, (i, d) => d); %>
                <%= allowanceTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Successful).Count() %>
            </td>
            <td><%= allowanceTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Failed).Count() %></td>
        </tr>
        <tr>
            <td>忠孝</td>
            <%  branchAllowanceItems = items.Where(i => i.SellerID == 3)
                        .Join(allowanceItems, i => i.InvoiceID, c => c.InvoiceID, (i, c) => c);    %>
            <td><%= branchAllowanceItems.Count() %></td>
            <td><%= branchAllowanceItems.Join(models.GetTable<InvoiceAllowanceDispatch>(),i=>i.AllowanceID,d=>d.AllowanceID,(i,d)=>i).Count() %></td>
            <td><%  allowanceTurnkeyLogs = branchAllowanceItems.Join(models.GetTable<InvoiceAllowanceDispatchLog>(), i => i.AllowanceID, d => d.AllowanceID, (i, d) => d); %>
                <%= allowanceTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Successful).Count() %>
            </td>
            <td><%= allowanceTurnkeyLogs.Where(d=>d.Status==(int)Naming.GeneralStatus.Failed).Count() %></td>
        </tr>
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

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "invoiceDispatch" + DateTime.Now.Ticks;
    InvoiceQueryViewModel _model;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _profile = Context.GetUser();
        _model = (InvoiceQueryViewModel)this.Model;
    }

</script>
