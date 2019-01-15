<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.Mvc.ViewUserControl" %>
<%  if (ViewBag.KnobJS == null)
    {
        ViewBag.KnobJS = true;  %>
<script src="bundles/knob.bundle.js"></script>
<script>

    function drawKnob($knob, value, duration) {
        $knob.knob();
        $({
            animatedVal: 0
        }).animate({
            animatedVal: value
        }, {
                duration: duration,
                easing: "swing",
                step: function () {
                    $knob.val(Math.ceil(this.animatedVal)).trigger("change");
                }
            });
    }
</script>
<%  } %>
<script runat="server">

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
    }

</script>
