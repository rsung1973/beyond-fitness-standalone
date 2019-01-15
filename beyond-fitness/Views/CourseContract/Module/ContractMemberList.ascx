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
            <%  if (ViewBag.ViewOnly != true)
                { %>
            <th>
                <%--<%  String display = "none";
                    if ((ViewBag.ContractType==1 && _model.Count()<1)
                        || (ViewBag.ContractType==3 && _model.Count()<2)
                        || ViewBag.ContractType==2)
                    {
                        display = "block";
                    } %>--%>
                <a href="#" class="btn btn-primary addMember"><i class="fa fa-fw fa-user-plus"></i>新增</a>
            </th>
            <%  } %>
            <th data-class="expand">姓名</th>
            <th>身份證字號/護照號碼</th>
            <th>性別</th>
            <th data-hide="phone">出生</th>
            <th data-hide="phone">連絡電話</th>
            <th data-hide="phone">緊急聯絡人姓名</th>
            <th data-hide="phone">緊急聯絡電話</th>
            <th data-hide="phone">關係</th>
            <th data-hide="phone">地址</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <%  if (ViewBag.ViewOnly != true)
                { %>
            <th nowrap="noWrap">
                <input type="hidden" name="UID" value="<%= item.UID %>" />
                <a onclick="$global.editContractMember(<%= item.UID %>);" class="btn btn-circle bg-color-yellow"><i class="fa fa-fw fa fa-lg fa-edit" aria-hidden="true"></i></a>&nbsp;&nbsp;
                                   <a onclick="$global.deleteContractMember(<%= item.UID %>);" class="btn btn-circle bg-color-red"><i class="fa fa-fw fa fa-lg fa-trash-alt" aria-hidden="true"></i></a>
            </th>
            <%  } %>
            <td><%= (ViewBag.ContractType==2 || ViewBag.ContractType==3) && ViewBag.OwnerID==item.UID ? "*" : null %><%= item.FullName() %></td>
            <td nowrap="noWrap"><%= item.UserProfileExtension.IDNo %></td>
            <td><%= item.UserProfileExtension.Gender %></td>
            <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}",item.Birthday) %></td>
            <td nowrap="noWrap"><%= item.Phone %></td>
            <td nowrap="noWrap"><%= item.UserProfileExtension.EmergencyContactPerson %></td>
            <td><%= item.UserProfileExtension.EmergencyContactPhone %></td>
            <td><%= item.UserProfileExtension.Relationship %></td>
            <td><%= item.Address() %></td>
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
    String _tableId = "dt_member" + DateTime.Now.Ticks;
    IQueryable<UserProfile> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<UserProfile>)this.Model;
    }

</script>
