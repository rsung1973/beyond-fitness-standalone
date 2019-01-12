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
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog" aria-labelledby="exampleModalLongTitle" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h6 class="title">請選擇課程單價</h6>
                <a class="closebutton" data-dismiss="modal"></a>
            </div>
            <div class="modal-popmenu-body">
                <ul class="menu_list">
                    <%  foreach (var item in _items)
                        {   %>
                    <li>
                        <a onclick="commitPrice(<%= item.PriceID %>,event);">
                            <div class="list_tb tb2">
                                <div class="list_tr">
                                    <div class="list_td">
                                        <%= item.SeriesID.HasValue 
                                                ? item.LowerLimit==1 
                                                    ? "單堂"
                                                    : item.LowerLimit + "堂"
                                                : item.Description %>
                                        <%= item.LessonPriceProperty.Any(p=>p.PropertyID==(int)Naming.LessonPriceFeature.舊會員續約) ? "(舊會員續約)" : null %>
                                        <span class="badge bg-blush float-right"><%= String.Format("{0,5:##,###,###,###}",item.ListPrice) %></span></div>
                                </div>
                            </div>
                        </a>
                    </li>
                    <%  } %>
                </ul>
            </div>
        </div>
    </div>

    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
    <script>
        $(function () {

        });

        function commitPrice(priceID, event) {
            var event = event || window.event;
            if ($global.commitPrice) {
                $global.commitPrice(priceID, $(event.target).text().trim().replace(/\s/g,''));
            }
            $global.closeAllModal();
        }

    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    String _dialogID = $"selectPrice{DateTime.Now.Ticks}";
    IQueryable<LessonPriceType> _model;
    IQueryable<LessonPriceType> _items;
    UserProfile _profile;
    CourseContractQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonPriceType>)this.Model;
        _profile = Context.GetUser();
        _viewModel = (CourseContractQueryViewModel)ViewBag.ViewModel;

        _items = _model;

        if (_profile.IsAssistant() || _profile.IsManager() || _profile.IsViceManager() || _profile.IsOfficer())
        {

        }
        else
        {
            _items = _items.Where(p => p.SeriesID.HasValue);
        }

        _items = _items.OrderBy(l => l.LowerLimit).ThenBy(l => l.PriceID);
    }


</script>
