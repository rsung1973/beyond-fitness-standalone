<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<label class="label label-warning">狀態後<i class="fa fa-asterisk"></i> 表示主管尚未對帳</label>
<table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%">
    <thead>
        <tr>
            <%  Html.RenderPartial("~/Views/Payment/Section/PaymentInvoiceList/TH.ascx"); %>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <%  Html.RenderPartial("~/Views/Payment/Section/PaymentInvoiceList/TD.ascx",item); %>
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
                    <%  if (_viewModel.IsCancelled == true)
                        {    %>
                    {
                        "targets": [1],
                        "visible": false
                    },
                    {
                        "targets": [2],
                        "visible": false
                    },
                    {
                        "targets": [5],
                        "visible": false
                    },
                    {
                        "targets": [14],
                        "visible": false
                    },
                    {
                        "targets": [16],
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
                    <%  }
                        else if (_viewModel.IsCancelled == false)
                            {   %>
                    {
                        "targets": [1],
                        "visible": false
                    },
                    {
                        "targets": [2],
                        "visible": false
                    },
                    {
                        "targets": [5],
                        "visible": false
                    },
                    {
                        "targets": [6],
                        "visible": false
                    },
                    {
                        "targets": [12],
                        "visible": false
                    },
                    {
                        "targets": [11],
                        "visible": false
                    },
                    {
                        "targets": [15],
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
                    <%      }
                            else
                            {   %>
                    {
                        "targets": [1],
                        "visible": false
                    },
                    {
                        "targets": [5],
                        "visible": false
                    },
                    {
                        "targets": [6],
                        "visible": false
                    },
                    {
                        "targets": [9],
                        "visible": false
                    },
                    {
                        "targets": [10],
                        "visible": false
                    },
                    {
                        "targets": [16],
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
                        <%  }   %>
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
    String _tableId = "paymentList" + DateTime.Now.Ticks;
    IQueryable<Payment> _model;
    PaymentQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = ((IQueryable<Payment>)this.Model).Where(p => p.TransactionType.HasValue);
        _viewModel = (PaymentQueryViewModel)ViewBag.ViewModel;
    }

</script>
