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
            <th data-class="expand"><i class="fa fa-fw fa-user text-muted hidden-md hidden-sm hidden-xs"></i>姓名</th>
            <th data-hide="phone"><i class="fa fa-fw fa-phone text-muted hidden-md hidden-sm hidden-xs"></i>聯絡電話</th>
            <th data-hide="phone"><i class="fa fa-fw fa-envelope text-muted hidden-md hidden-sm hidden-xs"></i>Email Address</th>
            <th data-hide="phone">編號</th>
            <%--<th data-hide="phone">剩餘/購買堂數</th>--%>
            <th>狀態</th>
            <th>功能</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <td><%= item.FullName() %></td>
            <td><%= item.Phone %></td>
            <td><%= item.LevelID == (int)Naming.MemberStatus.尚未註冊 || item.UserProfileExtension.CurrentTrial==1 ? "--" : item.PID %></td>
            <td><%= item.UserProfileExtension.CurrentTrial==1 ? "體驗學員" : item.MemberCode %></td>
            <%--<td><%  if(item.UserProfileExtension.CurrentTrial==1)
                    {
                        Writer.Write("體驗學員");
                    }
                    else
                    { 
                        var items = item.RegisterLesson.Where(l => l.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
                            .Where(l=>l.RegisterGroupID.HasValue);
                        int? totalLessons = items.Sum(l => l.Lessons);
                        int? attended = 
                            items.Sum(l => l.GroupingLesson.LessonTime.Count(/*t => t.LessonAttendance != null*/))
                            + items.Sum(l => l.AttendedLessons);
                        Writer.Write(totalLessons - attended);  %> / 
                    <%  
                        Writer.Write(totalLessons);
                    }   %></td>--%>
            <td><%= item.UserProfileExtension.CurrentTrial==1 ? "--" : ((Naming.MemberStatus)item.LevelID).ToString() %></td>
            <td nowrap="noWrap">
                <a onclick="$global.editLearner(<%= item.UID %>);" class="btn btn-circle bg-color-yellow"><i class="fa fa-fw fa fa-lg fa-edit" aria-hidden="true"></i></a>&nbsp;&nbsp;
                <%  if (!item.UserProfileExtension.CurrentTrial.HasValue)
                    { %>
                <a onclick="$global.editPDQ(<%= item.UID %>);" class="btn btn-circle bg-color-green modifyPDQDialog_link"><i class="fa fa-fw fa fa-lg fa-street-view " aria-hidden="true"></i></a>&nbsp;&nbsp;   
                        <%  if (_profile.IsAssistant() || _profile.IsManager() || _profile.IsViceManager() || _profile.IsOfficer())
                            { %>
                <a onclick="$global.listAdvisor(<%= item.UID %>);" class="btn btn-circle bg-color-blueLight"><i class="far fa-fw fa-lg fa-address-book" aria-hidden="true"></i></a>&nbsp;&nbsp;   
                        <%  } %>
                <%  } %>
                <%  if (_profile.IsAssistant() || _profile.IsManager() || _profile.IsViceManager() || _profile.IsOfficer())
                    {
                        if (item.LevelID == (int)Naming.MemberStatus.已註冊 || item.LevelID == (int)Naming.MemberStatus.尚未註冊)
                        { %>
                        <a onclick="$global.deleteLearner(<%= item.UID %>);" class="btn btn-circle bg-color-red delete"><i class="fa fa-fw fa fa-lg fa-trash-alt" aria-hidden="true"></i></a>
                <%      }
                        else
                        { %>
                        <a onclick="$global.enableLearner(<%= item.UID %>);" class="btn btn-circle bg-color-red"><i class="far fa-fw fa-lg fa-check-square" aria-hidden="true"></i></a>
                <%      }
                    }
                    if (!item.UserProfileExtension.CurrentTrial.HasValue)
                    { %>
                    <a onclick="$global.resetPassword('<%= item.UID.EncryptKey() %>');" class="btn btn-circle bg-color-pink forget"><i class="fa fa-fw fa fa-lg fa-key" aria-hidden="true"></i> </a>
                <%  } %>
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
    IQueryable<UserProfile> _model;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<UserProfile>)this.Model;
        _model = _model.OrderByDescending(u => u.LevelID);
        _tableId = "dt_learner" + DateTime.Now.Ticks;
        _profile = Context.GetUser();
    }

</script>
