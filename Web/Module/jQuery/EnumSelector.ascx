<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="EnumSelector.ascx.cs" Inherits="CommonLib.Web.Module.jQuery.EnumSelector" %>
<select name="<%= FieldName %>">
    <% if(!String.IsNullOrEmpty(SelectorIndication)) { %>
    <option value="<%: SelectorIndicationValue %>"><%: SelectorIndication %></option>
    <% } %>
    <% foreach(var item in _items) { %>
    <option value="<%: item.Key %>"><%: item.Value %></option>
    <% } %>
</select>
<script>
    $(function () {
        $('select[name="<%= FieldName %>"]').val('<%= FieldName!=null && Request[FieldName]!=null ? Request[FieldName] : DefaultValue %>');
    });
</script>
