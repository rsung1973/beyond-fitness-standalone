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
    <title>電子發票系統</title>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
    <%  String basePath = VirtualPathUtility.ToAbsolute("~/"); %>
    <script src="<%= basePath + "Scripts/jquery-2.1.4.min.js" %>"></script>
    <script src="<%= basePath + "js/plugin/StarWeb/StarBarcodeEncoder.js" %>"></script>
    <script src="<%= basePath + "js/plugin/StarWeb/StarWebPrintBuilder.js" %>"></script>
    <script src="<%= basePath + "js/plugin/StarWeb/StarWebPrintTrader.js" %>"></script>
</head>
<body>
    印表機IP:<input type="text" id="printerIP" /> <button type="button" onclick="printInvoice();">列印</button>
    <br />
    <canvas id="invCanvas" width="440" height="760" style="width:50%;"></canvas>
</body>
</html>
<script>

    function printInvoice() {
        UseIP = $('#printerIP').val();
        if (UseIP == '') {
            return;
        } else if (!$canvas) {
            return;
        }
        printCanvas($canvas[0]);
    }

    var $canvas;
    var LocalUrl = "";
    var UseIP = "";
    var SendCmd;
    var builder = new StarWebPrintBuilder();
    var CutCur_S = '\x1b\x64\x31';       //StarLine mode for Cutter @ current Poistion

    function renderInvoice(id) {
        //$canvas = $('<canvas>').attr('width', 400).attr('height', 760).appendTo($('body'));
        $canvas = $('#invCanvas');
        var canvas = $canvas[0];

        if (canvas.getContext) {
            var context = canvas.getContext('2d');

            var image = new Image();

            image.src = '<%= VirtualPathUtility.ToAbsolute("~/Invoice/DrawInvoice") + "?UID=" + _profile.UID %>' + '&InvoiceID=' + id;

            image.onload = function () {
                context.drawImage(image, 0, 0);
            }

            image.onerror = function () {
                alert('Image file was not able to be loaded.');
            }
        }
    }

    function printCanvas(canvas) {

        try {
            //document.getElementById('TxtPanel').value = "電子發票列印中,請稍候!!";
            //document.getElementById('BtPrtEInv').disabled = true;              //禁用按鍵        

            SendCmd = "";

            // 1.Printing Einvoce Top
            if (canvas.getContext) {
                var context = canvas.getContext('2d');

                SendCmd += builder.createInitializationElement();

                //SendCmd += builder.createLogoElement({ number: 1, width: 'single', height: 'single' });
                //var LogoSpace = "\x1b\x4a\x2c";    // 上紙到切紙位置（feed Dots)    
                //SendCmd += builder.createRawDataElement({ data: encodeEscapeSequence(LogoSpace) });
                SendCmd += builder.createBitImageElement({ context: context, x: 0, y: 0, width: canvas.width, height: canvas.height });

                var LogoSpace = "\x1b\x4a\x2c";    // 下移到切紙位置（feed 88Dots = 11mm)    
                SendCmd += builder.createRawDataElement({ data: encodeEscapeSequence(LogoSpace) });

                //------------------------------------------------------------------------
                // 5.Paper Cut
                // Type: full or partial
                // Feed: false or true         
                //SendCmd  += builder.createCutPaperElement({feed:false, type:'partial'});   
                SendCmd += builder.createRawDataElement({ data: encodeEscapeSequence(CutCur_S) });

                //-----------------------------------------------------------------------
                // Send Command to Printer
                SendMessage();
            }
        }
        catch (e) {
            alert(e.message);
        }

    }

    function encodeEscapeSequence(data) {
        var regexp = /\\[tnr\\]/g;

        if (regexp.test(data)) {
            data = data.replace(regexp, function (match) {
                switch (match) {
                    case '\\t': return '\\x09';
                    case '\\n': return '\\x0a';
                    case '\\r': return '\\x0d';
                }

                return '\\x5c';
            });
        }

        var regexp = /\\[Xx][0-9A-Fa-f]{2}/g;

        if (regexp.test(data)) {
            data = data.replace(regexp, function (match) {
                return String.fromCharCode(parseInt(match.slice(2), 16));
            });
        }

        return data;
    }

    function SendMessage() {

        LocalUrl = 'http://' + UseIP + '/StarWebPRNT/SendMessage';

        var trader = new StarWebPrintTrader({ url: LocalUrl });

        trader.onReceive = function (response) {
            var Pmsg = ' 傳送完成(OnLine)\n'
            if (response.traderSuccess == 'false') { Pmsg = ' 傳送失敗,印表機離線中(OffLine)\n' }
            if (trader.isCoverOpen({ traderStatus: response.traderStatus })) { Pmsg += '\t上蓋打開' }
            //if (trader.isOffLine({traderStatus:response.traderStatus})) { Pmsg += '\t離線中'}
            if (trader.isCompulsionSwitchClose({ traderStatus: response.traderStatus })) { Pmsg += '\t錢箱已打開' }
            if (trader.isEtbCommandExecute({ traderStatus: response.traderStatus })) { Pmsg += '\tETB指令執行中' }
            if (trader.isHighTemperatureStop({ traderStatus: response.traderStatus })) { Pmsg += '\t印字頭過熱停止' }
            if (trader.isNonRecoverableError({ traderStatus: response.traderStatus })) { Pmsg += '\t不可恢復的故障發生' }
            if (trader.isAutoCutterError({ traderStatus: response.traderStatus })) { Pmsg += '\t裁刀錯誤' }
            if (trader.isBlackMarkError({ traderStatus: response.traderStatus })) { Pmsg += '\t黑標偵測錯誤' }
            if (trader.isPaperEnd({ traderStatus: response.traderStatus })) { Pmsg += '\t缺紙錯誤' }
            if (trader.isPaperNearEnd({ traderStatus: response.traderStatus })) { Pmsg += '\t紙張不足警告' }

            $('<div style="color:blue;"></div>').text(Pmsg).insertAfter($canvas);
            //document.getElementById('TxtPanel').value = Pmsg;
            //document.getElementById('BtPrtEInv').disabled = false;              //禁用按鍵                           
        }

        trader.onError = function (response) {
            var Pmsg = ' 傳送錯誤\n';
            Pmsg += '\t無法傳送資料到 IP=' + UseIP + ' 印表機，請檢查印表機！';

            $('<div style="color:red;"></div>').text(Pmsg).insertAfter($canvas);
            //document.getElementById('TxtPanel').value = Pmsg;
            //document.getElementById('BtPrtEInv').disabled = false;              //禁用按鍵                
        }

        trader.sendMessage({ request: SendCmd });

    }


    $(function () {

    <%  foreach (var item in _model)
        {   %>
        renderInvoice(<%= item.InvoiceID %>);
    <%  }   %>

    });
</script>

<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    IQueryable<InvoiceItem> _model;
    InvoiceQueryViewModel _viewModel;
    UserProfile _profile;


    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (IQueryable<InvoiceItem>)this.Model;
        _viewModel = (InvoiceQueryViewModel)ViewBag.ViewModel;
        _profile = Context.GetUser();
    }

</script>
