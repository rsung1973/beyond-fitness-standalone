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
            <th data-class="expand">合約編號</th>
            <th data-hide="phone">分店</th>
            <th data-hide="phone">簽約體能顧問</th>
            <th>學員</th>
            <th data-hide="phone">合約名稱</th>
            <th data-hide="phone">生效日</th>
            <th data-hide="phone">剩餘/購買堂數</th>
            <th data-hide="phone">應付金額</th>
            <th data-hide="phone">已付金額</th>
            <th>欠款金額</th>
            <th data-hide="phone">已繳期數</th>       
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            {
                var totalPaid = item.TotalPaidAmount();
                var receivable = item.TotalCost - totalPaid;
                if (receivable != 0)
                {   %>
        <tr>
            <td nowrap="noWrap"><%= item.ContractNo() %></td>
            <td><%= item.CourseContractExtension.BranchStore.BranchName %></td>
            <td><%= item.ServingCoach.UserProfile.FullName() %></td>
            <td>
                <%  if (item.CourseContractType.IsGroup == true)
                    { %>
                <%= String.Join("/", item.CourseContractMember.Select(m => m.UserProfile).ToArray().Select(u => u.FullName())) %>
                <%  }
                    else
                    { %>
                <%= item.ContractOwner.FullName() %>
                <%  } %>
            </td>
            <td><%= item.CourseContractType.TypeName %>(<%= item.LessonPriceType.DurationInMinutes %>分鐘)</td>
            <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", item.EffectiveDate) %></td>
            <td><%= item.RemainedLessonCount() %>/<%= item.Lessons %></td>
            <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", item.TotalCost) %></td>
            <td nowrap="noWrap" class="text-right">
                <%= String.Format("{0:##,###,###,##0}", totalPaid) %></td>
            <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", receivable) %></td>
            <td nowrap="noWrap">
                <%  if (item.ContractPayment.Count > 0)
                    { %>
                <a onclick="showPaymentHistory(<%= item.ContractID %>);" class="btn btn-circle bg-color-yellow" id="paymentlistDialog_link"><i class="fa fa-fw fa fa-lg fa-eye" aria-hidden="true"></i></a>                
                <%  } %>
                <%= item.ContractPayment.Count %>
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
            "bPaginate": true,
            "pageLength": 30,
            "lengthMenu": [[30, 50, 100, -1], [30, 50, 100, "全部"]],
            "ordering": true,
            "order": [[4,"desc"]],
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

    function showPaymentHistory(contractID) {
        showLoading();
        $.post('<%= Url.Action("ListPaymentHistory","Accounting") %>', { 'contractID': contractID }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "dt_accounts" + DateTime.Now.Ticks;
    IQueryable<CourseContract> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<CourseContract>)this.Model;
    }

</script>
