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

<table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%">
    <thead>
        <tr>
            <th><i class="fa fa-fw fa-user text-muted hidden-md hidden-sm hidden-xs"></i>上課學員姓名</th>
            <th>功能</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _items.Where(u=>!u.GroupID.HasValue))
            {
                var profile = item.UserProfile; %>
        <tr>
            <td><%= profile.FullName() %></td>
            <td>
                <%  if (_model.GroupingMemberCount>1)
                    { %>
                <a onclick="addGroupMember(<%= _model.ContractID %>,<%= item.UID %>);" class="btn btn-circle btn-primary listAttendantDialog_link"><i class="fa fa-fw fa fa-lg fa-user-plus" aria-hidden="true"></i></a>&nbsp;&nbsp;
                <%  } %>
                <%  if (!item.EnterpriseCourseContract.RegisterLessonEnterprise.Select(t=>t.RegisterLesson)
                            .Where(r=>r.UID==profile.UID).Any(r => r.GroupingLesson.LessonTime.Count > 0))
                    { %>
                <a onclick="removeProgramMember(<%= item.ContractID %>,<%= item.UID %>);" class="btn btn-circle bg-color-red delete"><i class="fa fa-fw fa fa-lg fa-trash-alt" aria-hidden="true"></i></a>
                <%  } %>
            </td>
        </tr>
        <%  } %>
        <%  foreach (var item in _items.Where(u=>u.GroupID.HasValue).GroupBy(u=>u.GroupID))
                            {
        %>
        <tr>
            <td><%= String.Join("、", item.Select(g=>g.UserProfile).ToArray().Select(u=>u.FullName())) %></td>
            <td>
                <%  if (item.Count() < _model.GroupingMemberCount)
                                    { %>
                <a onclick="addGroupMember(<%= _model.ContractID %>,<%= item.First().UID %>);" class="btn btn-circle btn-primary"><i class="fa fa-fw fa fa-lg fa-user-plus" aria-hidden="true"></i></a>&nbsp;&nbsp;
                                <%  } %>
                <%  if (item.Count() > 1)
                                    { %>
                <a onclick="takeGroupApart(<%= item.Key %>);" class="btn btn-circle bg-color-red"><i class="fa fa-fw fa fa-lg fa-user-times" aria-hidden="true"></i></a>&nbsp;&nbsp;
                                <%  } %>

                <%--<a href="#" class="btn btn-circle bg-color-red delete"><i class="fa fa-fw fa fa-lg fa-trash-alt" aria-hidden="true"></i></a>--%>
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
                "pageLength": 10,
                "lengthMenu": [[10,30, 50, 100, -1], [10,30, 50, 100, "全部"]],
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

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "members" + DateTime.Now.Ticks;
    EnterpriseCourseContract _model;
    IQueryable<EnterpriseCourseMember> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (EnterpriseCourseContract)this.Model;
        _items = models.GetTable<EnterpriseCourseMember>().Where(t => t.ContractID == _model.ContractID);

    }

</script>
