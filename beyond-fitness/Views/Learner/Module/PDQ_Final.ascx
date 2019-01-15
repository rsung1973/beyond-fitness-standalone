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

<div id="<%= _dialog %>" title="編輯問卷調查表" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <!-- Widget ID (each widget will need unique ID)-->
        <div class="jarviswidget jarviswidget-color-blueDark" id="wid-id-6" data-widget-colorbutton="false" data-widget-togglebutton="false" data-widget-editbutton="false" data-widget-fullscreenbutton="false" data-widget-deletebutton="false">
            <!-- widget options:
                                    usage: <div class="jarviswidget" id="wid-id-0" data-widget-editbutton="false">
                                    
                                    data-widget-colorbutton="false" 
                                    data-widget-editbutton="false"
                                    data-widget-togglebutton="false"
                                    data-widget-deletebutton="false"
                                    data-widget-fullscreenbutton="false"
                                    data-widget-custombutton="false"
                                    data-widget-collapsed="true" 
                                    data-widget-sortable="false"
                                    
                                -->
            <header>
                <h2><strong>方案設計工具結果</strong></h2>
                <div class="widget-toolbar">

                    <div class="progress progress-striped active" rel="tooltip" data-original-title="100%" data-placement="bottom">
                        <div class="progress-bar progress-bar-success" role="progressbar" style="width: 100%">100%</div>
                    </div>

                </div>
            </header>
            <!-- widget div-->
            <div>

                <!-- widget edit box -->
                <div class="jarviswidget-editbox">
                    <!-- This area used as dropdown edit box -->
                </div>
                <!-- end widget edit box -->

                <!-- widget content -->
                <div class="widget-body bg-color-darken txt-color-white no-padding">
                    <form action="<%= VirtualPathUtility.ToAbsolute("~/Member/UpdatePDQ/") + _model.UID %>" id="pageForm" class="smart-form" method="post">
                        <input type="hidden" name="groupID" value="0" />
                        <fieldset>
                            <div class="row">
                                <section class="col col-4">
                                    <label>請選擇【目標】合適結果</label>
                                    <label class="select">
                                        <select class="input-lg" name="goalID">
                                            <%  foreach (var item in models.GetTable<GoalAboutPDQ>())
                                                { %>
                                            <option value="<%= item.GoalID %>"><%= item.Goal %></option>
                                            <%  } %>
                                        </select>
                                        <i></i>
                                        <%  if (_model.PDQUserAssessment != null)
                                            { %>
                                        <script>
                                            $('select[name="goalID"]').val(<%= _model.PDQUserAssessment.GoalID %>)
                                        </script>
                                        <%  } %>
                                    </label>
                                </section>
                                <section class="col col-4">
                                    <label>請選擇【風格】合適結果</label>
                                    <label class="select">
                                        <select class="input-lg" name="styleID">
                                            <%  foreach (var item in models.GetTable<StyleAboutPDQ>())
                                                { %>
                                            <option value="<%= item.StyleID %>"><%= item.Style %></option>
                                            <%  } %>
                                        </select>
                                        <i></i>
                                        <%  if (_model.PDQUserAssessment != null)
                                            { %>
                                        <script>
                                            $('select[name="styleID"]').val(<%= _model.PDQUserAssessment.StyleID %>)
                                        </script>
                                        <%  } %>
                                    </label>
                                </section>
                                <section class="col col-4">
                                    <label>請選擇【訓練水準】合適結果</label>
                                    <label class="select">
                                        <select class="input-lg" name="levelID">
                                            <%  foreach (var item in models.GetTable<TrainingLevelAboutPDQ>())
                                                { %>
                                            <option value="<%= item.LevelID %>"><%= item.TrainingLevel %></option>
                                            <%  } %>
                                        </select>
                                        <i></i>
                                        <%  if (_model.PDQUserAssessment != null)
                                            { %>
                                        <script>
                                            $('select[name="levelID"]').val(<%= _model.PDQUserAssessment.LevelID %>)
                                        </script>
                                        <%  } %>
                                    </label>
                                </section>
                            </div>
                        </fieldset>

                        <div class="widget-footer">

                            <button class="btn btn-lg btn-success" type="button" onclick="$global.saveFinal(true);">
                                完成問卷
                            </button>

                            <button class="btn btn-lg btn-danger pull-left" type="button" onclick="$global.saveFinal(false);">
                                上一步
                            </button>

                        </div>


                    </form>

                </div>
                <!-- end widget content -->

            </div>
            <!-- end widget div -->

        </div>
        <!-- end widget -->
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen: false,
            width: "100%",
            resizable: false,
            modal: true,
            title: "<div class='modal-title'><h4><i class='fa fa-edit'></i> 編輯問卷調查表</h4></div>",
            close: function () {
                $('#<%= _dialog %>').remove();
            }
        });

        $(function () {
            $global.saveFinal = function (next) {
                console.log('debug:final...');
                var $form = $('#<%= _dialog %> form');
                $form.ajaxForm({
                    url: "<%= Url.Action("UpdatePDQ","Learner",new { _model.UID }) %>",
                    beforeSubmit: function () {
                        showLoading();
                    },
                    success: function (data) {
                        hideLoading();
                        if (data.result) {
                            $('#<%= _dialog %>').dialog('close');
                            if (next) {
                                if ($global.editPDQDone) {
                                    $global.editPDQDone();
                                }
                            }
                            else {
                                $.post('<%= Url.Action("PDQ","Learner",new { uid=_model.UID,groupID=5 }) %>', {}, function (data) {
                                    $(data).appendTo($('body'));
                                });
                            }
                        } else {
                            alert(data.message);
                        }
                    },
                    error: function () {
                    }
                }).submit();
            };
        });

        

    </script>
</div>

<script runat="server">

    String _dialog = "PDQ_" + DateTime.Now.Ticks;
    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;

    }

</script>
