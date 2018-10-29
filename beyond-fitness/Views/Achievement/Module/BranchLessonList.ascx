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

<table id="<%= _tableId %>" class="table table-striped table-bordered table-hover display responsive no-wrap" width="100%">
    <thead>
        <tr>
            <th data-class="expand">分店</th>
            <th>P.T總堂數</th>
            <th data-hide="phone">P.T比例</th>
            <th>P.I總堂數</th>
            <th data-hide="phone">P.I比例</th>
            <th>體驗課程總堂數</th>
            <th data-hide="phone">體驗課程比例</th>
            <th data-hide="phone">總計</th>
        </tr>
    </thead>
    <tbody>
        <%  
            if (_model.Count() > 0)
            {

                foreach (var g in models.GetTable<BranchStore>())
                {
                    var items = _model.Where(t => t.BranchID == g.BranchID);
                    int PTCount = items.PTLesson().Count();

                    int PICount = items.Where(l => l.TrainingBySelf == 1).Count();

                    int trialCount = items.TrialLesson().Count();
                    int totalCount = PTCount + PICount + trialCount;
                     %>
        <tr>
            <td><%= g.BranchName %></td>
            <td nowrap="noWrap" class="text-center">
                <%
                     %>
                <%= PTCount %>
            </td>
            <td nowrap="noWrap" class="text-center"><%= totalCount > 0 ? $"{Math.Round(PTCount * 100m / totalCount)}%" : "--" %></td>
            <td nowrap="noWrap" class="text-center">
                <%= PICount %>
            </td>
            <td nowrap="noWrap" class="text-center"><%= totalCount > 0 ? $"{Math.Round(PICount * 100m / totalCount)}%" : "--" %></td>
            <td nowrap="noWrap" class="text-center"><%= trialCount %></td>
            <td nowrap="noWrap" class="text-center"><%= totalCount > 0 ? $"{Math.Round(trialCount * 100m / totalCount)}%" : "--" %></td>
            <td nowrap="noWrap" class="text-center">
                <%  if ((_viewModel.AchievementDateTo - _viewModel.AchievementDateFrom)?.TotalDays > 31)
                    { %>
                <%= totalCount %>
                <%  }
                    else
                    { %>
                <a href='javascript:showBranchLessonList(<%= JsonConvert.SerializeObject(new { g.BranchID }) %>);'><u><%= totalCount %></u></a>
                <%  } %>
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
            "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l>r>" +
                     "t" +
                     "<'dt-toolbar-footer'<'col-sm-6 col-xs-12 hidden-xs'i><'col-xs-12 col-sm-6'p>>",
            "autoWidth": false,
            "responsive": true,
            "lengthMenu": [[10, 30, 50, -1], [10, 30, 50, "全部"]],
            "ordering": [0],
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

<%  if (_model.Count() > 0)
    {  %>
        $('#btnDownloadLessons').css('display', 'inline');
<%  }  %>

        $('.achievement').text('<%= _viewModel.QueryInterval %>課程總覽');

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "branchLesson" + DateTime.Now.Ticks;
    IQueryable<LessonTime> _model;
    AchievementQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }

</script>
