<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>


<%  int idx = 0;
    for (int row = 0; row < (_items.Length + 1) / 2; row++)
    {   %>
    <div class="row">
        <%  for (int col = 0; col < 2 && idx < _items.Length; col++)
            {%>
        <section class="col col-6">
            <% renderItem(idx++); %>
        </section>
        <%      } %>
    </div>
<%  }%>

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
        ViewBag.PDQTask = item.PDQTask.Where(p => p.UID == _model.UID).FirstOrDefault();
        ViewBag.Answer = item.PDQTask.Where(p => p.UID == _model.UID && !p.SuggestionID.HasValue).FirstOrDefault();
        ViewBag.InlineGroup = true;
        Html.RenderPartial("~/Views/Interactivity/Module/QuestionnaireItem.ascx", item);
    }

</script>
