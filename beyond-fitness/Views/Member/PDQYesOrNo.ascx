<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

    <label class="label font-md"><%=  _model.QuestionNo %>.<%= _model.Question %></label>
    <div class="inline-group">
        <label class="radio font-md">
            <input type="radio" name="<%= "_" + _model.QuestionID %>" value="1"/>
            <i></i>是</label>
        <label class="radio font-md">
            <input type="radio" name="<%= "_" + _model.QuestionID %>" value="0" />
            <i></i>否</label>
            <%  if (_task != null && _task.YesOrNo.HasValue)
                { %>
            <script>
                $('input:radio[name="<%= "_" + _model.QuestionID %>"][value="<%= _task.YesOrNo==true ? 1 : 0 %>"]').prop('checked', true);
            </script>
            <%  } %>
    </div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PDQQuestion _model;
    PDQTask _task;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (PDQQuestion)this.Model;
        _task = (PDQTask)ViewBag.PDQTask;
    }

</script>
