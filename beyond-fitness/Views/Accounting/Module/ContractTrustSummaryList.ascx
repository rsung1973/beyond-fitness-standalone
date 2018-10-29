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
            <th>信託期初金額</th>
            <th data-hide="phone">T(轉入）</th>
            <th data-hide="phone">B(新增)</th>
            <th data-hide="phone">N(返還)</th>
            <th data-hide="phone">S(終止)</th>
            <th data-hide="phone">X(轉讓)</th>
            <th data-hide="phone">收/付金額</th>
            <th>信託期末金額</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _items)
            {
                %>
        <tr>
            <td nowrap="noWrap" class="text-right">
                <%  var totalInitialAmt = item.ContractTrustSettlement.Sum(s => s.InitialTrustAmount);
                    var totalTrustAmt = item.ContractTrustSettlement.Sum(s => s.TotalTrustAmount);
                    var totalBookingAmt = item.ContractTrustSettlement.Sum(s => s.BookingTrustAmount);%>
                <%= String.Format("{0:##,###,###,##0}",totalInitialAmt.AdjustTrustAmount()) %></td>
            <td nowrap="noWrap" class="text-right">
                <%  var totalAmt =  item.ContractTrustTrack.Where(t => t.TrustType == "T").Sum(t => t.Payment.PayoffAmount);
                    int T_Amt = totalAmt ?? 0;  %>
                <%= totalAmt.HasValue && totalAmt!=0  ? String.Format("{0:##,###,###,##0}",totalAmt.AdjustTrustAmount()) : "--" %>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  totalAmt = item.ContractTrustSettlement.Where(s => s.InitialTrustAmount == 0)
                            .Join(_model.Where(t => t.TrustType == "B").Select(t => t.ContractID).Distinct(), s => s.ContractID, t => t, (s, t) => s)
                            .Select(s => s.CourseContract).Sum(c => c.TotalCost); //item.ContractTrustTrack.Where(t => t.TrustType == "B").Sum(t => t.Payment.PayoffAmount); 
                    int B_Amt = totalAmt ?? 0;  %>
                <%= totalAmt.HasValue ? String.Format("{0:##,###,###,##0}",totalAmt.AdjustTrustAmount()) : "--" %>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%   totalAmt = (item.ContractTrustTrack
                     .Where(t => t.TrustType == "N")
                     .Select(t => t.LessonTime.RegisterLesson)
                     .Sum(lesson => lesson.LessonPriceType.ListPrice * lesson.GroupingMemberCount * lesson.GroupingLessonDiscount.PercentageOfDiscount / 100) ?? 0);
                    //+ (item.ContractTrustTrack.Where(t => t.TrustType == "V")
                    //.Select(t=>t.VoidPayment.Payment)
                    // .Sum(p => p.PayoffAmount) ?? 0); 
                    int N_Amt = totalAmt ?? 0; %>
                <%= totalAmt.HasValue && totalAmt!=0 ? String.Format("({0:##,###,###,##0})",totalAmt.AdjustTrustAmount()) : "--" %>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  totalAmt = -item.ContractTrustTrack.Where(t => t.TrustType == "S").Sum(t => t.Payment.PayoffAmount);
                    int S_Amt = totalAmt ?? 0;  %>
                <%= totalAmt.HasValue && totalAmt!=0  ? String.Format("({0:##,###,###,##0})",totalAmt.AdjustTrustAmount()) : "--" %>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  totalAmt = -item.ContractTrustTrack.Where(t => t.TrustType == "X").Sum(t => t.Payment.PayoffAmount);
                    int X_Amt = totalAmt ?? 0;%>
                <%= totalAmt.HasValue && totalAmt!=0  ? String.Format("({0:##,###,###,##0})",totalAmt.AdjustTrustAmount()) : "--" %>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  totalAmt = totalBookingAmt-totalInitialAmt;
                    totalAmt = B_Amt + T_Amt - N_Amt - S_Amt - X_Amt; %>
                <%= totalAmt>=0 ? String.Format("{0:##,###,###,##0}",totalAmt.AdjustTrustAmount()) : String.Format("({0:##,###,###,##0})",-totalAmt.AdjustTrustAmount()) %>
            </td>
            <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}",totalBookingAmt.AdjustTrustAmount()) %></td>
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

<%  if(_items.Count()>0)
    {  %>
        $('#btnDownloadTrustSummary').css('display', 'inline');
<%  }  %>

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "trustSummary" + DateTime.Now.Ticks;
    IQueryable<Settlement> _items;
    IQueryable<ContractTrustTrack> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<ContractTrustTrack>)this.Model;
        _items = (IQueryable<Settlement>)ViewBag.DataItems;
    }

</script>
