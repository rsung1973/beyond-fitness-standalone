/*
* Licensed to the Apache Software Foundation (ASF) under one
* or more contributor license agreements.  See the NOTICE file
* distributed with this work for additional information
* regarding copyright ownership.  The ASF licenses this file
* to you under the Apache License, Version 2.0 (the
* "License"); you may not use this file except in compliance
* with the License.  You may obtain a copy of the License at
*
*   http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing,
* software distributed under the License is distributed on an
* "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
* KIND, either express or implied.  See the License for the
* specific language governing permissions and limitations
* under the License.
*/

(function(root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        define(['exports', 'echarts'], factory);
    } else if (
        typeof exports === 'object' &&
        typeof exports.nodeName !== 'string'
    ) {
        // CommonJS
        factory(exports, require('echarts/lib/echarts'));
    } else {
        // Browser globals
        factory({}, root.echarts);
    }
})(this, function(exports, echarts) {
    var log = function(msg) {
        if (typeof console !== 'undefined') {
            console && console.error && console.error(msg);
        }
    };
    if (!echarts) {
        log('ECharts is not Loaded');
        return;
    }

    var colorPalette = [
            "#ffb980",
            "#d87a80",
            "#2ec7c9",
            "#b6a2de",
            "#5ab1ef",            
            "#8d98b3",
            "#e5cf0d",
            "#97b552",
            "#95706d",
            "#dc69aa",
            "#07a2a4",
            "#9a7fd1",
            "#588dd5",
            "#f5994e",
            "#c05050",
            "#59678c",
            "#c9ab00",
            "#7eb00a",
            "#6f5553",
            "#c14089"
    ];

    var theme = {
        color: colorPalette,
        "backgroundColor": "#1c222c",

        "title": {
            "textStyle": {
                "color": "#008acd",
                 "fontWeight": "bold",
            },
            "subtextStyle": {
                "color": "#aaaaaa",
                "fontWeight": "bold",
                "fontSize": "14"
            }
        },

        "visualMap": {
            itemWidth: 15,
            "color": ["#5ab1ef", "#e0ffff"]
        },

        "toolbox": {
            "iconStyle": {
                "normal": {
                    "borderColor": "#97b552"
                },
                "emphasis": {
                    "borderColor": "#97b552"
                }
            }
        },

        "tooltip": {
            "axisPointer": {
                "lineStyle": {
                    "color": "#999999",
                    "width": "1"
                },
                "crossStyle": {
                    "color": "#999999",
                    "width": "1"
                }
            }
        },

        "dataZoom": {
            "backgroundColor": "rgba(47,69,84,0)",
            "dataBackgroundColor": "#efefff",
            "fillerColor": "rgba(182,162,222,0.2)",
            "handleColor": "#008acd",
            "handleSize": "100%",
            "textStyle": {
                "color": "#333333"
            }
        },

        grid: {
            borderColor: '#eee',
            left: '3%',
            right: '4%',
            bottom: '3%',
            containLabel: true
        },

        "line": {
            "itemStyle": {
                "borderWidth": 1
            },
            "lineStyle": {
                "width": 2
            },
            "label" : {
                "show": "true",
                "fontWeight": "bold",
                "position": "top",
                "textBorderColor": "transparent"
            },
            "symbolSize": 10,
            "symbol": "circle",
            "smooth": true
        },
        "radar": {
            "itemStyle": {
                "borderWidth": 1
            },
            "lineStyle": {
                "width": 2
            },
            "symbolSize": 3,
            "symbol": "emptyCircle",
            "smooth": true
        },
        "pie": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ccc"
            }
        },
        "scatter": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ccc"
            }
        },
        "boxplot": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ccc"
            }
        },
        "parallel": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ccc"
            }
        },
        "sankey": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ccc"
            }
        },
        "funnel": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ccc"
            }
        },
        "gauge": {
            "title": {
                "color": "#fff"
            },
            "axisLabel": {
                "color": "#cccccc"
            },
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ccc",
            }
        },
        "candlestick": {
            "itemStyle": {
                "color": "#d87a80",
                "color0": "#2ec7c9",
                "borderColor": "#d87a80",
                "borderColor0": "#2ec7c9",
                "borderWidth": 1
            }
        },
        "graph": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ccc"
            },
            "lineStyle": {
                "width": 1,
                "color": "#aaaaaa"
            },
            "symbolSize": 3,
            "symbol": "emptyCircle",
            "smooth": true,
            "color": [
                "#2ec7c9",
                "#b6a2de",
                "#5ab1ef",
                "#ffb980",
                "#d87a80",
                "#8d98b3",
                "#e5cf0d",
                "#97b552",
                "#95706d",
                "#dc69aa",
                "#07a2a4",
                "#9a7fd1",
                "#588dd5",
                "#f5994e",
                "#c05050",
                "#59678c",
                "#c9ab00",
                "#7eb00a",
                "#6f5553",
                "#c14089"
            ],
            "label": {
                "color": "#eeeeee"
            }
        },
        "map": {
            "itemStyle": {
                "normal": {
                    "areaColor": "#dddddd",
                    "borderColor": "#eeeeee",
                    "borderWidth": 0.5
                },
                "emphasis": {
                    "areaColor": "rgba(254,153,78,1)",
                    "borderColor": "#444",
                    "borderWidth": 1
                }
            },
            "label": {
                "normal": {
                    "textStyle": {
                        "color": "#d87a80"
                    }
                },
                "emphasis": {
                    "textStyle": {
                        "color": "rgb(100,0,0)"
                    }
                }
            }
        },
        "geo": {
            "itemStyle": {
                "normal": {
                    "areaColor": "#dddddd",
                    "borderColor": "#eeeeee",
                    "borderWidth": 0.5
                },
                "emphasis": {
                    "areaColor": "rgba(254,153,78,1)",
                    "borderColor": "#444",
                    "borderWidth": 1
                }
            },
            "label": {
                "normal": {
                    "textStyle": {
                        "color": "#d87a80"
                    }
                },
                "emphasis": {
                    "textStyle": {
                        "color": "rgb(100,0,0)"
                    }
                }
            }
        },
        "categoryAxis": {
            "axisLine": {
                "show": true,
                "lineStyle": {
                    "color": "#999999"
                }
            },
            "axisTick": {
                "show": true,
                "lineStyle": {
                    "color": "#cccccc"
                }
            },
            "axisLabel": {
                "show": true,
                "textStyle": {
                    "color": "#cccccc"
                }
            },
            "splitLine": {
                "show": false,
                "lineStyle": {
                    "color": [
                        "#444d55"
                    ],
                    "type": "dashed"
                }
            },
            "splitArea": {
                "show": false,
                "areaStyle": {
                    "color": [
                        "rgba(0,0,0,0)",
                        "rgba(0,0,0,0)"
                    ]
                }
            }
        },
        "valueAxis": {
            "axisLine": {
                "show": true,
                "lineStyle": {
                    "color": "#999999"
                }
            },
            "axisTick": {
                "show": true,
                "lineStyle": {
                    "color": "#cccccc"
                }
            },
            "axisLabel": {
                "show": true,
                "textStyle": {
                    "color": "#cccccc"
                }
            },
            "splitLine": {
                "show": true,
                "lineStyle": {
                    "color": [
                        "#444d55"
                    ],
                    "type": "dashed"
                }
            },
            "splitArea": {
                "show": true,
                "areaStyle": {
                    "color": [
                        "transparent"
                    ]
                }
            }
        },
        "logAxis": {
            "axisLine": {
                "show": true,
                "lineStyle": {
                    "color": "#999999"
                }
            },
            "axisTick": {
                "show": true,
                "lineStyle": {
                    "color": "#cccccc"
                }
            },
            "axisLabel": {
                "show": true,
                "textStyle": {
                    "color": "#cccccc"
                }
            },
            "splitLine": {
                "show": true,
                "lineStyle": {
                    "color": [
                        "#eee"
                    ]
                }
            },
            "splitArea": {
                "show": true,
                "areaStyle": {
                    "color": [
                        "rgba(250,250,250,0.3)",
                        "rgba(200,200,200,0.3)"
                    ]
                }
            }
        },

        "bar": {      
            "itemStyle": {
                //"barBorderWidth": "0",
                //"barBorderColor": "#ccc"
            },
            "label" : {
                "show": "true",
                "fontWeight": "bold",
                "position": "top",
                "textBorderColor": "transparent",
                "color": "#fff"
            },
        },
        "timeAxis": {
            "axisLine": {
                "show": true,
                "lineStyle": {
                    "color": "#999999"
                }
            },
            "axisTick": {
                "show": true,
                "lineStyle": {
                    "color": "#cccccc"
                }
            },
            "axisLabel": {
                "show": true,
                "textStyle": {
                    "color": "#eeeeee"
                }
            },
            "splitLine": {
                "show": true,
                "lineStyle": {
                    "color": [
                        "#eee"
                    ]
                }
            },
            "splitArea": {
                "show": false,
                "areaStyle": {
                    "color": [
                        "rgba(250,250,250,0.3)",
                        "rgba(200,200,200,0.3)"
                    ]
                }
            }
        },

        "legend": {
            "textStyle": {
                "color": "#cccccc"
            }
        },

        "timeline": {
            "lineStyle": {
                "color": "#008acd",
                "width": "3"
            },
            "itemStyle": {
                "normal": {
                    "color": "#008acd",
                    "borderWidth": "1"
                },
                "emphasis": {
                    "color": "#a9334c"
                }
            },
            "controlStyle": {
                "normal": {
                    "color": "#008acd",
                    "borderColor": "#008acd",
                    "borderWidth": 0.5
                },
                "emphasis": {
                    "color": "#008acd",
                    "borderColor": "#008acd",
                    "borderWidth": 0.5
                }
            },
            "checkpointStyle": {
                "color": "#2ec7c9",
                "borderColor": "#2ec7c9"
            },
            "label": {
                "normal": {
                    "textStyle": {
                        "color": "#008acd"
                    }
                },
                "emphasis": {
                    "textStyle": {
                        "color": "#008acd"
                    }
                }
            }
        },

        "markPoint": {
            "label": {
                "color": "#eeeeee"
            },
            "emphasis": {
                "label": {
                    "color": "#eeeeee"
                }
            }
        }
    };

    echarts.registerTheme('macarons_nero', theme);
});
