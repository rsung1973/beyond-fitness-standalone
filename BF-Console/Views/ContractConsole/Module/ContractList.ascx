<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table class="table table-striped table-custom nowrap dataTable-contract" style="width: 100%">
    <thead>
        <tr>
            <th>學生</th>
            <th>上課場所</th>
            <th>體能顧問</th>
            <th>合約編號</th>
            <th>合約名稱</th>
            <th>服務項目</th>
            <th>購買堂數</th>
            <th>編輯日期</th>
            <th>合約起日</th>
            <th>合約迄日</th>
            <th>目前狀態</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            {   %>
        <tr onclick="processContract('<%= item.ContractID.EncryptKey() %>');">
            <td>
                <%  if (item.CourseContractType.IsGroup == true)
                    { %>
                <%= String.Join("/",item.CourseContractMember.Select(m=>m.UserProfile).ToArray().Select(u=>u.FullName())) %>
                <%  }
                    else
                    { %>
                <%= item.ContractOwner.FullName() %>
                <%  } %>
            </td>
            <td><%= item.CourseContractExtension.BranchStore.BranchName %></td>
            <td><%= item.ServingCoach.UserProfile.FullName() %></td>
            <td><%= item.ContractNo() %></td>
            <td><%= item.CourseContractType.TypeName %>(<%= item.LessonPriceType.DurationInMinutes %>分鐘)</td>
            <td><%= item.CourseContractRevision!=null 
                            ? item.CourseContractRevision.Reason 
                            : item.Renewal == true
                                ? "續約"
                                : "新約" %></td>
            <td><%= item.Lessons %></td>
            <td><%= String.Format("{0:yyyy/MM/dd}", item.ContractDate) %></td>
            <td><%= String.Format("{0:yyyy/MM/dd}", item.EffectiveDate) %></td>
            <td><%= String.Format("{0:yyyy/MM/dd}", item.Expiration) %></td>
            <td>
                <%= item.ContractCurrentStatus() %>
                <i class='zmdi zmdi-more-vert float-right'></i>
            </td>
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
                [0, 'asc']
            ],
            "pageLength": 30,
            "lengthMenu": [
                [30, 50, 100, -1],
                [30, 50, 100, "全部"]
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
                leftColumns: 1
            },
            "columnDefs": [{
                targets: [1, 3, 5, 6, 7, 8, 9],
                className: "align-center more"

            },
            {
                targets: [0, 2, 4, 10],
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

    <%  if (_viewModel.ScrollToView == false)
    {
    }
    else
    {   %>
            // 讓捲軸用動畫的方式移動到 #header 的 top 位置並加入動畫效果             
            $([document.documentElement, document.body]).animate({
                scrollTop: $(".dataTable-contract").offset().top
            }, 2000);
    <%  }   %>

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
    IQueryable<CourseContract> _model;
    CourseContractQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<CourseContract>)this.Model;
        _viewModel = ViewBag.ViewModel as CourseContractQueryViewModel;
    }


</script>
