<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="recentLessons" title="檢視上課記錄" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white">
        <div class="row">
            <article class="col-sm-12 col-md-12 col-lg-12">
                <div class="jarviswidget" id="lessonContent" data-widget-togglebutton="false" data-widget-editbutton="false" data-widget-fullscreenbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false">
                    <%  Html.RenderPartial("~/Views/ClassFacet/Module/LessonContentView.ascx", _model); %>
                </div>
            </article>
        </div>
        <!-- end row -->
    </div>
    <div class="modal-footer">
        <%--<button type="button" class="btn btn-primary" id="btnModalClone">
            複製課表 <i class="fa fa-files-o" aria-hidden="true"></i>
        </button>--%>
    </div>

    <script>
        $('#recentLessons').dialog({
            //autoOpen : false,
            resizable: true,
            modal: true,
            width: "auto",
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-edit'></i>  目前狀態：<%= _item.CurrentLessonStatus() %></h4>",
            close: function (event, ui) {
                $('#recentLessons').remove();
            }
        });

        $(function () {

            $('#btnModalClone').on('click', function (evt) {
                if ($global.cloneLesson) {
                    $global.cloneLesson(<%= _item.LessonID %>);
                    $('#recentLessons').dialog('close');
                }
            });
        });
    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    RegisterLesson _model;
    LessonTime _item;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (RegisterLesson)this.Model;
        _item = (LessonTime)ViewBag.LessonTime;
    }

</script>
