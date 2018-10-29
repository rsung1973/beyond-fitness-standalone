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

<div class="modal-dialog">
    <div class="modal-content">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                &times;
            </button>
            <h4 class="modal-title" id="myModalLabel">設定團體上課學員</h4>
        </div>
        <div class="modal-body bg-color-darken txt-color-white">
            <form action="<%= VirtualPathUtility.ToAbsolute("~/Member/ApplyGroupLessons") %>" id="add-form" class="smart-form" method="post">
                <input type="hidden" name="lessonId" value="<%= _model.RegisterID %>" />
                <fieldset>
                    <div class="row">
                        <section class="col col-8">
                            <label class="input">
                                <i class="icon-append fa fa-search"></i>
                                <input type="text" name="userName" maxlength="20" placeholder="請輸入學員姓名" />
                            </label>
                        </section>
                        <section class="col col-4">
                            <button id="btnQuery" class="btn bg-color-blue btn-sm" type="button">查詢</button>
                        </section>
                    </div>
                </fieldset>
                <fieldset>
                    <div class="inline-group" id="userList">
                        <% if (_items.Length > 0)
                            {
                                for (int i = 0; i < (_items.Length + 2) / 3; i++)
                                { %>
                        <%          for (int j = 0; j < 3; j++)
                                    {
                                        if ((i * 3 + j) < _items.Length)
                                        { %>
                                            <label class="checkbox">
                                                <input type="checkbox" name="registerID" value="<%= _items[i * 3 + j].RegisterID %>" <%= _items[i * 3 + j].RegisterGroupID==_model.RegisterGroupID ? "checked" : null %> />
                                                <i></i><%= _items[i * 3 + j].UserProfile.FullName() %></label>
                        <%              }
                                    } %>
                        <%      }
                            }
                            else
                            { %>
                                查無相符條件的上課資料!!
                        <%  } %>
                    </div>
                </fieldset>

                <footer>
                    <button type="button" id="btnGrouping" class="btn btn-primary">
                        送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                    </button>
                    <button type="button" class="btn btn-default" data-dismiss="modal">
                        取消
                    </button>
                </footer>
            </form>
        </div>
        <!-- /.modal-content -->
    </div>
    <!-- /.modal-dialog -->
</div>

<script>
    $('#btnGrouping').on('click', function (evt) {
        var $items = $('input:checkbox[name="registerID"]:checked');
        var memberCount = <%= _model.GroupingMemberCount-1 %>;
        if ($items.length <= 0) {
            $.SmartMessageBox({
                title: "<i class=\"fa fa-fw far fa-trash-alt\" aria-hidden=\"true\"></i> 作業訊息",
                content: "請勾選本次團體課學員!!",
                buttons: '[關閉]'
            });
            return;
        } else if($items.length > memberCount) {
            $.SmartMessageBox({
                title: "<i class=\"fa fa-fw far fa-trash-alt\" aria-hidden=\"true\"></i> 作業訊息",
                content: "勾選的學員數超過本次團體課人數!!",
                buttons: '[關閉]'
            });
            return;
        }
        startLoading();
        $('#add-form').submit();
    });

    $('#btnQuery').on('click',function(evt) {
        var userName = $('input[name="userName"]').val();
        $('#loading').css('display', 'table');
        $('#userList').load('<%= VirtualPathUtility.ToAbsolute("~/Member/GroupLessonUsersSelector") %>',{'lessonId':<%= _model.RegisterID %>,'userName':userName},function(){
            $('#loading').css('display', 'none');
        });
    });

</script>


<script runat="server">

    ModelStateDictionary _modelState;
    RegisterLesson _model;
    RegisterLesson[] _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (RegisterLesson)this.Model;
        var models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _items = models.GetTable<RegisterLesson>().Where(l => l.Attended == (int)Naming.LessonStatus.準備上課 && l.ClassLevel == _model.ClassLevel
            && l.Lessons == _model.Lessons
            && l.GroupingLesson.LessonTime.Count == 0
            && l.UID != _model.UID
            && l.GroupingMemberCount == _model.GroupingMemberCount).ToArray();
    }

</script>
