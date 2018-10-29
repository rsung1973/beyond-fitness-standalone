<%@  Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<form id="assessment" action="<%= VirtualPathUtility.ToAbsolute("~/Attendance/CommitAssessment") %>" class="smart-form" method="post">
        <input type="hidden" name="coachID" value="<%= _model.LessonTime.AttendingCoach %>" />
        <div class="col-xs-12 col-sm-6 cols-md-6 cols-lg-6">
            <div class="padding-10">
                <h5 class="margin-top-0"><i class="fa fa-chart-pie"></i>著重方向</h5>
                <ul class="no-padding no-margin">

                    <fieldset>
                        <div class="input-group">
                            <span class="input-group-addon">動作學習</span>
                            <input class="form-control" id="actionLearning" name="actionLearning" value="<%: _model.LessonTime.LessonTrend.ActionLearning %>" type="text" placeholder="請輸入0-10數字" />
                            <span class="input-group-addon">分</span>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="input-group">
                            <span class="input-group-addon">姿勢矯正</span>
                            <input class="form-control" id="postureRedress" name="postureRedress" value="<%: _model.LessonTime.LessonTrend.PostureRedress %>" type="text" placeholder="請輸入0-10數字"/>
                            <span class="input-group-addon">分</span>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="input-group">
                            <span class="input-group-addon">訓練</span>
                            <input class="form-control" id="training" name="training" value="<%: _model.LessonTime.LessonTrend.Training %>" type="text" placeholder="請輸入0-10數字"/>
                            <span class="input-group-addon">分</span>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="input-group">
                            <span class="input-group-addon">狀態溝通</span>
                            <input class="form-control" id="counseling" name="counseling" value="<%: _model.LessonTime.LessonTrend.Counseling %>" type="text" placeholder="請輸入0-10數字">
                            <span class="input-group-addon">分</span>
                        </div>
                    </fieldset>
                </ul>
            </div>

        </div>
        <div class="col-xs-12 col-sm-6 cols-md-6 cols-lg-6">
            <div class="padding-10">
                <h5 class="margin-top-0"><i class="fa fa-chart-pie"></i>體適能</h5>
                <ul class="no-padding no-margin">
                    <fieldset>
                        <div class="input-group">
                            <span class="input-group-addon">柔軟度</span>
                            <input class="form-control" id="flexibility" name="flexibility" value="<%: _model.LessonTime.FitnessAssessment.Flexibility %>" type="text" placeholder="請輸入0-10數字"/>
                            <span class="input-group-addon">分</span>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="input-group">
                            <span class="input-group-addon">心肺</span>
                            <input class="form-control" id="cardiopulmonary" name="cardiopulmonary" value="<%: _model.LessonTime.FitnessAssessment.Cardiopulmonary %>" type="text" placeholder="請輸入0-10數字"/>
                            <span class="input-group-addon">分</span>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="input-group">
                            <span class="input-group-addon">肌力</span>
                            <input class="form-control" id="strength" name="strength" value="<%: _model.LessonTime.FitnessAssessment.Strength %>" type="text" placeholder="請輸入0-10數字"/>
                            <span class="input-group-addon">分</span>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="input-group">
                            <span class="input-group-addon">肌耐力</span>
                            <input class="form-control" id="endurance" name="endurance" value="<%: _model.LessonTime.FitnessAssessment.Endurance %>" type="text" placeholder="請輸入0-10數字"/>
                            <span class="input-group-addon">分</span>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="input-group">
                            <span class="input-group-addon">爆發力</span>
                            <input class="form-control" id="explosiveForce" name="explosiveForce" value="<%: _model.LessonTime.FitnessAssessment.ExplosiveForce %>" type="text" placeholder="請輸入0-10數字"/>
                            <span class="input-group-addon">分</span>
                        </div>
                    </fieldset>
                    <fieldset>
                        <div class="input-group">
                            <span class="input-group-addon">運動表現</span>
                            <input class="form-control" id="sportsPerformance" name="sportsPerformance" value="<%: _model.LessonTime.FitnessAssessment.SportsPerformance %>" type="text" placeholder="請輸入0-10數字"/>
                            <span class="input-group-addon">分</span>
                        </div>
                    </fieldset>
                </ul>
            </div>
        </div>
        <footer>
            <button type="button" name="submit" class="btn btn-primary" onclick="commitAssessment();">
                上課結束 <i class="fa fa-paper-plane" aria-hidden="true"></i>
            </button>
        </footer>
    </form>

<script>
    $(function () {
        var $formValidator = $("#assessment").validate({
            // Rules for form validation
            rules: {
                actionLearning: {
                    required: true,
                    min: 0,
                    max:10
                },
                postureRedress: {
                    required: true,
                    min: 0,
                    max: 10
                },
                training: {
                    required: true,
                    min: 0,
                    max: 10
                },
                counseling: {
                    required: true,
                    min: 0,
                    max: 10
                },
                flexibility: {
                    required: true,
                    min: 0,
                    max: 10
                },
                cardiopulmonary: {
                    required: true,
                    min: 0,
                    max: 10
                },
                strength: {
                    required: true,
                    min: 0,
                    max: 10
                },
                endurance: {
                    required: true,
                    min: 0,
                    max: 10
                },
                explosiveForce: {
                    required: true,
                    min: 0,
                    max: 10
                },
                sportsPerformance: {
                    required: true,
                    min: 0,
                    max: 10
                }
            },

            // Messages for form validation
            messages: {
                actionLearning: {
                    required: '請輸入分數0~10',
                    min: '請輸入分數0~10',
                    max: '請輸入分數0~10'
                },
                postureRedress: {
                    required: '請輸入分數0~10',
                    min: '請輸入分數0~10',
                    max: '請輸入分數0~10'
                },
                training: {
                    required: '請輸入分數0~10',
                    min: '請輸入分數0~10',
                    max: '請輸入分數0~10'
                },
                counseling: {
                    required: '請輸入分數0~10',
                    min: '請輸入分數0~10',
                    max: '請輸入分數0~10'
                },
                flexibility: {
                    required: '請輸入分數0~10',
                    min: '請輸入分數0~10',
                    max: '請輸入分數0~10'
                },
                cardiopulmonary: {
                    required: '請輸入分數0~10',
                    min: '請輸入分數0~10',
                    max: '請輸入分數0~10'
                },
                strength: {
                    required: '請輸入分數0~10',
                    min: '請輸入分數0~10',
                    max: '請輸入分數0~10'
                },
                endurance: {
                    required: '請輸入分數0~10',
                    min: '請輸入分數0~10',
                    max: '請輸入分數0~10'
                },
                explosiveForce: {
                    required: '請輸入分數0~10',
                    min: '請輸入分數0~10',
                    max: '請輸入分數0~10'
                },
                sportsPerformance: {
                    required: '請輸入分數0~10',
                    min: '請輸入分數0~10',
                    max: '請輸入分數0~10'
                }
            },

            // Ajax form submition
            //submitHandler: function (form) {

            //},

            // Do not change code below
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    });
</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    LessonTimeExpansion _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (LessonTimeExpansion)this.Model;

        if (_model.LessonTime.FitnessAssessment == null)
        {
            _model.LessonTime.FitnessAssessment = new FitnessAssessment { };
        }
        if (_model.LessonTime.LessonTrend == null)
        {
            _model.LessonTime.LessonTrend = new LessonTrend { };
        }

    }





</script>
