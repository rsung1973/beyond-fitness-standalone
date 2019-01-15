<%@  Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table id="<%= _tableId %>" class="table" width="100%">
    <thead>
        <tr>
            <%  if (ViewBag.ShowOnly != true)
                { %>
            <th style="width: 180px" rowspan="2">
                <button type="button" onclick="updateSequence();" class="btn bg-color-pink btn-xs">
                    <i class="fa fa-refresh"></i>更新排序
                </button>
            </th>
            <th data-class="expand" class="col-xs-4 col-sm-4">動作</th>
            <th data-hide="phone">實際/目標次數</th>
            <th data-hide="phone">實際/目標強度</th>
<%--            <th data-hide="phone">加強說明/評論</th>--%>
            <%  } else { %>
            <th data-class="expand" class="col-xs-4 col-sm-4" rowspan="2">動作</th>
            <th data-hide="phone" class="col-xs-4 col-sm-4">實際/目標次數</th>
            <th data-hide="phone" class="col-xs-4 col-sm-4">實際/目標強度</th>
            <%--<th data-hide="phone">加強說明/評論</th>--%>
            <%  } %>
        </tr>
        <tr>
            <th colspan="3">加強說明/評論</th>
        </tr>
    </thead>
    <tbody>
        <%  var items = _model.TrainingItem.OrderBy(t => t.Sequence);
            foreach (var item in items )
            {
                Html.RenderPartial("~/Views/Lessons/SingleTrainingItem.ascx", item);
            }  %>
    </tbody>
    <%  if (ViewBag.ShowOnly != true)
        { %>
    <tfoot>
        <tr>
            <td>
                <button type="button" class="btn bg-color-orange btn-xs" onclick="addTrainingItem(<%= _model.ExecutionID %>);">
                    <i class="fa fa-plus"></i>編輯項目
                </button>
            </td>
            <td>
                <button type="button" class="btn bg-color-orange btn-xs" onclick="addBreakInterval(<%= _model.ExecutionID %>);">
                    <i class="far fa-clock"></i>編輯休息時間與組數
                </button>
            </td>
            <td></td>
            <td></td>
        </tr>
    </tfoot>
    <%  } %>
</table>



<script>

    $(function () {
        $('#<%= _tableId %> tbody tr:odd').addClass('odd');
        $('#<%= _tableId %> tbody tr:even').addClass('even');
        $('.fa-arrow-circle-o-up').removeClass('disabled');
        $('.fa-arrow-circle-o-down').removeClass('disabled');
        $('.fa-arrow-circle-o-up').first().addClass('disabled');
        $('.fa-arrow-circle-o-down').last().addClass('disabled');

        var responsiveHelper_<%= _tableId %> = undefined;
        var responsiveHelper_<%= _tableId %>_fixed_column = undefined;
        var responsiveHelper_<%= _tableId %>_col_reorder = undefined;
        var responsiveHelper_<%= _tableId %>_tabletools = undefined;

        var breakpointDefinition = {
            tablet: 1024,
            phone: 480
        };

        <%--$('#<%= _tableId %>').dataTable({
            "bPaginate": false,
            "sDom": "",
            "autoWidth": true,
            "ordering": false,
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
        });--%>

        /* END BASIC */
    });

</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    TrainingExecution _model;
    String _tableId;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (TrainingExecution)this.Model;
        _tableId = ViewBag.DataTableId ?? "dt_basic" + DateTime.Now.Ticks;
    }

</script>
