(function(GLOBAL) {

    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;
    
    
    if (typeof GLOBAL.DS.RAComponents.avsparettochart !== 'undefined') {
        return;
    }

    var avsChartPrototype = {
        is: 'ra-avsparettochart',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.createdCallback.call(this);


        this.divs.root.removeChild(this.divs.constraintDropZone);
        this.divs.root.removeChild(this.divs.colorDropZone);
        this.divs.root.removeChild(this.divs.sizeDropZone);
        this.divs.root.removeChild(this.divs.labelDropZone);
    
    
        this.runButtonDisabledFlag = true;
        this.coefficientData = [];
        this.variablesMap = {};
        
        this.showResponseAsPercentage = true; 
        this.hideInsignificantFactors = true;
        
        this.addRunButton();
    };
    
    avsChartPrototype.getChartSettings = function(data) {
        return { 'showResponseAsPercentage': this.showResponseAsPercentage , 'hideInsignificantFactors': this.hideInsignificantFactors};
    
    };
    
    avsChartPrototype.restoreChartSettings = function(chartSettings) {
        if(chartSettings.showResponseAsPercentage !== undefined){
            this.showResponseAsPercentage = chartSettings.showResponseAsPercentage;
            if(this.percentaageSettingsButton !== undefined){
                this.percentaageSettingsButton.setCheck(this.showResponseAsPercentage);
            }
        }
        
        if(chartSettings.hideInsignificantFactors !== undefined){
            this.hideInsignificantFactors = chartSettings.hideInsignificantFactors;
            if(this.insignificantFactorsSettingsButton !== undefined){
                this.insignificantFactorsSettingsButton.setCheck(this.hideInsignificantFactors);
            }
        }
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
            return false;
        }
        
        if (data.properties.role !== 'OUTPUT') {            
            return false;
        }
        
        return true;
    };


    avsChartPrototype.validateXData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        
         // and not discrete
        if (data.properties.dataType === 'STRING') {            
            return false;
        }
        
        if (data.properties.role !== 'INPUT') {            
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
        this.controls.xControl.nParameters(10);
        
        this.controls.xControl.setChangeListener(
                function(params) {
                    this.setXParameter(params);
                    this.hideDropZones();
                    this.renderChart();
                }.bind(this)
         );         
            
        
        this.controls.yControl.nParameters(1);
        
        this.controls.yControl.setShowAxisFilter(true);
        this.controls.yControl.setShowParamFilter(false);
        this.controls.yControl.setShowAggregationType(false);
        
         
        
        var chartSettingsControl = panel.getControl('ra-chartsettingscontrol');
        
        this.percentaageSettingsButton = chartSettingsControl.addCheckBox(
            'percentage', 
            NLSUtils.translate('SHOW_RESPONSE_AS_PERCENT'), 
            this.showResponseAsPercentage
        );
        
        this.percentaageSettingsButton.setUpdateCallback(function(newVal){
            this.showResponseAsPercentage = newVal;
            this.renderChart();
        }.bind(this));
        
        this.insignificantFactorsSettingsButton = chartSettingsControl.addCheckBox(
            'insignificantfactors', 
            NLSUtils.translate('HIDE_INSIGNIFICANT_FACTORS'), 
            this.hideInsignificantFactors
        );
        this.insignificantFactorsSettingsButton.setUpdateCallback(function(newVal){
            this.hideInsignificantFactors = newVal;
            this.renderChart();
        }.bind(this));
    
    };
    
    avsChartPrototype.placeholderFilter = function() {
        // this function is sued to show or hide axis drop zone. in this chart
        // we want to hide axes only when chart is rendered which can be etected by
        // coefficientData length 
        if(this.validateRender() &&  this.coefficientData.length > 0){ 
            return false;
        }else{
            return true;
        }
            
    };
    
    avsChartPrototype.addRunButton = function() {
        var that = this;        
        
        this.divs.runButtonZone = document.createElement('div');
        this.divs.runButtonZone.classList.add('avsDropChart-runDropZone');
        
        //XSS_CHECKED
        require(['DS/Controls/Button'],
                    function(WUXButton){
        				var iconPath = this._3DSpaceURL +
                                '/webapps/SMAAnalyticsWidget/assets/icons/' + 'Pareto_run.png';
                        this.runButton = new WUXButton(
                                            {   icon: iconPath, 
                                                displayStyle: 'normal',                                                
                                                touchMode: true,
                                                disabled: this.runButtonDisabledFlag,                                                
                                                minWidth: 75,
                                                minHeight: 75 
                                            }).inject(this.divs.runButtonZone);
                        this.runButton.addEventListener('buttonclick', function(e){
                            e.preventDefault();
                            e.stopPropagation();
                            this.runApproximationAndPlot();
                        }.bind(this));
                    }.bind(this));
                


        this.divs.root.appendChild(this.divs.runButtonZone);
    };
    
    
    avsChartPrototype.getXAxisDefaultParameter = function() {
        return [];
    };
    
    avsChartPrototype.resetCache = function() {
        this.coefficientData = [];
        this.variablesMap = {};
    };
    

    
    avsChartPrototype.addYParameter = function(parameter) {
    
    if (
        this.parameters.y.length <
        this.controls.yControl.getNParameters()
        ) {
            this.parameters.y.push(parameter);
        } else {
            // Replace last parameter
            this.parameters.y.splice(-1, 1, parameter);
        }
        
        this.resetCache();
        
        this.divs.yAxisDropZone.updatePlaceholder();
        
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
    
    avsChartPrototype.setXParameter = function(parameter) {
        this.parameters.x = parameter;
        this.resetCache();        
        this.divs.xAxisDropZone.updatePlaceholder();
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
        
       this.resetCache();
        
        this.divs.xAxisDropZone.updatePlaceholder();
    };
    
    avsChartPrototype.setYParameters = function(parameters) {
        
        this.parameters.y = parameters;
        this.resetCache();
        this.divs.yAxisDropZone.updatePlaceholder();        
    };
    
    avsChartPrototype.getDefaultXAxisLabel = function() {
        return NLSUtils.translate('FACTORS');
    };
    
    avsChartPrototype.getDefaultYAxisLabel = function() {
        return NLSUtils.translate('RESPONSE');
    };
    
    avsChartPrototype.validateRender = function() {
        if (!(this.parameters.x.length > 0 && this.parameters.y.length > 0)) {
            return false;
        }        
        return true;
    };

    avsChartPrototype.renderChart = function(configuration) {
        var that = this;
        
        // if configuration is undefined then its not restore and there is some change in chart 
        // e.g parameter drop, resize or param delete, must store it to widget prefer temp storage
        if(configuration === undefined){
            this.chartParent.updateChartsConfigPreference(this.chartId);            
        }
        
        this.divs.runButtonZone.style.display = "block";
        
        this.configuration = configuration;
         
        
        // remove previos chart if it exists 
        if (this.avsDropChart !== null) {
            this.divs.chartDropZone.removeChild(this.avsDropChart);
            delete this.avsDropChart;
            this.avsDropChart = null;
        }
        
        if (this.avsDropChart === null) {
                this.avsDropChart = document.createElement('ra-chart');            
                this.avsDropChart.chartParent = this;
                this.avsDropChart.id = this.chartId;
                this.divs.chartDropZone.appendChild(this.avsDropChart);
        }
                 
             
        if (this.validateRender() === false) { 
            // chart is not valid to be rendered yet, disable the run button    
            this.runButtonDisabledFlag = true;            
        } else {
            // if coefficientData is populated then it means approximation is already run, 
            // we just need to render the chart, may be due to resize or some view option change
            if(this.coefficientData.length > 0){
                // disable and hide run button
                this.runButtonDisabledFlag = true;
                this.divs.runButtonZone.style.display = "none";
                this.renderModifiedChart(this.configuration);
                
            }else{
                // chart is valid to be rendered and we need to run approximations, enable the run button
                this.runButtonDisabledFlag = false;
            }
        }
        
        if(typeof this.runButton !== 'undefined'){       
                this.runButton.disabled = this.runButtonDisabledFlag;
        }
        return;
    };
    
    avsChartPrototype.runApproximationAndPlot = function(){
       
       // mask the chart when approximation is running
        this.propagateChartEvent({ eventType: 'mask' });
       
       // hide the run button div  
        this.divs.runButtonZone.style.display = "none";
        
        var inputIdList = [];
        for (var i = 0; i < this.parameters.x.length; i++) {                    
            inputIdList.push(this.parameters.x[i].id);
        }
        
        var outputIdList = [];
        for (var i = 0; i < this.parameters.y.length; i++) {
            outputIdList.push(this.parameters.y[i].id);
        }
        this.dataProvider.executeGenerateApproximations(inputIdList, outputIdList, this.parseCoeffData.bind(this));

    }
          
          
    
    avsChartPrototype.parseCoeffData = function(data){
            var allData = JSON.parse(data);
            
            var returnMaps = data.split("CoefficientsMap:");
            
            Object.keys(allData.variablesMap).forEach(function(key) {
            	var variableName = allData.variablesMap[key];
            	
            	// find the parameter on x axis with variable name, 
            	// what happens if parameter not found?
            	
            	var curParameter = null;
            	for( var paramIndex = 0; paramIndex < this.parameters.x.length; ++paramIndex){
            	   var curParameterName = decodeURIComponent( this.parameters.x[paramIndex].name);
            		if(variableName === curParameterName){
                		curParameter = this.parameters.x[paramIndex];
            		}
        		}
        		if(curParameter !== null){
        			this.variablesMap[key] = curParameter;
        		}
             
             }.bind(this));
             
            var rawCoeffData = allData.coefficientsMap;
            var sum = 0.0;
            Object.keys(rawCoeffData).forEach(function(key) {
                if(key !== 'Constant'){
                    
                    var rawCurCoeff = parseFloat(rawCoeffData[key]);
                    var curCoeff = Math.abs(rawCurCoeff);
                    var curCoeffSign = "positive";
                    if(rawCurCoeff < 0){
                        curCoeffSign = "negative";
                    }
                    
                    var curCoeefObj = {'term': key, 'value': curCoeff, 'valueSign': curCoeffSign};
                    sum += curCoeff;
                    this.coefficientData.push(curCoeefObj);
                }
                
            }.bind(this));
            
            this.coefficientData.sort(function(a, b){return b.value - a.value});
           
            this.renderModifiedChart(this.configuration);
        };
        
        

avsChartPrototype.renderModifiedChart = function(configuration){        
            
    var that = this;
    this.preRender();
    this.updateSize(configuration);
    if (configuration) {
        this.requestObject.datasetId = configuration.datasetId;
    }

    if (Object.keys(this.legendElements).length === 0) {
        this.removeOverlayElements();
        this.overlayLegend = null;
    }

    var contributionLabel = NLSUtils.translate('PARETO_CONTRIBUTION_LABEL');
    if(this.showResponseAsPercentage === true){
        contributionLabel = NLSUtils.translate('PARETO_PERCENT_CONTRIBUTION_LABEL');
    }
         
    var yAxisLabel =  contributionLabel +
    that._getDisplayTextForParameter(that.parameters.y, 
    that.getDefaultYAxisLabel());  
            	
    var yLineAxisLabel = NLSUtils.translate('CUMULATIVE_PERCENT_LABEL');

    var chartRequest =
                        {
                            chart: {                        
                                type: 'column',
                                height: this.getChartAreaHeight() -5,
                                width:  this.getChartAreaWidth() - 5 
                            },
   
                            legend: {
                                enabled: true,
                                align: 'center',
                                itemStyle: {
                                    textOverflow: undefined,
                                    cursor: undefined
                                }  
                            },
                        
                            title: {
                                text: ''
                            },
                            exporting: { enabled: false },
                            credits: { enabled: false },
                            tooltip: { enabled: true,  shared: true },
                            
                             plotOptions: {
                                series: {
                                    events: {
                                        legendItemClick: function () {                    
                                            return false;
                                        }
                                    }
                                }
                            },
    
    
                            xAxis: {
                                categories: [],
                                crosshair: true
                            },
                            
                            yAxis: [{
                                title: {
                                    text: yAxisLabel
                                }
                            }, {
                                title: {
                                    text: yLineAxisLabel
                                },
                                minPadding: 0,
                                maxPadding: 0,
                                max: 100,
                                min: 0,
                                opposite: true,
                                labels: {
                                    format: "{value}%"
                                }
                            }],
                            
                            series: [{
                                type: 'line',
                                name: NLSUtils.translate('Cumulative'),
                                yAxis: 1,
                                zIndex: 10,
                                baseSeries: 1,
                                showInLegend: false,
                                color: this.chartProperties.defaults[0].line.color,
                                data: []
                            }, {
                                name: NLSUtils.translate('Factor'),
                                type: 'column',
                                zIndex: 2,
                                data: []
                            }]
                        };

    chartRequest.legend.labelFormatter =  function () {
        var str = '';
        Object.keys(that.variablesMap).forEach(function(key) {
            str =   str + key + ':' + '\"' + decodeURIComponent(that.variablesMap[key].displayName) +  '\"        ';
        });
        return str;
    };
        
    if( this.showResponseAsPercentage === true){
        chartRequest.yAxis[0].min = 0;
        chartRequest.yAxis[0].max = 100;
        chartRequest.yAxis[0].labels = {
            format: "{value}%"
        };
        chartRequest.yAxis[1].visible = false;
    }

    var total = 0.0; 
    var maxCoeff = 0.0;  
        
    this.coefficientData.forEach(function(coeffObject) {              
        //coeffObject.value = (coeffObject.value/sum)*100;
        total += coeffObject.value;
        if(coeffObject.value > maxCoeff){
            maxCoeff = coeffObject.value;
        }
    });
  
    var percentageRunningTotal = 0.0;        
    this.coefficientData.forEach(function(coeffObj){        
        
        if((this.hideInsignificantFactors === true && 
            coeffObj.value > (0.05*total)) || this.hideInsignificantFactors === false){
                            
            chartRequest.xAxis.categories.push(coeffObj.term);            
            var percentageCoeffValue = (coeffObj.value/total)*100;
                
            var yObject = {};
            if(this.showResponseAsPercentage === true){
                yObject['y'] = parseFloat(percentageCoeffValue.toFixed(2));
            }else{
                yObject['y'] = parseFloat(coeffObj.value.toFixed(2));
            }
        
            yObject['color'] = this.chartProperties.defaults[0].bar.color[coeffObj.valueSign];        
                
            chartRequest. series[1].data.push(yObject);
        
            percentageRunningTotal += percentageCoeffValue;
                        
            // if last % is greater than 100.0 % due to floating points
            // calculations (even by small amout e.g 100.0000001), 
            // last cumulative glyph does not show up, hence rounding it to 100.0
                        
            if (percentageRunningTotal > 100.0){
                percentageRunningTotal = 100.0;
            }
            chartRequest. series[0].data.push(parseFloat(percentageRunningTotal.toFixed(2)));
        }    
    }.bind(this));
        
    this.loadHighChartsLibrary().then(function(Highcharts){       
        var paretoChart =  new Highcharts.chart(that.chartId, chartRequest);
        var series = paretoChart.series;                           
        series[1].legendSymbol.destroy();
        that.propagateChartEvent({ eventType: 'unmask' });
     });
};
    
    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avsparettochart = avsChartPrototype;
})(this);
