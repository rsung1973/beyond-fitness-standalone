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
                <h2><strong>Step<%= _pdqGroup.GroupID %>.</strong> <i><%= _pdqGroup.GroupName %></i> </h2>
                <div class="widget-toolbar">

                    <div class="progress progress-striped active" rel="tooltip" data-original-title="<%= ViewBag.Percent %>" data-placement="bottom">
                        <div class="progress-bar progress-bar-success" role="progressbar" style="width: <%= ViewBag.Percent %>"><%= ViewBag.Percent %></div>
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
                        <input type="hidden" name="groupID" value="<%= _pdqGroup.GroupID %>" />
                        <%  
                                    for (int idx = 0; idx < _items.Length; idx++)
                                    {   %>
                        <fieldset>
                            <section>
                                <% renderItem(idx); %>
                            </section>
                        </fieldset>
                        <%  } %>

                        <div class="widget-footer">

                            <button class="btn btn-lg btn-primary" type="button" onclick="$global.saveAll(true);">
                                下一步
                            </button>

                            <button class="btn btn-lg btn-danger pull-left" type="button" onclick="$global.saveAll(false);">
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
        $(function(){
            $global.saveAll = function (next) {
                console.log('debug:all...');
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
                            var groupID = <%= _pdqGroup.GroupID %>;
                            if(next)
                                groupID++;
                            else
                                groupID--;
                            $.post('<%= Url.Action("PDQ","Learner",new { uid=_model.UID }) %>', {'groupID':groupID}, function (data) {
                                $(data).appendTo($('body'));
                            });

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
    PDQQuestion[] _items;
    PDQGroup _pdqGroup;
    UserProfile _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        int? groupID = (int?)ViewBag.GroupID;
        _pdqGroup = models.GetTable<PDQGroup>().Where(g => g.GroupID == groupID).First();
        _items = _pdqGroup.PDQQuestion.OrderBy(q => q.QuestionNo).ToArray();

        ViewBag.InlineGroup = false;

    }

    void renderItem(int idx)
    {
        var item = _items[idx];
        ViewBag.PDQTask = item.PDQTask.Where(p => p.UID == _model.UID).FirstOrDefault();
        ViewBag.Answer = item.PDQTask.Where(p => p.UID == _model.UID && !p.SuggestionID.HasValue).FirstOrDefault();
        if (item.QuestionID == _pdqGroup.ConclusionID)
        {
            Html.RenderPartial("~/Views/Member/PDQItemII.ascx", item);
        }
        else
        {
            Html.RenderPartial("~/Views/Member/PDQItem.ascx", item);
        }
    }

</script>
