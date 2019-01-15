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
            <th data-class="expand">體能顧問</th>
            <th data-hide="phone">Level</th>
            <th>上課堂數</th>
            <th data-hide="phone">上課抽成金額（含稅）</th>
            <th>上課抽成金額</th>
            <th data-hide="phone">業績金額（含稅）</th>
            <th>業績金額</th>
        </tr>
    </thead>
    <tbody>
        <%
            if (_model.Count() > 0)
            {
                //IQueryable<ServingCoach> coaches = models.GetTable<ServingCoach>();
                //if (_viewModel.BranchID.HasValue)
                //{
                //    coaches = coaches.Join(models.GetTable<CoachWorkplace>().Where(b => b.BranchID == _viewModel.BranchID), c => c.CoachID, b => b.CoachID, (c, b) => c);
                //}
                decimal totalCount = 0, summary = 0, totalShares = 0, subtotal = 0;
                foreach (var c in _viewModel.ByCoachID)
                {
                    var coach = models.GetTable<ServingCoach>().Where(s => s.CoachID == c).First();
                    var items = _model.Where(t => t.AttendingCoach == coach.CoachID);
                    var tuitionItems = _items.Where(a => a.CoachID == coach.CoachID);
                    var lesson = items.FirstOrDefault();
        %>
        <tr>
            <td><%= coach.UserProfile.FullName() %></td>
            <td nowrap="noWrap" class="text-center"><%= lesson != null ? lesson.LessonTimeSettlement.ProfessionalLevel.LevelName : "--" %></td>
            <td class="text-right">
                <%  var attendanceCount = items.Count() - (decimal)(items
                    .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自主訓練
                        || (t.RegisterLesson.RegisterLessonEnterprise != null
                            && t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.DocumentLevelDefinition.自主訓練)).Count()) / 2m;
                    totalCount += attendanceCount; %>
                <%= attendanceCount>0 ? attendanceCount.ToString() : "--" %>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  int shares;
                    var lessons = items
                            .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
                            .Where(t => t.RegisterLesson.RegisterLessonEnterprise == null
                                || t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status != (int)Naming.DocumentLevelDefinition.自主訓練);
                    var achievement = models.CalcAchievement(lessons, out shares);
                    summary += achievement;
                    Writer.Write(shares > 0 ? shares.ToString() : "--");
                    totalShares += shares; %>
            </td>
            <td nowrap="noWrap" class="text-right"><%= shares>0 ? Math.Round(shares / 1.05m).ToString() : "--" %></td>
            <td nowrap="noWrap" class="text-right">
                <%  var tuitionAmt = tuitionItems.Sum(l => l.ShareAmount);
                    subtotal += tuitionAmt ?? 0; %>
                <%= tuitionAmt>0 ? tuitionAmt.ToString() : "--" %></td>
            <td nowrap="noWrap" class="text-right"><%= tuitionAmt>0 ? Math.Round((tuitionAmt ?? 0) / 1.05m).ToString() : "--" %></td>
        </tr>
        <%  } %>
    </tbody>
    <tfoot>
        <tr>
            <td colspan="2" class="text-right">總計</td>
            <td nowrap="noWrap" class="text-right"><%= totalCount %></td>
            <td nowrap="noWrap" class="text-right"><%= totalShares %></td>
            <td nowrap="noWrap" class="text-right"><%= Math.Round(totalShares / 1.05m) %></td>
            <td nowrap="noWrap" class="text-right"><%= subtotal %></td>
            <td nowrap="noWrap" class="text-right"><%= Math.Round(subtotal / 1.05m) %></td>
        </tr>
    </tfoot>
    <%  } %>
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
            "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l>r>" +
                     "t" +
                     "<'dt-toolbar-footer'<'col-sm-6 col-xs-12 hidden-xs'i><'col-xs-12 col-sm-6'p>>",
            "autoWidth": false,
            "responsive": true,
            "lengthMenu": [[30, 50, 100, -1], [30, 50, 100, "全部"]],
            "ordering": [1],
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
        $('#btnDownloadAchievement').css('display', 'inline');
<%  }  %>
        $('.achievement').text('<%= _viewModel.AchievementYearMonthFrom %>');


    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "performance" + DateTime.Now.Ticks;
    IQueryable<LessonTime> _model;
    IQueryable<TuitionAchievement> _items;
    AchievementQueryViewModel _viewModel;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
        _items = (IQueryable<TuitionAchievement>)ViewBag.TuitionItems;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }


</script>
