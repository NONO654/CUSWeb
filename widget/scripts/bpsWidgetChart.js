/*
 * Widget chart APIs
 * bpsWidgetChart.js
 * version 1.0
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 *
 */
var bpsWidgetChart = {
    drawChart: function (widget, objects, chartConfig) {
        var groupByFields = chartConfig.groupBy;

        if (chartConfig._validatedFields === undefined) {
            for (var j = 0; j < groupByFields.length; j++) { //ensure all fields are valid.
                var groupBy = groupByFields[j];
                var fieldConfig = bpsWidgetAPIs.getField(widget, groupBy);
                if (fieldConfig == null) {
                    if (j+1 == groupByFields.length) {
                        groupByFields = groupByFields.slice(0, j);
                    } else {
                        var temp = groupByFields.slice(0, j).concat(groupByFields.slice(j+1));
                        groupByFields = temp;
                        j--;
                    }
                    continue;
                }
            }

            // check to see the validity of calculation field if defined/specified
            var nlsCalculationField  = null,
            calculationObj   = chartConfig.calculation,
            calculationFieldConfig  = null;

            if (calculationObj != undefined) {
                calculationFieldConfig       = bpsWidgetAPIs.getField(widget, calculationObj.field);
                if (calculationFieldConfig == null || calculationObj.type == null) {
                    delete chartConfig.calculation;
                } else {
                    nlsCalculationField = calculationFieldConfig.label.text;
                    chartConfig.calculation._field = calculationFieldConfig;
                    chartConfig.calculation._tipCalculationFieldName = nlsCalculationField;
                }
            }
            chartConfig._validatedFields = true;
        }

        var chartData = {},
        uniqueCategories2 = {};

        //loop through all objects and start grouping field values.
        for (var i = 0; i < objects.length; i++) {
            var category    = chartData;
            var objectData  = objects[i];
            var calFieldConfigValue = null;

            if( chartConfig.calculation != null)
            {
                var calFieldConfigValues = bpsWidgetAPIs.getFieldData(chartConfig.calculation._field, objectData);
                calFieldConfigValue  = parseFloat(calFieldConfigValues[0].value);
            }

            for (var j = 0; j < groupByFields.length; j++) {
                var increment = null;
                if (j+1 == groupByFields.length) {
                    increment = 1;
                }
                var groupBy     = groupByFields[j];
                var fieldConfig = bpsWidgetAPIs.getField(widget, groupBy);
                var values      = bpsWidgetAPIs.getFieldData(fieldConfig, objectData);

                for (var k = 0; k < values.length; k++) {
                    var value = values[k].value;
                    if (value == null || value == "") {
                        value = "Unspecified";
                    }
                    if (increment) {
                        if (j != 0 && uniqueCategories2[value] === undefined) {
                            uniqueCategories2[value] = value;
                        }
                        if (category[value] === undefined) {
                            category[value] = {};
                            category[value].count = increment;
                            if( chartConfig.calculation != undefined) {
                                category[value].SUM = calFieldConfigValue;
                                category[value].MINIMUM = calFieldConfigValue;
                                category[value].MAXIMUM = calFieldConfigValue;
                            }
                        } else {
                            category[value].count += increment;

                            if( chartConfig.calculation != undefined) {
                                category[value].SUM = category[value].SUM + calFieldConfigValue;
                                category[value].MINIMUM = (category[value].MINIMUM > calFieldConfigValue) ? calFieldConfigValue : category[value].MINIMUM;
                                category[value].MAXIMUM = (category[value].MAXIMUM < calFieldConfigValue) ? calFieldConfigValue : category[value].MAXIMUM;
                            }
                        }
                    } else {
                        if (category[value] === undefined) {
                            category[value] = {};
                        }
                        category = category[value];
                    }
                }
            }
        }

        var series = [];
        var categoryItems1 = this.getKeys(chartData);
        var categoryItems2 = this.getKeys(uniqueCategories2);

        var getColor = {
            'past due'        : '#FF0000',
            'due today'       : '#FFFF00',
            'due tomorrow'    : '#0000FF',
            'due this week'   : '#00FFFF',
            'due future'      : '#00FF00',
            'no date'         : '#000000'
        };

        if (categoryItems2.length == 0) {
            var data = [];
            for(var i in chartData) {

                var value = {};
                value.name = i;

                if (chartConfig.calculation != undefined) {
                    chartData[i].AVERAGE   = chartData[i].SUM / chartData[i].count;
                    value.y                = chartData[i][chartConfig.calculation.type];
                    value.count            = chartData[i].count;
                    value.calculationData  = this.setCalculationFieldData(chartConfig, chartData[i]);
                } else {
                    value.y = chartData[i].count;
                }
                // start - for specifying specific color to each pie
                if (getColor[i.toLowerCase()] != undefined) {
                   value.color = getColor[i.toLowerCase()];
                }
                data.push(value);
            }

            series.push( {
               name: "Items",
               data:data
            });
        } else {
            for (var i = 0; i < categoryItems2.length; i++) {
                var category2 = categoryItems2[i];
                var data = [];
                for (var j = 0; j < categoryItems1.length; j++) {
                    var category1 = categoryItems1[j];
                    var value = {};
                    value.name = category2;

                    if (chartData[category1][category2] === undefined) {
                        value.y = 0;
                        value.count = 0;
                    } else {
                        if (chartConfig.calculation != undefined) {
                            chartData[category1][category2].AVERAGE = chartData[category1][category2].SUM / chartData[category1][category2].count;
                            value.y = chartData[category1][category2][chartConfig.calculation.type];
                            value.count = chartData[category1][category2].count;
                            value.calculationData  = this.setCalculationFieldData(chartConfig, chartData[category1][category2]);
                        } else {
                            value.y = chartData[category1][category2].count;
                        }
                    }
                    data.push(value);
                }

                series.push({
                    name: category2,
                    data: data
                });
            }
        }
        return this.draw(categoryItems1, series, chartConfig, widget);
    },
    setCalculationFieldData: function(chartConfig, chartData) {
       var calculationData = {};
       if (chartConfig.calculation != undefined) {
           calculationData.SUM     = this.setCalculationField(chartConfig, chartData, "SUM");
           calculationData.AVERAGE = this.setCalculationField(chartConfig, chartData, "AVERAGE");
           calculationData.MINIMUM = this.setCalculationField(chartConfig, chartData, "MINIMUM");
           calculationData.MAXIMUM = this.setCalculationField(chartConfig, chartData, "MAXIMUM");
       } else {
           calculationData = null;
       }

       return calculationData;
    },
    setCalculationField: function(chartConfig, chartData, type) {
        var calculationDataType = {};
        calculationDataType.label = bpsWidgetConstants.str[type];
        calculationDataType.value = chartData[type];
        calculationDataType.selected = (chartConfig.calculation.type == type) ? "true" : "false";
        return calculationDataType;
    },
    getMainTitle: function(chartConfig) {
        var mainTitle = null;
        if (chartConfig.label != undefined) {
            mainTitle = chartConfig.label.text;
        }
        return mainTitle;
    },
    getSubTitle: function(chartConfig) {
        var subHeader = null;
        if (chartConfig.subHeader != undefined) {
            subHeader = chartConfig.subHeader.text;
        }
        return subHeader;
    },
    getXaxisTitle: function(chartConfig, widget) {
        var xAxisTitle = "";
        var groupByFields = chartConfig.groupBy;
        for (var j = 0; j < groupByFields.length; j++) {
            var groupBy     = groupByFields[j];
            var fieldConfig = bpsWidgetAPIs.getField(widget, groupBy);
            if(j == 0)
            {
                xAxisTitle = fieldConfig.label.text;
            }
            else
            {
                xAxisTitle += " / " + fieldConfig.label.text;
            }
        }
        return xAxisTitle;
    },
    getYaxisTitle: function(chartConfig) {
        var yAxisTitle = "Items";
        if (chartConfig.calculation != undefined) {
            yAxisTitle = chartConfig.calculation._field.label.text + " <B>(" + bpsWidgetConstants.str[chartConfig.calculation.type] + ")</B>";
        }
        return yAxisTitle;
    },
    getKeys: function(object) {
        var list = [];
        for (var key in object) {
            if (object.hasOwnProperty(key)) {
                list.push(key);
            }
        }
        //sort list.
        // list = list.sort();
        return list;
    },
    html: function() { return jQuery('<div width="100%" id="'+ this.getId() +'" ></div>');},
    getId: function() { return "dsCHART_" + new Date().getTime();},
    draw: function(categories, series, chartConfig, widget){

            var chartData = {
                chart: {
                    type: chartConfig.type.toLowerCase(),
                },
                title: {
                    text: this.getMainTitle(chartConfig)
                },
                subtitle: {
                    text: this.getSubTitle(chartConfig)
                },
                tooltip: {
                    useHTML: true,
                    borderWidth: 0,
                    style: {
                        padding: 0
                    },
                    formatter: function () {
                        var tip = null;

                        if (chartConfig.calculation != undefined) {
                            tip = "<div style='padding: 2px; border-bottom: 2px solid #000000'>";
                            tip += this.series.name + ":<b>" + this.point.y + "</b>";
                            tip += "<br>Items:<b>" + this.point.count+ "</b>";
                            tip += "</div>";

                            if (this.point.calculationData != null) {
                                tip += "<div style='padding: 2px;'>";
                                if (this.point.calculationData.SUM.selected == "false") {
                                    tip +=  "<div>" + chartConfig.calculation._tipCalculationFieldName + "  (" + this.point.calculationData.SUM.label + ") <b>" + this.point.calculationData.SUM.value + "</b></div>";
                                }
                                if (this.point.calculationData.AVERAGE.selected == "false") {
                                    tip +=  "<div>" + chartConfig.calculation._tipCalculationFieldName + "  (" + this.point.calculationData.AVERAGE.label + ") <b>" + this.point.calculationData.AVERAGE.value + "</b></div>";
                                }
                                if (this.point.calculationData.MAXIMUM.selected == "false") {
                                    tip +=  "<div>" + chartConfig.calculation._tipCalculationFieldName + "  (" + this.point.calculationData.MAXIMUM.label + ") <b>" + this.point.calculationData.MAXIMUM.value + "</b></div>";
                                }
                                if (this.point.calculationData.MINIMUM.selected == "false") {
                                    tip +=  "<div>" + chartConfig.calculation._tipCalculationFieldName + "  (" + this.point.calculationData.MINIMUM.label + ") <b>" + this.point.calculationData.MINIMUM.value + "</b></div>";
                                }
                                tip += "</div>";
                            }
                        } else {
                            tip = "<div style='padding: 2px;'>";
                            tip += this.point.name + "<br>";
                            tip += this.series.name + ":" + this.point.y;
                            tip += "</div>";
                        }
                        return tip;
                    }
                },
                xAxis: {
                    categories: categories,
                    title: {
                        text: this.getXaxisTitle(chartConfig, widget)
                    }
                },
                yAxis: {
                    title: {
                        text: this.getYaxisTitle(chartConfig)
                    }
                },
                plotOptions: {
                    column: {
                        allowPointSelect: true,
                        cursor: 'pointer',
                        dataLabels: {
                            enabled: false,
                            color: '#000000',
                            format: '<b>{point.name}</b>: {point.y}'
                        },
                        states: {
                            hover: {
                                borderColor: '#000000',
                                borderWidth: 2
                            }
                        }
                    },
                    bar: {
                        allowPointSelect: true,
                        cursor: 'pointer',
                        dataLabels: {
                            enabled: false,
                            color: '#000000',
                            format: '<b>{point.name}</b>: {point.y}'
                        },
                        states: {
                            hover: {
                                borderColor: '#000000',
                                borderWidth: 2
                            }
                        }
                    },
                    pie: {
                        allowPointSelect: true,
                        cursor: 'pointer',
                        dataLabels: {
                            enabled: false,
                            color: '#000000',
                            format: '<b>{point.name}</b>: {point.percentage:.1f} %'

                        },
                        states: {
                            hover: {
                                borderColor: '#000000',
                                borderWidth: 2
                            }
                        },
                        showInLegend: true
                    }
                },
                credits: {enabled:false},   // to suppress highcharts.com display on right bottom
                series: series
            };

            var ctnr = this.html();
            chartData.chart.renderTo = ctnr[0];
            setTimeout(function(){new Highcharts.Chart(chartData);}, 1);
            return ctnr;

        }
};
