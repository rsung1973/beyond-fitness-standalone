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
<table class="table table-striped table-bordered table-hover" width="100%">
    <thead>
        <tr>
            <th>收款項目</th>
            <th class="text-center">退件（作廢）</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <%  var paymentItems = _auditItems.Where(a => a.Payment.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費);
                var voidItemsToConfirm = _voidItemsToConfirm.Where(a => a.Payment.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費);
                var editingVoidItems = _editingVoidItems.Where(a => a.Payment.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費);   %>
            <td>體能顧問費(<%= paymentItems.Count()+voidItemsToConfirm.Count()+editingVoidItems.Count() %>)</td>
            <td class="text-center">
                <%  
                    if (editingVoidItems.Count() > 0)
                    {   %>
                <a onclick="showVoidPaymentToEdit(<%= (int)Naming.PaymentTransactionType.體能顧問費 %>);"><u>(<%= editingVoidItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                    --
                <%  } %></td>
        </tr>
        <tr>
            <%  paymentItems = _auditItems.Where(a => a.Payment.TransactionType == (int)Naming.PaymentTransactionType.自主訓練);
                voidItemsToConfirm = _voidItemsToConfirm.Where(a => a.Payment.TransactionType == (int)Naming.PaymentTransactionType.自主訓練);
                editingVoidItems = _editingVoidItems.Where(a => a.Payment.TransactionType == (int)Naming.PaymentTransactionType.自主訓練);   %>
            <td>自主訓練(<%= paymentItems.Count()+voidItemsToConfirm.Count()+editingVoidItems.Count() %>)</td>
            <td class="text-center">
                <%  
                    if (editingVoidItems.Count() > 0)
                    {   %>
                <a onclick="showVoidPaymentToEdit(<%= (int)Naming.PaymentTransactionType.自主訓練 %>);"><u>(<%= editingVoidItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                    --
                <%  } %></td>
        </tr>
        <tr>
            <%  paymentItems = _auditItems.Where(a => a.Payment.TransactionType == (int)Naming.PaymentTransactionType.飲品);
                voidItemsToConfirm = _voidItemsToConfirm.Where(a => a.Payment.TransactionType == (int)Naming.PaymentTransactionType.飲品);
                editingVoidItems = _editingVoidItems.Where(a => a.Payment.TransactionType == (int)Naming.PaymentTransactionType.飲品);   %>
            <td>飲品(<%= paymentItems.Count()+voidItemsToConfirm.Count()+editingVoidItems.Count() %>)</td>
            <td class="text-center">
                <%  
                    if (editingVoidItems.Count() > 0)
                    {   %>
                <a onclick="showVoidPaymentToEdit(<%= (int)Naming.PaymentTransactionType.飲品 %>);"><u>(<%= editingVoidItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                    --
                <%  } %></td>
        </tr>
        <tr>
            <%  paymentItems = _auditItems.Where(a => a.Payment.TransactionType == (int)Naming.PaymentTransactionType.運動商品);
                voidItemsToConfirm = _voidItemsToConfirm.Where(a => a.Payment.TransactionType == (int)Naming.PaymentTransactionType.運動商品);
                editingVoidItems = _editingVoidItems.Where(a => a.Payment.TransactionType == (int)Naming.PaymentTransactionType.運動商品);   %>
            <td>運動商品(<%= paymentItems.Count()+voidItemsToConfirm.Count()+editingVoidItems.Count() %>)</td>
            <td class="text-center">
                <%  
                    if (editingVoidItems.Count() > 0)
                    {   %>
                <a onclick="showVoidPaymentToEdit(<%= (int)Naming.PaymentTransactionType.運動商品 %>);"><u>(<%= editingVoidItems.Count() %>)</u></a>
                <%  }
                    else
                    { %>
                    --
                <%  } %></td>
        </tr>
    </tbody>
</table>

<script>
    function showPaymentToAudit(transactionType) {
        showLoading();
        $.post('<%= Url.Action("AuditPayment","Payment") %>', { 'transactionType': transactionType }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }

    function showVoidPaymentToConfirm(transactionType) {
        showLoading();
        $.post('<%= Url.Action("ApproveToVoidPayment","Payment") %>', { 'transactionType': transactionType }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }

    function showVoidPaymentToEdit(transactionType) {
        showLoading();
        $.post('<%= Url.Action("EditToVoidPayment","Payment") %>', { 'transactionType': transactionType }, function (data) {
            hideLoading();
            $(data).appendTo($('body'));
        });
    }
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    IQueryable<PaymentAudit> _auditItems;
    IQueryable<VoidPayment> _voidItemsToConfirm;
    IQueryable<VoidPayment> _editingVoidItems;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        var profile = Context.GetUser();

        _auditItems = models.GetPaymentToAuditByAgent(profile);
        _voidItemsToConfirm = models.GetVoidPaymentToApproveByAgent(profile);
        _editingVoidItems = models.GetVoidPaymentToEditByAgent(profile);
    }

</script>
