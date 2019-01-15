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
            <th data-class="expand">兌換時間</th>
            <th>學員姓名</th>
            <th data-hide="phone"><i class="fa fa-fw fa-user text-muted hidden-md hidden-sm hidden-xs"></i>兌換人員</th>
            <th>兌換商品</th>
            <th data-hide="phone">使用日期</th>
            <th data-hide="phone">贈與學員</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <td><%= String.Format("{0:yyyy/MM/dd}",item.AwardDate) %></td>
            <td><%= item.UserProfile.FullName() %></td>
            <td><%= item.Actor.RealName %></td>
            <td><%= item.BonusAwardingItem.ItemName %></td>
            <td><%= item.BonusAwardingItem.BonusAwardingLesson!=null
                        ? item.AwardingLesson!=null
                            ? item.AwardingLesson.RegisterLesson.LessonTime.Count>0
                                ? String.Format("{0:yyyy/MM/dd}",item.AwardingLesson.RegisterLesson.LessonTime.First().ClassTime) 
                                : "--" 
                            : item.AwardingLessonGift.RegisterLesson.LessonTime.Count>0
                                ? String.Format("{0:yyyy/MM/dd}",item.AwardingLessonGift.RegisterLesson.LessonTime.First().ClassTime)
                                : "--"
                        : "--"  %></td>
            <td><%= item.AwardingLessonGift!=null ? item.AwardingLessonGift.RegisterLesson.UserProfile.FullName() : "--" %></td>
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
    IQueryable<LearnerAward> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _tableId = "dt_bonusAward" + DateTime.Now.Ticks;
        _model = (IQueryable<LearnerAward>)this.Model;
    }

</script>
