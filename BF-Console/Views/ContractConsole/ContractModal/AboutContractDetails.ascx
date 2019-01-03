<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<div class="modal fade" id="<%= _dialogID %>" tabindex="-1" role="dialog" aria-labelledby="exampleModalLongTitle" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <a class="closebutton" data-dismiss="modal"></a>
            <div class="modal-body">
                <div class="card">
                    <div class="body">
                        <div class="panel-group full-body" id="accordionDetail_contract" role="tablist" aria-multiselectable="true">
                            <div class="panel">
                                <div class="panel-heading" role="tab" id="headingDetailContract">
                                    <h4 class="panel-title">
                                        <a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordionDetail_contract" href="#collapseDetail_contract" aria-expanded="false" aria-controls="collapseDetail_contract"><i class="material-icons">subject</i> 合約詳細資訊 
                                            <%  if (_model.Status <= (int)Naming.ContractQueryStatus.待審核)
                                                {   %>
                                            <span class="badge bg-orange"><%= (Naming.ContractQueryStatus)_model.Status %></span>
                                            <%  }
                                                else if (_model.Status == (int)Naming.CourseContractStatus.已生效)
                                                {   %>
                                            <span class="badge bg-green">生效中</span>
                                            <%  }
                                                else if (_model.Status == (int)Naming.CourseContractStatus.已過期)
                                                {   %>
                                            <span class="badge bg-red">已過期</span>
                                            <%  }
                                                else if (_model.Status == (int)Naming.CourseContractStatus.已終止)
                                                {   %>
                                            <span class="badge bg-red">已終止</span>
                                            <%  }
                                                else if (_model.Status == (int)Naming.CourseContractStatus.已轉讓)
                                                {   %>
                                            <span class="badge bg-red">已轉讓</span>
                                            <%  }
                                                else if (_model.Status == (int)Naming.CourseContractStatus.已轉點)
                                                {   %>
                                            <span class="badge bg-red">已轉點</span>
                                            <%  }   %>
                                        </a>
                                    </h4>
                                </div>
                                <div id="collapseDetail_contract" class="panel-collapse collapse show" role="tabpanel" aria-labelledby="headingDetailContract">
                                    <div class="panel-body no-padding">
                                        <ul class="mb_list xl-aliceblue">
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd">合約編號</div>
                                                        <div class="list_td rt"><%= _model.ContractNo() %></div>
                                                    </div>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd">合約名稱</div>
                                                        <div class="list_td rt"><%= _model.ContractName() %></div>
                                                    </div>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd">學生</div>
                                                        <div class="list_td rt"><%= _model.ContractLearner() %></div>
                                                    </div>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd">合約起日</div>
                                                        <div class="list_td rt"><%= $"{_model.ValidFrom:yyyy/MM/dd}" %></div>
                                                    </div>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd">合約迄日</div>
                                                        <div class="list_td rt col-red"><%= $"{_model.Expiration:yyyy/MM/dd}" %></div>
                                                    </div>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd">合約金額</div>
                                                        <div class="list_td rt"><%= $"{_model.TotalCost:##,###,###,###}" %></div>
                                                    </div>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd p-l-20">專業顧問服務總費用</div>
                                                        <div class="list_td rt"><%= String.Format("{0:##,###,###,###}",(_model.TotalCost*8+5)/10) %></div>
                                                    </div>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd p-l-20">教練課程費</div>
                                                        <div class="list_td rt"><%= String.Format("{0:##,###,###,###}",(_model.TotalCost*2+5)/10) %></div>
                                                    </div>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd">課程單價 
                                                            <span class="badge bg-blue">
                                                                <%  if (_model.LessonPriceType.SeriesID.HasValue)
                                                                    {   %>
                                                                <%--<%= _model.LessonPriceType.Description %>--%> <%= _model.LessonPriceType.LowerLimit %>堂
                                                                <%  }
                                                                    else
                                                                    {   %>
                                                                <%= _model.LessonPriceType.Description %>
                                                                <%  }   %>
                                                            </span>
                                                        </div>
                                                        <div class="list_td rt"><%= $"{_model.LessonPriceType.ListPrice:##,###,###,###}" %></div>
                                                    </div>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd">剩餘/購買堂數</div>
                                                        <div class="list_td rt"><%= _model.RemainedLessonCount() %>/<%= _model.Lessons %></div>
                                                    </div>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd">備註</div>
                                                        <div class="list_td rt"><%= _model.Remark %></div>
                                                    </div>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd">合約體能顧問</div>
                                                        <div class="list_td rt"><%= _model.ServingCoach.UserProfile.FullName() %></div>
                                                    </div>
                                                </div>
                                            </li>
                                            <li>
                                                <div class="list_tb tb2">
                                                    <div class="list_tr">
                                                        <div class="list_td hd">上課場所</div>
                                                        <div class="list_td rt"><%= _model.CourseContractExtension?.BranchStore.BranchName %></div>
                                                    </div>
                                                </div>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                            <div class="panel">
                                <div class="panel-heading" role="tab" id="headingLearnerlist">
                                    <h4 class="panel-title"><a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordionDetail_contract" href="#collapseLearnerlist" aria-expanded="false" aria-controls="collapseLearnerlist"><i class="material-icons">subject</i> 學生詳細資訊 </a></h4>
                                </div>
                                <div id="collapseLearnerlist" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingLearnerlist">
                                    <div class="panel-body no-padding">
                                        <div class="table-responsive">
                                            <%  Html.RenderPartial("~/Views/ContractConsole/Module/ContractMemberList.ascx", _model.CourseContractMember.Select(m => m.UserProfile)); %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <%  if (_model.InstallmentID.HasValue)
                                {   %>
                            <div class="panel xl-khaki">
                                <div class="panel-heading" role="tab" id="headingInstallmentList">
                                    <h4 class="panel-title material-icons"><a role="button" data-toggle="collapse" data-parent="#accordionDetail_contract" href="#collapseInstallmentList" aria-expanded="true" aria-controls="collapseInstallmentList"><i class="material-icons">subject</i> 分期詳細資訊 </a></h4>
                                </div>
                                <div id="collapseInstallmentList" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingInstallmentList">
                                    <div class="panel-body no-padding">
                                        <div class="row">
                                            <div class="col-md-12 col-12">
                                                <%  Html.RenderPartial("~/Views/ContractConsole/Module/ContractInstallmentList.ascx", models.GetTable<CourseContract>().Where(c => c.InstallmentID == _model.InstallmentID)); %>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <%  } %>
                            <div class="panel xl-pink">
                                <div class="panel-heading" role="tab" id="headingInvoiceList">
                                    <h4 class="panel-title material-icons"><a role="button" data-toggle="collapse" data-parent="#accordionDetail_contract" href="#collapseInvoiceList" aria-expanded="true" aria-controls="collapseInvoiceList"><i class="material-icons">subject</i> 收款詳細資訊 </a></h4>
                                </div>
                                <div id="collapseInvoiceList" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingInvoiceList">
                                    <div class="panel-body no-padding">
                                        <div class="row">
                                            <div class="col-md-12 col-12">
                                                <ul class="mb_list xl-pink">
                                                    <li>
                                                        <div class="list_tb tb2">
                                                            <div class="list_tr">
                                                                <div class="list_td hd">應收款期限</div>
                                                                <div class="list_td rt col-red"></div>
                                                            </div>
                                                        </div>
                                                    </li>
                                                    <li>
                                                        <div class="list_tb tb2">
                                                            <div class="list_tr">
                                                                <div class="list_td hd">收款次數</div>
                                                                <div class="list_td rt"><%= _model.ContractPayment.Count %></div>
                                                            </div>
                                                        </div>
                                                    </li>
                                                    <li>
                                                        <div class="list_tb tb2">
                                                            <div class="list_tr">
                                                                <div class="list_td hd">合約金額</div>
                                                                <div class="list_td rt"><%= $"{_model.TotalCost:##,###,###,###}" %></div>
                                                            </div>
                                                        </div>
                                                    </li>
                                                    <li>
                                                        <div class="list_tb tb2">
                                                            <div class="list_tr">
                                                                <div class="list_td hd">已收金額</div>
                                                                <div class="list_td rt">
                                                                    <%  var totalPaidAmt = _model.TotalPaidAmount(); %>
                                                                    <%= $"{totalPaidAmt:##,###,###,##0}" %></div>
                                                            </div>
                                                        </div>
                                                    </li>
                                                    <li>
                                                        <div class="list_tb tb2">
                                                            <div class="list_tr">
                                                                <div class="list_td hd">未收金額</div>
                                                                <div class="list_td rt col-red"><%= $"{_model.TotalCost-totalPaidAmt:##,###,###,##0}" %></div>
                                                            </div>
                                                        </div>
                                                    </li>
                                                </ul>
                                            </div>
                                            <div class="col-md-12 col-12">
                                                <%  Html.RenderPartial("~/Views/ContractConsole/Module/ContractPaymentList.ascx", 
                                                            models.GetTable<ContractPayment>()
                                                                .Where(c => c.ContractID == _model.ContractID)
                                                                .Select(c=>c.Payment)); %>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <%  Html.RenderPartial("~/Views/ConsoleHome/Shared/BSModalScript.ascx", model: _dialogID); %>
    <script>
        $(function () {
            $('#<%= _dialogID %> .panel-collapse').on('shown.bs.collapse', function (event) {
                <%--$('#<%= _dialogID %>').resize();--%>
                //$('.modal.fade.show').resize();
            });
        });
    </script>
</div>
<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContract _model;
    String _dialogID = $"contractDetails{DateTime.Now.Ticks}";
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
        _profile = Context.GetUser();
    }


</script>
