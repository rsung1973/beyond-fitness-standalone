<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="jarviswidget" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
    <header class="bg-color-redLight">
        <span class="widget-icon"><i class="fa fa-birthday-cake"></i></span>
        <h2>今天有<%= _items.Where(u=>u.BirthdateIndex==startDay).Count() %>個學員生日喔!</h2>
    </header>
    <!-- widget div-->
    <div>
        <!-- widget content -->
        <div class="widget-body txt-color-white padding-5">
            <!-- content -->
            <%  foreach (var item in _items)
                    { %>
                        <div class="user">
                            <a href="http://line.me/R/msg/text/?｡◕‿◕｡╔ ░ⒽⒶⓅⓅⓎ░ ⒷⒾⓇⓉⒽ ⒹⒶⓎ░ ╗(◕‿◕✿)" target="_blank">
                                <%  item.RenderUserPicture(Writer, new { @class = "", @style = "width:40px" }); %><%= item.FullName() %>
                                <div class="email">
                                <%  if (item.BirthdateIndex==startDay)
                                    {   %>
                                    <label class="label bg-color-red">今天生日喔 <i class="fa fa-birthday-cake"></i></label>
                                <%  }
                                    else
                                    { %>
                                    <%= String.Format("{0:M/d}", item.Birthday) %>生日喔！
                                <%  } %>    
                                </div>
                            </a>
                        </div>
            <%  } %>
            <!-- end content -->
        </div>
        <!-- end widget content -->
    </div>
    <!-- end widget div -->
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    List<UserProfile> _items;
    int startDay, endDay;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;

        IQueryable<UserProfile> items = models.GetTable<UserProfile>();
        ServingCoach coach = (ServingCoach)ViewBag.CurrentCoach;
        if (coach != null)
        {
            items = items.Join(models.GetTable<LearnerFitnessAdvisor>().Where(a => a.CoachID == coach.CoachID),
                                u => u.UID, a => a.UID, (u, a) => u);
        }

        startDay = DateTime.Today.Month*100 + DateTime.Today.Day;
        var endDate = DateTime.Today.AddDays(7);
        endDay = endDate.Month*100 + endDate.Day;
        if (startDay < endDay)
        {
            _items = items.Where(u => u.BirthdateIndex >= startDay
                    && u.BirthdateIndex <= endDay)
                .OrderBy(u => u.BirthdateIndex).ToList();
        }
        else
        {
            _items = items
                    .Where(u => u.BirthdateIndex >= startDay)
                    .OrderBy(u => u.BirthdateIndex)
                    .ToList();
            _items.AddRange(items
                        .Where(u => u.BirthdateIndex <= endDay)
                        .OrderBy(u => u.BirthdateIndex));
        }

    }

</script>
