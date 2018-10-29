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
            <th>時間</th>
            <th>P.T</th>
            <th>P.I</th>
            <th data-hide="phone">體驗課程</th>
            <th data-hide="phone">總計</th>
        </tr>
    </thead>
    <tbody>
        <%  
            if (_model.Count() > 0)
            {
                foreach (var branch in models.GetTable<BranchStore>())
                {
                    var c = _model.Where(t => t.BranchID == branch.BranchID);

                    foreach (var h in models.GetTable<DailyWorkingHour>())
                    {
                        var items = c.Where(t => t.HourOfClassTime == h.Hour);

                        int PTCount = items.PTLesson().Count();

                        int PICount = items.Where(l => l.TrainingBySelf == 1).Count();

                        int trialCount = items.TrialLesson().Count();
                        int totalCount = PTCount + PICount + trialCount;
                     %>
        <tr>
            <td><%= branch.BranchName %></td>
            <td><%= h.Hour %>:00~<%= h.Hour+1 %>:00</td>
            <td nowrap="noWrap" class="text-center"><%= PTCount>0 ? PTCount.ToString() : "--" %></td>
            <td nowrap="noWrap" class="text-center"><%= PICount>0 ? PICount.ToString() : "--" %></td>
            <td nowrap="noWrap" class="text-center"><%= trialCount>0 ? trialCount.ToString() : "--" %></td>
            <td nowrap="noWrap" class="text-center"><%= totalCount>0 ? totalCount.ToString() : "--" %></td>
        </tr>
        <%          }
                }
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
    String _tableId = "lesson" + DateTime.Now.Ticks;
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
