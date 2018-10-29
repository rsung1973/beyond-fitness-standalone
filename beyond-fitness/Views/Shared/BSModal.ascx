<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<div class="modal fade" id="<%= this.ID %>" tabindex="-1" role="dialog" aria-labelledby="confirmLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <h3 class="modal-title" id="confirmLabel origan-text"><span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span>
                    <label></label>
                </h3>
            </div>
            <div class="modal-body text-center">
                <p>
                    <label></label>
                </p>
            </div>
            <div class="modal-footer">
                <button type="button" name="btnConfirm" class="btn btn-system btn-sm"><span class="glyphicon glyphicon-ok" aria-hidden="true"></span>確認</button>
                <button type="button" class="btn btn-default btn-sm" data-dismiss="modal"><span class="glyphicon glyphicon-log-out" aria-hidden="true"></span>取消</button>
            </div>
        </div>
    </div>
</div>
