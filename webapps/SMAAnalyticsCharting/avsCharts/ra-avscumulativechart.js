(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.avscumulativechart !== 'undefined') {
        return;
    }
    
    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;
    
    var avsChartPrototype = {
        is: 'ra-avscumulativechart',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.createdCallback.call(this);

        this.divs.root.removeChild(this.divs.colorDropZone);
        this.divs.root.removeChild(this.divs.sizeDropZone);
        this.divs.root.removeChild(this.divs.labelDropZone);
        this.divs.root.removeChild(this.divs.yAxisDropZone);
        
        this.makeZoomable({maxZoom:1});
        this.showAsPercentage = false; 
        this.showStatistics = false;
        this.applyFilters = true;
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
            console.log('y parameter cannot be discrete');
            return false;
        }
        return true;
    };
    avsChartPrototype.getChartSettings = function(data) {
        return { 'showAsPercentage': this.showAsPercentage , 'showStatistics': this.showStatistics,
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
        GLOBAL.DS.RAComponents.avsdropchartbase.renderControlPanel.call(
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
        var that = this;

        this.requestObject.chartRequest.charts[0] = that.controls.chartPropertiesControl.getRequest();
        this.requestObject.chartRequest.charts[0].guid = 'bar1';

        var dataParams = { raw: [{ guid: this.parameters.x.id }] };
        var dataMaps = { colorMaps: [] };
        var legends = null;

        // Populate x parameter
        if (this.parameters.x.dataType === 'STRING') {
            this.requestObject.chartRequest.charts[0].x = {
                data: { type: 'binnedDiscrete', guid: this.parameters.x.id }
            };
            this.requestObject.chartRequest.charts[0].x.data.discreteValues = that.controls.xControl.getDiscreteValues();
        } else {
            this.requestObject.chartRequest.charts[0].x = {
                data: {
                    type: 'binnedEqualWidth',
                    numBins: 10,
                    guid: this.parameters.x.id
                }
            };
            this.requestObject.chartRequest.charts[0].x.data.minFilterPercent = that.controls.xControl.getLinearMinValue();
            this.requestObject.chartRequest.charts[0].x.data.maxFilterPercent = that.controls.xControl.getLinearMaxValue();
        }
        this.addRawParam(this.parameters.x, dataParams.raw);
        this.requestObject.chartRequest.charts[0].x.axisProperties = that.controls.xControl.getAxisProperties();

        // Populate y parameter
        var yLabelOverride = null;
        this.requestObject.chartRequest.charts[0].y = {
        		series: [
                    {
                        type: 'aggregation',
                        aggregationType: 'COUNT',
                        guid: this.parameters.x.id
                    }
                ]
            };
        
        var yAxisLabel = "";
        if ( this.showAsPercentage === true){
            yAxisLabel = NLSUtils.translate('CUMULATIVE FREQUENCY_PERCENT');
        }else {
            yAxisLabel = NLSUtils.translate('CUMULATIVE_FREQUENCY');
        }
        
        this.updateAxisLabel(this.requestObject.chartRequest.charts[0].y, yAxisLabel);
        
        
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
            }
        }

        
        this.requestObject.chartRequest.data = dataParams;
        this.requestObject.chartRequest.dataMaps = dataMaps;
        this.requestObject.chartRequest.legends = legends;

        this.requestObject.chartRequest.charts[0].axisAsPercent = this.showAsPercentage;
        // sd4: aesthetic changes to axes
        // FIXME: this should be picked up from defaults, but that does not seem to
        // happen
        this.requestObject.chartRequest.charts[0].x.axisProperties.style =
            'tabular';

        this.requestObject.chartRequest.charts[0].x.axisProperties.majorTickMarks = {
            visible: false
        };
        
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
    GLOBAL.DS.RAComponents.avscumulativechart = avsChartPrototype;
})(this);
