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
            <th data-class="expand">姓名</th>
            <th><i class="fa fa-fw fa-money text-muted hidden-md hidden-sm hidden-xs"></i>業績金額</th>
            <th></th>
        </tr>
    </thead>
    <tbody>
        <%  var items = _model.GroupBy(t => t.CoachID);
            int subtotal = 0;
            foreach(var item in items)
            {
                UserProfile coach = models.GetTable<UserProfile>().Where(u => u.UID == item.Key).First();   %>
                <tr>
                    <td nowrap="noWrap"><%= coach.FullName() %></td>
                    <td nowrap="noWrap" class="text-right"><%  var summary = item.Sum(l => l.ShareAmount);
                            subtotal += summary.Value; %>
                        <%= summary %></td>
                    <td nowrap="noWrap"><a onclick="showTuitionAchievement(<%= coach.UID %>);" class="btn btn-circle bg-color-blueLight classlistDialog_link "><i class="fa fa-eye"></i></a></td>
                </tr>
        <%  } %>
    </tbody>
    <tfoot>
        <tr>
            <td>總計</td>
            <td nowrap="noWrap" class="text-right"><%= subtotal %></td>
            <td></td>
        </tr>
    </tfoot>
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
            //"ordering": false,
            "sDom": "",
            "autoWidth": true,
            "oLanguage": {
                "sSearch": ''
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
    String _tableId = "tuitionAchievement"+DateTime.Now.Ticks;
    IQueryable<TuitionAchievement> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<TuitionAchievement>)this.Model;
    }

</script>
