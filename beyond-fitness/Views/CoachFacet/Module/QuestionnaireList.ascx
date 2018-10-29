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

<div title="待辦事項：階段性調整計劃" class="bg-color-darken">
    <!-- content -->
    <table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%">
        <thead>
            <tr>
                <th>學員</th>
                <th>目前狀態</th>
            </tr>
        </thead>
        <tbody>
            <%  foreach (var item in _model)
                { %>
            <tr>
                <td><%= item.UserProfile.FullName() %></td>
                <td><%  if (item.PDQTask.Count == 0)
                        {
                            if (item.Status == (int)Naming.IncommingMessageStatus.拒答)
                            {   %>
                                回覆不方便填寫
                        <%  }
                            else  if (item.Status == (int)Naming.IncommingMessageStatus.教練代答)
                            {   %>
                                我超強不用了解學生
                        <%  }
                            else
                            {
                                if (_profile.IsAssistant())
                                {   %>
                            <a href="#" onclick="$global.rejectQuestionnaire(<%= item.QuestionnaireID %>);" class="btn btn-circle bg-color-redLight"><i class="fa fa-fw fa fa-lg fa-times" aria-hidden="true"></i></a>
                            <%  } %>
                            <a href="http://line.me/R/msg/text/?Hi <%= item.UserProfile.FullName() %>, 請記得登入http%3A%2F%2Fwww.beyond-fitness.tw%2F填寫階段性調整計劃喔！" target="_blank" class="btn btn-circle bg-color-greenLight">LINE</a>
                            尚未填寫
                    <%      }
                        }
                        else
                        { %>
                            <a href="javascript:showLearnerQuestionnaire(<%= item.QuestionnaireID %>);" class="btn bg-color-blueLight btn-circle questionnaire_link"><i class="fa fa-volume-up fa-lg"></i></a>
                            已於<%= String.Format("{0:yyyy/MM/dd}",item.PDQTask.First().TaskDate) %>填寫                                 
                    <%  } %>
                </td>
            </tr>
            <%  } %>
        </tbody>
    </table>
    <!-- end content -->
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
            "pageLength": 10,
            "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "全部"]],
            "order": [[1, "desc"]],
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
    });
    </script>

</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<QuestionnaireRequest> _model;
    String _tableId;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<QuestionnaireRequest>)this.Model;
        _tableId = ViewBag.DataTableId ?? "dt_questList" + DateTime.Now.Ticks;
        _profile = Context.GetUser();
    }

</script>
