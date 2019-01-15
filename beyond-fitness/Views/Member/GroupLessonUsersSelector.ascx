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

<%  if (_items.Length > 0)
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

<script runat="server">

    ModelStateDictionary _modelState;
    RegisterLesson _model;
    RegisterLesson[] _items;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (RegisterLesson)this.Model;
        _items = (RegisterLesson[])ViewBag.DataItems;
    }

</script>
