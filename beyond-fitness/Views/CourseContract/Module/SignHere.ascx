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

<%  if(_model.CourseContract.Status==(int)Naming.CourseContractStatus.待簽名)
    {
        if (_model.CourseContract.CourseContractType.IsGroup==true)
        {%>
<img onclick="signaturePanel(<%= _model.ContractID %>,<%= _model.UID %>,'<%= ViewBag.SignatureName %>');" src="<%= _item != null && _item.Signature != null ? _item.Signature : VirtualPathUtility.ToAbsolute("~/img/SignHere.png") %>" width="160px" />
    <%  }
        else
        {   %>
<img onclick="signaturePanel(<%= _model.ContractID %>,<%= _model.UID %>,'<%= ViewBag.SignatureName %>');" src="<%= _item != null && _item.Signature != null ? _item.Signature : VirtualPathUtility.ToAbsolute("~/img/SignHere.png") %>" width="200px" />
    <%  }
    }
    else if(_item != null && _item.Signature != null)
    { 
        if (_model.CourseContract.CourseContractType.IsGroup==true)
        {   %>
<img src="<%= _item.Signature %>" width="160px" />
    <%  }
        else
        {   %>
<img src="<%= _item.Signature %>" width="200px" />
    <%  }
    } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractMember _model;
    CourseContractSignature _item;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContractMember)this.Model;
        _item = _model.CourseContractSignature.Where(s => s.SignatureName == ViewBag.SignatureName).FirstOrDefault();
    }

</script>
