<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialog %>" title="編輯項目" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitDiagnosisAssessment","FitnessDiagnosis",new { diagnosisID = _model.DiagnosisID }) %>" method="post" autofocus>
            <fieldset>
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Item</label>
                            <div class="icon-addon">
                                <select class="form-control" name="ItemID">
                                    <%  foreach (var item in _items)
                                        { %>
                                    <option value="<%= item.ItemID %>" <%= item==_defaultItem ? "selected" : null %>><%= item.ItemName %></option>
                                    <%  } %>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6" id="assessmentTest">
                        <div class="form-group">
                            <label>Times</label>
                            <div class="input-group">
                                <span class="input-group-addon">完成</span>
                                <div class="icon-addon" id="generalAssessment">
                                    <input type="number" placeholder="" name="Assessment" class="form-control" value="<%= String.Format("{0:.}",_viewModel.Assessment) %>" />
                                </div>
                                <span class="input-group-addon"><%= _defaultItem.Unit %></span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row" id="cardioTest">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>安靜心跳率</label>
                            <div class="input-group">
                                <div class="icon-addon" id="cardioAssessment">
                                </div>
                                <span class="input-group-addon">次</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>測試當下心跳率</label>
                            <div class="input-group">
                                <div class="icon-addon">
                                    <input type="number" placeholder="" class="form-control" name="AdditionalAssessment" value="<%= String.Format("{0:.}",_viewModel.AdditionalAssessment) %>" />
                                </div>
                                <span class="input-group-addon">次</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <label id="calcCardio" class="label label-info"><i class="fa fa-info-circle"></i>&nbsp;有效訓練心跳率 = <span id="effectiveRate"></span>（220-年齡-安靜心跳率)*70%+安靜心跳率）</label>
                </div>
            </fieldset>
            <fieldset>
                <div class="form-group">
                    <label>Level <span class="text-warning calcAssessment">(系統計算結果：<span id="calcJudgement"><%= _viewModel.Judgement %></span>）</span></label> 
                    <div class="icon-addon">
                        <select class="form-control" name="Judgement">
                            <option>稍差</option>
                            <option>一般</option>
                            <option>良好</option>
                            <option>特殊</option>
                        </select>
                    </div>
                </div>
            </fieldset>
            <fieldset>
                <div class="form-group">
                    <label>Action</label>
                    <textarea class="form-control" placeholder="請輸入動作說明" rows="3" name="DiagnosisAction"><%= _viewModel.DiagnosisAction %></textarea>
                </div>
            </fieldset>
            <fieldset>
                <div class="form-group">
                    <label>Description</label>
                    <textarea class="form-control" placeholder="請輸入加強描述" rows="3" name="Description"><%= _viewModel.Description %></textarea>
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
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-edit'></i>  編輯項目</h4>",
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
                                $('#diagAssessment').html(data);
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

        $(function () {

            function checkAssessment() {
                var itemID = parseInt($('select[name="ItemID"]').val());
                switch (itemID) {
                    case 53:
                    case 54:
                    case 55:
                        $('#assessmentTest').css('display', 'block');
                        $('.calcAssessment').css('display', 'block');
                        $('#cardioTest').css('display', 'none');
                        $('#calcCardio').css('display', 'none');
                        $('input[name="Assessment"]').appendTo($('#generalAssessment'));
                        break;
                    case 57:
                        $('#assessmentTest').css('display', 'none');
                        $('.calcAssessment').css('display', 'block');
                        $('#cardioTest').css('display', 'block');
                        $('input[name="Assessment"]').appendTo($('#cardioAssessment'));
                        break;
                    default:
                        $('#assessmentTest').css('display', 'none');
                        $('.calcAssessment').css('display', 'none');
                        $('#cardioTest').css('display', 'none');
                        $('#calcCardio').css('display', 'none');
                        break;
                }
            }

            checkAssessment();

    <%  if(_viewModel.Judgement!=null)
        {   %>
            $('select[name="Judgement"]').val('<%= _viewModel.Judgement %>');
    <%  }  %>

            $('select[name="ItemID"]').on('change', function (evt) {
                checkAssessment();
            });

            $('input[name="Assessment"]').on('blur', function (evt) {
                var val = $('input[name="Assessment"]').val();
                if (val != '' && $('#cardioTest').css('display')=='none') {
                    makeJudgement();
                }
            });

            $('input[name="AdditionalAssessment"]').on('blur', function (evt) {
                if ($('input[name="Assessment"]').val() != '' && $('input[name="AdditionalAssessment"]').val() != '' && $('#cardioTest').css('display') == 'block') {
                    makeJudgement();
                }
            });

            function makeJudgement() {
                $('#<%= _dialog %> form').ajaxForm({
                    url: "<%= Url.Action("MakeJudgement","FitnessDiagnosis",new { diagnosisID = _model.DiagnosisID }) %>",
                    beforeSubmit: function () {
                        showLoading();
                    },
                    success: function (data) {
                        hideLoading();
                        if (data.result) {
                            $('#calcJudgement').text(data.message);
                            $('select[name="Judgement"]').val(data.message);
                            if ($('select[name="ItemID"]').val()=='57') {
                                $('#calcCardio').css('display', 'block');
                                $('#effectiveRate').text(data.effectiveRate);
                            }
                        } else {
                            $('#calcJudgement').text(data.message);
                            alert(data.message);
                        }
                    },
                    error: function () {
                    }
                }).submit();
            }

        });

    </script>

</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialog = "diagoDesc" + DateTime.Now.Ticks;
    BodyDiagnosis _model;
    IQueryable<FitnessAssessmentItem> _items;
    FitnessAssessmentItem _defaultItem;
    FitnessDiagnosisViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (BodyDiagnosis)this.Model;
        _viewModel = (FitnessDiagnosisViewModel)ViewBag.ViewModel;
        _items = models.GetTable<FitnessAssessmentItem>().Where(f => f.GroupID == 8);
        if (_viewModel.ItemID.HasValue)
        {
            _items = _items.Where(i => i.ItemID == _viewModel.ItemID);
            _defaultItem = _items.First();
        }
        else
        {
            _defaultItem = _items.First();
        }
    }

</script>
