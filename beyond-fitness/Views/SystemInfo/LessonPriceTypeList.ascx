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
            <th data-class="expand">類別名稱</th>
            <th data-hide="phone"><i class="fa fa-fw fa-money text-muted hidden-md hidden-sm hidden-xs"></i>狀態</th>
            <th data-hide="phone"><i class="fa fa-fw fa-money text-muted hidden-md hidden-sm hidden-xs"></i>原價金額</th>
            <th data-hide="phone"><i class="fa fa-fw fa-credit-money text-muted hidden-md hidden-sm hidden-xs"></i>鐘點費用(現金)</th>
            <th data-hide="phone"><i class="fa fa-fw fa-credit-card text-muted hidden-md hidden-sm hidden-xs"></i>鐘點費用(信用卡)</th>
            <th data-hide="phone">是否開放全員使用</th>
            <th>功能</th>
        </tr>
    </thead>
    <tbody>
        <%  int idx = 0;
            foreach (var item in _model)
            {
                idx++;%>
        <tr>
            <td><%= idx %></td>
            <td><%= item.Description %></td>
            <td><%= item.Status==(int)Naming.DocumentLevelDefinition.正常 ? "開課中"
                        : item.Status==(int)Naming.DocumentLevelDefinition.自主訓練 ? "P.I session"
                        : "已停用" %></td>
            <td><%= item.ListPrice %></td>
            <td><%= item.CoachPayoff %></td>
            <td><%= item.CoachPayoffCreditCard %></td>
            <td><%= item.UsageType==0 ? "否" : "是" %></td>
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
                            <a href="<%= VirtualPathUtility.ToAbsolute("~/SystemInfo/EditLessonPrice") + "?priceID=" + item.PriceID %>"><i class="fa fa-fw fa fa-edit" aria-hidden="true"></i>修改資料</a>
                        </li>
                        <% if (item.RegisterLesson.Count == 0)
                            { %>
                        <li>
                            <a onclick="deletePrice(<%= item.PriceID %>);"><i class="fa fa-fw far fa-trash-alt" aria-hidden="true"></i>刪除資料</a>
                        </li>
                        <%  } %>
                        <%  if(item.Status!=(int)Naming.DocumentLevelDefinition.自主訓練)
                            { 
                                if (item.Status == (int)Naming.DocumentLevelDefinition.已刪除)
                                { %>
                            <li>
                                <a href="<%= VirtualPathUtility.ToAbsolute("~/SystemInfo/UpdateLessonPrice")+"?status=1&priceID="+item.PriceID %>"><i class="far fa-fw fa-check-square" aria-hidden="true"></i>啟用資料</a>
                            </li>
                            <%  }
                                else
                                { %>
                            <li>
                                <a onclick="disablePrice(<%= item.PriceID %>);"><i class="fa fa-fw far fa-trash-alt" aria-hidden="true"></i>停用資料</a>
                            </li>
                            <%  }
                            } %>
                    </ul>
                </div>
            </td>
        </tr>
        <%  } %>
    </tbody>
</table>

<script>

    function deletePrice(itemID) {
        confirmIt({ title: '刪除課程類別', message: '確定刪除此課程類別?' }, function (evt) {
            startLoading();
            $('<form method="post"/>').appendTo($('body'))
                .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/SystemInfo/DeleteLessonPrice/") %>' + itemID)
                .submit();
        });
    }

    function disablePrice(itemID) {
        confirmIt({ title: '停用課程類別', message: '確定停用此課程類別?' }, function (evt) {
            startLoading();
            $('<form method="post"/>').appendTo($('body'))
                .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/SystemInfo/UpdateLessonPrice") + "?status=0&priceID=" %>' + itemID)
                .submit();
        });
    }

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
    IQueryable<LessonPriceType> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _tableId = ViewBag.DataTableId ?? "dt_basic";
        _model = (IQueryable<LessonPriceType>)this.Model;
    }

</script>
