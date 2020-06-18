(function(GLOBAL) {
    if (
        typeof GLOBAL.DS.RAComponents.avsrawscatterchartmatrix !== 'undefined'
    ) {
        return;
    }
    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;
    
    var avsChartPrototype = {
        is: 'ra-avsrawscatterchartmatrix',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbasematrix]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsdropchartbasematrix.createdCallback.call(
            this
        );

        this.addShapeAxis();
    };

    avsChartPrototype.initialize = function(configuration) {
        GLOBAL.DS.RAComponents.avsdropchartbasematrix.initialize.call(
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
        this.handleRefreshAfterDrop();
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
        GLOBAL.DS.RAComponents.avsdropchartbasematrix.preRender.call(this);

        this.divs.shapeDropZone.hidePlaceholder();
    };

    avsChartPrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.avsdropchartbasematrix.renderControlPanel.call(
            this,
            panel
        );

        var that = this;

        var dimensions = this.chartProperties.uiprops.dimensions;

        // Modify param panels
        this.controls.xControl.nParameters(10);
        this.controls.xControl.setShowAxisFilter(true);
        this.controls.xControl.setShowParamFilter(true);

        // Modify param panels
        this.controls.yControl.nParameters(10);
        this.controls.yControl.setShowAxisFilter(true);
        this.controls.yControl.setShowParamFilter(true);

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
        this.controls.colorControl.setShowAggregationType(false);
        this.controls.sizeControl.setShowAggregationType(false);
        this.controls.shapeControl.setShowAggregationType(false);
        //this.controls.labelControl.setShowAggregationType(false);
    };

    avsChartPrototype.updateRequest = function() {
        var that = this;

        var baseChart = that.controls.chartPropertiesControl.getRequest();
        baseChart.guid = 'scatter1';

        var dataParams = {
            raw: [
                { guid: this.parameters.x[0].id },
                { guid: this.parameters.y[0].id }
            ]
        };
        var dataMaps = { colorMaps: [], sizeMaps: [], shapeMaps: [] };
        var legends = null;

        // Populate color parameter
        var type = that.controls.colorControl.getType();
        if (type === 'byData') {
            baseChart.color = {
                type: 'byData',
                data: { guid: this.parameters.color.id }
            };
            if (this.parameters.color.dataType === 'STRING') {
                baseChart.color.data.type = 'binnedDiscrete';
                baseChart.color.data.discreteValues = that.controls.colorControl.getDiscreteValues();
            } else {
                baseChart.color.data.type = 'raw';
                baseChart.color.data.minFilterPercent = that.controls.colorControl.getLinearMinValue();
                baseChart.color.data.maxFilterPercent = that.controls.colorControl.getLinearMaxValue();
            }

            var colorMap = that.controls.colorControl.getDataMap();
            baseChart.color.dataMap = colorMap.guid;
            this.addDataMap(colorMap, dataMaps.colorMaps);

            this.addRawParam(this.parameters.color, dataParams.raw);

            var colorLegend = {
                guid: 'colorLegend1',
                type: 'color',
                chartGuid: baseChart.guid,
                width: 300,
                height: 100
            };
            if (legends === null) {
                legends = [];
            }
            legends.push(colorLegend);
        } else {
            baseChart.color.type = 'fixed';
            baseChart.color.defaultColor = that.controls.colorControl.getFixedColor();
        }

        // Populate size parameter
        if (this.parameters.size != null) {
            baseChart.size = { data: { guid: this.parameters.size.id } };
            baseChart.size.data.type = 'raw';
            baseChart.size.data.minFilterPercent = that.controls.sizeControl.getLinearMinValue();
            baseChart.size.data.maxFilterPercent = that.controls.sizeControl.getLinearMaxValue();

            var sizeMap = that.controls.sizeControl.getDataMap();
            baseChart.size.dataMap = sizeMap.guid;
            this.addDataMap(sizeMap, dataMaps.sizeMaps);

            this.addRawParam(this.parameters.size, dataParams.raw);

            var sizeLegend = {
                guid: 'sizeLegend1',
                type: 'size',
                orientation: 'vertical',
                chartGuid: baseChart.guid,
                width: 300,
                height: 100
            };
            if (legends === null) {
                legends = [];
            }
            legends.push(sizeLegend);
        } else {
            baseChart.size = {};
        }
        baseChart.size.baseSize = that.controls.sizeControl.getLinearScaleValue();

        // Populate shape parameter
        if (this.parameters.shape != null) {
            baseChart.shape = { data: { guid: this.parameters.shape.id } };
            if (this.parameters.shape.dataType === 'STRING') {
                baseChart.shape.data.type = 'binnedDiscrete';
                baseChart.shape.data.discreteValues = that.controls.shapeControl.getDiscreteValues();
            } else {
                baseChart.shape.data.type = 'raw';
                baseChart.shape.data.minFilterPercent = that.controls.shapeControl.getLinearMinValue();
                baseChart.shape.data.maxFilterPercent = that.controls.shapeControl.getLinearMaxValue();
            }

            var shapeMap = that.controls.shapeControl.getDataMap();
            baseChart.shape.dataMap = shapeMap.guid;
            this.addDataMap(shapeMap, dataMaps.shapeMaps);

            this.addRawParam(this.parameters.shape, dataParams.raw);

            var shapeLegend = {
                guid: 'shapeLegend1',
                type: 'shape',
                orientation: 'vertical',
                chartGuid: baseChart.guid,
                width: 300,
                height: 100
            };
            if (legends === null) {
                legends = [];
            }
            legends.push(shapeLegend);
        } else {
            baseChart.shape = null;
        }

        // Populate label parameter
        if (this.parameters.label != null) {
            baseChart.label = {
                data: { type: 'raw', guid: this.parameters.label.id }
            };
            baseChart.label.properties = that.controls.labelControl.getLabelProperties();
            this.addRawParam(this.parameters.label, dataParams.raw);
        } else {
            baseChart.label = null;
        }

        // Srikanth: There can be more than one constraint attaded to a chart
        if (
            this.parameters.constraints != null &&
            this.parameters.constraints.length > 0
        ) {
            baseChart.constraints = [];
            var allC = baseChart.constraints;
            this.parameters.constraints.forEach(function(c) {
                var constraintRequest = {
                    type: c.properties.type,
                    guid: c.id,
                    surface: { opacity: 1.0, color: '#ededed' }
                };
                allC.push(constraintRequest);
            });
        } else {
            if (this.chartProperties.defaults[0].constraints != null) {
                // TODO get the latest state from the ui panel
                baseChart.constraints = this.chartProperties.defaults[0].constraints;
                //               var constraintRequest = {"type":"GREATER_THAN",
                //               "guid": "MaxRange < 200"}; baseChart.constraints[0]
                //               = constraintRequest;
            }
        }

        //        this.requestObject.chartRequest.layout =
        //        {"type":"matrix","numGridRows":3,"numGridColumns":3};
        this.requestObject.chartRequest.layout = {
            type: 'matrix',
            numGridRows: this.parameters.y.length,
            numGridColumns: this.parameters.x.length
        };
        this.requestObject.chartRequest.charts = [];

        for (
            var i = this.requestObject.chartRequest.layout.numGridRows - 1;
            i > -1;
            i--
        ) {
            this.addRawParam(this.parameters.y[i], dataParams.raw);
            for (
                var j = 0;
                j < this.requestObject.chartRequest.layout.numGridColumns;
                j++
            ) {
                var curChart = JSON.parse(JSON.stringify(baseChart));
                
                // Populate x parameter
                if (this.parameters.x[j].dataType === 'STRING') {
                    curChart.x = {
                        data: { type: 'binnedDiscrete', guid: this.parameters.x[j].id }
                    };                    
                } else {
                    curChart.x = {
                        data: { type: 'raw', guid: this.parameters.x[j].id }
                    };                    
                }
                curChart.x.axisProperties = {title: { text: decodeURIComponent(this.parameters.x[j].displayName)}};

                // Populate y parameter
                if (this.parameters.y[i].dataType === 'STRING') {
                    curChart.y = {
                        data: { type: 'binnedDiscrete', guid: this.parameters.y[i].id }
                    };                    
                } else {
                    curChart.y = {
                        data: { type: 'raw', guid: this.parameters.y[i].id }
                    };                    
                }
                curChart.y.axisProperties = {title: { text: decodeURIComponent(this.parameters.y[i].displayName) }};
        
            
                this.addRawParam(this.parameters.x[j], dataParams.raw);
                this.requestObject.chartRequest.charts.push(curChart);
            }
        }

        this.requestObject.chartRequest.data = dataParams;
        this.requestObject.chartRequest.dataMaps = dataMaps;
        this.requestObject.chartRequest.legends = legends;
    };

    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avsrawscatterchartmatrix = avsChartPrototype;
})(this);
