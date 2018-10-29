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

<div id="<%= _dialog %>" title="設定體能顧問" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitAdvisorAssignment","Learner",new { _model.UID }) %>" class="smart-form" autofocus>
            <fieldset>
                <section>
                    <label class="label">體能顧問</label>
                    <label class="select">
                        <select class="input" name="CoachID">
                            <option value="">請選擇體能顧問</option>
                            <%  var items = models.GetTable<ServingCoach>().Where(c =>
                                    !models.GetTable<LearnerFitnessAdvisor>().Where(f => f.UID == _model.UID)
                                        .Select(f => f.CoachID)
                                        .Contains(c.CoachID));
                                Html.RenderPartial("~/Views/SystemInfo/ServingCoachOptions.ascx",items); %>
                        </select>
                        <i class="icon-append far fa-keyboard"></i>
                    </label>
                </section>
            </fieldset>
        </form>
    </div>
    <script>
        console.log('debug...');

        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "auto",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 設定體能顧問</h4></div>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
                "class": "btn btn-primary",
                click: function () {
                    var $form = $('#<%= _dialog %> form');
                    clearErrors();
                    $form.ajaxSubmit({
                        beforeSubmit: function () {
                            showLoading();
                        },
                        success: function (data) {
                            hideLoading();
                            if ($.isPlainObject(data)) {
                                if (data.result) {
                                    $global.listAdvisor(<%= _model.UID %>);
                                    $('#<%= _dialog %>').dialog('close');
                                } 
                            } else {
                                $(data).appendTo($('body')).remove();
                            }
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
    String _dialog = "selectAdvisor" + DateTime.Now.Ticks;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;

    }

</script>
