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
            <th data-class="expand">處理代碼</th>
            <%--<th data-hide="phone,tablet">信託契約編號</th>--%>
            <th data-hide="phone">入會契約編號</th>
            <th data-hide="phone">買受人證號</th>
            <th>姓名</th>
            <th data-hide="phone,tablet">通訊地址</th>
            <th data-hide="phone,tablet">電話(H)</th>
            <th data-hide="phone">轉出買受人証號</th>
            <th>當期信託金額</th>
            <th>信託餘額</th>
            <th data-hide="phone">契約總價金</th>
            <th data-hide="phone,tablet">契約起日</th>
            <th data-hide="phone,tablet">契約迄日</th>
        </tr>
    </thead>
    <tbody>
        <%  
            //System.Diagnostics.Debugger.Launch();
            //var st = _model.Where(t => t.TrustType == "S").FirstOrDefault();
            foreach (var item in _model.GroupBy(t => t.ContractID))
            {
                var contract = models.GetTable<CourseContract>().Where(c => c.ContractID == item.Key).First();
                var settlement = models.GetTable<ContractTrustSettlement>().Where(s => s.ContractID == item.Key && s.SettlementID == item.First().SettlementID).First();
                var initialTrustAmount = settlement.InitialTrustAmount==0 ? contract.TotalCost : settlement.InitialTrustAmount; //settlement.BookingTrustAmount;
                %>
            <%  var amt = item.Where(t => t.TrustType == "B").Sum(t => t.Payment.PayoffAmount);
                if (amt.HasValue && amt > 0 && settlement.InitialTrustAmount == 0)
                { %>
            <tr>
                <td>B</td>
                <%--<td></td>--%>
                <td><%= contract.ContractNo() %></td>
                <td><%= contract.ContractOwner.UserProfileExtension.IDNo %></td>
                <td><%= contract.ContractOwner.RealName %></td>
                <td><%= contract.ContractOwner.Address() %></td>
                <td><%= contract.ContractOwner.Phone %></td>
                <td><%--<%  if (item.TrustType == Naming.TrustType.T.ToString())
                        {   %>
                    <%= item.CourseContract.CourseContractExtension.CourseContractRevision.SourceContract.ContractOwner.UserProfileExtension.IDNo %>
                    <%  } %>--%>
                </td>
                <td nowrap="noWrap" class="text-right">
                    <%  //initialTrustAmount += amt.Value; %>
                    <%= settlement.InitialTrustAmount == 0 ? String.Format("{0:##,###,###,##0}", contract.TotalCost.AdjustTrustAmount()) : null  %>
                </td>
                <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", initialTrustAmount.AdjustTrustAmount())   %></td>
                <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", contract.TotalCost.AdjustTrustAmount())   %></td>
                <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", contract.ValidFrom) %></td>
                <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", contract.Expiration) %></td>
            </tr>  
            <%  } %>
            <%  amt = item.Where(t => t.TrustType == "T").Sum(t => t.Payment.PayoffAmount);
                if (amt.HasValue && amt > 0)
                { %>
            <tr>
                <td>T</td>
                <%--<td></td>--%>
                <td><%= contract.ContractNo() %></td>
                <td><%= contract.ContractOwner.UserProfileExtension.IDNo %></td>
                <td><%= contract.ContractOwner.RealName %></td>
                <td><%= contract.ContractOwner.Address() %></td>
                <td><%= contract.ContractOwner.Phone %></td>
                <td>
                    <%= contract.CourseContractExtension.CourseContractRevision.SourceContract.ContractOwner.UserProfileExtension.IDNo %>
                </td>
                <td nowrap="noWrap" class="text-right">
                    <%  //initialTrustAmount += amt.Value; %>
                    <%= String.Format("{0:##,###,###,##0}", amt.AdjustTrustAmount())   %>
                </td>
                <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", initialTrustAmount.AdjustTrustAmount())   %></td>
                <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", contract.TotalCost.AdjustTrustAmount())   %></td>
                <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", contract.ValidFrom) %></td>
                <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", contract.Expiration) %></td>
            </tr>
            <%  } %>
            <%  amt = item.Where(t => t.TrustType == "N").Select(t => t.LessonTime.RegisterLesson)
                    .Sum(lesson => lesson.LessonPriceType.ListPrice * lesson.GroupingMemberCount * lesson.GroupingLessonDiscount.PercentageOfDiscount / 100);
                if (amt.HasValue && amt > 0)
                { %>
            <tr>
            <td>N</td>
            <%--<td></td>--%>
            <td><%= contract.ContractNo() %></td>
            <td><%= contract.ContractOwner.UserProfileExtension.IDNo %></td>
            <td><%= contract.ContractOwner.RealName %></td>
            <td><%= contract.ContractOwner.Address() %></td>
            <td><%= contract.ContractOwner.Phone %></td>
            <td>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  initialTrustAmount -= amt.Value; %>
                <%= String.Format("({0:##,###,###,##0})", amt.AdjustTrustAmount())   %>
            </td>
            <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", initialTrustAmount.AdjustTrustAmount())   %></td>
            <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", contract.TotalCost.AdjustTrustAmount())   %></td>
            <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", contract.ValidFrom) %></td>
            <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", contract.Expiration) %></td>
        </tr>
            <%  } %>
            <%  //amt = item.Where(t => t.TrustType == "V")
                //    .Select(t => t.VoidPayment.Payment)
                //    .Sum(p => p.PayoffAmount);
                amt = 0;
                if (amt.HasValue && amt > 0 && settlement.InitialTrustAmount == 0)
                { %>
            <tr>
            <td>N</td>
            <%--<td></td>--%>
            <td><%= contract.ContractNo() %></td>
            <td><%= contract.ContractOwner.UserProfileExtension.IDNo %></td>
            <td><%= contract.ContractOwner.RealName %></td>
            <td><%= contract.ContractOwner.Address() %></td>
            <td><%= contract.ContractOwner.Phone %></td>
            <td>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  initialTrustAmount -= amt.Value; %>
                <%= String.Format("({0:##,###,###,##0})", amt.AdjustTrustAmount())   %>
            </td>
            <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", initialTrustAmount.AdjustTrustAmount())   %></td>
            <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", contract.TotalCost.AdjustTrustAmount())   %></td>
            <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", contract.ValidFrom) %></td>
            <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", contract.Expiration) %></td>
        </tr>
            <%  } %>
        <%  amt = -item.Where(t => t.TrustType == "X").Sum(t => t.Payment.PayoffAmount);
                if (amt.HasValue && amt > 0)
                { %>
            <tr>
                <td>X</td>
                <%--<td></td>--%>
                <td><%= contract.ContractNo() %></td>
                <td><%= contract.ContractOwner.UserProfileExtension.IDNo %></td>
                <td><%= contract.ContractOwner.RealName %></td>
                <td><%= contract.ContractOwner.Address() %></td>
                <td><%= contract.ContractOwner.Phone %></td>
                <td>
                    <%--<%= contract.CourseContractExtension.CourseContractRevision.SourceContract.ContractOwner.UserProfileExtension.IDNo %>--%>
                </td>
                <td nowrap="noWrap" class="text-right">
                    <%  initialTrustAmount -= amt.Value; %>
                    <%= String.Format("({0:##,###,###,##0})", amt.AdjustTrustAmount())   %>
                </td>
                <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", initialTrustAmount.AdjustTrustAmount())   %></td>
                <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", contract.TotalCost.AdjustTrustAmount())   %></td>
                <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", contract.ValidFrom) %></td>
                <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", contract.Expiration) %></td>
            </tr>
            <%  } %>
            <%  amt = item.Where(t => t.TrustType == "S").Sum(t => t.ReturnAmount);
                if (amt.HasValue && amt > 0)
                { %>
            <tr>
                <td>S</td>
                <%--<td></td>--%>
                <td><%= contract.ContractNo() %></td>
                <td><%= contract.ContractOwner.UserProfileExtension.IDNo %></td>
                <td><%= contract.ContractOwner.RealName %></td>
                <td><%= contract.ContractOwner.Address() %></td>
                <td><%= contract.ContractOwner.Phone %></td>
                <td>
                    <%--<%= contract.CourseContractExtension.CourseContractRevision.SourceContract.ContractOwner.UserProfileExtension.IDNo %>--%>
                </td>
                <td nowrap="noWrap" class="text-right">
                    <%  initialTrustAmount -= amt.Value; %>
                    <%= String.Format("({0:##,###,###,##0})", amt.AdjustTrustAmount())   %>
                </td>
                <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", initialTrustAmount.AdjustTrustAmount())   %></td>
                <td nowrap="noWrap" class="text-right"><%= String.Format("{0:##,###,###,##0}", contract.TotalCost.AdjustTrustAmount())   %></td>
                <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", contract.ValidFrom) %></td>
                <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", contract.Expiration) %></td>
            </tr>
            <%  } %>
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
            "ordering": false,
            //"order": [[1,'asc']],
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

<%  if(_model.Count()>0)
    {  %>
        $('#btnDownloadTrustTrack').css('display', 'inline');
        $('#btnDownloadTrustContract').css('display', 'inline');
        //$('#btnDownloadTrustLesson').css('display', 'inline');
<%  }  %>

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "contractTrust" + DateTime.Now.Ticks;
    IQueryable<ContractTrustTrack> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<ContractTrustTrack>)this.Model;
    }

</script>
