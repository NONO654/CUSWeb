(function(GLOBAL) {
    if (
        typeof GLOBAL.DS.RAComponents.avsrawscattermatrixchart !== 'undefined'
    ) {
        return;
    }

    var avsChartPrototype = {
        is: 'ra-avsrawscattermatrixchart',
        behaviors: [GLOBAL.DS.RAComponents.avsrawscatterchart]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsrawscatterchart.createdCallback.call(this);
    };
    avsChartPrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.avsdropchartbase.renderControlPanel.call(
            this,
            panel
        );

        var that = this;

        var dimensions = this.chartProperties.uiprops.dimensions;

        // Add shape param panel
        var shapeDim = this.findDimension(dimensions, 'shape');
        if (typeof shapeDim !== 'undefined') {
            var shapeParamControl = panel.getControl(shapeDim.uipanel);
            shapeParamControl.title('Shape');
            shapeParamControl.nParameters(1);
            shapeParamControl.setDefaultRequest(
                this.chartProperties.defaults[0].shape
            );
            shapeParamControl.setFilter(this.validateShapeData);
            shapeParamControl.setChangeListener(function(params) {
                that.setShapeParameter(params.length == 0 ? null : params[0]);
                that.renderChart();
            });
            if (this.parameters.shape) {
                shapeParamControl.updateController([this.parameters.shape]);
            }
        }
        this.controls.shapeControl = shapeParamControl;
        this.controls.shapeControl.
            querySelector('.controlIcon').
            classList.add('sizeParamIcon');

        // Modify param panels
        this.controls.yControl.setShowAggregationType(false);
        // sd4: this is the only difference between regular scatter chart and
        // scatter grid
        // we will allow upto 25 parameters
        this.controls.yControl.nParameters(25);
        this.controls.colorControl.setNoParamSelectVisible(false);
        this.controls.colorControl.setShowAggregationType(false);
        this.controls.sizeControl.setShowAggregationType(false);
        this.controls.shapeControl.setShowAggregationType(false);
        this.controls.labelControl.setShowAggregationType(false);
    };
    // sd4: this is overridden version of the one in ra-avsdropchartbase.js
    avsChartPrototype.validateRender = function() {
        var chartType = this.chartProperties.defaults[0].type;
        var chartLayout = this.chartProperties.defaults[0].layout;

        if (this.parameters.y.length > 1) {
            return true;
        }
        return false;
    };

    // this.parameters.x --> xParam
    // this.parameters.y[0] --> yParam
    // this.requestObject.chartRequest.charts[0] --> currChart
    avsChartPrototype.updateRequestForHistogram = function(
        guid,
        xParam,
        dataParams,
        dataMaps,
        legends
    ) {
        curChart = JSON.parse(
            JSON.stringify(this.controls.chartPropertiesControl.getRequest())
        );
        curChart.guid = guid;

        /*       var dataParams = {"raw":[{"guid":xParam.id}]};
           var dataMaps = {"colorMaps":[]};
           var legends = null;*/

        // Populate x parameter
        if (xParam.dataType === 'STRING') {
            curChart.x = { data: { type: 'binnedDiscrete', guid: xParam.id } };
            curChart.x.data.discreteValues = this.controls.yControl.getDiscreteValues();
        } else {
            curChart.x = {
                data: { type: 'binnedEqualWidth', numBins: 10, guid: xParam.id }
            };
            curChart.x.data.minFilterPercent = '0'; // this.controls.xControl.getLinearMinValue();
            curChart.x.data.maxFilterPercent = '100'; // this.controls.xControl.getLinearMaxValue();
        }
        this.addRawParam(xParam, dataParams.raw);
        curChart.x.axisProperties = this.controls.yControl.getAxisProperties();

        // Populate y parameter
        var yLabelOverride = null;
        /* if (this.parameters.y.length > 0) {
         curChart.y = {"series":[]};
         for (var i=0; i<this.parameters.y.length; i++) {
             var ySeries =
     {"type":"aggregation","guid":this.parameters.y[i].id};
             ySeries.aggregationType =
     this.controls.yControl.getAggregationType(i);
             curChart.y.series.push(ySeries);

             this.addRawParam(this.parameters.y[i], dataParams.raw);
         }
     }
     else {*/
        curChart.y = {
            series: [
                {
                    type: 'aggregation',
                    aggregationType: 'COUNT',
                    guid: xParam.id
                }
            ]
        };
        if (this.controls.yControl.isUserDefinedAxisTitleText() === false) {
            yLabelOverride = xParam.displayName + ' (COUNT)';
        }
        /*   }   */
        curChart.y.minFilterPercent = this.controls.yControl.getAxisMinValue();
        curChart.y.maxFilterPercent = this.controls.yControl.getAxisMaxValue();
        curChart.y.axisProperties = this.controls.yControl.getAxisProperties();
        if (yLabelOverride != null) {
            this.updateAxisLabel(curChart.y, yLabelOverride);
        }

        // Populate color parameter
        var type = this.controls.colorControl.getType();
        if (type === 'byData') {
            curChart.color = {
                type: 'byData',
                data: { guid: this.parameters.color.id }
            };
            if (this.parameters.color.dataType === 'STRING') {
                curChart.color.data.type = 'binnedDiscrete';
                curChart.color.data.discreteValues = this.controls.colorControl.getDiscreteValues();
            } else {
                curChart.color.data.type = 'aggregation';
                curChart.color.data.aggregationType = this.controls.colorControl.getAggregationType();
                curChart.color.data.minFilterPercent = this.controls.colorControl.getLinearMinValue();
                curChart.color.data.maxFilterPercent = this.controls.colorControl.getLinearMaxValue();
            }
            var colorMap = this.controls.colorControl.getDataMap();
            curChart.color.dataMap = colorMap.guid;
            this.addDataMap(colorMap, dataMaps.colorMaps);

            this.addRawParam(this.parameters.color, dataParams.raw);

            var colorLegend = {
                guid: 'colorLegend1',
                type: 'color',
                chartGuid: curChart.guid,
                width: 300,
                height: 100
            };
            if (legends === null) {
                legends = [];
            }
            legends.push(colorLegend);
        } else {
            curChart.color.type = type;
            if (type === 'fixed') {
                curChart.color.defaultColor = this.controls.colorControl.getFixedColor();
            } else {
                var colorMap = this.controls.colorControl.getDataMap();
                curChart.color.dataMap = colorMap.guid;
                this.addDataMap(colorMap, dataMaps.colorMaps);

                var colorLegend = {
                    guid: 'colorLegend1',
                    type: 'color',
                    chartGuid: curChart.guid,
                    width: 300,
                    height: 100
                };
                if (legends === null) {
                    legends = [];
                }
                legends.push(colorLegend);
            }
        }
        return curChart;
    };

    // this.parameters.x --> xParam
    // this.parameters.y[0] --> yParam
    // this.requestObject.chartRequest.charts[0] --> currChart
    avsChartPrototype.updateRequestForBlock = function(
        guid,
        xParam,
        yParam,
        dataParams,
        dataMaps,
        legends
    ) {
        curChart = JSON.parse(
            JSON.stringify(this.controls.chartPropertiesControl.getRequest())
        );
        curChart.guid = guid;

        // var dataParams = {"raw":[{"guid":xParam.id},{"guid":yParam.id}]};
        // var dataMaps = {"colorMaps":[],"sizeMaps":[],"shapeMaps":[]};
        // var legends = null;

        // Populate x parameter
        if (xParam.dataType === 'STRING') {
            curChart.x = { data: { type: 'binnedDiscrete', guid: xParam.id } };
            curChart.x.data.discreteValues = this.controls.yControl.getDiscreteValues();
        } else {
            curChart.x = { data: { type: 'raw', guid: xParam.id } };
            curChart.x.data.minFilterPercent = '0'; // this.controls.xControl.getLinearMinValue();
            curChart.x.data.maxFilterPercent = '100'; // this.controls.xControl.getLinearMaxValue();
        }
        curChart.x.axisProperties = this.controls.yControl.getAxisProperties();

        // Populate y parameter
        if (yParam.dataType === 'STRING') {
            curChart.y = { data: { type: 'binnedDiscrete', guid: yParam.id } };
            curChart.y.data.discreteValues = this.controls.yControl.getDiscreteValues();
        } else {
            curChart.y = { data: { type: 'raw', guid: yParam.id } };
            curChart.y.data.minFilterPercent = this.controls.yControl.getLinearMinValue();
            curChart.y.data.maxFilterPercent = this.controls.yControl.getLinearMaxValue();
        }
        curChart.y.axisProperties = this.controls.yControl.getAxisProperties();

        // Populate color parameter
        var type = this.controls.colorControl.getType();
        if (type === 'byData') {
            curChart.color = {
                type: 'byData',
                data: { guid: this.parameters.color.id }
            };
            if (this.parameters.color.dataType === 'STRING') {
                curChart.color.data.type = 'binnedDiscrete';
                curChart.color.data.discreteValues = this.controls.colorControl.getDiscreteValues();
            } else {
                curChart.color.data.type = 'raw';
                curChart.color.data.minFilterPercent = this.controls.colorControl.getLinearMinValue();
                curChart.color.data.maxFilterPercent = this.controls.colorControl.getLinearMaxValue();
            }

            var colorMap = this.controls.colorControl.getDataMap();
            curChart.color.dataMap = colorMap.guid;
            this.addDataMap(colorMap, dataMaps.colorMaps);

            this.addRawParam(this.parameters.color, dataParams.raw);

            var colorLegend = {
                guid: 'colorLegend1',
                type: 'color',
                chartGuid: curChart.guid,
                width: 300,
                height: 100
            };
            if (legends === null) {
                legends = [];
            }
            legends.push(colorLegend);
        } else {
            curChart.color.type = 'fixed';
            curChart.color.defaultColor = this.controls.colorControl.getFixedColor();
        }

        // Populate size parameter
        if (this.parameters.size != null) {
            curChart.size = { data: { guid: this.parameters.size.id } };
            curChart.size.data.type = 'raw';
            curChart.size.data.minFilterPercent = this.controls.sizeControl.getLinearMinValue();
            curChart.size.data.maxFilterPercent = this.controls.sizeControl.getLinearMaxValue();

            var sizeMap = this.controls.sizeControl.getDataMap();
            curChart.size.dataMap = sizeMap.guid;
            this.addDataMap(sizeMap, dataMaps.sizeMaps);

            this.addRawParam(this.parameters.size, dataParams.raw);

            var sizeLegend = {
                guid: 'sizeLegend1',
                type: 'size',
                orientation: 'vertical',
                chartGuid: curChart.guid,
                width: 300,
                height: 100
            };
            if (legends === null) {
                legends = [];
            }
            legends.push(sizeLegend);
        } else {
            curChart.size = {};
        }
        curChart.size.baseSize = this.controls.sizeControl.getLinearScaleValue();

        // Populate shape parameter
        if (this.parameters.shape != null) {
            curChart.shape = { data: { guid: this.parameters.shape.id } };
            if (this.parameters.shape.dataType === 'STRING') {
                curChart.shape.data.type = 'binnedDiscrete';
                curChart.shape.data.discreteValues = this.controls.shapeControl.getDiscreteValues();
            } else {
                curChart.shape.data.type = 'raw';
                curChart.shape.data.minFilterPercent = this.controls.shapeControl.getLinearMinValue();
                curChart.shape.data.maxFilterPercent = this.controls.shapeControl.getLinearMaxValue();
            }

            var shapeMap = this.controls.shapeControl.getDataMap();
            curChart.shape.dataMap = shapeMap.guid;
            this.addDataMap(shapeMap, dataMaps.shapeMaps);

            this.addRawParam(this.parameters.shape, dataParams.raw);

            var shapeLegend = {
                guid: 'shapeLegend1',
                type: 'shape',
                orientation: 'vertical',
                chartGuid: curChart.guid,
                width: 300,
                height: 100
            };
            if (legends === null) {
                legends = [];
            }
            legends.push(shapeLegend);
        } else {
            curChart.shape = null;
        }

        // Populate label parameter
        if (this.parameters.label != null) {
            curChart.label = {
                data: { type: 'raw', guid: this.parameters.label.id }
            };
            curChart.label.properties = this.controls.labelControl.getLabelProperties();
            this.addRawParam(this.parameters.label, dataParams.raw);
        } else {
            curChart.label = null;
        }

        // Srikanth: There can be more than one constraint added to a chart
        if (
            this.parameters.constraints != null &&
            this.parameters.constraints.length > 0
        ) {
            curChart.constraints = [];
            var allC = curChart.constraints;
            this.parameters.constraints.forEach(function(c) {
                var constraintRequest = {
                    type: c.properties.type,
                    guid: c.id,
                    surface: { opacity: 0.75, color: '#aa0000' },
                    line: {
                        visible: true,
                        color: '#ff0000',
                        width: 1,
                        style: 'solid'
                    }
                };
                allC.push(constraintRequest);
            });
        } else {
            if (this.chartProperties.defaults[0].constraints != null) {
                curChart.constraints = this.chartProperties.defaults[0].constraints;
            }
        }

        return curChart;
    };

    avsChartPrototype.updateRequest = function() {
        // GLOBAL.DS.RAComponents.avsrawscatterchart.updateRequest.call(this);
        console.log(this.controls.yControl);
        if (
            this.controls.yControl.parameters &&
            this.controls.yControl.parameters.length
        ) {
            this.requestObject.chartRequest.layout = {
                type: 'matrix',
                numGridRows: this.controls.yControl.parameters.length,
                numGridColumns: this.controls.yControl.parameters.length
            };
        }
        console.log('inside matrix update rewuest!!!');

        this.requestObject.chartRequest.charts = [];
        var dataParams = {
            raw: [
                { guid: this.parameters.y[0].id },
                { guid: this.parameters.y[1].id }
            ]
        };
        var dataMaps = { colorMaps: [], sizeMaps: [], shapeMaps: [] };
        var legends = [];

        for (
            var i = 0;
            i < this.requestObject.chartRequest.layout.numGridRows;
            i++
        ) {
            for (
                var j = 0;
                j < this.requestObject.chartRequest.layout.numGridColumns;
                j++
            ) {
                // there will be only one for each of color, shape and size
                // parameter so we can clear out the legends for every chart
                legends = [];
                console.log(
                    'x[' +
                        i +
                        ']: ' +
                        this.parameters.y[i].ID +
                        ', y[' +
                        j +
                        ']:' +
                        this.parameters.y[j].ID
                );
                if (i == j) {
                    var curChart = this.updateRequestForHistogram(
                        'bar' + i,
                        this.parameters.y[i],
                        this.parameters.y[i],
                        dataParams,
                        dataMaps,
                        legends
                    );
                    console.log(curChart);
                    this.requestObject.chartRequest.charts.push(curChart);
                } else {
                    var curChart = this.updateRequestForBlock(
                        'scatter' + i + j,
                        this.parameters.y[i],
                        this.parameters.y[j],
                        dataParams,
                        dataMaps,
                        legends
                    );
                    console.log(curChart);
                    this.requestObject.chartRequest.charts.push(curChart);
                }
            }
        }
        this.requestObject.chartRequest.data = dataParams;
        this.requestObject.chartRequest.dataMaps = dataMaps;
        this.requestObject.chartRequest.legends =
            legends.length === 0 ? null : legends;
    };

    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avsrawscattermatrixchart = avsChartPrototype;
})(this);
