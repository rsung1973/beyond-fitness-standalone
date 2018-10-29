<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
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
            <h4 class="modal-title" id="myModalLabel">新增動作</h4>
        </div>
        <%  if (_model != null)
            { %>
        <form action="<%= VirtualPathUtility.ToAbsolute("~/Lessons/CommitTrainingItem") %>" method="post">
            <input type="hidden" name="executionID" value="<%= _model.ExecutionID %>" />
            <div class="modal-body bg-color-darken txt-color-white">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <div class="icon-addon addon-lg">
                                <% Html.RenderPartial("~/Views/Lessons/BodyPartsSelector.ascx"); %>
                            </div>
                            <p class="note"><strong>Note:</strong> 輸入15或10-12</p>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <div class="input-group input-group-lg">
                                <span class="input-group-addon">目標</span>
                                <div class="icon-addon addon-lg">
                                    <input type="text" placeholder="" class="form-control" name="goalTurns" />
                                </div>
                                <span class="input-group-addon">次數</span>
                            </div>
                            <p class="note"><strong>Note:</strong> 輸入15或10-12</p>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <input class="form-control input-lg" placeholder="請輸入動作內容" type="text" maxlength="15" name="description" />
                            <p class="note"><strong>Note:</strong> 最多僅能輸入15個中英文字</p>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <div class="input-group input-group-lg">
                                <span class="input-group-addon">目標</span>
                                <div class="icon-addon addon-lg">
                                    <input type="text" placeholder="" class="form-control" name="goalStrength" />
                                </div>
                                <span class="input-group-addon">強度</span>
                            </div>
                            <p class="note"><strong>Note:</strong> 輸入15磅 或10-12 KG 或30秒</p>
                        </div>
                    </div>
                </div>

                <fieldset>

                    <div class="form-group">
                        <textarea class="form-control" placeholder="請輸入加強說明" name="remark" rows="3"></textarea>
                        <p class="note"><strong>Note:</strong> 最多輸入250個中英文字</p>
                    </div>

                </fieldset>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">
                    取消
                </button>
                <button type="button" class="btn btn-primary" onclick="commitTrainingItem();">
                    送出 <i class="fa fa-paper-plane" aria-hidden="true"></i>
                </button>
            </div>
        </form>
        <%  }
            else
            { %>
                預編課程資料錯誤!!
        <%  } %>
    </div>
    <!-- /.modal-content -->
</div>

<script>
    $('#btnAddTraining').on('click', function (evt) {
        //$addTrainingModal.find('form').submit();
        $addTrainingModal.modal('hide');
    });
</script>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    TrainingExecution _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (TrainingExecution)this.Model;
    }

</script>
