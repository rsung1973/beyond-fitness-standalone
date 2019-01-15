<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<section class="col col-12">
    <%  if (_model.Count() > 0)
        { %>
    <label class="label">依您輸入的關鍵字，搜尋結果如下：</label>
        <%  foreach (var item in _model)
            { %>
    <label class="radio">
        <input type="radio" name="UID" value="<%= item.UID %>" />
        <i></i><%= item.FullName() %>
    </label>
        <%  } %>
    <%  }
        else
        { %>
    <span>查無相符條件的學員資料!!</span>
    <%  } %>
    <label class="radio">
        <input type="radio" name="UID" value="" />
        <i></i>立即新增學員資料
    </label>
    <%  if (ViewBag.ReferenceUID != null)
        { %>
    <label class="radio">
        <input type="radio" name="referenceUID" value="<%= ViewBag.ReferenceUID %>">
        <i></i>立即新增學員資料(複製前一筆資料再進行修改)
    </label>
    <%  } %>
</section>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<UserProfile> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<UserProfile>)this.Model;
    }

</script>
