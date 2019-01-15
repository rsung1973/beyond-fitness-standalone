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
            <th data-class="expand" class="col-xs-3 col-sm-3">Item</th>
            <th class="col-xs-3 col-sm-3">Level</th>
            <th data-hide="phone" class="col-xs-3 col-sm-3">Action</th>
            <th data-hide="phone">Description</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model.DiagnosisAssessment)
            { %>
        <tr>
            <td>
                <%  if (_model.LevelID == (int)Naming.DocumentLevelDefinition.暫存)
                    { %>
                <a href="#" onclick="editDiagnosisAssessment(<%= _model.DiagnosisID %>,<%= item.ItemID %>);">
                    <i class="fa fa-pencil-alt text-warning fa-lg btn btn-xs bg-color-orange"></i>
                </a>&nbsp;&nbsp;
                <a href="#" onclick="deleteDiagnosisAssessment(<%= _model.DiagnosisID %>,<%= item.ItemID %>);">
                    <i class="far fa-trash-alt btn btn-xs fa-lg bg-color-redLight"></i>
                </a>
                <%  } %>
                <%= item.FitnessAssessmentItem.ItemName %>
            </td>
            <td><%  if (item.FitnessAssessmentItem.Unit == "N/A")
                    { %>
                <%= item.Judgement %>
                <%  }
                    else if(item.ItemID == 57)
                    {   %>
                <%= item.Judgement %> <%= String.Format("({0:.}/{1:.} {2})",item.Assessment,item.AdditionalAssessment,item.FitnessAssessmentItem.Unit) %>
                <%  }
                    else
                    { %>
                <a href="#" onclick="diagnosisRule(<%= item.DiagnosisID %>,<%= item.ItemID %>);"><u><%= item.Judgement %> <%= String.Format("({0:.}{1})",item.Assessment,item.FitnessAssessmentItem.Unit) %></u></a>
                <%  } %>
                </td>
            <td><%= item.DiagnosisAction %></td>
            <td><%= item.Description %></td>
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
            "sDom": "",
            "autoWidth": true,
            "order": [],
            "bPaginate": false,
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
    BodyDiagnosis _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _tableId = "dt_testing" + DateTime.Now.Ticks;
        _model = (BodyDiagnosis)this.Model;
    }

</script>
