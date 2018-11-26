<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<li class="col-lg-4 col-md-4 col-12">
    <div class="body mylearner">
        <div class="user-info">
            <div class="image">
                <%  if (_item != null)
                    {   %>
                <a href="profile.html">
                    <% _item.AsAttendingCoach.UserProfile.PictureID.RenderUserPicture(this.Writer, null , "images/avatar/noname.png"); %>
                </a>
                <%  }
                    else
                    {   %>
                <img src="images/avatar/noname.png" />
                <%  } %>
            </div>
        </div>
        <h6 class="m-t-10">本日頭條</h6>
    </div>
</li>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    static LessonTime _item;
    static long _Expiration = 0;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;

        if (_item == null || _Expiration < DateTime.Now.Ticks)
        {
            lock (this.GetType())
            {
                if (_item == null || _Expiration < DateTime.Now.Ticks)
                {
                    _Expiration = DateTime.Today.AddDays(1).Ticks;

                    var finished = models.GetTable<LessonTime>()
                                    .Where(l => l.ClassTime >= DateTime.Today.AddDays(-7))
                                    .Where(l => l.LessonAttendance != null).PTorPILesson()
                                    .OrderBy(l => l.LessonID);

                    var finishedCount = finished.Count();
                    if (finishedCount > 0)
                    {
                        int skipCount = (int)(DateTime.Now.Ticks % finishedCount);
                        _item = finished.Skip(skipCount).Take(1).FirstOrDefault();
                    }
                }
            }
        }

    }

</script>
