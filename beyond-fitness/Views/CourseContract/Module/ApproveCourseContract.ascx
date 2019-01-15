<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="審核新合約" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding" style="overflow-y: initial;">
        <iframe src="<%= Url.Action("ViewContract","CourseContract",new { _model.ContractID }) %>" style="width:25cm;height:425px"  ></iframe>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            height: "560",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 審核新合約</h4></div>",
            buttons: [{
                html: "<i class='fa fa-times' aria-hidden='true'></i>&nbsp; 退件",
                "class": "btn",
                click: function () {
                    showLoading();
                    $.post('<%= Url.Action("ExecuteContractStatus","CourseContract",new { _model.ContractID, Status = (int)Naming.CourseContractStatus.草稿, Drawback=true }) %>', {}, function (data) {
                        hideLoading();
                        if (data.result) {
                            alert('合約已退件!!');
                            showLoading();
                            window.location.href = '<%= Url.Action("Index","CoachFacet",new { showTodoTab = true }) %>';
                        } else {
                            $(data).appendTo($('body')).remove();
                        }
                    });
                }
            },
            {
                html: "<i class='fa fa-check' aria-hidden='true'></i>&nbsp; 確認審核",
                "class": "btn btn-primary",
                click: function () {
                    showLoading();
                    $.post('<%= Url.Action("ExecuteContractStatus","CourseContract",new { _model.ContractID, Status = (int)Naming.CourseContractStatus.待簽名 }) %>', {}, function (data) {
                        hideLoading();
                        if (data.result) {
                            alert('合約審核完成!!');
                            showLoading();
                            window.location.href = '<%= Url.Action("Index","CoachFacet",new { showTodoTab = true }) %>';
                        } else {
                            $(data).appendTo($('body')).remove();
                        }
                    });
                }
            }],
            close: function () {
                $('#<%= _dialog %>').remove();
            }
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
