<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Utility" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>Invoice No:
        <textarea cols="80" rows="10" name="invoiceNo"><%= Request["invoiceNo"] %></textarea><br />
            Track Code:<input type="text" name="trackCode" value="<%= Request["trackCode"] %>" />
            No: <input type="text" name="startNo" value="<%= Request["startNo"] %>" /> ~ 
            <input type="text" name="endNo" value="<%= Request["endNo"] %>" />            
            <asp:Button ID="btnCreate" runat="server" Text="OK!!" />
        </div>
        <br />
        C0401:
        <textarea cols="80" rows="10"><%= _item!=null ? _item.ConvertToXml().OuterXml : null %></textarea>
        <br />
        C0701:
                <textarea cols="80" rows="10"><%= _voidItem!=null ? _voidItem.ConvertToXml().OuterXml : null %></textarea>
    </form>
</body>
</html>
<script runat="server">

    protected WebHome.Models.MIG3_1.C0401.Invoice _item;
    protected WebHome.Models.MIG3_1.C0701.VoidInvoice _voidItem;
    ModelSource<UserProfile> models;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        using (models = new ModelSource<UserProfile>())
        {
            doTask();
        }
    }

    void doTask()
    {

        String invoiceNo = Request["invoiceNo"].GetEfficientString();
        String trackCode = Request["trackCode"].GetEfficientString();
        String startNo = Request["startNo"].GetEfficientString();
        String endNo = Request["endNo"].GetEfficientString();

        if(invoiceNo!=null)
        {
            if (invoiceNo.Length == 10)
            {
                var item = models.GetTable<InvoiceItem>().Where(i => i.TrackCode == invoiceNo.Substring(0, 2)
                    && i.No == invoiceNo.Substring(2)).FirstOrDefault();
                if (item != null)
                {
                    _item = item.CreateC0401();
                    _voidItem = new WebHome.Models.MIG3_1.C0701.VoidInvoice
                    {
                        VoidInvoiceNumber = invoiceNo,
                        InvoiceDate = String.Format("{0:yyyyMMdd}", item.InvoiceDate),
                        BuyerId = item.InvoiceBuyer.ReceiptNo,
                        SellerId = item.InvoiceSeller.ReceiptNo,
                        VoidDate = DateTime.Now.Date.ToString("yyyyMMdd"),
                        VoidTime = DateTime.Now,
                        VoidReason = "註銷重開",
                        Remark = ""
                    };
                }
            }
            else
            {
                String storedPath = Path.Combine(Logger.LogDailyPath, "MIG");
                storedPath.CheckStoredPath();

                String[] items = invoiceNo.Split(new String[] { "\r\n", ",", ";", "、" }, StringSplitOptions.RemoveEmptyEntries);
                foreach (var invNo in items)
                {
                    if (invNo.Length != 10)
                        break;
                    var item = models.GetTable<InvoiceItem>().Where(i => i.TrackCode == invNo.Substring(0, 2)
                        && i.No == invNo.Substring(2)).FirstOrDefault();
                    if (item != null)
                    {
                        storedMIG(item, storedPath);
                    }
                }
            }
        }
        else if(trackCode!=null)
        {
            System.Linq.Expressions.Expression<Func<InvoiceItem, bool>> queryExpr = i => i.TrackCode == Request["trackCode"];
            bool hasNo = false;
            if(startNo!=null)
            {
                queryExpr = queryExpr.And(i => String.Compare(i.No, startNo) >= 0);
                hasNo = true;
            }
            if (endNo != null)
            {
                queryExpr = queryExpr.And(i => String.Compare(i.No, endNo) <= 0);
                hasNo = true;
            }
            if(hasNo)
            {
                var items = models.GetTable<InvoiceItem>().Where(queryExpr);
                var count = items.Count();
                if (count > 0)
                {
                    //this.AjaxAlert("送出執行註銷筆數:" + count);
                    var dataItem = items.Select(i => i.InvoiceID).ToArray();
                    System.Threading.ThreadPool.QueueUserWorkItem(t =>
                    {
                        using (ModelSource<InvoiceItem> currMgr = new ModelSource<InvoiceItem>())
                        {
                            String storedPath = Path.Combine(Logger.LogDailyPath, "MIG");
                            storedPath.CheckStoredPath();
                            foreach (var id in dataItem)
                            {
                                var item = currMgr.GetTable<InvoiceItem>().Where(i => i.InvoiceID == id).FirstOrDefault();
                                if (item != null)
                                {
                                    try
                                    {
                                        storedMIG(item, storedPath);
                                        currMgr.ExecuteCommand(@"DELETE FROM CDS_Document
                                            FROM    DerivedDocument INNER JOIN
                                                    CDS_Document ON DerivedDocument.DocID = CDS_Document.DocID
                                            WHERE   (DerivedDocument.SourceID = {0})", item.InvoiceID);
                                        currMgr.ExecuteCommand("delete CDS_Document where DocID={0}", item.InvoiceID);
                                    }
                                    catch(Exception ex)
                                    {
                                        Logger.Error(ex);
                                    }
                                }
                            }
                        }
                    });
                }

            }
        }

    }

    void storedMIG(InvoiceItem item,String storedPath)
    {
        String invoiceNo = item.TrackCode + item.No;
        String C0701Outbound = Path.Combine(WebHome.Properties.Settings.Default.EINVTurnKeyPath, "C0701", "SRC");
        if (!Directory.Exists(C0701Outbound))
        {
            Directory.CreateDirectory(C0701Outbound);
        }

        item.CreateC0401().ConvertToXml().Save(Path.Combine(storedPath, "C0401_" + invoiceNo + ".xml"));
        (new WebHome.Models.MIG3_1.C0701.VoidInvoice
        {
            VoidInvoiceNumber = invoiceNo,
            InvoiceDate = String.Format("{0:yyyyMMdd}", item.InvoiceDate),
            BuyerId = item.InvoiceBuyer.ReceiptNo,
            SellerId = item.InvoiceSeller.ReceiptNo,
            VoidDate = DateTime.Now.Date.ToString("yyyyMMdd"),
            VoidTime = DateTime.Now,
            VoidReason = "註銷重開",
            Remark = ""
        }).ConvertToXml().Save(Path.Combine(C0701Outbound, "C0701_" + item.TrackCode + item.No + ".xml"));

    }


</script>
