<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%--<script>
    var $currentModal;
    $(function () {
        $('input[type="button"]').addClass('btn');
        //$('form').on('submit', function () {
        //    var $currentModal = showLoadingModal();
        //});
    });
</script>--%>
<%--<asp:PlaceHolder ID="plScript" runat="server">
    <script>
        function showInvoiceModal(docID) {
            var element = event.target;
            $.post('<%= VirtualPathUtility.ToAbsolute("~/Helper/ShowInvoiceModal.aspx")%>', 'docID=' + docID, function (html) {
                //            $(element).after($(html).find("#mainContent"));
                $(html).find("#mainContent").dialog({
                    width : 640,
                    buttons: [
                        {
                            text: "關閉",
                            icons: {
                                primary: "ui-icon-close"
                            },
                            click: function () {
                                $(this).dialog("close");
                            }
                        }
                    ]
                });
            });
        }

        function showAllowanceModal(docID) {
            var element = event.target;
            $.post('<%= VirtualPathUtility.ToAbsolute("~/Helper/ShowAllowanceModal.aspx")%>', 'docID=' + docID, function (html) {
                $(html).find("#mainContent").dialog({
                    width: 640,
                    buttons: [
                        {
                            text: "關閉",
                            icons: {
                                primary: "ui-icon-close"
                            },
                            click: function () {
                                $(this).dialog("close");
                            }
                        }
                    ]
                });
            });
        }

        function showLoadingModal() {
            var $body = $('body');
            //var $modal = $('<div style="position: absolute;top: 0;left: 0;z-index: 1000;width: 100%;opacity: 0.5;filter: Alpha(opacity=50);background: gray;"><img src="<%= VirtualPathUtility.ToAbsolute("~/images/loading.gif") %>" style="position: absolute;top:0;left:0;right:0;bottom:0;margin:auto;max-height:100%;max-width:100%;"></div>');
            var $modal = $('<div style="position: absolute;top: 0;left: 0;z-index: 1000;width: 100%;opacity: 0.5;filter: Alpha(opacity=50);background: gray;"><img src="<%= VirtualPathUtility.ToAbsolute("~/images/loading.gif") %>" style="position: absolute;"></div>');
            var $img = $modal.find('img');
            $modal.css('height', $body.css('height'));
            $img.css('top', $body.scrollTop() + screen.height / 2 - 48);
            $img.css('left', screen.width / 2 - 24);
            $body.append($modal);
            return $modal;
        }
    </script>
</asp:PlaceHolder>--%>
<script runat="server">
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);

        UserControl script = (UserControl)this.LoadControl("CommonScriptInclude.ascx");
        Page.Header.Controls.Add(script);
        
    }
</script>