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
                    <th data-class="expand">日期</th>
                    <th>體能顧問</th>
                    <th>P.T已完成</th>
                    <th>P.T未完成</th>
                    <th>P.I已完成</th>
                    <th>P.I未完成</th>
                    <th data-hide="phone">S.T</th>
                    <th data-hide="phone">體驗課程</th>
                    <th data-hide="phone">教練P.I</th>
                </tr>
            </thead>
            <tbody>
                <%  int PTTotalCount = 0, PTUnfinished = 0, PITotalCount = 0, PIUnfinished = 0, STTotalCount = 0, trialTotalCount = 0, selfTotalCount = 0;

                    Expression<Func<LessonTime, DateTime>> groupBy;
                    bool byHour = false;
                    if (_viewModel.AchievementDateFrom == _viewModel.AchievementDateTo)
                    {
                        byHour = true;
                        groupBy = l => l.ClassTime.Value;
                    }
                    else
                    {
                        groupBy = l => l.ClassTime.Value.Date;
                    }

                    foreach (var g in _model.GroupBy(groupBy)
                        .OrderBy(g => g.Key))
                    {
                        foreach (var c in g.GroupBy(l=>l.AttendingCoach))
                        {
                            var coach = models.GetTable<ServingCoach>().Where(s => s.CoachID == c.Key).First(); %>
                <tr>
                    <td><%= byHour ? $"{g.Key:yyyy/MM/dd HH:mm}" : $"{g.Key:yyyy/MM/dd}" %></td>
                    <td><%= coach.UserProfile.FullName() %></td>
                    <td nowrap="noWrap" class="text-center">
                        <%  var items = c.PTLesson();
                            int PTCount = items.Where(l => l.LessonAttendance != null).Count();
                            PTTotalCount += PTCount;
                            if (PTCount > 0)
                            {   %>
                        <a href='javascript:showLessonList(<%= JsonConvert.SerializeObject(new { ClassTime = g.Key, CoachID = coach.CoachID }) %>);'><u>(<%= PTCount %>)</u></a>
                        <%  }
                            else
                            { %>
                        --
                        <%  } %>
                    </td>
                    <td nowrap="noWrap" class="text-center">
                        <%  PTCount = items.Where(l => l.LessonAttendance == null).Count();
                            PTUnfinished += PTCount;
                            if (PTCount > 0)
                            {   %>
                        <u>(<%= PTCount %>)</u>
                        <%  }
                            else
                            { %>
                        --
                        <%  } %>
                    </td>
                    <td nowrap="noWrap" class="text-center">
                        <%  items = c.Where(l => l.TrainingBySelf == 1);
                            int PICount = items.Where(l => l.LessonAttendance != null).Count();
                            PITotalCount += PICount;
                            if (PICount > 0)
                            {   %>
                        <u>(<%= PICount %>)</u>
                        <%  }
                            else
                            { %>
                        --
                        <%  } %>
                    </td>                   
                    <td nowrap="noWrap" class="text-center">
                        <%  PICount = items.Where(l => l.LessonAttendance == null).Count();
                            PIUnfinished += PICount;
                            if (PICount > 0)
                            {   %>
                        <u>(<%= PICount %>)</u>
                        <%  }
                            else
                            { %>
                        --
                        <%  } %>
                    </td>                   
                    <td nowrap="noWrap" class="text-center">
                        <%  items = c.Where(l => l.TrainingBySelf == 2);
                            int STCount = items.Count();
                            STTotalCount += STCount;
                            if (STCount > 0)
                            {   %>
                        <u>(<%= STCount %>)</u>
                        <%  }
                            else
                            { %>
                        --
                        <%  } %>
                    </td>
                    <td nowrap="noWrap" class="text-center">
                        <%  items = c.TrialLesson();

                            int trialCount = items.Count();
                            trialTotalCount += trialCount;
                            if (trialCount > 0)
                            {   %>
                        <u>(<%= trialCount %>)</u>
                        <%  }
                            else
                            { %>
                        --
                        <%  } %>
                    </td>
                    <td nowrap="noWrap" class="text-center">
                        <%  items = c.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.教練PI);

                            int selfCount = items.Count();
                            selfTotalCount += selfCount;
                            if (selfCount > 0)
                            {   %>
                        <u>(<%= selfCount %>)</u>
                        <%  }
                            else
                            { %>
                        --
                        <%  } %>
                    </td>
                </tr>
                <%      }
                    } %>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="2" class="text-right">總計</td>
                    <td class="text-center"><%= PTTotalCount %></td>
                    <td class="text-center"><%= PTUnfinished %></td>
                    <td class="text-center"><%= PITotalCount %></td>
                    <td class="text-center"><%= PIUnfinished %></td>
                    <td class="text-center"><%= STTotalCount %></td>
                    <td class="text-center"><%= trialTotalCount %></td>
                    <td class="text-center"><%= selfTotalCount %></td>
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
        $('#btnLearnerToComplete').css('display', 'inline');
<%  }  %>

        $('.achievement').text('');

<%  if (_viewModel.AchievementDateFrom.HasValue || _viewModel.AchievementDateTo.HasValue)
    { %>
        $('.achievement').text('(<%= _viewModel.AchievementDateFrom.HasValue ? String.Format("{0:yyyy/MM/dd}",_viewModel.AchievementDateFrom) : null %>~<%= _viewModel.AchievementDateTo.HasValue ? String.Format("{0:yyyy/MM/dd}",_viewModel.AchievementDateTo.Value.AddMonths(1).AddDays(-1)) : null %>)');
        <%  } %>

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
