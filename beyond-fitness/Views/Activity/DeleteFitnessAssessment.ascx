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


<div class="modal fade" id="<%= ViewBag.ModalId ?? "theModal" %>" tabindex="-1" role="dialog" aria-labelledby="confirmLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                                &times;
                            </button>
                            <h4 class="modal-title" id="myModalLabel">刪除檢測項目</h4>
                        </div>
                        <div class="modal-body bg-color-darken txt-color-white">                           
                                 <div class="row">
                                    <label class="control-label">請勾選檢測項目後點選送出即可刪除</label>
                                    <div class="form-group">                                            
                                            <div class="col-md-10">
                                                <%  foreach (var item in _model.LearnerFitnessAssessmentResult)
                                                    { %>
                                                        <div class="checkbox">
                                                            <label class="font-lg">
                                                                <input type="checkbox" name="itemID" value="<%= item.ItemID %>">
                                                                <%= item.FitnessAssessmentItem.ItemName %> <%= item.Assessment %><%= item.FitnessAssessmentItem.Unit %></label>
                                                        </div>
                                                <%  } %>
                                            </div>
                                    </div>
                                </div>                                                              
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">
                                取消
                            </button>
                            <button type="button" id="btnDeleteAssessment" class="btn btn-primary">
                                送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                            </button>
                        </div>
        </div>
    </div>
</div>
<script>
    
    $(function () {
        var $modal = $('#<%= ViewBag.ModalId ?? "theModal" %>');
        $modal.on('hidden.bs.modal', function (evt) {
            $modal.remove();
        });

        //$modal.on('shown.bs.modal', function () {
        //    $(this).find('.modal-dialog').css({
        //        width: 'auto',
        //        height: 'auto',
        //        'max-height': '100%'
        //    });
        //});

        $modal.modal('show');

        $('#btnDeleteAssessment').on('click', function (evt) {
            var itemID = [];
            $('input:checkbox[name="itemID"]:checked').each(function(idx) {
                itemID[itemID.length] = $(this).val();
            });
            deleteFitnessAssessment(<%= _model.AssessmentID %>,itemID);
            $modal.modal('hide');
        });
    });

</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LearnerFitnessAssessment _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LearnerFitnessAssessment)this.Model;
        ViewBag.ModalId = "editAssessment";
    }

</script>
