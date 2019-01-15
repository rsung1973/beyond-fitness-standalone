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

<div id="<%= _dialogID %>" title="Beyond幣列表" class="bg-color-darken">
    <!-- Widget ID (each widget will need unique ID)-->
    <div class="jarviswidget jarviswidget-color-darken" id="wid-id-2" data-widget-editbutton="false" data-widget-colorbutton="false" data-widget-deletebutton="false" data-widget-togglebutton="false">
        <div>
            <!-- widget edit box -->
            <div class="jarviswidget-editbox">
                <!-- This area used as dropdown edit box -->
            </div>
            <!-- end widget edit box -->
            <!-- widget content -->
            <div class="widget-body bg-color-darken txt-color-white no-padding">
                <table class="table table-striped table-bordered table-hover" width="100%">
                    <thead>
                        <tr>
                            <th>活動名稱</th>
                            <th>獲得日期</th>
                            <th>Beyond幣</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%  var items = _model.GroupBy(t => t.PDQQuestion.GroupID);
                            foreach (var g in items.OrderBy(t => t.Key))
                            {
                                var group = models.GetTable<PDQGroup>().Where(p => p.GroupID == g.Key).First(); %>
                        <tr>
                            <td><%= group.GroupName %></td>
                            <td><%  if (g.Count() == 1)
                                    {   %>
                                <%= $"{g.First().TaskDate:yyyy/MM/dd}" %>
                                <%  }
                                    else
                                    {   %>
                                    --
                                <%  } %>
                            </td>
                            <td class="text-center"><%= g.Sum(t=>t.PDQQuestion.PDQQuestionExtension.BonusPoint) %></td>
                        </tr>
                        <%  } %>
                    </tbody>
                </table>
            </div>
            <!-- end widget content -->
        </div>
        <!-- end widget div -->
    </div>
    <!-- end widget -->
    <script>
        $('#<%= _dialogID %>').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: "auto",
            height: "auto",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-table'></i>  Beyond幣列表</h4>",
            close: function (event, ui) {
                $('#<%= _dialogID %>').remove();
            }
        });
    </script>
</div>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    AwardQueryViewModel _viewModel;
    String _dialogID = "bonus" + DateTime.Now.Ticks;
    IQueryable<PDQTask> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<PDQTask>)this.Model;
        _viewModel = (AwardQueryViewModel)ViewBag.ViewModel;
    }

</script>
