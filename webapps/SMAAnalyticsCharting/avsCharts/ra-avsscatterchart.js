(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.avsscatterchart !== 'undefined') {
        return;
    }

    var chartLibrary = GLOBAL.DS.RAObjects.chartParameterLibrary;

    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;

    var avsChartPrototype = {
        is: 'ra-avsscatterchart',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.createdCallback.call(this);
        this.addShapeAxis();

        this.makeZoomable();
    };

    avsChartPrototype.initialize = function(configuration) {
        GLOBAL.DS.RAComponents.avsdropchartbase.initialize.call(
            this,
            configuration
        );
        if (!this.parameters.shape) {
            this.parameters.shape = null;
        }
    };

    avsChartPrototype.addShapeAxis = function() {
        var that = this;

        this.divs.shapeDropZone = document.createElement('ra-chartdroptarget');
        this.divs.shapeDropZone.classList.add('avsDropChart-shapeDropZone');
        this.divs.shapeDropZone.setDragEnterListener(
            this.divs.shapeDropZone.showPlaceholder
        );
        this.divs.shapeDropZone.setDragLeaveListener(
            this.divs.shapeDropZone.hidePlaceholder
        );
        this.divs.shapeDropZone.setParameterListener(
            this.divs.setShapeParameter
        );
        this.divs.shapeDropZone.showPlaceholder();
        this.divs.shapeDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        this.divs.shapeDropZone.setPlaceholderText(function() {
            if (
                typeof that.parameters.shape !== 'undefined' &&
                that.parameters.shape !== null
            ) {
                return String(
                    decodeURIComponent(
                        that.parameters.shape.displayName ||
                            that.parameters.shape.name
                    )
                );
            } else {
                return 'Shape';
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateShapeData);
        paramHandler.setDropListener(function(param) {
            if (param) {        
                var targetShapeMap = that.getShapeMap(param);           
                that.setShapeMap(param, targetShapeMap);            
            } else {
                that.setShapeParameter(null, null);            
            }
        });
        this.divs.shapeDropZone.appendChild(paramHandler);
        this.divs.root.appendChild(this.divs.shapeDropZone);
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

    avsChartPrototype.getShapeMap = function(param) {
        var targetShapeMap = null;
        if (param.properties.structure == 'SCALAR') {
            if (
                param.properties.dataType == 'REAL' ||
                param.properties.dataType == 'INTEGER'
            ) {
                var assignedParameterShapeMap = GLOBAL.DS.RAObjects.assignedLinearParamShapeDimension;            
                var existingParamShapeMap = assignedParameterShapeMap[param.id];
                
                if(existingParamShapeMap === undefined){
                    if (
                        DS.RAObjects.nextShapeMapNumericIndex >=
                        DS.RAObjects.dataMaps.binnedShapeMaps.length
                    ) {
                        DS.RAObjects.nextShapeMapNumericIndex = 0;
                    }
                    var shapeMapIndex = DS.RAObjects.nextShapeMapNumericIndex;
                    DS.RAObjects.nextShapeMapNumericIndex++; // increment it to assign
                    // a different map to
                    // another parameter
                    targetShapeMap =
                    DS.RAObjects.dataMaps.binnedShapeMaps[shapeMapIndex];
                    
                    assignedParameterShapeMap[param.id] = targetShapeMap;
                    
                    // propagate colorMap change event
                    this.propagateChartEvent({
                        eventType: 'paramMapUpdate',
                        paramId: param.id,
                        shapeMap: targetShapeMap
                    });
                    
                } else {
                    targetShapeMap = existingParamShapeMap;
                }
            } else if (param.properties.dataType == 'STRING') {
                var assignedDiscreteParameterShapeMap = GLOBAL.DS.RAObjects.assignedDiscreteParamShapeDimension;            
                var existingDiscreteParamShapeMap = assignedDiscreteParameterShapeMap[param.id];
                
                if(existingDiscreteParamShapeMap === undefined){
                    if (
                        DS.RAObjects.nextShapeMapDiscreteIndex >=
                        DS.RAObjects.dataMaps.discreteShapeMaps.length
                    ) {
                        DS.RAObjects.nextShapeMapDiscreteIndex = 0;
                    }
                    var shapeMapIndex = DS.RAObjects.nextShapeMapDiscreteIndex;
                    DS.RAObjects.nextShapeMapDiscreteIndex++; // increment it to
                    // assign a different
                    // map to another
                    // parameter
                    targetShapeMap =
                        DS.RAObjects.dataMaps.discreteShapeMaps[shapeMapIndex];
                        
                    assignedDiscreteParameterShapeMap[param.id] = targetShapeMap;
                    
                    // propagate colorMap change event
                    this.propagateChartEvent({
                        eventType: 'paramMapUpdate',
                        paramId: param.id,
                        shapeMap: targetShapeMap
                    });
                        
                     
                } else {
                    targetShapeMap = existingDiscreteParamShapeMap;
                }
            }
        }
        return targetShapeMap;
    };
    avsChartPrototype.setShapeMap = function(param, shapeMap) {
        console.log('Added shape parameter: ' + param.id);
        this.controls.shapeControl.updateController(
            [param.properties],
            shapeMap
        );
        this.setShapeParameter(param.properties);
        this.renderChart();
    };

    avsChartPrototype.validateShapeData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };

    avsChartPrototype.setShapeParameter = function(parameter) {
        var that = this;
        that.parameters.shape = parameter;
        that.divs.shapeDropZone.updatePlaceholder();
    };

    avsChartPrototype.preRender = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.preRender.call(this);

        this.divs.shapeDropZone.hidePlaceholder();
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
        var shapeIcon = this.controls.shapeControl.querySelector(
            '.controlIcon'
        );
        if (shapeIcon !== null) {
            shapeIcon.classList.add('shapeParamIcon');
            shapeIcon.setAttribute('title', NLSUtils.translate('Shape'));
        }

        // Modify param panels
        this.controls.yControl.setShowAggregationType(false);
        this.controls.colorControl.setNoParamSelectVisible(false);
    };

    avsChartPrototype.updateRequest = function() {
        var that = this;

        this.requestObject.chartRequest.charts[0] = that.controls.chartPropertiesControl.getRequest();
        this.requestObject.chartRequest.charts[0].guid = 'scatter1';

        var dataParams = {
            raw: [
                { guid: this.parameters.x.id },
                { guid: this.parameters.y[0].id }
            ]
        };
        var dataMaps = { colorMaps: [], sizeMaps: [], shapeMaps: [] };
        var legends = null;

        // Populate x parameter
        /*this.requestObject.chartRequest.charts[0].x.data = {};
    this.requestObject.chartRequest.charts[0].x.axisProperties =
    that.controls.xControl.getAxisProperties(); if (this.parameters.x.dataType
    === 'STRING') { this.requestObject.chartRequest.charts[0].x.data = {
                "type":"binnedDiscrete","guid":this.parameters.x.id};
        this.requestObject.chartRequest.charts[0].x.data.discreteValues =
    that.controls.xControl.getDiscreteValues();

        this.requestObject.chartRequest.charts[0].x.axisProperties.style =
    "auto";
    }
    else {
        this.requestObject.chartRequest.charts[0].x.data =
    {"type":"binnedEqualWidth","guid":this.parameters.x.id};
        // 5 pixel bins
        var numBins = parseInt(this.divs.chartDropZone.offsetWidth / 5);
        this.requestObject.chartRequest.charts[0].x.data.numBins = numBins;
        this.requestObject.chartRequest.charts[0].x.data.minFilterPercent =
    that.controls.xControl.getLinearMinValue();
        this.requestObject.chartRequest.charts[0].x.data.maxFilterPercent =
    that.controls.xControl.getLinearMaxValue();

        this.requestObject.chartRequest.charts[0].x.axisProperties.style =
    "numeric";
    }*/

        // QW8: For now, I'm replacing ONLY THE X PARAMETER using the new
        // chartParameter paradigm.

        // Update the parameter. Everything else handled by "updateRequestObject".
        if (this.parameters.x.dataType == 'STRING') {
        } else {
            this.chartParameters.x.update({
                data: {
                    numBins: parseInt(this.divs.chartDropZone.offsetWidth / 5)
                }
            });
        }

        // Update the request object --- moved to finish.
        // this.updateRequestObject();

        // Populate y parameter
        this.requestObject.chartRequest.charts[0].y.data = {};
        this.requestObject.chartRequest.charts[0].y.axisProperties = that.controls.yControl.getAxisProperties();
        if (this.parameters.y[0].dataType === 'STRING') {
            this.requestObject.chartRequest.charts[0].y.data = {
                type: 'binnedDiscrete',
                guid: this.parameters.y[0].id
            };
            this.requestObject.chartRequest.charts[0].y.data.discreteValues = that.controls.yControl.getDiscreteValues();

            this.requestObject.chartRequest.charts[0].y.axisProperties.style =
                'auto';
        } else {
            this.requestObject.chartRequest.charts[0].y.data = {
                type: 'binnedEqualWidth',
                guid: this.parameters.y[0].id
            };
            // 5 pixel bins
            var numBins = parseInt(this.divs.chartDropZone.offsetHeight / 5);
            this.requestObject.chartRequest.charts[0].y.data.numBins = numBins;
            this.requestObject.chartRequest.charts[0].y.data.minFilterPercent = that.controls.yControl.getLinearMinValue();
            this.requestObject.chartRequest.charts[0].y.data.maxFilterPercent = that.controls.yControl.getLinearMaxValue();

            this.requestObject.chartRequest.charts[0].y.axisProperties.style =
                'numeric';
        }

        // Populate color parameter
        /*var type = that.controls.colorControl.getType();
    if (type === 'byData') {
        this.requestObject.chartRequest.charts[0].color =
    {"type":"byData","data":{"type":"aggregation","guid":this.parameters.color.id}};
        if (this.parameters.color.dataType === 'STRING') {
            this.requestObject.chartRequest.charts[0].color.data.discreteValues
    = that.controls.colorControl.getDiscreteValues();
        }
        else {
            this.requestObject.chartRequest.charts[0].color.data.minFilterPercent
    = that.controls.colorControl.getLinearMinValue();
            this.requestObject.chartRequest.charts[0].color.data.maxFilterPercent
    = that.controls.colorControl.getLinearMaxValue();
        }
        this.requestObject.chartRequest.charts[0].color.data.aggregationType =
    that.controls.colorControl.getAggregationType();

        var colorMap = that.controls.colorControl.getDataMap();
        this.requestObject.chartRequest.charts[0].color.dataMap = colorMap.guid;
        this.addDataMap(colorMap, dataMaps.colorMaps);

        this.addRawParam(this.parameters.color, dataParams.raw);

        var colorLegend = {"guid":"colorLegend1","type":"color",
    "chartGuid":this.requestObject.chartRequest.charts[0].guid,"width":300,
    "height":100}; if (legends === null) { legends = [];
        }
        legends.push(colorLegend);
    }
    else {
        this.requestObject.chartRequest.charts[0].color.type = "fixed";
        this.requestObject.chartRequest.charts[0].color.defaultColor =
    that.controls.colorControl.getFixedColor();
    }*/
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

        // Populate size parameter
        if (this.parameters.size != null) {
            this.requestObject.chartRequest.charts[0].size = {
                data: { guid: this.parameters.size.id }
            };
            this.requestObject.chartRequest.charts[0].size.data.type =
                'aggregation';
            this.requestObject.chartRequest.charts[0].size.data.aggregationType = that.controls.sizeControl.getAggregationType();
            this.requestObject.chartRequest.charts[0].size.data.minFilterPercent = that.controls.sizeControl.getLinearMinValue();
            this.requestObject.chartRequest.charts[0].size.data.maxFilterPercent = that.controls.sizeControl.getLinearMaxValue();

            var sizeMap = that.controls.sizeControl.getDataMap();
            this.requestObject.chartRequest.charts[0].size.dataMap =
                sizeMap.guid;
            this.addDataMap(sizeMap, dataMaps.sizeMaps);

            this.addRawParam(this.parameters.size, dataParams.raw);

            var sizeLegend = {
                guid: 'sizeLegend1',
                type: 'size',
                orientation: 'vertical',
                chartGuid: this.requestObject.chartRequest.charts[0].guid,
                width: 300,
                height: 100
            };
            if (legends === null) {
                legends = [];
            }
            legends.push(sizeLegend);
        } else {
            this.requestObject.chartRequest.charts[0].size = {};
        }
        this.requestObject.chartRequest.charts[0].size.baseSize = that.controls.sizeControl.getLinearScaleValue();

        // Populate shape parameter
        if (this.parameters.shape != null) {
            this.requestObject.chartRequest.charts[0].shape = {
                data: { type: 'aggregation', guid: this.parameters.shape.id }
            };
            if (this.parameters.shape.dataType === 'STRING') {
                this.requestObject.chartRequest.charts[0].shape.data.discreteValues = that.controls.shapeControl.getDiscreteValues();
            } else {
                this.requestObject.chartRequest.charts[0].shape.data.minFilterPercent = that.controls.shapeControl.getLinearMinValue();
                this.requestObject.chartRequest.charts[0].shape.data.maxFilterPercent = that.controls.shapeControl.getLinearMaxValue();
            }
            this.requestObject.chartRequest.charts[0].shape.data.aggregationType = that.controls.shapeControl.getAggregationType();

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
            this.requestObject.chartRequest.charts[0].shape = null;
        }

        // Populate label parameter
        if (this.parameters.label != null) {
            this.requestObject.chartRequest.charts[0].label = {
                data: { type: 'aggregation', guid: this.parameters.label.id }
            };
            this.requestObject.chartRequest.charts[0].label.data.aggregationType = that.controls.labelControl.getAggregationType();
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
    GLOBAL.DS.RAComponents.avsscatterchart = avsChartPrototype;
})(this);
