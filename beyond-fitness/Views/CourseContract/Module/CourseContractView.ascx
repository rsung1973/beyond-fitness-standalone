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
        <div class="well no-padding well-light" style="width: 23cm; height: 30cm">
            <h2 class="text-center"><b>體能顧問聘請服務合約</b></h2>
            <div class="<%= Request["pdf"]=="1" ? "bs-example bs-example-type seal" : "bs-example bs-example-type" %>">
                <table class="table" style="font-size: 16px">
                    <%  if (_model.ContractNo != null)
                        { %>
                    <tbody>
                        <tr>
                            <td colspan="3">合約編號：<%= _model.ContractNo() %></td>
                        </tr>
                    </tbody>
                    <%  } %>
                    <tbody>
                        <tr>
                            <td colspan="3">學員資料</td>
                        </tr>
                        <%  IEnumerable<CourseContractMember> items;
                            if(_model.CourseContractType.ContractCode=="CFA")
                            {
                                items = _model.CourseContractMember.Where(m => m.UID == _model.OwnerID);
                            }
                            else
                            {
                                items = _model.CourseContractMember;
                            }
                            foreach (var m in items)
                            { %>
                        <tr style="border-width: 1px; border-top-style: dashed;">
                            <td>姓名：<%= m.UserProfile.RealName %></td>
                            <td colspan="2">身份證字號/護照號碼：<%= m.UserProfile.UserProfileExtension.IDNo %></td>
                        </tr>
                        <tr>
                            <td>性別：<%= m.UserProfile.UserProfileExtension.Gender=="F" ? "女" : "男" %></td>
                            <td>出生：<%= String.Format("{0:yyyy/MM/dd}",m.UserProfile.Birthday) %></td>
                            <td>聯絡電話：<%= m.UserProfile.Phone %></td>
                        </tr>
                        <tr>
                            <td>緊急聯絡人姓名：<%= m.UserProfile.UserProfileExtension.EmergencyContactPerson %></td>
                            <td>關係：<%= m.UserProfile.UserProfileExtension.Relationship %></td>
                            <td>緊急聯絡電話：<%= m.UserProfile.UserProfileExtension.EmergencyContactPhone %></td>
                        </tr>
                        <tr>
                            <td colspan="3">地址：<%= m.UserProfile.Address() %></td>
                        </tr>
                        <%  } %>
                        <tr style="height: 1cm; border-width: 1px; border-top-style: dashed;">
                            <td colspan="3">課程內容</td>
                        </tr>
                    </tbody>
                    <tbody>
                        <tr>
                            <td colspan="2">名稱：<%= _model.CourseContractType.TypeName %>(<%= _model.LessonPriceType.DurationInMinutes %>分鐘)</td>
                            <td>上課場所：<%= _model.CourseContractExtension.BranchStore.BranchName %></td>
                        </tr>
                        <tr>
                            <td colspan="2">專業顧問建置與諮詢費：<%= String.Format("{0:##,###,###,###}",(_model.TotalCost*8+5)/10) %></td>
                            <td>教練課程費：<%= String.Format("{0:##,###,###,###}",(_model.TotalCost*2+5)/10) %></td>
                        </tr>
                        <tr>
                            <td colspan="2">購買堂數：<%= _model.Lessons %></td>
                            <td>專業顧問服務總費用：<%= String.Format("{0:##,###,###,###}",_model.TotalCost) %></td>
                        </tr>
                        <tr>
                            <td colspan="3">顧問服務使用期限：自 <%= String.Format("{0:yyyy/MM/dd}",_model.ValidFrom) %> 起，至 <%= String.Format("{0:yyyy/MM/dd}",_model.Expiration) %> 止。</td>
                        </tr>
                        <tr>
                            <td colspan="3" style="height: <%= _model.CourseContractType.IsGroup==true ? "1cm" : "2cm" %>">備註：<%= _model.Remark %></td>
                        </tr>
                    </tbody>
                </table>
                <table class="table" style="font-size: 16px">
                    <tr>
                        <td>
                            <%  if (_model.Status >= (int)Naming.CourseContractStatus.待審核)
                                { %>
                                ☑
                            <%  }
                                else
                                { %>
                            <input type="checkbox" name="extension" />
                            <%  } %>
                        </td>
                        <td>展延：無法於上述使用期限內完成課程堂數者，得於到期前30日內申請展延使用，並得就未完成部分協商展延3個月內完成，且展延後不得申請轉讓或退費。</td>
                    </tr>
                    <tr>
                        <td>
                            <%  if (_model.Status >= (int)Naming.CourseContractStatus.待審核)
                                { %>
                                ☑
                            <%  }
                                else
                                { %>
                            <input type="checkbox" name="booking" />
                            <%  } %>
                        </td>
                        <td>預約：須於欲使用其體能顧問服務時段至少24小時前向其負責之體能顧問預約其服務與其場地租用權力。</td>
                    </tr>
                    <tr>
                        <td>
                            <%  if (_model.Status >= (int)Naming.CourseContractStatus.待審核)
                                { %>
                                ☑
                                <%  }
                                    else
                                    { %>
                            <input type="checkbox" name="cancel" />
                            <%  } %>
                  
                        </td>
                        <td>取消：如欲取消預約時段，學員必須於原定時間24小時前通知負責之體能顧問，否則該未使用之預約顧問服務仍應記入已使用之體能顧問課程堂數內。</td>
                    </tr>
                    <tr>
                        <td colspan="2">您已確認並瞭解於簽署本合約後，即表示即日起您同意接受本合約正面及背面條款之相關約束及其責任。</td>
                    </tr>
                </table>
                <table class="table" style="font-size: 16px">
                    <tr>
                        <td colspan="2"></td>
                        <td>Beyond Fitness超越體能顧問有限公司</td>
                    </tr>
                    <tr>
                        <td>學員簽名：
                                            <%  ViewBag.SignatureName = "Signature";
                                                if (_model.CourseContractType.IsGroup == true)
                                                {
                                                    foreach (var m in _model.CourseContractMember)
                                                    {
                                                        Html.RenderPartial("~/Views/CourseContract/Module/SignHere.ascx", m);
                                                    }
                                                }
                                                else
                                                {
                                                    Html.RenderPartial("~/Views/CourseContract/Module/SignHere.ascx", _owner);
                                                } %>
                        </td>
                        <td></td>
                        <td>
                            <%  if (_model.Status > (int)Naming.CourseContractStatus.待簽名)
                                { %>
                            主管簽核代表：
                            <img src="<%= _model.Status==(int)Naming.CourseContractStatus.待審核 && Request["pdf"]!="1"
                                    ? Context.GetUser().LoadInstance(models).UserProfileExtension.Signature
                                    : _model.ContractAgent.UserProfileExtension.Signature %>" width="200px" class="modifySignDialog_link">
                            <%  } %>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">家長/監護人簽名：
                                            <%  ViewBag.SignatureName = "GuardianSignature";
                                                Html.RenderPartial("~/Views/CourseContract/Module/SignHere.ascx", _owner); %>
                        </td>
                        <td>簽約體能顧問：<img src="<%= _model.ServingCoach.UserProfile.UserProfileExtension.Signature %>" width="200px" class="modifySignDialog_link"></td>
                    </tr>
                    <tr>
                        <td colspan="2">日期：<%= String.Format("{0:yyyy/MM/dd}",_signatureDate) %></td>
                        <td>日期：<%= String.Format("{0:yyyy/MM/dd}",_signatureDate) %></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <div class="well padding-5 well-light" style="width: 23cm; height: 30cm">
            <h2 class="text-center"><b>Beyond Fitness訓練特約條款</b></h2>
            <div class="<%= Request["pdf"]=="1" ? "bs-example bs-example-type seal" : "bs-example bs-example-type" %>">
                <table class="table" style="font-size: 13px">
                    <tr>
                        <td>本場館為超越體能顧問有限公司 (以下簡稱本公司)負責經營管理並提供各項體能顧問服務，學員權利義務均以本合約與特約條款之規定為準，相關內容應於申請時詳加閱讀，並同意遵守以維護場館之環境品質。<br />
                            超越體能顧問有限公司已提供3天之合約審閱期，您已確認閱讀完畢。</td>
                    </tr>
                </table>
                <table style="font-size: 13px">
                    <tr>
                        <td>
                            <%  if (_model.CourseContractType.IsGroup == true)
                                {%>
                            <ol style="-webkit-padding-start: 20px;">
                                <li>營業時間及設備：營業時間及設備參照各上課地點規定。</li>
                                <li>學員資格：未成年人應得其法定代理人允許或承認。</li>
                                <li>教練課程費入台新銀行信託專戶。</li>
                                <li>學員健康情形與醫療諮詢：您聲明其身體健康狀況良好，並無存在會妨礙其預計使用體能顧問服務之醫療原因或傷病。您確認本公司未在客戶簽署本特約條款之前為您提供醫療建議，且在簽署本特約條款後亦不會為您提供有關身體狀況和使用訓練課程能力的任何建議。如果您目前或簽約後有任何健康或醫療方面的問題，應先諮詢醫生，然後再使用其體能顧問服務之權利。</li>
                                <li>使用期限：顧問服務使用期限係依課程堂數而定，使用期限原則不逾18個月。</li>
                                <li>展延：無法於上述使用期限內完成課程堂數者，得於到期前30日內申請展延使用，並得就未完成部分協商展延3個月內完成，且展延後不得申請轉讓或退費。</li>
                                <li>預約：須於欲使用其體能顧問服務時段至少24小時前向其負責之體能顧問預約其服務與其場地租用權力。</li>
                                <li>取消：如欲取消預約時段，學員必須於原定時間24小時前通知負責之體能顧問，否則該未使用之預約顧問服務仍應記入已使用之體能顧問課程堂數內。</li>
                                <li>遲到：若學員遲到20分鐘以上，其負責之體能顧問有權利視為「缺席」處理，並記入已使用之體能顧問課程堂數內，且本公司無義務於剩餘預約時段內提供服務（特殊情形視情況由體能顧問及本公司協調而定）。</li>
                                <li>學員使用體能顧問服務需完成系統登錄確認。1對2之課程，學員需同時出席，僅1位學員出席時，仍視為已使用體能顧問課程堂數。</li>
                                <li>更換教練：學員有權利選擇體能顧問，並瞭解且同意其係購買本公司之課程而非指定體能顧問或其他特定體能顧問之個人服務，若該排定之體能顧問無法提供服務，本公司得指派其他體能顧問進行其服務交接。</li>
                                <li>轉讓：學員需親自至本公司申請辦理後，得將課程轉讓第三人，無須收取手續費。</li>
                                <li>轉點：學員得於合約存續期間申請轉換使用本公司其他營業場所，為轉換時應遵循下列方式：
                                            <ul class="list-unstyled">
                                                <li>(1)	轉換至費用較高之場所：依同方案之價格計算補足差額。</li>
                                                <li>(2)	轉換至費用較低之場所：直接轉換無退費。</li>
                                            </ul>
                                </li>
                                <li>學員於簽署本合約且支付「顧問費用」後，有權於「使用期限」內使用本「體能顧問聘請服務合約」所簽訂之顧問條款。所有體能顧問相關服務需於「使用期限」內使用完畢，逾期且未申請展延之剩餘未使用之課程堂數，將喪失使用權。未使用或喪失使用權之課程堂數，將不予退費。</li>
                                <li>終止合約及退費計算基準：
                                            <ul class="list-unstyled">
                                                <li>(1)	學員得於本合約期限屆滿前，隨時終止本合約，惟因涉及學員權益及金額，請學員須親赴本公司辦理。</li>
                                                <li>(2)	合約簽訂後七日內，學員未使用所約定服務(課程)而解除契約者，全額退還學員已繳費用。</li>
                                                <li>(3)	已繳服務總費用扣除依簽約時課程單堂原價(<% LessonPriceType originalPrice = null; %>
                                                    <%= (originalPrice =_model.OriginalSeriesPrice())!=null 
                                                    ? String.Format("{0:##,###,###,###}",originalPrice.ListPrice) 
                                                    : String.Format("{0:##,###,###,###}",_model.LessonPriceType.ListPrice) %>/人)乘以實際上課堂數之費用。</li>
                                            </ul>
                                </li>
                                <li>場所使用規定
                                            <ul class="list-unstyled">
                                                <li>(1)	學員應遵守本合約及本公司管理規範，並應遵守本公司及專業教練指導，並不得攜帶違禁品或危險物品進入營業場所，及勿攜帶貴重物品至場內。</li>
                                                <li>(2)	學員應於每次使用本公司設備完畢後即行攜離。其有學員未攜離物品經本公司定2個月以上期間公告招領而仍未取回者，依《民法》第607條等相關規定處理。</li>
                                                <li>(3)	學員應了解本公司之置物櫃並非保險箱，其功能僅在於提供學員更換及置放衣物使用，不應用做存放財物用途，學員應避免攜帶貴重物品，否則應自行隨身攜帶並妥善保管。</li>
                                                <li>(4)	使用場所設備應著適當合宜服裝，且場所內不得有賭博、喝酒、吸菸、喧嘩、口出穢言或其他不當或足以影響其他學員權益等行為；於場所指定區域內並不得飲食。</li>
                                                <li>(5)	學員應適當使用場所內各種設備，並自行斟酌個人健康狀況，遵守本公司指導，不作不當運動或參與其體力所無法負荷之活動。</li>
                                            </ul>
                                </li>
                                <li>依個人資料保護法妥為保護學員因簽約提供資料及其相關消費資訊，未經學員簽署同意之前，不得利用於推廣與行銷。但其提供政府相關機關依法查核用途者，不在此限。</li>
                                <li>本公司未授權任何銷售人員、體能顧問就本合約以外事項為任何口頭表示或承諾，您確認本合約構成您與本公司之完整協議。任何與本合約不符之明示、默示或口頭之承諾，對於本公司均不生效力。</li>
                                <li>您瞭解本公司並無授權員工向您介紹營養食品或醫療產品，您同意不得因信賴本公司員工所為之推銷或建議，而向本公司請求任何賠償。</li>
                                <li>本公司為便利學員充分有效使用本公司運動器材設備，得為各種管理規範之訂頒及其修正。</li>
                                <li>本合約如有未盡事宜，由雙方本誠信原則協議之或依民法或其他相關法令定之。因本合約涉訟時，除法律另有規定外，雙方同意以台北地方法院為第一審管轄法院。</li>
                            </ol>
                            <%  }
                                else
                                { %>
                            <ol style="-webkit-padding-start: 20px;">
                                <li>營業時間及設備：營業時間及設備參照各上課地點規定。</li>
                                <li>學員資格：未成年人應得其法定代理人允許或承認。</li>
                                <li>教練課程費入台新銀行信託專戶。</li>
                                <li>學員健康情形與醫療諮詢：您聲明其身體健康狀況良好，並無存在會妨礙其預計使用體能顧問服務之醫療原因或傷病。您確認本公司未在客戶簽署本特約條款之前為您提供醫療建議，且在簽署本特約條款後亦不會為您提供有關身體狀況和使用訓練課程能力的任何建議。如果您目前或簽約後有任何健康或醫療方面的問題，應先諮詢醫生，然後再使用其體能顧問服務之權利。</li>
                                <li>使用期限：顧問服務使用期限係依課程堂數而定，使用期限原則不逾18個月。</li>
                                <li>展延：無法於上述使用期限內完成課程堂數者，得於到期前30日內申請展延使用，並得就未完成部分協商展延3個月內完成，且展延後不得申請轉讓或退費。</li>
                                <li>預約：須於欲使用其體能顧問服務時段至少24小時前向其負責之體能顧問預約其服務與其場地租用權力。</li>
                                <li>取消：如欲取消預約時段，學員必須於原定時間24小時前通知負責之體能顧問，否則該未使用之預約顧問服務仍應記入已使用之體能顧問課程堂數內。</li>
                                <li>遲到：若學員遲到20分鐘以上，其負責之體能顧問有權利視為「缺席」處理，並記入已使用之體能顧問課程堂數內，且本公司無義務於剩餘預約時段內提供服務（特殊情形視情況由體能顧問及本公司協調而定）。</li>
                                <li>學員使用體能顧問服務需完成系統登錄確認。</li>
                                <li>更換教練：學員有權利選擇體能顧問，並瞭解且同意其係購買本公司之課程而非指定體能顧問或其他特定體能顧問之個人服務，若該排定之體能顧問無法提供服務，本公司得指派其他體能顧問進行其服務交接。</li>
                                <li>轉讓：學員需親自至本公司申請辦理後，得將課程轉讓第三人，無須收取手續費。</li>
                                <li>轉點：學員得於合約存續期間申請轉換使用本公司其他營業場所，為轉換時應遵循下列方式：
                                <ul class="list-unstyled">
                                    <li>(1)	轉換至費用較高之場所：依同方案之價格計算補足差額。</li>
                                    <li>(2)	轉換至費用較低之場所：直接轉換無退費。</li>
                                </ul>
                                </li>
                                <li>學員於簽署本合約且支付「顧問費用」後，有權於「使用期限」內使用本「體能顧問聘請服務合約」所簽訂之顧問條款。所有體能顧問相關服務需於「使用期限」內使用完畢，逾期且未申請展延之剩餘未使用之課程堂數，將喪失使用權。未使用或喪失使用權之課程堂數，將不予退費。</li>
                                <li>終止合約及退費計算基準：
                                            <ul class="list-unstyled">
                                                <li>(1)	學員得於本合約期限屆滿前，隨時終止本合約，惟因涉及學員權益及金額，請學員須親赴本公司辦理。</li>
                                                <li>(2)	合約簽訂後七日內，學員未使用所約定服務(課程)而解除契約者，全額退還學員已繳費用。</li>
                                                <li>(3)	已繳服務總費用扣除依簽約時課程單堂原價(<% LessonPriceType originalPrice = null; %>
                                                    <%= (originalPrice =_model.OriginalSeriesPrice())!=null 
                                                    ? String.Format("{0:##,###,###,###}",originalPrice.ListPrice) 
                                                    : String.Format("{0:##,###,###,###}",_model.LessonPriceType.ListPrice) %>/人)乘以實際上課堂數之費用。</li>
                                            </ul>
                                </li>
                                <li>場所使用規定
                                <ul class="list-unstyled">
                                    <li>(1)	學員應遵守本合約及本公司管理規範，並應遵守本公司及專業教練指導，並不得攜帶違禁品或危險物品進入營業場所，及勿攜帶貴重物品至場內。</li>
                                    <li>(2)	學員應於每次使用本公司設備完畢後即行攜離。其有學員未攜離物品經本公司定2個月以上期間公告招領而仍未取回者，依《民法》第607條等相關規定處理。</li>
                                    <li>(3)	學員應了解本公司之置物櫃並非保險箱，其功能僅在於提供學員更換及置放衣物使用，不應用做存放財物用途，學員應避免攜帶貴重物品，否則應自行隨身攜帶並妥善保管。</li>
                                    <li>(4)	使用場所設備應著適當合宜服裝，且場所內不得有賭博、喝酒、吸菸、喧嘩、口出穢言或其他不當或足以影響其他學員權益等行為；於場所指定區域內並不得飲食。</li>
                                    <li>(5)	學員應適當使用場所內各種設備，並自行斟酌個人健康狀況，遵守本公司指導，不作不當運動或參與其體力所無法負荷之活動。</li>
                                </ul>
                                </li>
                                <li>依個人資料保護法妥為保護學員因簽約提供資料及其相關消費資訊，未經學員簽署同意之前，不得利用於推廣與行銷。但其提供政府相關機關依法查核用途者，不在此限。</li>
                                <li>本公司未授權任何銷售人員、體能顧問就本合約以外事項為任何口頭表示或承諾，您確認本合約構成您與本公司之完整協議。任何與本合約不符之明示、默示或口頭之承諾，對於本公司均不生效力。</li>
                                <li>您瞭解本公司並無授權員工向您介紹營養食品或醫療產品，您同意不得因信賴本公司員工所為之推銷或建議，而向本公司請求任何賠償。</li>
                                <li>本公司為便利學員充分有效使用本公司運動器材設備，得為各種管理規範之訂頒及其修正。</li>
                                <li>本合約如有未盡事宜，由雙方本誠信原則協議之或依民法或其他相關法令定之。因本合約涉訟時，除法律另有規定外，雙方同意以台北地方法院為第一審管轄法院。</li>
                            </ol>
                            <%  } %>
                        </td>
                    </tr>
                    <tr>
                        <td>您已詳閱上述各項記載、購買服務之項目及各項特約條款，並確認收到副本。</td>
                    </tr>
                </table>
                <table class="table" style="font-size: 13px">
                    <tr>
                        <td>學員簽名：
                                     <%  ViewBag.SignatureName = "Signature1";
                                         if (_model.CourseContractType.IsGroup == true)
                                         {
                                             foreach (var m in _model.CourseContractMember)
                                             {
                                                 Html.RenderPartial("~/Views/CourseContract/Module/SignHere.ascx", m);
                                             }
                                         }
                                         else
                                         {
                                             Html.RenderPartial("~/Views/CourseContract/Module/SignHere.ascx", _owner);
                                         } %>                  
                        </td>
                        <td>日期：<%= String.Format("{0:yyyy/MM/dd}",_signatureDate) %></td>
                    </tr>
                    <tr>
                        <td colspan="2">家長/監護人簽名：
                        <%  ViewBag.SignatureName = "GuardianSignature1";
                            Html.RenderPartial("~/Views/CourseContract/Module/SignHere.ascx", _owner); %>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</div>
