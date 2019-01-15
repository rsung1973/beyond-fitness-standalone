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

<div id="<%= _dialog %>" title="編輯結果" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form action="<%= Url.Action("CommitExerciseResult","ExerciseGame",new { _model.UID }) %>" method="post" autofocus>
            <fieldset>
                <div class="row">
                    <div class="col col-md-4">
                        <div class="form-group">
                            <div class="icon-addon">
                                <select name="ExerciseID" class="form-control">
                                    <%  foreach (var item in models.GetTable<ExerciseGameItem>())
                                        { %>
                                    <option value="<%= item.ExerciseID %>"><%= item.Exercise %></option>
                                    <%  } %>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col col-md-4">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon">結果</span>
                                <input class="form-control" name="Score" placeholder="請輸入純數字" type="number" maxlength="15"/>
                                <%--<div class="icon-addon">
                                </div>--%>
                            </div>
                        </div>
                    </div>
                    <div class="col col-md-4">
                        <div class="form-group">
                            <div class="input-group">
                                <span class="input-group-addon">日期</span>
                                <input type="text" class="form-control date form_date" value="<%= String.Format("{0:yyyy/MM/dd}", DateTime.Today) %>" readonly="readonly" data-date-format="yyyy/mm/dd" placeholder="請輸入付款日期" name="TestDate" />
                            </div>
                        </div>
                    </div>
                </div>
            </fieldset>
        </form>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "600",
            resizable: false,
            modal: true,
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-edit'></i>  編輯結果</h4>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp;確定",
                "class": "btn btn-primary",
                click: function () {
                    var $form = $('#<%= _dialog %> form');
                    clearErrors();
                    $form.ajaxSubmit({
                        beforeSubmit: function () {
                            showLoading();
                        },
                        success: function (data) {
                            hideLoading();
                            if ($.isPlainObject(data)) {
                                if (data.result) {
                                    $('#<%= _dialog %>').dialog('close');
                                    loadExerciseResult();
                                } else {
                                    alert(data.message);
                                }
                            } else {
                                $(data).appendTo($('body')).remove();
                            }
                        }
                    });
                }
            }],
            close: function () {
                $('#<%= _dialog %>').remove();
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
    String _dialog = "testResult" + DateTime.Now.Ticks;
    ExerciseGameContestant _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (ExerciseGameContestant)this.Model;
    }

</script>
