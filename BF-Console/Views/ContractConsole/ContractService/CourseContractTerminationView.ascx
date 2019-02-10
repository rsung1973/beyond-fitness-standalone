<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

<div class="row">
    <div class="col-md-12">
        <div class="well no-padding well-light">
            <h2 class="text-center"><b>學員服務申請表</b></h2>
            <div class="<%= Request["pdf"]=="1" ? "bs-example bs-example-type seal" : "bs-example bs-example-type" %>">
                <table class="table" style="font-size: 15px">
                    <tbody>
                        <tr>
                            <td colspan="2">合約編號：<%= _contract.ContractNo() %></td>
                        </tr>
                        <tr>
                            <td>姓名：<%= _contract.ContractOwner.RealName %></td>
                            <td>聯絡電話：<%= _contract.ContractOwner.Phone %></td>
                        </tr>
                    </tbody>
                    <tbody>
                        <tr>
                            <td colspan="2">申請項目：<%  if (_contract.Status >= (int)Naming.CourseContractStatus.待審核)
                                { %>
                                ☑
                            <%  }
                                else
                                { %>
                                <input type="checkbox" name="extension" checked="checked"  onclick="this.checked = true;" />
                                <%  } %> 終止</td>
                        </tr>
                        <tr>
                            <td colspan="2">申請日期：<%= String.Format("{0:yyyy/MM/dd}", _contract.ContractDate) %></td>
                        </tr>
                        <tr>
                        <tr>
                            <td colspan="2">
                                <%  var original = _model.SourceContract;
                                    var remained = original.RemainedLessonCount();
                                    var refund = original.TotalPaidAmount() - (original.Lessons - original.RemainedLessonCount()) * _contract.CourseContractExtension.SettlementPrice * _contract.CourseContractType.GroupingMemberCount * _contract.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount / 100; %>
                            申請內容：原合約編號 <%= original.ContractNo() %> 原購買堂數：<%= original.Lessons %>堂 / <%= String.Format("{0:##,###,###,###}",original.LessonPriceType.ListPrice) %>元，
                                終止時全部堂數以單堂 / <%= String.Format("{0:##,###,###,###}",_contract.CourseContractExtension.SettlementPrice) %>元 計價，
                                並扣除剩餘上課堂數：<%= remained %>堂，計算退款差額 <%= String.Format("{0:##,###,###,##0}",refund) %>元，確定於 <%= String.Format("{0:yyyy/MM/dd}",_signatureDate) %> 終止服務。</td>
                        </tr>
                        <tr style="height: 16cm">
                            <td colspan="2"><%= _contract.Remark %></td>
                        </tr>
                    </tbody>
                </table>
                <table class="table" style="font-size: 15px">
                    <tr>
                        <td colspan="3">備註：各項申請內容皆應依體能顧問聘請合約之規定辦理並經雙方簽署後始生效力</td>
                    </tr>
                    <tr>
                        <td colspan="2">日期：<%= String.Format("{0:yyyy/MM/dd}",_signatureDate) %></td>
                        <td>超越體能顧問有限公司</td>
                    </tr>
                    <tr>
                        <td>學員簽名：
                            <%  ViewBag.SignatureName = "Signature";
                                Html.RenderPartial("~/Views/CourseContract/Module/SignHere.ascx", _owner);  %>
                        </td>
                        <td></td>
                        <td style="vertical-align: middle;">主管簽約代表：
                            <%  UserProfile contractAgent = (UserProfile)ViewBag.ContractAgent;
                                if (_contract.Status > (int)Naming.CourseContractStatus.待確認 || contractAgent!=null)
                                {   %>
                            <img src="<%= contractAgent!=null ? contractAgent.LoadInstance(models).UserProfileExtension.Signature : _contract.ContractAgent.UserProfileExtension.Signature %>" width="200px" class="modifySignDialog_link">
                            <%  }   %>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">家長/監護人簽名：
                            <%  ViewBag.SignatureName = "GuardianSignature";
                                Html.RenderPartial("~/Views/CourseContract/Module/SignHere.ascx", _owner); %>
                        </td>
                        <td>簽約體能顧問：<img src="<%= _contract.ServingCoach.UserProfile.UserProfileExtension.Signature %>" width="200px" class="modifySignDialog_link"/></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContractRevision _model;
    CourseContractMember _owner;
    CourseContract _contract;
    DateTime? _signatureDate;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContractRevision)this.Model;
        _contract = _model.CourseContract;
        _owner = _contract.CourseContractMember.Where(m => m.UID == _contract.OwnerID).First();
        var item = _contract.CourseContractLevel.Where(l => l.LevelID == (int)Naming.CourseContractStatus.待簽名).FirstOrDefault();
        if (item != null)
        {
            _signatureDate = item.LevelDate;
        }
        else
        {
            _signatureDate = _contract.EffectiveDate ?? _contract.ContractDate;
        }
    }

</script>
