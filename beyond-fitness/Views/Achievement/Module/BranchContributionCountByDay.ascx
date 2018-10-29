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
            <th>日期</th>
            <th>續約合約比例</th>
            <th data-hide="phone">續約合約總金額</th>
            <th>新合約比例</th>
            <th data-hide="phone">新合約總金額</th>
            <th data-hide="phone">P.I比例</th>
            <th>P.I總金額</th>
            <th data-hide="phone">其他比例</th>
            <th>其他總金額</th>
            <th data-hide="phone">總計金額</th>
        </tr>
    </thead>
    <tbody>
        <%  
            IQueryable<TuitionAchievement> items, contractItems, newContractItems, renewalContractItems, piSessionItems, otherItems;
            decimal achievement;
            var totalCount = _model.Count();
            if (totalCount > 0)
            {
                for (DateTime startDate = _viewModel.AchievementDateFrom.Value; startDate < _viewModel.AchievementDateTo.Value.AddDays(1); startDate = startDate.AddDays(1))
                {
                    foreach (var branch in models.GetTable<BranchStore>())
                    {
                        items = _model.Where(t => t.Payment.PayoffDate >= startDate && t.Payment.PayoffDate < startDate.AddDays(1))
                            .Where(t => t.Payment.PaymentTransaction.BranchID == branch.BranchID);
                        var count = items.Count();

                        var coachAchievement = items.Sum(t => t.ShareAmount) ?? 0m;

                        contractItems = items.Where(t => t.Payment.ContractPayment != null);
                        newContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == false);
                        renewalContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == true
                                                    || !t.Payment.ContractPayment.CourseContract.Renewal.HasValue);
                        piSessionItems = items.Where(t => t.Payment.TransactionType == (int)Naming.PaymentTransactionType.自主訓練);
                        otherItems = items.Where(t => t.Payment.TransactionType != (int)Naming.PaymentTransactionType.體能顧問費
                                                        && t.Payment.TransactionType != (int)Naming.PaymentTransactionType.自主訓練);
        %>
        <tr>
            <td><%= branch.BranchName %></td>
            <td><%= $"{startDate:yyyy/MM/dd}" %></td>
            <td nowrap="noWrap" class="text-center">
                <%  var renewalCount = renewalContractItems.Select(t => t.Payment.ContractPayment.CourseContract.ContractID)
                        .Distinct().Count();
                    achievement = renewalContractItems.Sum(t => t.ShareAmount) ?? 0;
                    if (count > 0 && achievement > 0)
                    { %>
                <%= Math.Round(achievement * 100m / coachAchievement) %>%
                <%  }
                    else
                    { %>
                --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  
                    if (achievement > 0)
                    {
                %>
                <%= $"{achievement:##,###,###}" %>
                <%  }
                    else
                    { %>
                --
                <%  } %>
            </td>

            <td nowrap="noWrap" class="text-center">
                <%  var newCount = newContractItems.Select(t => t.Payment.ContractPayment.CourseContract.ContractID)
                        .Distinct().Count();
                    achievement = newContractItems.Sum(t => t.ShareAmount) ?? 0;
                    if (count > 0 && achievement > 0)
                    { %>
                <%= Math.Round(achievement * 100m / coachAchievement) %>%
                <%  }
                    else
                    { %>
                --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  
                    if (achievement > 0)
                    {
                %>
                <%= $"{achievement:##,###,###}" %>
                <%  }
                    else
                    { %>
                --
                <%  } %>
            </td>

            <td nowrap="noWrap" class="text-center">
                <%  var piCount = piSessionItems.Count();
                    achievement = piSessionItems.Sum(t => t.ShareAmount) ?? 0;
                    if (count > 0 && piCount > 0)
                    { %>
                <%= Math.Round(achievement * 100m / coachAchievement) %>%
                <%  }
                    else
                    { %>
                --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  
                    if (piCount > 0)
                    {
                %>
                <%= $"{achievement:##,###,###}" %>
                <%  }
                    else
                    { %>
                --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-center">
                <%  var otherCount = otherItems.Count();
                    achievement = otherItems.Sum(t => t.ShareAmount) ?? 0;
                    if (count > 0 && otherCount > 0)
                    { %>
                <%= Math.Round(achievement * 100m / coachAchievement) %>%
                <%  }
                    else
                    { %>
                --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  
                    if (otherCount > 0)
                    {
                %>
                <%= $"{achievement:##,###,###}" %>
                <%  }
                    else
                    { %>
                --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-right">
                <%  
                    if (count > 0)
                    {
                %>
                <%= $"{coachAchievement:##,###,###}" %>
                <%  }
                    else
                    { %>
                --
                <%  } %>
            </td>
        </tr>
        <%          }
                }
            }
        %>
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

<%  if (_viewModel.AchievementDateFrom.HasValue || _viewModel.AchievementDateTo.HasValue)
    { %>
        $('.achievement').text('(<%= String.Format("{0:yyyy/MM/dd}", _viewModel.AchievementDateFrom) %>~<%= String.Format("{0:yyyy/MM/dd}", _viewModel.AchievementDateTo) %>)');
<%  }   %>
    });

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "lesson" + DateTime.Now.Ticks;
    IQueryable<TuitionAchievement> _model;
    AchievementQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<TuitionAchievement>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }

</script>
