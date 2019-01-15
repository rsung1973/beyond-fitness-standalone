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
        {   %>
            <label class="label">依您輸入的關鍵字，搜尋結果如下：</label>
    <%      Html.RenderPartial("~/Views/Lessons/Module/CourseContractAttendeeSelector.ascx", _items);
        }
        else
        { %>
            <span>查無相符條件的上課資料！</span>
    <%  } %>


<script runat="server">

    ModelStateDictionary _modelState;
    IQueryable<RegisterLesson> _items;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _items = (IQueryable<RegisterLesson>)this.Model;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
