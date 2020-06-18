(function(GLOBAL) {
    if (
        typeof GLOBAL.DS.RAComponents.avsbinnedscattermatrixchart !==
        'undefined'
    ) {
        return;
    }

    var avsChartPrototype = {
        is: 'ra-avsbinnedscattermatrixchart',
        behaviors: [GLOBAL.DS.RAComponents.avsscatterchart]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsscatterchart.createdCallback.call(this);
    };

    avsChartPrototype.updateRequest = function() {
        GLOBAL.DS.RAComponents.avsscatterchart.updateRequest.call(this);
        var that = this;

        this.requestObject.chartRequest.layout = {
            type: 'matrix',
            numGridRows: 3,
            numGridColumns: 3
        };

        var baseChart = JSON.parse(
            JSON.stringify(this.requestObject.chartRequest.charts[0])
        );
        this.requestObject.chartRequest.charts = [];

        for (
            var i = 0;
            i < this.requestObject.chartRequest.layout.numGridRows;
            i++
        ) {
            for (
                var j = 0;
                j < this.requestObject.chartRequest.layout.numGridColumns;
                j++
            ) {
                var curChart = JSON.parse(JSON.stringify(baseChart));
                this.requestObject.chartRequest.charts.push(curChart);
            }
        }
    };

    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avsbinnedscattermatrixchart = avsChartPrototype;
})(this);
