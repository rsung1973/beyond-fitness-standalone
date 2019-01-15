<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<table class="table table-striped table-bordered table-hover" width="100%">
    <thead>
        <tr>
            <th><i class="fa fa-fw fa-certificate text-muted hidden-md hidden-sm hidden-xs"></i>證照名稱</th>
            <th><i class="fa fa-fw fa-calendar text-muted hidden-md hidden-sm hidden-xs"></i>到期日</th>
            <%  if (ViewBag.ViewOnly != true)
                { %>
            <th>功能</th>
            <%  } %>
        </tr>
    </thead>
    <tbody>
        <%  foreach (var item in _model)
            { %>
        <tr>
            <td><%= item.ProfessionalCertificate.Description %></td>
            <td><%= String.Format("{0:yyyy/MM/dd}",item.Expiration) %></td>
            <%  if (ViewBag.ViewOnly != true)
                { %>
            <td>
                <a onclick="deleteCertificate(<%= item.CertificateID %>);" class="btn btn-circle bg-color-red delete"><i class="fa fa-fw fa fa-lg fa-trash-alt" aria-hidden="true"></i></a>
            </td>
            <%  } %>
        </tr>
        <%  } %>
    </tbody>
</table>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IEnumerable<CoachCertificate> _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (IEnumerable<CoachCertificate>)this.Model;
    }

</script>
