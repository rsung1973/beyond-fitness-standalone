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
            <th>體能顧問</th>
            <th>學員</th>
            <th data-class="expand"><i class="fa fa-fw fa-calendar-plus-o text-muted hidden-md hidden-sm hidden-xs"></i>購買日期</th>
            <th data-hide="phone">課程類型</th>
            <th data-hide="phone">團體課程</th>
            <th data-hide="phone" style="width: 80px">剩餘/購買</th>
            <th data-hide="phone, tablet" style="width: 80px" data-hide="phone">付款方式</th>
            <th data-hide="phone, tablet" style="width: 50px" data-hide="phone">分期</th>
            <th>應付總金額</th>
            <th data-hide="phone">實付總金額</th>
            <th>欠款總金額</th>
            <th data-hide="phone, tablet">付款紀錄</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
                <tr>
                    <td><%= item.AdvisorID.HasValue ?  item.ServingCoach.UserProfile.RealName : null %></td>
                    <td><%= item.UserProfile.FullName() %></td>
                    <td><%= item.RegisterDate.ToString("yyyy/MM/dd") %></td>
                    <td>
                        <%= item.LessonPriceType.Description %>                        
                    </td>
                    <td>
                        <%= item.GroupingMemberCount > 1 ? "是" : "否" %>
                        <%  if (item.GroupingMemberCount > 1)
                            {
                                if (!item.RegisterGroupID.HasValue)
                                {
                                    item.GroupingLesson = new GroupingLesson { };
                                    models.SubmitChanges();
                                }%>
                        <ul class="list-inline friends-list">
                            <%  foreach (var g in item.GroupingLesson.RegisterLesson.Where(r=>r.RegisterID!=item.RegisterID))
                                { %>
                            <li><%= g.UserProfile.FullName() %></li>
                            <%  } %>
                        </ul>
                        <%  } %>
                    </td>
                    <td><%= item.Lessons - (item.AttendedLessons ?? 0)
                                - item.GroupingLesson.LessonTime.Count(/*t=>t.LessonAttendance!= null*/) %> / <%= item.Lessons %></td>
                    <td><%= item.IntuitionCharge.Payment=="Cash" ? "現金" : "信用卡" %></td>
                    <td><%= item.IntuitionCharge.ByInstallments>1 ? item.IntuitionCharge.ByInstallments+"期" : "否" %></td>
                    <td><% var subtotal = item.Lessons * item.LessonPriceType.ListPrice * item.GroupingLessonDiscount.PercentageOfDiscount / 100;
                            Writer.Write(String.Format("{0:##,###,###,###}", subtotal)); %></td>
                    <td><% var payoffAmt = item.IntuitionCharge.TuitionInstallment.Where(t => t.PayoffDate.HasValue).Sum(t => t.PayoffAmount);
                            Writer.Write(String.Format("{0:##,###,###,###}", payoffAmt));  %></td>
                    <td><%  Writer.Write(String.Format("{0:##,###,###,###}", subtotal-payoffAmt)); %></td>
                    <td><%  if(item.IntuitionCharge!=null)
                            {
                                if (item.IntuitionCharge.ByInstallments > 1)
                                {
                                    Writer.WriteLine("已付期數:" + item.IntuitionCharge.TuitionInstallment.Count);
                                }
                                foreach (var t in item.IntuitionCharge.TuitionInstallment)
                                { %>
                                    <%= t.PayoffDate.HasValue ? String.Format("{0:yyyy/MM/dd}",t.PayoffDate) : "尚未付款" %><%= t.PayoffAmount.HasValue ? "《"+ String.Format("{0:##,###,###,###}",t.PayoffAmount)+ "》" : null %><br />
                        <%          
                                }
                            }
                            else
                            {   %>
                                    尚未付款
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
    IQueryable<RegisterLesson> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _tableId = ViewBag.DataTableId ?? "dt_basic";
        _model = (IQueryable<RegisterLesson>)this.Model;
    }

</script>
