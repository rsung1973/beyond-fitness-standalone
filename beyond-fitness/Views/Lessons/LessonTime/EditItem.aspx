<%@ Page Title="" Language="C#" MasterPageFile="~/template/MainPage.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="System.Web.Mvc.ViewPage" %>

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

<asp:Content ID="ribbonContent" ContentPlaceHolderID="ribbonContent" runat="server">
    <div id="ribbon">
        <span class="ribbon-button-alignment">
            <span id="refresh" class="btn btn-ribbon">
                <i class="fa fa-edit"></i>
            </span>
        </span>
        <!-- breadcrumb -->
        <ol class="breadcrumb">
            <li>課程管理></li>
            <li>編輯上課內容</li>
        </ol>
        <!-- end breadcrumb -->
        <!-- You can also add more buttons to the
            ribbon for further usability

            Example below:

            <span class="ribbon-button-alignment pull-right">
            <span id="search" class="btn btn-ribbon hidden-xs" data-title="search"><i class="fa-grid"></i> Change Grid</span>
            <span id="add" class="btn btn-ribbon hidden-xs" data-title="add"><i class="fa-plus"></i> Add</span>
            <span id="search" class="btn btn-ribbon" data-title="search"><i class="fa-search"></i> <span class="hidden-mobile">Search</span></span>
            </span> -->
    </div>
</asp:Content>
<asp:Content ID="pageTitle" ContentPlaceHolderID="pageTitle" runat="server">
    <h1 class="page-title txt-color-blueDark">
        <!-- PAGE HEADER -->
        <i class="fa-fw fa fa-edit"></i>編輯上課內容
    </h1>
