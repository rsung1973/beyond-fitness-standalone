<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%@ Import Namespace="WebHome.Models.ViewModel" %>

<fieldset>
    <section>
        <label class="input">
            <i class="icon-append fa fa-envelope-o "></i>
            <input type="<%= _model.InputType ?? "text" %>" class="form-control input-lg" placeholder="<%= _model.PlaceHolder %>" name="<%= _model.Name %>" id="<%= _model.Id %>" value="<%= _model.Value %>"/>
        </label>
    </section>
</fieldset>
<%--<span id="<%= _model.Id+"Icon" %>" class="<%= _model.IsValid == true ? "glyphicon glyphicon-ok form-control-feedback text-success" 
        : _model.IsValid == false ? "glyphicon glyphicon-remove form-control-feedback text-danger" : "glyphicon form-control-feedback text-success" %>" aria-hidden="true"></span>
<span id="<%= _model.Id+"Status" %>" class="<%= _model.IsValid == false ? "error" : "sr-only" %>"><%= _model.ErrorMessage %></span>--%>

<script runat="server">

    InputViewModel _model;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        _model = (InputViewModel)this.Model;
    }
</script>

