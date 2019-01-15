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

<label class="label label-warning">狀態後<i class="fa fa-asterisk"></i> 表示主管尚未對帳</label>
<table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%">
    <thead>
        <tr>
            <%  Html.RenderPartial("~/Views/Payment/Section/PaymentAchievementList/TH.ascx"); %>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <%  Html.RenderPartial("~/Views/Payment/Section/PaymentAchievementList/TD.ascx",item); %>
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
            "ordering": true,
            "order": [[4, "desc"]],
            "sDom": "<'dt-toolbar'<'col-xs-12 col-sm-6'f><'col-sm-6 col-xs-12 hidden-xs'l C>r>" +
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
            },
            "columnDefs": [
                    {
                        "targets": [0],
                        "visible": false
                    },
                    {
                        "targets": [1],
                        "visible": false
                    },
                    {
                        "targets": [10],
                        "visible": false
                    },
                    {
                        "targets": [11],
                        "visible": false
                    },
                    {
                        "targets": [12],
                        "visible": false
                    },
                    {
                        "targets": [13],
                        "visible": false
                    },
                    {
                        "targets": [14],
                        "visible": false
                    },
                    {
                        "targets": [15],
                        "visible": false
                    },
                    {
                        "targets": [16],
                        "visible": false
                    },
                    {
                        "targets": [17],
                        "visible": false
                    },

            ]
        });

        $global.editAchievement = function (paymentID) {
            var event = event || window.event;
            var $tr = $(event.target).closest('tr');
            showLoading();
            $.post('<%= Url.Action("EditPaymentAchievement","Payment") %>', { 'paymentID': paymentID }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        alert('收款已勾記!!');
                        $tr.remove();
                    } else {
                        alert(data.message);
                    }
                } else {
                    $(data).appendTo($('body'));
                }
            });
        };

    });

</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "paymentList" + DateTime.Now.Ticks;
    IQueryable<Payment> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<Payment>)this.Model;

    }

</script>
