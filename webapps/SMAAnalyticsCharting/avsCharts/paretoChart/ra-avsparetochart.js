(function(GLOBAL, template) {
    if (typeof GLOBAL.DS.RAComponents.avsanovachart !== 'undefined') {
        return;
    }

    var avsChartPrototype = {
        is: 'ra-avsparetochart',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase]
    };

    avsChartPrototype.createdCallback = function() {
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);
    };

    avsChartPrototype.initialize = function() {
        /*Setup functionality for various chart elements. We need to do the
     * following: > Set up default data
     *
     *  > Set up a drop zone to accept a parameter and hide itself after it gets
     *    one.
     *
     *  > Set up an ra-avsdropchartelement to render the plot once the data is
     * set up. The actual rendering of this element is handled by the
     * 'renderChart' method, which has been copied with some modifications from
     * ra-avsdropchartbase. (This was done since this element has a different
     * dom.)
     */

        this.setupData();
        // this.setupLegend();
        this.setupChartElement();
        this.setupDropZone();
    };

    /*avsChartPrototype.setupLegend = function(){
    GLOBAL.DS.RAComponents.avsdropchartbase.setupLegend.call(this);
    this.overlayLegend.classList.add('hidden');
};*/

    avsChartPrototype.setupData = function() {
        var width = this.querySelector('ra-avsdropchartelement').offsetWidth,
            height = this.querySelector('ra-avsdropchartelement').offsetHeight,
            charts = JSON.parse(JSON.stringify(this.chartProperties.defaults));

        this.requestObject = {
            chartRequest: { width: width, height: height, charts: charts }
        };

        // Pareto charts cn only have a single param.
        this.parameter = null;

        this.dataSet = null; // A clientside dataset object
        this.dataSetId = null; // The id of the dataset the ANOVA params are in

        // Do we need dimensions?
        // this.uiprops = this.chartProperties.uiprops; //.dimensions
    };

    avsChartPrototype.setupChartElement = function() {
        var chart = this.querySelector('ra-avsdropchartelement');

        // We need to set this.avsDropChart so that dropChartBase can handle
        // rendering  that element. This should probably be changed so that the drop
        // chart can render  itself.
        this.avsDropChart = chart;

        this.avsDropChart.setDataProvider(this.dataProvider);
        // this.avsDropChart.setLegend(this.overlayLegend);
    };

    avsChartPrototype.setupDropZone = function() {
        var that = this;

        // Sets up the drop zone to accept a drop parameter
        var dropZone = this.querySelector('ra-droptarget');
        dropZone.setFilter(function(data) {
            return that.validateParameter(data);
        });
        dropZone.setDropListener(function(data) {
            that.querySelector('ra-droptarget').classList.add('hidden');
            // that.overlayLegend.classList.remove('hidden');
            that.setParameter(data.properties);
        });
    };

    avsChartPrototype.setParameter = function(paramData) {
        var that = this;

        this.parameter = paramData;

        if (typeof paramData !== 'object') {
            this.dataSet = null;
            this.dataSetId = null;
        }

        if (!this.dataSet) {
            // If there is no dataSet, find one matching the dataSetId for the param
            // or make one.

            // Check if there exists a data set for the parameter
            var dsKey = Object.keys(
                GLOBAL.DS.RAObjects.datasets
            ).forEach(function(key) {
                if (
                    GLOBAL.DS.RAObjects.datasets[key].metadata.parentId !==
                    paramData.source
                ) {
                    return false;
                }

                return true;
            });

            var dataSet;
            if (typeof dsKey !== 'undefined') {
                // Dataset exists.
                dataSet = GLOBAL.DS.RAObjects.datasets[dsKey];
            } else {
                // Create a new dataset
                this.dataSet = new GLOBAL.DS.RAConstructors.DataSet({
                    metadata: { parentId: paramData.source },
                    data: {
                        terms: {
                            metadata: {
                                displayName: 'Terms',
                                dataType: 'STRING'
                            }
                        }
                    }
                });
            }

            this.dataSetId = paramData.source;
        }

        if (!this.dataSet.hasColumn(paramData.id)) {
            // TODO: Figure out how to handle race condition.
            var metadata = {
                id: paramData.id,
                displayName:
                    paramData.alias || paramData.displayName || paramData.id,
                dataType: 'REAL',
                status: 'NOT_READY'
            };

            this.dataSet.setColumn(paramData.id, {
                values: [],
                metadata: metadata
            });

            var paramIds = [this.parameter.id];

            var requestObject = {
                datasetId: this.dataSetId,
                paramIDs: paramIds
            };

            this.controls.paramsControl.updateController([this.parameter]);

            this.dataProvider.executeSupport(
                'getAnovaTable',
                requestObject,
                function(data) {
                    data = JSON.parse(data);

                    that.dataSet.updateColumn('terms', data.terms);
                    that.dataSet.updateColumn(paramData.id, data[paramData.id]);
                    that.renderChart();
                }
            );
        } else {
            that.renderChart();
        }
    };

    avsChartPrototype.updateRequest = function() {
        // This is called by renderChart
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

        this.dataSet.sort(this.parameter.id);

        var cumulativeValues = [];
        var totalId = 'total' + this.parameter.id;
        var max = this.dataSet.columns[
            this.parameter.id
        ].values.reduce(function(last, current) {
            // This uses +last + +current to make sure both values are
            // converted to numbers before adding.
            var val = Number(last) + Number(current);
            cumulativeValues.push(val);
            return val;
        }, 0);

        this.dataSet.setColumn('total' + this.parameter.id, {
            metadata: {
                id: 'total' + this.parameter.id,
                displayName: 'Total ' + this.parameter.displayName,
                dataType: 'REAL',
                status: 'NOT_READY'
            },
            values: cumulativeValues
        });

        var dataParams = {
            raw: [
                { guid: 'terms' },
                { guid: this.parameter.id },
                { guid: totalId }
            ]
        };

        this.requestObject.chartRequest.charts[0].x = {
            data: {
                type: 'binnedDiscrete',
                guid: 'terms',
                unique: false,
                sortOrder: 'ENCOUNTERED'
            },
            axisProperties: { title: { text: 'Terms' } }
        };

        // y-param is always null, since it's variation in an ANOVA.
        this.requestObject.chartRequest.charts[0].y = {
            series: [{ type: 'raw', guid: this.parameter.id }],
            axisProperties: { title: { text: 'Contribution to Variance' } },
            minUserValue: 0,
            maxUserValue: max
        };

        this.requestObject.chartRequest.charts[0].color = {
            // defaultColor : '#c74646',
            type: 'bySeries'
        };

        // Chart 2: line chart
        this.requestObject.chartRequest.charts[1].x = {
            data: {
                type: 'binnedDiscrete',
                guid: 'terms',
                sortOrder: 'ENCOUNTERED'
            },
            axisProperties: { visible: 'false' }
        };

        // y-param is always null, since it's variation in an ANOVA.
        this.requestObject.chartRequest.charts[1].y = {
            series: [{ type: 'raw', guid: totalId }],
            axisProperties: { visible: 'false' },
            minUserValue: 0,
            maxUserValue: max
        };

        this.requestObject.chartRequest.data = dataParams;

        this.requestObject.datasets = [this.dataSet.getDataSetObject()];

        this.requestObject.datasetId = this.dataSet.id;

        console.log(this.requestObject);
    };

    avsChartPrototype.resize = function() {
        this.renderChart();
    };

    /*avsChartPrototype.onLegendDock = function(legend){
    var dir = legend.dockDirection;

    var dimensions = {};

    if(dir === 'top'){
        dimensions = {
            'top' : legend.getAttribute('height') + 'px',
            'bottom' : '0px',
            'left' : '0px',
            'right' : '0px'
        };
    } else if(dir === 'bottom'){
        dimensions = {
                'bottom' : legend.getAttribute('height') + 'px',
                'top' : '0px',
                'left' : '0px',
                'right' : '0px'
            };
    } else if(dir === 'left'){
        dimensions = {
                'top' : '0px',
                'bottom' : '0px',
                'right' : '0px',
                'left' : legend.getAttribute('width') + 'px'
            };
    } else if(dir === 'right'){
        dimensions = {
                'top' : '0px',
                'bottom' : '0px',
                'right' : legend.getAttribute('width') + 'px',
                'left' : '0px'
            };
    }

    d3.select(this).select('ra-avsdropchartelement').style(dimensions);

    this.renderChart();
};

avsChartPrototype.onLegendUndock = function(){
    //Clear all styles and revert to what's on the style sheet.

    d3.select(this).select('ra-avsdropchartelement').style({
        'top' : '',
        'bottom' : '',
        'left' : '',
        'right' : ''
    });

    this.renderChart();
};*/

    avsChartPrototype.renderChart = function() {
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

        this.avsDropChart.removeChartTiles();
        this.avsDropChart.removeLegendTiles();

        // this.avsDropChart.setLegend(this.overlayLegend);
        this.avsDropChart.setTotalWidth(this.offsetWidth);
        this.avsDropChart.setTotalHeight(this.offsetHeight);
        this.avsDropChart.renderRequest(this.requestObject);
        console.log('rendering avs drop chart!');
    };

    // Create a new drop chart base and add this to it. avsdropchartbase is waaaaaay
    // to specific to x/y plots.
    avsChartPrototype.preRender = function() {};

    avsChartPrototype.validateParameter = function(param) {
        // Param must be a numeric, output parameter with the same data set as
        // already exists, if  there is a data set.
        if (
            param.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        } else if (param.properties.role !== 'OUTPUT') {
            return false;
        } else if (this.dataSetId && data.source !== this.dataSetId) {
            return false;
        } else if (param.properties.dataType === 'STRING') {
            return false;
        }

        return true;
    };

    avsChartPrototype.validateRender = function() {
        if (typeof this.parameter !== 'object') {
            return false;
        }

        return true;
    };

    avsChartPrototype.renderControlPanel = function(panel) {
        var that = this;

        // Add input params panel
        var paramsControl = panel.getControl('ra-parametercontrol2');
        paramsControl.title('Parameters');
        // inputsControl.nParameters(2);
        paramsControl.setFilter(this.validateParameter);
        paramsControl.setChangeListener(function(params) {
            that.setParameter(params[0]);
        });
        if (this.parameters instanceof Array) {
            paramsControl.updateController([this.parameter]);
        }

        this.controls = { paramsControl: paramsControl };
    };

    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avsparetochart = avsChartPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
