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
<div class="inline-group">
    <label class="label">依您輸入的關鍵字，搜尋結果如下：</label>
    <%  foreach (var item in _items)
        {
    %>
    <label class="radio">
        <input type="radio" name="UID" value="<%= item.UID %>" />
        <i></i><%= item.FullName() %>
    </label>
    <%      }   %>
</div>
<%  }
    else
    { %>
            查無相符條件的學員資料!!
    <%  }  %>
<%  if (ViewBag.EnableNew==true)
    {   %>
<%--<label class="radio">
    <input type="radio" name="searchNameRadio">
    <i></i>立即新增體驗學員
</label>
<div class="row">
    <section class="col col-4">
        <label class="label">請輸入體驗學員姓名</label>
        <label class="input">
            <input type="text" name="RealName" maxlength="20" class="input-lg" placeholder="請輸入學員姓名" value="" />
        </label>
    </section>
    <section class="col col-4">
        <label class="label">請輸入電話號碼</label>
        <label class="input">
            <input type="tel" name="Phone" maxlength="20" class="input-lg" placeholder="請輸入手機號碼或市話" data-mask="0999999999" value="" />
        </label>
    </section>
    <section class="col col-4">
        <label class="label">請選擇性別</label>
        <label class="select">
            <select class="input-lg" name="Gender" id="Gender">
                <option value="M">男</option>
                <option value="F">女</option>
            </select>
            <i class="icon-append far fa-keyboard"></i>
        </label>
    </section>
</div>--%>

<%  } %>
<script runat="server">

    ModelStateDictionary _modelState;
    IQueryable<UserProfile> _items;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _items = (IQueryable<UserProfile>)this.Model;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
