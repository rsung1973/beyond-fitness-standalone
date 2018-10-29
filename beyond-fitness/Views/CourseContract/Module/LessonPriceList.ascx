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

<%  foreach (var item in _model)
    { %>
<option value="<%= item.PriceID %>" lowerLimit="<%= item.LowerLimit %>" upperBound="<%= item.UpperBound %>" listPrice="<%= String.Format("{0:##,###,###,###}",item.ListPrice) %>"><%= String.Format("{0,5:##,###,###,###}",item.ListPrice) %>元 /
    <%= item.SeriesID.HasValue 
            ? item.LowerLimit==1 
                ? "單堂"
                : item.LowerLimit + "堂"
            : item.Description %>
    <%= item.LessonPriceProperty.Any(p=>p.PropertyID==(int)Naming.LessonPriceFeature.舊會員續約) ? "(舊會員續約)" : null %>
</option>
<%  } %>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<LessonPriceType> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IQueryable<LessonPriceType>)this.Model;
    }

</script>
