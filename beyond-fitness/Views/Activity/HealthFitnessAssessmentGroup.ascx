<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<form action="<%= Url.Action("UpdateLessonFitnessAssessment","Activity",new { assessmentID = _model.AssessmentID,groupID = 2,forHealth = true }) %>" id="<%= _formID %>" class="form-horizontal" method="post">
<%--    <fieldset>
        <div class="form-group">
            <div class="col col-sm-6 col-md-6">
                <div class="input-group">
                    <span class="input-group-addon">疲勞指數</span>
                    <% var item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 10).FirstOrDefault(); %>
                    <input class="form-control" type="number" placeholder="請輸入1-10" name="_10" value="<%= item!=null ? item.TotalAssessment : null %>"/>
                    <span class="input-group-addon">指數</span>
                </div>
            </div>
            <div class="col col-sm-6 col-md-6">
                <div class="input-group">
                    <span class="input-group-addon">睡眠時間</span>
                    <% item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 12).FirstOrDefault(); %>
                    <input class="form-control" type="number" placeholder="請輸入純數字" name="_12" value="<%= item!=null ? item.TotalAssessment : null %>" />
                    <span class="input-group-addon">小時</span>
                </div>
            </div>
        </div>
    </fieldset>--%>
    <fieldset>
        <div class="form-group">
            <div class="col col-sm-6 col-md-4">
                <div class="input-group">
                    <span class="input-group-addon">腰</span>
                    <% var item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 13).FirstOrDefault(); %>
                    <input class="form-control" type="number" placeholder="請輸入純數字" name="_13" value="<%= item!=null ? item.TotalAssessment : null %>" />
                    <span class="input-group-addon">CM</span>
                </div>
            </div>
            <div class="col col-sm-6 col-md-4">
                <div class="input-group">
                    <span class="input-group-addon">腿</span>
                    <% item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 14).FirstOrDefault(); %>
                    <input class="form-control" type="number" placeholder="請輸入純數字" name="_14" value="<%= item!=null ? item.TotalAssessment : null %>" />
                    <span class="input-group-addon">CM</span>
                </div>
            </div>
            <div class="col col-sm-6 col-md-4">
                <div class="input-group">
                    <span class="input-group-addon">臀</span>
                    <% item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 15).FirstOrDefault(); %>
                    <input class="form-control" type="number" placeholder="請輸入純數字" name="_15" value="<%= item!=null ? item.TotalAssessment : null %>" />
                    <span class="input-group-addon">CM</span>
                </div>
            </div>
        </div>
    </fieldset>
    <fieldset>
        <div class="form-group">
            <div class="col col-sm-6 col-md-4">
                <div class="input-group">
                    <span class="input-group-addon">體重</span>
                    <% item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 49).FirstOrDefault(); %>
                    <input class="form-control" type="number" placeholder="請輸入純數字" name="_49" value="<%= item!=null ? item.TotalAssessment : null %>" />
                    <span class="input-group-addon">KG</span>
                </div>
            </div>
            <div class="col col-sm-6 col-md-4">
                <div class="input-group">
                    <span class="input-group-addon">皮脂厚度</span>
                    <% item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 50).FirstOrDefault(); %>
                    <input class="form-control" type="number" placeholder="請輸入純數字" name="_50" value="<%= item!=null ? item.TotalAssessment : null %>" />
                    <span class="input-group-addon">MM</span>
                </div>
            </div>
            <div class="col col-sm-6 col-md-4">
                <div class="input-group">
                    <span class="input-group-addon">體脂率</span>
                    <% item = _model.LessonFitnessAssessmentReport.Where(r => r.ItemID == 51).FirstOrDefault(); %>
                    <input class="form-control" type="number" placeholder="請輸入純數字" name="_51" value="<%= item!=null ? item.TotalAssessment : null %>" />
                    <span class="input-group-addon">%</span>
                </div>
            </div>
        </div>
    </fieldset>
    <%  if (ViewBag.ShowOnly != true)
        { %>
    <div class="form-actions">
        <div class="row">
            <div class="col-md-12">
                <button class="btn btn-primary" type="button" onclick="updateHealthAssessment();">
                    <i class="fa fa fa-reply"></i>
                    更新
                </button>
            </div>
        </div>
    </div>
    <%  }
        else
        { %>
            <script>
                $('#<%= _formID %> input').prop('disabled', true);
            </script>
    <%  } %>
</form>
<div class="<%= _formID %>">
    <%  Html.RenderPartial("~/Views/Activity/HealthIndex.ascx", _model.UserProfile); %>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonFitnessAssessment _model;
    String _formID;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonFitnessAssessment)this.Model;
        _formID = "health_" + _model.AssessmentID;
    }

</script>
