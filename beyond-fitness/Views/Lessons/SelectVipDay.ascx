<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>


<div id="selectVip" style="position: absolute;left:0px;top:0px  width: 250px; height: 200px;">
    <%  foreach (var item in _items)
        {
            this.Writer.WriteLine(Html.ActionLink(item.ClassTime.Value.ToString("HH:mm"), "VipDay", "Lessons",new { id = item.LessonID }, new {@class="btn-system btn-medium" })); %>
            <br />
    <%  } %>
</div>
<script>
    $(function () {
        $('#selectDay').on('click', function (evt) {
            $(this).remove();
        });
        //$('#selectVip').on('hidden.bs.modal', function (evt) {
        //    $('#selectVip').remove();
        //}).on('click', function (evt) {
        //    $('#selectVip').remove();
        //}).modal('show');
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonTime> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _items = (IQueryable<LessonTime>)this.Model;
    }

</script>
