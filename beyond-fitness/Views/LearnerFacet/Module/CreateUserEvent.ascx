<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialogID %>" title="新增行事曆" class="bg-color-darken">
    <form action="<%= Url.Action("CommitUserEvent","LearnerFacet",new { UID = _viewModel.UID,EventID = _viewModel.EventID }) %>" class="smart-form" autofocus>
        <fieldset>
            <div>
                <section>
                    <label class="label">請輸入行事曆內容</label>
                    <label class="input">
                        <i class="icon-append far fa-keyboard"></i>
                        <input type="text" name="Title" maxlength="10" placeholder="請輸入行事曆內容" value="<%= _viewModel.Title %>"/>
                    </label>
                </section>
            </div>
        </fieldset>
        <fieldset>
            <div class="row">
                <section class="col col-6">
                    <label class="label">請選擇開始時間</label>
                    <label class="input">
                        <i class="icon-append far fa-calendar-alt"></i>
                        <input type="text" name="StartDate" readonly="readonly" class="form-control input-lg date form_date" data-date-format="yyyy/mm/dd" value="<%= String.Format("{0:yyyy/MM/dd}",_viewModel.StartDate) %>" placeholder="請選擇開始時間" />
                    </label>
                </section>
                <section class="col col-6">
                    <label class="label">請選擇結束時間</label>
                    <label class="input">
                        <i class="icon-append far fa-calendar-alt"></i>
                        <input type="text" name="EndDate" readonly="readonly" class="form-control input-lg date form_date" data-date-format="yyyy/mm/dd" value="<%= String.Format("{0:yyyy/MM/dd}",_viewModel.EndDate) %>" placeholder="請選擇結束時間" />
                    </label>
                </section>
            </div>
        </fieldset>
    </form>
    <script>

        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-plus'></i>  新增行事曆</h4>",
            buttons: [
<%  if(_viewModel.EventID.HasValue)
    {   %>
            {
                html: "<i class='far fa-trash-alt'></i>&nbsp;刪除",
                "class": "btn btn-primary",
                click: function () {
                    var $this = $(this);
                    //$(this).dialog("close");
                    showLoading();
                    $.post('<%= Url.Action("CancelEvent","LearnerFacet",new { id = _viewModel.EventID }) %>', {}, function (data) {
                        hideLoading();
                        if (data.result) {
                            alert('行事曆已取消!!');
                            $('#calendar').fullCalendar('removeEvents', function (calEvent) {
                                return calEvent.lessonID == <%= _viewModel.EventID %>;
                            });
                            $this.dialog("close");
                        } else {
                            alert(data.message);
                        }
                    });
                }
            },
<%  }   %>
            {
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {
                    //$(this).dialog("close");
                    showLoading();
                    $('#<%= _dialogID %> form').ajaxSubmit({
                        success: function (data) {
                            hideLoading();
                            $('#calendar').fullCalendar('refetchEvents');
                            $(data).appendTo($('body'));
                        }
                    });
                }
            }],
            close: function (event, ui) {
                $('#<%= _dialogID %>').remove();
            }
        });

        $('.form_date').datetimepicker({
            language: 'zh-TW',
            weekStart: 0,
            todayBtn: 1,
            clearBtn: 1,
            autoclose: 1,
            todayHighlight: 1,
            startView: 2,
            minView: 2,
            forceParse: 0
        });

    </script>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserEventViewModel _viewModel;
    String _dialogID;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (UserEventViewModel)ViewBag.ViewModel;
        _dialogID = "addEventDialog" + DateTime.Now.Ticks;
    }

</script>
