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

<% if (_items != null && _items.Count() > 0)
    { %>
<table class="table">
    <tr class="info">
        <th class="col-xs-3 col-md-1 text-center">姓名</th>
        <th class="col-xs-3 col-md-1 text-center">學員編號</th>
        <th class="col-xs-6 col-md-10 text-center">功能</th>
    </tr>
    <% foreach (var item in _items)
        { %>
    <tr>
        <td><%= item.RealName %></td>
        <td class="text-center"><%= item.MemberCode %></td>
        <td>
            <a class="btn btn-system btn-small" href="<%= VirtualPathUtility.ToAbsolute("~/Member/EditLearner/") + item.UID %>">修改 <i class="fa fa-edit" aria-hidden="true"></i></a>
            <%--<a class="btn btn-system btn-small" href="<%= VirtualPathUtility.ToAbsolute("~/Member/AddLessons/") + item.UID %>">新增上課數 <i class="fa fa-plus-square" aria-hidden="true"></i></a>--%>
            <% if (item.LevelID == (int)Naming.MemberStatusDefinition.Deleted)
                { %>
            <a class="btn btn-system btn-small" href="<%= VirtualPathUtility.ToAbsolute("~/Member/EnableUser/") + item.UID %>">啟用 <i class="fa fa-check-square" aria-hidden="true"></i></a>
            <a class="btn btn-system btn-small disabled">新增/刪除上課數 <i class="fa fa-calendar-o" aria-hidden="true"></i></a>
            <%  }
                else
                { %>
            <a class="btn btn-system btn-small" onclick='deleteLearner(<%= item.UID %>);'>刪除 <i class="fa fa-trash-o" aria-hidden="true"></i></a>
            <a class="btn btn-system btn-small" href="<%= VirtualPathUtility.ToAbsolute("~/Member/AddLessons/") + item.UID %>">新增/刪除上課數 <i class="fa fa-calendar-o" aria-hidden="true"></i></a>
                    <% if (item.RegisterLesson.Where(r => r.Attended == (int)Naming.LessonStatus.準備上課 && r.GroupingMemberCount > 1).Count() > 0)
                        { %>
            <a class="btn btn-system btn-small" href="<%= VirtualPathUtility.ToAbsolute("~/Member/GroupLessons/") + item.UID %>">設定團體學員 <i class="fa fa-link" aria-hidden="true"></i></a>
                    <%  } %>
            <%  }  %>
            <a class="btn btn-system btn-small" href="<%= VirtualPathUtility.ToAbsolute("~/member/PDQ/") + item.UID %>">填寫問卷 <i class="fa fa-pencil" aria-hidden="true"></i></a>
            <a href="<%= VirtualPathUtility.ToAbsolute("~/Member/ShowLearner/") + item.UID %>" class="btn btn-system btn-small">檢視 <i class="fa fa-eye" aria-hidden="true"></i></a>
        </td>
    </tr>
    <%     } %>
</table>
<%  }
    else { %>
<h4>未建立資料</h4>
<% } %>


<script runat="server">

    ModelSource<UserProfile> models;
    IEnumerable<UserProfile> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _items = (IEnumerable<UserProfile>)this.Model;
    }




</script>
