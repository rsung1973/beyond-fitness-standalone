<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Helper.DataOperation" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<ul class="row clearfix list-unstyled m-b-0" id="<%= _viewID %>">
    <li class="col-lg-6 col-md-12 col-sm-12">
        <div class="header">
            <h2><strong>合約資料</strong> - <%= _model.ContractName() %> <span class="badge bg-blue"><i class="zmdi zmdi-pin"></i>&nbsp;&nbsp;<%= _model.CourseContractExtension.BranchStore.BranchName %></span> </h2>
        </div>
        <div class="body">
            <div class="row">
                <div class="col-md-6 col-sm-6 invoice1">
                    <div class="clientlogo">
                        <%  _model.ContractOwner.PictureID.RenderUserPicture(this.Writer, new { @class = "fit" }, "images/avatar/noname.png"); %>
                    </div>
                    <address>
                        <strong><%= _model.ContractOwner.FullName() %></strong><br />
                        購買堂數：<%= _model.Lessons %><br />
                        <span class="p-l-40 col-red">剩餘堂數：<%= _model.RemainedLessonCount() %></span>
                    </address>
                </div>
                <div class="col-md-6 col-sm-6 text-right">
                    <p class="m-b-0"><strong>合約起日: </strong><%= $"{_model.ValidFrom:yyyy/MM/dd}" %></p>
                    <p class="m-b-0 col-red"><strong>合約迄日: </strong><%= $"{_model.Expiration:yyyy/MM/dd}" %></p>
                    <p class="m-b-0"><%= _model.ContractNo() %> <span class="badge bg-green"><%= (Naming.CourseContractStatus)_model.Status %></span></p>
                </div>
            </div>
            <div class="mt-40"></div>
            <hr>
            <div class="row">
                <div class="col-md-6">
                    <h5>其他增補說明</h5>
                    <p><%= _model.Remark %></p>
                </div>
                <div class="col-12 text-right">
                    <h3 class="text-right">專業顧問服務總費用：<%= $"{_model.TotalCost:##,###,###,###}" %></h3>
                </div>
            </div>
        </div>
    </li>
    <li class="col-lg-6 col-md-12 col-sm-12">
        <%  Action<String> applyPartial = ViewBag.ApplyService as Action<String>;
            if (applyPartial != null)
            {
                applyPartial(_viewID);
            }
        %>
    </li>
    <li class="col-12">
        <button type="button" class="btn btn-darkteal btn-round waves-effect float-right finish">確定，不後悔</button>
        <button type="button" class="btn btn-danger btn-round btn-simple waves-effect quit">不, 點錯了</button>
    </li>
</ul>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContract _model;
    UserProfile _profile;
    String _viewID = $"assign{DateTime.Now.Ticks}";

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
        _profile = Context.GetUser();
    }


</script>
