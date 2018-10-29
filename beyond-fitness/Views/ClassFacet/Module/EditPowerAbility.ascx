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

<div id="<%= _dialog %>" title="編輯人格與運動能力" class="bg-color-darken">
    <div class="modal-body bg-color-darken txt-color-white">
        <div class="row">
            <div class="col col-12">
                <div class="user">
                    <a onclick="commitPowerAbility('多變型（初階）');" class="btn btn-circle btn-warning">變</a>
                    <email>多變型（初階）</email>
                </div>
                <div class="user">
                    <a onclick="commitPowerAbility('多變型（中階）');" class="btn btn-circle btn-success">變</a>
                    <email>多變型（中階）</email>
                </div>
                <div class="user">
                    <a onclick="commitPowerAbility('多變型（高階）');" class="btn btn-circle btn-danger">變</a>
                    <email>多變型（高階）</email>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col col-12">
                <div class="user">
                    <a onclick="commitPowerAbility('保守型（初階）');" class="btn btn-circle btn-warning">守</a>
                    <email>保守型（初階）</email>
                </div>
                <div class="user">
                    <a onclick="commitPowerAbility('保守型（中階）');" class="btn btn-circle btn-success">守</a>
                    <email>保守型（中階）</email>
                </div>
                <div class="user">
                    <a onclick="commitPowerAbility('保守型（高階）');" class="btn btn-circle btn-danger">守</a>
                    <email>保守型（高階）</email>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col col-12">
                <div class="user">
                    <a onclick="commitPowerAbility('混合型（初階）');" class="btn btn-circle btn-warning">混</a>
                    <email>混合型（初階）</email>
                </div>
                <div class="user">
                    <a onclick="commitPowerAbility('混合型（中階）');" class="btn btn-circle btn-success">混</a>
                    <email>混合型（中階）</email>
                </div>
                <div class="user">
                    <a onclick="commitPowerAbility('混合型（高階）');" class="btn btn-circle btn-danger">混</a>
                    <email>混合型（高階）</email>
                </div>
            </div>
        </div>
        <div class="row">
            <form action="#" autofocus class="smart-form">
                <fieldset>
                    <section>
                        <div class="row">
                            <div class="col col-6">
                                <div class="rating">
                                    <%  for (int i = 5; i > 0; i--)
                                        { %>
                                    <input type="radio" id="Flexibility-<%= i %>" name="Flexibility" value="<%= i %>">
                                    <label for="Flexibility-<%= i %>"><i class="fa fa-star"></i></label>
                                    <%  } %>
                                    柔軟度
                                </div>
                            </div>
                            <div class="col col-6">
                                <div class="rating">
                                    <%  for (int i = 5; i > 0; i--)
                                        { %>
                                    <input type="radio" id="MuscleStrength-<%= i %>" name="MuscleStrength" value="<%= i %>">
                                    <label for="MuscleStrength-<%= i %>"><i class="fa fa-star"></i></label>
                                    <%  } %>
                                    相對肌力
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col col-6">
                                <div class="rating">
                                    <%  for (int i = 5; i > 0; i--)
                                        { %>
                                    <input type="radio" id="Cardiopulmonary-<%= i %>" name="Cardiopulmonary" value="<%= i %>">
                                    <label for="Cardiopulmonary-<%= i %>"><i class="fa fa-star"></i></label>
                                    <%  } %>                                    
                                    心肺適能
                                </div>
                            </div>
                        </div>
                    </section>
                </fieldset>
            </form>
        </div>
        <div class="row">
            <div style="width: 400px">
                <canvas id="<%= _chartID %>"></canvas>
            </div>
        </div>
    </div>
    <script>
        $('#<%= _dialog %>').dialog({
            //autoOpen : false,
            resizable: true,
            modal: true,
            width: 'auto',
            title: "<h4 class='modal-title'><i class='fa-fw fa fa-cog'></i>  設定人格與運動能力</h4>",
            close: function (event, ui) {
                $('#<%= _dialog %>').remove();
            },
        });

        function commitPowerAbility(ability,feature,point) {
            showLoading();
            $.post('<%= Url.Action("CommitPowerAbility", "ClassFacet", new { _model.UID }) %>', { 'ability': ability,'feature':feature,'point':point }, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    if (data.result) {
                        if (feature) {
                            showFeatureChart();
                        } else {
                            showAbility(ability);
                            $('#<%= _dialog %>').dialog('close');
                        }
                    } else {
                        alert(data.message);
                    }
                } else {
                    $(data).appendTo($('body'));
                    $('#<%= _dialog %>').dialog('close');
                }
            });
        }
        //debugger;
        var RadarConfig = {
            type: 'radar',
            data: {
                labels: ["柔軟度", "相對肌力", "心肺適能"],
                datasets: [{
                    label: "分佈圖",
                    backgroundColor: "rgba(233,157,201,.43)",
                    pointBackgroundColor: "rgba(220,220,220,1)",
                    data: <%= _item!=null ? $"[{_item.Flexibility},{_item.MuscleStrength},{_item.Cardiopulmonary}]" : "[, , ]"  %>,
                }]
            },
            options: {
                legend: {
                    display: false
                },

                scale: {
                    reverse: false,
                    display: true,
                    ticks: {
                        showLabelBackdrop: false,
                        beginAtZero: true,
                        backdropColor: '#FAF0E6',
                        maxTicksLimit: 5,
                        max: 5,
                        fontSize: 5,
                        backdropPaddingX: 5,
                        backdropPaddingY: 5
                    },
                    gridLines: {
                        color: "#888888",
                        lineWidth: 1
                    },
                    pointLabels: {
                        fontSize: 12,
                        fontColor: "#AAAAAA"
                    }
                }
            }
        };

        function showFeatureChart() {
            showLoading();
            $.post('<%= Url.Action("GetPowerAbility", "ClassFacet", new { _model.UID }) %>', {}, function (data) {
                hideLoading();
                if ($.isPlainObject(data)) {
                    RadarConfig.data.datasets[0].data = [data.Flexibility,data.MuscleStrength,data.Cardiopulmonary];
                    $global.myRadar.update(RadarConfig);
                } else {
                    $(data).appendTo($('body'));
                }
            });
        }

        $(function () {

            $('#<%= _dialog %> input:radio').on('click', function (evt) {
                commitPowerAbility(null, this.name, this.value);
            });

            if($global.chartJS==undefined) {
                loadScript('<%= VirtualPathUtility.ToAbsolute("~/js/plugin/chartjs2_7_2/chart.min.js") %>',function() { 
                    $global.chartJS=true;
                    $global.myRadar = new Chart(document.getElementById("<%= _chartID %>"), RadarConfig);
                });
            } else {
                $global.myRadar = new Chart(document.getElementById("<%= _chartID %>"), RadarConfig);
            }

    <%  if(_item!=null)
        {
            if(_item.Flexibility.HasValue)
            {   %>
            $('#<%= _dialog %> input:radio[name="Flexibility"][value="<%= _item.Flexibility %>"]').prop('checked',true);
        <%  }
            if(_item.Cardiopulmonary.HasValue)
            {   %>
            $('#<%= _dialog %> input:radio[name="Cardiopulmonary"][value="<%= _item.Cardiopulmonary %>"]').prop('checked',true);
        <%  }
            if(_item.MuscleStrength.HasValue)
            {   %>
            $('#<%= _dialog %> input:radio[name="MuscleStrength"][value="<%= _item.MuscleStrength %>"]').prop('checked',true);
        <%  }
        }   %>

        });

    </script>
</div>



<script runat="server">

    ModelSource<UserProfile> models;
    ModelStateDictionary _modelState;
    UserProfile _model;
    String _dialog = "powerAbility" + DateTime.Now.Ticks;
    PersonalExercisePurpose _item;
    string _chartID = "radarChart" + DateTime.Now.Ticks;

    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        models = ((SampleController<UserProfile>)ViewContext.Controller).DataSource;
        _modelState = (ModelStateDictionary)ViewBag.ModelState;
        _model = (UserProfile)this.Model;
        _item = _model.PersonalExercisePurpose;
    }

</script>
