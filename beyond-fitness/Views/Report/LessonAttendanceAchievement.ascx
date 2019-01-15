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
            <th>總終點課數</th>
            <th data-hide="phone"><i class="fa fa-fw fa-money text-muted hidden-md hidden-sm hidden-xs"></i>總鐘點費用</th>
            <th data-hide="phone">等級</th>
            <th ><i class="fa fa-fw fa-money text-muted hidden-md hidden-sm hidden-xs"></i>實際抽成費用</th>
            <th></th>
        </tr>
    </thead>
    <tbody>
        <%  var items = _model.GroupBy(t => new { CoachID = t.AttendingCoach });
            int totalCount = 0, summary = 0, totalShares = 0;
            foreach(var item in items)
            {
                ServingCoach coach = models.GetTable<ServingCoach>().Where(u => u.CoachID == item.Key.CoachID).First(); %>
                <tr>
                    <td><%= coach.UserProfile.FullName() %></td>
                    <td><%= item.Count() %>
                        <%   totalCount += item.Count(); %></td>
                    <td><%  var achievement = models.CalcAchievement(item);
                            summary += achievement;
                            Writer.Write(achievement); %>
                    </td>
                    <td><%= coach.ProfessionalLevel.LevelName %></td>
                    <td><%  var shares = (int)(achievement * coach.ProfessionalLevel.GradeIndex / 100);
                            totalShares += shares;  %>
                        <%= shares %></td>
                    <td><a href="javascript:showAttendanceAchievement(<%= coach.CoachID %>);" class="btn bg-color-blueLight">檢視明細</a></td>
                </tr>
        <%  } %>
    </tbody>
    <tfoot>
        <tr>
            <td>總計</td>
            <td><%= totalCount %></td>
            <td><%= summary %></td>
            <td></td>
            <td><%= totalShares %></td>
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
    String _tableId = "dt_lessonAchievement";
    IQueryable<LessonTime> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
    }

    //int calcAchievement(IQueryable<LessonTime> items)
    //{
    //    var lessons = items.Where(t => t.LessonAttendance != null && t.LessonPlan.CommitAttendance.HasValue)
    //        .Select(l => l.GroupingLesson)
    //                .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r)
    //                .Where(r => r.IntuitionCharge != null);

    //    Utility.Logger.Debug(
    //    String.Join("\r\n", lessons.Select(r => r.RegisterID + "\t"
    //        + r.IntuitionCharge.Payment + "\t"
    //        + r.IntuitionCharge.FeeShared + "\t"
    //        + r.LessonPriceType.CoachPayoff + "\t"
    //        + r.LessonPriceType.CoachPayoffCreditCard + "\t"
    //        + r.GroupingLessonDiscount.PercentageOfDiscount + "\t"
    //        )));

    //    var fullAchievement = lessons.Where(r => r.IntuitionCharge.Payment == "Cash" || r.IntuitionCharge.FeeShared == 0).Sum(l => l.LessonPriceType.CoachPayoff * l.GroupingLessonDiscount.PercentageOfDiscount / 100)
    //        + lessons.Where(r => r.IntuitionCharge.Payment == "CreditCard" && r.IntuitionCharge.FeeShared == 1).Sum(l => l.LessonPriceType.CoachPayoffCreditCard * l.GroupingLessonDiscount.PercentageOfDiscount / 100);

    //    lessons = items.Where(t => t.LessonAttendance == null || !t.LessonPlan.CommitAttendance.HasValue)
    //        .Select(l => l.GroupingLesson)
    //                .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r);
    //    var halfAchievement = lessons.Where(r => r.IntuitionCharge.Payment == "Cash" || r.IntuitionCharge.FeeShared == 0).Sum(l => l.LessonPriceType.CoachPayoff * l.GroupingLessonDiscount.PercentageOfDiscount / 100) / 2
    //        + lessons.Where(r => r.IntuitionCharge.Payment == "CreditCard" && r.IntuitionCharge.FeeShared == 1).Sum(l => l.LessonPriceType.CoachPayoffCreditCard * l.GroupingLessonDiscount.PercentageOfDiscount / 100) / 2;

    //    return (fullAchievement ?? 0) + (halfAchievement ?? 0);
    //}

</script>
