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
            <th>學員</th>
            <th>合約名稱</th>
            <th data-hide="phone">全價計算堂數 / 半價計算堂數</th>
        </tr>
    </thead>
    <tbody>
        <%  var items = _model.Where(t => t.RegisterLesson.RegisterLessonContract != null)
                .GroupBy(t => new { ContractID = t.RegisterLesson.RegisterLessonContract.ContractID });
            foreach(var item in items)
            {
                CourseContract contract = models.GetTable<CourseContract>().Where(u => u.ContractID == item.Key.ContractID).First(); %>
                <tr>
                    <td nowrap="noWrap"><%= contract.ContractNo + "-" + String.Format("{0:00}",contract.SequenceNo) %></td>
                    <td nowrap="noWrap"><%= contract.CourseContractExtension.BranchStore.BranchName %></td>
                    <td nowrap="noWrap">
                        <%  if (contract.CourseContractType.IsGroup==true)
                            { %>
                        <%= String.Join("/",contract.CourseContractMember.Select(m=>m.UserProfile.RealName)) %>
                        <%  }
                            else
                            { %>
                        <%= contract.ContractOwner.FullName() %>
                        <%  } %></td>
                    <td><%= contract.CourseContractType.TypeName %>(<%= contract.LessonPriceType.DurationInMinutes %>分鐘)</td>
                    <td><%  var halfCount = item.Count(t => t.LessonAttendance == null || !t.LessonPlan.CommitAttendance.HasValue); %>
                        <%= item.Count()-halfCount %> / <%= halfCount %>
                    </td>
                </tr>
        <%  } %>
        <%  var enterprise = _model.Where(t => t.RegisterLesson.RegisterLessonEnterprise != null
                    && t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
                .GroupBy(t => new
                {
                    ContractID = t.RegisterLesson.RegisterLessonEnterprise.ContractID,
                    t.RegisterID
                });
            foreach(var item in enterprise)
            {
                EnterpriseCourseContract contract = models.GetTable<EnterpriseCourseContract>().Where(u => u.ContractID == item.Key.ContractID).First();
                                RegisterLesson lesson = models.GetTable<RegisterLesson>().Where(g => g.RegisterID == item.Key.RegisterID).First();  %>
        <tr>
            <td nowrap="noWrap"><%= contract.ContractNo %></td>
            <td nowrap="noWrap"><%= contract.BranchStore.BranchName %></td>
            <td nowrap="noWrap"><%= String.Join("/",lesson.GroupingLesson.RegisterLesson.Select(m=>m.UserProfile).Select(u=>u.FullName())) %></td>
            <td><%= contract.Subject %></td>
            <td><%  var halfCount = item.Count(t => t.LessonAttendance == null || !t.LessonPlan.CommitAttendance.HasValue); %>
                <%= item.Count()-halfCount %> / <%= halfCount %>
            </td>
        </tr>
        <%  } %>
        <%  var others = _model.Where(t => t.RegisterLesson.RegisterLessonContract == null 
                        && t.RegisterLesson.RegisterLessonEnterprise == null
                        && t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練);
            foreach(var item in others)
            {
                 %>
        <tr>
            <td nowrap="noWrap">--</td>
            <td nowrap="noWrap"><%= item.BranchID.HasValue ? item.BranchStore.BranchName : "其他" %></td>
            <td nowrap="noWrap"><%= item.RegisterLesson.UserProfile.FullName() %></td>
            <td><%= item.RegisterLesson.LessonPriceType.Description  %>(<%= item.RegisterLesson.LessonPriceType.DurationInMinutes %>分鐘)</td>
            <td><%  var halfCount = item.LessonAttendance == null || !item.LessonPlan.CommitAttendance.HasValue ? 1 : 0 ; %>
                <%= 1-halfCount %> / <%= halfCount %>
            </td>
        </tr>
        <%  } %>
        <%  var PISession = _model
                .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自主訓練
                        || (t.RegisterLesson.RegisterLessonEnterprise != null
                            && t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.DocumentLevelDefinition.自主訓練))
                .Select(t => new { t.BranchID, t.RegisterLesson.UID, PISession = t })
                .GroupBy(g => new { g.BranchID, g.UID });

            foreach(var item in PISession)
            {
                var branch = models.GetTable<BranchStore>().Where(b => b.BranchID == item.Key.BranchID).First();
                var profile = models.GetTable<UserProfile>().Where(u => u.UID == item.Key.UID).First();
                %>
        <tr>
            <td nowrap="noWrap">--</td>
            <td nowrap="noWrap"><%= branch.BranchName %></td>
            <td nowrap="noWrap"><%= profile.FullName() %></td>
            <td>P.I. Session</td>
            <td>
                <%= (decimal)item.Count() / 2m %>
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
            "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l>r>" +
                                     "t" +
                                     "<'dt-toolbar-footer'<'col-sm-6 col-xs-12 hidden-xs'i><'col-xs-12 col-sm-6'p>>",
            "autoWidth": false,
            "order": [],
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
    String _tableId = "attendanceAchievement" + DateTime.Now.Ticks;
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
