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
<%@ Import Namespace="Newtonsoft.Json" %>

<script>

    function attendLesson(lessonID) {
        var event = event || window.event;
        showLoading();
        $.post('<%= Url.Action("AttendLesson","Attendance") %>', { 'lessonID': lessonID }, function (data) {
            hideLoading();
            if (data) {
                if (data.result) {
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
                $('<form method="post" />').appendTo($('body'))
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
            <%--            $('#addItem').remove();
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
                });--%>

            showLoading();
            $.post('<%= Url.Action("AddTrainingBreakInterval","Lessons") %>', { 'id': executionID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }


        function editTrainingItem(executionID, itemID) {
            <%--            $('#addItem').remove();
            $modal = $('<div class="modal fade" id="addItem" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" />');
            showLoading();
            $modal.appendTo($('#content'))
                .load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/EditTrainingItem") %>', { 'executionID': executionID, 'itemID': itemID }, function () {
                    hideLoading();
                    $modal.on('hidden.bs.modal', function (evt) {
                        $('body').scrollTop(screen.height);
                    });
                    $modal.modal('show');
                });--%>
            showLoading();
            $.post('<%= Url.Action("EditTrainingItem","Lessons") %>', { 'executionID': executionID, 'itemID': itemID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });

        }

        function editBreakInterval(executionID, itemID) {
            <%--            $('#addItem').remove();
            $modal = $('<div class="modal fade" id="addItem" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" />');
            showLoading();
            $modal.appendTo($('#content'))
                .load('<%= VirtualPathUtility.ToAbsolute("~/Lessons/EditTrainingBreakInterval") %>', { 'executionID': executionID, 'itemID': itemID }, function () {
                    hideLoading();
                    $modal.on('hidden.bs.modal', function (evt) {
                        $('body').scrollTop(screen.height);
                    });
                    $modal.modal('show');
                });--%>
            showLoading();
            $.post('<%= Url.Action("EditTrainingBreakInterval","Lessons") %>', { 'executionID': executionID, 'itemID': itemID }, function (data) {
                hideLoading();
                $(data).appendTo($('body'));
            });
        }


        function deleteItem(executionID, itemID) {
            var event = event || window.event;
            var $tr = $(event.target).closest('tr');
            var $tr1 = $tr.next();

            confirmIt({ title: '刪除訓練項目', message: '確定刪除此訓練項目?' }, function (evt) {
                showLoading();
                $.post('<%= VirtualPathUtility.ToAbsolute("~/Lessons/DeleteTrainingItem") %>', { 'itemID': itemID, 'executionID': executionID }, function (data) {
                    hideLoading();
                    if (data.result) {
                        $tr.remove();
                        if ($tr1.is('tr.remark')) {
                            $tr1.remove();
                        }
                    } else {
                        smartAlert(data.message);
                    }
                });
            });
        }

        function moveItem(direction) {
            var $tr = $(event.target).parent().parent().parent();
            var $tr1 = $tr.next();
            if (direction == 'up') {
                var $target = $tr.prevAll('tr.rowIdx').first();
                $target.before($tr);
                if ($tr1.is('tr.remark')) {
                    $target.before($tr1);
                }
            } else if (direction == 'down') {
                var $target = $tr.nextAll('tr.rowIdx').first();
                var $target1 = $target.next();
                if ($target1.is('tr.remark')) {
                    $target = $target1;
                }
                if ($tr1.is('tr.remark')) {
                    $target.after($tr1);
                }
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

        function commitTrainingItem($form) {
            showLoading();
            $form.ajaxForm({
                <%--url: "<%= VirtualPathUtility.ToAbsolute("~/Lessons/CommitTrainingItem") %>",--%>
                beforeSubmit: function () {
                },
                success: function (data) {
                    hideLoading();
                    if (data.result) {
                        smartAlert("資料已儲存!!", function (message) {
                            //$('#addItem').remove();
                            $('#updateSeq').ajaxForm({
                                success: function (data) {
                                    $('#updateSeq').html(data);
                                    //$('body').scrollTop(screen.height);
                                }
                            }).submit();
                        });
                    } else {
                        smartAlert(data.message, function () {
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

    function updateBasicAssessment() {
        var event = event || window.event;
        var hasValue = false;
        var $form = $(event.target).closest('form');
        $form.find('input').each(function (idx) {
            if ($(this).val() != '') {
                hasValue = true;
            }
        });
        if (hasValue) {
            $form.ajaxSubmit({
                success: function (data) {
                    $('.' + $form.prop('id')).html(data);
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
                $(data).appendTo($('body'));
            }
        });
    }

    function editAssessmentTrendItem(assessmentID, itemID) {
        showLoading();
        $.post('<%= Url.Action("EditAssessmentTrendItem","Activity") %>', { 'assessmentID': assessmentID, 'itemID': itemID }, function (data) {
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
                    $('#trendList' + item.assessmentID).load('<%= Url.Action("FitnessAssessmentTrendList","Activity") %>', item, function () {
                        hideLoading();
                    });
                });
            }
        });
    }

    function editAssessmentGroupItem(assessmentID, itemID) {
        showLoading();
        $.post('<%= Url.Action("EditAssessmentGroupItem","Activity") %>', { 'assessmentID': assessmentID, 'itemID': itemID }, function (data) {
            hideLoading();
            if (data) {
                $(data).appendTo($('#content'));
            }
        });
    }

    function commitAssessmentGroupItem(item, majorID) {
        showLoading();
        $.post('<%= Url.Action("CommitAssessmentTrendItem","Activity") %>', item, function (data) {
            hideLoading();
            if (data.result) {
                smartAlert("資料已儲存!!", function () {
                    showLoading();
                    drawGroupPie(item);
                    drawStrengthPie(item.assessmentID);
                    $('#_' + item.assessmentID + "_" + majorID).load('<%= Url.Action("FitnessAssessmentGroup","Activity") %>', { 'assessmentID': item.assessmentID, 'itemID': majorID }, function () {
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

    function deleteAssessmentItem(assessmentID, itemID, majorID) {
        var event = event || window.event;
        confirmIt({ title: '刪除評量指數', message: '確定刪除此評量指數項目?' }, function (evt) {
            showLoading();
            $.post('<%= Url.Action("DeleteFitnessAssessmentReport","Activity") %>', { 'assessmentID': assessmentID, 'itemID': itemID }, function (data) {
                hideLoading();
                if (data.result) {

                    //smartAlert("資料已刪除!!");
                    $('#_' + assessmentID + "_" + majorID).load('<%= Url.Action("FitnessAssessmentGroup","Activity") %>', { 'assessmentID': assessmentID, 'itemID': majorID }, function (data) {
                    });
                }
            });
        });
    }

</script>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
