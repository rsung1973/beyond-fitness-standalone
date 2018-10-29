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

<%  if (_profile != null)
    { %>
<div class="tab-content">
    <div class='tab-pane active'>
        <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
            <% Html.RenderPartial("~/Views/Lessons/LessonLearnerAssessment.ascx", _groups.First()); %>
        </div>
    </div>
</div>
<%  }
    else
    { %>
<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
        <ul class="nav nav-tabs">
            <%  int idx = 0;
                foreach (var item in _groups)
                {
                    idx++; %>
                    <li class='<%= idx == 1 ? "active" : null %>'>
                        <a href="#<%= _tabPrefix + idx %>" data-toggle="tab">
                            <span class="<%= idx == 1 ? "badge bg-color-blue txt-color-white" : "badge bg-color-blueDark txt-color-white" %>">
                                <i class="<%= item.UserProfile.UserProfileExtension.Gender == "F" ? "fa fa-female" : "fa fa-male" %>"></i></span><%= item.UserProfile.FullName() %></a>
                    </li>
            <%      
                } %>
        </ul>
        <div class="tab-content">
            <%  idx = 0;
                foreach (var item in _groups)
                {
                    idx++;%>
                    <div class='<%= idx == 1 ? "tab-pane active" : "tab-pane" %>' id='<%= _tabPrefix + idx %>'>
                        <% Html.RenderPartial("~/Views/Lessons/LessonLearnerAssessment.ascx", item); %>
                    </div>
            <%  } %>
        </div>
</div>
<%  } %>

<script>

    function updateBasicAssessment() {
        var event = event || window.event;
        var hasValue = false;
        var $form = $(event.target).closest('form');
        $form.find('input').each(function (idx) {
            if ($(this).val() != '') {
                hasValue = true;
            }
        });
        if(hasValue) {
            $form.ajaxSubmit({
                    success: function (data) {
                        $('.'+$form.prop('id')).html(data);
                        smartAlert("資料已儲存!!");
                    }
                });
        } else {
            smartAlert("請輸入至少一個項目!!");
        }
    }

    function editAssessmentItem(assessmentID) {
        showLoading();
        $.post('<%= Url.Action("EditAssessmentItem","Activity") %>', { 'assessmentID': assessmentID }, function (data) {
            hideLoading();
            if (data) {
                $(data).appendTo($('#content'));
            }
        });
    }

    function editAssessmentTrendItem(assessmentID,itemID) {
        showLoading();
        $.post('<%= Url.Action("EditAssessmentTrendItem","Activity") %>', { 'assessmentID': assessmentID,'itemID':itemID }, function (data) {
            hideLoading();
            if (data) {
                $(data).appendTo($('#content'));
            }
        });
    }

    function commitAssessmentTrendItem(item) {
        showLoading();
        $.post('<%= Url.Action("CommitAssessmentTrendItem","Activity") %>', item, function (data) {
            hideLoading();
            if (data.result) {
                smartAlert("資料已儲存!!", function () {
                    showLoading();
                    drawTrendPie(item.assessmentID);
                    $('#trendList'+item.assessmentID).load('<%= Url.Action("FitnessAssessmentTrendList","Activity") %>', item, function () {
                        hideLoading();
                    });
                });
            }
        });
    }

    function editAssessmentGroupItem(assessmentID,itemID) {
        showLoading();
        $.post('<%= Url.Action("EditAssessmentGroupItem","Activity") %>', { 'assessmentID': assessmentID,'itemID':itemID }, function (data) {
            hideLoading();
            if (data) {
                $(data).appendTo($('#content'));
            }
        });
    }

    function commitAssessmentGroupItem(item,majorID) {
        showLoading();
        $.post('<%= Url.Action("CommitAssessmentTrendItem","Activity") %>', item, function (data) {
            hideLoading();
            if (data.result) {
                smartAlert("資料已儲存!!", function () {
                    showLoading();
                    drawGroupPie(item);
                    drawStrengthPie(item.assessmentID);
                    $('#_' + item.assessmentID + "_" + majorID).load('<%= Url.Action("FitnessAssessmentGroup","Activity") %>', { 'assessmentID' : item.assessmentID,'itemID':majorID }, function () {
                        hideLoading();
                    });
                });
            }
        });
    }

    function deleteAssessmentTrendItem(assessmentID, itemID) {
        var event = event || window.event;
        confirmIt({ title: '刪除評量指數', message: '確定刪除此評量指數項目?' }, function (evt) {
            showLoading();
            var item = { 'assessmentID': assessmentID, 'itemID': itemID };
            $.post('<%= Url.Action("DeleteFitnessAssessmentReport","Activity") %>', item, function (data) {
                hideLoading();
                if (data.result) {
                    //smartAlert("資料已刪除!!");
                    drawTrendPie(assessmentID);
                    drawStrengthPie(assessmentID);
                    $('#trendList' + assessmentID).load('<%= Url.Action("FitnessAssessmentTrendList","Activity") %>', { 'assessmentID': assessmentID }, function (data) {
                        //hideLoading();
                    });
                    $('#_' + assessmentID + "_" + itemID).empty();
                }
            });
        });
    }

    function deleteAssessmentItem(assessmentID, itemID,majorID) {
        var event = event || window.event;
        confirmIt({ title: '刪除評量指數', message: '確定刪除此評量指數項目?' }, function (evt) {
            showLoading();
            $.post('<%= Url.Action("DeleteFitnessAssessmentReport","Activity") %>', { 'assessmentID': assessmentID, 'itemID': itemID }, function (data) {
                hideLoading();
                if (data.result) {

                    //smartAlert("資料已刪除!!");
                    $('#_' + assessmentID + "_" + majorID).load('<%= Url.Action("FitnessAssessmentGroup","Activity") %>', { 'assessmentID' : assessmentID,'itemID':majorID }, function (data) {
                    });
                }
            });
        });
    }


</script>


<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    LessonTime _model;
    List<LessonFitnessAssessment> _groups;
    String _tabPrefix = "tab-r";
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (LessonTime)this.Model;
        _profile = (UserProfile)ViewBag.Profile;
        if (_profile != null)
        {
            _groups = _model.LessonFitnessAssessment.Where(f => f.UID == _profile.UID).ToList();
        }
        else
        {
            _groups = _model.LessonFitnessAssessment.ToList();
        }
    }

</script>
