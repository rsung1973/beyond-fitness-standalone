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

<tr>
    <td nowrap="noWrap"><%= _model.ContractNo() %></td>
    <td nowrap="noWrap"><%= _model.CourseContractRevision!=null ? _model.CourseContractRevision.SourceContract.CourseContractExtension.BranchStore.BranchName : _model.CourseContractExtension.BranchStore.BranchName %></td>
    <td><%= _model.ServingCoach.UserProfile.FullName() %></td>
    <td>
        <%  if (_model.CourseContractType.IsGroup==true)
            { %>
        <%= String.Join("/",_model.CourseContractMember.Select(m=>m.UserProfile).ToArray().Select(u=>u.FullName())) %>
        <%  }
            else
            { %>
        <%= _model.ContractOwner.FullName() %>
        <%  } %>
    </td>
    <td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", _model.EffectiveDate) %></td>
    <td><%= _model.CourseContractType.TypeName %>(<%= _model.LessonPriceType.DurationInMinutes %>分鐘)</td>
    <td><%= $"{_model.PayoffDue:yyyy/MM/dd}" %></td>
    <td><%  if (_model.SequenceNo == 0)
            { %>
        <%= _model.Status == (int)Naming.CourseContractStatus.已生效 ? _model.RemainedLessonCount().ToString() : "--" %>/<%= _model.Lessons %>
        <%  }
            else
            { %>
                --/--
        <%  } %>
    </td>
    <td nowrap="noWrap" class="text-right"><%= _model.Status>=(int)Naming.CourseContractStatus.已生效 ? String.Format("{0:##,###,###,###}",_model.TotalCost) : "--" %></td>
    <td nowrap="noWrap" class="text-right"><%  var revision = _model.CourseContractRevision; %>
        <%  if(revision==null)
            { %>
        <%= String.Format("{0:##,###,###,###}",_model.TotalPaidAmount()) %>
        <%  } %>
    </td>
    <td>
        <%= revision==null ? "新合約" : revision.Reason %></td>
    <td nowrap="noWrap">
        <%  if (revision == null)
            {   %>
        <%= ((Naming.ContractQueryStatus)_model.Status).ToString() %>
        <%= _model.Expiration.HasValue && _model.Expiration.Value < DateTime.Today ? "(*)" : null %>
        <%  }
            else
            {   %>
        <%= ((Naming.ContractServiceStatus)_model.Status).ToString() %>
        <%  } %>
    </td>
    <td nowrap="noWrap">
        <%  if(revision==null)
                    {   %>
        <a onclick="$global.viewContract(<%= _model.ContractID %>);" class="btn btn-circle bg-color-yellow modifyPersonalContractDialog_link"><i class="fa fa-fw fa fa-lg fa-binoculars" aria-hidden="true"></i></a>
        <%  if (_model.Status > (int)Naming.CourseContractStatus.待審核 && _model.ContractID>1045)
                        { %>
        <a href="<%= Url.Action("GetContractPdf","CourseContract",new { _model.ContractID }) %>" target="_blank" class="btn btn-circle bg-color-green"><i class="far fa-fw fa-lg fa-file-pdf" aria-hidden="true"></i></a>
        <%  }
                        else
                        { %>
        <%  }
                    }
                    else
                    {
                        if (_model.Status > (int)Naming.CourseContractStatus.待審核)
                        { %>
        <a href="<%= Url.Action("GetContractAmendmentPdf","CourseContract",new { revision.RevisionID }) %>" target="_blank" class="btn btn-circle bg-color-green"><i class="far fa-fw fa-lg fa-file-pdf" aria-hidden="true"></i></a>
        <%  }
                        else
                        { %>
        <a href="<%= Url.Action("ViewContractAmendment","CourseContract",new { revision.RevisionID }) %>" target="_blank" class="btn btn-circle bg-color-yellow"><i class="fa fa-fw fa fa-lg fa-binoculars" aria-hidden="true"></i></a>
        <%  }
                    }   %>
    </td>
</tr>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContract _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
    }

</script>
