<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<!--合約詳細資料-->
<div class="container-fluid contract">
    <div class="row clearfix">
        <h4 class="card-outbound-header m-l-15">詳細資料</h4>
        <div class="col-lg-12">
            <div class="card">
                <div class="header">
                    <ul class="header-dropdown">
                        <li>
                            <a href="javascript:moreContractQuery();"><i class="zmdi zmdi-search-for"></i></a>
                        </li>
                    </ul>
                </div>
                <div class="body" id="<%= _viewID %>">
                    <%  Html.RenderPartial("~/Views/ContractConsole/Module/ContractList.ascx", _contractItems); %>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
    function showContractList(viewModel,alertCount) {
        if (alertCount && alertCount > 300) {
            swal({
                title: "繼續載入?",
                text: "讀取大量資料，將影響系統效能!",
                type: "warning",
                showCancelButton: true,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "確定, 不後悔",
                cancelButtonText: "不, 點錯了",
                closeOnConfirm: true,
                closeOnCancel: true,
            }, function (isConfirm) {
                if (isConfirm) {
                    showLoading();
                    $.post('<%= Url.Action("InquireContract", "ContractConsole") %>', viewModel, function (data) {
                        hideLoading();
                        if ($.isPlainObject(data)) {
                            swal(data.message);
                        } else {
                            $('#<%= _viewID %>').empty()
                                .append(data);
                        }
                    });
                } else {
                }
            });
        } else {
            showLoading();
            $.post('<%= Url.Action("InquireContract", "ContractConsole") %>', viewModel, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    swal(data.message);
                } else {
                    $('#<%= _viewID %>').empty()
                        .append(data);
                }
            });
        }
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    String _viewID = $"contractDetails{DateTime.Now.Ticks}";
    IQueryable<CourseContract> _contractItems;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _contractItems = ViewBag.Contracts as IQueryable<CourseContract>;
        if (_contractItems == null)
            _contractItems = models.GetTable<CourseContract>().Where(c => false);
    }


</script>
