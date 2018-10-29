<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table id="dt_basic" class="table table-forum" width="100%">
    <thead>
        <tr>
            <th data-hide="phone" style="width: 40px"><i class="fa fa-fw fa-calendar-plus-o text-muted hidden-md hidden-sm hidden-xs"></i>日期</th>
            <th data-class="expand">課程類型</th>
            <th data-hide="phone">團體課程</th>
            <th style="width: 80px">剩餘/購買</th>
            <th data-hide="phone, tablet" style="width: 80px" data-hide="phone">付款方式</th>
            <th data-hide="phone, tablet" style="width: 50px" data-hide="phone">分期</th>
            <th data-hide="phone">是否付款</th>
            <%  if (ViewBag.ShowOnly != true)
                { %>
            <th style="width: 120px" data-hide="phone">功能</th>
            <%  } %>
        </tr>
    </thead>
    <tbody>
        <% if (_items != null && _items.Count() > 0)
        {
            foreach (var item in _items)
            { %>
                <tr>
                    <td><%= item.RegisterDate.ToString("yyyy/MM/dd") %></td>
                    <td><%= item.LessonPriceType.Description + " " + item.LessonPriceType.ListPrice %></td>
                    <td>
                        <%  if (item.GroupingMemberCount > 1)
                            {
                                var currentGroups = models.GetTable<GroupingLesson>().Where(g => g.GroupID == item.RegisterGroupID)
                                    .Join(models.GetTable<RegisterLesson>().Where(r => r.RegisterID != item.RegisterID), g => g.GroupID,
                                        r => r.RegisterGroupID, (g, r) => r);
                                if(currentGroups.Count()>0)
                                { 
                                %>
                                    <ul class="list-inline friends-list">
                                        <%  foreach (var g in currentGroups)
                                            { %>
                                                <li>
                                                    <a href="<%= VirtualPathUtility.ToAbsolute("~/Member/ShowLearner/") + g.UID %>">
                                                        <% g.UserProfile.RenderUserPicture(Writer, "_" + g.UID ); %><%= g.UserProfile.FullName() %></a>
                                                </li>
                                        <%  } %>
                                    </ul>
                         <%     }
                                else
                                { %>
                                    尚未設定團體成員
                        <%      }
                            }
                            else
                            {   %>
                                否
                        <%  } %>
                    </td>
                    <td><%= item.Lessons  - (item.AttendedLessons ?? 0)
                                - (item.RegisterGroupID.HasValue ? item.GroupingLesson.LessonTime.Count(/*l=>l.LessonAttendance!= null*/) : 0) %>/<%= item.Lessons %></td>
                    <td><%= item.IntuitionCharge!=null && item.IntuitionCharge.Payment=="Cash" ? "現金" : "信用卡" %></td>
                    <td><%= item.IntuitionCharge!=null && item.IntuitionCharge.ByInstallments > 1 ? item.IntuitionCharge.ByInstallments + "期" : "無" %></td>
                    <td>
                        <%  if(item.IntuitionCharge!=null && item.IntuitionCharge.TuitionInstallment.Count>0 )
                            { 
                                foreach (var t in item.IntuitionCharge.TuitionInstallment)
                                { %>
                                    <%= t.PayoffDate.HasValue ? String.Format("{0:yyyy/MM/dd}",t.PayoffDate) : "尚未付款" %><%= t.PayoffAmount.HasValue ? "《"+ String.Format("{0:##,###,###,###}",t.PayoffAmount)+ "》" : null %><br />
                            <%  }
                            }
                            else
                            {   %>
                                尚未付款
                        <%  } %>
                    </td>
                    <%  if (ViewBag.ShowOnly != true)
                        { %>
                            <td>
                                <%  bool grouping = item.GroupingMemberCount > 1;
                                    bool newRegistering = item.LessonTime.Count == 0;
                                      %>
                                    <div class="btn-group dropup">
                                        <button class="btn bg-color-blueLight" data-toggle="dropdown">
                                            請選擇功能
                                        </button>
                                        <button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                                            <span class="caret"></span>
                                        </button>
                                        <ul class="dropdown-menu">
                                            <%  if (grouping)
                                                { %>
                                                    <li>
                                                        <a onclick="javascript:addGroupingUser(<%= item.RegisterID %>);"><i class="fa fa-fw fa fa-link" aria-hidden="true"></i> 設定團體上課學員</a>
                                                    </li>
                                                    <li class="divider"></li>
                                            <%  } %>
                                                <li>
                                                    <a onclick="javascript:registerLessons(<%= item.RegisterID %>)"><i class="fa fa-fw fa fa-edit" aria-hidden="true"></i> 修改課堂數</a>
                                                </li>
                                                <li>
                                                    <a href="<%= Url.Action("LessonTuitionInstallment","Member",new { id = item.RegisterID }) %>"><i class="fa fa-fw fa fa-dollar-sign" aria-hidden="true"></i> 維護付款紀錄</a>
                                                </li>
                                            <%  if (newRegistering)
                                                { %>
                                                    <li>
                                                        <a onclick="javascript:deleteLesson(<%= item.RegisterID %>)"><i class="fa fa-fw far fa-trash-alt" aria-hidden="true"></i> 刪除資料</a>
                                                    </li>
                                            <%  } %>
                                        </ul>
                                    </div>
                            </td>
                    <%  } %>
                </tr>
        <%  }
        } %>
    </tbody>
