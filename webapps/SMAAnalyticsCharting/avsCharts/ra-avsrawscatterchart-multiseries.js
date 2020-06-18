(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.avsrawscatterchartmultiseries !== 'undefined') {
        return;
    }

    var chartLibrary = GLOBAL.DS.RAObjects.chartParameterLibrary;
    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;

    var avsChartPrototype = {
        is: 'ra-avsrawscatterchart-multiseries',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase, GLOBAL.DS.RAComponents.avsrawscatterchart]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsrawscatterchart.createdCallback.call(this);
    };
    
    avsChartPrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.avsrawscatterchart.renderControlPanel.call(
            this,
            panel
        );

        // Modify param panels
        if(this.controls.yControl) {
        	this.controls.yControl.nParameters(10);
        	this.controls.yControl.setShowAxisFilter(true);
        	this.controls.yControl.setShowParamFilter(false);
            this.controls.yControl.setParameterColorSelector(this.getSeriesColorForParameter);
        }
    };

    // sd4: this is the meat of where the chart request happens
    // A modified version of this is in all the matrix charts
    // IF YOU MAKE A CHANGE HERE, UPDATE THE SCATTER MATRIX AS WELL
    avsChartPrototype.updateRequest = function() {
        var that = this;
        var originalRequest = that.controls.chartPropertiesControl.getRequest();
        
        var dataParams = {
	            raw: [
	                { guid: this.parameters.x.id }
	            ]
	        };
        var dataMaps = { colorMaps: [], sizeMaps: [], shapeMaps: [] };
        var legends = null;
        var dataParams = {
	            raw: [
	                { guid: this.parameters.x.id }
	            ]
	        };

        for(var i = 0 ;i < this.parameters.y.length; i++) {
	        this.requestObject.chartRequest.charts[i] = JSON.parse(JSON.stringify(originalRequest));
	        this.requestObject.chartRequest.charts[i].guid = 'scatter'+(i+1);
	        
	        if (this.parameters.x.dataType === 'STRING') {
	            this.requestObject.chartRequest.charts[i].x = {"data":{"type":"binnedDiscrete","guid":this.parameters.x.id}};
	            this.requestObject.chartRequest.charts[i].x.data.discreteValues =
	        that.controls.xControl.getDiscreteValues();
	        }
	        else {
	            this.requestObject.chartRequest.charts[i].x = {"data":{"type":"raw","guid":this.parameters.x.id}};
	            this.requestObject.chartRequest.charts[i].x.data.minFilterPercent = that.controls.xControl.getLinearMinValue();
	            this.requestObject.chartRequest.charts[i].x.data.maxFilterPercent = that.controls.xControl.getLinearMaxValue();
	        }

	        dataParams.raw.push({ guid: this.parameters.y[i].id })
	
	        // Populate y parameter
	        if (this.parameters.y[i].dataType === 'STRING') {
	            this.requestObject.chartRequest.charts[i].y = {
	                data: { type: 'binnedDiscrete', guid: this.parameters.y[0].id }
	            };
	            this.requestObject.chartRequest.charts[i].y.data.discreteValues = that.controls.yControl.getDiscreteValues();
	        } else {
	            this.requestObject.chartRequest.charts[i].y = {
	                data: { type: 'raw', guid: this.parameters.y[i].id }
	            };
	            this.requestObject.chartRequest.charts[i].y.data.minFilterPercent = that.controls.yControl.getLinearMinValue();
	            this.requestObject.chartRequest.charts[i].y.data.maxFilterPercent = that.controls.yControl.getLinearMaxValue();
	        }
	        this.requestObject.chartRequest.charts[i].y.axisProperties = that.controls.yControl.getAxisProperties();
	
	        // Populate color parameter
	
	        // Color hacks copied from binned param
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
	            if (this.parameters.y.length === 1) {
	                type = 'fixed';
	                this.requestObject.chartRequest.charts[i].color.defaultColor = that.controls.colorControl.getFixedColor();
	            } else if (this.parameters.y.length > 1) {
	                // Get colormaps from example library
	                // This should come from parameter <---> color map
	                // TODO: fire event to change parameter color in the parameters tree
	                // TODO: I think the colorMAp needs just the colors for the
	                // parameters and in the same order  We will have to create this
	                // datamap on the fly - I guess
	                type = 'fixed';
	                this.requestObject.chartRequest.charts[i].color.defaultColor = this.getSeriesColorForParameter(this.parameters.y[i].id);;

	            }
	        }
	
	        // Populate size parameter
	        if (this.parameters.size != null) {
	            this.requestObject.chartRequest.charts[i].size = {
	                data: { guid: this.parameters.size.id }
	            };
	            this.requestObject.chartRequest.charts[i].size.data.type = 'raw';
	            this.requestObject.chartRequest.charts[i].size.data.minFilterPercent = that.controls.sizeControl.getLinearMinValue();
	            this.requestObject.chartRequest.charts[i].size.data.maxFilterPercent = that.controls.sizeControl.getLinearMaxValue();
	
	            var sizeMap = that.controls.sizeControl.getDataMap();
	            this.requestObject.chartRequest.charts[i].size.dataMap =
	                sizeMap.guid;
	            this.addDataMap(sizeMap, dataMaps.sizeMaps);
	
	            this.addRawParam(this.parameters.size, dataParams.raw);
	
	            var sizeLegend = {
	                guid: 'sizeLegend1',
	                type: 'size',
	                orientation: 'vertical',
	                chartGuid: this.requestObject.chartRequest.charts[i].guid,
	                width: 300,
	                height: 100
	            };
	            if (legends === null) {
	                legends = [];
	            }
	            if(i===0)
	            	legends.push(sizeLegend);
	        } else {
	            this.requestObject.chartRequest.charts[0].size = {};
	        }
	        this.requestObject.chartRequest.charts[0].size.baseSize = that.controls.sizeControl.getLinearScaleValue();
	
	        // Populate shape parameter
	        if (this.parameters.shape != null) {
	            this.requestObject.chartRequest.charts[0].shape = {
	                data: { guid: this.parameters.shape.id }
	            };
	            if (this.parameters.shape.dataType === 'STRING') {
	                this.requestObject.chartRequest.charts[0].shape.data.type =
	                    'binnedDiscrete';
	                this.requestObject.chartRequest.charts[0].shape.data.discreteValues = that.controls.shapeControl.getDiscreteValues();
	            } else {
	                this.requestObject.chartRequest.charts[0].shape.data.type =
	                    'raw';
	                this.requestObject.chartRequest.charts[0].shape.data.minFilterPercent = that.controls.shapeControl.getLinearMinValue();
	                this.requestObject.chartRequest.charts[0].shape.data.maxFilterPercent = that.controls.shapeControl.getLinearMaxValue();
	            }
	
	            var shapeMap = that.controls.shapeControl.getDataMap();
	            this.requestObject.chartRequest.charts[0].shape.dataMap =
	                shapeMap.guid;
	            this.addDataMap(shapeMap, dataMaps.shapeMaps);
	
	            this.addRawParam(this.parameters.shape, dataParams.raw);
	
	            var shapeLegend = {
	                guid: 'shapeLegend1',
	                type: 'shape',
	                orientation: 'vertical',
	                chartGuid: this.requestObject.chartRequest.charts[0].guid,
	                width: 300,
	                height: 100
	            };
	            if (legends === null) {
	                legends = [];
	            }
	            legends.push(shapeLegend);
	        } else {
	            if (this.parameters.y.length === 1) {
	                type = 'fixed';
	                this.requestObject.chartRequest.charts[i].color.shape = null;
	            } else if (this.parameters.y.length > 1) {
	                // Get colormaps from example library
	                // This should come from parameter <---> color map
	                // TODO: fire event to change parameter color in the parameters tree
	                // TODO: I think the colorMAp needs just the colors for the
	                // parameters and in the same order  We will have to create this
	                // datamap on the fly - I guess
	                type = 'fixed';
	                this.requestObject.chartRequest.charts[i].shape.type = this.getShapeForParameter(this.parameters.y[i].id);;

	            }
	        	
	          //  this.requestObject.chartRequest.charts[0].shape = null;
	        }
	
	        // Populate label parameter
	        if (this.parameters.label != null) {
	            this.requestObject.chartRequest.charts[0].label = {
	                data: { type: 'raw', guid: this.parameters.label.id }
	            };
	            this.requestObject.chartRequest.charts[0].label.properties = that.controls.labelControl.getLabelProperties();
	            this.addRawParam(this.parameters.label, dataParams.raw);
	        } else {
	            this.requestObject.chartRequest.charts[0].label = null;
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
        }
        this.requestObject.chartRequest.data = dataParams;
        this.requestObject.chartRequest.dataMaps = dataMaps;
        this.requestObject.chartRequest.legends = legends;
    };

    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avsrawscatterchartmultiseries = avsChartPrototype;
})(this);
