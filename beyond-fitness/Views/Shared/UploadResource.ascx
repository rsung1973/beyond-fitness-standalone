<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<i class="icon-append far fa-keyboard"></i> 圖片：
<input type="file" class="input-lg" name="photopic" id="photopic" aria-describedby="photopicStatus"/>
<%--    <span class="glyphicon glyphicon-remove form-control-feedback text-danger" aria-hidden="true"></span>
    <span id="photopicStatus" class="sr-only">(success)</span>--%>
<%--    <label class="control-label" for="nickname">擷取圖片：</label>
    <input type="text" class="form-control" placeholder="請輸入來源(Url)" name="imgUrl" aria-describedby="coachnameStatus" />
    <a  id="getImg" class="btn btn-system btn-small">擷取 <i class="fa fa-eye" aria-hidden="true"></i></a>--%>

<script type="text/javascript">
    $(function () {
        var fileUpload = $('#photopic');
        var elmt = fileUpload.prev();

        fileUpload.off('click').on('change', function () {

            $('<form method="post" action="<%= VirtualPathUtility.ToAbsolute("~/Information/UploadResource/"+DocID) %>" id="myForm" enctype="multipart/form-data"></form>')
            .append(fileUpload).ajaxForm({
                url: "<%= VirtualPathUtility.ToAbsolute("~/Information/UploadResource/"+DocID) %>",
                beforeSubmit: function () {
                    //status.show();
                    //btn.hide();
                    //console.log('提交時');
                },
                success: function (data) {
                    elmt.after(fileUpload);
                    if(data) {
                        if (data.result) {
                            loadResource(<%= DocID %>);
                        } else {
                            smartAlert(data.message);
                        }
                    }
                    //status.hide();
                    //console.log('提交成功');
                },
                error: function () {
                    elmt.after(fileUpload);
                    //status.hide();
                    //btn.show();
                    //console.log('提交失败');
                }
            }).submit();
        });

        $('#getImg').on('click', function (evt) {
            var url = $('input[name="imgUrl"]').val();
            if (url != '') {
                $.post('<%= VirtualPathUtility.ToAbsolute("~/Information/RetrieveResource")%>', { 'docID': <%= DocID %>, 'imgUrl': url }, function (data) {
                    if(data.result) {
                        loadResource(<%= DocID %>);
                    }
                    smartAlert(data.message);
                });
            }
        });

    });
</script>
<script runat="server">

    [System.ComponentModel.Bindable(true)]
    public int DocID
    {
        get; set;
    }
</script>
