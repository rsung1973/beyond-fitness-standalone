<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<label class="label"><%--<i class="fa-fw fa fa-quora"></i>--%><%=  _model.QuestionNo %>.<%= _model.Question %></label>
<label class="textarea">
    <i class="icon-append fa fa-comments"></i>
    <textarea rows="1" name="<%= "_" + _model.QuestionID %>" placeholder="<%= _item!=null ? _item.PDQAnswer : "請輸入簡短描述" %>" maxlength="100"></textarea>
</label>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PDQQuestion _model;
    PDQTask _item;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (PDQQuestion)this.Model;
        _item = (PDQTask)ViewBag.PDQTask;
    }

</script>
