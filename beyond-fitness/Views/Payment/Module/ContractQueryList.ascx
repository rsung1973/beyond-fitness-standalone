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
            <th>分店</th>
            <th data-hide="phone">體能顧問</th>
            <th>學員姓名</th>
            <th data-hide="phone">生效日期</th>
            <th>合約名稱</th>
            <th data-hide="phone">剩餘/購買堂數</th>
            <th data-hide="phone">合約總金額</th>
            <th data-hide="phone">已收金額</th>
            <th data-hide="phone">服務項目</th>
            <th data-hide="phone">狀態</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <td nowrap="noWrap"><%= item.ContractNo + "-" + String.Format("{0:00}",item.SequenceNo) %></td>
            <td ><%= item.CourseContractExtension.BranchStore.BranchName %></td>
            <td ><%= item.ServingCoach.UserProfile.FullName() %></td>
            <td >
                <%  if (item.CourseContractType.IsGroup==true)
                    { %>
                <%= String.Join("/",item.CourseContractMember.Select(m=>m.UserProfile.RealName)) %>
                <%  }
                    else
                    { %>
                <%= item.ContractOwner.FullName() %>
                <%  } %>
            </td>
            <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", item.ContractDate) %></td>
            <td><%= item.CourseContractType.TypeName %>(<%= item.LessonPriceType.DurationInMinutes %>分鐘)</td>
            <td><%= item.RemainedLessonCount() %>/<%= item.Lessons %></td>
            <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,###}",item.TotalCost) %></td>
            <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,###}",item.TotalPaidAmount()) %></td>
            <td>新合約</td>
            <td nowrap="noWrap"><%= ((Naming.CourseContractStatus)item.Status).ToString() %></td>
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
            "pageLength": 30,
            "lengthMenu": [[30, 50, 100, -1], [30, 50, 100, "全部"]],
            "ordering": true,
            "order": [],
            "sDom": "",
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

        $global.listAmendment = function (contractID) {
            showLoading();
            $.post('<%= Url.Action("ListAmendment","CourseContract") %>', { 'contractID': contractID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        };

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "dt_contract" + DateTime.Now.Ticks;
    IQueryable<CourseContract> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<CourseContract>)this.Model;
    }

</script>
