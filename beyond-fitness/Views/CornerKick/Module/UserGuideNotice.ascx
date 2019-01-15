<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Models.Timeline" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%  if (_item != null)
    {
        var item = _item.GuideEventList.Where(v => v.SystemEventID == __EVENT_ID).FirstOrDefault();
        if(item!=null)
        {   %>
<li>
    <i class="livicon-evo prefix" data-options="name: angle-wide-right-alt.svg; size: 30px; style: solid; autoPlay:true"></i>
    <a href="javascript:gtag('event', '新手上路', {  'event_category': '連結點擊',  'event_label': '我的通知'});window.location.href = '<%= Url.Action(item.SystemEventBulletin.ActionName, item.SystemEventBulletin.ControllerName,new { keyID = HttpUtility.UrlEncode(item.EventID.EncryptKey()) }) %>';"><%= _model.UserProfileExtension.Gender == "F" ? "親愛的" : "兄弟" %>，跟著 Beyond 走，新手導航去</a>
</li>
<%      }
    } %>

<script runat="server">

    ModelStateDictionary _modelState;
    ModelSource<UserProfile> models;
    UserProfile _model;
    List<TimelineEvent> _items;
    UserGuideEvent _item;

    public const int __EVENT_ID = 1;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _model = (UserProfile)this.Model;
        _items = (List<TimelineEvent>)ViewBag.UserNotice;

        _item = _model.CheckUserGuideEvent(models);

        if(_item!=null)
        {
            _items.Add(_item);
        }

    }

</script>
