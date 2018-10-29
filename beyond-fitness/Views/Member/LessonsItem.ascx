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

<% Html.RenderPartial("~/Views/Member/LearnerClassLevel.ascx", _model);  %>
<div class="form-group has-feedback">
    <% Html.RenderInput("本次購買上課堂數：", "lessons", "lessons", "請輸入數字", _modelState, defaultValue: _model.Lessons.ToString()); %>
</div>


<script>

    $(function () {

        $.validator.addMethod("checkLessons", function (value, element, param) {
            var classLevel = parseInt($('select[name="classLevel"]').val());
            var lessons = parseInt($(element).val());

            if (lessons <= 0)
                return false;

            <%--            switch (classLevel) {
                case 1:
                case 2:
                    return lessons > 0;
                case 3:
                case 4:
                    return (lessons % 25) == 0;
                case 5:
                case 6:
                    return (lessons % 50) == 0;
                case 7:
                case 8:
                    return (lessons % 75) == 0;
            }
            return false;   --%>
            return true;
        }, "上課堂數錯誤!!");

        $('#lessons').rules('add', {
            'required': true,
            'checkLessons': true
        });
    });


</script>

<script runat="server">

    ModelStateDictionary _modelState;
    LessonViewModel _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = this.Model as LessonViewModel;
    }
</script>
