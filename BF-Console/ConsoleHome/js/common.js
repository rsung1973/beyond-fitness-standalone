
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

function smartAlert(message) {
    swal(message);
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
        confirmed: ['刪除成功!', '資料已經刪除 Bye!','success'],
        cancelled: ['取消成功', '你的資料現在非常安全 :)', 'error'],
        afterConfirmed: null,
    };
    if (options) {
        $.extend(defaultOptions, options);
    }

    swal(defaultOptions, function (isConfirm) {
        if (isConfirm) {
            doDelete(function () {
                if (defaultOptions.afterConfirmed instanceof Function) {
                    swal({
                        'title': defaultOptions.confirmed[0],
                        'text': defaultOptions.confirmed[1],
                        'confirmButtonText': defaultOptions.confirmed[2]
                    }, defaultOptions.afterConfirmed);
                } else {
                    swal(defaultOptions.confirmed[0], defaultOptions.confirmed[1], defaultOptions.confirmed[2]);
                }
            });
        } else {
            swal(defaultOptions.cancelled[0], defaultOptions.cancelled[1], defaultOptions.cancelled[2]);
            if ($global.closeAllModal)
                $global.closeAllModal();
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


var $global = {
    'onReady': [],
    call: function (name) {
        var fn = $global[name];
        if (typeof fn === 'function') {
            fn();
        }
    },
};