(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.avsanovachart !== 'undefined') {
        return;
    }

    var avsChartPrototype = {
        is: 'ra-avsanovachart',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.createdCallback.call(this);

        //        this.divs.root.removeChild(this.divs.yAxisDropZone);
        this.divs.root.removeChild(this.divs.sizeDropZone);
        this.divs.root.removeChild(this.divs.colorDropZone);
        this.divs.root.removeChild(this.divs.labelDropZone);
    };

    avsChartPrototype.setXParameter = function(parameter) {
        var that = this;
        console.log('rendering avs X test drop chart!');

        this.dataSetId = parameter.source;

        this.dataSet = new GLOBAL.DS.RAConstructors.DataSet({
            metadata: { parentId: this.dataSetId },
            data: {
                terms: {
                    metadata: { displayName: 'terms', dataType: 'STRING' }
                }
            }
        });

        var metadata = {
            displayName: parameter.displayName,
            dataType: parameter.dataType
        };

        this.dataSet.setColumn(parameter.id, {
            values: [],
            metadata: metadata
        });

        var requestObject = {
            datasetId: this.dataSetId,
            paramIDs: [parameter.id]
        };

        this.dataProvider.executeSupport(
            'getAnovaTable',
            requestObject,
            function(data) {
                data = JSON.parse(data);
                that.dataSet.updateColumn('terms', data.terms);
                that.dataSet.updateColumn(parameter.id, data[parameter.id]);
                that.parameters.x = parameter;
                that.divs.xAxisDropZone.updatePlaceholder();
                that.renderChart();
            }
        );
    };

    avsChartPrototype.validateRender = function() {
        if (this.parameters.y.length > 0) {
            // TODO right now x is required for anova data call
            if (this.parameters.x === null) {
                return false;
            }
            return true;
        }
        if (this.parameters.x !== null) {
            if (
                this.parameters.y.length == 0 &&
                this.parameters.x.dataType === 'STRING'
            ) {
                return false;
            }
            return true;
        }
        return false;
    };

    avsChartPrototype.updateRequest = function() {
        var that = this;

        var xLabel = null;
        var yLabel = null;
        var dataParams = { raw: [] };

        if (this.parameters.x != null) {
            this.requestObject.chartRequest.charts[0].x = {
                data: {
                    type: 'binnedDiscrete',
                    unique: false,
                    sortOrder: 'DESCENDING',
                    guid: this.parameters.x.id
                }
            };
            this.addRawParam(this.parameters.x, dataParams.raw);
            xLabel = this.parameters.x.name;
        } else if (this.parameters.y.length > 0) {
            this.requestObject.chartRequest.charts[0].x = {
                data: {
                    type: 'binnedDiscrete',
                    unique: false,
                    sortOrder: 'DESCENDING',
                    guid: this.parameters.y[0].id
                }
            };
            this.addRawParam(this.parameters.y[0], dataParams.raw);
            xLabel = this.parameters.y[0].name;
        }

        // Must be numeric
        if (this.parameters.y.length > 0) {
            this.requestObject.chartRequest.charts[0].y = {
                series: [
                    { type: 'raw', guid: this.parameters.y[0].id },
                    { type: 'raw', guid: this.parameters.y[0].id }
                ]
            };
            this.addRawParam(this.parameters.y[0], dataParams.raw);
            yLabel = this.parameters.y[0].name;
        } else if (this.parameters.x != null) {
            this.requestObject.chartRequest.charts[0].y = {
                series: [
                    { type: 'raw', guid: this.parameters.x.id },
                    { type: 'raw', guid: this.parameters.x.id }
                ]
            };
            this.addRawParam(this.parameters.x, dataParams.raw);
            yLabel = this.parameters.x.name;
        }

        if (this.parameters.color != null) {
            var colorRequest = {
                type: 'byData',
                data: { type: 'raw', guid: this.parameters.color.id }
            };
            this.requestObject.chartRequest.charts[0].color = colorRequest;
            this.addRawParam(this.parameters.color, dataParams.raw);
        }
        dataParams.raw.push({ guid: 'terms' });
        this.requestObject.chartRequest.data = dataParams;

        this.updateAxisLabel(
            this.requestObject.chartRequest.charts[0].x,
            xLabel
        );
        this.updateAxisLabel(
            this.requestObject.chartRequest.charts[0].y,
            yLabel
        );

        if (typeof this.datasets === 'undefined') {
            this.datasets = [];
        }
        this.datasets.push(this.dataSet);

        this.requestObject.datasets = [];
        for (var i = 0; i < this.datasets.length; i++) {
            this.requestObject.datasets.push(
                this.datasets[i].getDataSetObject()
            );
        }
    };

    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avsanovachart = avsChartPrototype;
})(this);
