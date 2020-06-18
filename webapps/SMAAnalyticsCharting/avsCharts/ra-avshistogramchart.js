(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.avshistogramchart !== 'undefined') {
        return;
    }
    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;
    
    var avsChartPrototype = {
        is: 'ra-avshistogramchart',
        behaviors: [GLOBAL.DS.RAComponents.avsbarchart]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsbarchart.createdCallback.call(this);        
        this.divs.root.removeChild(this.divs.yAxisDropZone);
        this.divs.root.removeChild(this.divs.colorDropZone);
        this.makeZoomable({maxZoom:1});
        
        this.showAsPercentage = false; 
        this.showStatistics = false;
        this.applyFilters = true;
        
    };
    
     avsChartPrototype.getChartSettings = function(data) {
        return { 'showAsPercentage': this.showAsPercentage , 
        'showStatistics': this.showStatistics,
        'applyFilters' : this.applyFilters};
    
    };
    
    avsChartPrototype.restoreChartSettings = function(chartSettings) {
        if(chartSettings.showAsPercentage !== undefined){
            this.showAsPercentage = chartSettings.showAsPercentage;
            if(this.percentaageSettingsButton !== undefined){
                this.percentaageSettingsButton.setCheck(this.showAsPercentage);
            }
        }
        
        if(chartSettings.showStatistics !== undefined){
            this.showStatistics = chartSettings.showStatistics;
            if(this.statisticsSettingsButton !== undefined){
                this.statisticsSettingsButton.setCheck(this.showStatistics);
            }
        }
        
        if(chartSettings.applyFilters !== undefined){
            this.applyFilters = chartSettings.applyFilters;
            if(this.filterSettingButton !== undefined){
                this.filterSettingButton.setCheck(this.applyFilters);
            }
        }
        
    };
    
    avsChartPrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.avsbarchart.renderControlPanel.call(
            this,
            panel
        );
        
        var chartSettingsControl = panel.getControl('ra-chartsettingscontrol');
        
        this.percentaageSettingsButton = chartSettingsControl.addCheckBox(
    		'percentage', 
    		NLSUtils.translate('SHOW_AS_PERCENT'), 
    		this.showAsPercentage
		);
        this.percentaageSettingsButton.setUpdateCallback(function(newVal){
        	this.showAsPercentage = newVal;
        	this.renderChart();
        }.bind(this));
        
        this.statisticsSettingsButton = chartSettingsControl.addCheckBox(
    		'statistics', 
    		NLSUtils.translate('SHOW_STATISTICS'), 
    		this.showStatistics
		);
        this.statisticsSettingsButton.setUpdateCallback(function(newVal){
        	this.showStatistics = newVal;
        	this.renderChart();
        }.bind(this));
                
        this.filterSettingButton = chartSettingsControl.addCheckBox(
            'applyFilters',
            NLSUtils.translate('APPLY_FILTERS'),
            this.applyFilters
        );
        
        this.filterSettingButton.setTitleText({
            long: NLSUtils.translate('APPLY_FILTERS_NO_EXCLUDED')
        });

        this.filterSettingButton.setUpdateCallback(function(newVal){
            this.applyFilters = newVal;
            this.renderChart();
        }.bind(this));
        
    };
    
    // override 
    avsChartPrototype.getXParameter = function(parameter, attributes) {
    	attributes = attributes || {};
    	attributes.data = attributes.data || {};
    	
    	var chartParam = GLOBAL.DS.RAComponents.avsdropchartbase.getXParameter.call(this, parameter, attributes);
    	if(parameter.dataType !== 'STRING') {
    		attributes.axisProperties = attributes.axisProperties || {};
    		attributes.axisProperties.style = 'forcedNumeric';
    	}

    	chartParam.update(attributes);
    	
    	return chartParam;
    };
    
    avsChartPrototype.updateRequest = function() {
        GLOBAL.DS.RAComponents.avsbarchart.updateRequest.call(this);
        var that = this;
        
        var yAxisLabel = "";
        if ( this.showAsPercentage === true){
            yAxisLabel = NLSUtils.translate('FREQUENCY_PERCENT');
        }else {
            yAxisLabel = NLSUtils.translate('FREQUENCY');
        }
        
        this.updateAxisLabel(this.requestObject.chartRequest.charts[0].y, yAxisLabel);
        
        this.requestObject.chartRequest.charts[0].axisAsPercent = this.showAsPercentage;
        this.requestObject.chartRequest.charts[0].generateStatistics = this.showStatistics;
        this.requestObject.chartRequest.useFiltering = this.applyFilters;
        this.requestObject.chartRequest.ignoreExcludedPoints = true;
    };
    avsChartPrototype.renderLegends = function(data, chart, uniqueKey) {
        GLOBAL.DS.RAComponents.avsdropchartbase.renderLegends.call(
            this,
            data,
            chart,
            uniqueKey
        );
        
        
        this.renderstatsLegend(data);
    };
    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avshistogramchart = avsChartPrototype;
})(this);
