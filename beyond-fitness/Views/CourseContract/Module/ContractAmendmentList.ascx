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
            <th data-class="expand">合約編號</th>
            <th data-hide="phone">簽約顧問</th>
            <th data-hide="phone">異動日期</th>
            <th data-hide="phone">申請項目</th>
            <th data-hide="phone">狀態</th>
            <th data-hide="phone">功能</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <td nowrap="noWrap"><%= item.CourseContract.ContractNo + "-" + String.Format("{0:00}",item.RevisionNo) %></td>
            <td nowrap="noWrap"><%= item.CourseContract.ServingCoach.UserProfile.FullName() %></td>
            <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}",item.CourseContract.ContractDate) %></td>
            <td nowrap="noWrap"><%= item.Reason %></td>
            <td nowrap="noWrap"><%= (Naming.CourseContractStatus)item.CourseContract.Status %></td>
            <td nowrap="noWrap">
                <%  if (item.CourseContract.Status == (int)Naming.CourseContractStatus.待確認)
                    { %>
                <%--<a onclick="$global.openToApproveAmendment(<%= item.RevisionID %>);" class="btn btn-circle bg-color-green"><i class="far fa-fw fa-lg fa-copy" aria-hidden="true"></i></a>--%>
                <a href="<%= Url.Action("ViewContractAmendment","CourseContract",new { item.RevisionID }) %>" target="_blank" class="btn btn-circle bg-color-yellow modifyPersonalContractDialog_link"><i class="fa fa-fw fa fa-lg fa-binoculars" aria-hidden="true"></i></a>
                <%  }
                    else if (item.CourseContract.Status == (int)Naming.CourseContractStatus.待簽名)
                    { %>
                <%--<a onclick="$global.openToSignAmendment(<%= item.RevisionID %>);" class="btn btn-circle bg-color-green"><i class="far fa-fw fa-lg fa-copy" aria-hidden="true"></i></a>--%>
                <a href="<%= Url.Action("ViewContractAmendment","CourseContract",new { item.RevisionID }) %>" target="_blank" class="btn btn-circle bg-color-yellow modifyPersonalContractDialog_link"><i class="fa fa-fw fa fa-lg fa-binoculars" aria-hidden="true"></i></a>
                <%  }
                    else if (item.CourseContract.Status == (int)Naming.CourseContractStatus.待審核)
                    {   %>
                <a href="<%= Url.Action("GetContractAmendmentPdf","CourseContract",new { item.RevisionID }) %>" target="_blank" class="btn btn-circle bg-color-green"><i class="far fa-fw fa-lg fa-copy" aria-hidden="true"></i></a>
                <a href="<%= Url.Action("ViewContractAmendment","CourseContract",new { item.RevisionID }) %>" target="_blank" class="btn btn-circle bg-color-yellow modifyPersonalContractDialog_link"><i class="fa fa-fw fa fa-lg fa-binoculars" aria-hidden="true"></i></a>
                <%--<a onclick="$global.enableAmendment(<%= item.RevisionID %>);" class="btn btn-circle bg-color-red"><i class="far fa-fw fa-lg fa-check-square" aria-hidden="true"></i></a>--%>
                <%  }
                    else
                    {  %>
                <a href="<%= Url.Action("GetContractAmendmentPdf","CourseContract",new { item.RevisionID }) %>" target="_blank" class="btn btn-circle bg-color-green"><i class="far fa-fw fa-lg fa-copy" aria-hidden="true"></i></a>
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
            "sDom": "",
            "autoWidth": true,
            "ordering": false,
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

        $('#<%= _tableId %> a.addMember').on('click', function (evt) {
            showLoading();
            $.post('<%= Url.Action("SelectContractMember","CourseContract") %>', { 'referenceUID': $global.referenceUID,'contractType':$global.contractType }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        });

        $global.useLearnerDiscount = <%= ViewBag.UseLearnerDiscount==true ? "true" : "false" %>;

    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "dt_amendment" + DateTime.Now.Ticks;
    IEnumerable<CourseContractRevision> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IEnumerable<CourseContractRevision>)this.Model;
    }

</script>
