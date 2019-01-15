<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<% if (_message != null)
    { %>
<div id="msgDialog" title="系統訊息" class="bg-color-darken">
    <div class="panel panel-default bg-color-darken">
        <%= _message %>
    </div>
    <script>
        $('#msgDialog').dialog({
            //autoOpen: false,
            resizable: true,
            modal: true,
            width: 640,
            height: "auto",
            closeText: "關閉",
            title: "<h4 class='modal-title'><i class='fa fa-fw fa-user-circle'></i>  系統訊息</h4>",
            buttons: [
                        {
                            text: "關閉",
                            "class": "btn btn-primary",
                            click: function () {
                                $(this).dialog("close");
                            }
                        }
            ],
            close: function (event, ui) {
                $('#msgDialog').remove();
            }
        });

        $('#btnSend').on('click', function (evt) {

            var form = $(this)[0].form;
            if (!validateForm(form))
                return false;

            $($(this)[0].form).ajaxSubmit({
                success: function (data) {
                    $(data).appendTo($('body'));
                }
            });
        });
    </script>
</div>

<%  } %>
<script runat="server">
    String _message;
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _message = (String)this.Model ?? (String)ViewBag.Message ?? Request["Message"];
    }

</script>
