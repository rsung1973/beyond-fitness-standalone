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
                    <%  if (_model.FitnessAssessmentItem.UseSingleSide == true)
                        { %>
                    <div class="col-md-6 bySide">
                        <div class="form-group">
                            <div class="icon-addon">
                                <select class="form-control" name="bySingleSide">
                                    <option value="False">雙邊</option>
                                    <option value="True">單邊</option>
                                </select>
                                <script>
                                    $(function(){
                                        $('select[name="bySingleSide"]').val('<%= _model.BySingleSide == true %>');
                                    });
                                </script>
                            </div>
                        </div>
                    </div>
                    <%  }
                        if (_model.FitnessAssessmentItem.UseCustom == true)
                        { %>
                    <div class="col-md-6 byCustom">
                        <div class="form-group">
                            <div class="input-group">
                                <div class="icon-addon">
                                    <input placeholder="請輸入20個中文字" class="form-control" name="byCustom" value="<%= _model.ByCustom %>" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <%  } %>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <div class="note">
                            <strong>Note:</strong> 請選擇一種輸入方式 : 輸入訓練總量或輸入訓練重量與次數
                        </div>
                        <div class="col-md-3">
                            <label class="radio">
                                <input type="radio" name="calc" <%= _model.TotalAssessment.HasValue ? "checked" : null %> value="total" />
                                <i></i>輸入訓練總量
                            </label>
                        </div>
                        <div class="col-md-9">
                            <div class="input-group">
                                <div class="icon-addon">
                                    <input type="number" step="0.1" placeholder="請輸入純數字" class="form-control" name="totalAssessment" value="<%= String.Format("{0:.#}",_model.TotalAssessment) %>" <%= _model.TotalAssessment.HasValue ? "required" : null %> />
                                </div>
                                <span class="input-group-addon"><%= _model.FitnessAssessmentItem.Unit %></span>
                            </div>
                            <script>
                                $('input[name="totalAssessment"]').focus(function(evt){
                                    $('input[name="calc"][value="total"]').prop('checked',true);
                                    $('input[name="calc"][value="total"]').trigger('click');
                                });
                            </script>
                        </div>
                    </div>
                </div>
                <%  if (_model.FitnessAssessmentItem.Unit != "次" && _model.FitnessAssessmentItem.Unit != "組")
                    { %>
                <div class="row">
                    <div class="col-md-12">
                        <div class="col-sm-12 col-md-3">
                            <label class="radio">
                                <input type="radio" name="calc" <%= !_model.TotalAssessment.HasValue ? "checked" : null %> value="times" />
                                <i></i>輸入訓練重量與次數
                            </label>
                        </div>
                        <div class="col-sm-6 col-md-5">
                            <div class="input-group">
                                <div class="icon-addon">
                                    <input type="number" step="0.1" placeholder="請輸入純數字" class="form-control" name="singleAssessment" value="<%= String.Format("{0:.#}",_model.SingleAssessment) %>" <%= !_model.TotalAssessment.HasValue ? "required" : null %> />
                                </div>
                                <span class="input-group-addon">KG</span>
                            </div>
                        </div>
                        <div class="col-sm-6 col-md-4">
                            <div class="input-group">
                                <div class="icon-addon">
                                    <input type="number" placeholder="請輸入純數字" class="form-control" name="byTimes" value="<%= _model.ByTimes %>" <%= !_model.TotalAssessment.HasValue ? "required" : null %> />
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
                <%  } %>
            </div>
        </form>
    </div>
    <script>
    
        $(function () {

            $('#<%= _dialogID %>').dialog({
                //autoOpen: false,
                resizable: true,
                modal: true,
                width: "600",
                height: "auto",
                title: "<h4 class='modal-title'><i class='fa fa-fw fa-edit'></i>  修改評量指數</h4>",
                buttons: [{
                    html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                    "class": "btn btn-primary",
                    click: function () {
                        update<%= _dialogID %>();
                        $(this).dialog("close");
                    }
                }],
                close: function (event, ui) {
                    $('#<%= _dialogID %>').remove();
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

            function update<%= _dialogID %>() {

                var $form = $('#<%= _dialogID %> form');
                if(!validateForm($form[0]))
                    return false;

                commitAssessmentGroupItem({
                    'assessmentID': <%= _model.AssessmentID %>,
                    'itemID':<%= _model.ItemID %>,
                    'calc': $('input[name="calc"]:checked').val(),
                    'totalAssessment': $('input[name="totalAssessment"]').val(),
                    'singleAssessment': $('input[name="singleAssessment"]').val(),
                    'byTimes': $('input[name="byTimes"]').val(),
                    'bySingleSide': $('select[name="bySingleSide"]').val(),
                    'byCustom': $('input[name="byCustom"]').val()},<%= _model.FitnessAssessmentItem.FitnessAssessmentGroup.MajorID %>);
            }

        });

    </script>
</div>


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
