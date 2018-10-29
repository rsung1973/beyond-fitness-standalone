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

<div id="<%= _dialogID %>" title="編輯評量指數" class="bg-color-darken">
    <div class="panel panel-default bg-color-darken">
        <form action="<%= Url.Action("UpdateAssessmentReport","Activity",new { assessmentID = _model.AssessmentID }) %>" method="post">
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="row">
                    <div class="col-sm-6">
                        <div class="form-group">
                            <div class="icon-addon">
                                <select class="form-control" name="trendItem">
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6">
                        <div class="input-group">
                            <div class="icon-addon">
                                <input type="number" name="trendAssessment" placeholder="請輸入純數字" class="form-control" required="required" />
                            </div>
                            <span class="input-group-addon">分鐘</span>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <div class="note">
                            <strong>Note:</strong> 請輸入著重方向之總分鐘數, 例如: 全部的肌力訓練在本次課堂中佔有20分鐘, 則輸入20
                        </div>
                    </div>
                </div>
                <hr class="simple" />
                <div class="row subItem">
                    <div class="col-md-6">
                        <div class="form-group">
                            <div class="icon-addon">
                                <select class="form-control" name="itemID">
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 bySide" style="display: none">
                        <div class="form-group">
                            <div class="icon-addon">
                                <select class="form-control" name="bySingleSide">
                                    <option value="False">雙邊</option>
                                    <option value="True">單邊</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 byCustom" style="display: none">
                        <div class="form-group">
                            <div class="input-group">
                                <div class="icon-addon">
                                    <input placeholder="請輸入20個中文字" class="form-control" name="byCustom">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row subItem">
                    <div class="col-md-12">
                        <div class="note">
                            <strong>Note:</strong> 請選擇一種輸入方式 : 輸入訓練總量或輸入訓練重量與次數
                        </div>
                        <div class="col-md-3">
                            <label class="radio">
                                <input type="radio" name="calc" checked="checked" value="total" />
                                <i></i>輸入訓練總量
                            </label>
                        </div>
                        <div class="col-md-9">
                            <div class="input-group">
                                <div class="icon-addon">
                                    <input type="number" step="0.1" placeholder="請輸入純數字" class="form-control" name="totalAssessment" required />
                                </div>
                                <span class="input-group-addon" id="itemUnit">KG</span>
                            </div>
                        </div>
                        <script>
                                $('input[name="totalAssessment"]').focus(function(evt){
                                    $('input[name="calc"][value="total"]').prop('checked',true);
                                    $('input[name="calc"][value="total"]').trigger('click');
                                });
                        </script>
                    </div>
                </div>
                <div class="row subItem" id="calcSingle">
                    <div class="col-md-12">
                        <div class="col-sm-12 col-md-3">
                            <label class="radio">
                                <input type="radio" name="calc" value="times">
                                <i></i>輸入訓練重量與次數
                            </label>
                        </div>
                        <div class="col-sm-6 col-md-5">
                            <div class="input-group">
                                <div class="icon-addon">
                                    <input type="number" step="0.1" placeholder="請輸入純數字" class="form-control" name="singleAssessment" />
                                </div>
                                <span class="input-group-addon">KG</span>
                            </div>
                        </div>
                        <div class="col-sm-6 col-md-4">
                            <div class="input-group">
                                <div class="icon-addon">
                                    <input type="number" placeholder="請輸入純數字" class="form-control" name="byTimes" />
                                </div>
                                <span class="input-group-addon">次</span>
                            </div>
                        </div>

                        <script>
                            $('input[name="byTimes"],input[name="singleAssessment"]').focus(function(evt){
                                $('input[name="calc"][value="times"]').prop('checked',true);
                                $('input[name="calc"][value="times"]').trigger('click');
                            });
                        </script>
                    </div>
                </div>
            </div>
        </form>
    </div>
   </div>
        
