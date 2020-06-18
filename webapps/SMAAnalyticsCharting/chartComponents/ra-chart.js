(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.chart !== 'undefined') {
        return;
    }

    var chart = {
        is: 'ra-chart',
        behaviors: [GLOBAL.DS.RAComponents.chartcomponent]
    };

    chart.createdCallback = function() {
        GLOBAL.DS.RAComponents.chartcomponent.createdCallback.call(this);

        this.classList.add('ra-chart');
        this.clickCallbacks = [];
    };

    chart.addDescriptorDropZone = function() {};

    chart.registerTooltipHandler = function() {};

    chart.getPopover = function() {};

    chart.setDataProvider = function(dataProvider) {
        this.dataProvider = dataProvider;
    };
    
    chart.set3DSpaceURL = function(_3DSpaceURL) {
        this._3DSpaceURL = _3DSpaceURL;
    };
    

    chart.setChartProperties = function(chartData) {
        this.chartProperties = chartData.properties;
    };

    // chart.addChartCreator = function(chartType, chartFunction){
    //  this.chartCreators[chartType] = chartFunction;
    //};

    chart._createDefaultDropZones = function() {
        // Create default drop zones
    };

    chart.highlightDropZones = function(dragType) {
        // Highlight appropriate drop zones based on the type of data being dragged.
    };

    chart.setupClick = function() {
        var that = this;

        this.on('click', function(args) {
            that.clickCallbacks.forEach(function(cb) {
                if (typeof cb === 'function') {
                    cb.call(that, args);
                }
            });
        });
    };

    chart.addClickHandler = function(fn) {
        this.clickCallbacks.push(fn);
    };

    chart.getClickHandlers = function() {};

    chart.removeClickHandler = function(clickHandler) {};

    chart.refresh = function() {};

    chart.save = function() {};

    chart.setSelect = function() {
        // Sets the selection object on the chart programmaticaly. This will call
        // any associated callbacks invoked on a change of selection.
    };

    chart.getSelect = function() {};

    chart.getState = function() {};

    chart.restore = function() {};

    chart.getConfig = function() {};

    chart.setConfig = function() {};

    chart.getParameters = function() {};

    chart.renderControlPanel = function() {};
    // This should be implemented on individual charts.

    Polymer(chart);

    GLOBAL.DS.RAComponents.chart = chart;
})(this);
