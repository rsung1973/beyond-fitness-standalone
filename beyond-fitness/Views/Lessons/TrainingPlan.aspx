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
            <%  Html.RenderPartial("~/Views/Lessons/LessonsInfo.ascx", _model.LessonTime); %>
        </article>
        <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
            <div class="jarviswidget" id="wid-id-0" data-widget-togglebutton="false" data-widget-editbutton="false" data-widget-fullscreenbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false">

                <header>
                    <span class="widget-icon"><i class="fa fa-rss text-success"></i></span>
                    <h2><%= _model.ClassDate.ToString("yyyy/MM/dd") %> <%= String.Format("{0:00}",_model.Hour) %>:00-<%= String.Format("{0:00}",_model.Hour+1) %>:00 課表</h2>
                    <div class="widget-toolbar">
                        <%  if ((_model.LessonTime.TrainingBySelf==1 || models.CouldMarkToAttendLesson(_model.LessonTime)) && _model.LessonTime.LessonAttendance == null)
                            { %>
                        <a onclick="attendLesson(<%= _model.LessonID %>);" class="btn btn-success"><i class="far fa-fw fa-check-square"></i>完成上課</a>
                        <%  } %>
                        <a onclick="cloneLesson(<%= _model.LessonID %>);" class="btn bg-color-orange"><i class="fa fa-fw fa-files-o"></i> 複製課表</a>
                        <a onclick='previewLesson(<%= JsonConvert.SerializeObject(new
                            {
                                classDate = _model.ClassDate.ToString("yyyy-MM-dd"),
                                hour = _model.Hour,
                                registerID = _model.RegisterID,
                                lessonID = _model.LessonID
                            }) %>);'
                            class="btn bg-color-orange"><i class="fa fa-fw fa-eye"></i> 檢視課表</a>
                    </div>
                    <ul id="widget-tab-1" class="nav nav-tabs pull-right">
                        <li class="active">
                            <a data-toggle="tab" href="#s5"><i class="fa fa-commenting-o"></i><span>教練悄悄話</span></a>
                        </li>
                        <%  if (_model.LessonTime.TrainingBySelf != 1)
                            { %>
                        <li>
                            <a data-toggle="tab" href="#s7"><i class="fa fa-history"></i><span>身體健康指數</span></a>
                        </li>
                        <%  } %>
                        <li>
                            <a data-toggle="tab" href="#s1"><i class="fa fa-child"></i><span>暖身</span></a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#s2"><i class="fa fa-heartbeat"></i><span>訓練內容</span></a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#s3"><i class="fa fa-comments-o"></i><span>課後提醒</span></a>
                        </li>
                        <%  if (_model.LessonTime.TrainingBySelf != 1)
                            { %>
                        <li>
                            <a data-toggle="tab" href="#s4"><i class="fa fa-chart-pie"></i><span>評量指數</span></a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#s6"><i class="fa fa-line-chart"></i><span>體能分析表</span></a>
                        </li>
                        <%  } %>
                    </ul>

                </header>
                <!-- widget div-->
                <div class="no-padding">
                    <div class="widget-body no-padding">
                        <!-- content -->
                        <div id="myTabContent" class="tab-content padding-10">
                            <div class="tab-pane fade" id="s1">
                                <div class="panel-body status">
                                    <div class="chat-body custom-scroll">
                                        <%  Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _model.LessonTime); %>
                                        <ul>
                                            <li class="message">
                                                <% _model.LessonTime.AsAttendingCoach.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online", @style = "width:95px" }); %>
                                                <div class="message-text">
                                                    <time><%= String.Format("{0:yyyy-MM-dd HH:mm}",_model.LessonTime.ClassTime) %></time>
                                                    <a class="username"><%= _model.LessonTime.AsAttendingCoach.UserProfile.FullName() %></a> <div id="msgWarming"><%= _plan.Warming %></div>
                                                </div>
                                            </li>
                                        </ul>
                                    </div>
                                    <div class="chat-footer">
                                        <!-- CHAT TEXTAREA -->
                                        <div class="textarea-div">
                                            <div class="typearea">
                                                <textarea id="warming" name="warming" placeholder="請輸入100個中英文字" class="custom-scroll" maxlength="100" rows="20"><%= _plan.Warming %></textarea>
                                            </div>
                                        </div>

                                        <!-- CHAT REPLY/SEND -->
                                        <span class="textarea-controls">
                                            <button id="btnUpdateWarming" onclick="commitPlan();" class="btn btn-sm btn-primary pull-right">
                                                更新
                                            </button>
                                        </span>
                                    </div>
                                </div>
                            </div>
                            <!-- end s1 tab pane -->
                            <div class="tab-pane fade widget-body no-padding-bottom" id="s2">
                                <%  Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _model.LessonTime); %>
                                <form action="<%= VirtualPathUtility.ToAbsolute("~/Lessons/UpdateTrainingItemSequence/") + _model.LessonID %>" method="post" id="updateSeq">
                                    <% Html.RenderAction("SingleTrainingExecutionPlan","Lessons", new { LessonID = _model.LessonID }); %>
                                </form>
                            </div>
                            <!-- end s2 tab pane -->
                            <div class="tab-pane fade widget-body no-padding-bottom" id="s3">
                                <div class="panel-body status">
                                    <div class="chat-body custom-scroll">
                                        <%  Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _model.LessonTime); %>
                                        <ul>
                                            <li class="message">
                                                <% _model.LessonTime.AsAttendingCoach.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online",@style = "width:95px" }); %>
                                                <div class="message-text">
                                                    <time><%= String.Format("{0:yyyy-MM-dd HH:mm}",_model.LessonTime.ClassTime) %></time>
                                                    <a class="username"><%= _model.LessonTime.AsAttendingCoach.UserProfile.FullName() %></a>
                                                    <div id="msgEndingOperation">
                                                        <%= _plan.EndingOperation %>
                                                    </div>
                                                </div>
                                            </li>
                                        </ul>
                                    </div>
                                    <div class="chat-footer">
                                        <!-- CHAT TEXTAREA -->
                                        <div class="textarea-div">
                                            <div class="typearea">
                                                <textarea id="endingOperation" name="endingOperation" placeholder="請輸入100個中英文字" class="custom-scroll" maxlength="100" rows="20"><%= _plan.EndingOperation %></textarea>
                                            </div>
                                        </div>

                                        <!-- CHAT REPLY/SEND -->
                                        <span class="textarea-controls">
                                            <button onclick="commitPlan();" class="btn btn-sm btn-primary pull-right">
                                                更新
                                            </button>
                                        </span>
                                    </div>
                                </div>
                            </div>
                            <!-- end s3 tab pane -->
                            <%  if (_model.LessonTime.TrainingBySelf != 1)
                                { %>
                            <div class="tab-pane fade widget-body no-padding-bottom" id="s4">
                                <% Html.RenderPartial("~/Views/Lessons/LessonAssessment.ascx", _model.LessonTime); %>
                            </div>
                            <div class="tab-pane fade widget-body no-padding-bottom" id="s6">
                                <% Html.RenderPartial("~/Views/Lessons/LessonAssessmentReport.ascx", _model.LessonTime); %>
                            </div>
                            <div class="tab-pane fade widget-body no-padding-bottom" id="s7">
                                <% Html.RenderPartial("~/Views/Lessons/HealthAssessment.ascx", _model.LessonTime); %>
                            </div>
                            <%  } %>
                            <!-- end s4 tab pane -->
                            <div class="tab-pane fade active widget-body in no-padding-bottom" id="s5">
                                <div class="panel-body status">
                                    <div class="chat-body custom-scroll">
                                        <%  Html.RenderPartial("~/Views/Lessons/Feedback/CommonFeedback.ascx", _model.LessonTime); %>
                                        <ul>
                                            <li class="message">
                                                <% _model.LessonTime.AsAttendingCoach.UserProfile.RenderUserPicture(Writer, new { @class = "profileImg online", @style = "width:95px" }); %>
                                                <div class="message-text">
                                                    <time><%= String.Format("{0:yyyy-MM-dd HH:mm}",_model.LessonTime.ClassTime) %></time>
                                                    <a class="username"><%= _model.LessonTime.AsAttendingCoach.UserProfile.FullName() %></a> 
                                                    <div id="msgRemark"><%= _plan.Remark %></div>
                                                </div>
                                            </li>
                                        </ul>
                                    </div>
                                    <div class="chat-footer">
                                        <!-- CHAT TEXTAREA -->
                                        <div class="textarea-div">
                                            <div class="typearea">
                                                <textarea id="remark" name="remark"  placeholder="請輸入100個中英文字" class="custom-scroll" maxlength="100" rows="20"><%= _plan.Remark %></textarea>
                                            </div>
                                        </div>

                                        <!-- CHAT REPLY/SEND -->
                                        <span class="textarea-controls">
                                            <button onclick="commitPlan();" class="btn btn-sm btn-primary pull-right">
                                                更新
                                            </button>
                                        </span>
                                    </div>
                                </div>
                            </div>
                            <!-- end s5 tab pane -->
                        </div>

                        <!-- end content -->
                    </div>

                </div>
                <!-- end widget div -->
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

        function attendLesson(lessonID) {
            var event = event || window.event;
            showLoading();
            $.post('<%= Url.Action("AttendLesson","Attendance") %>', { 'lessonID': lessonID }, function (data) {
                hideLoading();
                if (data) {
                    if(data.result) {
                        smartAlert("已完成打卡!!");
                        $(event.target).remove();
                    } else {
                        smartAlert(data.message);
                    }
                }
            });
        }

        function commitPlan() {
            showLoading(true);
            $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/CommitPlan") %>',
                {
                    'recentStatus': $('#recentStatus').val(),
                    'warming': $('#warming').val(),
                    'endingOperation': $('#endingOperation').val(),
                    'remark': $('#remark').val()
                }, function (data) {
                    hideLoading();
                    if (data.result) {
                        smartAlert('資料已更新!!');
                        $('#msgWarming').text($('#warming').val());
                        $('#msgEndingOperation').text($('#endingOperation').val());
                        $('#msgRemark').text($('#remark').val());
                    } else {
                        smartAlert(data.message);
                    }
            });
        }

        function deleteTraining(itemID) {
            confirmIt({ title: '刪除訓練組數', message: '確定刪除此訓練組數?' }, function (evt) {
                showLoading()
                $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/DeleteTraining/") %>' + itemID, {}, function (data) {
                    $('#s2').empty().append($(data));
                    hideLoading();
                });
            });
        }

        function deletePlan() {
            confirmIt({ title: '刪除課表', message: '確定刪除此課表?' }, function (evt) {
                showLoading();
                $('<form method="post"/>').appendTo($('body'))
                    .prop('action', '<%= VirtualPathUtility.ToAbsolute("~/Lessons/DeletePlan") %>')
                    .submit();
            });
        }

        function addTraining() {
            showLoading();
            $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/AddTraining") %>', {}, function (data) {
                if (data) {
                    hideLoading();
                    $('#trainingPlan').before($(data));
                }
            });
        }


        var $modal;
        function addTrainingItem(executionID) {
            <%--            $('#addItem').remove();
            $modal = $('<div class="modal fade" id="addItem" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" />');
            showLoading();
            $modal.appendTo($('#content'))
                .load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/AddTrainingItem") %>' + '?id=' + executionID , {}, function () {
                    hideLoading();
                    $modal.on('hidden.bs.modal', function (evt) {
                        $('body').scrollTop(screen.height);
                    });
                    $modal.modal('show');
                });--%>
            showLoading();
            $.post('<%= Url.Action("AddTrainingItem","Lessons") %>', { 'id': executionID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }

        function addBreakInterval(executionID) {
            $('#addItem').remove();
            $modal = $('<div class="modal fade" id="addItem" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" />');
            //$('#loading').css('display', 'table');
            showLoading();
            $modal.appendTo($('#content'))
                .load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/AddTrainingBreakInterval") %>' + '?id=' + executionID, {}, function () {
                    hideLoading();
                    $modal.on('hidden.bs.modal', function (evt) {
                        $('body').scrollTop(screen.height);
                    });
                    $modal.modal('show');
                });
        }

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
                        'registerID': <%= _model.RegisterID %>,
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

        function editTrainingItem(executionID, itemID) {
            $('#addItem').remove();
            $modal = $('<div class="modal fade" id="addItem" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" />');
            showLoading();
            $modal.appendTo($('#content'))
                .load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/EditTrainingItem") %>', { 'executionID': executionID, 'itemID': itemID }, function () {
                    hideLoading();
                    $modal.on('hidden.bs.modal', function (evt) {
                        $('body').scrollTop(screen.height);
                    });
                    $modal.modal('show');
                });
        }

        function editBreakInterval(executionID, itemID) {
            $('#addItem').remove();
            $modal = $('<div class="modal fade" id="addItem" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" />');
            showLoading();
            $modal.appendTo($('#content'))
                .load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/EditTrainingBreakInterval") %>', { 'executionID': executionID, 'itemID': itemID }, function () {
                    hideLoading();
                    $modal.on('hidden.bs.modal', function (evt) {
                        $('body').scrollTop(screen.height);
                    });
                    $modal.modal('show');
                });
        }


        function deleteItem(executionID,itemID) {
            var event = event || window.event;
            confirmIt({ title: '刪除訓練項目', message: '確定刪除此訓練項目?' }, function (evt) {
                showLoading();
                $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/DeleteTrainingItem") %>', { 'itemID': itemID,'executionID':executionID }, function (data) {
                    hideLoading();
                    if (data.result) {
                        $(event.target).parent().parent().parent().remove();
                    } else {
                        smartAlert(data.message);
                    }
                });
            });
        }

        function moveItem(direction) {
            var $tr = $(event.target).parent().parent().parent();
            if (direction == 'up') {
                var $target = $tr.prev();
                $target.before($tr);
            } else if (direction == 'down') {
                var $target = $tr.next();
                $target.after($tr);
            }
            $('.fa-arrow-circle-o-up').removeClass('disabled');
            $('.fa-arrow-circle-o-down').removeClass('disabled');
            $('.fa-arrow-circle-o-up').first().addClass('disabled');
            $('.fa-arrow-circle-o-down').last().addClass('disabled');

        }

        function updateSequence() {
            showLoading();
            $('#updateSeq').ajaxForm({
                success: function (data) {
                    $('#updateSeq').html(data);
                    hideLoading();
                    smartAlert("資料已儲存!!");
                }
            }).submit();
        }

        function commitTrainingItem() {
            showLoading();
            $('#addItem').find('form').ajaxForm({
                <%--url: "<%= VirtualPathUtility.ToAbsolute("~/Lessons/CommitTrainingItem") %>",--%>
                beforeSubmit: function () {
                },
                success: function (data) {
                    hideLoading();
                    if (data.result) {
                        smartAlert("資料已儲存!!", function (message) {
                            $modal.modal('hide');
                            //$('#addItem').remove();
                            $('#updateSeq').ajaxForm({
                                success: function (data) {
                                    $('#updateSeq').html(data);
                                    $('body').scrollTop(screen.height);
                                }
                            }).submit();
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

        function commitTraining() {

            var event = event || window.event;
            showLoading();
            $(event.target).parents('form').ajaxForm({
                url: "<%= VirtualPathUtility.ToAbsolute("~/Lessons/CommitTraining") %>",
                beforeSubmit: function () {
                },
                success: function (data) {
                    hideLoading();
                    if (data.result) {
                        smartAlert("資料已儲存!!", function (message) {
                        });
                    } else {
                        smartAlert(data.message, function () {
                        });
                    }
                },
                error: function () {
                }
            }).submit();
        }

        function commitAssessment() {
            $('#assessment').ajaxForm({
                url: "<%= VirtualPathUtility.ToAbsolute("~/Attendance/CommitAssessment") %>",
                beforeSubmit: function () {
                    showLoading(true);
                },
                success: function (data) {
                    hideLoading();
                    if (data.result) {
                        smartAlert("資料已儲存!!", function (message) {
                        });
                    } else {
                        if (data.forceLogout) {
                            window.location.href = '<%= VirtualPathUtility.ToAbsolute("~/Account/AlertTimeout") %>';
                        } else {
                            smartAlert(data.message, function () {
                            });
                        }
                    }
                },
                error: function () {
                }
            }).submit();
        }

    </script>

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