</asp:Content>
<asp:Content ID="mainContent" ContentPlaceHolderID="mainContent" runat="server">

    <div class="row">
        <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
            <!-- Widget ID (each widget will need unique ID)-->
            <div class="jarviswidget" data-widget-togglebutton="false" data-widget-editbutton="false" data-widget-fullscreenbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false">
                <header>
                    <ul class="nav nav-tabs pull-right">
                        <%  var learnerLesson = _model.LessonTime.GroupingLesson.RegisterLesson;
                            var prefix = "reg" + DateTime.Now.Ticks + "_";
                            var idx = 0;
                            foreach (var item in learnerLesson)
                            { %>
                                <li>
                                    <a data-toggle="tab" class="userTab" href="#<%= prefix + item.RegisterID %>" data-role="<%= idx++ %>" ><span class="badge bg-color-blue txt-color-white"><i class="<%= item.UserProfile.UserProfileExtension.Gender == "F" ? "fa fa-female" : "fa fa-male" %>"></i><%= item.UserProfile.FullName() %></span></a>
                                </li>
                        <%  } %>
                    </ul>
                    <script>
                        $(function () {
                            $('a[data-toggle="tab"].userTab').on('shown.bs.tab', function (evt) {
                                var $target = $($('a[data-toggle="tab"].editLessonTab').eq($(this).attr('data-role')));
                                $('#editLesson').appendTo($($target.attr('href')));
                            });
                        });
                    </script>

                </header>
                <div class="no-padding">
                    <div class="widget-body no-padding">
                        <!-- content -->
                        <div class="tab-content padding-10">
                            <%  idx = 0;
                                ViewBag.LessonTime = _model.LessonTime;
                                foreach (var item in learnerLesson)
                                { %>
                                    <div class="tab-pane fade" id="<%= prefix + item.RegisterID %>">
                                        <%  ViewBag.HasContent = idx++ > 0;
                                            Html.RenderPartial("~/Views/Lessons/LearnerLessonPlan.ascx",item); %>
                                        <% Html.RenderPartial("~/Views/Lessons/LessonTime/EditContent.ascx", item); %>
                                    </div>
                            <%  } %>
                        </div>
                    </div>
                </div>
                <script>
                    $(function(){
                        $('a[href="#<%= prefix + _model.RegisterID %>"]').closest('li').addClass('active');
                        $('#<%= prefix + _model.RegisterID %>').addClass('active in');
                    });
                </script>
            </div>
        </article>
    </div>
    <%  Html.RenderPartial("~/Views/Shared/ConfirmationDialog.ascx"); %>
    <script>

        $(function(){
            $global.cloneLesson = function(sourceID) {
                showLoading();
                $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/CloneTrainingPlan") %>',{'sourceID': sourceID,'lessonID':<%= _model.LessonID %>},function(data){
                    hideLoading();
                    if(data.result) {
                        smartAlert("資料已複製!!", function (message) {
                            makeLessonPlan(<%= JsonConvert.SerializeObject(new
                                {
                                    classDate = _model.ClassDate.ToString("yyyy-MM-dd"),
                                    hour = _model.Hour,
                                    registerID = _model.RegisterID,
                                    lessonID = _model.LessonID
                                }) %>);
                        });
                    } else {
                        smartAlert(data.message);
                    }
                });
            };
        });

        function cloneLesson(lessonID) {
            $('#addItem').remove();
            $modal = $('<div class="modal fade" id="addItem" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" />');
            showLoading();
            $modal.appendTo($('#content'))
                .load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/QueryLessonTime") %>', 
                    {
                        'lessonID':lessonID,
                        <%--'coachID':<%= _model.LessonTime.AttendingCoach %>,--%>
                        'userName':'<%= _model.LessonTime.RegisterLesson.UserProfile.FullName() %>',
                        'classDate': '<%= _model.ClassDate.ToString("yyyy-MM-dd") %>',
                        'hour': <%= _model.Hour %>,
                        'registerID': <%= _model.RegisterID %>
                        } , function () {
                            hideLoading();
                            $modal.on('hidden.bs.modal', function (evt) {
                                $('body').scrollTop(screen.height);
                            });
                            $modal.modal('show');
                        });
        }

        function commitCloneLesson() {
            if($('#addItem form input:radio').is(':checked')) {
                var hasItem = <%= _model.LessonTime.TrainingPlan.Sum(p=>p.TrainingExecution.TrainingItem.Count)>0 ? "true" : "false" %>;
                        if(hasItem) {
                            confirmIt({ title: '複製課表', message: '確定複製課表項目取代現有項目?' }, function (evt) {
                                doCloneLesson();
                            });
                        } else {
                            doCloneLesson();
                        }
                    } else {
                        smartAlert('請選擇欲複製的課程!!');
                    }
                }

                function doCloneLesson() {
                    showLoading();
                    $('#addItem').find('form').ajaxForm({
                        beforeSubmit: function () {
                        },
                        success: function (data) {
                            hideLoading();
                            if (data.result) {
                                smartAlert("資料已複製!!", function (message) {
                                    $modal.modal('hide');
                                    //$('#addItem').remove();
                                    //$('#updateSeq').ajaxForm({
                                    //    success: function (data) {
                                    //        $('#updateSeq').html(data);
                                    //        $('body').scrollTop(screen.height);
                                    //    }
                                    //}).submit();
                                    makeLessonPlan(<%= JsonConvert.SerializeObject(new
                                {
                                    classDate = _model.ClassDate.ToString("yyyy-MM-dd"),
                                    hour = _model.Hour,
                                    registerID = _model.RegisterID,
                                    lessonID = _model.LessonID
                                }) %>);
                        });
                    } else {
                        smartAlert(data.message, function () {
                            $modal.modal('hide');
                            //$('#addItem').remove();
                        });
                    }
                },
                error: function () {
                }
            }).submit();

        }

    </script>
    <%  Html.RenderPartial("~/Views/Lessons/Module/TrainingItemScript.ascx"); %>


</asp:Content>
<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    LessonTimeExpansion _model;
    LessonPlan _plan;
    List<RegisterLesson> _groups;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (LessonTimeExpansion)this.Model;
        _plan = _model.LessonTime.LessonPlan ?? new LessonPlan { };
        if(_model.RegisterLesson.GroupingMemberCount>1)
        {
            _groups = _model.RegisterLesson.GroupingLesson.RegisterLesson.ToList();
        }
        else
        {
            _groups = new List<RegisterLesson>();
            _groups.Add(_model.RegisterLesson);
        }
        ViewBag.CloneLesson = true;
    }



</script>
