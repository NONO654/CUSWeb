(function(GLOBAL, template) {
    if (typeof GLOBAL.DS.RAComponents.avsarraychart !== 'undefined') {
        return;
    }

    var avsChartPrototype = {
        is: 'ra-avsarraychart',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase]
    };

    avsChartPrototype.createdCallback = function() {
        // GLOBAL.DS.RAComponents.avsdropchartbase.createdCallback.call(this);
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.paramLength = null;

        this.setupDropTargets();

        // We need to set this.avsDropChart so that dropChartBase can handle
        // rendering  that element. This should probably be changed so that the drop
        // chart can render  itself.
        this.avsDropChart = this.querySelector('ra-avsdropchartelement');
    };

    avsChartPrototype.initialize = function() {
        this.setupTestRequests();
        this.avsDropChart.setDataProvider(this.dataProvider);
    };

    avsChartPrototype.setXParameter = function(param) {
        this.xParameter = param;

        if (!this.paramLength) {
            this.paramLength = param.dimensions[0];
        }

        this.setupDataSet();
    };

    avsChartPrototype.setYParameter = function(param) {
        this.yParameter = param;

        if (!this.paramLength) {
            this.paramLength = param.dimensions[0];
        }

        this.setupDataSet();
    };

    avsChartPrototype.setupDataSet = function() {
        var that = this;

        if (!(this.xParameter && this.yParameter)) {
            // Only set up data set if parameters have been defined!
            return;
        }

        // Builds a data set for this chart. This will contain the necessary data
        // that needs to get  sent to the server.
        this.dataSet = this.dataSet || new GLOBAL.DS.RAConstructors.DataSet({});

        // Get param IDs for x and y
        var xParamId = this.xParameter.id.split('[')[0];
        var yParamId = this.yParameter.id.split('[')[0];

        var indexMapper = function(paramId) {
            return paramId.
                split('[').
                slice(1).
                map(function(d) {
                    return parseFloat(d);
                });
        };

        var xIndices = indexMapper(this.xParameter.id);
        var yIndices = indexMapper(this.yParameter.id);

        var getArrayParam = function(rawData, paramId, arrayIndices) {
            var param = rawData.parmValues[paramId];
            for (var i = 0; i < arrayIndices.length; i++) {
                param = param[arrayIndices[i]];
            }
            return param;
        };

        // FIXME: Add real support name.
        this.dataProvider.executeSupport('getRow', function(jsonData) {
            var rawData = JSON.parse(jsonData).elements[0];
            var xArrayParam = getArrayParam(rawData, xParamId, xIndices);
            var yArrayParam = getArrayParam(rawData, yParamId, yIndices);

            that.dataSet.setColumn('x', {
                metadata: {
                    id: 'x',
                    displayName: that.xParameter.displayName,
                    dataType: 'REAL'
                },
                values: xArrayParam
            });

            that.dataSet.setColumn('y', {
                metadata: {
                    id: 'y',
                    displayName: that.yParameter.displayName,
                    dataType: 'REAL'
                },
                values: yArrayParam
            });

            that.renderChart();
        });
    };

    avsChartPrototype.renderControlPanel = function(panel) {
        // Add this once it's possible to change params.
    };

    avsChartPrototype.setupDropTargets = function() {
        var that = this;
        // FIXME: This uses hard coded data from GLOBAL.DS.RAObjects.ArrayTest,
        // since  arrays are not set up in either the standalone or integrated
        // version. This should  be roughly correct, except for filtering, which has
        // been removed.

        // Sets up the drop zone to accept a drop parameter
        var mainDropTarget = this.querySelector('.mainDropZone');
        var arrayParam = GLOBAL.DS.RAObjects.ArrayTest.arrayParam;
        arrayParam.id = arrayParam.ID;
        mainDropTarget.setFilter(function(data) {
            return that.validateArray(arrayParam);
        });
        mainDropTarget.setDropListener(function(data) {
            that.setArray(arrayParam);
        });

        var xDropTarget = this.querySelector('.xAxis');
        var xParam = GLOBAL.DS.RAObjects.ArrayTest.xParam;
        xParam.id = xParam.ID;
        xDropTarget.setFilter(function(data) {
            return that.validateParameter(data);
        });
        xDropTarget.setDropListener(function(xParam) {
            that.setXParameter(xParam);
        });

        var yDropTarget = this.querySelector('.yAxis');
        var yParam = GLOBAL.DS.RAObjects.ArrayTest.yParam;
        yParam.id = yParam.ID;
        yDropTarget.setFilter(function(data) {
            return that.validateParameter(yParam);
        });
        yDropTarget.setDropListener(function(data) {
            that.setYParameter(yParam);
        });
    };

    avsChartPrototype.validateParameter = function(param) {
        // A parameter must be a 1-d array of the same length as the length of any
        // existent arrays.
        if (!param.dimensions) {
            return false;
        } else if (param.dimensions.length !== 1) {
            return false;
        } else if (
            this.paramLength &&
            param.dimensions[0] !== this.paramLength
        ) {
            return false;
        }

        return true;
    };

    avsChartPrototype.setArray = function(param) {
        var xParam = GLOBAL.DS.RAObjects.ChartUtils.getSubarrayParam(param, [
            0
        ]);
        xParam.id = xParam.ID;

        var yParam = GLOBAL.DS.RAObjects.ChartUtils.getSubarrayParam(param, [
            1
        ]);
        yParam.id = yParam.ID;

        this.setXParameter(xParam);
        this.setYParameter(yParam);
    };

    avsChartPrototype.validateArray = function(param) {
        if (param.structure !== 'ARRAY') {
            return false;
        }

        var xParam = GLOBAL.DS.RAObjects.ChartUtils.getSubarrayParam(param, [
                0
            ]),
            yParam = GLOBAL.DS.RAObjects.ChartUtils.getSubarrayParam(param, [
                1
            ]);

        try {
            this.paramLength = xParam.dimensions[0];
        } catch (e) {
            return false;
        }

        return this.validateParameter(xParam) && this.validateParameter(yParam);
    };

    avsChartPrototype.setupTestRequests = function() {
        this.dataProvider.registerSupport('getRow', function(request, cb) {
            var rowObject = GLOBAL.DS.RAObjects.ArrayTest.rowResponse;

            if (typeof cb === 'function') {
                cb(JSON.stringify(rowObject));
            }
        });
    };

    avsChartPrototype.updateRequest = function() {
        var that = this;

        this.requestObject = {
            chartRequest: {
                width: this.querySelector('ra-avsdropchartelement').offsetWidth,
                height: this.querySelector('ra-avsdropchartelement').
                    offsetHeight,
                charts: JSON.parse(
                    JSON.stringify(this.chartProperties.defaults)
                )
            }
        };

        var dataParams = { raw: [{ guid: 'x' }, { guid: 'y' }] };

        var yData = this.dataSet.getColumn('y').getColumnData();

        this.requestObject.chartRequest.charts[0].x = {
            data: { type: 'raw', guid: 'x' }
        };

        this.requestObject.chartRequest.charts[0].y = {
            series: [{ type: 'raw', guid: 'y' }]
        };

        this.requestObject.chartRequest.charts[1].x = {
            data: { type: 'raw', guid: 'x' }
        };

        this.requestObject.chartRequest.charts[1].y = {
            data: { type: 'raw', guid: 'y' },
            minUserValue: yData.min,
            maxUserValue: yData.max
        };

        if (this.chartProperties.defaults.size != null) {
            // TODO get the latest state from the ui panel
            this.requestObject.chartRequest.charts[1].size = this.chartProperties.defaults.size;
        }

        this.requestObject.chartRequest.data = dataParams;

        this.requestObject.datasets = [this.dataSet.getDataSetObject()];

        this.requestObject.datasetId = this.dataSet.id;
    };

    avsChartPrototype.validateRender = function() {
        if (this.xParameter && this.yParameter) {
            return true;
        }

        return false;
    };

    avsChartPrototype.preRender = function() {};

    avsChartPrototype.renderChart = function() {
        Array.prototype.forEach.call(
            this.querySelectorAll('ra-droptarget'),
            function(el) {
                el.classList.add('hidden');
            }
        );

        var that = this;

        if (this.validateRender() == false) {
            if (this.avsDropChart !== null) {
                this.avsDropChart.removeChartTiles();
                this.avsDropChart.removeLegendTiles();
            }
            return;
        }

        this.preRender();
        this.updateRequest();

        // TODO: Add legend rendering back in if we need it.

        this.avsDropChart.removeChartTiles();
        this.avsDropChart.removeLegendTiles();

        this.avsDropChart.setTotalWidth(this.offsetWidth);
        this.avsDropChart.setTotalHeight(this.offsetHeight);
        this.avsDropChart.renderRequest(this.requestObject);
        console.log('rendering avs drop chart!');
    };

    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avsarraychart = avsChartPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
