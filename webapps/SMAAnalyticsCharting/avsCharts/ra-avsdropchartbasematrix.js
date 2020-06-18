(function(GLOBAL) {
    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;
    var avsDropChartBaseMatrixPrototype = {
        is: 'ra-avsdropchartbasematrix',
        behaviors: [GLOBAL.DS.RAComponents.chart]
    };

    avsDropChartBaseMatrixPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.chart.createdCallback.call(this);

        this.divs = { root: document.createElement('div') };
        this.divs.root.classList.add('avsDropChart-rootDiv');
        this.appendChild(this.divs.root);

        // Srikanth: this should be the first since it will be laid out at the back
        this.addChart();
        // Srikanth: this should be the second since it will be laid out at the back
        //this.addConstraintDropZone();
        this.addXAxis();
        this.addYAxis();
        this.addColorDropZone();
        this.addSizeDropZone();
        //this.addLabelDropZone();
    };

    avsDropChartBaseMatrixPrototype.initialize = function(configuration) {
        if (configuration) {
            this.parameters = configuration.parameters;
        } else {
            this.parameters = {
                x: [],
                y: [],
                color: null,
                size: null,
                label: null,
                constraints: null
            };
        }

        this.requestObject = null;
        this.avsDropChart = null;
        this.overlayLegend = null;
    };

    avsDropChartBaseMatrixPrototype.getConfiguration = function() {
        var configuration = {};
                
        configuration.parameters = this.parameters;
        configuration.chartParameters = this.chartParameters;
      
        configuration.height = this.requestObject.chartRequest.height;
        configuration.width = this.requestObject.chartRequest.width;
        configuration.datasetId = this.requestObject.datasetId;        
        
        
        return configuration;
    };

    avsDropChartBaseMatrixPrototype.restore = function(configuration) {
        // this.renderControlPanel();
        // this.updateRequest();
        if (configuration.colorLegend) {
            this.setupLegend(configuration.colorLegend);
            this.resizeDropZonesWLegend(this.overlayLegend);
        }
        this.renderChart(configuration);
    };

    avsDropChartBaseMatrixPrototype.addXAxis = function() {
        var that = this;
        // The main chart will be contianed in an ra-droptarget element to handle
        // drops
        // TODO: This should be generalized onto a more specific drop target for
        // chart drop  zones, probably.
        this.divs.xAxisDropZone = document.createElement('ra-chartdroptarget');
        this.divs.xAxisDropZone.classList.add('avsDropChart-xAxisDropZone');
        this.divs.xAxisDropZone.setDragEnterListener(
            this.divs.xAxisDropZone.showPlaceholder
        );
        this.divs.xAxisDropZone.setDragLeaveListener(
            this.divs.xAxisDropZone.hidePlaceholder
        );
        this.divs.xAxisDropZone.setParameterListener(this.divs.addXParameter);
        this.divs.xAxisDropZone.showPlaceholder();
        this.divs.xAxisDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        this.divs.xAxisDropZone.setPlaceholderText(function() {
            if (that.parameters.x.length === 0) {
                return NLSUtils.translate('X Axis');
            } else {
                var text = '';
                for (var i = 0; i < that.parameters.x.length; i++) {
                    if (i != 0) {
                        text += ',';
                    }
                    text += decodeURIComponent(
                    		that.parameters.x[i].displayName ||
                    		that.parameters.x[i].name
                    		);
                }
                return text;
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateXData);
        paramHandler.setDropListener(function(param) {
            that.requestObject.datasetId = param.source;
            console.log('Added x parameter: ' + param.id);
            that.addXParameter(param.properties);
            that.controls.xControl.updateController(that.parameters.x);
            that.renderChart();
        });

        this.divs.xAxisDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.xAxisDropZone);
    };

    avsDropChartBaseMatrixPrototype.addYAxis = function() {
        var that = this;
        // The main chart will be contianed in an ra-droptarget element to handle
        // drops
        // TODO: This should be generalized onto a more specific drop target for
        // chart drop  zones, probably.
        this.divs.yAxisDropZone = document.createElement('ra-chartdroptarget');
        this.divs.yAxisDropZone.classList.add('avsDropChart-yAxisDropZone');
        this.divs.yAxisDropZone.setDragEnterListener(
            this.divs.yAxisDropZone.showPlaceholder
        );
        this.divs.yAxisDropZone.setDragLeaveListener(
            this.divs.yAxisDropZone.hidePlaceholder
        );
        this.divs.yAxisDropZone.setParameterListener(this.divs.addYParameter);
        this.divs.yAxisDropZone.showPlaceholder();
        this.divs.yAxisDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        this.divs.yAxisDropZone.setPlaceholderText(function() {
            if (that.parameters.y.length === 0) {
                return NLSUtils.translate('Y Axis');
            } else {
                var text = '';
                for (var i = 0; i < that.parameters.y.length; i++) {
                    if (i != 0) {
                        text += ',';
                    }
                    text += decodeURIComponent(
                    		that.parameters.y[i].displayName ||
                    		that.parameters.y[i].name
                    		);
                }
                return text;
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateYData);
        paramHandler.setDropListener(function(param) {
            console.log('Added y parameter: ' + param.id);
            that.addYParameter(param.properties);
            that.controls.yControl.updateController(that.parameters.y);
            that.renderChart();
        });

        this.divs.yAxisDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.yAxisDropZone);
    };

    avsDropChartBaseMatrixPrototype.addColorDropZone = function() {
        var that = this;
        // The main chart will be contianed in an ra-droptarget element to handle
        // drops
        // TODO: This should be generalized onto a more specific drop target for
        // chart drop  zones, probably.
        this.divs.colorDropZone = document.createElement('ra-chartdroptarget');
        this.divs.colorDropZone.classList.add('avsDropChart-colorDropZone');
        this.divs.colorDropZone.setDragEnterListener(
            this.divs.colorDropZone.showPlaceholder
        );
        this.divs.colorDropZone.setDragLeaveListener(
            this.divs.colorDropZone.hidePlaceholder
        );
        this.divs.colorDropZone.setParameterListener(
            this.divs.setColorParameter
        );
        this.divs.colorDropZone.showPlaceholder();
        this.divs.colorDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        this.divs.colorDropZone.setPlaceholderText(function() {
            if (
                typeof that.parameters.color !== 'undefined' &&
                that.parameters.color !== null
            ) {
            	return String(
                        decodeURIComponent(
                            that.parameters.color.displayName ||
                                that.parameters.color.name
                        )
                      );
            } else {
                return NLSUtils.translate('Color');
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateColorData);
        paramHandler.setDropListener(function(param) {
            param.properties ? (param = param.properties) : null;

            that.onColorDrop(param);
        });

        this.divs.colorDropZone.appendChild(paramHandler);
        this.divs.root.appendChild(this.divs.colorDropZone);
    };
    avsDropChartBaseMatrixPrototype.onColorDrop = function(param) {
        if (param) {        
            var targetColorMap = this.getColorMap(param);           
            this.setColorMap(param, targetColorMap);
            
        } else {
            this.setColorParameter(null, null);
            this.handleRefreshAfterDrop();
        }    
    };
    
    avsDropChartBaseMatrixPrototype.getColorMap = function(param) {
        var targetColorMap = null;
        if (param.structure === 'SCALAR') {
            if (param.dataType === 'REAL' || param.dataType === 'INTEGER') {
                        
                var assignedParameterColorMap = GLOBAL.DS.RAObjects.assignedLinearParamColorDimension;            
                var existingParamColorMap = assignedParameterColorMap[param.id];
                if(existingParamColorMap === undefined){
                    if (
                        DS.RAObjects.nextColorMapNumericIndex >=
                        DS.RAObjects.dataMaps.linearColorMaps.length
                        ) {
                            DS.RAObjects.nextColorMapNumericIndex = 0;
                        }
                    var colorMapIndex = DS.RAObjects.nextColorMapNumericIndex;
                    DS.RAObjects.nextColorMapNumericIndex++; // increment it to
                    // assign a different
                    // map to another
                    // parameter
                    targetColorMap =
                        DS.RAObjects.dataMaps.linearColorMaps[colorMapIndex];
                    assignedParameterColorMap[param.id] =  targetColorMap;
                    
                    // propagate colorMap change event
                    this.propagateChartEvent({
                        eventType: 'paramMapUpdate',
                        paramId: param.id,
                        colorMap: targetColorMap
                    });
                    
                } else {
                    targetColorMap = existingParamColorMap;
                }
                
            } 
            else if (param.dataType === 'STRING') {
            
                var assignedDiscreteParameterColorMap = GLOBAL.DS.RAObjects.assignedDiscreteParamColorDimension;            
                var existingDiscreteParamColorMap = assignedDiscreteParameterColorMap[param.id];
                
                if(existingDiscreteParamColorMap === undefined){
                    if (
                        DS.RAObjects.nextColorMapDiscreteIndex >=
                        DS.RAObjects.dataMaps.discreteColorMaps.length
                    ) {
                        DS.RAObjects.nextColorMapDiscreteIndex = 0;
                    }
                    var colorMapIndex = DS.RAObjects.nextColorMapDiscreteIndex;
                    DS.RAObjects.nextColorMapDiscreteIndex++; // increment it to
                    // assign a different
                    // map to another
                    // parameter
                    targetColorMap =
                        DS.RAObjects.dataMaps.discreteColorMaps[colorMapIndex];
                    assignedDiscreteParameterColorMap[param.id] = targetColorMap;
                } else {
                    targetColorMap = existingDiscreteParamColorMap;
                }
            }
        }
        return targetColorMap;
    };

    avsDropChartBaseMatrixPrototype.setColorMap = function(param, colorMap) {
        this.setColorParameter(param, colorMap);

        this.controls.colorControl.updateController(
            [this.parameters.color],
            colorMap
        );
        this.handleRefreshAfterDrop();
    };
    
    avsDropChartBaseMatrixPrototype.addSizeDropZone = function() {
        var that = this;
        // The main chart will be contianed in an ra-droptarget element to handle
        // drops
        // TODO: This should be generalized onto a more specific drop target for
        // chart drop  zones, probably.
        this.divs.sizeDropZone = document.createElement('ra-chartdroptarget');
        this.divs.sizeDropZone.classList.add('avsDropChart-sizeDropZone');
        this.divs.sizeDropZone.setDragEnterListener(
            this.divs.sizeDropZone.showPlaceholder
        );
        this.divs.sizeDropZone.setDragLeaveListener(
            this.divs.sizeDropZone.hidePlaceholder
        );
        this.divs.sizeDropZone.setParameterListener(this.divs.setSizeParameter);
        this.divs.sizeDropZone.showPlaceholder();
        this.divs.sizeDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        this.divs.sizeDropZone.setPlaceholderText(function() {
            if (
                typeof that.parameters.size !== 'undefined' &&
                that.parameters.size !== null
            ) {
                return String(that.parameters.size.name);
            } else {
                return NLSUtils.translate('Size');
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateSizeData);
        paramHandler.setDropListener(function(param) {
            console.log('Added size parameter: ' + param.id);
            that.setSizeParameter(param.properties);
            that.controls.sizeControl.updateController([that.parameters.size]);
            that.renderChart();
        });

        this.divs.sizeDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.sizeDropZone);
    };
    
    avsDropChartBaseMatrixPrototype.handleRefreshAfterDrop = function() {
        this.hideDropZones();
        this.renderChart();
    };
    
    

    avsDropChartBaseMatrixPrototype.addLabelDropZone = function() {
        var that = this;
        // The main chart will be contianed in an ra-droptarget element to handle
        // drops
        // TODO: This should be generalized onto a more specific drop target for
        // chart drop  zones, probably.
        this.divs.labelDropZone = document.createElement('ra-chartdroptarget');
        this.divs.labelDropZone.classList.add('avsDropChart-labelDropZone');
        this.divs.labelDropZone.setDragEnterListener(
            this.divs.labelDropZone.showPlaceholder
        );
        this.divs.labelDropZone.setDragLeaveListener(
            this.divs.labelDropZone.hidePlaceholder
        );
        this.divs.labelDropZone.setParameterListener(
            this.divs.setLabelParameter
        );
        this.divs.labelDropZone.showPlaceholder();
        this.divs.labelDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        this.divs.labelDropZone.setPlaceholderText(function() {
            if (
                typeof that.parameters.label !== 'undefined' &&
                that.parameters.label !== null
            ) {
                return String(
                        decodeURIComponent(
                            that.parameters.label.displayName ||
                                that.parameters.label.name
                        )
                    );
            } else {
                return NLSUtils.translate('Label');
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateLabelData);
        paramHandler.setDropListener(function(param) {
            console.log('Added label parameter: ' + param.id);
            that.setLabelParameter(param.properties);
            that.controls.labelControl.updateController([
                that.parameters.label
            ]);
            that.renderChart();
        });

        this.divs.labelDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.labelDropZone);
    };

    avsDropChartBaseMatrixPrototype.addConstraintDropZone = function() {
        var that = this;
        // The main chart will be contianed in an ra-droptarget element to handle
        // drops
        // TODO: This should be generalized onto a more specific drop target for
        // chart drop  zones, probably.
        this.divs.constraintDropZone = document.createElement(
            'ra-chartdroptarget'
        );
        this.divs.constraintDropZone.classList.add(
            'avsDropChart-constraintDropZone'
        );
        this.divs.constraintDropZone.setDragEnterListener(
            this.divs.constraintDropZone.showPlaceholder
        );
        this.divs.constraintDropZone.setDragLeaveListener(
            this.divs.constraintDropZone.hidePlaceholder
        );
        this.divs.constraintDropZone.setParameterListener(
            this.divs.setConstraint
        );
        this.divs.constraintDropZone.showPlaceholder();
        this.divs.constraintDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        this.divs.constraintDropZone.setPlaceholderText(function() {
            if (
                typeof that.parameters.constraints !== 'undefined' &&
                that.parameters.constraints !== null
            ) {
                return String(that.parameters.constraints.name);
            } else {
                return NLSUtils.translate('Requirements');
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateConstraintData);
        paramHandler.setDropListener(function(constraint) {
            console.log('Added constraints parameter: ' + constraint.id);
            constraint.properties.name = constraint.name; // add name as property so that it shows up in
            // the control panel and drop zone
            that.setConstraint(constraint);
            that.controls.constraintControl.updateController(
                that.parameters.constraints
            );
            that.renderChart();
        });

        this.divs.constraintDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.constraintDropZone);
    };

    avsDropChartBaseMatrixPrototype.addChart = function() {
        var that = this;
        this.divs.chartDropZone = document.createElement('ra-chartdroptarget');
        this.divs.chartDropZone.classList.add('avsDropChart-chartDropZone');
        this.divs.chartDropZone.dragHappening = function() {};
        this.divs.chartDropZone.dragEnded = function() {};
        this.divs.chartDropZone.setPlaceholderFilter(function() {
            return true;
        });
        this.divs.root.appendChild(this.divs.chartDropZone);
        this.divs.chartDropZone.hidePlaceholder();
    };

    avsDropChartBaseMatrixPrototype.validateXData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };

    avsDropChartBaseMatrixPrototype.validateYData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };

    avsDropChartBaseMatrixPrototype.validateColorData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };

    avsDropChartBaseMatrixPrototype.validateSizeData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        // and not discrete
        if (data.properties.dataType === 'STRING') {
            console.log('size parameter cannot be discrete');
            return false;
        }
        return true;
    };

    avsDropChartBaseMatrixPrototype.validateLabelData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };

    avsDropChartBaseMatrixPrototype.validateConstraintData = function(data) {
        // check that datum is a parameter
        //          if(data.type !==
        //          GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER){
        //              return false;
        //          }
        return true;
    };

    avsDropChartBaseMatrixPrototype.addXParameter = function(parameter) {
        var that = this;
        if (
            that.parameters.x.length < that.controls.xControl.getNParameters()
        ) {
            that.parameters.x.push(parameter);
        } else {
            // Replace last parameter
            that.parameters.x.splice(-1, 1, parameter);
        }
        that.divs.xAxisDropZone.updatePlaceholder();
    };

    avsDropChartBaseMatrixPrototype.addYParameter = function(parameter) {
        var that = this;
        if (
            that.parameters.y.length < that.controls.yControl.getNParameters()
        ) {
            that.parameters.y.push(parameter);
        } else {
            // Replace last parameter
            that.parameters.y.splice(-1, 1, parameter);
        }
        that.divs.yAxisDropZone.updatePlaceholder();
    };

    avsDropChartBaseMatrixPrototype.setXParameters = function(parameters) {
        var that = this;
        that.parameters.x = parameters;
        that.divs.xAxisDropZone.updatePlaceholder();
    };

    avsDropChartBaseMatrixPrototype.setYParameters = function(parameters) {
        var that = this;
        that.parameters.y = parameters;
        that.divs.yAxisDropZone.updatePlaceholder();
    };

    avsDropChartBaseMatrixPrototype.setColorParameter = function(parameter) {
        var that = this;
        that.parameters.color = parameter;
        that.divs.colorDropZone.updatePlaceholder();
    };

    avsDropChartBaseMatrixPrototype.setSizeParameter = function(parameter) {
        var that = this;
        that.parameters.size = parameter;
        that.divs.sizeDropZone.updatePlaceholder();
    };

    avsDropChartBaseMatrixPrototype.setLabelParameter = function(parameter) {
        var that = this;
        that.parameters.label = parameter;
        that.divs.labelDropZone.updatePlaceholder();
    };

    avsDropChartBaseMatrixPrototype.setConstraint = function(constraint) {
        var that = this;
        if (constraint.constructor === Array) {
            // The control panel sends the constraints as an array:
            that.parameters.constraints = constraint;
        } else {
            var that = this;
            if (!that.parameters.constraints) {
                that.parameters.constraints = [];
            }
            that.parameters.constraints.push(constraint);
        }
        that.divs.constraintDropZone.updatePlaceholder();
    };

    avsDropChartBaseMatrixPrototype.setupLegend = function(legend) {
        var that = this;

        this.overlayLegend = this.getOverlayElement(legend);

        this.overlayLegend.addCallback('dock', function() {
            that.onLegendDock(this);
        });

        this.overlayLegend.addCallback('undock', function() {
            that.onLegendUndock(this);
        });

        var imagesDiv = document.createElement('div');
        imagesDiv.classList.add('images');

        this.overlayLegend.querySelector('.content').appendChild(imagesDiv);
    };

    avsDropChartBaseMatrixPrototype.getDefaultLegend = function(width, height) {
        var legend = {
            dockable: 'true',
            height: height,
            width: width,
            position: 'center',
            'element-draggable': 'true'
        };
        return legend;
    };

    avsDropChartBaseMatrixPrototype.onLegendDock = function(legend) {
        this.resizeDropZonesWLegend(legend);
        this.renderChart();
    };

    avsDropChartBaseMatrixPrototype.onLegendUndock = function() {
        // Clear all styles and revert to what's on the style sheet.

        d3.
            select(this).
            select('.content').
            style({ top: '', bottom: '', left: '', right: '' });
    };

    avsDropChartBaseMatrixPrototype.resizeDropZonesWLegend = function(legend) {
        var dir = legend.dockDirection || legend.getAttribute('dockDirection');
        var dimensions = {};

        this.divs.root.style.top = '0px';
        this.divs.root.style.left = '0px';
        this.divs.root.style.height = '100%';
        this.divs.root.style.width = '100%';

        if (dir === 'top') {
            dimensions = {
                top: '3px',
                bottom: '0px',
                left: '0px',
                right: '0px'
            };
            this.divs.root.style.top = legend.getAttribute('height') + 'px';
            this.divs.root.style.bottom = '0px';
            this.divs.root.style.height =
                'calc( 100% - ' + this.divs.root.style.top + ' )';
        } else if (dir === 'bottom') {
            dimensions = {
                bottom: legend.getAttribute('height') + 'px',
                top: '3px',
                left: '0px',
                right: '0px'
            };
            this.divs.root.style.top = '0px';
            this.divs.root.style.height =
                'calc( 100% - ' + dimensions.bottom + ' )';
        } else if (dir === 'left') {
            dimensions = {
                top: '3px',
                bottom: '0px',
                right: '0px',
                left: '0px'
            };
            this.divs.root.style.left = legend.getAttribute('width') + 'px';
            this.divs.root.style.right = '0px';
            this.divs.root.style.width =
                'calc( 100% - ' + this.divs.root.style.left + ' )';
        } else if (dir === 'right') {
            dimensions = {
                top: '3px',
                bottom: '0px',
                right: legend.getAttribute('width') + 'px',
                left: '0px'
            };
            this.divs.root.style.left = '0px';
            this.divs.root.style.width =
                'calc( 100% - ' + dimensions.right + ' )';
        }

        d3.
            select(this).
            select('.content').
            style(dimensions);
    };

    avsDropChartBaseMatrixPrototype.updateRequest = function() {
        var that = this;
    };

    avsDropChartBaseMatrixPrototype.placeholderFilter = function() {
        return !this.validateRender();
    };
    avsDropChartBaseMatrixPrototype.validateRender = function() {
        if (!(this.parameters.x.length >= 1 && this.parameters.y.length >= 1)) {
            return false;
        }
        return true;
    };

    avsDropChartBaseMatrixPrototype.preRender = function() {
        var that = this;

        this.divs.xAxisDropZone.hidePlaceholder();
        this.divs.yAxisDropZone.hidePlaceholder();
        this.divs.colorDropZone.hidePlaceholder();
        this.divs.sizeDropZone.hidePlaceholder();
        if(this.divs.labelDropZone !== undefined){
            this.divs.labelDropZone.hidePlaceholder();
        }
        if(this.divs.constraintDropZone !== undefined){
            this.divs.constraintDropZone.hidePlaceholder();
        }
        this.divs.chartDropZone.hidePlaceholder();
    };
    avsDropChartBaseMatrixPrototype.updateSize = function(configuration) {
        if (configuration) {
            this.requestObject.chartRequest.height = configuration.height;
            this.requestObject.chartRequest.width = configuration.width;
        } else {
            this.requestObject.chartRequest.height = this.divs.chartDropZone.offsetHeight;
            this.requestObject.chartRequest.width = this.divs.chartDropZone.offsetWidth;
        }
    };
    avsDropChartBaseMatrixPrototype.resize = function() {
        this.renderChart();
    };
    avsDropChartBaseMatrixPrototype.renderChart = function(configuration) {
        var that = this;
        
        // if configuration is undefined then its not restore and there is some change in chart 
        // e.g parameer drop, resize or param delete, must store it to widget prefer temp storage
        if(configuration === undefined){
            this.chartParent.updateChartsConfigPreference(this.chartId);            
        }
        

        if (this.validateRender() == false) {
            if (this.avsDropChart !== null) {
                this.avsDropChart.removeChartTiles();
                this.avsDropChart.removeLegendTiles();
                if (this.requestObject.chartRequest.legends === null) {
                    this.removeOverlayElements();
                    this.overlayLegend = null;
                }
            }
            return;
        }

        this.preRender();
        this.updateSize(configuration);
        this.updateRequest();
        if (configuration) {
            that.requestObject.datasetId = configuration.datasetId;
        }

        if (this.requestObject.chartRequest.legends === null) {
            this.removeOverlayElements();
            this.overlayLegend = null;
        }
        if (
            this.overlayLegend === null &&
            (this.requestObject.chartRequest.legends !== null &&
                typeof this.requestObject.chartRequest.legends !== 'undefined')
        ) {
            this.setupLegend(
                this.getDefaultLegend(
                    this.requestObject.chartRequest.legends[0].width,
                    this.requestObject.chartRequest.legends[0].height
                )
            );
        }

        if (this.avsDropChart === null) {
            this.avsDropChart = document.createElement(
                'ra-avsdropchartelementmatrix'
            );
            this.avsDropChart.setDataProvider(this.dataProvider);
            this.divs.chartDropZone.appendChild(this.avsDropChart);
            console.log('creating avs drop chart!');

            // this.avsDropChart.makeZoomable(this.zoomOptions);
        } else {
            this.avsDropChart.removeChartTiles();
            this.avsDropChart.removeLegendTiles();
        }
        this.avsDropChart.setLegend(this.overlayLegend);
        // TODO get background color from the template
        this.avsDropChart.setBackgroundColor('white');
        this.avsDropChart.setTotalWidth(this.getChartAreaWidth());
        this.avsDropChart.setTotalHeight(this.getChartAreaHeight());
        console.log('|||' + this.requestObject + '|||');
        this.avsDropChart.renderRequest(
            this.requestObject,
            this,
            this.chartProperties.defaults[0].type
        );
        console.log('rendering avs drop chart!');
    };
    avsDropChartBaseMatrixPrototype.hideDropZones = function() {
        this.querySelectorAll('ra-chartdroptarget').forEach(function(dropZone) {
            dropZone.hidePlaceholder();
        });
        this.divs.chartDropZone.style.display = 'block';
    };

    avsDropChartBaseMatrixPrototype.addRawParam = function(
        newParam,
        paramArray
    ) {
        for (var i = 0; i < paramArray.length; i++) {
            if (paramArray[i].guid === newParam.id) {
                return;
            }
        }
        paramArray.push({ guid: newParam.id });
    };

    avsDropChartBaseMatrixPrototype.addDataMap = function(
        newDataMap,
        dataMapArray
    ) {
        for (var i = 0; i < dataMapArray.length; i++) {
            if (dataMapArray[i].guid === newDataMap.guid) {
                return;
            }
        }
        dataMapArray.push(newDataMap);
    };

    avsDropChartBaseMatrixPrototype.updateAxisLabel = function(
        axisParent,
        label
    ) {
        if (typeof axisParent.axisProperties === 'undefined') {
            axisParent.axisProperties = {};
        }
        if (typeof axisParent.axisProperties.title === 'undefined') {
            axisParent.axisProperties.title = {};
        }
        axisParent.axisProperties.title.text = label;
    };

    avsDropChartBaseMatrixPrototype.getChartAreaWidth = function() {
        return this.divs.chartDropZone.offsetWidth;
    };
    avsDropChartBaseMatrixPrototype.getChartAreaHeight = function() {
        return this.divs.chartDropZone.offsetHeight;
    };
    avsDropChartBaseMatrixPrototype.renderStylePanel = function() {};
    avsDropChartBaseMatrixPrototype.updateStylePanel = function() {};
    avsDropChartBaseMatrixPrototype.renderControlPanel = function(panel) {
        var that = this;

        this.requestObject = {
            chartRequest: {
                width: this.getChartAreaWidth(),
                height: this.getChartAreaHeight(),
                charts: []
            }
        };

        var dimensions = this.chartProperties.uiprops.dimensions;

        // Add chart properties panel
        var chartPropertiesControl = null;
        var chartType = this.chartProperties.defaults[0].type;
        if (chartType === 'bar') {
            chartPropertiesControl = panel.getControl(
                'ra-barchartpropertiescontrol'
            );
        } else if (chartType === 'line') {
            chartPropertiesControl = panel.getControl(
                'ra-linechartpropertiescontrol'
            );
        } else if (chartType === 'scatter') {
            chartPropertiesControl = panel.getControl(
                'ra-scatterchartpropertiescontrol'
            );
        }
        if (chartPropertiesControl !== null) {
            chartPropertiesControl.setDefaultRequest(
                this.chartProperties.defaults[0]
            );
            chartPropertiesControl.setChangeListener(function() {
                that.renderChart();
            });
        }

        // Add x param panel
        var xDim = this.findDimension(dimensions, 'x');
        if (typeof xDim !== 'undefined') {
            var xParamControl = panel.getControl(xDim.uipanel);
            xParamControl.title('X');
            xParamControl.nParameters(1);
            xParamControl.setDefaultRequest(this.chartProperties.defaults[0].x);
            xParamControl.setFilter(this.validateXData);
            xParamControl.setShowAggregationType(false);
            xParamControl.setChangeListener(
                function(params) {
                    this.setXParameters(params);
                    this.hideDropZones();
                    this.renderChart();
                }.bind(this)
            );
            if (this.parameters.x instanceof Array) {
                xParamControl.updateController(this.parameters.x);
            }
            var xParamIcon = xParamControl.querySelector('.controlIcon');
            if (xParamIcon !== null) {
                xParamIcon.classList.add('xParamIcon');
                xParamIcon.setAttribute('title', NLSUtils.translate('X Axis'));
            }
        }

        // Add y param panel
        var yDim = this.findDimension(dimensions, 'y');
        if (typeof yDim !== 'undefined') {
            var yParamControl = panel.getControl(yDim.uipanel);
            yParamControl.title('Y');
            yParamControl.nParameters(1);
            yParamControl.setDefaultRequest(this.chartProperties.defaults[0].y);
            yParamControl.setFilter(this.validateYData);
            yParamControl.setChangeListener(
                function(params) {
                    this.setYParameters(params);
                    this.hideDropZones();
                    this.renderChart();
                }.bind(this)
            );
            if (this.parameters.y instanceof Array) {
                yParamControl.updateController(this.parameters.y);
            }
            var yParamIcon = yParamControl.querySelector('.controlIcon');
            if (yParamIcon !== null) {
                yParamIcon.classList.add('yParamIcon');
                yParamIcon.setAttribute('title', NLSUtils.translate('Y Axis'));
            }
        }

        // Add color param panel
        var colorDim = this.findDimension(dimensions, 'color');
        if (typeof colorDim !== 'undefined') {
            var colorParamControl = panel.getControl(colorDim.uipanel);
            colorParamControl.title('Color');
            colorParamControl.nParameters(1);
            colorParamControl.setDefaultRequest(
                this.chartProperties.defaults[0].color
            );
            colorParamControl.setFilter(this.validateColorData);
            colorParamControl.setChangeListener(function(params) {
            	that.onColorDrop(params.length == 0 ? null : params[0]);
            	
                //that.setColorParameter(params.length == 0 ? null : params[0]);
                //that.renderChart();
            });
            if (this.parameters.color) {
                colorParamControl.updateController([this.parameters.color], this.getColorMap(this.parameters.color));
            }
            var colorParamIcon = colorParamControl.querySelector('.controlIcon');
            if (colorParamIcon !== null) {
                colorParamIcon.classList.add('colorParamIcon');
                colorParamIcon.setAttribute(
                    'title',
                    NLSUtils.translate('Color')
                );
            }
        }

        // Add size param panel
        var sizeDim = this.findDimension(dimensions, 'size');
        if (typeof sizeDim !== 'undefined') {
            var sizeParamControl = panel.getControl(sizeDim.uipanel);
            sizeParamControl.title('Size');
            sizeParamControl.nParameters(1);
            sizeParamControl.setDefaultRequest(
                this.chartProperties.defaults[0].size
            );
            sizeParamControl.setFilter(this.validateSizeData);
            sizeParamControl.setChangeListener(function(params) {
                that.setSizeParameter(params.length == 0 ? null : params[0]);
                that.renderChart();
            });
            if (this.parameters.size) {
                sizeParamControl.updateController([this.parameters.size]);
            }
            var sizeParamIcon = sizeParamControl.querySelector('.controlIcon');
            if (sizeParamIcon !== null) {
                sizeParamIcon.classList.add('sizeParamIcon');
                sizeParamIcon.setAttribute('title', NLSUtils.translate('Size'));
            }
        }

        // Add label param panel
        var labelDim = this.findDimension(dimensions, 'label');
        if (typeof labelDim !== 'undefined') {
            var labelParamControl = panel.getControl(labelDim.uipanel);
            labelParamControl.title('Label');
            labelParamControl.nParameters(1);
            labelParamControl.setDefaultRequest(
                this.chartProperties.defaults[0].label
            );
            labelParamControl.setFilter(this.validateLabelData);
            labelParamControl.setChangeListener(function(params) {
                that.setLabelParameter(params.length == 0 ? null : params[0]);
                that.renderChart();
            });
            if (this.parameters.label) {
                labelParamControl.updateController([this.parameters.label]);
            }
            var labelParamIcon = labelParamControl.querySelector(
                    '.controlIcon'
                );
                if (labelParamIcon !== null) {
                    labelParamIcon.classList.add('labelParamIcon');
                    labelParamIcon.setAttribute(
                        'title',
                        NLSUtils.translate('Label')
                    );
                }
        }

        // Add constraint param panel
        var constraintDim = this.findDimension(dimensions, 'constraints');
        if (typeof constraintDim !== 'undefined') {
            var constraintParamControl = panel.getControl(
                constraintDim.uipanel
            );
            constraintParamControl.title('Constraints');
            constraintParamControl.nParameters(10);
            constraintParamControl.setFilter(this.validateConstraintData);
            constraintParamControl.setChangeListener(function(constraints) {
                that.setConstraint(constraints);
                that.renderChart();
            });
            if (this.parameters.constraints) {
                // Srikanth: constraints is already an array and should contain the
                // 'Name'  property that the control panel looks for...
                constraintParamControl.updateController(
                    this.parameters.constraints
                );
            }
            var constraintParamIcon = constraintParamControl.querySelector('.controlIcon');
            if (constraintParamIcon !== null) {
                constraintParamIcon.classList.add('requirementParamIcon');
                constraintParamIcon.setAttribute(
                    'title',
                    NLSUtils.translate('Constraints')
                );
            }
        }

        this.controls = {
            chartPropertiesControl: chartPropertiesControl,
            xControl: xParamControl,
            yControl: yParamControl,
            colorControl: colorParamControl,
            sizeControl: sizeParamControl,
            labelControl: labelParamControl,
            constraintControl: constraintParamControl
        };
    };

    avsDropChartBaseMatrixPrototype.findDimension = function(
        dimensions,
        findIt
    ) {
        for (var i = 0; i < dimensions.length; i++) {
            if (dimensions[i].dim === findIt) {
                return dimensions[i];
            }
        }
    };

    Polymer(avsDropChartBaseMatrixPrototype);
    GLOBAL.DS.RAComponents.avsdropchartbasematrix = avsDropChartBaseMatrixPrototype;
})(this);
