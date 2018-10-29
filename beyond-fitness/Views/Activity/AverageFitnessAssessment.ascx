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
            <th data-class="expand">類別</th>
            <th>年齡區間</th>
            <%  for (int i = 0; i < _items.Length; i++)
                       {
                           var f = _items[i];  %>
            <th <%= i > 1 ? "data-hide=\"phone\"" : null %>><%= f.ItemName %></th>
            <%  } %>
        </tr>
    </thead>
    <tbody>
        <%  var items = _model.GroupBy(v => new
            {
                Index = (int)(v.Years / 10),
                v.Gender,
                v.AthleticLevel
            });
            foreach(var item in items)
            {
                   %>
                <tr>
                    <td>
                        <%= item.Key.AthleticLevel==0 ? "一般" : "運動員" %>
                        <%= item.Key.Gender == "F" ? "女性" : "男性" %>
                    </td>
                    <td><%= item.Key.Index*10 %>-<%= item.Key.Index*10+10 %></td>
                    <%  for (int i = 0; i < _items.Length; i++)
                        {
                            var f = _items[i];
                            var assessment = item.Where(a => a.ItemID == f.ItemID);
                            var totalCount = assessment.Count();
                              %>
                    <td><%= totalCount==0  ? "--" : checkValue(assessment.Sum(a=>a.Assessment)/totalCount,f.Unit) %></td>
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
    String _tableId = "dt_AssessmentAvg";
    IQueryable<V_LearnerFitenessAssessment> _model;
    FitnessAssessmentItem[] _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<V_LearnerFitenessAssessment>)this.Model;
        _items = (FitnessAssessmentItem[])ViewBag.FitnessItems;

    }

    String checkValue(decimal decVal, String unit)
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
