<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="編輯目標" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitDiagnosisGoal","FitnessDiagnosis",new { diagnosisID = _model.DiagnosisID }) %>" method="post" class="smart-form" autofocus>
            <fieldset>
                <div class="form-group">
                    <label class="label">目標</label>
                    <textarea cols="80" class="form-control" name="Goal" placeholder="請輸入目標" rows="3"><%= _model.Goal %></textarea>
                </div>
            </fieldset>
            <fieldset>
                <div class="form-group">
                    <label class="label">診斷內容</label>
                    <textarea cols="80" class="form-control" placeholder="請輸入診斷內容" rows="3" name="Description"><%= _model.Description %></textarea>
                </div>
            </fieldset>
        </form>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-anchor'></i>  編輯診斷內容</h4>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {
                    showLoading();
                    $('#<%= _dialog %> form').ajaxSubmit({
                        success: function (data) {
                            hideLoading();
                            if ($.isPlainObject(data)) {
                                alert(data.message);
                            } else {
                                $('#diagGoal').html(data);
                                $('#<%= _dialog %>').dialog('close');
                            }
                        }
                    });
                }
            }],
            close: function (event, ui) {
                $('#<%= _dialog %>').remove();
            }
        });
    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "diagoDesc" + DateTime.Now.Ticks;
    BodyDiagnosis _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (BodyDiagnosis)this.Model;
    }

</script>
