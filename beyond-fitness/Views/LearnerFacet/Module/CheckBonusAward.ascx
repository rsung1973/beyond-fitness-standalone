<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>

    <div class="panel-body status smart-form vote">
        <div class="who clearfix">
            <%  var lesson = _model.RegisterLesson.OrderByDescending(r => r.RegisterID).First();
                lesson.ServingCoach.UserProfile.PictureID.RenderUserPicture(Writer, new { @class = "busy", @style = "width:40px" });
                var currentBonusPoint = _model.BonusPoint(models); %>
            <span class="name font-lg"><b><%= lesson.ServingCoach.UserProfile.FullName() %></b></span>
            <span class="from font-md"><b>Hi, <%= _model.FullName() %></b>您現在已經累積點數<b><%= currentBonusPoint %>點</b>，截至目前為止已兌換的商品如下</span>
        </div>
        <ul class="comments">
            <%  foreach (var item in _model.LearnerAward)
                { %>
            <li>
                <label class="radio font-md">
                    <i class="far fa-check-square"></i><%= item.BonusAwardingItem.ItemName %>：<%= item.BonusAwardingItem.PointValue %>點
                </label>
            </li>
            <%  } %>
        </ul>
        <div class="image font-md">
            <strong>若您仍有足夠點數可參考以下商品，若有興趣可至各分店兌換喔！<br />
                商品兌換後恕不退換！
            </strong>
        </div>
    </div>
    <div class="product-content product-wrap clearfix bg-color-darken">
        <div class="row">
        <%  foreach (var item in models.GetTable<BonusAwardingItem>()
                .Where(b=>!b.Status.HasValue || b.Status!=0)
                .OrderByDescending(b=>b.OrderIndex))
            {
                %>
            <div class="col-sm-6 col-md-6 col-lg-4">
                <!-- product -->
                <div class="product-content product-wrap clearfix">
                    <div class="row">
                        <div class="col-md-5 col-sm-6 col-xs-6">
                            <div class="product-image" style="min-height: auto;">
                                <img src="<%= item.SampleUrl!=null ? VirtualPathUtility.ToAbsolute(item.SampleUrl) : null %>" alt="194x228" class="img-responsive"/>
                                <span class="tag2 hot">HOT
                                </span>
                            </div>
                        </div>
                        <div class="col-md-7 col-sm-6 col-xs-6">
                            <div class="product-deatil" style="min-height: auto;">
                                <h5 class="name">
                                    <a href="#"><%= item.ItemName %><%--<span>價值：<%= item.Price %></span>--%>
                                    </a>
                                </h5>
                                <p class="price-container">
                                    <span><%= item.PointValue %>點</span>
                                </p>
                                <span class="tag1"></span>
                            <%  if ((item.ExchangeableOnline == true || _profile.IsAssistant() || _profile.IsAuthorizedSysAdmin() || _profile.IsCoach()) && currentBonusPoint>=item.PointValue)
                                {
                                    if (item.BonusAwardingIndication != null && item.BonusAwardingIndication.Indication == "AwardingLessonGift")
                                    { %>
                                    <a href="#" onclick="awardingLessonGift(<%= item.ItemID %>);" class="btn bg-color-red">立即兌換</a>
                            <%      }
                                    else
                                    {   %>
                                    <a href="#" onclick="exchangeBonus(<%= item.ItemID %>);" class="btn bg-color-red">立即兌換</a>
                            <%      }
                                } %>
                            </div>
                        </div>
                    </div>
                    <!-- end product -->
                </div>
            </div>
        <%      
            } %>
        </div>
    </div>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    UserProfile _profile;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _profile = Context.GetUser();
    }

</script>
