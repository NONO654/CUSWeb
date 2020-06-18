(function(GLOBAL) {
    var chartLibrary = GLOBAL.DS.RAObjects.chartParameterLibrary;
    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;

    var avsDropChartBasePrototype = {
        is: 'ra-avsdropchartbase',
        behaviors: [GLOBAL.DS.RAComponents.chart]
    };

    avsDropChartBasePrototype.createdCallback = function() {
        var that = this;

        GLOBAL.DS.RAComponents.chart.createdCallback.call(this);

        // QW8: Added to support multiple legends
        this.overlayLegends = [];
        this.legendElements = {};
        this.legendData = {};

        this.divs = { root: document.createElement('div') };
        this.divs.root.classList.add('avsDropChart-rootDiv');
        this.appendChild(this.divs.root);

        this.dockedLegends = {};

        // Srikanth: this should be the first since it will be laid out at the back
        this.addChart();
        // Srikanth: this should be the second since it will be laid out at the back
        this.addConstraintDropZone();
        this.addXAxis();
        this.addYAxis();
        this.addColorDropZone();
        // this.addColorParameter();
        this.addSizeDropZone();
        // this.addSizeParameter();
        this.addLabelDropZone();
        // this.addLabelParameter();

        this.chartParameters = {};

        this.addChartEventListener(function(args, sources) {
            that.onChartEvent(args, sources);
        });
    };

    avsDropChartBasePrototype.onChartEvent = function(args, sources) {
        if (this.avsDropChart && sources.indexOf(this.avsDropChart) === -1) {
            if (args.eventType !== 'undefined') {
                if (args.eventType === 'CASE_MODIFIED') {
                    var modifiedEvents = args.events;
                    var updateConstraints = false;
                    var updateChart = false;
                    var updateXaxisDropzone = false;                    

                    modifiedEvents.forEach(
                        function(event) {
                            if (event.eventSubType === 'constraintChanged') {
                                var modifiedConstraint =
                                    event.modifiedConstraint;

                                // even though constraint might not have been used
                                // on chart, it may make some feasible points
                                // infeasible, server does not plot infeasible
                                // points hence we need to refresh plot
                                updateChart = true;
                                if (this.parameters.constraints !== null) {
                                    for (var constraint in this.parameters.
                                        constraints) {
                                        var parameterIds = this.parameters.
                                            constraints[constraint].properties.
                                            parameterID;
                                        for (var paramaterId in parameterIds) {
                                            if (
                                                modifiedConstraint.parameterID ===
                                                    parameterIds[paramaterId] &&
                                                this.parameters.constraints[
                                                    constraint
                                                ].properties.type ==
                                                    modifiedConstraint.type
                                            ) {
                                                // we need to change name as well
                                                // even though its not used
                                                this.parameters.constraints[
                                                    constraint
                                                ].properties.name =
                                                    modifiedConstraint.name;
                                                this.parameters.constraints[
                                                    constraint
                                                ].name =
                                                    modifiedConstraint.name;
                                                this.parameters.constraints[
                                                    constraint
                                                ].properties.boundValue =
                                                    modifiedConstraint.boundValue;
                                                updateConstraints = true;
                                                updateChart = true;
                                                break;
                                            }
                                        }
                                    }
                                }
                            } else if (
                                event.eventSubType === 'parameterChanged'
                            ) {
                                // It could be either rename parameter or
                                // parameter display name change, is there
                                // anything else?
                                var newParameterMap = event.parameterMap;

                                var parameterChanged = {
                                    parChgResult: false,
                                    parDelResult: false
                                };
                                
                                if(Array.isArray( this.parameters.x)){
                					var xParameters = this.parameters.x;
                					for (
                    					var xParameterIndex = 0;
                    					xParameterIndex < xParameters.length;
                    					xParameterIndex++
                					) {
                    					var xparameter = xParameters[xParameterIndex];
                    					this._updatreParameterIfChanged(
                        					newParameterMap,
                        					xparameter,
                        					null, //xcontrol needs all params
                                    		this.divs.xAxisDropZone,
                        					parameterChanged
                    					);                    					
                    					
                					}
                					this.controls.xControl.updateController(this.parameters.x);               
            					}else{
            					
                                	this._updatreParameterIfChanged(
                                    	newParameterMap,
                                    	this.parameters.x,
                                    	this.controls.xControl,
                                    	this.divs.xAxisDropZone,
                                    	parameterChanged,
                                    	this.setXParameter.bind(this)
                                	);
								}

                                var yParameters = this.parameters.y;

                                for (
                                    var yParameterIndex = 0;
                                    yParameterIndex < yParameters.length;
                                    yParameterIndex++
                                ) {
                                    var yparameter =
                                        yParameters[yParameterIndex];
                                    this._updatreParameterIfChanged(
                                        newParameterMap,
                                        yparameter,
                                        null,
                                        this.divs.yAxisDropZone,
                                        parameterChanged
                                    );
                                }
                                if(this.controls.yControl !== undefined){
                                	this.controls.yControl.updateController(this.parameters.y);
                                }
                                

                                if (
                                    typeof this.parameters.yline !== 'undefined'
                                ) {
                                    var yLineParameters = this.parameters.yline;
                                    for (
                                        var yLineParameterIndex = 0;
                                        yLineParameterIndex <
                                        yLineParameters.length;
                                        yLineParameterIndex++
                                    ) {
                                        var ylineparameter =
                                            yLineParameters[
                                                yLineParameterIndex
                                            ];
                                        this._updatreParameterIfChanged(
                                            newParameterMap,
                                            ylineparameter,
                                            null,
                                            this.divs.yAxisLineDropZone,
                                            parameterChanged
                                        );
                                    }
                                    if(this.controls.yLineControl !== undefined){
                                    	this.controls.yLineControl.updateController(this.parameters.yline);
                                    }
                                }

                                this._updatreParameterIfChanged(
                                    newParameterMap,
                                    this.parameters.label,
                                    this.controls.labelControl,
                                    this.divs.labelDropZone,
                                    parameterChanged
                                );
                                this._updatreParameterIfChanged(
                                    newParameterMap,
                                    this.parameters.color,
                                    this.controls.colorControl,
                                    this.divs.colorDropZone,
                                    parameterChanged,
                                    this.setColorParameter.bind(this)
                                );

                                this._updatreParameterIfChanged(
                                    newParameterMap,
                                    this.parameters.colorline,
                                    this.controls.colorLineControl,
                                    this.divs.colorLineDropZone,
                                    parameterChanged
                                );
                                this._updatreParameterIfChanged(
                                    newParameterMap,
                                    this.parameters.shape,
                                    this.controls.shapeControl,
                                    this.divs.shapeDropZone,
                                    parameterChanged
                                );
                                this._updatreParameterIfChanged(
                                    newParameterMap,
                                    this.parameters.size,
                                    this.controls.sizeControl,
                                    this.divs.sizeDropZone,
                                    parameterChanged
                                );

                                this._updatreConstraintIfChangedParameter(
                                    newParameterMap
                                );
                                
                                if( typeof this.parameterChangeHandler === 'function'){
                                        	this.parameterChangeHandler(newParameterMap, parameterChanged);
								}
                                     

                                if (parameterChanged.parChgResult === true) {
                                    updateChart = true;
                                }
                            } else if (
                                event.eventSubType === 'parametersDeleted'
                            ) {
                                var deletedParametersIds = event.deletedParams;
                                for (var deletedParamIndex in deletedParametersIds) {
                                    var deletedParamId =
                                        deletedParametersIds[deletedParamIndex];
                                    var parameterDeleted = {
                                        parDelResult: false
                                    };
                                    
                                    if(Array.isArray( this.parameters.x)){
                						var xParameters = this.parameters.x;
                						for (
                    						var xParameterIndex = 0;
                    						xParameterIndex < xParameters.length;
                    						xParameterIndex++
                						) {
                    						var xparameter = xParameters[xParameterIndex];
                    						this._deleteParameterIfUsing(
                        						deletedParamId,
                        						xparameter,
                        						function(xParameterIndex) {
                                                	this.parameters.x.splice(
                                                    	xParameterIndex,
                                                    	1
                                                	);
                                            	}.bind(this),
                        						this.controls.xControl,
                                            	this.divs.xAxisDropZone,
                                            	parameterDeleted,
                                            	xParameterIndex
                    						);                    						
                						}               
            						}else{            					
                                    	this._deleteParameterIfUsing(
                                        	deletedParamId,
                                        	this.parameters.x,
                                        	function() {
                                            	this.setXParameter(null);
                                        	}.bind(this),
                                        	this.controls.xControl,
                                        	this.divs.xAxisDropZone,
                                        	parameterDeleted
                                    	);
                                    }

                                    var yParameters = this.parameters.y;

                                    for (
                                        var yParameterIndex = 0;
                                        yParameterIndex < yParameters.length;
                                        yParameterIndex++
                                    ) {
                                        var yparameter =
                                            yParameters[yParameterIndex];

                                        this._deleteParameterIfUsing(
                                            deletedParamId,
                                            yparameter,
                                            function(yParameterIndex) {
                                                this.parameters.y.splice(
                                                    yParameterIndex,
                                                    1
                                                );
                                            }.bind(this),
                                            this.controls.yControl,
                                            this.divs.yAxisDropZone,
                                            parameterDeleted,
                                            yParameterIndex
                                        );
                                    }

                                    if (
                                        typeof this.parameters.yline !==
                                        'undefined'
                                    ) {
                                        var yLineParameters = this.parameters.
                                            yline;

                                        for (
                                            var yLineParameterIndex = 0;
                                            yLineParameterIndex <
                                            yLineParameters.length;
                                            yLineParameterIndex++
                                        ) {
                                            var ylineparameter =
                                                yLineParameters[
                                                    yLineParameterIndex
                                                ];

                                            this._deleteParameterIfUsing(
                                                deletedParamId,
                                                ylineparameter,
                                                function(yLineParameterIndex) {
                                                    this.parameters.yline.splice(
                                                        yLineParameterIndex,
                                                        1
                                                    );
                                                }.bind(this),
                                                this.controls.yLineControl,
                                                this.divs.yAxisLineDropZone,
                                                parameterDeleted,
                                                yLineParameterIndex
                                            );
                                        }
                                    }

                                    this._deleteParameterIfUsing(
                                        deletedParamId,
                                        this.parameters.label,
                                        function() {
                                            this.parameters.label = null;
                                            if(this.chartParameters.label !== undefined){
                                            	delete this.chartParameters.label;
                                            }
                                        }.bind(this),
                                        this.controls.labelControl,
                                        this.divs.labelDropZone,
                                        parameterDeleted
                                    );
                                    this._deleteParameterIfUsing(
                                        deletedParamId,
                                        this.parameters.color,
                                        function() {
                                            this.setColorParameter(null);
                                            if(this.chartParameters.color !== undefined){
                                            	delete this.chartParameters.color;
                                            }
                                        }.bind(this),
                                        this.controls.colorControl,
                                        this.divs.colorDropZone,
                                        parameterDeleted
                                    );

                                    this._deleteParameterIfUsing(
                                        deletedParamId,
                                        this.parameters.colorline,
                                        function() {
                                            this.parameters.colorline = null;
                                        }.bind(this),
                                        this.controls.colorLineControl,
                                        this.divs.colorLineDropZone,
                                        parameterDeleted
                                    );
                                    this._deleteParameterIfUsing(
                                        deletedParamId,
                                        this.parameters.shape,
                                        function() {
                                            this.parameters.shape = null;
                                            if(this.chartParameters.shape !== undefined){
                                            	delete this.chartParameters.shape;
                                            }
                                        }.bind(this),
                                        this.controls.shapeControl,
                                        this.divs.shapeDropZone,
                                        parameterDeleted
                                    );
                                    this._deleteParameterIfUsing(
                                        deletedParamId,
                                        this.parameters.size,
                                        function() {
                                            this.parameters.size = null;
                                            if(this.chartParameters.size !== undefined){
                                            	delete this.chartParameters.size;
                                            }
                                        }.bind(this),
                                        this.controls.sizeControl,
                                        this.divs.sizeDropZone,
                                        parameterDeleted
                                    );

                                    this._deleteParameterIfUsingConstraint(
                                        deletedParamId,
                                        parameterDeleted
                                    );
                                    
                                    if( typeof this.parameterDeleteHandler === 'function'){
                                        	this.parameterDeleteHandler(deletedParamId, parameterDeleted);
                                     }
                                        
                                        
                                    if (
                                        parameterDeleted.parDelResult === true
                                    ) {
                                        updateChart = true;
                                        if( typeof this.resetCache === 'function'){
                                        	this.resetCache();
                                        }
                                    }
                                }
                            } else if (
                                event.eventSubType === 'filtersChanged' ||
                                event.eventSubType === 'datasetChanged'
                            ) {
                                updateChart = true;
                            }
                        }.bind(this)
                    );

                    if (updateConstraints === true) {
                        this.controls.constraintControl.updateController(
                            this.parameters.constraints
                        );
                        this.divs.constraintDropZone.updatePlaceholder();
                    }
                    if (updateXaxisDropzone) {
                        this.controls.xControl.updateController([
                            this.parameters.x
                        ]);
                        this.divs.xAxisDropZone.updatePlaceholder();
                    }

                    if (updateChart) {
                    	// when parameter is deleted, if we do not call hideDropzones then 
                    	// dropzones are not visible  IR-646099
                    	this.hideDropZones();
                    	
                        this.renderChart();
                    }
                    return;
                } else if(args.eventType === 'selection') { // check if chart wants to handle selection event
                    if(typeof this.handleSelectionEvent === 'function'){
                        this.handleSelectionEvent(args);
                    }
                }
                this.avsDropChart.propagateChartEvent(args, sources);
            }
        }
    };

    avsDropChartBasePrototype.initialize = function(configuration) {
        if (configuration) {
        	//Note: a lot of this is restore code. Not sure why we have 
            this.parameters = configuration.parameters;
            
            if(configuration.chartParameters !== undefined){
            	this.restoreChartParameters(configuration.chartParameters);
            }

            var parameterChanged = { parChgResult: false, parDelResult: false };

            var newParameterMap = configuration.latestParameters;
            var newConstrintMap = configuration.latestConstraints;

            if(Array.isArray( this.parameters.x)){
                var xParameters = this.parameters.x;
                for (
                    var xParameterIndex = 0;
                    xParameterIndex < xParameters.length;
                    xParameterIndex++
                ) {
                    var xparameter = xParameters[xParameterIndex];
                    this._updatreParameterIfChanged(
                        newParameterMap,
                        xparameter,
                        null,
                        null,
                        parameterChanged
                    );
                    if (parameterChanged.parDelResult === true) {
                        this.parameters.x.splice(xParameterIndex, 1);
                        --xParameterIndex; // we just removed 1
                        parameterChanged.parDelResult = false;
                    }
                }               
            }else{
                 this._updatreParameterIfChanged(
                    newParameterMap,
                    this.parameters.x,
                    null,
                    null,
                    parameterChanged
                );
                if (parameterChanged.parDelResult === true) {
                    this.parameters.x = null;
                    parameterChanged.parDelResult = false;
                }

                this.setXParameter(this.parameters.x);
            }
            
            
            
            var yParameters = this.parameters.y;

            for (
                var yParameterIndex = 0;
                yParameterIndex < yParameters.length;
                yParameterIndex++
            ) {
                var yparameter = yParameters[yParameterIndex];
                this._updatreParameterIfChanged(
                    newParameterMap,
                    yparameter,
                    null,
                    null,
                    parameterChanged
                );
                if (parameterChanged.parDelResult === true) {
                    this.parameters.y.splice(yParameterIndex, 1);
                    --yParameterIndex; // we just removed 1
                    parameterChanged.parDelResult = false;
                }
            }
            
            // this code is for updating chartparameter.y which will not work if 
            // y parameters are array, if y parameter is an array then we are not using chartparameters
            // but this.paramters, this should change but its safe for now TODO
           	this.setYParameter(this.parameters.y);
           
            

            if (typeof this.parameters.yline !== 'undefined') {
                var yLineParameters = this.parameters.yline;
                for (
                    var yLineParameterIndex = 0;
                    yLineParameterIndex < yLineParameters.length;
                    yLineParameterIndex++
                ) {
                    var ylineparameter = yLineParameters[yLineParameterIndex];
                    this._updatreParameterIfChanged(
                        newParameterMap,
                        ylineparameter,
                        null,
                        null,
                        parameterChanged
                    );
                    if (parameterChanged.parDelResult === true) {
                        this.parameters.y.splice(yLineParameterIndex, 1);
                        --yLineParameterIndex; // we just removed 1
                        parameterChanged.parDelResult = false;
                    }
                }
            }

            this._updatreParameterIfChanged(
                newParameterMap,
                this.parameters.label,
                null,
                null,
                parameterChanged
            );
            if (parameterChanged.parDelResult === true) {
                this.parameters.label = null;
                if(this.chartParameters.label !== undefined){
                    delete this.chartParameters.label;
				}
                parameterChanged.parDelResult = false;
            }
            
            this.setLabelParameter(this.parameters.label);
            
            if(this.parameters.color !== null){
                this._updatreParameterIfChanged(
                    newParameterMap,
                    this.parameters.color,
                    null,
                    null,
                    parameterChanged
                );
                if (parameterChanged.parDelResult === true) {
                    this.parameters.color = null;
                    if(this.chartParameters.color !== undefined){
                    	delete this.chartParameters.color;
					}
                    parameterChanged.parDelResult = false;
                }else{
                	var parColorMap = this.getColorMap(this.parameters.color);
                	this.setColorParameter(this.parameters.color, parColorMap);
                }
            }
            

            this._updatreParameterIfChanged(
                newParameterMap,
                this.parameters.colorline,
                null,
                null,
                parameterChanged
            );
            if (parameterChanged.parDelResult === true) {
                this.parameters.colorline = null;
                parameterChanged.parDelResult = false;
            }
            
           if (typeof this.parameters.shape !== 'undefined' &&
           this.parameters.shape !== null) {
              
            this._updatreParameterIfChanged(
                newParameterMap,
                this.parameters.shape,
                null,
                null,
                parameterChanged
            );
            if (parameterChanged.parDelResult === true) {
                this.parameters.shape = null;
                if(this.chartParameters.shape !== undefined){
                    delete this.chartParameters.shape;
				}
                parameterChanged.parDelResult = false;
            }else{            
            	this.setShapeParameter(this.parameters.shape, this.getShapeMap(this.parameters.shape));
            }
            
            }
            
            this._updatreParameterIfChanged(
                newParameterMap,
                this.parameters.size,
                null,
                null,
                parameterChanged
            );
            if (parameterChanged.parDelResult === true) {
                this.parameters.size = null;
                if(this.chartParameters.size !== undefined){
                    delete this.chartParameters.size;
				}
                parameterChanged.parDelResult = false;
            }
            
            this.setSizeParameter(this.parameters.size);

            if (
                typeof this.parameters.constraints !== 'undefined' &&
                this.parameters.constraints !== null
            ) {
                for (
                    var constraintIndex = 0;
                    constraintIndex < this.parameters.constraints.length;
                    constraintIndex++
                ) {
                    var constraint = this.parameters.constraints[
                        constraintIndex
                    ];
                    var constraintParameterId =
                        constraint.properties.parameterID[0];
                    if (
                        newParameterMap.get(constraintParameterId) === undefined
                    ) {
                        this.parameters.constraints.splice(constraintIndex, 1);
                        --constraintIndex; // we just removed one must account for
                        // it
                    } else {
                        // wish we could use constraintMap lookup but it uses
                        // constraintid which keep chjanging, we will have to loop
                        // over all constraint to match the bound values
                        for (var newConstraintKey in newConstrintMap) {
                            var newConstraint =
                                newConstrintMap[newConstraintKey];
                            if (
                                (newConstraint.parameterID[0] ===
                                    constraintParameterId)
                                 && 
                                (constraint.properties.type ===
                                     newConstraint.type)
                            ) {
                                constraint.properties.boundValue =
                                    newConstraint.boundValue;
                                constraint.properties.sourceParameterName =
                                    newConstraint.sourceParameterName;
                                constraint.name = newConstraint.name;
                                break;
                            }
                        }
                    }
                }
                this.setConstraint(this.parameters.constraints);
            }
        } else {
            this.parameters = {
                x: this.getXAxisDefaultParameter(),
                y: [],
                yline: [],
                color: null,
                size: null,
                label: null,
                constraints: null
            };
        }

        this.requestObject = null;
        this.avsDropChart = null;
        
        // make sure that the zoom is configured
        this.initializeZoom();
    };
    
    avsDropChartBasePrototype.getXAxisDefaultParameter = function() {
        return null;
    };

    avsDropChartBasePrototype.getConfiguration = function() {
    	var that = this;
    	
        var configuration = {};
        configuration.parameters = this.parameters;
        //configuration.chartParameters = this.chartParameters;
        configuration.chartParameters = {};
        
        Object.keys(this.chartParameters).forEach(function(paramKey){
        	var param = that.chartParameters[paramKey];
        	
        	if(param.type === 'chartParameter'){
        		configuration.chartParameters[paramKey] = {
            		type : 'chartParameter',
            		label : param.label,
            		templateName : param.templateName,
            		updateJSON : param.getUpdateJSON()
            	};
        	} else if(param.type === 'arrayParameter'){
        		configuration.chartParameters[paramKey] = {
        			type : 'arrayParameter',
        			label : param.label,
        			entries : []
        		};
        		
        		var arrayParams = param.getParameters();
        		Object.keys(arrayParams).forEach(function(arrayParamKey){
        			var arrayParam = arrayParams[arrayParamKey];
        			
        			configuration.chartParameters[paramKey].entries.push({
        				type : arrayParam.type,
        				templateName : arrayParam.templateName,
        				updateJSON : arrayParam.getUpdateJSON()
        			});
        		});
        		
        		//TODO: Check and see how this works for the y-parameters on the line (and bar?) chart.
        		//Possible additional work needed: if we need to support attributes/settings directly
        		//on the array chart, we should create array charts that have a template for storing those
        		//attributes, in addition to the array of chart parameters currently present.
        		
        		//We'll then need to save/restore templateName and updateJSON for the array parameter in
        		//the same way we do for regular chart parameter settings/attributes/attribute objects.
        		
        		//If none of that makes sense, tell Carlin that array parameters are broken and he'll fix it.
        	}
        });
        
        /*if(this.overlayLegend !== null){
        var colorLegend = {
            'dockable' : this.overlayLegend.getAttribute('dockable'),
            'height' : this.overlayLegend.getAttribute('height'),
            'width' : this.overlayLegend.getAttribute('width'),
            'position' : this.overlayLegend.getAttribute('position'),
            'dockDirection' : this.overlayLegend.getAttribute('dockDirection'),
            'element-draggable' :
    this.overlayLegend.getAttribute('element-draggable')
        };
        configuration.colorLegend = colorLegend;
    }*/
        configuration.height = this.requestObject.chartRequest.height;
        configuration.width = this.requestObject.chartRequest.width;
        configuration.datasetId = this.requestObject.datasetId;
        
        //Save information about the dock positions of the legends
        configuration.legendData = this.legendData;
        
        
        
        Object.keys(this.legendData).forEach(function(key){
            var legend = this.legendElements[key];
            configuration.legendData[key].legendOptions = legend.getOverlayAttributes();
        }.bind(this));
        
        var dockedLegends = {};
        Object.keys(this.dockedLegends).forEach(function(legendId){
            var legend = this.dockedLegends[legendId];
            var dockDirection = legend.getAttribute('dockDirection') || legend.dockDirection;
            dockedLegends[legendId] = {
                dockDirection : dockDirection
            };
            configuration.legendData[legendId].legendOptions.dockDirection = dockDirection;
        }.bind(this));
        
        configuration.dockedLegends = dockedLegends;
        
        if(this.getChartSettings !== undefined){
            configuration.chartSettings = this.getChartSettings();
        }
        
        return configuration;
        
    };

    avsDropChartBasePrototype.restore = function(configuration) {
        // TODO: We need to set this up to work with multiple legends.

        // this.renderControlPanel();
        // this.updateRequest();
        /*if (configuration.colorLegend) {
            // this.setupLegend(configuration.colorLegend);
            // this.resizeDropZonesWLegend(this.overlayLegend);
            this.addLegend('color');
        }*/
        
        //Restore all legends. This should do the following:
        //1: Get legend data, including the dock positions of all legends
        //2: Generate legends that match the old ones
        //3: Add all docked legend elements to the docked legends object before updating
        //   positions
        var legendData = configuration.legendData;
        var dockedLegendIds = configuration.dockedLegendIds;
        Object.keys(legendData).forEach(function(key){
           var legendOptions = legendData[key].legendOptions;
           var legendId = key;
           var newLegend = this.addLegend(legendId, legendOptions);
           if(newLegend.getAttribute('position') === 'dock'){
               this.dockedLegends[legendId] = newLegend;
           }
        }.bind(this));
        
        if(configuration.chartSettings !== undefined && this.restoreChartSettings !== undefined) {
            this.restoreChartSettings(configuration.chartSettings);
        }
        
        /*if(configuration.chartParameters !== undefined){
        	this.restoreChartParameters(configuration.chartParameters);
        }*/
        
        this.updateLegendPositions();
        
        this.renderChart(configuration);
    };
    
    avsDropChartBasePrototype.restoreChartParameters = function(parametersJson){
    	var that = this;
    	
    	Object.keys(parametersJson).forEach(function(key){
    		var paramJson = parametersJson[key];
    		var newChartParam;
    		
    		if(paramJson.type === 'chartParameter'){
    			newChartParam = chartLibrary.parameterTemplates[paramJson.templateName].create(paramJson.label);
    			newChartParam.update(paramJson.updateJSON);
    		}
    		//TODO: We need to add code to restore array parameters.
    		
    		that.chartParameters[key] = newChartParam;
    	});
    };

    avsDropChartBasePrototype.placeholderFilter = function() {
        return !this.validateRender();
    };

    avsDropChartBasePrototype.addXAxis = function() {
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
        this.divs.xAxisDropZone.setParameterListener(this.divs.setXParameter);
        this.divs.xAxisDropZone.showPlaceholder();

        this.divs.xAxisDropZone.setPlaceholderText(function() {
            if (
                typeof that.parameters.x !== 'undefined' &&
                that.parameters.x !== null
            ) {
                return String(
                    decodeURIComponent(
                        that.parameters.x.displayName || that.parameters.x.name
                    )
                );
            } else {
                return that.getDefaultXAxisLabel();
            }
        });
        this.divs.xAxisDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateXData);
        paramHandler.setDropListener(
            function(param) {
                // add x-axis parameter source as the dataset id
                this.requestObject.datasetId = param.source;
                this.setXParameter(param.properties);
                this.controls.xControl.updateController([this.parameters.x]);
                this.handleRefreshAfterDrop();
            }.bind(this)
        );

        this.divs.xAxisDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.xAxisDropZone);
    };

    avsDropChartBasePrototype.addYAxis = function() {
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
                return that.getDefaultYAxisLabel();
            } else {
                var text = '';
                for (var i = 0; i < that.parameters.y.length; i++) {
                    if (i !== 0) {
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
                
        	if( that.requestObject.datasetId === undefined){
				that.requestObject.datasetId = param.source;
			}
			
            that.addYParameter(param.properties);
            that.controls.yControl.updateController(that.parameters.y);
            that.handleRefreshAfterDrop();
        });

        this.divs.yAxisDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.yAxisDropZone);
    };
    avsDropChartBasePrototype.removeYAxis = function() {
        this.divs.root.removeChild(this.divs.yAxisDropZone);
        this.divs.yAxisDropZone = null;
    };

    avsDropChartBasePrototype.addYLineAxis = function() {
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
                return NLSUtils.translate('Y Secondary Axis');
            } else {
                var text = '';
                for (var i = 0; i < that.parameters.yline.length; i++) {
                    if (i != 0) {
                        text += ',';
                    }
                    text += decodeURIComponent(
                    that.parameters.yline[i].name);
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
    
    avsDropChartBasePrototype.validateYLineData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };
    
    avsDropChartBasePrototype.addColorDropZone = function() {
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

    avsDropChartBasePrototype.onColorDrop = function(param) {
            
        if (param) {        
            var targetColorMap = this.getColorMap(param);           
            this.setColorMap(param, targetColorMap);
            
        } else {
            this.setColorParameter(null, null);
            this.handleRefreshAfterDrop();
        }
    };

    avsDropChartBasePrototype.getColorMap = function(param) {
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
                    
                    // propagate colorMap change event
                    this.propagateChartEvent({
                        eventType: 'paramMapUpdate',
                        paramId: param.id,
                        colorMap: targetColorMap
                    });
                    
                } else {
                    targetColorMap = existingDiscreteParamColorMap;
                }
            }
        }
        return targetColorMap;
    };

    avsDropChartBasePrototype.setColorMap = function(param, colorMap) {
    
        this.controls.colorControl.updateController(
                [param],
                colorMap
            );
        
        if(colorMap === null){
            colorMap = this.controls.colorControl.getDataMap();
        }
        this.setColorParameter(param, colorMap);
        
        this.handleRefreshAfterDrop();
    };

    avsDropChartBasePrototype.addSizeDropZone = function() {
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
        this.divs.sizeDropZone.setParameterListener(this.setSizeParameter);
        this.divs.sizeDropZone.showPlaceholder();
        this.divs.sizeDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        this.divs.sizeDropZone.setPlaceholderText(function() {
            if (
                typeof that.parameters.size !== 'undefined' &&
                that.parameters.size !== null
            ) {
                return String(
                    decodeURIComponent(
                        that.parameters.size.displayName ||
                            that.parameters.size.name
                    )
                );
            } else {
                return NLSUtils.translate('Size');
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateSizeData);
        paramHandler.setDropListener(function(param) {
            that.setSizeParameter(param.properties);
            //Update size controller (handles display in control panel.)
            that.controls.sizeControl.updateController([that.parameters.size]);
            
            //Update chart parameter
            that.handleRefreshAfterDrop();
        });

        this.divs.sizeDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.sizeDropZone);
    };

    avsDropChartBasePrototype.handleRefreshAfterDrop = function() {
        this.hideDropZones();
        this.renderChart();        
    };

    avsDropChartBasePrototype.addLabelDropZone = function() {
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
            that.setLabelParameter(param.properties);
            that.controls.labelControl.updateController([
                that.parameters.label
            ]);
            that.handleRefreshAfterDrop();
        });

        this.divs.labelDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.labelDropZone);
    };

    avsDropChartBasePrototype.addConstraintDropZone = function() {
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
        this.divs.constraintDropZone.setParameterListener(function(constraint) {
            that.divs.setConstraint(constraint);
        });
        this.divs.constraintDropZone.showPlaceholder();
        this.divs.constraintDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );
        this.divs.constraintDropZone.setFilter(this.validateConstraintData);

        this.divs.constraintDropZone.setPlaceholderText(function() {
            if (
                typeof that.parameters.constraints !== 'undefined' &&
                that.parameters.constraints !== null &&
                that.parameters.constraints.length !== 0
            ) {
                var name = '';
                for (
                    var idx = 0;
                    idx < that.parameters.constraints.length;
                    idx++
                ) {
                    name += decodeURIComponent(that.parameters.constraints[idx].name)
                         + ', ';
                }
                return name.substring(0, name.lastIndexOf(','));
            } else {
                return NLSUtils.translate('Requirements');
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateConstraintData);
        paramHandler.setDropListener(function(constraint) {
            constraint.properties.name = constraint.name; // add name as property so that it shows up in
            // the control panel and drop zone
            constraint = constraint.properties;
            that.setConstraint(constraint);
            that.controls.constraintControl.updateController(
                that.parameters.constraints
            );
            that.handleRefreshAfterDrop();
        });

        this.divs.constraintDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.constraintDropZone);
    };

    avsDropChartBasePrototype.addChart = function() {        
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

    avsDropChartBasePrototype.validateXData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };

    avsDropChartBasePrototype.validateYData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };

    avsDropChartBasePrototype.validateColorData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };

    avsDropChartBasePrototype.validateSizeData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        // and not discrete
        if (
            typeof data !== 'undefined' &&
            data.properties.dataType === 'STRING'
        ) {
            console.log('size parameter cannot be discrete');
            return false;
        }
        return true;
    };

    avsDropChartBasePrototype.validateLabelData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };

    avsDropChartBasePrototype.validateConstraintData = function(data) {
        // check that datum is a constraint
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.CONSTRAINT
        ) {
            return false;
        }
        return true;
    };

    avsDropChartBasePrototype.setXParameter = function(parameter) {
        this.parameters.x = parameter;

        // if x ix not null, then we're resetting the x parameter
        if (this.parameters.x !== null) {
            var attributes = {
                data: { guid: parameter.id },
                axisProperties: {
                    title: { text: decodeURIComponent(parameter.displayName) }
                }
            };
            this.chartParameters.x = this.getXParameter(parameter, attributes);
            this.chartParameters.x.update(attributes);
        } else if (typeof this.chartParameters.x !== 'undefined') {
            // x was null and it was previously set, so delete the previous x
            // reference
            delete this.chartParameters.x;
        }

        this.divs.xAxisDropZone.updatePlaceholder();

        this.updateStylePanel();
    };
    
    avsDropChartBasePrototype.setYParameter = function(parameter) {
        this.parameters.y = parameter;

        // if y ix not null, then we're resetting the y parameter
        if (this.parameters.y !== null && this.parameters.y.length !== 0) {
        
        	if(typeof this.getYParameter === 'function'){
            	var attributes = {
                	data: { guid: parameter[0].id },
                	axisProperties: {
                    	title: { text: decodeURIComponent(parameter[0].displayName) }
                	}
            	};
            	this.chartParameters.y = this.getYParameter(parameter, attributes);
            	this.chartParameters.y.update(attributes);
            }
        } else if (typeof this.chartParameters.y !== 'undefined') {
            // y was null and it was previously set, so delete the previous y
            // reference
            delete this.chartParameters.y;
        }

        this.divs.yAxisDropZone.updatePlaceholder();

        this.updateStylePanel();
    };
    
    avsDropChartBasePrototype.setConstraintParameter = function(parameters) {
        this.parameters.constraints = [parameters];

        // if x ix not null, then we're resetting the x parameter
        if (this.parameters.constraints !== null) {
            //var attributes = {};
            this.chartParameters.constraints = this.getConstraintParameters(parameter, attributes);
            //this.chartParameters.x.update(attributes);
        } else if (typeof this.chartParameters.constraints !== 'undefined') {
            // x was null and it was previously set, so delete the previous x
            // reference
            delete this.chartParameters.x;
        }

        this.divs.constraintDropZone.updatePlaceholder();

        this.updateStylePanel();
    };
    
    avsDropChartBasePrototype.addConstraintParameter = function(constraint){
    	if(!this.chartParameters.constraints){
    		this.chartParameters.constraints = new GLOBAL.DS.RAConstructors.ArrayChartParameter('Constraints');
    	}
    	
    	var constraintParam = chartLibrary.parameterTemplates.constraint.create(constraint.name);
		
		var constraintAttributes = {
			type : constraint.properties.type,
			parameterId : constraint.properties.parameterID[0],
			guid : constraint.id
		};
		
		constraintParam.update(constraintAttributes);
		
		this.chartParameters.constraints.addArrayParameter(constraintParam);
    };
    
    avsDropChartBasePrototype.getConstraintParameter = function(constraints, attributes){
    	var constraintsParameter = new GLOBAL.DS.RAConstructors.ArrayChartParameter('Constraints');
    	
    	constraints.forEach(function(constraint){
    		
    		var constraint = chartLibrary.parameterTemplates.constraint.create(constraint.name);
    		
    		var constraintAttributes = attributes[constraint.id] || {
    			type : constraint.type,
    			parameterId : constraint.id,
    		};
    		
    		constraint.update(constraintArrtibutes);
    		
    		constraintsParameter.addArrayParameter(constraint);
    	});
    	
    	return constraintsParameter;
    };

    avsDropChartBasePrototype.getXParameter = function(parameter, attributes) {
        var chartParam;

        if (parameter.dataType === 'STRING') {
            chartParam = chartLibrary.parameterTemplates.discreteSpatial.create(
                'X'
            );
            attributes.discreteValues = parameter.discreteValues;
        } else {
            chartParam = chartLibrary.parameterTemplates.binnedNumericSpatial.create(
                'X'
            );
        }

        return chartParam;
    };

    avsDropChartBasePrototype.updateRequestObject = function() {
        var key, i, parameter;
        var guidsMap = {};

        this.requestObject = this.requestObject || {};
        this.requestObject.data = this.requestObject.data || {};
        this.requestObject.data.raw = this.requestObject.data.raw || [];
        this.requestObject.legends = this.requestObject.legends || [];

        // Update raw params.
        // To build the raw params array, we assign each guid as a key on a map.
        // This ensures that each  key only appears once.

        // Note: once we eliminate the old code for doing this, we can directly
        // assign the raw params  array insead of copying the old version of it to the
        // guidsMap object.
        for (var i = 0; i < this.requestObject.data.raw.length; i++) {
            guidsMap[this.requestObject.data.raw[i]] = true;
        }

        for (key in this.chartParameters) {
            parameter = this.chartParameters[key];
            parameter.getGuids().forEach(function(guid){
            	guidsMap[guid] = true;
            });

            // TODO: Generalize legends.
            // if(parameter.attributes.legend &&
            // parameter.checkToggle(parameter.attributes.legend)){

            //}
        }

        this.requestObject.data.raw = Object.keys(guidsMap);

        // Update request object with chart data.
        // This coulde be combined with the above for loop if necessary. It's
        // separate for now for  purely organizational purposes.
        for (key in this.chartParameters) {
            this.requestObject.chartRequest.charts[0][
                key
            ] = this.chartParameters[key].getRequestJSON();
        }

        // Update data maps;
        if (typeof this.requestObject.dataMaps === 'undefined') {
            this.requestObject.dataMaps = {
                colorMaps: [],
                shapeMaps: [],
                sizeMaps: []
            };
        }
        
        //TODO: Come up with a nice way to do this.
        this.requestObject.dataMaps.sizeMaps = 
        	GLOBAL.DS.RAObjects.dataMaps.sizeMaps || {};

        this.requestObject.dataMaps.colorMaps =
            GLOBAL.DS.RAObjects.dataMaps.linearColorMaps || [];
        
        //First attempt at making this a bit more specific to what we're using. Is there a good way to generalize this process?
        var allShapeMaps;
        if(GLOBAL.DS.RAObjects.dataMaps.discreteShapeMaps && GLOBAL.DS.RAObjects.dataMaps.binnedShapeMaps){
        	allShapeMaps = GLOBAL.DS.RAObjects.dataMaps.discreteShapeMaps.concat(GLOBAL.DS.RAObjects.dataMaps.binnedShapeMaps);
        } else {
        	allShapeMaps = GLOBAL.DS.RAObjects.dataMaps.discreteShapeMaps ? GLOBAL.DS.RAObjects.dataMaps.discreteShapeMaps :
        		(GLOBAL.DS.RAObjects.dataMaps.binnedShapeMaps ? GLOBAL.DS.RAObjects.dataMaps.binnedShapeMaps : {});
        }
        
        var usedShapeMapId;
        if(this.chartParameters.shape){
        	usedShapeMapId = this.chartParameters.shape.attributes.dataMap.value;
        }
        
        this.requestObject.dataMaps.shapeMaps = allShapeMaps.filter(function(shapeMap){
        	return shapeMap.guid === usedShapeMapId;
        });
    };

    avsDropChartBasePrototype.addYParameter = function(parameter) {
        var that = this;
        
        if(this.supportColorYParamElement()){
            parameter.seriesColor = this.getSeriesColorForParameter(parameter.id);
        }
        
        if (that.divs.yAxisDropZone) {
            if (
                that.parameters.y.length <
                that.controls.yControl.getNParameters()
            ) {
                that.parameters.y.push(parameter);
            } else {
                // Replace last parameter
                that.parameters.y.splice(-1, 1, parameter);
            }
            
            if(typeof that.getYParameter === 'function'){
            	var attributes = {
                    data: { guid: parameter.id },
                    axisProperties: {
                        title: { text: decodeURIComponent(parameter.displayName) }
                    }
                };
            	that.chartParameters.y = that.getYParameter(parameter, attributes);
            	that.updateStylePanel();
            }
            
            
            that.divs.yAxisDropZone.updatePlaceholder();
        }
    };


    avsDropChartBasePrototype.setYParameters = function(parameters) {
        if (this.divs.yAxisDropZone) {
            this.parameters.y = parameters;
            this.divs.yAxisDropZone.updatePlaceholder();
        }
    };
    
    avsDropChartBasePrototype.getDefaultYAxisLabel = function() {
        return NLSUtils.translate('Y Axis');
    };
    
    avsDropChartBasePrototype.getDefaultXAxisLabel = function() {
        return NLSUtils.translate('X Axis');
    };
    

    avsDropChartBasePrototype.addYLineParameter = function(parameter) {
        var that = this;
        
        if(this.supportColorYParamElement()){
            parameter.seriesColor = this.getSeriesColorForParameter(parameter.id);
        }
        
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

    avsDropChartBasePrototype.setYLineParameters = function(parameters) {
        var that = this;
        that.parameters.yline = parameters;
        that.divs.yAxisLineDropZone.updatePlaceholder();
    };
    
    avsDropChartBasePrototype.setLegend = function(key, data) {
        this.legendData[key] = data;
        if (typeof this.legendElements[key] === 'undefined') {
            this.addLegend(key, data);
        }
    };

    avsDropChartBasePrototype.setColorParameter = function(
        parameter,
        colorMap
    ) {

        this.parameters.color = parameter;

        if (this.parameters.color !== null) {
            var attributes = { data: { guid: parameter.id }, type: 'byData' };
            if (colorMap !== undefined && colorMap !== null) {
                attributes.dataMap = colorMap.guid;
            }

            this.chartParameters.color = this.getColorParameter(
                parameter,
                attributes
            );
            // this.chartParameters.color.update(attributes);
        } else {
            this.removeParameter('color');
        }
        

        this.updateStylePanel();
        this.divs.colorDropZone.updatePlaceholder();
    };

    avsDropChartBasePrototype.getColorParameter = function(
        parameter,
        attributes
    ) {
        // Note: this is probably not the method you're looking for. Most charts
        // define their own parameter  getters, so look in the chart file (i.e.
        // ra-avsscattergrid.js)

        var chartParam = chartLibrary.parameterTemplates.color.create('Color');
        chartParam.update(attributes);

        return chartParam;
    };

    avsDropChartBasePrototype.removeParameter = function(paramName) {
        delete this.chartParameters[paramName];
        this.parameters[paramName] = null;

        if (this.requestObject) {
        }
    };

    avsDropChartBasePrototype.setSizeParameter = function(parameter) {
    	
    	if(typeof parameter !== 'undefined' && parameter !== null){
    		var sizeChartParam = chartLibrary.parameterTemplates.size.create('Size', {
    			data : {
    				'guid' : parameter.id
    			}
    		});
    		this.chartParameters.size = sizeChartParam;
    		this.parameters.size = parameter;
    	} else {
    		delete this.chartParameters.size;
    		delete this.parameters.size;
    	}
    	
    	this.updateStylePanel();
        this.divs.sizeDropZone.updatePlaceholder();        
        
    };

    avsDropChartBasePrototype.setLabelParameter = function(parameter) {
    	
    	if(typeof parameter !== 'undefined' && parameter !== null){
    		var labelChartParam = chartLibrary.parameterTemplates.label.create('Label', {
    			data: {
    				'guid' : parameter.id
    			}
    		});
    		this.chartParameters.label = labelChartParam;
    		this.parameters.label = parameter;
    	} else {
    		delete this.chartParameters.label;
    		this.parameters.label = null;
    	}
    	
    	this.updateStylePanel();
        this.divs.labelDropZone.updatePlaceholder();
        
    };

    avsDropChartBasePrototype.setConstraint = function(constraint) {
        if (constraint.constructor === Array) {
            // The control panel sends the constraints as an array:
            this.parameters.constraints = constraint;
            
            // this is a callback from control panel and it sends the 
            // all remaining constraints when some constraint is deleted
            // so we need to delete all old consrtraints
            if(this.chartParameters.constraints){
                delete this.chartParameters.constraints;
            }
            for(var i = 0; i < constraint.length; i++){
            	this.addConstraintParameter(constraint[i]);
            }
        } else {
            if (!this.parameters.constraints) {
                this.parameters.constraints = [];
            }
            this.parameters.constraints.push(constraint);
            this.addConstraintParameter(constraint);
        }
        
        this.divs.constraintDropZone.updatePlaceholder();
        this.updateStylePanel();
    };

    avsDropChartBasePrototype.removeLegend = function(legendId) {};

    avsDropChartBasePrototype.addLegend = function(legendId, legend) {
        var that = this;

        // Use legend defaults if there aren't any legend arguments.
        legend = legend || {
            dockable: 'true',
            height: 100, // that.legendData[legendId].height,
            width: 300, // that.legendData[legendId].width,
            position: 'center',
            'element-draggable': 'true',
            hideFrame: 'true'
        };

        var overlayLegend = this.getOverlayElement(legend);
        
        overlayLegend.setDraggable();

        // Random string ID. Has a period in it.
        // var legendId = Math.random() + '';
        overlayLegend.legendId = legendId;

        // With multiple legends, it's probably best to handle all legends in the
        // chart rather than in the char base. Under this paradigm, the base doesn't
        // need to maintain a pointer to the legends, and shouldn't do so since that
        // would require keeping that list synchronized to the list on the chart.
        // this.overlayLegends.push(overlayLegend);

        overlayLegend.addCallback('dock', function() {
            that.onLegendDock(this);
        });

        overlayLegend.addCallback('undock', function(e) {
            that.onLegendUndock(this, e);
        });

        overlayLegend.setDockHeight(function() {
            return 80;
        });
        overlayLegend.setDockWidth(function() {
            return 150;
        });
        
        var imagesDiv = document.createElement('div');
        imagesDiv.classList.add('images');           

        overlayLegend.querySelector('.content').appendChild(imagesDiv);
        
        this.legendElements[legendId] = overlayLegend;
        
        if(overlayLegend.getAttribute('position') === 'dock'){
            overlayLegend.updateDockPosition();
        }

        return overlayLegend;
    };

    /*avsDropChartBasePrototype.setupLegend = function(legend){
    var that = this;

    this.overlayLegend = this.getOverlayElement(legend);

    this.overlayLegend.addCallback('dock', function(){
        that.onLegendDock(this);
    });

    this.overlayLegend.addCallback('undock', function(){
        that.onLegendUndock(this);
    });

    //QW8: These methods for setting dock height/width are functionally the
same.
    //I've used both here to demonstrate how they're used, in case they need to
    //be modified in the future to be mroe intelligent.
    this.overlayLegend.setDockHeight(80);
    this.overlayLegend.setDockWidth(function(){
        return 150;
    });

    var imagesDiv = document.createElement('div');
    imagesDiv.classList.add('images');

    this.overlayLegend.querySelector('.content').appendChild(imagesDiv);
};*/

    avsDropChartBasePrototype.getDefaultLegend = function(width, height) {
        var legend = {
            dockable: 'true',
            height: height,
            width: width,
            position: 'center',
            'element-draggable': 'true'
        };
        return legend;
    };

    avsDropChartBasePrototype.onLegendDock = function(legend) {
        if (typeof this.dockedLegends[legend.legendId] !== 'undefined') {
            // This shouldn't happen. Let's make it obvious when it does!
            console.log(
                'WARNING! DUPLICATE LEGEND TYPE! SOMETHING IS PROBABLY BROKEN!'
            );
            console.log(
                'WARNING! DUPLICATE LEGEND TYPE! SOMETHING IS PROBABLY BROKEN!'
            );
            console.log(
                'WARNING! DUPLICATE LEGEND TYPE! SOMETHING IS PROBABLY BROKEN!'
            );
        }

        this.dockedLegends[legend.legendId] = legend;
        this.updateLegendPositions();
        // this.updateDockDirection(legend);
        // this.resizeDropZonesWLegend(legend);
        this.renderChart();
    };

    avsDropChartBasePrototype.updateLegendPositions = function() {
        var topHeight = 0,
            leftWidth = 0,
            rightWidth = 0,
            bottomHeight = 0;

        var legend, dir, top, left, right, bottom;
        for (var key in this.dockedLegends) {
            // Position all legends
            /*
         * We need to update all positions, since this needs to be able removing
         * a legend, wich could change the positions of everything else. There
         * may be a slightly more efficient way to do this, but it likely would
         * be significantly more complex for minimal benefit.
         * #MicroOptimizations
         */
            legend = this.dockedLegends[key];
            dir = legend.getAttribute('dockDirection');

            top = Number(topHeight) + 'px';
            bottom = Number(bottomHeight) + 'px';
            left = Number(leftWidth) + 'px';
            right = Number(rightWidth) + 'px';

            if (dir === 'top') {
                bottom = '';
                topHeight += legend.offsetHeight;
            } else if (dir === 'bottom') {
                top = '';
                bottomHeight += legend.offsetHeight;
            } else if (dir === 'left') {
                right = '';
                leftWidth += legend.offsetWidth;
            } else if (dir === 'right') {
                left = '';
                rightWidth += legend.offsetWidth;
            }

            legend.style.top = top;
            legend.style.bottom = bottom;
            legend.style.right = right;
            legend.style.left = left;
        }

        // Resize drop zone
        d3.select(this.divs.root).style({
            top: topHeight + 'px',
            bottom: bottomHeight + 'px',
            left: leftWidth + 'px',
            right: rightWidth + 'px'
        });

        // Add padding to drop zones based on legends
        /*d3.select(this).select('.content').style({
        top : topHeight === 0 ? '3px' : '0px',
        bottom : bottomHeight === 0 ? '3px' : '0px',
        left : leftWidth === 0 ? '3px' : '0px',
        right : rightWidth === 0 ? '3px' : '0px'
    });*/
    };

    avsDropChartBasePrototype.getLegendRequest = function() {
        // For each legend, the key for the legend (based on the request) should be
        // "legend" + legendData.guid
        // This is the same as 'type' in the data from the server. These should
        // match up.
        // Alternately, we can render only based on what comes back from the server.
        // In this case,  we don't need to create keys based on the request data, only
        // on the data from the server.
        // This is probably a better approach.
        // Legend data seems to be handled by the controls? This seems like kind of
        // a bad idea, but  it's what the AVS guys implemented. Color control is in
        // this file, but is probably unused.
    };

    avsDropChartBasePrototype.renderLegends = function(data, chart, uniqueKey) {
        // We need to render legends here since a single chart base can potentially
        // have multiple  charts which share legends.

        var that = this;

        this.legendData = {};
        for (var i = 0; i < data.legendTiles.length; i++) {
            this.legendData[data.legendTiles[i].type] = data.legendTiles[i];
        }

        if (!this.legendData) {
            return;
        }

        var removeLegendsMap = {};
        Object.keys(this.legendElements).forEach(function(key) {
            if(key !== 'statistics'){
                removeLegendsMap[key] = true;
            }
        });

        Object.keys(this.legendData).forEach(function(legendKey) {
            if (typeof that.legendElements[legendKey] === 'undefined') {
                that.addLegend(legendKey);
            }

            // update all current tiles
            var legendTiles = d3.
                select(that.legendElements[legendKey].querySelector('.images')).
                selectAll('.tile').
                data([that.legendData[legendKey]]);

            // insert new tiles
            legendTiles.
                enter().
                append('img').
                classed('tile', true).
                style({ position: 'absolute', left: 0, top: 0 }).
                style('left', 0).
                style('top', 0);

            // Note: I added the height and width settings to this block in case the
            // height/width  for a specific legend change between server calls.
            legendTiles.
                attr('width', function(d) {
                    return d.width;
                }).
                attr('height', function(d) {
                    return d.height;
                }).
                each(function(d) {
                    var tile = this;

                    var callback = function(url) {
                        d3.select(tile).attr('src', url);
                    };

                    that.dataProvider.getResourceAsUrl(
                        'renderAVSChart',
                        d.id,
                        callback,
                        chart,
                        uniqueKey
                    );
                });

            // make sure this "updated" legend isn't removed
            delete removeLegendsMap[legendKey];
        });

        var updateLegendPositions = false;
        // Remove old legends
        Object.keys(removeLegendsMap).
            filter(function(d) {
                return removeLegendsMap[d];
            }).
            forEach(function(key) {
                var removeElement = that.legendElements[key];
                
                if (removeElement) {
                    removeElement.close();
                    delete that.legendElements[key];
                }
                var dockedLegend = that.dockedLegends[key];
                // undock the legend, if any were undocked during this loop, we'll fire the update
                updateLegendPositions = that.undockLegend(dockedLegend) || updateLegendPositions;
            });
        
        if(updateLegendPositions){
            // update the legend positions and re-render
            this.updateLegendPositions();
            this.renderChart(); 
        }
    };

    avsDropChartBasePrototype.renderstatsLegend = function(data) {
    
        var statKey = 'statistics';
        
        if(this.showStatistics === true){        
            
            var that = this;
            if (data.statistics && data.statistics[0]) {
                if (!that.legendElements[statKey]) {
                    that.addLegend(statKey);                    
                }
                
                if( !that.legendData.hasOwnProperty(statKey)){
                    that.legendData[statKey] = {};
                    that.legendData[statKey].legendOptions = that.legendElements[statKey].getOverlayAttributes();
                    
                }                    
                    
                var legendTile = that.legendElements[statKey].querySelector(
                    '.images'
                );

                var str = '<table style="width:100%;height:100%">';
                data.statistics[0].forEach(function(stat) {
                    str =
                        str +
                        '<tr><td>' +
                        NLSUtils.translate(stat.statistic) +
                        '</td><td>' +
                        Number((stat.value).toFixed(4)) +
                        '</td></tr>';
                });
                str = str + '</table>';
                legendTile.innerHTML = str;
            }
        }else{
             var removeElement = this.legendElements[statKey];
                
             if (removeElement) {
                removeElement.close();
                delete this.legendElements[statKey];
             }
             
             if(this.dockedLegends[statKey]){
                delete this.dockedLegends[statKey];
                this.updateLegendPositions();
                this.renderChart(); 
             }   
        }
        
    
    };
    
    avsDropChartBasePrototype.onLegendUndock = function(legend) {
        var legendUndocked = this.undockLegend(legend);

        // Update sizing based on removed legend. Reposition other legends
        // appropriately.
        if(legendUndocked){
            this.updateLegendPositions();
        }

        this.renderChart();
    };
    
    avsDropChartBasePrototype.undockLegend = function(legend){
        if(legend !== undefined && this.dockedLegends && this.dockedLegends[legend.legendId]){
            // Remove docked legend from docked legends map
            delete this.dockedLegends[legend.legendId];
            return true;
        }
        return false;
    };

    avsDropChartBasePrototype.updateRequestLegends = function() {
        // Updates sizing for the legends in the request object.
        // This is implemented here since most charts override updateRequest

        var request, el, content, dir;

        if (
            this.requestObject &&
            this.requestObject.chartRequest &&
            this.requestObject.chartRequest.legends
        ) {
            for (
                var i = 0;
                i < this.requestObject.chartRequest.legends.length;
                i++
            ) {
                request = this.requestObject.chartRequest.legends[i];
                el = this.legendElements['legend' + request.guid];
                if (el) {
                    // If there exists an element for this legend, update its
                    // height/width to match the rendered  size of the contents of
                    // that element.
                    content = el.querySelector('.content');
                    request.width = content.offsetWidth;
                    request.height = content.offsetHeight;
                    dir = el.getAttribute('dockdirection');
                    if (dir === 'left' || dir === 'right') {
                        request.orientation = 'vertical';
                    } else {
                        request.orientation = 'horizontal';
                    }
                }
            }
        }
    };

    avsDropChartBasePrototype.validateRender = function() {
        var chartType = this.chartProperties.defaults[0].type;
        var chartLayout = this.chartProperties.defaults[0].layout;
        if (chartType === 'scatter' ) {
            if (!(this.parameters.x !== null && this.parameters.y.length > 0)) {
                return false;
            }
        } else if (chartType === 'contour') {
                if (!(this.parameters.x !== null && this.parameters.y.length > 0 && this.parameters.color !=null)) {
                    return false;
                }
        }else if (chartType === 'bar' && chartLayout === 'paretto'){
            if (!(this.parameters.x.length > 0 && this.parameters.y.length > 0)) {
                return false;
            }
        }else {
            if (!(this.parameters.x !== null)) {
                return false;
            }
        }
        return true;
    };

    avsDropChartBasePrototype.preRender = function() {
        var that = this;

        this.divs.xAxisDropZone.hidePlaceholder();
        if (that.divs.yAxisDropZone) {
            this.divs.yAxisDropZone.hidePlaceholder();
        }
        this.divs.colorDropZone.hidePlaceholder();
        this.divs.sizeDropZone.hidePlaceholder();
        this.divs.labelDropZone.hidePlaceholder();
        this.divs.constraintDropZone.hidePlaceholder();
        this.divs.chartDropZone.hidePlaceholder();
    };

    avsDropChartBasePrototype.updateSize = function(configuration) {
        if (configuration) {
            this.requestObject.chartRequest.height = configuration.height;
            this.requestObject.chartRequest.width = configuration.width;
        } else {
            this.requestObject.chartRequest.height = this.divs.chartDropZone.offsetHeight;
            this.requestObject.chartRequest.width = this.divs.chartDropZone.offsetWidth;
        }
    };
    avsDropChartBasePrototype.resize = function() {
        this.renderChart();        
    };

    avsDropChartBasePrototype.makeZoomable = function(options) {
        console.warn('DEPRECATED - settings should be passed via AvailableCharts');
        this.zoomable = true;
        this.zoomOptions = options;

        if (this.avsDropChart) {
            this.avsDropChart.makeZoomable(options);
        }
    };
    
    avsDropChartBasePrototype.initializeZoom = function(){
        this.zoomable = false;
        this.zoomOptions = {
            'enabled' : false, // completely disabled
            'x' :  false, // disabled on the x axis
            'y' :  false, // disabled on the y axis
        };
        if(this.chartProperties && this.chartProperties.uiprops && this.chartProperties.uiprops.zoomable){
            // enable zoom iff all is set
            this.zoomable = this.chartProperties.uiprops.zoomable === 'all';
            
            // TODO:  send in options that make zoom work in one/both directions
//          this.zoomable = this.chartProperties.uiprops.zoomable !== 'none';
//            this.zoomOptions = {
//                'x' :  ['x','all'].indexOf(this.chartProperties.uiprops.zoomable) >= 0,
//                'y' :  ['y','all'].indexOf(this.chartProperties.uiprops.zoomable) >= 0,
//            };
        }
        if(this.zoomable){
            this.zoomOptions.enabled = true;
            this.zoomOptions.x = true;
            this.zoomOptions.y = true;
        }
    };

    avsDropChartBasePrototype.renderChart = function(configuration) {
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
                if (Object.keys(this.legendElements).length === 0) {
                    this.removeOverlayElements();
                    this.overlayLegend = null;
                }
            }
            return;
        }

        this.preRender();
        this.updateSize(configuration);
        if (configuration) {
            that.requestObject.datasetId = configuration.datasetId;
        }

        if (Object.keys(this.legendElements).length === 0) {
            this.removeOverlayElements();
            this.overlayLegend = null;
        }

        if (this.avsDropChart === null) {
            this.avsDropChart = document.createElement(
                'ra-avsdropchartelement'
            );
            
            // FIXME: need a better way of getting the ra-gridframe
            this.parentElement.parentElement.parentElement.addCallback('print', function() {
                var dce = that.avsDropChart;
                dce.printRequest(
                        dce.requestObject,
                        dce.chart,
                        dce.uniqueKey
                    );
            });

            this.avsDropChart.chartParent = this;

            this.avsDropChart.setDataProvider(this.dataProvider);
            this.divs.chartDropZone.appendChild(this.avsDropChart);

            // commented out because selection is handled in the zoom code
            // multiple variables are passed with the zoomOptions to keep track of whether zoom is enabled or not
            //if (this.zoomable) {
            this.avsDropChart.makeZoomable(this.zoomOptions);
            //}
        } else {
            this.avsDropChart.removeChartTiles();
        }

        // TODO get background color from the template
        this.avsDropChart.setBackgroundColor('white');
        this.avsDropChart.setTotalWidth(this.getChartAreaWidth());
        this.avsDropChart.setTotalHeight(this.getChartAreaHeight());

        var renderLegends = function(data) {
            that.renderLegends(data, that, requestType);
            // AFTER REVIEW OF DCE
            that.hideDropZones();
        };
        var requestType = this.chartProperties.defaults[0].type;

        this.updateRequest();
        this.updateRequestObject();
        this.updateRequestLegends();

		/* This is a hack by Carlin, I'll look a bit deeper and figure out why 
		   setting properties on the Y-axis is making it bomb later, but that 
		   should work for now. we don't have a settings panel, 
		   anyways, so it shouldn't matter that we're removing the properties. */
		   
		try{
		
			if(typeof this.requestObject.chartRequest.charts[0].y.axisProperties.title.properties !==
			'undefined'){
				delete this.requestObject.chartRequest.charts[0].y.axisProperties.title.properties;
			}
		}catch(e){}
		
        // d9u -the below forces the raw scatter to not be binned, should be fixed
        // by Carlin soon :)
        //        delete this.requestObject.chartRequest.charts[0].x.data.numBins;
        //        this.requestObject.chartRequest.charts[0].x.data.type = 'raw';

        this.avsDropChart.renderRequest(
            this.requestObject,
            this,
            requestType,
            renderLegends
        );
    };

    avsDropChartBasePrototype.hideDropZones = function() {
        // validateRender is now being sent to the dropzones and called
        // there when hidePlaceholder is called
        // if(this.validateRender()){
        var dropZones = this.querySelectorAll('ra-chartdroptarget');

        Array.prototype.forEach.call(
            dropZones,
            function(dropZone) {
                dropZone.hidePlaceholder();
                // dropZone.style.display ='none';
            },
            this
        );

        this.divs.chartDropZone.style.display = 'block';
        //}
    };

    avsDropChartBasePrototype.addRawParam = function(newParam, paramArray) {
        for (var i = 0; i < paramArray.length; i++) {
            if (paramArray[i].guid === newParam.id) {
                return;
            }
        }
        paramArray.push({ guid: newParam.id });
    };

    avsDropChartBasePrototype.addDataMap = function(newDataMap, dataMapArray) {
        for (var i = 0; i < dataMapArray.length; i++) {
            if (dataMapArray[i].guid === newDataMap.guid) {
                return;
            }
        }
        dataMapArray.push(newDataMap);
    };

    avsDropChartBasePrototype.updateAxisLabel = function(axisParent, label) {
        if (typeof axisParent.axisProperties === 'undefined') {
            axisParent.axisProperties = {};
        }
        if (typeof axisParent.axisProperties.title === 'undefined') {
            axisParent.axisProperties.title = {};
        }
        axisParent.axisProperties.title.text = label;
    };

    avsDropChartBasePrototype.getChartAreaWidth = function() {
        return this.divs.chartDropZone.offsetWidth;
    };

    avsDropChartBasePrototype.getChartAreaHeight = function() {
        return this.divs.chartDropZone.offsetHeight;
    };

    avsDropChartBasePrototype.renderStylePanel = function(panel) {
        var that = this;

        this.stylePanel = panel;

        panel.setChangeCallback(function(data) {
            that.chartParameters[data.id].update(data);

            that.renderChart();
        });

        this.updateStylePanel();
    };

    avsDropChartBasePrototype.updateStylePanel = function() {
        var that = this;

        if (this.stylePanel && this.stylePanel.currentChart() === this) {
            var parameters = Object.keys(this.chartParameters).map(function(
                key
            ) {
                var json = that.chartParameters[key].getTweakerJSON();
                json.id = key;
                return json;
            });

            this.stylePanel.setParameters(parameters);
        }
    };

    avsDropChartBasePrototype.renderControlPanel = function(panel) {
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
        } else if (chartType === 'contour') {
            chartPropertiesControl = panel.getControl(
                    'ra-contourchartpropertiescontrol'
                );
        }
        if (chartPropertiesControl !== null) {
            chartPropertiesControl.setDefaultRequest(
                this.chartProperties.defaults[0]
            );
            chartPropertiesControl.setChangeListener(
                function() {
                    this.hideDropZones();
                    this.renderChart();
                }.bind(this)
            );
        }

        // Add x param panel
        var xDim = this.findDimension(dimensions, 'x');
        if (typeof xDim !== 'undefined') {
            var xParamControl = panel.getControl(xDim.uipanel);
            xParamControl.setAttribute('data-rec-id', 'customcharts.controlpanel.x');
            xParamControl.title('X');
            xParamControl.nParameters(1);
            xParamControl.setDefaultRequest(this.chartProperties.defaults[0].x);
            xParamControl.setFilter(this.validateXData.bind(this));
            xParamControl.setShowAggregationType(false);
            xParamControl.setChangeListener(
                function(params) {
                    this.setXParameter(params.length == 0 ? null : params[0]);
                    this.hideDropZones();
                    this.renderChart();
                }.bind(this)
            );            
            if(this.parameters.x instanceof Array){
                    xParamControl.updateController(this.parameters.x);
            }else if (this.parameters.x) {
                xParamControl.updateController([this.parameters.x]);
            }

            var xParamIcon = xParamControl.querySelector('.controlIcon');
            if (xParamIcon !== null) {
                xParamIcon.classList.add('xParamIcon');
                xParamIcon.setAttribute('title', this.getDefaultXAxisLabel());
            }
        }

        // Add y param panel
        var yDim = this.findDimension(dimensions, 'y');
        if (typeof yDim !== 'undefined') {
            var yParamControl = panel.getControl(yDim.uipanel);
            yParamControl.setAttribute('data-rec-id', 'customcharts.controlpanel.y');
            yParamControl.title('Y');
            yParamControl.nParameters(1);
            yParamControl.setDefaultRequest(this.chartProperties.defaults[0].y);
            yParamControl.setFilter(this.validateYData.bind(this));
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
                yParamIcon.setAttribute('title', this.getDefaultYAxisLabel());
            }
        }
        
        if(this.supportYLine()){   
            
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
                
        
            // Add y secondary panel
            var yLineDim = this.findDimension(dimensions, 'yline');
            if (typeof yLineDim !== 'undefined') {
                var yLineParamControl = panel.getControl(yLineDim.uipanel);
                yLineParamControl.setAttribute('data-rec-id', 'customcharts.controlpanel.yline');                
                yLineParamControl.title('Y Secondary Axis');
                yLineParamControl.nParameters(10);
                yLineParamControl.setDefaultRequest(this.chartProperties.defaults[1].y);
                yLineParamControl.setFilter(this.validateYLineData);
                yLineParamControl.setChangeListener(function(params) {
                    that.setYLineParameters(params);
                    that.renderChart();
                });
                if (this.parameters.yline) {
                    yLineParamControl.updateController(this.parameters.yline);
                }
                var yAltParamIcon = yLineParamControl.querySelector('.controlIcon');
                if (yAltParamIcon !== null) {
                    yAltParamIcon.classList.add('yAltParamIcon');
                    yAltParamIcon.setAttribute('title', NLSUtils.translate('Y Secondary Axis'));
                }                
            }
        }
        

        // Add color param panel
        var colorDim = this.findDimension(dimensions, 'color');
        if (typeof colorDim !== 'undefined') {
            var colorParamControl = panel.getControl(colorDim.uipanel);
            colorParamControl.setAttribute('data-rec-id', 'customcharts.controlpanel.color');
            colorParamControl.title('Color');
            colorParamControl.nParameters(1);
            colorParamControl.setDefaultRequest(
                this.chartProperties.defaults[0].color
            );
            colorParamControl.setFilter(this.validateColorData);
            colorParamControl.setChangeListener(function(params) {
                that.onColorDrop(params.length == 0 ? null : params[0]);

                // that.setColorParameter(params.length == 0 ? null : params[0]);
                // that.renderChart();
            });
            if (this.parameters.color) {
                colorParamControl.updateController([this.parameters.color], this.getColorMap(this.parameters.color));
            }

            var colorParamIcon = colorParamControl.querySelector(
                '.controlIcon'
            );
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
            sizeParamControl.setAttribute('data-rec-id', 'customcharts.controlpanel.size');
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
            labelParamControl.setAttribute('data-rec-id', 'customcharts.controlpanel.label');
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
            constraintParamControl.setAttribute('data-rec-id', 'customcharts.controlpanel.constraint');
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

            var constraintParamIcon = constraintParamControl.querySelector(
                '.controlIcon'
            );
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
        
        if (yLineParamControl !== undefined){
            this.controls.yLineControl = yLineParamControl;
            this.controls.lineChartPropertiesControl = lineChartPropertiesControl;
                    
         }
                
    };

    avsDropChartBasePrototype._deleteParameterIfUsing = function(
        deletedParamId,
        parameter,
        setParameterNullFunct,
        control,
        dropZone,
        prameterUsed,
        arrayIndex
    ) {
        if (
            typeof parameter !== 'undefined' &&
            parameter !== null &&
            parameter.id === deletedParamId
        ) {
            control.removeParameter(parameter);
            setParameterNullFunct(arrayIndex);
            dropZone.updatePlaceholder();
            prameterUsed.parDelResult = true;
        }
    };

    avsDropChartBasePrototype._getDisplayTextForParameter = function(param, defaultText){
    
        if (param instanceof Array){
            if(param.length > 0){
                var text = '';
                for (var i = 0; i < param.length; i++) {
                    if (i !== 0) {
                        text += ',';
                    }
                    text += decodeURIComponent(
                        param[i].displayName ||
                        param[i].name
                    );
                }
                return text;
            }else{
                return defaultText;
            }
                    
        }else{
            if(param !== 'undefined' &&  param !== null){
                return decodeURIComponent(
                            param.displayName ||
                            param.name);
             }else{
                 return defaultText;
             }                 
        }
        
    }
    
    avsDropChartBasePrototype._updatreParameterIfChanged = function(
        newParameterMap,
        parameter,
        control,
        dropZone,
        parameterChanged,
        setCharParmetFunct
    ) {
        if (typeof parameter !== 'undefined' && parameter !== null) {
            var parLookup = newParameterMap.get(parameter.id);
            if (parLookup !== undefined) {
                if (parameter.displayName !== parLookup.displayName) {
                    // unfortunately currently we need to in order to update axis
                    // title we need to rerender entire chart, we should change this
                    // to just rerender axis or better just update the html
                    parameterChanged.parChgResult = true;

                    parameter.displayName = parLookup.displayName;

                    if (control !== null) {
                        control.updateController([parameter]);
                    }
                    if (dropZone !== null) {
                        dropZone.updatePlaceholder();
                    }
                    if (setCharParmetFunct !== undefined) {
                        setCharParmetFunct(parameter);
                    }
                }
            } else {
                parameterChanged.parDelResult = true;
            }
        }
    };

    avsDropChartBasePrototype._updatreConstraintIfChangedParameter = function(
        newParameterMap
    ) {
        var constraintChanged = false;
        if (
            typeof this.parameters.constraints !== 'undefined' &&
            this.parameters.constraints !== null
        ) {
            for (
                var constraintIndex = 0;
                constraintIndex < this.parameters.constraints.length;
                constraintIndex++
            ) {
                var constraint = this.parameters.constraints[constraintIndex];
                var constraintParameterId =
                    constraint.properties.parameterID[0];
                var newParameter = newParameterMap.get(constraintParameterId);
                if (newParameter === undefined) {
                    // should never happen, if it happens dont do anything
                } else {
                    if (
                        newParameter.displayName !==
                        constraint.properties.sourceParameterName
                    ) {
                        constraintChanged = true;
                        constraint.name = constraint.name.replace(
                            constraint.properties.sourceParameterName,
                            newParameter.displayName
                        );
                        constraint.properties.name = constraint.properties.name.replace(
                            constraint.properties.sourceParameterName,
                            newParameter.displayName
                        );
                        constraint.properties.sourceParameterName =
                            newParameter.displayName;
                    }
                }
            }
        }

        if (constraintChanged === true) {
            this.controls.constraintControl.updateController(
                this.parameters.constraints
            );
            this.divs.constraintDropZone.updatePlaceholder();
        }
    };

    avsDropChartBasePrototype._deleteParameterIfUsingConstraint = function(
        deletedParamId,
        prameterUsed
    ) {
        if (
            typeof this.parameters.constraints === 'undefined' ||
            this.parameters.constraints === null
        ) {
            return null;
        }

        for (
            var constraintIndex = 0;
            constraintIndex < this.parameters.constraints.length;
            constraintIndex++
        ) {
            var constraint = this.parameters.constraints[constraintIndex];
            var constraintParameterId = constraint.properties.parameterID[0];

            if (constraintParameterId === deletedParamId) {
                this.controls.constraintControl.removeParameter(constraint);
                this.parameters.constraints.splice(constraintIndex, 1);
                --constraintIndex; // we just removed one must account for it
                this.divs.constraintDropZone.updatePlaceholder();
                prameterUsed.parDelResult = true;
            }
        }
    };

    avsDropChartBasePrototype.findDimension = function(dimensions, findIt) {
        for (var i = 0; i < dimensions.length; i++) {
            if (dimensions[i].dim === findIt) {
                return dimensions[i];
            }
        }
    };
    avsDropChartBasePrototype.getShapeForParameter = function(parameterId) {
        
        var parameterToShapeMap = GLOBAL.DS.RAObjects.shapeToColorMap;
        var usedShapeSet = GLOBAL.DS.RAObjects.userShapesForParameterSet;                
        
        var existingShape = parameterToShapeMap[parameterId];
        if(existingShape === undefined){
            var shapeMap = GLOBAL.DS.RAObjects.dataMaps.parametersShapeMap;
            for (var j=0; j<shapeMap.shapes.length; j++) {
                if(usedShapeSet.has(shapeMap.shapes[j])){
                    continue;
                } else {
                    existingShape = shapeMap.shapes[j];
                    usedShapeSet.add(existingShape);
                    parameterToShapeMap[parameterId] =  existingShape;
                    break;
                 }
              }
              // still undefined then use default color
              if(existingShape === undefined){
                existingShape = 'circle';
              }
         }
         return existingShape;          
      };   
    avsDropChartBasePrototype.getSeriesColorForParameter = function(parameterId) {
        
        var parameterToColorMap = GLOBAL.DS.RAObjects.parameterToColorMap;
        var usedColorSet = GLOBAL.DS.RAObjects.userColersForParameterSet;                
        
        var existingColor = parameterToColorMap[parameterId];
        if(existingColor === undefined){
            var colorMap = GLOBAL.DS.RAObjects.dataMaps.seriesParametersColorMap;
            for (var j=0; j<colorMap.colors.length; j++) {
                if(usedColorSet.has(colorMap.colors[j])){
                    continue;
                } else {
                    existingColor = colorMap.colors[j];
                    usedColorSet.add(existingColor);
                    parameterToColorMap[parameterId] =  existingColor;
                    break;
                 }
              }
              // still undefined then use default color
              if(existingColor === undefined){
                existingColor= '#368ec4';
              }
         }
         return existingColor;          
      };
      
    
    // should be overridden by derived chart if it wants to support yline
    avsDropChartBasePrototype.supportYLine = function() {
        return false;
    };
    
    // should be overridden by derived chart if it wants to support colored 
    // element in control panel for y and yline
    avsDropChartBasePrototype.supportColorYParamElement = function() {
        return false;
    };
    
    avsDropChartBasePrototype.loadHighChartsLibrary = function() {
         return new Promise(function(resolve, reject){
            require(['DS/WebappsUtils/WebappsUtils'], 
                function (WebappsUtils){
                    var proxifiedURL = WebappsUtils.getProxifiedWebappsBaseUrl() ;
                    var highChartsURI = proxifiedURL + 'SMAVenHighcharts/7.0.3/highcharts.js' ;
                    if( highChartsURI.indexOf( '?' ) > -1 ) {
                        highChartsURI = highChartsURI.substring( 0, highChartsURI.indexOf( '?' ) );
                    }
    
                    var highChartsMoreURI =proxifiedURL + 'SMAVenHighcharts/7.0.3/highcharts-more.js' ;
                    if( highChartsMoreURI.indexOf( '?' ) > -1 ) {
                        highChartsMoreURI = highChartsMoreURI.substring( 0, highChartsMoreURI.indexOf( '?' ) );
                    }
        
                    var exportingURI = proxifiedURL + 'SMAVenHighcharts/7.0.3/modules/exporting.js' ;
                    if( exportingURI.indexOf( '?' ) > -1 ) {
                        exportingURI = exportingURI.substring( 0, exportingURI.indexOf( '?' ) );
                    }
                    
                    require([highChartsURI, highChartsMoreURI, exportingURI], 
                        function (Highcharts, highchartsmore, exporting) {
                            // We need to initialize module files and pass in Highcharts
                            highchartsmore(Highcharts);
                            exporting(Highcharts); // Load exporting
                            resolve(Highcharts);
                    });
            });
        });
    }

    Polymer(avsDropChartBasePrototype);
    GLOBAL.DS.RAComponents.avsdropchartbase = avsDropChartBasePrototype;
})(this);
