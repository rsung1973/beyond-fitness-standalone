<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="well well-sm bg-color-darken txt-color-white">
    <!-- Widget ID (each widget will need unique ID)-->
    <div class="jarviswidget" id="wid-id-6" data-widget-editbutton="false" data-widget-custombutton="false" data-widget-colorbutton="false" data-widget-editbutton="false" data-widget-togglebutton="false" data-widget-deletebutton="false">
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
            <span class="widget-icon"><i class="fa fa-edit"></i></span>
            <h2>階段性調整計劃</h2>

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
                <div class="alert alert-warning fade in">
                    <i class="fa fa-info-circle">為了讓您的體能顧問做出更優化的階段性調整，下方提供
                &lt;六個小問題&gt;
                請您回答補充，資料僅提供訓練使用，不會外洩，敬請放心填寫！</i>
                </div>
                <form action="<%= Url.Action("CommitQuestionnaire","Interactivity",new { id = _model.QuestionnaireID }) %>" method="post" id="pageForm" class="smart-form">
                    <%  int idx = 0;
                        for (int row = 0; row < (_items.Length + 1) / 2; row++)
                        {   %>
                        <fieldset>
                            <div class="row">
                        <%  for(int col=0;col<2 && idx<_items.Length;col++)
                            {%>
                                <section class="col col-6">
                                    <% renderItem(idx++); %>
                                </section>
                    <%      } %>
                            </div>
                        </fieldset>
                    <%  }%>
                    <footer>
                        <button type="button" name="submit" class="btn btn-primary" onclick="saveAll();">
                            送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                        </button>
                    </footer>
                    <div class="message">
                        <i class="fa fa-check fa-lg"></i>
                        <p>
                            Your comment was successfully added!
                        </p>
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
    function saveAll() {
        $('#pageForm').ajaxForm({
            url: "<%= Url.Action("CommitQuestionnaire","Interactivity",new { id = _model.QuestionnaireID }) %>",
            beforeSubmit: function () {
                showLoading();
            },
            success: function (data) {
                hideLoading();
                if (data.result) {
                    smartAlert("資料已儲存!!", function () {
                        window.location.href = '<%= Url.Action("Vip","Account") %>';
                    });
                } else {
                    smartAlert(data.message);
                }
            },
            error: function () {
            }
        }).submit();
    }
</script>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _profile;
    PDQQuestion[] _items;
    QuestionnaireRequest _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (QuestionnaireRequest)this.Model;
        _items = _model.PDQGroup.PDQQuestion.OrderBy(q => q.QuestionNo).ToArray();
        _profile = Context.GetUser();
    }

    void renderItem(int idx)
    {
        var item = _items[idx];
        ViewBag.PDQTask = item.PDQTask.Where(p => p.UID == _profile.UID).FirstOrDefault();
        ViewBag.Answer = item.PDQTask.Where(p => p.UID == _profile.UID && !p.SuggestionID.HasValue).FirstOrDefault();
        ViewBag.InlineGroup = true;
        Html.RenderPartial("~/Views/Interactivity/Module/QuestionnaireItem.ascx", item);
    }

</script>
