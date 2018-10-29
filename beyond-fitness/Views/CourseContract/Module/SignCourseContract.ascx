<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="合約簽名" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding" style="overflow: scroll; -webkit-overflow-scrolling: touch">
        <iframe src="<%= Url.Action("ContractSignatureView","CourseContract",new { _model.ContractID }) %>" style="width:25cm;height:500px"  ></iframe>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            height: "560",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 合約簽名</h4></div>",
            <%--buttons: [{
                html: "<i class='fa fa-times' aria-hidden='true'></i>&nbsp; 重新整理",
                "class": "btn",
                click: function () {
                    $('#<%= _dialog %>').dialog('close');
                }
            }],--%>
            close: function (event, ui) {
                $('#<%= _dialog %>').remove();
                showLoading();
                window.location.href = '<%= Url.Action("Index","CoachFacet",new { showTodoTab = true }) %>';
            },
        });

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "reviewContract" + DateTime.Now.Ticks;
    CourseContract _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
    }

</script>