<%  if (_model.CourseContractType.ContractCode == "CFA")
    { %>
<div class="row">
    <div class="col-md-12">
        <div class="well padding-5 well-light" style="width: 23cm; height: 30cm">
            <h2 class="text-center"><b>附表-學員名單</b></h2>
            <div class="<%= Request["pdf"]=="1" ? "bs-example bs-example-type seal" : "bs-example bs-example-type" %>">
                <table class="table" style="font-size: 16px">
                    <tr>
                        <td>本人同意並授權以下人員得使用本人與超越體能顧問有限公司購買之體能顧問服務課程，任一人員(含本人)使用體能顧問服務，皆需計入體能顧問服務次數內，並應共同遵守合約及特約條款之規定。</td>
                    </tr>
                </table>
                <table class="table table-bordered" style="font-size: 16px">
                    <thead>
                        <th>姓名</th>
                        <th>身分證字號</th>
                        <th>行動電話</th>
                        <th>出生日期</th>
                        <th>性別</th>
                    </thead>
                    <tbody>
                        <%  foreach (var m in _model.CourseContractMember)
                            { %>
                        <tr>
                            <td><%= m.UserProfile.RealName %></td>
                            <td><%= m.UserProfile.UserProfileExtension.IDNo %></td>
                            <td><%= m.UserProfile.Phone %></td>
                            <td><%= String.Format("{0:yyyy/MM/dd}",m.UserProfile.Birthday) %></td>
                            <td><%= m.UserProfile.UserProfileExtension.Gender=="F" ? "女" : "男" %></td>
                        </tr>
                        <%  } %>
                    </tbody>
                </table>
                <table class="table" style="font-size: 16px">
                    <tr>
                        <td class="text-right">簽名：
                            <%  ViewBag.SignatureName = "Signature2";
                                Html.RenderPartial("~/Views/CourseContract/Module/SignHere.ascx", _owner);
                                %>                        
                        </td>
                        <td>日期：<%= String.Format("{0:yyyy/MM/dd}",_signatureDate) %></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</div>
<%  } %>


<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    CourseContract _model;
    CourseContractMember _owner;
    DateTime? _signatureDate;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (CourseContract)this.Model;
        _owner = _model.CourseContractMember.Where(m => m.UID == _model.OwnerID).First();
        var item = _model.CourseContractLevel.Where(l => l.LevelID == (int)Naming.CourseContractStatus.待審核).FirstOrDefault();
        if (item != null)
        {
            _signatureDate = item.LevelDate;
        }
        else
        {
            _signatureDate = DateTime.Now;
        }
    }

</script>
