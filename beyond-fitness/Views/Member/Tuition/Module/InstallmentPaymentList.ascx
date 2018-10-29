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
            <th>功能</th>
            <th>金額</th>
            <th>付款日期</th>
            <th>業績所屬體能顧問</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model.TuitionInstallment)
            { %>
        <tr>
            <td>
<%--                <a onclick="javascript:payInstallment(<%= _model.RegisterID %>);">
                    <i class="fa fa-pencil-square-o fa-2x text-warning btn btn-xs bg-color-orange"></i>
                </a>--%>
                <a onclick="deletePayment(<%= item.InstallmentID %>);" class="deletePay">
                    <i class="far fa-trash-alt fa-2x btn btn-xs bg-color-redLight"></i>
                </a>
                <a onclick="shareInstallment(<%= item.InstallmentID %>);">
                    <i class="fa fa-plus-square fa-2x btn btn-xs fa-user-plus bg-color-pink"></i>
                </a>
            </td>
            <td><%= String.Format("{0:##,###,###,###}",item.PayoffAmount) %></td>
            <td><%= String.Format("{0:yyyy/MM/dd}",item.PayoffDate) %></td>
            <td>
                <%  foreach(var t in item.TuitionAchievement)
                    { %>
                        <%= t.ServingCoach.UserProfile.FullName() %>《<%= String.Format("{0:##,###,###,###}",t.ShareAmount) %>》
                        <a onclick="deleteAchievementShare(<%= t.InstallmentID %>,<%= t.CoachID %>);" class="deletePay"><i class="far fa-trash-alt btn btn-xs bg-color-redLight"></i></a>
                        <br />
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
            "bPaginate": false,
            //"pageLength": 30,
            //"lengthMenu": [[30, 50, 100, -1], [30, 50, 100, "全部"]],
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
    IntuitionCharge _model;
    String _tableId;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IntuitionCharge)this.Model;
        _tableId = ViewBag.DataTableId ?? "dt_installment_" + DateTime.Now.Ticks;
    }

</script>
