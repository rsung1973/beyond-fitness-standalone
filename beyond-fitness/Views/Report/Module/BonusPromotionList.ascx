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
            <th data-class="expand"><i class="fa fa-fw fa-user text-muted hidden-md hidden-sm hidden-xs"></i>學員姓名</th>
            <th>目前累積Beyond幣</th>
            <th>目前剩餘Beyond幣</th>
            <th></th>
        </tr>
    </thead>
    <tbody>
        <%  var items = _model.GroupBy(t => t.UID);
            foreach (var g in items)
            {
                var profile = models.GetTable<UserProfile>().Where(u => u.UID == g.Key).First();
                var totalPoints = g.Sum(t => t.PDQQuestion.PDQQuestionExtension.BonusPoint);
                var remained = profile.BonusPoint(models) ?? 0;
                if (_viewModel.Lower.HasValue && remained < _viewModel.Lower)
                    continue;
                if (_viewModel.Upper.HasValue && remained > _viewModel.Upper)
                    continue;
                %>
        <tr>
            <td><%= profile.FullName() %></td>
            <td class="text-center"><%= totalPoints %></td>
            <td class="text-center"><%= remained %></td>
            <td nowrap="noWrap">
                <a href="#" onclick="listLearnerBonus('<%= profile.UID.EncryptKey() %>');" class="btn btn-circle bg-color-blueLight bonusListDialog_link"><i class="fa fa-fw fa-lg fa-eye" aria-hidden="true"></i></a>
            &nbsp;&nbsp;   
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
    String _tableId;
    IQueryable<PDQTask> _model;
    AwardQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _tableId = "bonusPromotion" + DateTime.Now.Ticks;
        _model = (IQueryable<PDQTask>)this.Model;
        _viewModel = (AwardQueryViewModel)ViewBag.ViewModel;
    }

</script>
