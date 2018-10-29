<%@ Page Title="" Language="C#" Inherits="System.Web.Mvc.ViewPage" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <style type="text/css">
        div.fspace {
            /*height: 8.8cm;*/
        }

        div.bspace {
            /*height: 8.9cm;*/
        }

        body, td, th {
            /*font-family: Verdana, Arial, Helvetica, sans-serif, "細明體", "新細明體";*/
        }

        body {
            margin: 0px;
            margin-left: 0cm;
            margin-right: 0cm;
            padding: 0px;
            /*font-family: "Arial", "Verdana","Helvetica", "sans-serif", "細明體", "新細明體";*/
        }

        .container {
            display: block;
            /*width: 100%;*/
            /*height: 9.4cm;*/
            border-top: 1px dotted #999;
            border-bottom: 1px dotted #999;
            padding-top: 0.3cm;
        }

            .container .cutfield {
                border: 1px dashed #808080;
                display: block;
                /*width: 5.7cm;*/
                /*height: 9cm;*/
                overflow: hidden;
                float: left;
            }

                .container .cutfield h2 {
                    font-size: 50px;
                    line-height: 1;
                    letter-spacing: -1px;
                    /*text-align: center;*/
                    padding: -10px 0 -10px 0;
                    margin-left: 5px;
                    margin-top: 0;
                    margin-right: 0;
                    margin-bottom: 0;
                }

                .container .cutfield h3 {
                    /*width: 5.2cm;*/
                    font-size: 40px;
                    line-height: 1.4;
                    text-align: center;
                    padding: 0;
                    padding-top: 1cm;
                    padding-bottom: 0.2cm;
                    margin: 0 auto;
                }

                    .container .cutfield h3.notop {
                        font-size: 12pt;
                        line-height: 1.4;
                        text-align: center;
                        padding: 0;
                        padding-top: 5px;
                        padding-bottom: 0px;
                        margin: 0;
                    }

                .container .cutfield p {
                    font-size: 26px;
                    line-height: 1.2;
                    padding: 0;
                    padding-top: -5px;
                    padding-left: 0.1cm;
					padding-bottom: -5px;
                    padding-right: 0.2cm;
                    margin: 0px 0px 0px 0px;
                }
				
				.container .logo {
					margin-top: -10px;
					padding-top: -10px;
				}

                    .container .cutfield p.sign {
                        font-size: 10pt;
                        line-height: 1.5;
                        padding: 0;
                        padding-top: 2px;
                        padding-bottom: 2px;
                        padding-left: 0.2cm;
                        padding-right: 0.2cm;
                        margin: 0;
                        border-top: 1px dashed #808080;
                        border-bottom: 1px dashed #808080;
                    }

                    .container .cutfield p.rule1 {
                        font-size: 9pt;
                    }

                    .container .cutfield p.rule {
                        font-size: 9pt;
                        padding: 0;
                        padding-top: 2px;
                        padding-bottom: 2px;
                        padding-left: 0.2cm;
                        padding-right: 0.2cm;
                        margin: 0;
                        margin-left: 2em;
                        text-indent: -2em;
                    }

                .container .cutfield .code1 {
                    text-align: center;
                    padding: 0;
                    padding-top: 0.2cm;
                    margin: 0;
                }

                .container .cutfield .code2 {
                    text-align: center;
                    padding: 0;
                    padding-top: 0.3cm;
                    margin: 0;
                }

                    .container .cutfield .code2 img {
                        /*margin: 0 0.6cm 0 0.6cm;*/
                        border: none;
                    }
        /*交易明細*/
		.listfield {
			font-size: 26px;
		}
		
        div.listfield {
            /*display:block;*/
            /*width: 720px;*/
            /*height:400px;*/
            margin-left: 0.1cm;
            padding: 0;
            /*overflow: hidden;*/
            /*float:left;*/
            /*-moz-column-count:2;*/ /* Firefox */
            /*-webkit-column-count:2;*/ /* Safari and Chrome */
            /*column-count:2;*/
            -moz-column-gap: 6px; /* Firefox */
            -webkit-column-gap: 6px; /* Safari and Chrome */
            column-gap: 6px;
            -moz-column-rule: 1px solid #999; /* Firefox */
            -webkit-column-rule: 1px solid #999; /* Safari and Chrome */
            column-rule: 1px solid #999;
        }

        .listfield .content_box {
            /*clear:both;*/
            /*width:240px;*/
            display: inline-block;
            padding: 2px 0px;
            margin: 0;
            /*overflow:hidden;*/
            font-size: 8pt;
            line-height: 1.5;
        }

            .listfield .content_box p.productname {
                /*width: 280px;*/
                display: inline-block;
                float: left;
            }

            .listfield .content_box p.quantity {
                /*width: 50px;*/
                display: inline-block;
                text-align: right;
                float: left;
            }

            .listfield .content_box p.price {
                /*width: 140px;*/
                display: inline-block;
                text-align: right;
                float: left;
            }

            .listfield .content_box p.totalPrice {
                /*width: 100px;*/
                display: inline-block;
                text-align: right;
                /*margin-left: 6px;*/
                float: right;
            }

        .listfield h3 {
            font-size: 12pt;
            line-height: 1.4;
            text-align: left;
            padding: 0.2cm 0.3cm;
            margin: 0;
        }

        .listfield p {
            /*font-size:10pt;*/
            line-height: 1.4;
            padding: 0;
            padding-top: 0.1cm;
            padding-left: 0.2cm;
            padding-right: 0.2cm;
            margin: 0;
        }

        /***共用***/
        .company .title {
            margin: 0px;
            padding: 0px;
            font-size: 15pt;
            font-family: 標楷體;
            font-weight: normal;
        }

        .company p {
            margin: 0px;
            padding: 0px;
            font-size: 9pt;
            font-family: 標楷體;
        }

        .customer {
            margin: 80px 0px 0px 180px;
            padding: 0px;
            color: #000;
        }

            .customer .title {
                margin: 0px;
                padding: 0px;
                font-size: 15pt;
                font-family: 標楷體;
            }

            .customer p {
                margin: 0px;
                padding: 0px;
                font-size: 15pt;
                font-family: 標楷體;
            }

        #barcode {
            width: 350px;
            height: 50px;
        }

        .qrcode {
            width: 160px;
            height: 160px;
        }
    </style>
    <title>電子發票系統</title>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
</head>
<body>
    <script type="text/javascript" src="<%= VirtualPathUtility.ToAbsolute("~/js/css3-multi-column.js") %>"></script>
    <%  foreach (var item in _model)
        {
            Html.RenderPartial("~/Views/Invoice/Module/InvoiceCanvasView.ascx", item);
        }

        if (_viewModel.UID.HasValue)
        {
            foreach (var i in _model)
            {
                models.GetTable<DocumentPrintLog>().InsertOnSubmit(new DocumentPrintLog
                {
                    DocID = i.InvoiceID,
                    PrintDate = DateTime.Now,
                    UID = _viewModel.UID.Value
                });
            }
            models.SubmitChanges();
            models.ExecuteCommand("delete DocumentPrintQueue where UID={0}", _viewModel.UID);
        }   %>
</body>
</html>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    IQueryable<InvoiceItem> _model;
    InvoiceQueryViewModel _viewModel;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (IQueryable<InvoiceItem>)this.Model;
        _viewModel = (InvoiceQueryViewModel)ViewBag.ViewModel;
        ViewBag.Canvas = true;
    }

</script>
