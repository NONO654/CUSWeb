//XSS_CHECKED
(function(GLOBAL) {
    var chartLibrary = GLOBAL.DS.RAObjects.chartParameterLibrary;
    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;

    var raTableBasePrototype = {
        is: 'ra-tablebase',
        behaviors: [GLOBAL.DS.RAComponents.chart]
    };
    

    raTableBasePrototype.createdCallback = function() {        
        this.initializationInProgress = false;
        
        // create the root
        this.divs = { root: document.createElement('div') };
        this.divs.root.classList.add('avsDropChart-rootDiv');
        this.appendChild(this.divs.root);
        
        this.addChart();
        this.chartParameters = {};

        this.addChartEventListener(function(args, sources) {
            this.onChartEvent(args, sources);
        }.bind(this));
    };
    
    raTableBasePrototype.onChartEvent = function(args, sources) {
        if (args.eventType !== 'undefined') {
            if (args.eventType === 'CASE_MODIFIED') {
                var modifiedEvents = args.events;
                var updateChart = false;

                modifiedEvents.forEach(
                    function(event) {
                        if (event.eventSubType === 'constraintChanged') {
                        	if(typeof this.constraintCallback === 'function'){
                                this.constraintCallback(event,updateObject);
                        	}
                        	updateChart = true;
                        } else if (
                            event.eventSubType === 'parameterChanged'
                        ) {

                            var newParameterMap = event.parameterMap;
                            this.updateFromConfiguration(newParameterMap);
//                            	this.parameterCallback(event,updateObject);
                            updateChart = true;
                        } else if (
                            event.eventSubType === 'parametersDeleted'
                        ) {
                        	if(event.deletedParams instanceof Array){
                        		event.deletedParams.forEach(deleteParameter,this);
                                updateChart = true;
                        	}
                        } else if (
                            event.eventSubType === 'filtersChanged' ||
                            event.eventSubType === 'datasetChanged'
                        ) {
                            updateChart = true;
                        }
                    }.bind(this)
                );

                if (updateChart) {
                    this.renderChart();
                }
                return;
            }
            this.avsDropChart.propagateChartEvent(args, sources);
        }
    };


    raTableBasePrototype.preRender = function() {
        var that = this;

        if(this.divs.xAxisDropZone){
        	this.divs.xAxisDropZone.hidePlaceholder();
        }
        if (this.divs.yAxisDropZone) {
            this.divs.yAxisDropZone.hidePlaceholder();
        }
        this.divs.chartDropZone.hidePlaceholder();
    };

    raTableBasePrototype.renderChart = function(configuration){
    	
        // if configuration is undefined then its not restore and there is some change in chart 
        // e.g parameer drop, resize or param delete, must store it to widget prefer temp storage
        if(configuration === undefined){
            this.chartParent.updateChartsConfigPreference(this.chartId);            
        }
        
        if (!this.validateRender()) {
            return;
        }
        
        this.preRender();
        
    	// prerender?
    	// we need the TreeDocument and the TreeListView to b
    	// postrender?
    	this.initializeTable().then(function(){
        	this.updateRequest();
    	}.bind(this),function(){}.bind(this));
//        this.updateRequestObject();
    	
    };
    
    raTableBasePrototype.addColumn = function(columnProperties){
    	if(this.tableView && columnProperties){
    		var mgr = this.tableView.getManager();
    		mgr.prepareUpdateView();
    		mgr.addColumn(columnProperties);
    		var columns = mgr.getColumns();
    		var column = columns[columns.length - 1];
    		column.text = columnProperties.text;
    		column.dataIndex = columnProperties.dataIndex;
    		column.width = "auto"; // makes width resizable 
    		mgr.pushUpdateView();
    	}
    };
    
    
    // searches the columns in the current treelistview for the column
    // with the provided id
    raTableBasePrototype.findColumn = function(colId){

    	if(this.tableView){
    		var mgr = this.tableView.getManager();
    		var columns = mgr.getColumns(),
    			column = null;
    		columns.some(function(_column){
    			if(_column.dataIndex === colId){
    				column = _column;
    				return true;
    			}
    		},this);
    		return column;
    	}
    };
    
    raTableBasePrototype.applyClassToRow = function(rowId, classList){
    	if(this.treeDocument){
    		var matchedNodesList = this.treeDocument.search({
    	        match: function(nodeInfos) {
    	            if (rowId && nodeInfos.nodeModel.options.id === rowId) {
    	                return true;
    	            }
    	        }
    	    });
    	}
    }
    
    
    raTableBasePrototype.addRow = function(rowProperties){
    	if(this.treeDocument && rowProperties){
    		this.treeDocument.prepareUpdate();
    		this.treeDocument.addChild(new this.TreeNodeModel(rowProperties));
    		this.treeDocument.pushUpdate();
    	}
    };
    
    raTableBasePrototype.initializeTable = function(){
    	return new Promise(function(resolve, reject){
    		if (this.initializationInProgress) {
    			reject();
    		} else if (!this.tableView){
    			this.initializationInProgress = true;
    			require(['DS/Tree/TreeListView', 'DS/Tree/TreeNodeModel'], function(TreeListView,TreeNodeModel){
    				var columns = this.setupColumns(this.getColumnList());
	    			this.tableView = new TreeListView({
	    				columns: columns,
	    				height: 'auto',
	    				width: 'auto',
	    				selection: {
	    					toggle: false,
	    					canMultiSelect: false,
	    					nodes: false
	    				},
	    				resize: {
	    					columns: true
	    				},
	    				enableDragAndDrop: false,
	    				isSortable: false
	    			}).inject(this.divs.chartDropZone);
	    			this.treeDocument = this.tableView.getDocument();
	    			this.TreeNodeModel = TreeNodeModel; // we'll need this later ...
	    			this.initializationInProgress = false;
	    			resolve();
	    		}.bind(this));
    		}else{
    			// the view is defined, but update the column list

    			this.updateColumns(this.getColumnList());
				
    			resolve();
    		}
    	}.bind(this));
    };
    
    raTableBasePrototype.getColumnList = function(){
    	return this.parameters.x;
    };
    
    raTableBasePrototype.setupColumns = function(columnArray){
		var columns = [{
			'text': '', // lets not show the text for this
			'dataIndex': 'tree'
		}];
    	if(columnArray instanceof Array){
    		columnArray.forEach(function(param){
    			if(param.id === 'tree'){
    				columns[0].text = decodeURIComponent(param.displayName);
    				return;
    			}
				columns.push({
					'text': decodeURIComponent(param.displayName),
					'dataIndex': param.id,
					'width': 'auto'
				});
			},this);
    	}
    	return columns;
    };
    raTableBasePrototype.updateColumns = function(columnsArray){
    	if(this.tableView && columnsArray instanceof Array){
    		var mgr = this.tableView.getManager();
    		
    		// add/update missing columns
    		columnsArray.forEach(function(param){
				var column = this.findColumn(param.id);
				if(column === null){
					this.addColumn({
						'text': decodeURIComponent(param.displayName),
						'dataIndex': param.id,
						'width': 'auto'
					});
				}else{
		    		mgr.prepareUpdateView();
					column.text = decodeURIComponent(param.displayName);
		    		mgr.pushUpdateView();
				}
			},this);
    		
    		// remove missing columns
    		var columns = mgr.getColumns().slice();
			// iterate backwards so as not to accidentally remove the wrong index
			for(var i = columns.length - 1; i > 0;  i--){
				var column = columns[i];
				var found = columnsArray.some(function(_column){
	    			if(column.dataIndex === _column.id){
	    				return true;
	    			}
	    			return false;
	    		},this);
				if(!found){
					mgr.prepareUpdateView();
					mgr.removeColumn(i);
					mgr.pushUpdateView();
				}
			}
			
			// we're having an issue with the columns not honoring the resize.
			// this kicks the tires and forces the resize to occur :)
			this.tableView.loadColumns(mgr.getColumns());
    	}
    };
    
    
    // see avsDropChartBasePrototype.addChart
    raTableBasePrototype.addChart = function() {        
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
    
//    raTableBasePrototype.setDataProvider = function(){
//    	// TODO: need to define how this works
//    };
    
    raTableBasePrototype.getConfiguration = function(){
        var configuration = {};
        configuration.parameters = this.parameters;
        configuration.chartParameters = this.chartParameters;
        configuration.height = this.requestObject.chartRequest.height;
        configuration.width = this.requestObject.chartRequest.width;
        configuration.datasetId = this.requestObject.datasetId;
        if(this.getChartSettings !== undefined){
            configuration.chartSettings = this.getChartSettings();
        }
        
        return configuration;
    };

    // TODO: change to Columns ...
    raTableBasePrototype.addXAxis = function() {
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
        this.divs.xAxisDropZone.setParameterListener(this.setXParameter);
        this.divs.xAxisDropZone.showPlaceholder();

        this.divs.xAxisDropZone.setPlaceholderText(function() {
            if (that.parameters.x.length === 0) {
                return NLSUtils.translate('Columns');
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
                this.controls.xControl.updateController(this.parameters.x);
                this.handleRefreshAfterDrop();
            }.bind(this)
        );

        this.divs.xAxisDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.xAxisDropZone);
    };
    
    // TODO: change to Rows
    raTableBasePrototype.addYAxis = function() {
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
        this.divs.yAxisDropZone.setParameterListener(this.addYParameter);
        this.divs.yAxisDropZone.showPlaceholder();
        this.divs.yAxisDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        this.divs.yAxisDropZone.setPlaceholderText(function() {
            if (that.parameters.y.length === 0) {
                return NLSUtils.translate('Rows');
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

    raTableBasePrototype.placeholderFilter = function() {
        return !this.validateRender();
    };
    raTableBasePrototype.validateRender = function(){
    	if(!(this.parameters.x.length > 0 && this.parameters.y.length > 0)){
    		return false;
    	}
    	return true;
    };
    

    raTableBasePrototype.validateXData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };

    raTableBasePrototype.validateYData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        return true;
    };
    
    // delete's all references to a parameter that has been deleted from a case
    raTableBasePrototype.deleteParameter = function(parameterId){
    	if(this.parameters.x instanceof Array){
    		this.parameters.x.some(function(xParam, paramIndex){
    			if(parameterId === xParam.id){
    				// remove it
        			if (this.divs.xAxisDropZone) {
            	        this.divs.xAxisDropZone.updatePlaceholder();
        			}
        			if (this.controls && this.controls.xControl) {
        				this.controls.xControl.removeParameter(parameter)
        			}
    	            this.parameters.x.splice(paramIndex,1);
    	            return true;
    			}
    		}.bind(this));
    		this.parameters.y.some(function(yParam, paramIndex){
    			if(parameterId === yParam.id){
    				// remove it
        			if (this.divs.yAxisDropZone) {
            	        this.divs.yAxisDropZone.updatePlaceholder();
        			}
        			if (this.controls && this.controls.yControl) {
        				this.controls.yControl.removeParameter(parameter)
        			}
    	            this.parameters.y.splice(paramIndex,1);
    	            return true;
    			}
    		}.bind(this));
    	}
    };
    
    raTableBasePrototype.updateFromConfiguration = function(paramsFromConfig){
        var removeIndices = [];
        if(this.parameters.x instanceof Array){
        	this.parameters.x.forEach(function(param,index){
        		var updatedParam = this.getParamFromConfiguration(paramsFromConfig,param);
        		if(!updatedParam){
        			removeIndices.push(index);
        			return;
        		}
        		
    			var nameUpdated = this.updateParameterName(param, updatedParam);
//        		if(nameUpdated){
//        			if (this.controls.xControl) {
//        				this.controls.xControl.updateController([param]);
//        			}
//        		}
        		
        	},this);
        	
        	// you want to reverse the list so that the indices are correct
        	removeIndices.reverse();
        	removeIndices.forEach(function(index){
        		this.parameters.x.splice(index,1);
        	},this);
            this.setXParameters(this.parameters.x);
        }
        
        removeIndices = [];
        if(this.parameters.y instanceof Array){
        	this.parameters.y.forEach(function(param){
        		var updatedParam = this.getParamFromConfiguration(paramsFromConfig,param);
        		if(!updatedParam){
        			removeIndices.push(index);
        			return;
        		}
        		
    			var nameUpdated = this.updateParameterName(param, updatedParam);
    			// the below is being done via the this.setYParameters call
    			// TODO: the updateController should be 
//        		if(nameUpdated){
//        			if (this.divs.yAxisDropZone) {
//            	        this.divs.yAxisDropZone.updatePlaceholder();
//        			}
//        			if (this.controls.yControl) {
//        				this.controls.yControl.updateController([param]);
//        			}
//        		}
        	},this);
        	
        	// you want to reverse the list so that the indices are correct
        	removeIndices.reverse();
        	removeIndices.forEach(function(index){
        		this.parameters.y.splice(index,1);
        	},this);
            this.setYParameters(this.parameters.y);
        }
    };
    
    raTableBasePrototype.initialize = function(configuration) {
    	if (configuration) {
            this.parameters = configuration.parameters;
            this.chartParameters = configuration.chartParameters;
            var newParameterMap = configuration.latestParameters;
            
            this.updateFromConfiguration(newParameterMap);

        } else {
            this.parameters = {
                x: [],
                y: [],
            };

            this.chartParameters = {
                x: [],
                y: [],
            };
        }

        this.requestObject = null;
        this.avsDropChart = null; // TODO: required?
    };
    raTableBasePrototype.updateRequest = function(){
    	console.log('Write update function');
    };
    raTableBasePrototype.renderRequest = function(){
    	console.log('Write render function');
    };
    
    raTableBasePrototype.getParamFromConfiguration = function(parameterMap, parameter){

        if (typeof parameter !== 'undefined' && parameter !== null) {
        	var parLookup = parameterMap.get(parameter.id);
        	if(typeof parLookup !== 'undefined'){
        		return parLookup;
        	}
        }
        return false;
    };
    raTableBasePrototype.updateParameterName = function(parameter, updatedParam){
    	if(typeof updatedParam !== 'undefined'){
    		if(parameter.displayName !== updatedParam.displayName){
    			parameter.displayName = updatedParam.displayName;
    			return true
    		}
    	}
    };
    
//    raTableBasePrototype.updateRequestObject = function(){
//    	var key, i, parameter;
//        var guidsMap = {};
//
//        this.requestObject = this.requestObject || {};
//        this.requestObject.data = this.requestObject.data || {};
//        this.requestObject.data.raw = this.requestObject.data.raw || [];
//
//        // Update raw params.
//        // To build the raw params array, we assign each guid as a key on a map.
//        // This ensures that each  key only appears once.
//
//        // Note: once we eliminate the old code for doing this, we can directly
//        // assign the raw params  array insead of copying the old version of it to the
//        // guidsMap object.
//        for (var i = 0; i < this.requestObject.data.raw.length; i++) {
//            guidsMap[this.requestObject.data.raw[i]] = true;
//        }
//
//        for (key in this.chartParameters) {
//            parameter = this.chartParameters[key];
//            guidsMap[parameter.settings.guid.value] = true;
//
//            // TODO: Generalize legends.
//            // if(parameter.attributes.legend &&
//            // parameter.checkToggle(parameter.attributes.legend)){
//
//            //}
//        }
//
//        this.requestObject.data.raw = Object.keys(guidsMap);
//
//        // Update request object with chart data.
//        // This coulde be combined with the above for loop if necessary. It's
//        // separate for now for  purely organizational purposes.
//        for (key in this.chartParameters) {
//            this.requestObject.chartRequest.charts[0][
//                key
//            ] = this.chartParameters[key].getRequestJSON();
//        }
//    };
    
    raTableBasePrototype.addRawParam = function(newParam, paramArray) {
        for (var i = 0; i < paramArray.length; i++) {
            if (paramArray[i].guid === newParam.id) {
                return;
            }
        }
        paramArray.push({ guid: newParam.id });
    };
    
    raTableBasePrototype.renderControlPanel = function(panel){
        var that = this;

        this.requestObject = {
            chartRequest: {
                width: this.getChartAreaWidth(),
                height: this.getChartAreaHeight(),
                charts: []
            }
        };
        var dimensions = this.chartProperties.uiprops.dimensions;

        // Add x param panel
        var xDim = this.findDimension(dimensions, 'x');
        if (typeof xDim !== 'undefined') {
            var xParamControl = panel.getControl(xDim.uipanel);
            xParamControl.title('X');
            xParamControl.nParameters(20);
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
            if (this.parameters.x) {
                xParamControl.updateController(this.parameters.x);
            }

            var xParamIcon = xParamControl.querySelector('.controlIcon');
            if (xParamIcon !== null) {
                xParamIcon.classList.add('xParamIcon');
                xParamIcon.setAttribute('title', NLSUtils.translate('Columns'));
            }
        }

        // Add y param panel
        var yDim = this.findDimension(dimensions, 'y');
        if (typeof yDim !== 'undefined') {
            var yParamControl = panel.getControl(yDim.uipanel);
            yParamControl.title('Y');
            yParamControl.nParameters(20);
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
                yParamIcon.setAttribute('title', NLSUtils.translate('Rows'));
            }
        }

        this.controls = {
            xControl: xParamControl,
            yControl: yParamControl
        };
    };

    raTableBasePrototype.getChartAreaWidth = function() {
        return this.divs.chartDropZone.offsetWidth;
    };

    raTableBasePrototype.getChartAreaHeight = function() {
        return this.divs.chartDropZone.offsetHeight;
    };
    
    raTableBasePrototype.findDimension = function(dimensions, findIt) {
        for (var i = 0; i < dimensions.length; i++) {
            if (dimensions[i].dim === findIt) {
                return dimensions[i];
            }
        }
    };

    raTableBasePrototype.setXParameter = function(parameter) {
    	if(typeof parameter === 'undefined'){
    		// not a real update
    		return;
    	}
    	
    	var doNotAdd = this.parameters.x.some(function(_parameter){
    		if(_parameter.id === parameter.id){
    			return true;
    		}
    	});
    	
    	if(doNotAdd){
    		return;
    	}
    	
        this.parameters.x.push(parameter);

        // if x ix not null, then we're resetting the x parameter
        if (this.parameters.x.length > 0) {
            var attributes = {
                data: { guid: parameter.id },
                axisProperties: {
                    title: { text: decodeURIComponent(parameter.displayName) }
                }
            };
            var newXParam = this.getXParameter(parameter, attributes)
            this.chartParameters.x.push(newXParam);
            newXParam.update(attributes);
        } else if (typeof this.chartParameters.x !== 'undefined') {
        	// TODO: We really do not need this for the table
            // x was null and it was previously set, so delete the previous x
            // reference
        	this.chartParameters.x.some(function(_parameter,_pIndex){
        		if(_parameter.id === parameter.id){
        			this.chartParameters.x.splice(_pIndex,1);
        		}
        	},this);
        }

        this.divs.xAxisDropZone.updatePlaceholder();
    };

    raTableBasePrototype.setXParameters = function(parameters) {
    	this.parameters.x = parameters;
    	
    	if(this.divs.xAxisDropZone){
            this.divs.xAxisDropZone.updatePlaceholder();
    	}
		if (this.controls && this.controls.xControl) {
			this.controls.xControl.updateController(this.parameters.x);
		}
    };

    raTableBasePrototype.getXParameter = function(parameter, attributes) {
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
    
    
    raTableBasePrototype.addYParameter = function(parameter) {
    	
    	if(typeof parameter === 'undefined'){
    		// not a real update
    		return;
    	}
    	
    	var doNotAdd = this.parameters.y.some(function(_parameter){
    		if(_parameter.id === parameter.id){
    			return true;
    		}
    	});
    	
    	if(doNotAdd){
    		return;
    	}
    	
        this.parameters.y.push(parameter);

        // if x ix not null, then we're resetting the x parameter
        if (this.parameters.y.length > 0) {
            var attributes = {
                data: { guid: parameter.id },
                axisProperties: {
                    title: { text: decodeURIComponent(parameter.displayName) }
                }
            };
            var newYParam = this.getYParameter(parameter, attributes)
            this.chartParameters.y.push(newYParam);
            newYParam.update(attributes);
        } else if (typeof this.chartParameters.y !== 'undefined') {
        	// TODO: We really do not need this for the table
            // x was null and it was previously set, so delete the previous x
            // reference
        	this.chartParameters.y.some(function(_parameter,_pIndex){
        		if(_parameter.id === parameter.id){
        			this.chartParameters.y.splice(_pIndex,1);
        		}
        	},this);
        }

        this.divs.yAxisDropZone.updatePlaceholder();
    };
    
    raTableBasePrototype.getYParameter = function(parameter, attributes) {
        var chartParam;

        if (parameter.dataType === 'STRING') {
            chartParam = chartLibrary.parameterTemplates.discreteSpatial.create(
                'Y'
            );
            attributes.discreteValues = parameter.discreteValues;
        } else {
            chartParam = chartLibrary.parameterTemplates.binnedNumericSpatial.create(
                'Y'
            );
        }

        return chartParam;
    };
    
    raTableBasePrototype.setYParameters = function(parameters) {
    	this.parameters.y = parameters;
    	if(this.divs.yAxisDropZone){
    		this.divs.yAxisDropZone.updatePlaceholder();
    	}
		if (this.controls && this.controls.yControl) {
			this.controls.yControl.updateController(this.parameters.y);
		}
    };
    
    
    raTableBasePrototype.handleRefreshAfterDrop = function() {
        this.hideDropZones();
        this.renderChart();        
    };

    raTableBasePrototype.hideDropZones = function() {
        // validateRender is now being sent to the dropzones and called
        // there when hidePlaceholder is called
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
    };
    
    raTableBasePrototype.restore = function(configuration) { 
        if(typeof configuration.chartSettings !== 'undefined' && typeof this.restoreChartSettings === 'function') {
            this.restoreChartSettings(configuration.chartSettings);
        }             
        this.renderChart(configuration);
    };
    
    Polymer(raTableBasePrototype); 
    GLOBAL.DS.RAComponents.ratablebase = raTableBasePrototype;
})(this);
