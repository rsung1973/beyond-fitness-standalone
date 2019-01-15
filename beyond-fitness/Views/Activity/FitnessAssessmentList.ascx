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
            <th style="width: 80px">功能</th>
            <th data-class="expand">檢測日期</th>
            <%  for (int i = 0; i < _items.Length; i++)
                       {
                           var f = _items[i];  %>
                    <th <%= i > 1 ? "data-hide=\"phone\"" : null %> ><%= f.ItemName %></th>
            <%  } %>
        </tr>
    </thead>
    <tbody>
        <%  foreach(var item in _model)
            {                %>
                <tr>
                    <td>
                        <a onclick="editAssessment(<%= item.AssessmentID %>);">
                            <i class="fa fa-pencil-square-o fa-2x btn btn-xs bg-color-orange"></i>
                        </a><a onclick="deleteAssessment(<%= item.AssessmentID %>);">
                            <i class="far fa-trash-alt fa-2x btn btn-xs bg-color-redLight"></i>
                        </a>
                    </td>
                    <td><%= item.AssessmentDate.ToString("yyyy/MM/dd") %></td>
                    <%  for (int i = 0; i < _items.Length; i++)
                        {
                            var f = _items[i];
                            var result = item.LearnerFitnessAssessmentResult.Where(r => r.ItemID == f.ItemID).FirstOrDefault();  %>
                            <td><%= result==null ? "--" : checkValue(result.Assessment,f.Unit) %></td>
                    <%  } %>
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
            "bPaginate": false,
            //"pageLength": 30,
            //"lengthMenu": [[30, 50, 100, -1], [30, 50, 100, "全部"]],
            //"ordering": false,
            "sDom": "",
            "autoWidth": true,
            "oLanguage": {
                "sSearch": ''
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
    String _tableId = "dt_fitnessAssessmentList_" + DateTime.Now.Ticks;
    IQueryable<LearnerFitnessAssessment> _model;
    FitnessAssessmentItem[] _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LearnerFitnessAssessment>)this.Model;
        _items = (FitnessAssessmentItem[])ViewBag.FitnessItems;
    }

    String checkValue(decimal decVal,String unit)
    {
        if (unit == "秒" && decVal > 60)
        {
            TimeSpan duration = new TimeSpan(0, 0, (int)decVal);
            return duration.Minutes + "分" + duration.Seconds + "秒";
        }
        else
            return decVal.ToString() + unit;
    }

</script>