</table>
<script>
    $(function () {

        /* BASIC ;*/
        var responsiveHelper_dt_basic = undefined;
        var responsiveHelper_datatable_fixed_column = undefined;
        var responsiveHelper_datatable_col_reorder = undefined;
        var responsiveHelper_datatable_tabletools = undefined;

        var breakpointDefinition = {
            tablet: 1024,
            phone: 480
        };

        $('#dt_basic').dataTable({
            "bPaginate": false,
            //"pageLength": 30,
            //"lengthMenu": [[30, 50, 100, -1], [30, 50, 100, "全部"]],
            "ordering": true,
            "sDom": "",
            "autoWidth": true,
            "oLanguage": {
                "sSearch": ''
            },
            "preDrawCallback": function () {
                // Initialize the responsive datatables helper once.
                if (!responsiveHelper_dt_basic) {
                    responsiveHelper_dt_basic = new ResponsiveDatatablesHelper($('#dt_basic'), breakpointDefinition);
                }
            },
            "rowCallback": function (nRow) {
                responsiveHelper_dt_basic.createExpandIcon(nRow);
            },
            "drawCallback": function (oSettings) {
                responsiveHelper_dt_basic.respond();
            }
        });

        /* END BASIC */
    });

    function deleteLesson(lessonID) {
        $.SmartMessageBox({
            title: "<i class=\"fa fa-fw far fa-trash-alt\" aria-hidden=\"true\"></i> 刪除課程",
            content: "確定刪除此課程資料?",
            buttons: '[刪除][取消]'
        }, function (ButtonPressed) {
            if (ButtonPressed == "刪除") {
                $('<form method="post"/>').appendTo($('body'))
                .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Member/DeleteLessons") %>' + '?id=' + lessonID)
                .submit();
            }
        });
    }

    function addGroupingUser(lessonId) {
        $('#linkgroup').remove();
        var $modal = $('<div class="modal fade" id="linkgroup" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" />');
        $('#loading').css('display', 'table');
        $modal.appendTo($('#content'))
            .load('<%= VirtualPathUtility.ToAbsolute("~/Member/GroupLessonUsers") %>', { 'lessonId': lessonId }, function () {
                $('#loading').css('display', 'none');
                $modal.on('hidden.bs.modal', function (evt) {
                    $('body').scrollTop(screen.height);
                });
                $modal.modal('show');
            });
    }

    function payInstallment(registerID) {
        $('#linkgroup').remove();
        var $modal = $('<div class="modal fade" id="linkgroup" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" />');
        $('#loading').css('display', 'table');
        $modal.appendTo($('#content'))
            .load('<%= VirtualPathUtility.ToAbsolute("~/Member/PayInstallment") %>', { 'registerID': registerID }, function () {
                $('#loading').css('display', 'none');
                $modal.on('hidden.bs.modal', function (evt) {
                    $('body').scrollTop(screen.height);
                });

                $modal.modal('show');
            });
    }
</script>
<script runat="server">

    IQueryable<RegisterLesson> _items;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _items = (IQueryable<RegisterLesson>)this.Model;
    }

</script>
