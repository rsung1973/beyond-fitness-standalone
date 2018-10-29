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
<%@ Import Namespace="Newtonsoft.Json" %>

<div id="<%= _dialogID %>" title="修改評量指數" class="bg-color-darken">
    <div class="panel panel-default bg-color-darken">
        <form>
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <div class="icon-addon">
                                <select class="form-control" name="trendItem">
                                    <option value="<%= _model.ItemID %>"><%= _model.FitnessAssessmentItem.ItemName %></option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="input-group">
                            <div class="icon-addon">
                                <input type="number" step="0.1" name="totalAssessment" placeholder="請輸入純數字" class="form-control" value="<%= String.Format("{0:.#}",_model.TotalAssessment) %>" required />
                            </div>
                            <span class="input-group-addon">分鐘</span>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    
    $(function () {
        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "600",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-edit'></i>  編輯休息時間與總組數</h4>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {

                    var $form = $('#<%= _dialogID %> form');
                    if(!validateForm($form[0]))
                        return false;

                    commitAssessmentTrendItem({
                        'assessmentID': <%= _model.AssessmentID %>,
                        'itemID':<%= _model.ItemID %>,
                        'totalAssessment': $('input[name="totalAssessment"]').val()});
                    $(this).dialog("close");
                }
            }],
            close: function (event, ui) {
                $('#<%= _dialogID %>').remove();
            }
        });

    });

</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonFitnessAssessmentReport _model;
    String _dialogID = "editAssessment" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFitnessAssessmentReport)this.Model;
    }

</script>
