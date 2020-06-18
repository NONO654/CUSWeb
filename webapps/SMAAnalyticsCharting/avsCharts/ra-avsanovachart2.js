(function(GLOBAL, template) {
    if (typeof GLOBAL.DS.RAComponents.avsanovachart !== 'undefined') {
        return;
    }

    var avsChartPrototype = {
        is: 'ra-avsanovachart2',
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

    avsChartPrototype.setupLegend = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.setupLegend.call(
            this,
            this.getDefaultLegend(
                this.requestObject.chartRequest.legends[0].width,
                this.requestObject.chartRequest.legends[0].height
            )
        );
        // this.overlayLegend.classList.add('hidden');
    };

    avsChartPrototype.setupData = function() {
        var width = this.querySelector('ra-avsdropchartelement').offsetWidth,
            height = this.querySelector('ra-avsdropchartelement').offsetHeight,
            charts = JSON.parse(JSON.stringify(this.chartProperties.defaults));

        this.requestObject = {
            chartRequest: { width: width, height: height, charts: charts }
        };

        this.parameters = [];

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
        this.avsDropChart.setLegend(this.overlayLegend);
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
            that.addParameter(data.properties);
        });
    };

    avsChartPrototype.updateParameters = function(paramsArray) {
        var that = this;
        this.parameters = paramsArray;

        var dataSetId = paramsArray[0].source;

        if (dataSetId !== this.dataSetId) {
            console.error('ERROR: Changed data sets! Things will break!!!');
        }

        this.parameters.forEach(function(d) {
            if (d.source !== dataSetId) {
                console.error('ERROR: Mismatched data sets!');
            }
        });

        if (!this.dataSet) {
            // If there is no dataSet, find one matching the dataSetId for the param
            // or make one.

            // Check if there exists a data set for the parameter
            var dsKey = Object.keys(
                GLOBAL.DS.RAObjects.datasets
            ).forEach(function(key) {
                if (
                    GLOBAL.DS.RAObjects.datasets[key].metadata.parentId !==
                    dataSetId
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
                    metadata: { parentId: dataSetId },
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

            this.dataSetId = dataSetId;
        }

        this.parameters.forEach(function(paramData) {
            if (!that.dataSet.hasColumn(paramData.id)) {
                // TODO: Figure out how to handle race condition.
                var metadata = {
                    id: paramData.id,
                    displayName:
                        paramData.alias ||
                        paramData.displayName ||
                        paramData.id,
                    dataType: 'REAL',
                    status: 'NOT_READY'
                };

                that.dataSet.setColumn(paramData.id, {
                    values: [],
                    metadata: metadata
                });

                that.controls.paramsControl.updateController(that.parameters);
            }
        });

        var paramIds = this.parameters.map(function(d) {
            return d.id;
        });

        var requestObject = { datasetId: this.dataSetId, paramIDs: paramIds };

        this.dataProvider.executeSupport(
            'getAnovaTable',
            requestObject,
            function(data) {
                data = JSON.parse(data);

                that.dataSet.updateColumn('terms', data.terms);
                that.parameters.forEach(function(paramData) {
                    that.dataSet.updateColumn(paramData.id, data[paramData.id]);
                });
                that.renderChart();
            },
            this,
            'anovaTable'
        );
    };

    avsChartPrototype.addParameter = function(paramData) {
        var that = this;

        this.parameters.push(paramData);

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

            var paramIds = this.parameters.map(function(d) {
                return d.id;
            });

            var requestObject = {
                datasetId: this.dataSetId,
                paramIDs: paramIds
            };

            this.controls.paramsControl.updateController(this.parameters);

            this.dataProvider.executeSupport(
                'getAnovaTable',
                requestObject,
                function(data) {
                    data = JSON.parse(data);

                    that.dataSet.updateColumn('terms', data.terms);
                    that.dataSet.updateColumn(paramData.id, data[paramData.id]);
                    that.renderChart();
                },
                this,
                'anovatable'
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

        var dataParams = { raw: [{ guid: 'terms' }] };

        this.requestObject.chartRequest.charts[0].x = {
            data: {
                type: 'binnedDiscrete',
                guid: 'terms',
                unique: false,
                sortOrder: 'DESCENDING'
            },
            axisProperties: { title: { text: 'Terms' } }
        };

        var ySeries = this.parameters.map(function(d) {
            dataParams.raw.push({ guid: d.id });

            return { type: 'raw', guid: d.id };
        });

        // y-param is always null, since it's variation in an ANOVA.
        this.requestObject.chartRequest.charts[0].y = {
            series: ySeries,
            axisProperties: { title: { text: 'Contribution to Variance' } }
        };

        this.requestObject.chartRequest.charts[0].color = {
            // defaultColor : '#c74646',
            type: 'bySeries'
        };

        var legendWidth, legendHeight;

        var legendWidth =
            this.overlayLegend && this.overlayLegend.querySelector('.content')
                ? this.overlayLegend.querySelector('.content').offsetWidth
                : 300;

        var legendHeight =
            this.overlayLegend && this.overlayLegend.querySelector('.content')
                ? this.overlayLegend.querySelector('.content').offsetHeight
                : 100;

        var orientation =
            this.requestObject.chartRequest.legends &&
            this.requestObject.chartRequest.legends.length > 0
                ? this.requestObject.chartRequest.legends[0]
                : 'horizontal';

        var orientation = this.legendOrientation || 'horizontal';

        this.requestObject.chartRequest.legends = [
            {
                width: legendWidth,
                height: legendHeight,
                orientation: orientation,
                type: 'color',
                guid: 'anovaLegend',
                chartGuid: this.requestObject.chartRequest.charts[0].guid
            }
        ];

        if (!this.overlayLegend) {
            this.setupLegend();
        }

        /*console.log('Legend: ');
    console.log({
        'width' : this.overlayLegend.querySelector('.content').offsetWidth,
        'height' : this.overlayLegend.querySelector('.content').offsetHeight,
        'orientation' : 'horizontal'
    });*/

        this.requestObject.chartRequest.data = dataParams;

        this.requestObject.datasets = [this.dataSet.getDataSetObject()];

        this.requestObject.datasetId = this.dataSet.id;

        console.log(this.requestObject);
    };

    avsChartPrototype.resize = function() {
        this.renderChart();
    };

    avsChartPrototype.onLegendDock = function(legend) {
        this.updateDockDirection(legend);

        var dir = legend.dockDirection;

        var dimensions = {};

        if (dir === 'top') {
            dimensions = {
                top: legend.getDockHeight() + 'px',
                bottom: '0px',
                left: '0px',
                right: '0px'
            };
        } else if (dir === 'bottom') {
            dimensions = {
                bottom: legend.getDockHeight() + 'px',
                top: '0px',
                left: '0px',
                right: '0px'
            };
        } else if (dir === 'left') {
            dimensions = {
                top: '0px',
                bottom: '0px',
                right: '0px',
                left: legend.getDockWidth() + 'px'
            };
        } else if (dir === 'right') {
            dimensions = {
                top: '0px',
                bottom: '0px',
                right: legend.getDockWidth() + 'px',
                left: '0px'
            };
        }

        d3.
            select(this).
            select('ra-avsdropchartelement').
            style(dimensions);

        this.renderChart();
    };

    avsChartPrototype.onLegendUndock = function() {
        // Clear all styles and revert to what's on the style sheet.

        d3.
            select(this).
            select('ra-avsdropchartelement').
            style({ top: '', bottom: '', left: '', right: '' });

        this.renderChart();
    };

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

        // if (this.overlayLegend === null && typeof
        // this.requestObject.chartRequest.legend !== 'undefined') {
        //    this.setupLegend(this.requestObject.chartRequest.legend.width,
        //      this.requestObject.chartRequest.legend.height);
        //}

        /*if (this.avsDropChart === null) {
        this.avsDropChart = document
                .createElement('ra-avsdropchartelement');
        this.avsDropChart.setDataProvider(this.dataProvider);
        this.divs.chartDropZone.appendChild(this.avsDropChart);
        console.log('creating avs drop chart!');

    } else {*/
        this.avsDropChart.removeChartTiles();
        this.avsDropChart.removeLegendTiles();
        //}
        this.avsDropChart.setLegend(this.overlayLegend);
        this.avsDropChart.setTotalWidth(this.offsetWidth);
        this.avsDropChart.setTotalHeight(this.offsetHeight);
        this.avsDropChart.renderRequest(this.requestObject, this, 'anovaChart');
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
        if (this.parameters.length < 1) {
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
            that.updateParameters(params);
        });
        if (this.parameters instanceof Array) {
            paramsControl.updateController(this.parameters);
        }

        this.controls = { paramsControl: paramsControl };
    };

    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avsanovachart2 = avsChartPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
