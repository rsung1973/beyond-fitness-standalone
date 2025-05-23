(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        define(['exports', 'echarts'], factory);
    } else if (typeof exports === 'object' && typeof exports.nodeName !== 'string') {
        // CommonJS
        factory(exports, require('echarts'));
    } else {
        // Browser globals
        factory({}, root.echarts);
    }
}(this, function (exports, echarts) {
    var log = function (msg) {
        if (typeof console !== 'undefined') {
            console && console.error && console.error(msg);
        }
    };
    if (!echarts) {
        log('ECharts is not Loaded');
        return;
    }
    echarts.registerTheme('macarons', {
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
        "backgroundColor": "#ffffff",
        "textStyle": {},
        "title": {
            "textStyle": {
                "color": "#008acd"
            },
            "subtextStyle": {
                "color": "#aaaaaa"
            }
        },
        "line": {
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
        "bar": {
            "itemStyle": {
                "barBorderWidth": 0,
                "barBorderColor": "#ccc"
            }
        },
        "pie": {
            "color": "rgba(170,170,170,0.95)",      
            "itemStyle": {
                "borderWidth": 0,
                "borderColor": "#ccc",
                "textBorderColor": "transparent",
                "color": "rgba(170,170,170,0.95)",      
            }
        },
        "scatter": {
            "itemStyle": {
                "borderWidth": 0,
                "borderColor": "#ccc"
            }
        },
        "boxplot": {
            "itemStyle": {
                "borderWidth": 0,
                "borderColor": "#ccc"
            }
        },
        "parallel": {
            "itemStyle": {
                "borderWidth": 0,
                "borderColor": "#ccc"
            }
        },
        "sankey": {
            "itemStyle": {
                "borderWidth": 0,
                "borderColor": "#ccc"
            }
        },
        "funnel": {
            "itemStyle": {
                "borderWidth": 0,
                "borderColor": "#ccc"
            }
        },
        "gauge": {
            "itemStyle": {
                "borderWidth": 0,
                "borderColor": "#ccc"
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
                "borderWidth": 0,
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
                "color": "transparent",               
            }
        },
        "map": {
            "itemStyle": {
                "areaColor": "#dddddd",
                "borderColor": "#eeeeee",
                "borderWidth": 0.5
            },
            "label": {
                "color": "#d87a80"
            },
            "emphasis": {
                "itemStyle": {
                    "areaColor": "rgba(254,153,78,1)",
                    "borderColor": "#444",
                    "borderWidth": 1
                },
                "label": {
                    "color": "rgb(100,0,0)"
                }
            }
        },
        "geo": {
            "itemStyle": {
                "areaColor": "#dddddd",
                "borderColor": "#eeeeee",
                "borderWidth": 0.5
            },
            "label": {
                "color": "#d87a80"
            },
            "emphasis": {
                "itemStyle": {
                    "areaColor": "rgba(254,153,78,1)",
                    "borderColor": "#444",
                    "borderWidth": 1
                },
                "label": {
                    "color": "rgb(100,0,0)"
                }
            }
        },
        "categoryAxis": {
            "axisLine": {
                "show": true,
                "lineStyle": {
                    "color": "#008acd"
                }
            },
            "axisTick": {
                "show": true,
                "lineStyle": {
                    "color": "#aab2bd"
                }
            },
            "axisLabel": {
                "show": true,
                "color": "#aab2bd"
            },
            "splitLine": {
                "show": false,
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
        "valueAxis": {
            "axisLine": {
                "show": true,
                "lineStyle": {
                    "color": "#008acd"
                }
            },
            "axisTick": {
                "show": true,
                "lineStyle": {
                    "color": "#aab2bd"
                }
            },
            "axisLabel": {
                "show": true,
                "color": "#aab2bd"
            },
            "splitLine": {
                "show": true,
                "lineStyle": {
                    "color": [
                        "#aab2bd"
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
        "logAxis": {
            "axisLine": {
                "show": true,
                "lineStyle": {
                    "color": "#008acd"
                }
            },
            "axisTick": {
                "show": true,
                "lineStyle": {
                    "color": "#aab2bd"
                }
            },
            "axisLabel": {
                "show": true,
                "color": "#aab2bd"
            },
            "splitLine": {
                "show": true,
                "lineStyle": {
                    "color": [
                        "#aab2bd"
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
        "timeAxis": {
            "axisLine": {
                "show": true,
                "lineStyle": {
                    "color": "#008acd"
                }
            },
            "axisTick": {
                "show": true,
                "lineStyle": {
                    "color": "#aab2bd"
                }
            },
            "axisLabel": {
                "show": true,
                "color": "#aab2bd"
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
        "toolbox": {
            "iconStyle": {
                "borderColor": "#2ec7c9"
            },
            "emphasis": {
                "iconStyle": {
                    "borderColor": "#18a4a6"
                }
            }
        },
        "legend": {           
            "textStyle": {
                "color": "#aab2bd"
            }
        },
        "tooltip": {
            "axisPointer": {
                "lineStyle": {
                    "color": "#008acd",
                    "width": "1"
                },
                "crossStyle": {
                    "color": "#008acd",
                    "width": "1"
                }
            }
        },
        "timeline": {
            "lineStyle": {
                "color": "#008acd",
                "width": 1
            },
            "itemStyle": {
                "color": "#008acd",
                "borderWidth": 1
            },
            "controlStyle": {
                "color": "#008acd",
                "borderColor": "#008acd",
                "borderWidth": 0.5
            },
            "checkpointStyle": {
                "color": "#2ec7c9",
                "borderColor": "#2ec7c9"
            },
            "label": {
                "color": "#008acd"
            },
            "emphasis": {
                "itemStyle": {
                    "color": "#a9334c"
                },
                "controlStyle": {
                    "color": "#008acd",
                    "borderColor": "#008acd",
                    "borderWidth": 0.5
                },
                "label": {
                    "color": "#008acd"
                }
            }
        },
        "visualMap": {
            "color": [
                "#5ab1ef",
                "#e0ffff"
            ]
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
        "markPoint": {
            "label": {
                "color": "transparent"
            },
            "emphasis": {
                "label": {
                    "color": "transparent"
                }
            }
        },        
        "grid": {
            "borderColor": "#AAB2BD",
            "left": "3%",
            "right": "4%",
            "bottom": "3%",
            "containLabel": true
        },
        "calendar": {
            "itemStyle": {
                "normal": {
                    "color": "#AAB2BD",
                    "borderWidth": 1,
                    "borderColor": "#fff",                    
                }                        
            },
            "splitLine": {
                "show": true,
                "lineStyle": {
                    "color": [
                        "#AAB2BD"
                    ],
                    "type": "dashed"
                }
            },
            "monthLabel": {
                "show": true,
                "color": "#fff",
                "nameMap": [
                    "一月", "二月", "三月",
                    "四月", "五月", "六月",
                    "七月", "八月", "九月",
                    "十月", "十月", "十二月"
                ]
            },
            "dayLabel": {
                "show": true,
                "color": "#AAB2BD",
                "nameMap": "cn",
            },
        },
        "series": [{
            "label": {
                "show": true,
                "normal": {
                    "show": true,
                    "fontSize": 16,
                    "fontWeight": "bold",
                    "color": "#AAB2BD"
                }
                } 
            }
        ]
    });
}));
