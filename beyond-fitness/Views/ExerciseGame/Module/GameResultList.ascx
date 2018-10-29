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
        <% var exerciseItem = models.GetTable<ExerciseGameItem>().ToArray(); %>
            <tr>
                <th data-class="expand">參賽者</th>
                <%  foreach (var item in exerciseItem)
                    {  %>
                <th data-hide="phone"><%= item.Exercise %>（積分）</th>
                <%  } %>
                <th data-hide="phone">總積分（積分）</th>
                <th>排名</th>
                <th>查看紀錄</th>
            </tr>
        </thead>
    <tbody>
        <%  var items = models.GetTable<ExerciseGameRank>()
                //.Where(r=>r.RecordID.HasValue)
                .GroupBy(r => r.UID);
            foreach (var g in items)
            {
                var contestant = g.First().ExerciseGameContestant;  %>
            <tr>
                <td nowrap="noWrap">
                    <%= contestant.UserProfile.FullName() %>
                </td>
                <%  foreach (var item in exerciseItem)
                    {
                        var gameRank = g.Where(r => r.ExerciseID == item.ExerciseID).FirstOrDefault();
                        if (gameRank != null)
                        {   %>
                <td nowrap="noWrap" class="text-center">
                            <%  if (item.Unit == "秒")
                                {
                                    if(gameRank.RecordID.HasValue)
                                    {   %>
                            <%= String.Format("{0:00}",(int)gameRank.ExerciseGameResult.Score/60) %>:<%= String.Format("{0:00}",(int)gameRank.ExerciseGameResult.Score%60) %>
                            <%      }
                                    else
                                    {
                                        Writer.Write("--");
                                    }
                                }
                                else
                                { %>
                            <%= gameRank.RecordID.HasValue ? gameRank.ExerciseGameResult.Score.ToString() : "--" %> 
                            <%  } %>
                            <%  if (gameRank.RankingScore.HasValue)
                                {   %>
                                    <span class="badge bg-color-pink"><%= gameRank.RankingScore %>P</span>
                            <%  }
                                else
                                { %>
                                    <%--<span class="badge bg-color-yellow">0P</span>--%>
                            <%  } %>
                </td>
                <%      }
                        else
                        {   %>
                <td nowrap="noWrap" class="text-center">-- <%--<span class="badge bg-color-yellow">0P</span>--%></td>
                <%      }    %>
                <%  } %>
                <td nowrap="noWrap" class="text-center">
                    <%  var personalRank = contestant.ExerciseGamePersonalRank; %>
                    <%= personalRank != null ? personalRank.TotalScope : 0 %>
                </td>
                <td class="text-center">
                    <%  if (personalRank != null)
                        { %>
                    <%= personalRank.Rank %>
                    <%  }
                        else
                        {
                            Writer.Write("--");
                        } %>
                    <%  if (contestant.Status == (int)Naming.GeneralStatus.Failed)
                        { %>
                        <span class="badge bg-color-red txt-color-white"><i class="fa fa-fw fa-h-square"></i> 退賽</span>
                    <%  } %>
                </td>
                <td>
                    <a onclick="showContestantRecord(<%= contestant.UID %>);" class="btn btn-circle bg-color-green"><i class="fa fa-fw fa-list-ol"></i></a>
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
            "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l>r>" +
                    "t" +
                    "<'dt-toolbar-footer'<'col-sm-6 col-xs-12 hidden-xs'i><'col-xs-12 col-sm-6'p>>",
            "autoWidth": false,
            "order": [6],
            "lengthMenu": [[10, 30, 50, -1], [10, 30, 50, "全部"]],
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
    String _tableId = "dt_gameResult" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
