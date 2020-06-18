(function(GLOBAL) {

    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;
    
    
    if (typeof GLOBAL.DS.RAComponents.pcdchart !== 'undefined') {
        return;
    }

    var avsChartPrototype = {
        is: 'ra-pcdchart',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase]
    };
    
    

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.createdCallback.call(this);
 
        this.divs.root.removeChild(this.divs.yAxisDropZone);       
        this.divs.root.removeChild(this.divs.constraintDropZone);
        this.divs.root.removeChild(this.divs.colorDropZone);
        this.divs.root.removeChild(this.divs.sizeDropZone);
        this.divs.root.removeChild(this.divs.labelDropZone);
        
        this.selectionEventData = {};
        
        // when filters are applied, filtered alternatives are not displayed hence the index of alternative on chart is 
        // not same as index on servant, this map is useful in finding corresponding indexes
        this.servantIndexToChartIndexMap = new Map();
        this.chartIndexToServantIndexMap = new Map();
                
        
    };
    
    avsChartPrototype.getDefaultXAxisLabel = function() {
        return NLSUtils.translate('Dimensions');
    };
    
    
    avsChartPrototype.getChartSettings = function(data) {
    };
    
    avsChartPrototype.restoreChartSettings = function(chartSettings) {
    };
    
     avsChartPrototype.addXAxis = function() {
        
        var that = this;
        
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

        this.divs.xAxisDropZone.setPlaceholderText(function() {        
            return that._getDisplayTextForParameter(that.parameters.x, that.getDefaultXAxisLabel());
        });
        
        
        this.divs.xAxisDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateXData.bind(this));
        paramHandler.setDropListener(this.xAxisDropListner.bind(this));

        this.divs.xAxisDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.xAxisDropZone);
    };
    
     avsChartPrototype.xAxisDropListner = function(param) {
        // add x-axis parameter source as the dataset id
        this.requestObject.datasetId = param.source;
        this.addXParameter(param.properties);
        this.controls.xControl.updateController(this.parameters.x);

         this.handleRefreshAfterDrop();
    };
    
    avsChartPrototype.validateXData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
                
        for( var paramIndex = 0; paramIndex < this.parameters.x.length; ++paramIndex){
            if(data.properties.ID === this.parameters.x[paramIndex].ID){
                return false;
            }
        }        
        
        return true;
    };
    
     avsChartPrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.avsdropchartbase.renderControlPanel.call(
            this,
            panel
        );

        // Modify param panels
        this.controls.xControl.nParameters(25);
        
        this.controls.xControl.setChangeListener(
                function(params) {
                    this.setXParameter(params);
                    this.hideDropZones();
                    this.renderChart();
                }.bind(this)
         );         
        
    };
    
    avsChartPrototype.placeholderFilter = function() {
        // this function is used to show or hide axis drop zone. 
        if(this.validateRender() ){ 
            return false;
        }else{
            return true;
        }
            
    };
    
    avsChartPrototype.getXAxisDefaultParameter = function() {
        return [];
    };
    
     avsChartPrototype.addXParameter = function(parameter) {
        
        if (
            this.parameters.x.length <
            this.controls.xControl.getNParameters()
        ) {
                this.parameters.x.push(parameter);
        } else {
             // Replace last parameter
            this.parameters.x.splice(-1, 1, parameter);
        }
         
        this.divs.xAxisDropZone.updatePlaceholder();
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
        
        
    avsChartPrototype.validateRender = function() {
        if (!(this.parameters.x.length > 1 )) {
            return false;
        }        
        return true;
    };
    
    avsChartPrototype.notifySelectionEvent = function(data){
        this.chartParent.propagateChartEvent(this.selectionEventData,[this]);  
        return;            
    }
    
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
        
            that.propagateChartEvent({ eventType: 'mask' });
            this.hideDropZones();
            this.updateSize(configuration);
             
            var inputIdList = [];
            for (var i = 0; i < this.parameters.x.length; i++) {                    
                inputIdList.push(this.parameters.x[i].id);
            }
            inputIdList.push('GRADING');
            
            this.datasetId = this.parameters.x.source;
            this.performanceMarkers = {};
            this.performanceMarkers.beforeGetParameterData =  Date.now();
            this.dataProvider.getParametersData(this.datasetId, inputIdList, this.createPcpChart.bind(this));                
        }
        
        return;
    };
    
    avsChartPrototype.loadPlotlyLibrary = function() {
        return new Promise(function(resolve, reject){
            require(['DS/WebappsUtils/WebappsUtils'], 
                function (WebappsUtils){
                    var proxifiedURL = WebappsUtils.getProxifiedWebappsBaseUrl() ;
                    var plotlyURI = proxifiedURL + 'PlotlyJS-1.46.1/plotly.min.js' ;
                    if( plotlyURI.indexOf( '?' ) > -1 ) {
                        plotlyURI = plotlyURI.substring( 0, plotlyURI.indexOf( '?' ) );
                    }
    
                   
                    
                    require([plotlyURI], 
                        function (Plotly) {                            
                            resolve(Plotly);
                    });
            });
        });
    }
      
    avsChartPrototype.resize = function() {
                 
        var that = this;  
        var update = {
            width: this.getChartAreaWidth(),
            height: this.getChartAreaHeight()    
        };
    
        this.loadPlotlyLibrary().then(
            function (Plotly) {   
                Plotly.relayout(that.chartId, update)
            });   
    };
         
    avsChartPrototype.createPcpChart = function(data){
    
        var that = this;    
        this.performanceMarkers.afterGetPArameterData =  Date.now(); 
        
        if (this.avsDropChart === null) {
            this.avsDropChart = document.createElement('ra-chart');            
            this.avsDropChart.chartParent = this;
            this.avsDropChart.id = this.chartId;
            this.divs.chartDropZone.appendChild(this.avsDropChart);
        }
   
        var paramsData = JSON.parse(data);
        
        this.servantIndexToChartIndexMap.clear();
        this.chartIndexToServantIndexMap.clear();
    
    
        var colorCode = [];                
                
        var dataLength = paramsData['GRADING'].length;
        var filteredData = [];
        for (var dimIndex = 0; dimIndex < this.parameters.x.length; dimIndex++) {
            filteredData[this.parameters.x[dimIndex].id] = [];
        }  
        
        var chartIndex = 0;
        for(var index = 0; index < dataLength; ++index){
            
            var hasNullData = false;
            
            for (var dimIndex = 0; dimIndex < this.parameters.x.length; dimIndex++) {
                if(paramsData[this.parameters.x[dimIndex].id][index] === null){
                    hasNullData = true;
                    break;
                }
            }
             
            if(hasNullData){
                continue;
            }else{
                for (var dimIndex = 0; dimIndex < this.parameters.x.length; dimIndex++) {
                    filteredData[this.parameters.x[dimIndex].id].push(paramsData[this.parameters.x[dimIndex].id][index]);
                }                
                this.servantIndexToChartIndexMap.set(index, chartIndex);
                this.chartIndexToServantIndexMap.set(chartIndex, index);
                ++chartIndex;
            }
            
            var curGrading = paramsData['GRADING'][index];
            if(curGrading === 'Best'){
                colorCode.push(0);            
            }else if(curGrading === 'Dominated'){
                colorCode.push(1);
            }else if(curGrading === 'Infeasible'){
                colorCode.push(2);
            }else if(curGrading === 'Excluded'){
                colorCode.push(3);
            }else{
                // what happens if it is none of above?? for time being let's make it zero
                colorCode.push(0);     
            }        
        }
        // datalength might have changed due to filtering
        dataLength = colorCode.length;
                
        var trace = {
            type: 'parcoords',
            opacity: 0.1,
            line: {
                color: colorCode,
                colorscale: [[0, '#59ff59'], [0.25, '#59ff59'],[0.26, '#b2f0f1'],[0.50, '#b2f0f1'],[0.51, '#ff5959'], [0.75, '#ff5959'],[0.76, '#a5a5a5'],[1, '#a5a5a5']],
                showscale: false,            
                cmin: 0,
                cmax: 3,
                colorbar: {
                        tickmode: "array",
                        tickvals: [0,1,2,3],
                        ticktext: ["Best","Dominated","Infeasible","Excluded"]
                 }
                   
            },  
            dimensions: []
        };

        for (var i = 0; i < this.parameters.x.length; i++) {        
            var dataValues = [];
            var tickValues = [];
            if(this.parameters.x[i].dataType === 'STRING'){
                var discreteSrings = this.parameters.x[i].stringSortedByFreqs;
                for(var index = 0; index < dataLength; ++index){
                    dataValues.push(discreteSrings.indexOf(filteredData[this.parameters.x[i].id][index]));
                    tickValues.push(index);
                }
            }else{
                dataValues = filteredData[this.parameters.x[i].id];
            }
        
            var dimensionData = {
                label:  decodeURIComponent(
                            this.parameters.x[i].displayName ||
                            this.parameters.x[i].name
                        ),
                multiselect: true,
                values: dataValues,
                id: this.parameters.x[i].id,
                constraintrange: []
                
            };
        
            if(this.parameters.x[i].dataType === 'STRING'){
                dimensionData['tickvals'] = tickValues;
                dimensionData['ticktext'] = this.parameters.x[i].stringSortedByFreqs;
            }                    
            trace.dimensions.push(dimensionData);
        }
    
        
    
        var layout = {
            width: this.getChartAreaWidth(),
            height: this.getChartAreaHeight(),
            margin: { l:40,
                        r:40,
                        b: 40,
                        t: 40
                    }        
        };

        
        this.getSelectedPoints().then(function(seelctionData){
            var selectedData = JSON.parse(seelctionData);
            for(var servantPointIndex = 0; servantPointIndex < selectedData.length;++servantPointIndex){
                if(selectedData[servantPointIndex] == 1){
                    var chartIndex = that.servantIndexToChartIndexMap.get(servantPointIndex);
                    trace.dimensions.forEach(function(dimension){
                        var data = dimension.values[chartIndex];
                        dimension.constraintrange.push([data,data]);
                    });
                }                
            }
            var data = [trace];
            that.loadPlotlyLibrary().then(
                function (Plotly) {
                    that.performanceMarkers.beforePlotlyChart =  Date.now();                
                    Plotly.plot(that.chartId, data, layout, {displayModeBar: false}).
                        then(function(){
                            that.performanceMarkers.afterPlotlyChart =  Date.now();
                            that.propagateChartEvent({ eventType: 'unmask' });
                            
                            console.log('Time to get parameter data : ' +  (that.performanceMarkers.afterGetPArameterData - that.performanceMarkers.beforeGetParameterData));
                            console.log('Time to process data : ' +  (that.performanceMarkers.beforePlotlyChart - that.performanceMarkers.afterGetPArameterData));
                            console.log('Time to plot plotly : ' +  (that.performanceMarkers.afterPlotlyChart  - that.performanceMarkers.beforePlotlyChart));
                            console.log('Total Time : ' +  (that.performanceMarkers.afterPlotlyChart  - that.performanceMarkers.beforeGetParameterData));
                            
                            that.avsDropChart.on('plotly_restyle', function(eventData) {                    
                                if(eventData[0].dimensions !== undefined){
                                    // this is a column reorder event
                                    var index = 0;
                                    for(index = 0; index < eventData[0].dimensions[0].length; ++index){
                                        var searchid = eventData[0].dimensions[0][index].id;
                                        for(var parIndex = index; parIndex < this.parameters.x.length;++parIndex){
                                            if (this.parameters.x[parIndex].id === searchid){
                                                // we need to exchange the order
                                                var temp = this.parameters.x[index];
                                                this.parameters.x[index] = this.parameters.x[parIndex];
                                                this.parameters.x[parIndex] = temp;
                                                break;
                                            }
                                        }                
                                    }
                                    this.chartParent.updateChartsConfigPreference(this.chartId);  
                                }else{
                                    // this is a filter selection event
                                    // find all selected points, ideally plotly should give this
                                    // it does not have capability to do 
                                    // https://github.com/plotly/react-plotly.js/issues/66 , 
                                    // we will have to find out these points using real data and filters
                                    var hasFilters = false;
                                    this.avsDropChart.data[0].dimensions.forEach(function(dimension){
                                        if( dimension['constraintrange'] !== undefined && dimension['constraintrange'].length !== 0){
                                            hasFilters = true;                       
                                        }
                                    });
                                    var selectedIndexes = [];
                                    var dataLength = this.avsDropChart.data[0].dimensions[0].values.length;
                        
                                    if(hasFilters){                           
                                        for(var index = 0; index < dataLength;++index){
                                            var allDimensionsAreSatisfied = true;
                                            this.avsDropChart.data[0].dimensions.forEach(function(dimension){
                                                var meetsAtLeastOneConstraints = false;
                                                if(dimension['constraintrange'] !== undefined &&  dimension['constraintrange'].length !== 0){                                        
                                                    var dimConstraintRange =   dimension['constraintrange'];
                                                    // if constraint range is not array of array, we need to make it
                                                    if(!Array.isArray(dimension['constraintrange'][0])){
                                                        dimConstraintRange = [dimension['constraintrange']];
                                                    }                                  
                                                    dimConstraintRange.forEach(function(constrintRange){
                                                        if( dimension.values[index] >= constrintRange[0] &&  dimension.values[index] <= constrintRange[1]){
                                                            meetsAtLeastOneConstraints = true; 
                                                        }
                                                    });
                                                }else{
                                                    // there are no constraints, so  all are valid
                                                    meetsAtLeastOneConstraints = true;
                                                }
                                        
                                                if(meetsAtLeastOneConstraints === false){
                                                    allDimensionsAreSatisfied = false;
                                                }
                                            });
                                            if(allDimensionsAreSatisfied === true){
                                                selectedIndexes.push(this.chartIndexToServantIndexMap.get(index));
                                            }                                
                                        }
                                    }
                                                     
                                    that.selectionEventData.eventType = 'selection';
                                    that.selectionEventData.allSelectedRowIndices = selectedIndexes;
                                    that.selectionEventData.numRowsRaw = dataLength;
                                    that.selectionEventData.numRowsSelected = 1; // probably not used??
                            
                                    // this is used to diplay alternative name in more info panel which should be last
                                    // selection info, we do not know which is last selected, lets use 0 th selected row
                                    that.selectionEventData.selectedRawRowIndices = [];
                                    if(selectedIndexes.length > 0){
                                        that.selectionEventData.selectedRawRowIndices.push(selectedIndexes[0]);
                                    }                                                                
                                    that.dataProvider.setSelectionPoints(that.datasetId, selectedIndexes, that.notifySelectionEvent.bind(that));
                                }
                            }.bind(that));
                    });
            });                        
        });                
        return; 
    };

    avsChartPrototype.getSelectedPoints = function(){    
        var that = this;
        return new Promise(function(resolve, reject){            
            that.dataProvider.getSelectionFlagColumn(that.datasetId, function(data){resolve(data);});
        });
    };
    


    
    avsChartPrototype.handleSelectionEvent = function(selectionArgs){
        var that = this;
               
        if(this.plotlychart !== null){
            this.avsDropChart.data[0].dimensions.forEach(function(dimension){
                dimension['constraintrange']=[];
            });
            
            for ( var index = 0; index < selectionArgs.allSelectedRowIndices.length;++index){
                var selectedIndex = this.servantIndexToChartIndexMap.get(selectionArgs.allSelectedRowIndices[index]);
                this.avsDropChart.data[0].dimensions.forEach(function(dimension){
                            var data = dimension.values[selectedIndex];
                            dimension.constraintrange.push([data,data]);
                        }                
                );
                
                
            }
            
            this.loadPlotlyLibrary().then(
            function (Plotly) {
                Plotly.update(that.chartId,that.avsDropChart.data, that.avsDropChart.layout);
            });
        }
    
    };
    
    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.pcdchart = avsChartPrototype;
})(this);
