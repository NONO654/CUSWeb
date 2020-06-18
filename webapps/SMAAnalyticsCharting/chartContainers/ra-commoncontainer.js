(function(GLOBAL) {
    var commonContainerPrototype = {
        is: 'ra-commoncontainer',
        behaviors: [
            GLOBAL.DS.RAComponents.chartcomponent
        ],
        keyPress: { ctrl: false, shift: false, alt: false }
    };
    
    commonContainerPrototype.setDataProvider = function(dataProvider) {
        this.dataProvider = dataProvider;
    };
    
    commonContainerPrototype.set3DSpaceURL = function(_3DSpaceURL) {
        this._3DSpaceURL = _3DSpaceURL;
    };
   

    // This bridge allows events to be communicated between the "widget" and
    // the grid container.
    // remember: only the grid-container propagates events to the individual charts
    commonContainerPrototype.setEventBridge = function(eventBridge) {
        this.eventBridge = eventBridge;
    };

    // sources is an array of chartElements, i.e some objects (not IDs) or the
    // eventBridge itself
    commonContainerPrototype.propagateChartEvent = function(args, sources) {
        // we first bubble up the events to the widget
        // this should update the parameters tree

        sources = sources || [];

        if (this.eventBridge && this.eventBridge.propagateChartEvent) {
            if (sources.indexOf(this.eventBridge) == -1) {
                try {
                    this.eventBridge.propagateChartEvent(args, sources);
                } catch (ignoredException) {}
            }
            if (args.eventType === 'mask' || args.eventType === 'unmask') {
                return;
            }
        }

        sources.push(this);
        
        // Propagate it to other charts
        var chart;
        if (typeof this.charts !== 'undefined') {
            for (var key in this.charts) {
                chart = this.charts[key];

                if (
                    sources.indexOf(chart.element) === -1 &&
                    chart.element.propagateChartEvent
                ) {
                    try {
                        chart.element.propagateChartEvent(args, sources);
                    } catch (ignoredException) {}
                }
            }
        }
    };
    
    commonContainerPrototype.chartBaseUrl = function(url) {
        if (typeof url !== 'undefined') {
            this.baseUrl = url;
        } else {
            return url;
        }

        return this;
    };
    
    commonContainerPrototype.updateChartsConfigPreference = function(chartId) {
    
        if (this.eventBridge && this.eventBridge.updateChartsConfigPreference) {           
            this.eventBridge.updateChartsConfigPreference(chartId, this.getChartConfig(chartId));            
        }
    };
    
    commonContainerPrototype.deleteChartFromChartsConfigPreference = function(chartId) {
    
        if (this.eventBridge && this.eventBridge.deleteChartFromChartsConfigPreference) {           
            this.eventBridge.deleteChartFromChartsConfigPreference(chartId);            
        }
    };
    
    commonContainerPrototype.updateControlPanel = function(controlPanel) {};

    commonContainerPrototype.setParamsControlPanel = function(controlPanel) {
        this.paramsControlPanel = controlPanel;
    };

    commonContainerPrototype.setSettingsControlPanel = function(controlPanel) {
        this.settingsControlPanel = controlPanel;
    };

    commonContainerPrototype.setControlPanel = function(controlPanel) {
        this.controlPanel = controlPanel;
    };

    commonContainerPrototype.setStylePanel = function(stylePanel) {
        this.stylePanel = stylePanel;
    };
    
    commonContainerPrototype.newGUID = function() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(
            c
        ) {
            var r = (Math.random() * 16) | 0,
                v = c == 'x' ? r : (r & 0x3) | 0x8;
            return v.toString(16);
        });
    };

    commonContainerPrototype.restore = function(chartsData) {
        var that = this;
        var idx = 0;
        for (var chartId in chartsData) {
            var chart = chartsData[chartId];
            chart.id = chartId;
            // restore each chart
            this.restoreChart(chart, idx, function(d) {
                console.log('restored:' + d);
            });
            idx++;
        } // iterate over all saved charts
    };

    commonContainerPrototype.save = function() {
        var that = this;
        var chartsJson = {};
        for (var chartId in this.charts) {            
            chartsJson[chartId] = this.getChartConfig(chartId);
        } // iterate over all saved charts
        return chartsJson;
    };
    
 // adds chart to the charts object in this container
    commonContainerPrototype.addChart = function(
        chartId,
        newChart,
        chartElement
    ) {
        if (typeof this.charts === 'undefined') {
            this.charts = {};
        }
        this.charts[chartId] = newChart;       
        newChart.element.chartParent = this;
    };
    
    commonContainerPrototype.createNewChartDialog = function() {
        // Create a modal dialog that can be used to generate a new chart.
    	//Not implemented yet, but we probably eventually want this.
    
    };

    // adds chart to the charts object in this container
    commonContainerPrototype.removeChart = function(chartId) {
        this.dataProvider.executeSupport('removeChart', { chartId: chartId });
        // only empty the control panel iff the removed chart is the current chart
        if (this.controlPanel.currentChart() === this.charts[chartId].element) {
            this.controlPanel.clearPanel();
        }
        delete this.charts[chartId];
         if(Object.keys(this.charts).length === 0){                  
            this.propagateChartEvent({ eventType: 'clearSelection' });
        }
        
        
        this.deleteChartFromChartsConfigPreference(chartId);
    };

    commonContainerPrototype.removeAllCharts = function() {
        for (var chartId in this.charts) {
            if (this.charts.hasOwnProperty(chartId)) {
                var chart = this.charts[chartId];
                this.removeChild(chart.frame);
                // sd4: i am not calling this method since the servant is already
                // dead
                // this.removeChart(chartId);
            }
        }
        this.controlPanel.clearPanel();
        this.charts = [];
    };
    
    Polymer(commonContainerPrototype);
    GLOBAL.DS.RAComponents.commoncontainer = commonContainerPrototype;
})(this);

