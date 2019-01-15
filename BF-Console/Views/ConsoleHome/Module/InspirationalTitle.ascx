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
<%  if (_item != null)
    { %>
<%= _item.Title %>
<%      } %>
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
                        if (_item != null)
                        {
                            var p = _item.UserProfile;
                        }
                    }
                }
            }
        }

    }

</script>