<script>

    var fitnessItem = <%= JsonConvert.SerializeObject(models.GetTable<FitnessAssessmentItem>().Where(g=>g.GroupID==3)
        .Select(g=>new {
            g.ItemID,
            g.ItemName,
            TotalAssessment = g.LessonFitnessAssessmentReport.Where(r=>r.AssessmentID == _model.AssessmentID).Select(r=>r.TotalAssessment).FirstOrDefault(),
            items = g.MinorItemFitnessAssessmentGroup.FirstOrDefault().FitnessAssessmentItem
            .Select(f=>new {
                f.ItemID,
                f.ItemName,
                f.Unit,
                f.UseCustom,
                f.UseSingleSide
            }).ToArray()
        }).ToArray()) %>;
    
    $(function () {
        var $modal = $('#<%= ViewBag.ModalId ?? "theModal" %>');
        $modal.on('hidden.bs.modal', function (evt) {
            $modal.remove();
            $('body').scrollTop(screen.height);
        });

        fitnessItem.forEach(function(item,index) {
            $('<option>').prop('value',item.ItemID)
                .text(item.ItemName).appendTo($('select[name="trendItem"]'));
            if(index==0) {
                $('input[name="trendAssessment"]').val(item.TotalAssessment);
            }
        });

        $('select[name="trendItem"]').val(18);
        buildSubItem(18);
        $('select[name="trendItem"]').on('change',function(evt) {
            buildSubItem($(this).val());
        });

        $('select[name="itemID"]').on('change',function(evt) {
            var unit = $(this).find('option:selected').prop('unit');
            $('#itemUnit').text(unit);
            if(unit=='次' || unit=='組') {
                $('#calcSingle').css('display','none');
            } else {
                $('#calcSingle').css('display','block');
            }
            if($('select[name="itemID"]').find('option:selected').prop('useCustom')==true) {
                $('.byCustom').css('display','block');
            } else {
                $('.byCustom').css('display','none');
            }
            if($('select[name="itemID"]').find('option:selected').prop('useSingleSide')==true) {
                $('.bySide').css('display','block');
            } else {
                $('.bySide').css('display','none');
            }
        });

        $('input[name="calc"]').on('click',function(evt) {
            if($('input[name="calc"]:checked').val()=='total') {
                $('input[name="totalAssessment"]').prop('required',true);
                $('input[name="singleAssessment"]').prop('required',false);
                $('input[name="byTimes"]').prop('required',false);
            } else {
                $('input[name="totalAssessment"]').prop('required',false);
                $('input[name="singleAssessment"]').prop('required',true);
                $('input[name="byTimes"]').prop('required',true);
            }
        });

        function buildSubItem(itemID) {
            var hasItem = false;
            var unit;
            var useCustom;
            var useSingleSide;
            fitnessItem.forEach(function(item,index) {
                if(item.ItemID==itemID) {
                    $('input[name="trendAssessment"]').val(item.TotalAssessment);
                    if(item.items.length>0) {
                        hasItem = true;
                        $('select[name="itemID"]').empty();
                        item.items.forEach(function(item,itemIdx) {
                            $('<option>').prop('value',item.ItemID)
                                .prop('unit',item.Unit)
                                .prop('useCustom',item.UseCustom)
                                .prop('useSingleSide',item.UseSingleSide)
                                .text(item.ItemName).appendTo($('select[name="itemID"]'));
                            if(itemIdx==0) {
                                unit = item.Unit;
                                $('#itemUnit').text(unit);
                                useCustom = item.UseCustom;
                                useSingleSide = item.UseSingleSide;
                            }
                        });
                        $('.subItem').css('display','block');
                        if(unit=='次' || unit=='組') {
                            $('#calcSingle').css('display','none');
                        } else {
                            $('#calcSingle').css('display','block');
                        }
                        if(useCustom==true) {
                            $('.byCustom').css('display','block');
                        } else {
                            $('.byCustom').css('display','none');
                        }
                        if(useSingleSide==true) {
                            $('.bySide').css('display','block');
                        } else {
                            $('.bySide').css('display','none');
                        }
                    }
                }
            });
            if(!hasItem) {
                $('.subItem').css('display','none');
            }
        }

        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "600",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-edit'></i>  編輯評量指數</h4>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {
                    if(update<%= _dialogID %>()) {
                        $(this).dialog("close");
                    }
                }
            }],
            close: function (event, ui) {
                $('#<%= _dialogID %>').remove();
            }
        });

        function update<%= _dialogID %>(callback) {

            var $form = $('#<%= _dialogID %> form');
            if(!validateForm($form[0]))
                return false;

            var item = {
                'assessmentID':<%= _model.AssessmentID %>,
                'itemID':$('select[name="trendItem"]').val()
            };
            $form.ajaxSubmit({
                success: function (data) {
                    if(data.result) {
                        showLoading();
                        drawTrendPie(<%= _model.AssessmentID %>);
                        drawStrengthPie(<%= _model.AssessmentID %>);
                        $('#trendList'+<%= _model.AssessmentID %>).load('<%= Url.Action("FitnessAssessmentTrendList","Activity") %>',  { 'assessmentID' : <%= _model.AssessmentID %>}, function () {
                            hideLoading();
                        });
                        //drawGroupPie(item);
                        $('#_' + <%= _model.AssessmentID %> + "_" + item.itemID).load('<%= Url.Action("FitnessAssessmentGroup","Activity") %>', item, function () {
                            hideLoading();
                        });
                        smartAlert('資料已儲存!!');
                    }
                }
            });

            return true;
        }
    });

</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonFitnessAssessment _model;
    String _dialogID = "editAssessment" + DateTime.Now.Ticks;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFitnessAssessment)this.Model;
    }

</script>
