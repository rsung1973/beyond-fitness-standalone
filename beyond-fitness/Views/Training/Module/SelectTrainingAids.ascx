<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div id="<%= _dialogID %>" title="編輯器材" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white no-padding">
        <form class="smart-form">
            <%  foreach (var item in models.GetTable<TrainingStage>())
                {
                    if (item.TrainingAids.Where(a => a.Status == (int)Naming.GeneralStatus.Successful)
                        .Count() == 0)
                        continue; %>
            <fieldset>
                <div class="row">
                    <label class="label"><%= item.Stage %>：</label>
                    <%
                        var aids = item.TrainingAids
                            .Where(t => t.Status == (int)Naming.GeneralStatus.Successful)
                            .ToArray();
                        int cols = aids.Length / 4;
                        int remainders = aids.Length % 4;
                        int remainderIdx = 1;
                        for(int idx=0;idx < aids.Length;)
                        { %>
                    <div class="col col-3">
                        <%
                            int bound = (remainderIdx++) < remainders ? cols + 1 : cols;
                            for (int j = 0; j < bound && idx < aids.Length; j++)
                            {
                                var aid = aids[idx++]; %>
                        <label class="checkbox" style="white-space:nowrap;">
                            <input type="checkbox" name="AidID" value="<%= aid.AidID %>" />
                            <i></i><%= aid.ItemName %></label>
                        <%  } %>
                    </div>
                    <%  } %>
                </div>
            </fieldset>
            <%  } %>
        </form>
    </div>
    <script>

        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: 'auto',
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-edit'></i>  編輯使用器材</h4>",
            buttons: [{
                html: "<i class='fa fa-paper-plane'></i>&nbsp; 確定",
                "class": "btn btn-primary",
                click: function () {
                    $global.aidID = [];
                    $('input:checkbox[name="AidID"]:checked').each(function (idx, elmt) {
                        $global.aidID.push(Number($(this).val()));
                    });
                    $('#trainingAids').load('<%= Url.Action("ShowTrainingAids","Training") %>', { 'aidID': $global.aidID }, function (data) { });
                    $('#<%= _dialogID %>').dialog("close");
                }
            }],
            close: function (event, ui) {
                $('#<%= _dialogID %>').remove();
            }

        });

        $(function () {
            if ($global.aidID && $global.aidID.length>0) {
                $global.aidID.forEach(function (item, idx) {
                    $('input:checkbox[name="AidID"][value=' + item + ']').prop('checked', true);
                });
            }
        });

    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    TrainingItemViewModel _viewModel;
    String _dialogID = "trainingAids" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (TrainingItemViewModel)ViewBag.ViewModel;
    }

</script>
