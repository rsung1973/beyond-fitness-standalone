<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>


<td nowrap="noWrap">
    <%  if (_model.InvoiceID.HasValue)
        {   %>
            <%= _model.InvoiceItem.TrackCode %><%= _model.InvoiceItem.No %>
    <%  } %>
</td>
<td><%= _model.PaymentTransaction.BranchStore.BranchName %></td>
<td ><%= _model.UserProfile.FullName() %></td>
<td ><%= _model.TuitionInstallment != null
            ? _model.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName()
            : _model.ContractPayment != null
                ? _model.ContractPayment.CourseContract.CourseContractType.IsGroup == true
                    ? String.Join("/", _model.ContractPayment.CourseContract.CourseContractMember.Select(m => m.UserProfile).ToArray().Select(u => u.FullName()))
                    : _model.ContractPayment.CourseContract.ContractOwner.FullName()
                : "--" %></td>
<td nowrap="noWrap"><%= String.Format("{0:yyyy/MM/dd}", _model.PayoffDate) %></td>
<td nowrap="noWrap"><%= _model.InvoiceID.HasValue ? String.Format("{0:yyyy/MM/dd}", _model.InvoiceItem.InvoiceDate) : null %></td>
<td nowrap="noWrap">
    <%  if (_model.InvoiceItem.InvoiceCancellation != null && _model.VoidPayment!=null)
        { %>
    <%= String.Format("{0:yyyy/MM/dd}", _model.InvoiceItem.InvoiceCancellation.CancelDate) %>
    <%  }
        else if (_model.InvoiceAllowance!=null)
        {   %>
    <%= String.Format("{0:yyyy/MM/dd}", _model.InvoiceAllowance.AllowanceDate) %>
    <%  } %>
</td>
<td><%= ((Naming.PaymentTransactionType)_model.TransactionType).ToString() %>
    <%  if (_model.TransactionType == (int)Naming.PaymentTransactionType.運動商品
            || _model.TransactionType == (int)Naming.PaymentTransactionType.飲品)
        { %>
    (<%= String.Join("、", _model.PaymentTransaction.PaymentOrder.Select(p => p.MerchandiseWindow.ProductName)) %>)
    <%  } %>
</td>
<td nowrap="noWrap" class="text-right"><%= _model.PayoffAmount >= 0 ? String.Format("{0:##,###,###,###}", _model.PayoffAmount) : String.Format("({0:##,###,###,###})", -_model.PayoffAmount) %></td>
<td nowrap="noWrap" class="text-right"><%= _model.InvoiceID.HasValue
                                               ? _model.InvoiceItem.InvoiceBuyer.IsB2C()
                                                    ? String.Format("{0:##,###,###,###}", _model.InvoiceItem.InvoiceAmountType.TotalAmount)
                                                    : String.Format("{0:##,###,###,###}", _model.InvoiceItem.InvoiceAmountType.SalesAmount)
                                               : null %></td>
<td nowrap="noWrap" class="text-right"><%= _model.InvoiceID.HasValue
                                               ? _model.InvoiceItem.InvoiceBuyer.IsB2C()
                                                    ? null
                                                    : String.Format("{0:##,###,###,###}", _model.InvoiceItem.InvoiceAmountType.TaxAmount)
                                               : null %></td>
<td nowrap="noWrap" class="text-right">
    <%  if (_model.InvoiceItem.InvoiceCancellation != null && _model.VoidPayment!=null)
        { %>
    <%= String.Format("{0:##,###,###,###}", _model.PayoffAmount) %>
    <%  }
        else if (_model.InvoiceAllowance!=null)
        {   %>
    <%= String.Format("{0:##,###,###,###}", _model.InvoiceAllowance.TotalAmount+_model.InvoiceAllowance.TaxAmount) %>
    <%  } %>
</td>
<td nowrap="noWrap" class="text-right">
    <%  if (_model.InvoiceAllowance!=null)
        {   %>
    <%= String.Format("{0:##,###,###,###}", _model.InvoiceAllowance.TotalAmount) %>
    <%  } %>
</td>
<td><%= _model.PaymentType %></td>
<td><%= _model.InvoiceID.HasValue
            ? _model.InvoiceItem.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票
                ? "電子"
                : "紙本"
            : "--" %></td>
<td>
    <%  if (_model.InvoiceItem.InvoiceCancellation != null && _model.VoidPayment!=null)
        { %>
    已作廢
    <%  }
        else if (_model.InvoiceAllowance!=null)
        {   %>
    已折讓
    <%  }
        else
        { %>
    已開立
    <%  } %>
</td>
<td><%= _model.InvoiceID.HasValue
            ? _model.InvoiceItem.InvoiceBuyer.IsB2C() ? "--" : _model.InvoiceItem.InvoiceBuyer.ReceiptNo
            : "--" %></td>
<td nowrap="noWrap">
    <%  if (_model.ContractPayment != null)
        { %>
            <%= _model.ContractPayment.CourseContract.ContractNo() %>
    <%  } %>
</td>
<td nowrap="noWrap" class="text-right">
    <%  if (_model.ContractPayment != null)
        { %>
    <%= String.Format("{0:##,###,###,###}", _model.ContractPayment.CourseContract.TotalCost) %>
    <%  }
        else
        { %>
    --
    <%  } %>
</td>
<td>
    <%  if (_model.VoidPayment != null)
        { %>
    <%= _model.VoidPayment.Remark %>
    <%  }
        else if (_model.InvoiceAllowance!=null)
        { %>
    <%= _model.InvoiceAllowance.InvoiceAllowanceDetails.First().InvoiceAllowanceItem.Remark %>
    <%  }
        else
        { %>
    <%= _model.Remark %>
    <%  } %>
</td>
<td><%  if (_model.VoidPayment != null)
        { %>
            <%= (Naming.CourseContractStatus)_model.VoidPayment.Status %>
    <%  }
        else
        { %>
            <%= (Naming.CourseContractStatus)_model.Status %>
            <%= _model.PaymentAudit != null && _model.PaymentAudit.AuditorID.HasValue ? "" : "(*)" %>
    <%  } %>
</td>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    Payment _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (Payment)this.Model;
    }

</script>
