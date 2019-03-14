<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Helper.DataOperation" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<table class="table table-striped table-custom nowrap dataTable-contract" style="width: 100%">
    <thead>
        <tr>
            <th>服務項目</th>
            <th>學生</th>
            <th>上課場所</th>
            <th>申請人</th>
            <th>合約編號</th>
            <th>編輯日期</th>
            <th>合約迄日</th>
            <th>購買堂數</th>
            <th>剩餘堂數</th>
            <th>合約金額</th>
            <th>已收金額</th>
            <th>目前狀態</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _items)
            {
                var contract = item.CourseContract; %>
        <tr onclick="processContractService('<%= item.RevisionID.EncryptKey() %>');">
            <td><%= item.Reason %></td>
            <td><%= contract.ContractLearner() %></td>
            <td><%= contract.CourseContractExtension.BranchStore.BranchName %></td>
            <td><%= contract.ContractAgent.FullName() %></td>
            <td><%= contract.ContractNo() %></td>
            <td><%= $"{contract.ContractDate:yyyy/MM/dd}" %></td>
            <td><%= $"{contract.Expiration:yyyy/MM/dd}" %></td>
            <td><%= _model.Lessons %></td>
            <td><%  if (item.Reason == "展延" && contract.Status == (int)Naming.CourseContractStatus.已生效)
                    {
                    }
                    else
                    {   %>
                <%= _model.RemainedLessonCount() %>
                <%  }   %>
            </td>
            <td><%= $"{_model.TotalCost:##,###,###,###}" %></td>
            <td><%= $"{_model.TotalPaidAmount():##,###,###,###}" %></td>
            <td><%= (Naming.ContractServiceStatus)contract.Status %></td>
        </tr>
        <%  }   %>
    </tbody>
</table>
<script>

    $(function () {

        if ($global.dtContract != undefined) {
            $global.dtContract.destroy();
        }

        $global.dtContract = $('.dataTable-contract').DataTable({
            //"ajax": 'ajax/data/contractlist-2.json',
                "order": [
                    [4, 'desc']
                ],
                "pageLength": 30,
                "lengthMenu": [
                    [30, 50, 100, -1],
                    [30, 50, 100, "全部"]
                ],
                "language": {
                    "lengthMenu": "每頁顯示 _MENU_ 筆資料",
                    "zeroRecords": "沒有資料也是種福氣",
                    "info": "共 _TOTAL_ 筆，目前顯示第 _START_ 至 _END_筆資料",
                    "infoEmpty": "顯示 0 筆的資料",
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
                    leftColumns: 1
                },
                "columnDefs": [{
                        targets: [9, 10],
                        className: "align-right more"

                    },
                    {
                        targets: [2, 5, 6, 7, 8],
                        className: "align-center more"

                    },
                    {
                        targets: [0, 1, 3, 4],
                        className: "more"

                    }
                ],
            "initComplete": function () {
                var api = this.api();
                api.$('td').click(function () {
                    if ($(this).hasClass('more')) {
                        $("#moreContractActionModal").modal('show');
                    }
                });
            }
        });

        $([document.documentElement, document.body]).animate({
            scrollTop: $(".dataTable-contract").offset().top
        }, 2000);

        setTimeout(function () {
            var $btnSelect = $('.dataTables_length div.btn-group.bootstrap-select.form-control.form-control-sm');
            var $menu = $btnSelect.find('select');
            $btnSelect.before($menu);
            $btnSelect.remove();
        }, 1000);

    });

</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContract _model;
    IQueryable<CourseContractRevision> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
        _items = models.GetTable<CourseContractRevision>().Where(r => r.OriginalContract == _model.ContractID)
                    .OrderBy(c => c.RevisionID);
    }


</script>
