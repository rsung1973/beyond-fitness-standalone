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

<!-- TABLE 1 -->
<% if (_items != null && _items.Count() > 0)
    { %>
<table class="table">
    <tr class="info">
        <th class="col-xs-4 col-md-2 text-center">姓名</th>
        <th class="col-xs-1 col-md-2 text-center">員工編號</th>
        <th class="col-xs-7 col-md-8 text-center">功能</th>
    </tr>
    <% foreach (var item in _items)
        { %>
    <tr>
        <td><%= item.RealName %></td>
        <td class="text-center"><%= item.MemberCode %></td>
        <td>
            <a class="btn btn-system btn-small" href="<%= VirtualPathUtility.ToAbsolute("~/Member/EditCoach/") + item.UID %>">修改 <i class="fa fa-edit" aria-hidden="true"></i></a>
            <% if (item.LevelID == (int)Naming.MemberStatusDefinition.Deleted)
                { %>
            <a class="btn btn-system btn-small" href="<%= VirtualPathUtility.ToAbsolute("~/Member/EnableUser/") + item.UID %>">啟用 <i class="fa fa-plus-square" aria-hidden="true"></i></a>
            <%  }
                else
                { %>
            <a  class="btn btn-system btn-small" onclick='deleteCoach(<%= item.UID %>);'>刪除 <i class="fa fa-trash-o" aria-hidden="true"></i></a>
            <%  } %>
            <a class="btn btn-system btn-small" href="<%= VirtualPathUtility.ToAbsolute("~/Member/ShowMember/") + item.UID %>">檢視 <i class="fa fa-eye" aria-hidden="true"></i></a>
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
        models = (ModelSource<UserProfile>)this.Model;

        _items = models.EntityList  //.Where(u => u.LevelID != (int)Naming.MemberStatusDefinition.Deleted)
            .Join(models.GetTable<UserRole>()
                .Where(r => r.RoleID == (int)Naming.RoleID.Coach || r.RoleID == (int)Naming.RoleID.FreeAgent),
            u => u.UID, r => r.UID, (u, r) => u);
    }

</script>
