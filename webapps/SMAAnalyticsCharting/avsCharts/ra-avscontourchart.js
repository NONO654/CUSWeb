(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.avscontourchart !== 'undefined') {
        return;
    }

    var chartLibrary = GLOBAL.DS.RAObjects.chartParameterLibrary;

    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;

    var avsChartPrototype = {
        is: 'ra-avscontourchart',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.createdCallback.call(this);

        this.makeZoomable();
    };

    avsChartPrototype.initialize = function(configuration) {
        GLOBAL.DS.RAComponents.avsdropchartbase.initialize.call(
            this,
            configuration
        );
    };


    avsChartPrototype.getColorParameter = function(parameter, attributes) {
        var chartParam;
        attributes = attributes || {};
        attributes.data = attributes.data || {};

        if (parameter.dataType === 'STRING') {
            chartParam = chartLibrary.parameterTemplates.binnedDiscreteColor.create(
                'Color'
            );
            attributes.data.discreteValues = parameter.stringSortedByFreqs;
        } else {
            chartParam = chartLibrary.parameterTemplates.binnedNumericColor.create(
                'Color'
            );
        }
        
        if(parameter.colorDataMap){
            attributes.dataMap = parameter.colorDataMap;
        }

        chartParam.update(attributes);

        return chartParam;
    };


    avsChartPrototype.preRender = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.preRender.call(this);

    };

    avsChartPrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.avsdropchartbase.renderControlPanel.call(
            this,
            panel
        );

        var that = this;

        var dimensions = this.chartProperties.uiprops.dimensions;

 
        // Modify param panels
        this.controls.yControl.setShowAggregationType(false);
        this.controls.colorControl.setNoParamSelectVisible(false);
        if(this.requestObject && this.requestObject.chartRequest && this.requestObject.chartRequest.charts[0] && this.requestObject.chartRequest.charts[0].approximation) {
            this.controls.chartPropertiesControl.setApproximation(this.requestObject.chartRequest.charts[0].approximation.approxId);
        }
    };

    avsChartPrototype.updateRequest = function() {
        var that = this;

        this.requestObject.chartRequest.charts[0] = that.controls.chartPropertiesControl.getRequest();
        this.requestObject.chartRequest.charts[0].guid = 'contour1';

        var dataParams = {
            raw: [
                { guid: this.parameters.x.id },
                { guid: this.parameters.y[0].id }
            ]
        };
        var dataMaps = { colorMaps: [] };
        var legends = null;

         // QW8: For now, I'm replacing ONLY THE X PARAMETER using the new
        // chartParameter paradigm.

        // Update the parameter. Everything else handled by "updateRequestObject".
        if (this.parameters.x.dataType == 'STRING') {
            throw "String parameters not supported for X";
        } else {
            this.chartParameters.x.update({
                data: {
                    type: 'raw'
                }
            });
        }

        // Update the request object --- moved to finish.
        // this.updateRequestObject();

        // Populate y parameter
        this.requestObject.chartRequest.charts[0].y.data = {};
        this.requestObject.chartRequest.charts[0].y.axisProperties = that.controls.yControl.getAxisProperties();
        if (this.parameters.y[0].dataType === 'STRING') {
            throw "String parameters not supported for Y";
        } else {
            this.requestObject.chartRequest.charts[0].y.data = {
                type: 'raw',
                guid: this.parameters.y[0].id
            };
            this.requestObject.chartRequest.charts[0].y.data.minFilterPercent = that.controls.yControl.getLinearMinValue();
            this.requestObject.chartRequest.charts[0].y.data.maxFilterPercent = that.controls.yControl.getLinearMaxValue();

            this.requestObject.chartRequest.charts[0].y.axisProperties.style =
                'numeric';
        }

         if (this.parameters.color && this.parameters.color.id) {
            dataParams.raw.push({ guid: this.parameters.color.id });

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

            // TODO: This is a hack. Need to figure out where the color maps come
            // from.
            var colorMap = that.controls.colorControl.getDataMap();
            this.addDataMap(colorMap, dataMaps.colorMaps);
        } else {
            // TODO: Use a fixed color parameter here.
            // Note: this probably means not deleting the parameter, maybe? Or some
            // better generalization?
            this.requestObject.chartRequest.charts[0].color.type = 'fixed';
            this.requestObject.chartRequest.charts[0].color.defaultColor = that.controls.colorControl.getFixedColor();
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

        GLOBAL.DS.RAObjects.dataMaps.linearColorMaps.forEach(function(
            colorMap
        ) {
            that.addDataMap(colorMap, dataMaps.colorMaps);
        });

        this.requestObject.chartRequest.data = dataParams;
        this.requestObject.chartRequest.dataMaps = dataMaps;
        this.requestObject.chartRequest.legends = legends;

        // this.updateRequestObject();
    };

    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avscontourchart = avsChartPrototype;
})(this);
