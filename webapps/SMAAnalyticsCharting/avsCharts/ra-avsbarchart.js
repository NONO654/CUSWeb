(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.avsbarchart !== 'undefined') {
        return;
    }

    
    var avsChartPrototype = {
        is: 'ra-avsbarchart',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.createdCallback.call(this);

        this.divs.root.removeChild(this.divs.sizeDropZone);
        this.divs.root.removeChild(this.divs.labelDropZone);

        this.makeZoomable({maxZoom:1});
    };

    avsChartPrototype.validateYData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        // and not discrete
        if (data.properties.dataType === 'STRING') {
            console.log('y parameter cannot be discrete');
            return false;
        }
        return true;
    };

    avsChartPrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.avsdropchartbase.renderControlPanel.call(
            this,
            panel
        );

        // Modify param panels
        if(this.controls.yControl) {
        	this.controls.yControl.nParameters(10);
        	this.controls.yControl.setShowAxisFilter(true);
        	this.controls.yControl.setShowParamFilter(false);
        }
    };

    avsChartPrototype.updateRequest = function() {
        var that = this;

        this.requestObject.chartRequest.charts[0] = that.controls.chartPropertiesControl.getRequest();
        this.requestObject.chartRequest.charts[0].guid = 'bar1';

        var dataParams = { raw: [{ guid: this.parameters.x.id }] };
        var dataMaps = { colorMaps: [] };
        var legends = null;

        // Populate x parameter
        if (this.parameters.x.dataType === 'STRING') {
            this.requestObject.chartRequest.charts[0].x = {
                data: { type: 'binnedDiscrete', guid: this.parameters.x.id }
            };
            this.requestObject.chartRequest.charts[0].x.data.discreteValues = that.controls.xControl.getDiscreteValues();
        } else {
            this.requestObject.chartRequest.charts[0].x = {
                data: {
                    type: 'binnedEqualWidth',
                    numBins: 10,
                    guid: this.parameters.x.id
                }
            };
            this.requestObject.chartRequest.charts[0].x.data.minFilterPercent = that.controls.xControl.getLinearMinValue();
            this.requestObject.chartRequest.charts[0].x.data.maxFilterPercent = that.controls.xControl.getLinearMaxValue();
        }
        this.addRawParam(this.parameters.x, dataParams.raw);
        this.requestObject.chartRequest.charts[0].x.axisProperties = that.controls.xControl.getAxisProperties();
        //this.requestObject.chartRequest.charts[0].x.axisProperties.style = 'forcedNumeric';

        // Populate y parameter
        //sd4: remember some charts like Histogram and Cumulative frequency may not have Y parameter
        var yLabelOverride = null;
        if (this.parameters.y && this.parameters.y.length > 0) {
            this.requestObject.chartRequest.charts[0].y = { series: [] };
            for (var i = 0; i < this.parameters.y.length; i++) {
                var ySeries = {
                    type: 'aggregation',
                    guid: this.parameters.y[i].id
                };
                ySeries.aggregationType = that.controls.yControl.getAggregationType(
                    i
                );
                this.requestObject.chartRequest.charts[0].y.series.push(
                    ySeries
                );

                this.addRawParam(this.parameters.y[i], dataParams.raw);
            }
        } else {
            this.requestObject.chartRequest.charts[0].y = {
                series: [
                    {
                        type: 'aggregation',
                        aggregationType: 'COUNT',
                        guid: this.parameters.x.id
                    }
                ]
            };
            if (that.controls.yControl && that.controls.yControl.isUserDefinedAxisTitleText() === false) {
                yLabelOverride = this.parameters.x.displayName + ' (COUNT)';
            }
        }
        if(that.controls.yControl) {
        	this.requestObject.chartRequest.charts[0].y.minFilterPercent = that.controls.yControl.getAxisMinValue();
        	this.requestObject.chartRequest.charts[0].y.maxFilterPercent = that.controls.yControl.getAxisMaxValue();
        	this.requestObject.chartRequest.charts[0].y.axisProperties = that.controls.yControl.getAxisProperties();
        }
        if (yLabelOverride != null) {
            this.updateAxisLabel(
                this.requestObject.chartRequest.charts[0].y,
                yLabelOverride
            );
        }

        // Populate color parameter
        //sd4: remember some charts like Histogram and Cumulative frequency may not have color parameter
        var type = 'fixed';
        if (that.controls.colorControl && that.controls.colorControl.getType() === 'byData') {
            this.requestObject.chartRequest.charts[0].color = {
                type: 'byData',
                data: { guid: this.parameters.color.id }
            };
            if (this.parameters.color.dataType === 'STRING') {
                this.requestObject.chartRequest.charts[0].color.data.type =
                    'binnedDiscrete';
                this.requestObject.chartRequest.charts[0].color.data.discreteValues = that.controls.colorControl.getDiscreteValues();
            } else {
                this.requestObject.chartRequest.charts[0].color.data.type =
                    'aggregation';
                this.requestObject.chartRequest.charts[0].color.data.aggregationType = that.controls.colorControl.getAggregationType();
                this.requestObject.chartRequest.charts[0].color.data.minFilterPercent = that.controls.colorControl.getLinearMinValue();
                this.requestObject.chartRequest.charts[0].color.data.maxFilterPercent = that.controls.colorControl.getLinearMaxValue();
            }
            var colorMap = that.controls.colorControl.getDataMap();
            this.requestObject.chartRequest.charts[0].color.dataMap =
                colorMap.guid;
            this.addDataMap(colorMap, dataMaps.colorMaps);

            this.addRawParam(this.parameters.color, dataParams.raw);

            var colorLegend = {
                guid: 'colorLegend1',
                type: 'color',
                chartGuid: this.requestObject.chartRequest.charts[0].guid,
                width: 300,
                height: 100
            };
            if (legends === null) {
                legends = [];
            }
            legends.push(colorLegend);
        } else {
            // sd4: We are NOT allowed to do 'fixed' color when there are more than
            // one y
            if (this.parameters.y.length === 1) {
                type = 'fixed';
                this.requestObject.chartRequest.charts[0].color.defaultColor = that.controls.colorControl.getFixedColor();
            } else if (this.parameters.y.length > 1) {
                // Get colormaps from example library
                // This should come from parameter <---> color map
                // TODO: fire event to change parameter color in the parameters tree
                // TODO: I think the colorMAp needs just the colors for the
                // parameters and in the same order  We will have to create this
                // datamap on the fly - I guess
                var colorMap = GLOBAL.DS.RAObjects.dataMaps.seriesParametersColorMap;
                type = 'bySeries';
                this.requestObject.chartRequest.charts[0].color.dataMap =
                    colorMap.guid;
                this.addDataMap(colorMap, dataMaps.colorMaps);
                // sd4: maybe I dont need the legend since the parameters panel will
                // be updated to reflect the colors??
                /* var colorLegend = {"guid":"colorLegend1","type":"color",
             "chartGuid":this.requestObject.chartRequest.charts[0].guid,"width":300,
             "height":100}; if (legends === null) { legends = [];
             }
             legends.push(colorLegend);*/
            }

            this.requestObject.chartRequest.charts[0].color.type = type;
        }

        // Srikanth: There can be more than one constraint added to a chart
        if (
            this.parameters.constraints != null &&
            this.parameters.constraints.length > 0
        ) {
            this.requestObject.chartRequest.charts[0].constraints = [];
            var allC = this.requestObject.chartRequest.charts[0].constraints;
            this.parameters.constraints.forEach(function(c) {
                var constraintRequest = {
                    type: c.properties.type,
                    parameterId: c.properties.parameterID[0],
                    guid: c.id,
                    surface: {
                        opacity: 1.0,
                        color: DS.RAObjects.dataMaps.constraint.color
                    },
                    line: {
                        visible: true,
                        color: DS.RAObjects.dataMaps.constraint.line.color,
                        width: DS.RAObjects.dataMaps.constraint.line.width,
                        style:
                            DS.RAObjects.dataMaps.constraint.line.style ||
                            'solid'
                    }
                };
                allC.push(constraintRequest);
            });
        } else {
            if (this.chartProperties.defaults[0].constraints != null) {
                // TODO get the latest state from the ui panel
                this.requestObject.chartRequest.charts[0].constraints = this.chartProperties.defaults[0].constraints;
                //               var constraintRequest = {"type":"GREATER_THAN",
                //               "guid": "MaxRange < 200"};
                //               this.requestObject.chartRequest.charts[0].constraints[0]
                //               = constraintRequest;
            }
        }

        this.requestObject.chartRequest.data = dataParams;
        this.requestObject.chartRequest.dataMaps = dataMaps;
        this.requestObject.chartRequest.legends = legends;
    };

    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avsbarchart = avsChartPrototype;
})(this);
