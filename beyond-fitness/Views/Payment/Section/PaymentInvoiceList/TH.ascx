<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>


<th data-class="expand">發票號碼</th>
<th data-hide="phone">分店</th>
<th data-hide="phone">收款人</th>
<th>學員</th>
<th>收款日</th>
<th data-hide="phone">發票日</th>
<th data-hide="phone">作廢/折讓日</th>
<th data-hide="phone">收款品項</th>
<th>收款金額</th> 
<th data-hide="phone">發票金額</th>
<th data-hide="phone">營業稅</th>
<th data-hide="phone">作廢/折讓(含稅)</th> 
<th data-hide="phone,tablet">折讓(未稅)</th> 
<th data-hide="phone">收款方式</th>
<th data-hide="phone">發票類型</th>
<th>發票狀態</th>
<th data-hide="phone">買受人統編</th>
<th data-hide="phone">合約編號</th>
<th data-hide="phone">合約總金額</th> 
<th data-hide="phone">備註</th>
<th data-hide="phone">狀態</th>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
    }

</script>
