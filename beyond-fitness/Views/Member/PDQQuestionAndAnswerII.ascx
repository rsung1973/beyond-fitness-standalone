<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<section class="bg-color-pinkDark">
    <label class="label font-md"><%= _model.Question %></label>
    <label class="input">
        <i class="icon-append fa fa-comment-o"></i>
        <input type="text" name="<%= "_" + _model.QuestionID %>" class="input-lg" placeholder="最多僅輸入50個中英文字" maxlength="50" value="<%= _item!=null ? _item.PDQAnswer : null %>" />
    </label>
</section>

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
