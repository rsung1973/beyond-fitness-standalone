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
            
            <th data-class="expand">項目</th>
            <th data-hide="phone"><%= _model.FitnessAssessmentItem.Unit=="次" ? "次數"
                                          : _model.FitnessAssessmentItem.Unit=="組" ? "組數"
                                          : _model.FitnessAssessmentItem.Unit=="分鐘" ? "訓練總量"
                                          : "訓練總量KG" %></th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _items)
            { %>
                <tr>
                    
                    <td>
                        <%  if (ViewBag.ShowOnly != true)
                        { %>
                        
                            <a onclick="editAssessmentGroupItem(<%= item.AssessmentID %>,<%= item.ItemID %>);">
                                <i class="fa fa-pencil-square-o text-warning btn btn-xs bg-color-orange"></i>
                            </a>&nbsp;&nbsp;
                            <a onclick="deleteAssessmentItem(<%= item.AssessmentID %>,<%= item.ItemID %>,<%= _model.ItemID %>);">
                                <i class="far fa-trash-alt btn btn-xs bg-color-redLight"></i>
                            </a>
                        
                        <%  } %><%= item.FitnessAssessmentItem.ItemName %><%= item.BySingleSide==true ? "(單邊)" : item.BySingleSide==false ? "(雙邊)" : null %><%= !String.IsNullOrEmpty(item.ByCustom) ? "("+item.ByCustom+")" : null %></td>
                    <td><%  if (item.TotalAssessment.HasValue)
                            { %>
                                <%= String.Format("{0:.#}", item.TotalAssessment * (item.BySingleSide==true ? 2 : 1)) %> 
                                <%  if (item.BySingleSide == true)
                                    {   %>
                                        (<%= item.TotalAssessment %> * 2) 
                                <%  } %> 
                                <%= item.FitnessAssessmentItem.Unit %>
                        <%  }
                            else
                            { %>
                                <%= String.Format("{0:.#}", item.SingleAssessment*item.ByTimes*(item.BySingleSide==true ? 2 : 1)) %> 
                                <%= item.FitnessAssessmentItem.Unit %>(<%= String.Format("{0:.#}", item.SingleAssessment) %><%= item.FitnessAssessmentItem.Unit %> * <%= String.Format("{0:.}", item.ByTimes) %> 次 <%= item.BySingleSide==true ? " * 2" : null %>)
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
            "bPaginate": false,
            //"pageLength": 30,
            //"lengthMenu": [[30, 50, 100, -1], [30, 50, 100, "全部"]],
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
    String _tableId;
    LessonFitnessAssessmentReport _model;
    IEnumerable<LessonFitnessAssessmentReport> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFitnessAssessmentReport)this.Model;
        _items = _model.LessonFitnessAssessment.LessonFitnessAssessmentReport.Where(i => i.FitnessAssessmentItem.FitnessAssessmentGroup.MajorID == _model.ItemID);
        _tableId = "dt_groupItem" + _model.AssessmentID + "_" + _model.ItemID + "_" + DateTime.Now.Ticks;
    }

</script>
