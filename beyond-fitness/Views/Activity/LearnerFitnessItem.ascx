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
                <h4 class="modal-title" id="myModalLabel">新增檢測項目</h4>
            </div>
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="row">
                    <div class="col-md-4 smart-form">
                        <label class="input input-group" data-date-format="yyyy/mm/dd" data-link-field="dtp_input1">
                            <i class="icon-append far fa-calendar-alt"></i>
                            <input type="text" class="form-control input-lg date form_date" value="<%= String.Format("{0:yyyy/MM/dd}",DateTime.Today) %>" readonly="readonly" data-date-format="yyyy/mm/dd" placeholder="請點選日曆" name="assessmentDate" id="assessmentDate" />
                        </label>
                    </div>

                    <div class="col-md-4">
                        <div class="form-group">
                            <div class="icon-addon addon-lg">
                                <select class="form-control" name="itemID">
                                </select>
                            </div>

                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="input-group input-group-lg">
                            <div class="icon-addon addon-lg">
                                <input type="number" class="form-control" name="assessment" id="assessment" />
                            </div>
                            <span id="itemUnit" class="input-group-addon">kg</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">
                    取消
                </button>
                <button type="button" id="btnAssess" class="btn btn-primary">
                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                </button>
            </div>
        </div>
    </div>
</div>
<script>

    var fitnessItem = <%= JsonConvert.SerializeObject(_model
        .Select(f => new {
            f.ItemID,
            f.ItemName,
            f.Unit,
            f.UseCustom,
            f.UseSingleSide
        }).ToArray()) %>;
    
    $(function () {
        var $modal = $('#<%= ViewBag.ModalId ?? "theModal" %>');
        $modal.on('hidden.bs.modal', function (evt) {
            $modal.remove();
        });

        fitnessItem.forEach(function(item,index) {
            $('<option>').prop('value',item.ItemID)
                .prop('unit',item.Unit)
                .prop('useCustom',item.UseCustom)
            .text(item.ItemName).appendTo($('select[name="itemID"]'));
        });

        $('select[name="itemID"]').on('change',function(evt){
            $('#itemUnit').text($('select[name="itemID"]').find('option:selected').prop('unit'));
            if($('select[name="itemID"]').find('option:selected').prop('useCustom')==true) {
                $('.bySide').css('display','none');
                $('.byCustom').css('display','block');
            } else {
                $('.bySide').css('display','block');
                $('.byCustom').css('display','none');
            }
        });

        //$modal.on('shown.bs.modal', function () {
        //    $(this).find('.modal-dialog').css({
        //        width: 'auto',
        //        height: 'auto',
        //        'max-height': '100%'
        //    });
        //});

        $modal.modal('show');

        $('.form_date').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            clearBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 2,
            minView: 2,
            forceParse: 0
        });

        $('#btnAssess').on('click', function (evt) {
            updateFitnessAssessment($('select[name="itemID"]').val(),$('#assessmentDate').val(),$('#assessment').val());
            $modal.modal('hide');
        });
    });

</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _userProfile;
    IQueryable<FitnessAssessmentItem> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<FitnessAssessmentItem>)this.Model;
        ViewBag.ModalId = "learnerFitnessItem";
        _userProfile = (UserProfile)ViewBag.Profile;
    }

</script>
