<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%  
    var totalLessons = _contractItems.Sum(c => c.Lessons) ?? 0;
    var completeLessons = _contractItems
        .Join(models.GetTable<RegisterLessonContract>(),
            c => c.ContractID, r => r.ContractID, (c, r) => r)
        .Join(models.GetTable<RegisterLesson>(), c => c.RegisterID, r => r.RegisterID, (c, r) => r)
        .Join(models.GetTable<LessonTime>(), r => r.RegisterID, l => l.RegisterID, (r, l) => l)
        .Where(l => l.LessonAttendance != null).Count();

    var ratio = completeLessons * 100 / Math.Max(totalLessons, 1);
%>
<div class="body">
    <div class="row">
        <div class="col-12 text-center">
            <input type="text" class="knob knobRate3" data-linecap="round" data-width="90" data-height="90" data-thickness="0.25" data-anglearc="250" data-angleoffset="-125" data-fgcolor="#78b83e" readonly id="<%= _knobID %>"/>
            <script>
                $(function () {
                    drawKnob($("#<%= _knobID %>"),<%= ratio %>, 3800);
                });
            </script>
            <h6 class="m-t-20">合約上課比例</h6>
         </div>
    </div>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<CourseContract> _model;
    IQueryable<CourseContract> _contractItems;
    String _knobID = $"installmentRate{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = _contractItems = (IQueryable<CourseContract>)this.Model;
    }


</script>
