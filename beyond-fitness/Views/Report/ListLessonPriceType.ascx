<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<header>
    <span class="widget-icon"><i class="fa fa-table txt-color-white"></i></span>
    <h2>課程類別 </h2>
    <!-- <div class="widget-toolbar">
                              add: non-hidden - to disable auto hide
                              
                              </div>-->
</header>
<!-- widget div-->
<div>
    <!-- widget edit box -->
    <div class="jarviswidget-editbox">
        <!-- This area used as dropdown edit box -->
    </div>
    <!-- end widget edit box -->
    <!-- widget content -->
    <div class="widget-body bg-color-darken txt-color-white no-padding">
        <table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%">
            <thead>
                <tr>
                    <th>#</th>
                    <th data-class="expand">類別名稱</th>
                    <th data-hide="phone"><i class="fa fa-fw fa-money text-muted hidden-md hidden-sm hidden-xs"></i>原價金額</th>
                    <th data-hide="phone"><i class="fa fa-fw fa-credit-money text-muted hidden-md hidden-sm hidden-xs"></i>鐘點費用(現金)</th>
                    <th data-hide="phone"><i class="fa fa-fw fa-credit-card text-muted hidden-md hidden-sm hidden-xs"></i>鐘點費用(信用卡)</th>
                </tr>
            </thead>
            <tbody>
                <%  int idx = 0;
                    foreach (var item in _model)
                    {
                        idx++;  %>
                <tr>
                    <td><%= idx %></td>
                    <td><%= item.Description %></td>
                    <td><%= item.ListPrice %></td>
                    <td><%= item.CoachPayoff %></td>
                    <td><%= item.CoachPayoffCreditCard %></td>
                </tr>
                <%  } %>
            </tbody>
        </table>
    </div>
    <!-- end widget content -->
</div>
<!-- end widget div -->
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
            "ordering": false,
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
    IQueryable<LessonPriceType> _model;
    String _tableId = "dt_priceType";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonPriceType>)this.Model;
    }

</script>
