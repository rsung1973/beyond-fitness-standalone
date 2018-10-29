<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<%  
    switch ((Naming.QuestionType)_model.QuestionType)
    {
        case Naming.QuestionType.問答題:
            Html.RenderPartial("~/Views/Interactivity/Module/QuestionAndAnswer.ascx", _model);
            break;
        case Naming.QuestionType.單選題:
        case Naming.QuestionType.單選其他:
            Html.RenderPartial("~/Views/Interactivity/Module/SingleChoice.ascx", _model);
            break;
        case Naming.QuestionType.多重選:
            break;
        case Naming.QuestionType.是非題:
            Html.RenderPartial("~/Views/Interactivity/Module/YesOrNo.ascx", _model);
            break;
    } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    PDQQuestion _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (PDQQuestion)this.Model;
    }

</script>
