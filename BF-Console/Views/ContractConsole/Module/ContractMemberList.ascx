<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table id="<%= _tableId %>" class="table table-striped table-custom nowrap bg-white col-charcoal dataTable dataTable-learner" width="100%">
    <thead>
        <tr>
            <th>姓名</th>
            <th>身分證字號</th>
            <th>性別</th>
            <th>生日</th>
            <th>連絡電話</th>
            <th>緊急聯絡人</th>
            <th>緊急聯絡電話</th>
            <th>關係</th>
            <th>地址</th>
        </tr>
    </thead>
    <tbody>
        <%  
            foreach (var item in _model)
            { %>
        <tr data-id="<%= item.UID %>">
            <td><%= item.UID==ViewBag.OwnerID ? "*" : null %><%= item.FullName() %></td>
            <td><%= item.UserProfileExtension.IDNo %></td>
            <td><%= item.UserProfileExtension.Gender == "F" ? "女" : "男" %></td>
            <td><%= String.Format("{0:yyyy/MM/dd}",item.Birthday) %></td>
            <td><%= item.Phone %></td>
            <td><%= item.UserProfileExtension.EmergencyContactPerson %></td>
            <td><%= item.UserProfileExtension.EmergencyContactPhone %></td>
            <td><%= item.UserProfileExtension.Relationship %></td>
            <td><%= item.Address() %><i class="zmdi zmdi-more-vert float-right"></i></td>
        </tr>
        <%  } %>
    </tbody>
</table>

<script>

    debugger;
    $(function () {

        var theDataTable = null;
        function buildDataTable() {
            theDataTable = $('#<%= _tableId %>').DataTable({
                "filter": false,
                "bPaginate": false,
                "info": false,
                "order": [
                    [0, 'asc'],
                    [1, 'asc']
                ],
                "language": {
                    "lengthMenu": "每頁顯示 _MENU_ 筆資料",
                    "zeroRecords": "沒有資料也是種福氣",
                    "info": "共 _TOTAL_ 筆，目前顯示第 _PAGE_ / _PAGES_",
                    "infoEmpty": "顯示 0 到 0 筆的資料",
                    "infoFiltered": "(總共從 _MAX_ 筆資料過濾)",
                    "loadingRecords": "快馬加鞭處理中...",
                    "processing": "快馬加鞭處理中...",
                    "search": "快速搜尋：",
                    "paginate": {
                        "first": "第一頁",
                        "last": "最後一頁",
                        "next": "下一頁",
                        "previous": "前一頁"
                    },
                },
                scrollX: true,
                scrollCollapse: true,
                fixedColumns: {
                    leftColumns: 1,
                },
                "initComplete": function () {
                    if ($global.contractMemberInitComplete) {
                        $global.contractMemberInitComplete(this);
                    }
                },
            });
        }

        var $collapse = $('#<%= _tableId %>').closest('.panel-collapse');
        if ($collapse.length > 0) {
            $collapse.on('shown.bs.collapse', function (event) {
                if (!theDataTable) {
                    buildDataTable();
                }
            });
        } else {
            buildDataTable();
        }
    });

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _tableId = "dt_member" + DateTime.Now.Ticks;
    IEnumerable<UserProfile> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IEnumerable<UserProfile>)this.Model;
    }

</script>
