(function(GLOBAL) {

    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;
    
    
    if (typeof GLOBAL.DS.RAComponents.avscapabilitychart !== 'undefined') {
        return;
    }

    var avsChartPrototype = {
        is: 'ra-avscapabilitychart',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase]
    };
    
    

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.createdCallback.call(this);

        this.divs.root.removeChild(this.divs.yAxisDropZone);        
        this.divs.root.removeChild(this.divs.xAxisDropZone);
        this.divs.root.removeChild(this.divs.colorDropZone);
        this.divs.root.removeChild(this.divs.sizeDropZone);
        this.divs.root.removeChild(this.divs.labelDropZone);
        
        this.divs.paramDropZones = {};
        this.boxChart = null;
        this.datasetId = null;
        
        this.selectionEventData = {};
        
        // when filters are applied, filtered alternatives are not displayed hence the index of alternative on chart is 
        // not same as index on servant, this map is useful in finding corresponding indexes
        this.servantIndexToChartBoxIndexMap = new Map();
        this.chartBoxIndexToServantIndexMap = new Map();
        
        this.chartCapabilityParameters = [            
            {'type': 'mean', 'text': NLSUtils.translate('MEAN'), 'className': 'avsDropChart-baseDropZone avsDropChart-meanDropZone'},
            {'type': 'std dev', 'text': NLSUtils.translate('STD_DEV'), 'className': 'avsDropChart-baseDropZone avsDropChart-stdDevDropZone'},
            {'type': 'min', 'text': NLSUtils.translate('MIN'), 'className': 'avsDropChart-baseDropZone avsDropChart-minDropZone'},
            {'type': 'max', 'text': NLSUtils.translate('MAX'), 'className': 'avsDropChart-baseDropZone avsDropChart-maxDropZone'}
    	];
        
        

        for(var dimIndex = 0; dimIndex <  this.chartCapabilityParameters.length;++dimIndex){
            var dimObject = this.chartCapabilityParameters[dimIndex];
            this.addParamDropZone(dimObject);
        } 
            
    };
    
    avsChartPrototype.getChartSettings = function(data) {
        
    
    };
    
    avsChartPrototype.restoreChartSettings = function(chartSettings) {
        
    };
    

    avsChartPrototype.capabilityChartParamValidater = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        
       
        return true;
    };
    
    avsChartPrototype.paramDropHandler = function(paramType, param) {

        this.parameters[paramType] = param;
        
        this.updateStylePanel();
        this.divs.paramDropZones[paramType].updatePlaceholder();
        
        if(this.parameters[paramType] !== null){
        
            this.controls.paramControls[paramType].updateController(
                [ this.parameters[paramType]]);
        }
        
        this.handleRefreshAfterDrop();
        
        return true;
    };
    
     avsChartPrototype.parameterChangeHandler = function(newParameterMap, parameterChanged){
    
    	for(var paramIndex = 0; paramIndex <  this.chartCapabilityParameters.length;++paramIndex){
    		var paramType = this.chartCapabilityParameters[paramIndex].type;
            var param = this.parameters[paramType];            
            if (
            	typeof param !== 'undefined' &&
            	param !== null ) 
            {
        	 	var parLookup = newParameterMap.get(param.id);
            	if (parLookup !== undefined) {
            	
            		if (param.displayName !== parLookup.displayName) {
            		 	parameterChanged.parChgResult = true;
                    	param.displayName = parLookup.displayName;
                    	this.controls.paramControls[paramType].updateController([param]);
                    	this.divs.paramDropZones[paramType].updatePlaceholder();
            		}
            	}else{
            		parameterChanged.parDelResult = true;
            	}        	 	
        	}          
        }
            
    };
    
    
    avsChartPrototype.parameterDeleteHandler = function(deletedParamId, parameterDeleted){
    
     
    	for(var paramIndex = 0; paramIndex <  this.chartCapabilityParameters.length;++paramIndex){
    		var paramType = this.chartCapabilityParameters[paramIndex].type;
            var param = this.parameters[paramType];
            if (
            	typeof param !== 'undefined' &&
            	param !== null &&
            	param.id === deletedParamId
        	) {
        	 	this.parameters[paramType] = null;
        	 	
            	this.controls.paramControls[paramType].removeParameter(param);            	
            	
            	this.divs.paramDropZones[paramType].updatePlaceholder();
            	
            	parameterDeleted.parDelResult = true;
        	}          
        }
            
    };
    
    
    avsChartPrototype.addParamDropZone = function(praramDetails) {
        var that = this;                
         
        var paramDropZone = document.createElement('ra-chartdroptarget');
        this.divs.paramDropZones[praramDetails.type] = paramDropZone;
        
        paramDropZone.setAttribute('data-paramType', praramDetails.type);
        
        var classes = praramDetails.className.split(" ");
        classes.forEach(function(iClass){        
        	paramDropZone.classList.add(iClass);
        });
        
        paramDropZone.setDragEnterListener(
            paramDropZone.showPlaceholder
        );
        paramDropZone.setDragLeaveListener(
            paramDropZone.hidePlaceholder
        );

        paramDropZone.showPlaceholder();
        paramDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        paramDropZone.setPlaceholderText(function() {
        
            var curParamType = this.getAttribute('data-paramType');
            
            if (
                typeof that.parameters[curParamType] !== 'undefined' &&
                that.parameters[curParamType] !== null
            ) {
                return String(
                    decodeURIComponent(
                        that.parameters[curParamType].displayName ||
                            that.parameters[curParamType].name
                    )
                );
            } else {
                return praramDetails.text;
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.capabilityChartParamValidater);
        paramHandler.setAttribute('data-paramType', praramDetails.type);
        
        paramHandler.setDropListener(function(param) {
            param.properties ? (param = param.properties) : null;
            var curParamType = this.getAttribute('data-paramType');
            that.paramDropHandler(curParamType, param);
        });

        paramDropZone.appendChild(paramHandler);
        this.divs.root.appendChild(paramDropZone);
    };
    
    avsChartPrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.avsdropchartbase.renderControlPanel.call(
            this,
            panel
        );
        
        this.controls.paramControls = {};
        
        var that = this;               
        var dimensions = this.chartProperties.uiprops.dimensions;
        
        var chartCapabilityDimensions = [
            {'type': 'mean', 'title': NLSUtils.translate('MEAN'),  'iconClass': 'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-stat-mean'},
            {'type': 'std dev', 'title': NLSUtils.translate('STD_DEV'), 'iconClass': 'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-stat-standard-deviation'},            
            {'type': 'min', 'title': NLSUtils.translate('MIN'),  'iconClass': 'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-move-to-bottom'},
            {'type': 'max', 'title': NLSUtils.translate('MAX'),  'iconClass': 'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-move-to-top'}
        ]; 
        
        for(var dimIndex = 0; dimIndex <  chartCapabilityDimensions.length;++dimIndex){
            var dimObject = chartCapabilityDimensions[dimIndex];
            
            var configDim = this.findDimension(dimensions, dimObject.type);
            if (typeof configDim !== 'undefined') {
                var paramControl = panel.getControl(configDim.uipanel);
                paramControl.title(dimObject.type);
                paramControl.nParameters(1);
                paramControl.setFilter(this.capabilityChartParamValidater);
             
                paramControl.setChangeListener(function(params) {
                   that.paramDropHandler(this._title, params.length == 0 ? null : params[0]);
                });
                
                if (typeof this.parameters[dimObject.type] !== 'undefined' && 
                    this.parameters[dimObject.type] !== null) {                
                    paramControl.updateController(
                        [this.parameters[dimObject.type]]
                    );
                }
            
                var paramIcon = paramControl.querySelector(
                        '.controlIcon'
                    );
                if (paramIcon !== null) {
                	var icons = dimObject.iconClass.split(" ");
                	
                	icons.forEach(function(icon) {
  						paramIcon.classList.add(icon);
					});
					
                    
                    paramIcon.setAttribute(
                        'title',
                        dimObject.title
                    );
                }
                this.controls.paramControls[dimObject.type] = paramControl;
            
            }   
        }
    };
    
    avsChartPrototype.placeholderFilter = function() {
        // this function is used to show or hide axis drop zone. 
        if(this.validateRender() ){ 
            return false;
        }else{
            return true;
        }
            
    };
        
    avsChartPrototype.validateRender = function() {
    
        if( typeof this.parameters['std dev'] !== 'undefined' && 
                this.parameters['std dev'] !== null &&
                typeof this.parameters['mean'] !== 'undefined' &&
                this.parameters['mean'] !== null ){
            return true;
        }        
        return false;
    };

    avsChartPrototype.renderChart = function(configuration) {
        var that = this;
        
        // if configuration is undefined then its not restore and there is some change in chart 
        // e.g parameter drop, resize or param delete, must store it to widget prefer temp storage
        if(configuration === undefined){
            this.chartParent.updateChartsConfigPreference(this.chartId);            
        }
        

        
        this.configuration = configuration;
        
        if(this.avsDropChart !== null){
            this.divs.chartDropZone.removeChild(this.avsDropChart);
            delete this.avsDropChart;
            this.avsDropChart = null;
        } 
        
             
        if (this.validateRender() === false) {
            
        } else {
            this.hideDropZones();
            this.updateSize(configuration);
             
            var inputIdList = [];
            inputIdList.push(this.parameters['std dev'].id);
            inputIdList.push(this.parameters['mean'].id);
            
            if( typeof this.parameters['min'] !== 'undefined' && 
                this.parameters['min'] !== null){
                inputIdList.push(this.parameters['min'].id);
            }
            
            if( typeof this.parameters['max'] !== 'undefined' && 
                this.parameters['max'] !== null){
                inputIdList.push(this.parameters['max'].id);
            }
            
            this.datasetId = this.parameters['std dev'].source;
        
            this.dataProvider.getParametersData(this.datasetId, inputIdList, this.createBoxChart.bind(this));                
        }
        
        return;
    };
    
    avsChartPrototype.selectionData = function(data){
    
        if(this.boxChart !== null){
            var selectedData = JSON.parse(data);
            for(var servantPointIndex = 0; servantPointIndex < selectedData.length;++servantPointIndex){
                var chartBoxIndex = this.servantIndexToChartBoxIndexMap.get(servantPointIndex);
                if(chartBoxIndex !== undefined){
                    if(selectedData[servantPointIndex] === 1){                    
                        this.updateColor(this.boxChart.series[0].data[chartBoxIndex], true);
                        this.boxChart.series[0].data[chartBoxIndex].selected = true;                        
                    }else{                    
                        this.updateColor(this.boxChart.series[0].data[chartBoxIndex], false);
                        this.boxChart.series[0].data[chartBoxIndex].selected = false;
                    }
                }    
            }
        }
        
    };
    
    avsChartPrototype.handleSelectionEvent = function(selectionArgs){
    
         if(this.boxChart !== null){
            
            for(var pointIndex = 0; pointIndex < selectionArgs.numRowsRaw;++pointIndex){
            
                var servantPointIndex = this.chartBoxIndexToServantIndexMap.get(pointIndex);
                if(selectionArgs.allSelectedRowIndices.indexOf(servantPointIndex) !== -1){
                    this.updateColor(this.boxChart.series[0].data[pointIndex], true);
                    this.boxChart.series[0].data[pointIndex].selected = true;
                    
                }else{
                    this.updateColor(this.boxChart.series[0].data[pointIndex], false);
                    this.boxChart.series[0].data[pointIndex].selected = false;
                    
                }    
            }
        }
    
    };
    
    avsChartPrototype.selectPoints = function(){    
        this.dataProvider.getSelectionFlagColumn(this.datasetId, this.selectionData.bind(this));
    };
    
    avsChartPrototype.notifySelectionEvent = function(data){
        this.chartParent.propagateChartEvent(this.selectionEventData,[this]);              
    }
    
     avsChartPrototype.updateColor = function(point, selected){
        var series = point.series,
                seriesOptions = series.options,
                seriesStates = seriesOptions.states,
                stem = point.stem,
                box = point.box,
                whiskers = point.whiskers,
                medianShape = point.medianShape;
    
            var selectedStroke = seriesStates.select
                ? seriesStates.select.color
                : null;
            var stroke = selected
                ? selectedStroke
                : point.color || series.color;
    
            stem.attr({ 'stroke': stroke });
            box.attr({ 'stroke': stroke });
            whiskers.attr({ 'stroke': stroke });
            medianShape.attr({ 'stroke': stroke });    
     };
     
avsChartPrototype.createBoxChart = function(data){
    
    var that = this;    
    
    if (this.avsDropChart === null) {
        this.avsDropChart = document.createElement('ra-chart');            
        this.avsDropChart.chartParent = this;
        this.avsDropChart.id = this.chartId;
        this.divs.chartDropZone.appendChild(this.avsDropChart);
    }
   
    var paramsData = JSON.parse(data);
        
    var meanParamData = paramsData[this.parameters['mean'].id];
    var stdDevParamData = paramsData[this.parameters['std dev'].id];
        
    var minParamData = [];
    var hasMinData = false;
    if (typeof this.parameters['min'] !== 'undefined' && this.parameters['min'] !== null){
        minParamData = paramsData[this.parameters['min'].id];
        hasMinData = true;
    }
             
    var maxParamData = [];
    var hasMaxData = false;
    if (typeof this.parameters['max'] !== 'undefined' && this.parameters['max'] !== null){
        maxParamData = paramsData[this.parameters['max'].id];
        hasMaxData = true;
    }

    var numOfBoxes = meanParamData.length;
        
    var minParamDisplayName = this.parameters['mean'].displayName;
    if(minParamDisplayName.startsWith('Statistics_')){
        minParamDisplayName = minParamDisplayName.substring(11);            
    }
    
    if(minParamDisplayName.endsWith('_Mean')){
        minParamDisplayName = minParamDisplayName.substring(0, minParamDisplayName.length-5);            
    }
        
    minParamDisplayName = decodeURIComponent(minParamDisplayName);
        
    var colorBox = function(point, selected, capabilityChart) {
        capabilityChart.updateColor(point, selected);  
    };


    var chartRequest = {
        chart: {
            type: 'boxplot',
            height: this.requestObject.chartRequest.height -5,
            width:  this.requestObject.chartRequest.width - 5 
        },
   
        legend: {
            enabled: false
        },
        scrollbar: {
            enabled: true
        }, 
        exporting: { enabled: false },
        credits: { enabled: false },
        tooltip: { enabled: false },
        plotOptions: {
            boxplot: {
                allowPointSelect: true,
                point: {
                    events: {
                        select: function(event) {
                            colorBox(this, true, that);                                    
                        },
                        unselect: function(event) {
                            colorBox(this, false, that);
                        },
                        click: function(event){
                            if(this.selected && event.ctrlKey === false){
                                return false;
                            }else{
                                // get selected index from category label, as this.index will not match the index use by servant
                                // if some points are filtered, we need to find a better way to do this
                                var currentPointServantIndex = that.chartBoxIndexToServantIndexMap.get(this.index);
                                var finalSelectedPoints = [];
                                        
                                // if cntrl key is not pressed then we are selecting this point,
                                // and unselecting other points
                                if(event.ctrlKey === false){
                                    finalSelectedPoints.push(currentPointServantIndex);
                                }else{
                                    for(var index = 0; index < this.series.points.length;++index){
                                        if (this.series.points[index].selected === true){
                                            var servantPointIndex = that.chartBoxIndexToServantIndexMap.get(index);
                                            finalSelectedPoints.push(servantPointIndex);
                                        }
                                    }
                                    
                                    // if this point is already selected and cntrl key is pressed, it means 
                                    // this is unselect to this point else this point is added to selected points list
                                    if( this.selected === false){   
                                        finalSelectedPoints.push(currentPointServantIndex);
                                    }else{
                                        //this is unselect. remove from current selection
                                        var indexToRemove = finalSelectedPoints.indexOf(currentPointServantIndex);
                                        if (indexToRemove > -1) {
                                            finalSelectedPoints.splice(indexToRemove, 1);
                                        }       
                                    }
                                }
                            
                                // we need to inform servant about current selection and propagate selection event to
                                // other charts
                                finalSelectedPoints.sort();
                            
                                that.selectionEventData.eventType = 'selection';
                                that.selectionEventData.allSelectedRowIndices = finalSelectedPoints;
                                that.selectionEventData.numRowsRaw = this.series.points.length;
                                that.selectionEventData.numRowsSelected = 1;
                                that.selectionEventData.selectedRawRowIndices = [];
                                that.selectionEventData.selectedRawRowIndices.push(currentPointServantIndex);
                                                                
                                that.dataProvider.setSelectionPoints(that.datasetId, finalSelectedPoints, that.notifySelectionEvent.bind(that));                                        
                            }                                        
                        } //click                                
                    } //events
                }, //point
                states: {
                    select: {                                
                        enabled: true
                    }
                }
            } //boxplot
        },//plotOptions
        title: {
            text: ''
        },
        xAxis: {
            categories: [],
            title: {
                text: NLSUtils.translate('CAPABILITY_CHART_X_AXIS_LABEL')
            }           
        },
        yAxis: [
                {
                    title: {
                        text: minParamDisplayName
                    },
                    lineWidth: 1,                    
                    plotLines: []
                },
                {
                    title: {
                        text: ''
                    },
                    opposite: true,
                    lineWidth: 1            
                }],
        series: [{
                    name: minParamDisplayName,                    
                    data: [],
                    tooltip: {
                        headerFormat: '<em>Alternative {point.key}</em><br/>'
                    }
                }]
    };
    
    chartRequest.series.color =  this.chartProperties.defaults[0].seriesColor;
    chartRequest.plotOptions.boxplot.states.select.color = this.chartProperties.defaults[0].selectedColor;
            
    this.servantIndexToChartBoxIndexMap.clear();
    this.chartBoxIndexToServantIndexMap.clear();
    var chartBoxIndex = 0;
    var MAX_SUPPORTED_BOXES = 1000;
    var displayMaxBoxMessage = false;
    for (var boxIndex = 0; boxIndex < numOfBoxes; ++boxIndex){
        var stdDevData = stdDevParamData[boxIndex];
        var meanData = meanParamData[boxIndex];
        
        if(stdDevData === null || meanData === null){
            continue;
        }
        
        if(chartBoxIndex >= MAX_SUPPORTED_BOXES){
            displayMaxBoxMessage = true;
            break;
        } 
        
        chartRequest.xAxis.categories.push((boxIndex +1).toString());
        this.servantIndexToChartBoxIndexMap.set(boxIndex, chartBoxIndex);
        this.chartBoxIndexToServantIndexMap.set(chartBoxIndex, boxIndex );
        ++chartBoxIndex;
            
        var seriesData = [];
                
        // below order is important
            
        // if min is present use it else use Mean - 3*std dev
        if(hasMinData === true){
            seriesData.push(minParamData[boxIndex]);
        }else{
            seriesData.push(meanData - (3*stdDevData));
        }
            
        // lower qurtile (mean- std_dev for time being)
        seriesData.push(meanData - stdDevData);
        //mean
        seriesData.push(meanData);
                
        // upper qurtile (mean+ std_dev for time being)
        seriesData.push(meanData + stdDevData);
            
        // if max is present use it else use Mean + 3*std dev
        if(hasMaxData === true){
            seriesData.push(maxParamData[boxIndex]);
        }else{
            seriesData.push(meanData + (3*stdDevData));
        }          
        
        chartRequest.series[0].data.push(seriesData);
          
    }
    
    var activeBoxes = chartRequest.series[0].data.length;
            
            
    var pixelPerActiveBox =  chartRequest.chart.width / activeBoxes;
            
    if(pixelPerActiveBox < 20.0){        
        chartRequest.chart.height = this.requestObject.chartRequest.height -20,
        chartRequest.chart["scrollablePlotArea"] = {
            'minWidth': (activeBoxes * 20)+ 400,
            'scrollPositionX': 0
        };
    }
    
    
    this.loadHighChartsLibrary().then(function(Highcharts){               
        that.boxChart = new Highcharts.chart(that.chartId, chartRequest);
        
        // add constriants if present
        if(that.parameters.constraints !== null){
            var extremes = that.boxChart.yAxis[0].getExtremes();
            var maxY = extremes.max;
            var minY = extremes.min;
        
            for(var constraintIndex = 0; constraintIndex < that.parameters.constraints.length; ++constraintIndex){
                var curConstriant = that.parameters.constraints[constraintIndex];
                
                var constraintObject = Object.assign({}, that.chartProperties.defaults[0].constraint);
                
                if(curConstriant.properties.type === 'GREATER_THAN'){
                    constraintObject.from = minY;
                    constraintObject.to = curConstriant.properties.boundValue;
                    that.boxChart.yAxis[0].addPlotBand(constraintObject);
                }else if (curConstriant.properties.type === 'LESS_THAN'){
                    constraintObject.from = curConstriant.properties.boundValue;
                    constraintObject.to = maxY;
                    that.boxChart.yAxis[0].addPlotBand(constraintObject);
                }                                        
                
            }
        }
        
        that.selectPoints();
            
        if(displayMaxBoxMessage === true)
        {
            var warningElement = document.createElement('div');
            	
            warningElement.classList.add('chart-warning');
            warningElement.classList.add('wux-notification-container');            	
            	
            warningElement.innerHTML += NLSUtils.translate('Maximum 1000 alternatives are supported, displaying first 1000 alternatives.');
            warningElement.setAttribute('notification-level', 'warning');
            	
            that.avsDropChart.appendChild(warningElement);
        		
        	var warningCloseButton = document.createElement('button');
            warningCloseButton.classList.add('wux-notification-close');
            warningCloseButton.classList.add('wux-ui-fa');
            warningCloseButton.classList.add('wux-ui-fa-times');
            warningCloseButton.onclick = function(){
                this.parentNode.parentNode.removeChild(this.parentNode);
                return false;
            };            
            warningElement.appendChild(warningCloseButton);                
        }        
    });
    return; 
};
    
    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avscapabilitychart = avsChartPrototype;
})(this);
