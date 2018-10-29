<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%  if (_model.Count() > 0)
    {
        var items = _model.GroupBy(i => i.GroupID);
        ;
        foreach (var g in items)
        {
            var itemList = g.ToArray();
            var assignment = itemList[0].InvoiceTrackCodeAssignment;
            var track = assignment.InvoiceTrackCode;
%>M,<%= String.Format("{0}{1:00}", track.Year - 1911, track.PeriodNo * 2) %>,<%= track.TrackCode %>,<%= itemList[itemList.Length-1].EndNo %>,<%= itemList[0].StartNo %>,07,<%= assignment.Organization.ReceiptNo %>
<%          for (int idx = 0; idx < itemList.Length; idx++)
            {
                var item = itemList[idx];
                assignment = item.InvoiceTrackCodeAssignment;
                track = assignment.InvoiceTrackCode;
                var org = assignment.Organization;
%>D,<%= org.ReceiptNo %>,<%= String.Format("{0:00000}",idx) %>,<%= org.TaxNo %>,<%= String.Format("{0:yyyyMMdd}",DateTime.Today) %>,<%= String.Format("{0}{1:00}", track.Year - 1911, track.PeriodNo * 2) %>,<%= track.TrackCode %>,<%= item.StartNo %>,<%= item.EndNo %>,<%= (item.EndNo-item.StartNo+1)/50 %>,07,<%= String.Format("{0:yyyyMMdd}",DateTime.Today) %>,<%= org.ReceiptNo %>
<%
            }
        }
    }
    else
    { %>
<script>alert('無資料可供下載!!');</script>
<%  } %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<InvoiceNoInterval> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<InvoiceNoInterval>)this.Model;

        if (_model.Count() > 0)
        {
            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.AddHeader("Cache-control", "max-age=1");
            Response.ContentType = "application/octet-stream";
            Response.AddHeader("Content-Disposition", String.Format("attachment;filename={0}", HttpUtility.UrlEncode("BranchNo_" + "(" + String.Format("{0:yyyy-MM-dd}",DateTime.Today) + ").csv")));
        }

    }

</script>
