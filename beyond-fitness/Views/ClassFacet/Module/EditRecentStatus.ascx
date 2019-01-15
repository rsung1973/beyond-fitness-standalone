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

<div id="modifyStudentStatusDialog" title="更新個人近況" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white">
        <form>
            <fieldset>
                <div class="form-group">
                    <textarea cols="80" class="form-control" placeholder="請輸入個人近況" rows="10" name="recentStatus"><%= _model.RecentStatus %></textarea>
                    <p class="note"><strong>Note:</strong> 最多輸入250個中英文字</p>
                </div>
            </fieldset>
        </form>
    </div>
    <script>

        $('#modifyStudentStatusDialog').dialog({
            //autoOpen : false,
            resizable : true,
            modal : true,
            width: "auto",
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-edit'></i>  更新個人近況</h4>",
            close: function (event, ui) {
                $('#modifyStudentStatusDialog').remove();
            },
            buttons : [{
                html : "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class" : "btn btn-primary",
                click : function() {
                    commitRecentStatus(<%= _model.UID %>,$('#modifyStudentStatusDialog').find('textarea').val());
                    $(this).dialog("close");
                }
            }]
        });

    </script>
</div>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        ViewBag.ModalId = "editRecentStatus";
    }

</script>
