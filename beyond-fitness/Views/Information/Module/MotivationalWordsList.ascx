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
            <th data-class="expand"><i class="fa fa-fw fa-user text-muted hidden-md hidden-sm hidden-xs"></i>發布者</th>
            <th><i class="fa fa-fw fa-volume-control-phone text-muted hidden-md hidden-sm hidden-xs"></i>激勵小語</th>
            <th data-hide="phone">開始時間</th>
            <th data-hide="phone">結束時間</th>
            <th data-hide="phone">功能</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
                <tr>
                    <td><%= item.UserProfile.FullName() %></td>
                    <td><%= item.Title %></td>
                    <td><%= String.Format("{0:yyyy/MM/dd}", item.Publication.StartDate) %></td>
                    <td><%= item.Publication.EndDate.HasValue ? String.Format("{0:yyyy/MM/dd}", item.Publication.EndDate) : "--" %></td>
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
                                    <a href="<%= Url.Action("EditMotivationalWords","Information",new { id = item.DocID }) %>"><i class="fa fa-fw fa fa-edit" aria-hidden="true"></i>修改資料</a>
                                </li>
                                <li>
                                    <a onclick="deleteArticle(<%= item.DocID %>);"><i class="fa fa-fw far fa-trash-alt" aria-hidden="true"></i>刪除資料</a>
                                </li>
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

    function deleteArticle(docID) {

        $.SmartMessageBox({
            title: "<i class=\"fa fa-fw far fa-trash-alt\" aria-hidden=\"true\"></i> 刪除激勵小語",
            content: "確定刪除此小語?",
            buttons: '[刪除][取消]'
        }, function (ButtonPressed) {
            if (ButtonPressed == "刪除") {
                $('<form method="post"/>').appendTo($('body'))
                    .prop('action', '<%= Url.Action("DeleteMotivationalWords","Information") %>' + '?id=' + docID)
                    .submit();
            }
        });
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId;
    IQueryable<Article> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _tableId = ViewBag.DataTableId ?? "dt_words_" + DateTime.Now.Ticks;
        _model = (IQueryable<Article>)this.Model;
    }

</script>
