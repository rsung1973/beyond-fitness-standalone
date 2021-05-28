
var loading = 0;
function showLoading() {
    //$('.page-loader-wrapper').css('display', 'block');
    var current = (new Date()).getTime();
    if ((current-loading) > 3000) {
        $('.page-loader-wrapper').fadeIn();
        loading = current;
    }
}

function hideLoading() {
    //$('.page-loader-wrapper').css('display', 'none');
    $('.page-loader-wrapper').fadeOut();
}

function loadScript(url, callback) {

    var script = document.createElement("script")
    script.type = "text/javascript";

    if (script.readyState) {  //IE
        script.onreadystatechange = function () {
            if (script.readyState === "loaded" ||
                script.readyState === "complete") {
                script.onreadystatechange = null;
                callback();
            }
        };
    } else {  //Others
        script.onload = function () {
            callback();
        };
    }

    script.src = url;
    document.getElementsByTagName("head")[0].appendChild(script);
}

function deleteData(doDelete, options) {
    var defaultOptions = {
        title: "不後悔?",
        text: "刪除後資料將無法回覆!",
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: "確定, 不後悔",
        cancelButtonText: "不, 點錯了",
        closeOnConfirm: false,
        closeOnCancel: false,
        confirmed: ['刪除成功!', '資料已經刪除 Bye!','OK'],
        cancelled: ['取消成功', '你的資料現在非常安全 :)', 'OK'],
        afterConfirmed: null,
    };
    if (options) {
        $.extend(defaultOptions, options);
    }

    Swal.fire({
        title: defaultOptions.title,
        text: defaultOptions.text,
        icon: defaultOptions.type,
        showCancelButton: defaultOptions.showCancelButton,
        confirmButtonColor: defaultOptions.confirmButtonColor,
        confirmButtonText: defaultOptions.confirmButtonText,
        cancelButtonText: defaultOptions.cancelButtonText,
        focusCancel: true
    }).then((result) => {
        if (result.isConfirmed) {
            showLoading();
            doDelete(function () {
                Swal.fire({
                    'title': defaultOptions.confirmed[0],
                    'text': defaultOptions.confirmed[1],
                    'confirmButtonText': defaultOptions.confirmed[2],
                    'icon': 'success'
                }).then((r) => {
                    if (defaultOptions.afterConfirmed instanceof Function) {
                        defaultOptions.afterConfirmed();
                    }
                });
            });
        } else {
            Swal.fire({
                'title': defaultOptions.cancelled[0],
                'text': defaultOptions.cancelled[1],
                'confirmButtonText': defaultOptions.cancelled[2],
                'icon': 'info'
            }).then((r) => {
                if ($global.closeAllModal)
                    $global.closeAllModal();
            });
        }
    });
}

function clearErrors() {
    $('label.help-error-text').remove();
}

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

var fileDownloadCheckTimer;
$.fn.launchDownload = function (url, params, target, loading) {

    var data = this.serializeObject();
    if (params) {
        $.extend(data, params);
    }

    if (loading) {
        token = (new Date()).getTime();
        data.fileDownloadToken = token;
    }

    var form = $('<form></form>').attr('action', url).attr('method', 'post');//.attr('target', '_blank');
    if (target) {
        form.attr('target', target);
        if (window.frames[target] == null) {
            $('<iframe>')
                .css('display','none')
                .attr('name', target).appendTo($('body'));
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

    if (loading) {
        showLoading();
        fileDownloadCheckTimer = window.setInterval(function () {
            var cookieValue = $.cookie('fileDownloadToken');
            if (cookieValue == token)
                finishDownload();
        }, 1000);
    }

    //send request
    form.appendTo('body').submit().remove();
};

function finishDownload() {
    window.clearInterval(fileDownloadCheckTimer);
    $.removeCookie('fileDownloadToken'); //clears this cookie value
    hideLoading();
}

function uploadFile($file, postData, url, callback, errorback) {

    $('<form method="post" enctype="multipart/form-data"></form>')
        .append($file).ajaxForm({
            url: url,
            data: postData,
            beforeSubmit: function () {
                showLoading();
            },
            success: function (data) {
                hideLoading();
                callback(data);
            },
            error: function () {
                hideLoading();
                errorback();
            }
        }).submit();
}

function showDialog(url, jsonData) {
    showLoading();
    $.post(url, jsonData, function (data) {
        hideLoading();
        if ($.isPlainObject(data)) {
            swal(data.message);
        } else {
            $(data).appendTo($('body'));
        }
    });
}




var $global = {
    'onReady': [],
    call: function (name) {
        var fn = $global[name];
        if (typeof fn === 'function') {
            fn();
        }
    },
};