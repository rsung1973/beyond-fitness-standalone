<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<% if (_viewModel != null && _viewModel.RecordCount > 0)
    { %>
    <ul class="pagination pagination-darkteal float-right">
        <% if (startPaging > 0)
            { %>
        <%--<li class="page-item"><a class="page-link" href="javascript:gotoPage(0);">最前</a></li>--%>
        <% } %>
        <% if (prevPaging)
            { %>
        <li class="page-item"><a class="page-link" href="javascript:gotoPage(<%= startPaging-_viewModel.PagingSize %>);">上一頁</a></li>
        <% } %>
        <% for (int i = startPaging.Value; i < Math.Min(pagingCount.Value, (startPaging + _viewModel.PagingSize).Value); i++)
            {
                if (i == _viewModel.CurrentIndex)
                { %>
                <li class="page-item active"><a class="page-link" href="javascript:void(0);"><%= i+1 %></a></li>
        <%      }
                else
                { %>
                <li class="page-item"><a class="page-link" href="javascript:gotoPage(<%= i %>);"><%= i+1 %></a></li>
        <%      }%>
        <%  } %>
        <%  if (nextPaging)
            { %>
        <li class="page-item"><a class="page-link" href="javascript:gotoPage(<%= startPaging+_viewModel.PagingSize %>);">下一頁</a></li>
        <%  } %>
        <%  if (startPaging + _viewModel.PagingSize < pagingCount)
            { %>
        <%--<li class="page-item"><a class="page-link" href="javascript:gotoPage(<%= pagingCount-1 %>);">最後</a></li>--%>
        <%  } %>
    </ul>
    <script>
        function gotoPage(currentIndex) {
            var viewModel = {
                "PageSize":<%= _viewModel?.PageSize %>,
                "PagingSize":<%= _viewModel?.PagingSize %>,
                "CurrentIndex":<%= _viewModel?.CurrentIndex %>,
            };
            viewModel.CurrentIndex = currentIndex;
            if ($global.onPaging) {
                $global.onPaging(viewModel);
            }
        }
    </script>
<% } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    QueryViewModel _viewModel;    int? startPaging, pagingCount;
    bool nextPaging, prevPaging;
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _viewModel = (QueryViewModel)ViewBag.ViewModel;

        if (_viewModel != null && _viewModel.PageSize > 0 && _viewModel.PagingSize > 0
            && _viewModel.CurrentIndex >= 0 && _viewModel.RecordCount >= 0)
        {
            pagingCount = (_viewModel.RecordCount + _viewModel.PageSize - 1) / _viewModel.PageSize;
            startPaging = _viewModel.CurrentIndex / _viewModel.PagingSize * _viewModel.PagingSize;
            prevPaging = pagingCount > 0 && startPaging >= _viewModel.PagingSize;
            nextPaging = pagingCount > 0 && (startPaging + _viewModel.PagingSize) < pagingCount;
        }
        else
        {
            _viewModel = null;
        }
    }

</script>
