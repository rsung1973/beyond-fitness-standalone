<%@  Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq.Expressions" %>
<%@ Import Namespace="System.Web.Mvc.Html" %>
<%@ Import Namespace="WebHome.Helper" %>
<%@ Import Namespace="WebHome.Models.Locale" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>
<%@ Import Namespace="WebHome.Models.DataEntity" %>
<%@ Import Namespace="WebHome.Controllers" %>
<%@ Register Src="~/Views/Shared/PageBanner.ascx" TagPrefix="uc1" TagName="PageBanner" %>

<% if (_attachment != null && _attachment.Count() > 0)
    { %>

<label class="label" for="nickname">圖片(鏈結網址)：</label>
<div class="row">
    <div class="col col-12">
        <asp:repeater id="rpList" runat="server" itemtype="WebHome.Models.DataEntity.Attachment">
        <ItemTemplate>
            <label class="radio font-md">
                <input type="radio" name="rbTitleImg" value="<%# Item.AttachmentID %>" />
                <i></i>設成主題圖片
            </label>
            <img width="60" src="<%# VirtualPathUtility.ToAbsolute("~/Information/GetResource/"+Item.AttachmentID) + "?stretch=false" %>" />  
             <a  onclick="javascript:deleteResource(<%# Item.AttachmentID %>)" class="btn btn-primary"><i class="fa fa-fw fa-trash-alt"></i> 刪除</a>
            <label  class="label" class="form-md">
                ( <%# VirtualPathUtility.ToAbsolute("~/Information/GetResource/"+Item.AttachmentID + "?stretch=true") %> )               
            </label>
            
        </ItemTemplate>
    </asp:repeater>
    </div>
</div>
<% if (_item.Illustration.HasValue)
    { %>
<script>
    $(function () {
        $('input[name="rbTitleImg"][value="<%= _item.Illustration %>"]:radio').prop('checked', true);
    });
</script>
<%  } %>
<% } %>

<script runat="server">

    ModelSource<UserProfile> models;
    Article _item;
    IEnumerable<Attachment> _attachment;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _item = (Article)this.Model;
        if (_item != null)
        {
            _attachment = _item.Document.Attachments;
            rpList.DataSource = _attachment;
            rpList.DataBind();
        }
    }

</script>
