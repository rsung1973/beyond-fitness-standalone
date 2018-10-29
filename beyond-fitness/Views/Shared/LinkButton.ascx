<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>

<a id='<%= _model.Id??"a"+counter %>' class="<%= _model.ButtonStyle %>" href="<%= VirtualPathUtility.ToAbsolute(_model.Href) %>"><%= _model.Value %> <i class="<%= _model.IconStyle %>" aria-hidden="true"></i></a>

<script runat="server">

    InputViewModel _model;
    int? counter;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _model = (InputViewModel)this.Model;
        counter = (int?)ViewBag.Counter;
        if(counter.HasValue)
        {
            counter = counter.Value + 1;
        }
        else
        {
            counter = 0;
        }
        ViewBag.Counter = counter;
    }
</script>

