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
<div class="btn-group dropup" data-toggle="dropdown">
    <button class="btn bg-color-blueLight" data-toggle="dropdown">請選擇功能</button>
    <button class="btn bg-color-blueLight dropdown-toggle" data-toggle="dropdown"><span class="caret"></span></button>
    <ul class="dropdown-menu">
<%  
    LessonTimeExpansion item = _model;
    %>
        <li><a onclick='makeLessonPlan(<%= JsonConvert.SerializeObject(new
                                {
                                    classDate = item.ClassDate.ToString("yyyy-MM-dd"),
                                    hour = item.Hour,
                                    registerID = item.RegisterID,
                                    lessonID = item.LessonID
                                }) %>);'><i class="fa fa-fw fa fa-edit" aria-hidden="true"></i>編輯上課內容</a></li>
        <li class="divider"></li>
<%  if (_model.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI)
    {   %>
        <li><a onclick="bookingSelfTraining(<%= _model.LessonID %>);"><i class="fa fa-fw fa fa-calendar-alt-check-o" aria-hidden="true"></i>修改上課時間</a></li>
<%  }
    else
    { %>
        <%--<li><a onclick="showLoading(true,function(){ window.location.href = '<%= VirtualPathUtility.ToAbsolute("~/Lessons/RebookingByCoach/") + _model.LessonID %>';});"><i class="fa fa-fw fa fa-calendar-alt-check-o" aria-hidden="true"></i>修改上課時間</a></li>--%>
<%  }
    if (item.LessonTime.LessonAttendance == null)
    { %>
        <li><a onclick="revokeBooking(<%= item.LessonID %>);"><i class="fa fa-fw far fa-trash-alt" aria-hidden="true"></i>取消上課</a></li>
<%  }
    if(item.LessonTime.TrainingPlan.Count>0)
    {  %>
        <li class="divider"></li>
        <li><a onclick='previewLesson(<%= JsonConvert.SerializeObject(new
                    {
                        classDate = item.ClassDate.ToString("yyyy-MM-dd"),
                        hour = item.Hour,
                        registerID = item.RegisterID,
                        lessonID = item.LessonID
                    }) %>);'><i class="fa fa-fw fa fa-eye" aria-hidden="true"></i>檢視上課內容</a></li>
<%  } %>
    </ul>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    LessonTimeExpansion _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (LessonTimeExpansion)this.Model;
    }

</script>
