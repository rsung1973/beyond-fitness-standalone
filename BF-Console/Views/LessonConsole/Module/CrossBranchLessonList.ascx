<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table class="table table-striped nowrap dataTable-crossBranch" style="width: 100%">
    <thead class="bg-darkteal">
        <tr>
            <th>體能顧問</th>
            <th>日期</th>
            <th>開始時間</th>
            <th>結束時間</th>
            <th>類型</th>
            <th>學生</th>
            <th>課程類別佔比</th>
            <th>該時段總人數</th>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            {   %>
        <tr onclick="processCrossBranch('<%= item.LessonID.EncryptKey() %>');">
            <td>
                <span class='list-icon'>
                    <% item.AsAttendingCoach.UserProfile.PictureID.RenderUserPicture(this.Writer, new { @class = "patients-img" }, "images/avatar/noname.png"); %>
                </span>
                <span class='hidden-sm-down'><%= item.AsAttendingCoach.UserProfile.RealName %>
                    <span class='small'>(<%= item.AsAttendingCoach.UserProfile.Nickname %>)</span>
                </span>
            </td>
            <td><%= $"{item.ClassTime:yyyy/MM/dd}" %></td>
            <td><%= $"{item.ClassTime:HH:mm}" %></td>
            <td><%= $"{item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value):HH:mm}" %></td>
            <td><%= item.LessonTypeStatus() %></td>
            <td><%= String.Join("、", item.GroupingLesson.RegisterLesson.Select(r => r.UserProfile.RealName))  %></td>
            <td>
                <%  var expansion = item.LessonTimeExpansion.First(); %>
                <%  var lessons = expansion.ConcurrentLessons(models); %>
                <div class='sparkline-pie'><%= lessons.PTLesson().Count() %>,<%= lessons.PILesson().Count() %>,<%= lessons.TrialLesson().Count() %></div>
            </td>
            <td>
                <%= lessons.ConcurrentRegisterLessons(models).Count() %>
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

        $global.dtContract = $('.dataTable-crossBranch').DataTable({
            //"ajax": 'ajax/data/contractlist-2.json',
            "order": [
                [1, 'desc'],
                [2, 'asc']
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
                leftColumns: 1,
            },
            columnDefs: [
                {
                    targets: [1, 2, 3, 4, 6, 5, 7],
                    className: "align-center more"
                },
                {
                    targets: [0],
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
                var $pie = $('.sparkline-pie')
                    .filter(function (idx, elment) {
                        return $('canvas', this).length === 0;
                    }).sparkline('html', {
                        type: 'pie',
                        offset: 90,
                        width: '50px',
                        height: '50px',
                        sliceColors: ['#ffe6aa', '#eeaaaa', '#c5b6e2']
                    });
            },

            "drawCallback": function (settings) {
            },
        });

        setTimeout(function () {
            var $btnSelect = $('.dataTables_length div.btn-group.bootstrap-select.form-control.form-control-sm');
            var $menu = $btnSelect.find('select');
            $btnSelect.before($menu);
            $btnSelect.remove();
        }, 1000);

        //$global.dtContract.on('draw', function () {
        //    console.log('draw...')
        //    var $btnSelect = $('.dataTables_length div.btn-group.bootstrap-select.form-control.form-control-sm');
        //    console.log($btnSelect);
        //    var $menu = $btnSelect.find('select');
        //    $btnSelect.before($menu);
        //    $btnSelect.remove();
        //});

        $('.dataTable-crossBranch').resize();

    });

</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonTime> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
    }


</script>
