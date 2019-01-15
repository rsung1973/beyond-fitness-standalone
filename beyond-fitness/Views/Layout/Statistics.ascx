<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  if (_userProfile != null && _userProfile.CurrentUserRole.RoleID != (int)Naming.RoleID.Learner)
    { %>
<ul id="sparks">
        <%  if (_item != null)
            { %>
                <li class="sparks-info">
                    <h5>
                        <%--<%  _item.UserProfile.RenderUserPicture(Writer, new { @class = "online", @style = "width:30px" }); %>
                        <%= _item.UserProfile.FullName() %>--%>
                        <span class="txt-color-blue">
                            <a href="javascript:void(0);" rel="tooltip" data-placement="top" data-original-title="<h1><em><%= _item.Title %></em></h1>" data-html="true"><%= /*_item.Title.Length>15 ?_item.Title.Substring(0,15) + "..." :*/ _item.Title %></a>
                        </span>
                    </h5>
                </li>
    <%      } %>
    <li class="sparks-info">
        <h5>今日上課人數 <span class="txt-color-blue"><% Html.RenderAction("DailyLearnerCount", "Lessons", new { date = DateTime.Today }); %>人</span></h5>
        <div class="sparkline txt-color-blue">
            <% Html.RenderAction("DailyBookingHourlyList", "Lessons", new { lessonDate = DateTime.Today }); %>
        </div>
    </li>
</ul>
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _userProfile;
    static Article _item;
    static long _Expiration = 0;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _userProfile = Context.GetUser();

        if (_item == null || _Expiration < DateTime.Now.Ticks)
        {
            lock (this.GetType())
            {
                if (_item == null || _Expiration < DateTime.Now.Ticks)
                {
                    _Expiration = DateTime.Today.AddDays(1).Ticks;
                    var items = models.GetTable<Document>().Where(d => d.DocType == (int)Naming.DocumentTypeDefinition.Inspirational)
                        .Select(d => d.Article.Publication)
                        .Where(p => p.StartDate < DateTime.Today.AddDays(1) && (!p.EndDate.HasValue || p.EndDate >= DateTime.Today))
                        .Select(p => p.Article)
                        .OrderBy(a => a.DocID);

                    var count = items.Count();
                    if (count > 0)
                    {
                        int skipCount = (int)(DateTime.Now.Ticks % count);
                        _item = items.Skip(skipCount).Take(1).FirstOrDefault();
                        if(_item!=null)
                        {
                            var p = _item.UserProfile;
                        }
                    }
                }
            }
        }

    }

</script>
