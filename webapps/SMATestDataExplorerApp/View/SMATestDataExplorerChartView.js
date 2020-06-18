define('DS/SMATestDataExplorerApp/View/SMATestDataExplorerChartView',
        ['UWA/Core',
            'UWA/Class/View',
            'DS/Controls/TooltipModel',
            'DS/SMATestDataExplorerApp/View/SMATestDataExplorerGraphView',
            'DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
            'DS/SMATestDataExplorerApp/SMATestDataExplorerMessage',
            'DS/WebappsUtils/WebappsUtils',
            'DS/Utilities/Utils',
            'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels'
            ],
            function (UWA, View, WUXTooltipModel, TestDataGraphView, TestDataSession, TestDataMessage, WebappsUtils, Utils, i18n) {
    'use strict';

    var ChartView = View.extend({
        tagName: 'div',
        className: 'tde-chart-container',
//        domEvents: { },
        graph: null,
        collection: null,
        modelID: null,
        resizing: false,
        stackedCharts: false,
        chartOptions: { },
        masterSeries: null,
        colors: [ 'red', 'black', 'green', 'blue', 'yellow', 'grey' ],
        domEvents: {
            'click' : function (e) {
                // handle the chart click event
                // highcharts does not propagate click events occurring in the chart area
                // resulting in zoom extent input fields not being committed (change event)
                // IR-610010-3DEXPERIENCER2018x
                var eventTarget = UWA.Event.getElement( e );
                
                // the input fields are positioned over the chart, so only fire the 
                // blur event when the click did not occur in the input field
                
                if( !( eventTarget.className === "tde-extent-input" || 
                       (eventTarget.classList && eventTarget.classList.contains && eventTarget.classList.contains( "tde-extent-input" ) ) ) ) {
                    var el = document.querySelector( ':focus' );
                    el && el.blur();
                }
            }
        },

        destroy: function() {
            this.container && this.graph && this.container.remove( this.graph );
            this.clearGraph();
            this.collection = null;
            this._parent();
        },

        setup: function() {
            TestDataSession.set( 'chartView', this );
            if( this.container ) {
                var self = this;
                this.container.addEvent('resize', function() {
                    self.resize();
                }); 
            }
            this.clearMutableOptions();
        },

        getCollection: function() {
            if( !this.collection ) {
                this.collection = TestDataSession.get('chartCollection' );
            }
            return this.collection;
        },

        // return the maximum number of data points to request based on the width of the
        // graph or if the graph has not yet been created, the width of its container
        numPlotPoints: function() {
            var num = 0;
            var rect;
            if( this.graph ) {
                var content = this.graph.getContent();
                if( content ) {
                    var sz = content.getSize();
                    if( sz ) {
                        num = sz.width;
                    }
                }
            }

            if( num === 0 ) {
                // if the plot has not been created, use the right panel size
                var rightPanel = document.querySelector( 'div.panel.right' );
                if( rightPanel ) {
                    rect = rightPanel.getBoundingClientRect();
                    if( rect && rect.width > num ) {
                        num = rect.width;
                    }
                } else if( this.container ) {
                    // if the plot and panel have not been created, use the container size
                    rect = this.container.getBoundingClientRect();
                    if( rect && rect.width && rect.width > num ) {
                        num = rect.width;
                    }
                }
            }
            
            return Math.round(num);
        },

        render: function ( options ) {	
            var self = this;
            this.container.setStyles({
                'text-align': 'left', 
                'background': 'white', 
                'height': '100%', 
                'width': '100%', 
                'padding': '30px 10px',
                'overflow': 'hidden',
            });

            var collection = this.getCollection();
            if( collection ) {
                if( this.model ) {
                    collection.push( this.model );
                }

                var mx = 0;
                var mn = 0;
                if( options ) {
                    options.zoomStart !== undefined &&  (mn = options.zoomStart);
                    options.zoomEnd   !== undefined &&  (mx = options.zoomEnd);
                }

                this.getChartData(  { bounds : { min: mn, max: mx } } )
                .then( function( response ) {
                    self.createGraph( response ).reflow();
                })
                .catch( function( err ) {
                    var errorMessage = (err && err.message) || i18n[ 'plotdata-ws-fail' ];
                    TestDataMessage.displayMessage('error', errorMessage);
                });
            }
            return this;
        },

        addSeries: function( options ) {
            var append = this.graph && this.graph.hasChart();

            if( append && options.models && options.models.length ) {
                var self = this;

                // get existing bounds
                var bounds = this.graph.getBounds();

                // request chart data for the full range, for global min
                // and max to be updated
                this.getChartData(  { bounds : { min: 0, max: 0 }, models: options.models } )
                .then( function( response ) {
                    if( bounds && !( ( bounds.x.min === 0 && bounds.x.max === 0 ) || 
                            ( bounds.x.min === response.xmin &&  bounds.x.max === response.xmax ) ) ) {
                        // if chart is zoomed, request the data for the
                        // zoomed range
                        self.getChartData(  { bounds : { min: Math.round( bounds.x.min ), max: Math.round( bounds.x.max ) }, models: options.models } )
                        .then( function( response ) {
                            self.createGraph( response ).reflow();
                        });
                    } else {
                        self.createGraph( response ).reflow();
                    }
                });
            } else {
                this.render( options );
            }
        },

        // called when the graph needs to be resized
        // using debounce to limit the rate of firing of
        // this (costly) function to once every 1/2 a second
        resize: Utils.debounce( function() {
            if( !this.resizing && this.graph ) {
                var self = this;
                this.resizing = true;
                this.graph.resize();
                self.resizing = false;
            }
        }, 500),


        clearMutableOptions: function( index ) {
            this.chartOptions = [];
        },

        getGlobalBounds: function ( index ) {
            var bound = null;
            if( index !== undefined && index !== null ) {
                if( index < this.chartOptions.stacked.length && this.chartOptions.stacked[ index ].globalBounds ) {
                    bound = this.chartOptions.stacked[ index ].globalBounds;
                } 
            } else if( this.chartOptions.overlay && this.chartOptions.overlay.globalBounds ) {
                bound =  this.chartOptions.overlay.globalBounds;
            }
            return bound;
        },

        getStackedChartOptions: function( index ) {
            var options;
            if( this.chartOptions.stacked && index <  this.chartOptions.stacked.length ) {
                options = this.chartOptions.stacked[index] ;
            }
            return options;
        },

        _makeXaxisLabel: function( items ) {
            var unit;
            var label;
            if( items) {
                items.forEach( function( item ) {
                    if( unit || label ) {
                        if( item.xunit !== unit ) {
                            console.log( 'ERROR: incompatible X axis units in datasets to be plotted');
                            TestDataMessage.displayMessage( 'error', i18n['incompatible-units'], i18n['invalid-plot-data'] );
                            unit  = '';
                            return;
                        }
                        if( item.xlabel !== label ) {
                            console.log( 'WARNING: different X axis labels in datasets to be plotted, setting label to X');
                            label = 'X';
                            return;
                        }
                    } else {
                        label = item.xlabel;
                        unit  = item.xunit;
                    }
                });
            }
            return unit ? label + ' (' + unit + ')' : label;
        },

        _saveMutableOptions: function( data ) {
            // Preserve previous overlay chart max/min line display setting
            var overlayGlobalDisplay = false;
            var overlayLocalDisplay = false;
            if( this.chartOptions.overlay ) {
                if( this.chartOptions.overlay.showGlobalMaxMinLines !== undefined ) {
                    overlayGlobalDisplay = this.chartOptions.overlay.showGlobalMaxMinLines;
                }
                if( this.chartOptions.overlay.showMaxMinLines !== undefined ) {
                    overlayLocalDisplay = this.chartOptions.overlay.showMaxMinLines;
                }
            }

            var stackedGlobalDisplay = [];
            var stackedLocalDisplay = [];
            if( this.chartOptions.stacked ) {
                this.chartOptions.stacked.forEach( function( opt ) {
                    stackedGlobalDisplay.push( opt.showGlobalMaxMinLines );
                    stackedLocalDisplay.push( opt.showMaxMinLines );
                });
            }

            // Reset options
            this.chartOptions.overlay = {};
            this.chartOptions.stacked = [];

            if( data && data.length ) {
                this.chartOptions.xAxisLabel = this._makeXaxisLabel( data );

                var view = this;
                var xmin, xmax, ymin, ymax;
                var yaxes = [];
                data.forEach( function( item, indx ) {
                    // get max and min for overlay bounds
                    xmin = indx === 0 ? item.xmin : Math.min( xmin, item.xmin );
                    xmax = indx === 0 ? item.xmax : Math.max( xmax, item.xmax );
                    ymin = indx === 0 ? item.ymin : Math.min( ymin, item.ymin );
                    ymax = indx === 0 ? item.ymax : Math.max( ymax, item.ymax );

                    yaxes.push( { label: item.ylabel, unit: item.yunit } );

                    // set stacked bounds
                    view.chartOptions.stacked.push( {
                        globalBounds: { x: { min: item.xmin, max: item.xmax },
                            y: { min: item.ymin, max: item.ymax } },
                            yAxisLabel: view._makeStackedYaxisLabel( item ),
                            showGlobalMaxMinLines: stackedGlobalDisplay.length > indx ? stackedGlobalDisplay[indx] : false,
                                    showMaxMinLines: stackedLocalDisplay.length > indx ? stackedLocalDisplay[indx] : false

                    });
                });

                // set overlay bounds
                this.chartOptions.overlay = { 
                        globalBounds: { x: { min: xmin, max: xmax },
                            y: { min: ymin, max: ymax } },
                            yAxisLabel: view._makeOverlayYaxisLabel( yaxes ),
                            showGlobalMaxMinLines: overlayGlobalDisplay,
                            showMaxMinLines: overlayLocalDisplay
                };
            }
        },

        _updateGlobalBounds: function( data ) {
            var self = this;
            data.forEach( function( model, indx ) {
                self.chartOptions.stacked.push( {
                    globalBounds: { x: { min: model.xmin, max: model.xmax },
                        y: { min: model.ymin, max: model.ymax } },
                        yAxisLabel: self._makeStackedYaxisLabel( model ),
                        showGlobalMaxMinLines: false,
                        showMaxMinLines:  false
                });


                if( self.chartOptions.overlay ) {
                    // TODO verify y axis units/label are compatible with existing overlay y axis
                    var bounds = self.getGlobalBounds();
                    self.chartOptions.overlay.globalBounds = { 
                            x: { min: bounds ? Math.min( model.xmin, bounds.x.min ) : model.xmin, max: bounds ? Math.max( model.xmax, bounds.x.max ) : model.xmax },
                            y: { min: bounds ? Math.min( model.ymin, bounds.y.min ) : model.ymin, max: bounds ? Math.max( model.ymax, bounds.y.max ) : model.ymax } 
                    };
                }
            });
        },

        _makeStackedYaxisLabel: function( axis ) {
            var ylabel = axis.ylabel ? axis.ylabel : '';
            if( axis.yunit ) {
                ylabel += ' (' + axis.yunit + ')';
            }
            return ylabel;
        },

        _makeOverlayYaxisLabel: function( yaxes ) {
            var unit, label;
            yaxes.forEach( function( axis ) {
                if( unit || label ) {
                    if( axis.unit !== unit ) {
                        console.log( 'ERROR: incompatible Y axis units in datasets to be plotted');
                        TestDataMessage.displayMessage( 'error', i18n['incompatible-units'], i18n['invalid-plot-data'] );
                        unit  = '';
                        return;
                    }
                    if( axis.label !== label ) {
                        label = 'Y';
                        return;
                    }
                } else {
                    label = axis.label;
                    unit  = axis.unit;
                }
            });
            return unit ? label + ' (' + unit + ')' : label;
        },

        getMasterSeries: function() {
            return this.masterSeries;
        },

        getXaxisLabel: function () {
            var label;
            if( this.chartOptions ) {
                label = this.chartOptions.xAxisLabel;
            }
            return label;
        },

        getYaxisLabel: function ( index ) {
            var label;
            if( this.isChartStacked() ) {
                if( index !== undefined || index !== null && index >= 0 && index < this.chartOptions.stacked.length ) {
                    label = this.chartOptions.stacked[index].yAxisLabel;
                } else {
                    console.log( "INTERNAL ERROR: bad stacked chart index");
                }
            } else {
                label = this.chartOptions.overlay.yAxisLabel;
            }
            return label;
        },

        // toggle the display of horizontal lines showing the current min and max values
        toggleMaxMinLines: function( options ) {
            options.show = !this.getMaxMinLineDisplay( options );
            this.setMaxMinLineDisplay( options );
            return this;
        },

        setMaxMinLineDisplay: function ( options ) {
            var show = options.show === undefined || options.show ;
            if( this.isChartStacked() ) {
                if( options.index !== undefined && this.chartOptions.stacked && this.chartOptions.stacked.length > options.index ) {
                    if( options.global ) {
                        this.chartOptions.stacked[ options.index ].showGlobalMaxMinLines = show;
                    } else {
                        this.chartOptions.stacked[ options.index ].showMaxMinLines = show;
                        this.graph.displayMaxMinLines( options );
                    }
                }
            } else {
                if( this.chartOptions.overlay ) {
                    if( options.global ) {
                        this.chartOptions.overlay.showGlobalMaxMinLines = show;
                    } else {
                        this.chartOptions.overlay.showMaxMinLines = show;
                        this.graph.displayMaxMinLines( options );
                    }
                }
            }
        },


        getMaxMinLineDisplay: function ( options ) {
            var show = false;
            if( this.isChartStacked() ) {
                if( options.index !== undefined && this.chartOptions.stacked && this.chartOptions.stacked.length > options.index ) {
                    if( options.global ) {
                        show = this.chartOptions.stacked[ options.index ].showGlobalMaxMinLines;
                    } else {
                        show = this.chartOptions.stacked[ options.index ].showMaxMinLines;
                    }
                }
            } else {
                if( this.chartOptions.overlay ) {
                    if( options.global ) {
                        show = this.chartOptions.overlay.showGlobalMaxMinLines;
                    } else {
                        show = this.chartOptions.overlay.showMaxMinLines;
                    }
                } 
            }
            return show;
        },

        // get plot data using the width of the graph to define the number of points to request
        getChartData: function( opts ) {
            // if opts.models is set, series are being appended to the chart,
            // otherwise request plot data for all models in the collection
            var view = this;
            return new Promise( function( resolve, reject ) {
                var options = {
                        numPoints: opts.numPoints ? opts.numPoints : view.numPlotPoints(),
                                zoomStart: opts.bounds.min,
                                zoomEnd:   opts.bounds.max 
                };

                var promises = [];
                if( opts.models ) {
                    // when opts.models is set, series are being appended to the chart
                    opts.models.forEach( function( model ) {
                        promises.push( model.getPlotData( options ) );
                    });
                } else {
                    // create chart of all models in the collection
                    var collection = view.getCollection();
                    collection && collection.forEach( function( model ) {
                        promises.push( model.getPlotData( options ) );
                    });

                    var clientCollection = TestDataSession.get( 'clientCollection' );
                    clientCollection && clientCollection.forEach( function( model ) {
                        promises.push( model.getPlotData( options ) );
                    });
                }

                Promise.all( promises )
                .then( function( response ) {
                    var data = view.prepareData( response );
                    if( data ) {
                        if( opts.bounds.min === 0 && opts.bounds.max === 0 ) {
                            // When bounds min & max are 0, get all values (i.e. not zoomed)
                            // Set global bounds and assign first response to master
                            if( opts.models ) {
                                view._updateGlobalBounds( response );
                            } else {
                                view._saveMutableOptions( response );
                            }
    
                            if( !( view.graph && view.graph.hasChart() ) ) {
                                view.masterSeries = data;
                            }
                        }
                        resolve( data );
                    } else {
                        reject( new Error( i18n[ 'item-not-supported' ]) );
                    }
                })
                .catch( function( err ) {
                    TestDataMessage.displayMessage('error', err );
                    reject( err );
                });
            });
        },

        onFacetSelect: function () {
        },

        onFacetUnselect: function () {
        },

        // return a valid filename based on ASAM object names
        chartTitleAsFilename: function( index ) {
            var fname;
            var chartView = TestDataSession.get('chartView');
            if( chartView && chartView.graph ) {
                var detail = chartView.graph.getDetailChart( index );
                if( detail && detail.title ) {
                    var title = detail.title.textStr;
                    fname = title && this.santizeFilename( title );
                }
            }
            return fname;
        },

        santizeFilename: function( name ) {
            return name.replace(/[\/\?\<\>\\\:\*\|\"]/gi, '-').replace(/ {2,}/g, ' ' ).replace(/_{2,}/g, '_' ).replace(/-{2,}/g, '-' );
        },

        clearProperties: function() {
            var collection = this.getCollection();
            collection && collection.forEach( function( model ) {
                model.markPropertiesObsolete();
            });
        },

        isIE: function() {
            return document.getElementsByTagName('html')[0].classList.contains('ie');
        },

        clearGraph: function() {
            if( this.graph ) {
                this.graph.destroy(); 
                this.graph = null;
            }
        },         

        toggleStackedDisplay: function() {
            if( this.graph ) {
                this.graph.toggleStackedDisplay();
                this.stackedCharts = this.graph.detailStacked();
            }
        },

        isChartStacked: function() {
            if( this.graph ) {
                return this.graph.detailStacked();
            }
            return this.stackedCharts;
        },

        getStackedChartIndex: function( chart ) {
            var chartIndex;
            var container = chart && chart.renderTo;
            var indx = container && parseInt( container.getAttribute( 'containerIndex' ) );
            if( indx !== undefined && indx !== null) {
                chartIndex = indx;
            }
            return chartIndex;
        },

        prepareData: function( data ) {
            // Collect data from existing curves and append new data
            // Compute range & domain bounds and populate seriesData array
            var pdata = null;
            if( !data || !Array.isArray( data ) || !data.length || !data[0] ) {
                return pdata;
            }

            // TODO: verify data to be plotted are compatible
            var self = this;
            pdata = UWA.clone( data[0] );
            pdata.seriesData = [];

            var numSeries = this.graph && this.graph.numSeries();
            var numValues = 0;
            if( numSeries ) {
                // Collect data from existing curves and get current chart bounds
                var bounds = this.graph.getBounds();
                pdata.xmin = bounds.x.min;
                pdata.xmax = bounds.x.max;
                pdata.ymin = bounds.y.min;
                pdata.ymax = bounds.y.max;

                // collect all series from the existing chart
                this.graph.getDetailSeries().forEach( function( s ) {
                    pdata.seriesData.push( UWA.clone( s ) );
                });
            } else {
                // Chart currently has no curves, set the bounds using input data
                data.forEach( function( item, indx ) {
                    pdata.xmin = indx === 0 ? item.xmin : Math.min( pdata.xmin, item.xmin ); 
                    pdata.xmax = indx === 0 ? item.xmax : Math.max( pdata.xmax, item.xmax );
                    pdata.ymin = indx === 0 ? item.ymin : Math.min( pdata.ymin, item.ymin ); 
                    pdata.ymax = indx === 0 ? item.ymax : Math.max( pdata.ymax, item.ymax );
                });
            }

            data.forEach( function( item, indx ) {     
                // update the y-bounds
                pdata.ymin = Math.min( pdata.ymin, item.ymin ); 
                pdata.ymax = Math.max( pdata.ymax, item.ymax );

                pdata.seriesData.push( { 
                    name: item.title,
                    color: self.colors[ (indx + numSeries) % self.colors.length ], 
                    data: item.values,
                    pointInterval:  (item.xmax - item.xmin )/( item.numValues - 1 ),
                    pointStart: item.xmin
                });
            });
            return pdata;
        },

        createGraph: function( data ) {
            var stackedCharts = this.isChartStacked();
            var multipleCurves = data.seriesData.length > 1;

            var bounds;
            if( this.getMaxMinLineDisplay( { global: true } ) ) {
                if( !stackedCharts ) {
                    bounds = this.getGlobalBounds();
                }
            }

            this.clearGraph();
            var self = this;

            this.graph = new TestDataGraphView(  { 
                context: this,
                stacked: stackedCharts,
                title: { text: data.title, margin: 50 },
                subtitle: { text: null },
                chart: { 
                    type : 'line',
                    marginLeft: 80,  
                    marginRight: 20,
                    animation: false,
                    zoomType: 'x'
                },
                xAxis: { 
                    type: 'linear',
                    minTickInterval: 1, 
                    gridLineColor: '#CCD6EB', 
                    gridLineWidth: 1,
                    title: { text: self.getXaxisLabel() }, 
                    allowDecimals: false,
                    maxPadding: 0,
                    minPadding:0,
                    events: {
                        afterSetExtremes: function(event){
                            var extremes = this.getExtremes();
                            var chartView = TestDataSession.get( 'chartView' );
                            extremes && chartView && chartView.graph && chartView.graph.setBounds( extremes );
                        }
                    }
                },
                yAxis: { 
                    labels: { enabled: true }, 
                    floor:   bounds ? bounds.y.min : data.ymin, 
                    ceiling: bounds ? bounds.y.max : data.ymax, 
                            gridLineColor: '#CCD6EB', 
                            gridLineWidth: 1,
                            title: { text: self.getYaxisLabel() },
                            tickColor: '#CCD6EB', 
                            tickLength: 10, 
                            tickWidth: 1
                },
                series: data.seriesData,
                legend: { enabled: false },
                plotOptions: {
                    line: { lineWidth: 1 },
                    series: {
                        pointStart: data.xmin,
                        marker: { states: { hover: { radius: 2 } }, enabled: false },
                        states: { hover: {  
                            lineWidthPlus: multipleCurves ? 1 : 0,
                                    halo: { size: 6, attributes: { 'stroke-width': 0, opacity: 0.5 } }
                        } 
                        },
                        animation: false
                    }
                },
                tooltip: {
                    // to place the tooltip at a specific position use the 'positioner'
                    // positioner: function () {
                    //     return { x:  80, y: 0 };
                    // },
                    formatter: function () {
                        return 'X: ' + Math.round(this.x) + '<br>Y: ' + this.y;
                    },
                    crosshairs: [true], 
                    shape: 'square',
                    shadow: false,
                    borderWidth: 0,
                    backgroundColor: '#FFFFFF',
                    valueSuffix: data.yunit
                },
                credits: { enabled: false },
                exporting: {
                    url: "https://export.highcharts.com/",
                    buttons: {
                        contextButton: {
                            menuItems: [ {
                                    text: i18n['toggle-cur-minmax-lines'], 
                                    onclick: function ( e ) {
                                        var chartView = TestDataSession.get( 'chartView' );
                                        if( chartView ) {
                                            var options = { global: false };
                                            if( chartView.isChartStacked() ) {
                                                var chart = this.userOptions && this.userOptions.chart;
                                                if( chart ) {
                                                    options.index = chartView.getStackedChartIndex( chart );
                                                } else {
                                                    console.log( "INTERNAL ERROR: chart not found");
                                                }
                                            }
                                            chartView.toggleMaxMinLines( options );
                                        } 
                                    }
                                }, {
                                    text: i18n['toggle-gbl-minmax-lines'], 
                                    onclick: function ( e ) {
                                        var chartView = TestDataSession.get( 'chartView' );
                                        if( chartView ) {
                                            var options = { global: true };
                                            if( chartView.isChartStacked() ) {
                                                var chart = this.userOptions && this.userOptions.chart;
                                                if( chart ) {
                                                    options.index = chartView.getStackedChartIndex( chart );
                                                } else {
                                                    console.log( "INTERNAL ERROR: chart not found");
                                                }
                                            } 
                                            chartView.toggleMaxMinLines( options );
                                            chartView.graph && chartView.graph._drawDetail();
                                        }
                                    } 
                                }, { 
                                    text: i18n.fitall, 
                                    onclick: function ( e ) {
                                        var chartView = TestDataSession.get( 'chartView' );
                                        chartView && chartView.graph && chartView.graph.fitAll();
                                    } 
                                }, { 
                                    separator: true, 
                                    className: 'tde-sep-class'
                                }, { 
                                    text: i18n.downloadCSV,   
                                    onclick: function ( e ) {
                                        var chart = this.userOptions && this.userOptions.chart;
                                        var chartView = TestDataSession.get( 'chartView' );
                                        if( chartView ) {
                                            if( chartView.isChartStacked() ) {
                                                var chart = this.userOptions && this.userOptions.chart;
                                                var index = chartView.getStackedChartIndex( chart );
                                                if( index !== undefined ) {
                                                    chartView.downloadCSV( index );
                                                }
                                            } else {
                                                chartView.downloadCSV();
                                            }
                                        }
                                    } 
                                }, { 
                                    text: i18n.downloadPDF,   
                                    onclick: function ( e ) {
                                        var chart = this.userOptions && this.userOptions.chart;
                                        var chartView = TestDataSession.get( 'chartView' );
                                        if( chartView && chart ) {
                                            var index = chartView.getStackedChartIndex( chart );
                                            if( index !== undefined ) {
                                                var fname = chartView.chartTitleAsFilename( index );
                                                this.exportChart({  type: 'application/pdf', filename: fname ? fname : 'chart' } );
                                            }
                                        }
                                    } 
                                }, { 
                                    text: i18n.downloadPNG,   
                                    onclick: function ( e ) {
                                        var chart = this.userOptions && this.userOptions.chart;
                                        var chartView = TestDataSession.get( 'chartView' );
                                        if( chartView && chart ) {
                                            var index = chartView.getStackedChartIndex( chart );
                                            if( index !== undefined ) {
                                                var fname = chartView.chartTitleAsFilename( index );
                                                this.exportChart( { filename: fname ? fname : 'chart' } );
                                            }
                                        }
                                    } 
                                }, { 
                                    text: i18n.downloadJPEG,  
                                    onclick: function ( e ) {
                                        var chart = this.userOptions && this.userOptions.chart;
                                        var chartView = TestDataSession.get( 'chartView' );
                                        if( chartView && chart ) {
                                            var index = chartView.getStackedChartIndex( chart );
                                            if( index !== undefined ) {
                                                var fname = chartView.chartTitleAsFilename( index );
                                                this.exportChart( { type: 'image/jpeg', filename: fname ? fname : 'chart' } );
                                            }
                                        }
                                    } 
                                },  { 
                                    text: i18n.downloadSVG,   
                                    onclick: function ( e ) {
                                        var chart = this.userOptions && this.userOptions.chart;
                                        var chartView = TestDataSession.get( 'chartView' );
                                        if( chartView && chart ) {
                                            var index = chartView.getStackedChartIndex( chart );
                                            if( index !== undefined ) {
                                                var fname = chartView.chartTitleAsFilename( index );
                                                this.exportChart( { type: 'image/svg+xml', filename: fname ? fname : 'chart' } );
                                            }
                                        }
                                    } 
                                }, { 
                                    separator: true, 
                                    style: 'margin-top: 3px; margin-bottom: 3px; border-top: 1px solid #ccd6eb;' 
                                }, { 
                                    text: i18n['print-chart'],
                                    onclick: function ( e ) { 
                                        this.print(); 
                                    }
                                }
                            ]
                        }
                    }
                }
            });
            this.graph.render().inject( this.container );
            return this.graph;
        },

        // dump the plot values for the chart at the current zoom level
        // Note: all of the points in the zoom range will be returned,
        // not reduced by the chart resolution
        downloadCSV: function( index ) {
            var bounds = this.graph._detailBounds;
            var mx = Math.round( bounds.x.max );
            var mn = Math.round( bounds.x.min );

            var self = this;
            var isOverlay = index === undefined;
            var collection = this.getCollection();
            if( !collection ) {
                console.log( "INTERNAL ERROR: collection not found");
                return;
            }

            var options = { min: mn, max: mx, numModels: 0, data: [] };
            if( isOverlay ) {
                options.numModels = collection.length;
                var promises = [];
                collection && collection.forEach( function( model ) {
                    promises.push( self.collectData( model, options ) );
                });

                Promise.all( promises )
                .then( function() {
                        self.writeCSV( options );
                    })
                    .catch( function( err ) {
                        var errorMessage = (err && err.message) || i18n[ 'plotdata-ws-fail' ];
                        TestDataMessage.displayMessage( 'error', errorMessage );
                });
            } else {
                var model = index < collection.length && collection[ index ];
                if( model ) {
                    options.title = model.get( 'name' );
                    model.getPlotData( {
                        numPoints: mx-mn,
                        zoomStart: mn,
                        zoomEnd:   mx
                    })
                    .then( function( data ) {
                        if( data ) {
                            options.data.push( data.values );
                            self.writeCSV( options );
                        } else {
                            TestDataMessage.displayMessage('error', i18n[ 'plotdata-ws-fail']);
                        }
                    })
                    .catch( function( err ) {
                        var errorMessage = (err && err.message) || i18n[ 'plotdata-ws-fail' ];
                        TestDataMessage.displayMessage( 'error', errorMessage );
                    });
                }
            }
        },

        collectData: function( model, options ) {
            return new Promise( function( resolve, reject ) {
                model.getPlotData( {
                    numPoints: options.max - options.min,
                    zoomStart: options.min,
                    zoomEnd:   options.max
                })
                .then( function( data ) {
                    if( data ) {
                        if( options.numModels === 1 ) {
                            options.title = model.get( 'name' );
                        }
                        options.data.push(data.values);
                    }
                    resolve( options )
                })
            })
        },

        writeCSV: function( options ) {
            var maxlen = 0;
            options.data.forEach( function( data ) {
                if( data.length > maxlen )
                    maxlen = data.length;
            });

            var filename = options.title ? this.santizeFilename( options.title ) : 'chart';
            filename += '.csv';
            var delim = ',';
            var x = options.min;

            var i;
            var text = this.getXaxisLabel() + delim ;
            var numCurves = options.data.length;
            for( i = 0; i < numCurves; ++i ) {
                text += this.getYaxisLabel( i ) + delim;
            }
            text += '\n';

            for( i = 0; i < maxlen; ++i ) {
                text += (x++) + delim;
                options.data.forEach( function( values ) {
                    if( i < values.length ) {
                        text += values[i];
                    }
                    text += delim;
                });
                text += '\n';
            }

            var blob = new Blob( [ text ], { type: 'text/csv' } );
            if( this.isIE() ) {
                window.navigator.msSaveOrOpenBlob( blob, filename );
            } else {
                var url = window.URL.createObjectURL( blob );
                var element = document.createElement('a');
                element.href = url;
                element.download = filename;
                element.style.display = 'none';
                document.body.appendChild( element );
                element.click();
                element.onload = function () {
                    window.URL.revokeObjectURL( url );
                };
                document.body.removeChild( element );
            }
        }
    });
    return ChartView;
});

