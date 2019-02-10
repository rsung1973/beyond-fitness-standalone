<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%  String basePath = VirtualPathUtility.ToAbsolute("~/"); %>

<!-- Link to Google CDN's jQuery + jQueryUI; fall back to local -->
<script src="<%= basePath + "Scripts/jquery-2.1.4.min.js" %>"></script>
<script src="<%= basePath + "Scripts/jquery-ui-1.10.3.min.js" %>"></script>
<script src="<%= basePath + "Scripts/jquery.scrollUp.min.js" %>"></script>
<!-- JQUERY VALIDATE -->
<script src="<%= basePath + "js/plugin/jquery-validate/jquery.validate.min.js" %>"></script>
<script src="<%= basePath + "js/jquery.form.js" %>"></script>
<script src="<%= basePath + "js/bootstrap-datetimepicker.js" %>"></script>
<script src="<%= basePath + "js/plugin/bootstrap-datetimepicker/locales/bootstrap-datetimepicker.zh-TW.js" %>"></script>
<script src="<%= basePath + "js/plugin/datatables/jquery.dataTables.min.js" %>"></script>
<script src="<%= basePath + "js/plugin/datatables/dataTables.colVis.min.js" %>"></script>
<script src="<%= basePath + "js/plugin/datatables/dataTables.tableTools.min.js" %>"></script>
<script src="<%= basePath + "js/plugin/datatables/dataTables.bootstrap.min.js" %>"></script>
<script src="<%= basePath + "js/plugin/datatable-responsive/datatables.responsive.min.js" %>"></script>
<script src="<%= basePath + "js/plugin/moment/moment.min.js" %>"></script>
<script src="<%= basePath + "js/plugin/fullcalendar/jquery.fullcalendar.min.js" %>"></script>
<script src="<%= basePath + "js/plugin/fullcalendar/lang-all.js" %>"></script>
<script src="<%= basePath + "js/plugin/jquery-blockui/jquery.blockUI.js" %>"></script>
<script src="<%= basePath + "js/plugin/jquery-nestable/jquery.nestable.min.js" %>"></script>

<!-- PACE LOADER - turn this on if you want ajax loading to show (caution: uses lots of memory on iDevices)-->
<%--<script data-pace-options='{ "restartOnRequestAfter": true }' src="<%= basePath + "js/plugin/pace/pace.min.js" %>"></script>--%>

<script>
    var $formValidator;
    var $pageFormValidator;

    $(function () {

        $formValidator = $("#theForm").validate({
            //debug: true,
            //errorClass: "label label-danger",

            success: function (label, element) {
                label.remove();
                var id = $(element).prop("id");
                $('#' + id + 'Icon').removeClass('glyphicon-remove').removeClass('text-danger')
                    .addClass('glyphicon-ok').addClass('text-success');
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element);
                var id = $(element).prop("id");
                $('#' + id + 'Icon').addClass('glyphicon-remove').addClass('text-danger')
                    .removeClass('glyphicon-ok').removeClass('text-success');
            }
        });

        $pageFormValidator = $("#pageForm")
            //.submit(function (e) {
            //    e.preventDefault();
            //    showLoading();
            //})
            .validate({
                //invalidHandler: function () {
                //    hideLoading();
                //},
                // Do not change code below
                errorPlacement: function (error, element) {
                    error.insertAfter(element.parent());
                }
            });

        $.validator.addMethod("regex", function (value, element, regexpr) {
            return regexpr.test(value);
        }, "資料格式錯誤!!");

<%  if(ViewBag.ScrollUp != false)
    {   %>
        $.scrollUp({
            //animation: 'slide',
            //activeOverlay: '#00FFFF',
            scrollText: '',
            scrollImg: true,
        });
<%  }   %>
    });

    $.fn.serializeObject = function () {
        var o = {};
        var a = this.serializeArray();
        $.each(a, function () {
            if (o[this.name] !== undefined) {
                if (!o[this.name].push) {
                    o[this.name] = [o[this.name]];
                }
                o[this.name].push(this.value || '');
            } else {
                o[this.name] = this.value || '';
            }
        });
        return o;
    };

    $.fn.launchDownload = function (url, params, target) {

        var data = this.serializeObject();
        if (params) {
            $.extend(data, params);
        }

        var form = $('<form></form>').attr('action', url).attr('method', 'post');//.attr('target', '_blank');
        if (target) {
            form.attr('target', target);
            if (window.frames[target] == null) {
                $('<iframe>').attr('name', target).appendTo($('body'));
            }
        }

        Object.keys(data).forEach(function (key) {
            var value = data[key];

            if (value instanceof Array) {
                value.forEach(function (v) {
                    form.append($("<input></input>").attr('type', 'hidden').attr('name', key).attr('value', v));
                });
            } else {
                form.append($("<input></input>").attr('type', 'hidden').attr('name', key).attr('value', value));
            }

        });

        //send request
        form.appendTo('body').submit().remove();
    };


</script>
<script>
         /*
          * CONVERT DIALOG TITLE TO HTML
          * REF: http://stackoverflow.com/questions/14488774/using-html-in-a-dialogs-title-in-jquery-ui-1-10
          */
         $.widget("ui.dialog", $.extend({}, $.ui.dialog.prototype, {
            _title : function(title) {
               if (!this.options.title) {
                  title.html("&#160;");
               } else {
                  title.html(this.options.title);
               }
            }
         }));    
         
</script>
