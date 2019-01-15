<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%  var weekStart = DateTime.Today.FirstDayOfWeek(); %>
<li id="<%= _viewID %>" class="<%= $"col-sm-{12/_allotment} col-{12/_allotment}" %>" onclick="window.location.href='<%= Url.Action("CrossBranchIndex","ConsoleHome") %>';">
    <div class="body">
        <i class="zmdi livicon-evo" data-options="name: legal.svg; size: 40px; style: original; strokeWidth:2px; autoPlay:true"></i>
        <h4><%  var count =
                _items
                    .Where(l => l.ClassTime >= weekStart && l.ClassTime < weekStart.AddDays(7))
                    .Count(); %>
            <%= count %>
        </h4>
        <span>預約待審核</span>
    </div>
    <%  if (count > 0)
        {%>
    <script>
        $(function () {
            $('#<%= _viewID %>').onclick(function (event) {

            });
        });
    </script>
    <%  } %>
</li>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonTime> _items;
    UserProfile _model;
    int _allotment;
    String _viewID = $"preferred{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _allotment = ((int?)ViewBag.Allotment) ?? 2;

        _items = _model.PreferredLessonTimeToApprove(models);

    }


</script>
