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

<div class="jarviswidget" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
    <header class="bg-color-red">
        <span class="widget-icon"><i class="fa fa-exclamation-triangle"></i></span>
        <h2>尚有<%= _items.Where(c=>c.Expiration>=DateTime.Today).Count() %>張合約即將過期，<%= _contrtacts.Where(c=>c.Expiration<DateTime.Today).Count() %>張已過期!</h2>
    </header>
    <!-- widget div-->
    <div>
        <!-- widget content -->
        <div class="widget-body txt-color-white padding-5">
            <!-- content -->
            <table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%">
                <thead>
                    <tr>
                        <th data-hide="phone,tablet">合約編號</th>
                        <th data-class="expand">學員</th>
                        <th data-hide="phone,tablet">簽約體能顧問</th>
                        <th data-hide="phone" class="text-center">到期日</th>
                        <th class="text-center">過期</th>
                    </tr>
                </thead>
                <tbody>
                    <%  foreach (var item in _items)
                        { %>
                    <tr>
                        <td><%= item.ContractNo() %></td>
                        <td><%= String.Join("/",item.CourseContractMember.Select(m=>m.UserProfile).ToArray().Select(u=>u.FullName())) %></td>
                        <td><%= item.ServingCoach.UserProfile.FullName() %></td>
                        <td class="text-center"><%= String.Format("{0:yyyy/MM/dd}",item.Expiration) %></td>
                        <td class="text-center"><%= item.Expiration<DateTime.Today ? "是" : "否" %></td>
                    </tr>
                    <%  } %>
                    <%  foreach (var item in _contrtacts)
                        { %>
                    <tr>
                        <td><%= item.ContractNo() %></td>
                        <td><%= String.Join("/",item.CourseContractMember.Select(m=>m.UserProfile).ToArray().Select(u=>u.FullName())) %></td>
                        <td><%= item.ServingCoach.UserProfile.FullName() %></td>
                        <td class="text-center"><%= String.Format("{0:yyyy/MM/dd}",item.Expiration) %></td>
                        <td class="text-center">是</td>
                    </tr>
                    <%  } %>

                </tbody>
            </table>
            <!-- end content -->
        </div>
        <!-- end widget content -->
    </div>
    <!-- end widget div -->
</div>

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
    IQueryable<CourseContract> _items;
    IQueryable<CourseContract> _contrtacts;
    String _tableId = "expiringContract" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        var profile = Context.GetUser();
        _items = models.PromptExpiringContract();
        _contrtacts = models.PromptRegisterLessonContract()
                    .FilterByExpired(models);
                        //.Join(models.GetTable<RegisterLesson>()
                        //    .Where(r => r.Attended != (int)Naming.LessonStatus.課程結束)
                        //    .Join(models.GetTable<RegisterLessonContract>(),
                        //        r => r.RegisterID, t => t.RegisterID, (r, t) => t),
                        //    c => c.ContractID, t => t.ContractID, (c, t) => c);

        ServingCoach coach = ViewBag.CurrentCoach as ServingCoach;
        if (coach != null && coach.CoachID!=profile.UID)
        {
            _items = _items.Where(c => c.FitnessConsultant == coach.CoachID);
            _contrtacts = _contrtacts.Where(c => c.FitnessConsultant == coach.CoachID);
        }
        else if (profile.IsAssistant())
        {

        }
        else if (profile.IsManager() || profile.IsViceManager())
        {
            //var coaches = profile.GetServingCoachInSameStore(models);
            //_items = _items.Join(coaches, c => c.FitnessConsultant, h => h.CoachID, (c, h) => c);
            _items = _items.FilterByBranchStoreManager(models, profile.UID);
            _contrtacts = _contrtacts.FilterByBranchStoreManager(models, profile.UID);
        }
        else if (profile.IsCoach())
        {
            _items = _items.Where(c => c.FitnessConsultant == profile.UID);
            _contrtacts = _contrtacts.Where(c => c.FitnessConsultant == profile.UID);
        }

    }

</script>
