(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.avsrawbarlinechart !== 'undefined') {
        return;
    }
    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;

    var chartLibrary = GLOBAL.DS.RAObjects.chartParameterLibrary;

    var avsChartPrototype = {
        is: 'ra-avsrawbarlinechart',
        behaviors: [GLOBAL.DS.RAComponents.avsrawbarchart]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsrawbarchart.createdCallback.call(this);

        this.addYLineAxis();
        this.addColorLineDropZone();
        this.makeZoomable({maxZoom:1});
    };

    avsChartPrototype.initialize = function(configuration) {
        GLOBAL.DS.RAComponents.avsrawbarchart.initialize.call(
            this,
            configuration
        );
        if (configuration) {
        } else {
            this.parameters.yline = [];
            this.parameters.colorline = null;
        }
    };

    avsChartPrototype.getXParameter = function(parameter, attributes) {
        var chartParam,
            attributes = {};

        if (parameter.dataType === 'STRING') {
            chartParam = chartLibrary.parameterTemplates.discreteSpatial.create(
                'X'
            );
            attributes.discreteValues = parameter.discreteValues;
        } else {
            chartParam = chartLibrary.parameterTemplates.rawNumeric.create('X');
        }

        chartParam.update(attributes);

        return chartParam;
    };

    avsChartPrototype.addYLineAxis = function() {
        var that = this;
        // The main chart will be contianed in an ra-droptarget element to handle
        // drops
        // TODO: This should be generalized onto a more specific drop target for
        // chart drop  zones, probably.
        this.divs.yAxisLineDropZone = document.createElement(
            'ra-chartdroptarget'
        );
        this.divs.yAxisLineDropZone.classList.add(
            'avsDropChart-yAxisLineDropZone'
        );
        this.divs.yAxisLineDropZone.setDragEnterListener(
            this.divs.yAxisLineDropZone.showPlaceholder
        );
        this.divs.yAxisLineDropZone.setDragLeaveListener(
            this.divs.yAxisLineDropZone.hidePlaceholder
        );
        this.divs.yAxisLineDropZone.setParameterListener(
            this.divs.addYLineParameter
        );
        this.divs.yAxisLineDropZone.showPlaceholder();
        this.divs.yAxisLineDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        this.divs.yAxisLineDropZone.setPlaceholderText(function() {
            if (that.parameters.yline.length === 0) {
                return NLSUtils.translate('Y Line Axis');
            } else {
                var text = '';
                for (var i = 0; i < that.parameters.yline.length; i++) {
                    if (i != 0) {
                        text += ',';
                    }
                    text += that.parameters.yline[i].name;
                }
                return text;
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateYLineData);
        paramHandler.setDropListener(function(param) {
            console.log('Added Y line parameter: ' + param.id);
            that.addYLineParameter(param.properties);
            that.controls.yLineControl.updateController(that.parameters.yline);
            that.renderChart();
        });

        this.divs.yAxisLineDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.yAxisLineDropZone);
    };

    avsChartPrototype.addColorLineDropZone = function() {
        var that = this;
        // The main chart will be contianed in an ra-droptarget element to handle
        // drops
        // TODO: This should be generalized onto a more specific drop target for
        // chart drop  zones, probably.
        this.divs.colorLineDropZone = document.createElement(
            'ra-chartdroptarget'
        );
        this.divs.colorLineDropZone.classList.add(
            'avsDropChart-colorLineDropZone'
        );
        this.divs.colorLineDropZone.setDragEnterListener(
            this.divs.colorLineDropZone.showPlaceholder
        );
        this.divs.colorLineDropZone.setDragLeaveListener(
            this.divs.colorLineDropZone.hidePlaceholder
        );
        this.divs.colorLineDropZone.setParameterListener(
            this.divs.setColorLineParameter
        );
        this.divs.colorLineDropZone.showPlaceholder();
        this.divs.colorLineDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        this.divs.colorLineDropZone.setPlaceholderText(function() {
            if (
                typeof that.parameters.colorline !== 'undefined' &&
                that.parameters.colorline !== null
            ) {
                return String(that.parameters.colorline.name);
            } else {
                return 'Color Line';
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateColorLineData);
        paramHandler.setDropListener(function(param) {
            console.log('Added color line parameter: ' + param.id);
            that.setColorLineParameter(param.properties);
            that.controls.colorLineControl.updateController([
                that.parameters.colorline
            ]);
            that.renderChart();
        });

        this.divs.colorLineDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.colorLineDropZone);
    };

    avsChartPrototype.validateYLineData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };

    avsChartPrototype.validateColorLineData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        // and not discrete
        if (data.properties.dataType === 'STRING') {
            console.log('color line parameter cannot be discrete');
            return false;
        }
        return true;
    };

    avsChartPrototype.addYLineParameter = function(parameter) {
        var that = this;
        if (
            that.parameters.yline.length <
            that.controls.yLineControl.getNParameters()
        ) {
            that.parameters.yline.push(parameter);
        } else {
            // Replace last parameter
            that.parameters.yline.splice(-1, 1, parameter);
        }
        that.divs.yAxisLineDropZone.updatePlaceholder();
    };

    avsChartPrototype.setYLineParameters = function(parameters) {
        var that = this;
        that.parameters.yline = parameters;
        that.divs.yAxisLineDropZone.updatePlaceholder();
    };

    avsChartPrototype.setColorLineParameter = function(parameter) {
        var that = this;
        that.parameters.colorline = parameter;
        that.divs.colorLineDropZone.updatePlaceholder();
    };

    avsChartPrototype.validateRender = function() {
        // If x is of type string we need to wait for a numeric param on y
        if (
            this.parameters.x !== null &&
            this.parameters.x.dataType === 'STRING'
        ) {
            if (this.parameters.y.length > 0) {
                return true;
            }
        } else {
            if (this.parameters.x !== null) {
                return true;
            }
        }
        return false;
    };

    avsChartPrototype.preRender = function() {
        GLOBAL.DS.RAComponents.avsrawbarchart.preRender.call(this);

        this.divs.yAxisLineDropZone.hidePlaceholder();
        this.divs.colorLineDropZone.hidePlaceholder();
    };

    avsChartPrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.avsrawbarchart.renderControlPanel.call(
            this,
            panel
        );

        var that = this;

        var dimensions = this.chartProperties.uiprops.dimensions;

        // Add line chart properties panel
        var lineChartPropertiesControl = panel.getControl(
            'ra-linechartpropertiescontrol'
        );
        lineChartPropertiesControl.setDefaultRequest(
            this.chartProperties.defaults[1]
        );
        lineChartPropertiesControl.setChangeListener(function() {
            that.renderChart();
        });
        this.controls.lineChartPropertiesControl = lineChartPropertiesControl;

        // Add y line param panel
        var yDim = this.findDimension(dimensions, 'yline');
        if (typeof yDim !== 'undefined') {
            var yParamControl = panel.getControl(yDim.uipanel);
            yParamControl.title('Y Line');
            yParamControl.nParameters(10);
            yParamControl.setDefaultRequest(this.chartProperties.defaults[1].y);
            yParamControl.setFilter(this.validateYLineData);
            yParamControl.setChangeListener(function(params) {
                that.setYLineParameters(params);
                that.renderChart();
            });
            if (this.parameters.yline) {
                yParamControl.updateController(this.parameters.yline);
            }
        }
        this.controls.yLineControl = yParamControl;

        // Add color line param panel
        var colorDim = this.findDimension(dimensions, 'colorline');
        if (typeof colorDim !== 'undefined') {
            var colorParamControl = panel.getControl(colorDim.uipanel);
            colorParamControl.title('Color Line');
            colorParamControl.nParameters(1);
            colorParamControl.setDefaultRequest(
                this.chartProperties.defaults[1].color
            );
            colorParamControl.setFilter(this.validateColorLineData);
            colorParamControl.setChangeListener(function(params) {
                that.setColorLineParameter(
                    params.length == 0 ? null : params[0]
                );
                that.renderChart();
            });
            if (this.parameters.colorline) {
                colorParamControl.updateController([this.parameters.colorline]);
            }
        }
        this.controls.colorLineControl = colorParamControl;

        // Modify param panels
        this.controls.yControl.title('Y Bar');
        this.controls.yLineControl.setShowAxisFilter(true);
        this.controls.yLineControl.setShowParamFilter(false);
        this.controls.yLineControl.setShowAggregationType(false);
        this.controls.colorControl.setShowAggregationType(false);
    };

    avsChartPrototype.updateRequest = function() {
        GLOBAL.DS.RAComponents.avsrawbarchart.updateRequest.call(this);
        var that = this;

        if (this.parameters.yline.length == 0) {
            this.requestObject.chartRequest.charts.splice(1, 1);
            return;
        } else if (this.requestObject.chartRequest.charts.length == 1) {
            this.requestObject.chartRequest.charts.push(
                that.controls.lineChartPropertiesControl.getRequest()
            );
        }

        var dataParams = this.requestObject.chartRequest.data;
        var dataMaps = this.requestObject.chartRequest.dataMaps;
        var legends = this.requestObject.chartRequest.legends;

        // Populate x parameter
        this.requestObject.chartRequest.charts[1].x = JSON.parse(
            JSON.stringify(this.requestObject.chartRequest.charts[0].x)
        );
        this.requestObject.chartRequest.charts[1].x.axisProperties = JSON.parse(
            JSON.stringify(this.chartProperties.defaults[1].x.axisProperties)
        );

        // Populate y parameter
        this.requestObject.chartRequest.charts[1].y.series = [];
        for (var i = 0; i < this.parameters.yline.length; i++) {
            var ySeries = { type: 'raw', guid: this.parameters.yline[i].id };
            this.requestObject.chartRequest.charts[1].y.series.push(ySeries);

            this.addRawParam(this.parameters.yline[i], dataParams.raw);
        }
        this.requestObject.chartRequest.charts[1].y.minFilterPercent = that.controls.yLineControl.getAxisMinValue();
        this.requestObject.chartRequest.charts[1].y.maxFilterPercent = that.controls.yLineControl.getAxisMaxValue();
        this.requestObject.chartRequest.charts[1].y.axisProperties = that.controls.yLineControl.getAxisProperties();

        // Populate color parameter
        var type = that.controls.colorLineControl.getType();
        if (type === 'byData') {
            this.requestObject.chartRequest.charts[1].color = {
                type: 'byData',
                data: { guid: this.parameters.colorline.id }
            };
            if (this.parameters.colorline.dataType === 'STRING') {
                this.requestObject.chartRequest.charts[1].color.data.type =
                    'binnedDiscrete';
                this.requestObject.chartRequest.charts[1].color.data.discreteValues = that.controls.colorLineControl.getDiscreteValues();
            } else {
                this.requestObject.chartRequest.charts[1].color.data.type =
                    'raw';
                this.requestObject.chartRequest.charts[1].color.data.minFilterPercent = that.controls.colorLineControl.getLinearMinValue();
                this.requestObject.chartRequest.charts[1].color.data.maxFilterPercent = that.controls.colorLineControl.getLinearMaxValue();
            }

            var colorMap = that.controls.colorLineControl.getDataMap();
            this.requestObject.chartRequest.charts[1].color.dataMap =
                colorMap.guid;
            this.addDataMap(colorMap, dataMaps.colorMaps);

            this.addRawParam(this.parameters.colorline, dataParams.raw);

            var colorLegend = {
                guid: 'colorLegend2',
                type: 'color',
                chartGuid: this.requestObject.chartRequest.charts[1].guid,
                width: 300,
                height: 100
            };
            if (legends === null) {
                legends = [];
            }
            legends.push(colorLegend);
        } else {
            this.requestObject.chartRequest.charts[1].color.type = type;
            if (type === 'fixed') {
                this.requestObject.chartRequest.charts[1].color.defaultColor = that.controls.colorLineControl.getFixedColor();
            } else {
                var colorMap = that.controls.colorLineControl.getDataMap();
                this.requestObject.chartRequest.charts[1].color.dataMap =
                    colorMap.guid;
                this.addDataMap(colorMap, dataMaps.colorMaps);

                var colorLegend = {
                    guid: 'colorLegend2',
                    type: 'color',
                    chartGuid: this.requestObject.chartRequest.charts[1].guid,
                    width: 300,
                    height: 100
                };
                if (legends === null) {
                    legends = [];
                }
                legends.push(colorLegend);
            }
        }

        this.requestObject.chartRequest.data = dataParams;
        this.requestObject.chartRequest.dataMaps = dataMaps;
        this.requestObject.chartRequest.legends = legends;
    };

    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avsrawbarlinechart = avsChartPrototype;
})(this);
