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

<script>
    $(function () {
        $('').launchDownload('<%= Url.Action("ShowContractList","ContractConsole") %>',
            <%= JsonConvert.SerializeObject(new CourseContractQueryViewModel
                {
                    //FitnessConsultant = _model.FitnessConsultant,
                    //ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                    //Status = (int)Naming.CourseContractStatus.草稿,
                    KeyID = _model.ContractID.EncryptKey(),
                }) %>);
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContract _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
    }


</script>
