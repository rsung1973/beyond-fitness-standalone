<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%  

    int idx = 1;
    foreach (var item in _items)
    {
        var orgItem = models.GetTable<Organization>().Where(o => o.CompanyID == item.SellerID).First();
        InquireVacantNoResult tailItem;
        if (item.CheckNext.HasValue)
        {
            tailItem = _model[_model.IndexOf(item) + 1];
        }
        else
        {
            tailItem = item;
        }
%><%= String.Format("{0:00000}",idx++) %>,<%= orgItem.ReceiptNo %>,<%= String.Format("{0}{1:00}", item.Year - 1911, item.PeriodNo * 2) %>,<%= item.TrackCode %>,<%= String.Format("{0:00000000}",item.InvoiceNo) %>,<%= String.Format("{0:00000000}",tailItem.InvoiceNo) %>,07
<%  } %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    List<InquireVacantNoResult> _model;
    IEnumerable<InquireVacantNoResult> _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (List<InquireVacantNoResult>)this.Model;

        _items = _model.Where(r => !r.CheckPrev.HasValue);

        var item = _model.First();
        var orgItem = models.GetTable<Organization>().Where(o => o.CompanyID == item.SellerID).First();

        Response.Clear();
        Response.ClearContent();
        Response.ClearHeaders();
        Response.AddHeader("Cache-control", "max-age=1");
        Response.ContentType = "application/octet-stream";
        Response.AddHeader("Content-Disposition", String.Format("attachment;filename={0}", HttpUtility.UrlEncode("BlankNo_" + orgItem.ReceiptNo + "(" + String.Format("{0}{1:00}", item.Year - 1911, item.PeriodNo * 2) + ").csv")));

    }

</script>
