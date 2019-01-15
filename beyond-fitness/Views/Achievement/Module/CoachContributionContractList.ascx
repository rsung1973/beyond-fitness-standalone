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
            <th>續約合約比例</th>
            <th data-hide="phone">續約合約張數</th>
            <th>新合約比例</th>
            <th data-hide="phone">新合約張數</th>
            <th data-hide="phone">總計</th>
        </tr>
    </thead>
    <tbody>
        <%
            IQueryable<CourseContract>  contractItems, newContractItems, renewalContractItems, piSessionItems, otherItems;
            int calcCount,count;
            var totalCount = _model.Count();
            if (totalCount > 0)
            {
                foreach (var coach in models.GetTable<ServingCoach>().Where(s => _viewModel.ByCoachID.Contains(s.CoachID)))
                {
                    contractItems = _model.Where(t => t.FitnessConsultant == coach.CoachID);
                    count = contractItems.Count();

                    newContractItems = contractItems.Where(t => t.Renewal == false);
                    renewalContractItems = contractItems.Where(t => t.Renewal == true
                                                || !t.Renewal.HasValue);
        %>
        <tr>
            <td><%= coach.UserProfile.FullName() %></td>
            <td nowrap="noWrap" class="text-center">
                <%  calcCount = renewalContractItems.Count();
                    if (count > 0 && calcCount > 0)
                    { %>
                <%= Math.Round(calcCount * 100m / count) %>%
                <%  }
                    else
                    { %>
                --
                <%  } %></td>
            <td nowrap="noWrap" class="text-center"><%= calcCount>0 ? calcCount.ToString() : "--" %></td>
            <td nowrap="noWrap" class="text-center">
                <%  calcCount = newContractItems.Count();
                    if (count > 0 && calcCount > 0)
                    { %>
                <%= Math.Round(calcCount * 100m / count) %>%
                <%  }
                    else
                    { %>
                --
                <%  } %></td>
            <td nowrap="noWrap" class="text-center"><%= calcCount>0 ? calcCount.ToString() : "--" %></td>
            <td nowrap="noWrap" class="text-right"><%= count>0 ? count.ToString() : "--" %></td>
        </tr>
        <%  } %>
    </tbody>
    <tfoot>
        <%  
            contractItems = _model;
            newContractItems = contractItems.Where(t => t.Renewal == false);
            renewalContractItems = contractItems.Where(t => t.Renewal == true
                                        || !t.Renewal.HasValue);
        %>
        <tr>
            <td class="text-right">總計</td>
            <td nowrap="noWrap" class="text-center">
                <%  count = contractItems.Count();

                    calcCount = renewalContractItems.Count();
                    if (calcCount > 0)
                    { %>
                <%= Math.Round(calcCount * 100m / count) %>%
                <%  }
                    else
                    { %>
                --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-center"><%= calcCount>0 ? calcCount.ToString() : "--" %></td>
            <td nowrap="noWrap" class="text-center">
                <%  calcCount = newContractItems.Count();
                    if (calcCount > 0 )
                    { %>
                <%= Math.Round(calcCount * 100m / count) %>%
                <%  }
                    else
                    { %>
                --
                <%  } %>
            </td>
            <td nowrap="noWrap" class="text-center"><%= calcCount>0 ? calcCount.ToString() : "--" %></td>
            <td nowrap="noWrap" class="text-right">
                <%= count>0 ? count.ToString() : "--" %>
            </td>
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
            "ordering": true,
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

<%  if (_model.Count() > 0)
    {  %>
        $('#btnDownloadAchievement').css('display', 'inline');
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
    String _tableId = "contract" + DateTime.Now.Ticks;
    IQueryable<CourseContract> _model;
    AchievementQueryViewModel _viewModel;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<CourseContract>)this.Model;
        _viewModel = (AchievementQueryViewModel)ViewBag.ViewModel;
    }


</script>
