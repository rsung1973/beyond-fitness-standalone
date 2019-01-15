<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="modal fade" id="<%= ViewBag.ModalId ?? "theModal" %>" tabindex="-1" role="dialog" aria-labelledby="confirmLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
        <%  if (ViewBag.Argument is ArgumentModel)
            {
                Html.RenderPartial(((ArgumentModel)ViewBag.Argument).PartialViewName, ((ArgumentModel)ViewBag.Argument).Model);
            } %>
        </div>
    </div>
</div>
<script>

    $(function () {
        var $modal = $('#<%= ViewBag.ModalId ?? "theModal" %>');
        $modal.appendTo($('body'));
        $modal.on('hidden.bs.modal', function (evt) {
            $modal.remove();
        });

        //$modal.on('shown.bs.modal', function () {
        //    $(this).find('.modal-dialog').css({
        //        width: 'auto',
        //        height: 'auto',
        //        'max-height': '100%'
        //    });
        //});

        $modal.modal('show');
    });
</script>