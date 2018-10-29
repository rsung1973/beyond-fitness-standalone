<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%  if (_model.Count() > 0)
    { %>
<label class="label">尚未繳納自主訓練費用學員如下：</label>
    <%  foreach (var item in _model)
        { %>
        <label class="radio">
            <input type="radio" name="RegisterID" value="<%= item.RegisterID %>"/>
            <i></i><%= item.RegisterLesson.UserProfile.FullName() %>（<%= String.Format("{0:yyyy/MM/dd HH:mm}",item.ClassTime) %>~<%= String.Format("{0:HH:mm}",item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value)) %>）
        </label>
    <%  } %>
<%  }
    else
    { %>
無符合條件的資料!!
<%  } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonTime> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonTime>)this.Model;
        _model = _model.OrderBy(l => l.ClassTime);
    }

</script>
