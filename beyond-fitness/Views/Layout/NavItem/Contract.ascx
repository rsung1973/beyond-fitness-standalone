<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_userProfile != null
        && (_userProfile.IsCoach() || _userProfile.IsAssistant() || _userProfile.IsOfficer()))
    { %>
<li>
    <a href="#" title="合約管理"><i class="fas fa-lg fa-fw fa-file-alt"></i><span class="menu-item-parent">合約管理</span></a>
    <ul>
        <li>
            <a href="<%= Url.Action("CreateContract", "CourseContract") %>" title="新增合約"><i class="far fa-lg fa-fw fa-copy"></i>新增合約</a>
        </li>
        <li>
            <a href="<%= Url.Action("ApplyAmendment", "CourseContract") %>" title="服務申請"><i class="fa fa-lg fa-fw fa-cogs"></i>服務申請</a>
        </li>
        <li>
            <a href="<%= Url.Action("ContractIndex","CourseContract") %>" title="合約查詢"><i class="fa fa-lg fa-fw fa-search"></i>合約查詢</a>
        </li>
        <%  if (_userProfile.IsAssistant() || _userProfile.IsOfficer())
            { %>
        <li>
            <a href="<%= Url.Action("ProgramIndex", "EnterpriseProgram") %>" title="企業合作方案"><i class="fas fa-lg fa-fw fa-hands-helping"></i>企業合作方案</a>
        </li>
        <%  }
            if(_userProfile.IsAssistant())
            { %>
        <li>
            <a href="<%= Url.Action("PriceIndex","LessonPrice") %>" title="體能顧問服務費用維護"><i class="fa fa-lg fa-fw fa-tasks"></i>體能顧問服務價目維護</a>
        </li>
        <%  } %>
    </ul>
</li>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    UserProfile _userProfile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _userProfile = Context.GetUser();
    }

</script>
