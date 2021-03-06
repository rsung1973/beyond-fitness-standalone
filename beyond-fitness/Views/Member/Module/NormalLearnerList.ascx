﻿<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<% if (_items != null && _items.Count() > 0)
    { %>

<table id="<%= _tableId %>" class="table table-striped table-bordered table-hover" width="100%">
    <thead>
        <tr>
            <th>體能顧問</th>
            <th data-class="expand"><i class="fa fa-fw fa-user text-muted hidden-md hidden-sm hidden-xs"></i>姓名</th>
            <th data-hide="phone"><i class="fa fa-fw fa-phone text-muted hidden-md hidden-sm hidden-xs"></i>電話</th>
            <th data-hide="phone"><i class="fa fa-fw fa-envelope text-muted hidden-md hidden-sm hidden-xs"></i>Email Address</th>
            <th data-hide="phone">編號</th>
            <th data-hide="phone">購買堂數</th>
            <th data-hide="phone">剩餘堂數</th>
            <th>功能</th>
        </tr>
    </thead>
    <tbody>
        <%  int idx = 0;
            int? totalLessons;
            int? attended;
            foreach (var item in _items)
            {
                idx++;%>
        <tr>
            <td><%= String.Join("<br/>",item.RegisterLesson.Where(r=>r.AdvisorID.HasValue).Select(r=>r.ServingCoach.UserProfile.RealName).Distinct())  %></td>
            <td><%= item.FullName() %></td>
            <td><%= item.Phone %></td>
            <td><%= item.LevelID==(int)Naming.MemberStatusDefinition.ReadyToRegister ? "尚未註冊" :  item.PID %></td>
            <td><%= item.MemberCode %></td>
            <td><%  var items = item.RegisterLesson.Where(l => l.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
                        .Where(l=>l.RegisterGroupID.HasValue);
                    totalLessons = items.Sum(l => l.Lessons);
                    Writer.Write(totalLessons); %></td>
            <td><%  attended = 
                        items.Sum(l => l.GroupingLesson.LessonTime.Count(/*t => t.LessonAttendance != null*/))
                        + items.Sum(l => l.AttendedLessons);
                    Writer.Write(totalLessons - attended); %></td>
            <td>
                <div class="btn-group dropup">
                    <button class="btn bg-color-blueLight" data-toggle="dropdown">
                        請選擇功能
                    </button>
                    <button class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <% if (item.LevelID == (int)Naming.MemberStatusDefinition.Deleted)
                            {   %>
                        <li>
                            <a href="<%= VirtualPathUtility.ToAbsolute("~/Member/EnableUser/") + item.UID %>"><i class="far fa-fw fa-check-square" aria-hidden="true"></i>啟用</a>
                        </li>
                        <li class="divider"></li>
                        <%  }
                            else
                            {
                                if (_userProfile.IsAssistant())
                                { %>
                        <li>
                            <a href="<%= VirtualPathUtility.ToAbsolute("~/Member/AddLessons/") + item.UID %>"><i class="fa fa-fw far fa-calendar-check" aria-hidden="true"></i>維護上課數</a>
                        </li>
                        <%      } %>
                        <li>
                            <a href="<%= VirtualPathUtility.ToAbsolute("~/member/PDQ/") + item.UID %>"><i class="fa fa-fw fa fa-street-view" aria-hidden="true"></i>問卷調查表</a>
                        </li>
                        <li>
                            <a href="<%= Url.Action("LearnerFitness","Activity",new { uid = item.UID }) %>"><i class="fa fa-fw fa fa-heart" aria-hidden="true"></i>檢測體能</a>
                        </li>
                        <li class="divider"></li>
                        <li>
                            <a href="#" onclick="checkBonus(<%= item.UID %>);" class="bonusDialog_link"><i class="fa fa-fw fa fa-gift" aria-hidden="true"></i>點數兌換</a>
                        </li>
                        <li class="divider"></li>
                        <li>
                            <a onclick='deleteLearner(<%= item.UID %>);'><i class="fa fa-fw far fa-trash-alt" aria-hidden="true"></i>刪除資料</a>
                        </li>
                        <%  } %>
                        <li>
                            <a href="<%= VirtualPathUtility.ToAbsolute("~/Member/EditLearner/") + item.UID %>"><i class="fa fa-fw fa fa-edit" aria-hidden="true"></i>修改資料</a>
                        </li>
                        <li>
                            <a href="<%= VirtualPathUtility.ToAbsolute("~/Member/ShowLearner/") + item.UID %>"><i class="fa fa-fw fa fa-eye" aria-hidden="true"></i>檢視資料</a>
                        </li>
                    </ul>
                </div>
                <%--<a class="btn btn-system btn-small" href="<%= VirtualPathUtility.ToAbsolute("~/Member/GroupLessons/") + item.UID %>">設定團體學員 <i class="fa fa-link" aria-hidden="true"></i></a>--%>
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
            "pageLength": 30,
            "lengthMenu": [[30, 50, 100, -1], [30, 50, 100, "全部"]],
            "ordering": true,
            "order": [[0, "desc"]],
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

    function checkBonus(id) {
        showLoading();
        $.post('<%= Url.Action("CheckBonus","LearnerFacet") %>', {'id' : id}, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
        return false;
    }
</script>

<%  }
    else
    { %>
<h4>未建立資料</h4>
<%  } %>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<UserProfile> _items;
    UserProfile _userProfile;
    String _tableId;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _tableId = ViewBag.DataTableId ?? "dt_learners_" + DateTime.Now.Ticks;
        _items = ((IQueryable<UserProfile>)this.Model).Where(u => !u.UserProfileExtension.CurrentTrial.HasValue);
        _userProfile = Context.GetUser();
    }

</script>
