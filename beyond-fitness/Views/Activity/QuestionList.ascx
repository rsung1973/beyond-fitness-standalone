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
            <th>#</th>
            <th data-class="expand"><i class="fa fa-fw fa-user text-muted hidden-md hidden-sm hidden-xs"></i>提問者</th>
            <th><i class="fa fa-fw fa-question text-muted hidden-md hidden-sm hidden-xs"></i>問題</th>
            <th data-hide="phone">回饋點數</th>
            <th data-hide="phone">功能</th>
        </tr>
    </thead>
    <tbody>
        <%  int idx = 0;
            foreach (var item in _model)
            {
                idx++; %>
                <tr>
                    <td><%= idx %></td>
                    <td><%= item.AskerID.HasValue ? item.UserProfile.RealName : null %></td>
                    <td><%= item.Question %></td>
                    <td><%= item.PDQQuestionExtension!=null ? item.PDQQuestionExtension.BonusPoint : null %></td>
                    <td>
                        <div class="btn-group dropup">
                            <button class="btn bg-color-blueLight" data-toggle="dropdown">
                                請選擇功能
                            </button>
                            <button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                                <span class="caret"></span>
                            </button>
                            <ul class="dropdown-menu">
                                <li>
                                    <a href="<%= Url.Action("EditDailyQuestion",new { questionID = item.QuestionID }) %>"><i class="fa fa-fw fa fa-edit" aria-hidden="true"></i>修改資料</a>
                                </li>
                                <%  if (item.PDQQuestionExtension.Status.HasValue)
                                    { %>
                                <li>
                                    <a onclick="enableItem(<%= item.QuestionID %>);"><i class="far fa-fw fa-check-square" aria-hidden="true"></i>啟用資料</a>
                                </li>
                                <%  }
                                    else
                                    {
                                        if (!item.PDQTask.Any())
                                        {%>
                                <li>
                                    <a onclick="deleteItem(<%= item.QuestionID %>);"><i class="fa fa-fw far fa-trash-alt" aria-hidden="true"></i>刪除資料</a>
                                </li>
                                    <%  } %>
                                <li>
                                    <a onclick="disableItem(<%= item.QuestionID %>);"><i class="fa fa-fw far fa-trash-alt" aria-hidden="true"></i>停用資料</a>
                                </li>
                                <%  } %>
                            </ul>
                        </div>
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
            "pageLength": 30,
            "lengthMenu": [[30, 50, 100, -1], [30, 50, 100, "全部"]],
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

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId;
    IQueryable<PDQQuestion> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<PDQQuestion>)this.Model;
        _tableId = "dt_QandA";
    }

</script>
