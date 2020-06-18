define('DS/SMATestDataExplorerApp/View/SMATestDataExplorerGraphView', [
    'UWA/Core',
    'UWA/Class/View',
    'DS/UIKIT/Alert',
    'DS/SMAHighcharts/Highcharts',
    'DS/Controls/TooltipModel',
    'DS/SMATestDataExplorerApp/SMATestDataExplorerMessage',
    'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels',
    'css!DS/SMATestDataExplorerApp/View/SMATestDataExplorerGraphView'
    ],

    function ( UWA, View, UIKITAlert, Highcharts,  WUXTooltipModel, TestDataMessage, i18n ) {
    'use strict';

    var Graph = View.extend( {
        tagName: 'div',
        className: 'tde-graph-nav-view',
        _context: null,

        _overlayOptions: null,
        _stackedOptions: [],
        _masterOptions: null,

        _detailcontainer: null,
        _mastercontainer: null,
        _stackedContainers: [],

        _stackedCharts: [],
        _overlayChart: null,
        _masterChart: null,

        _slider: {},
        _detailBounds: {},
        _minExt: null,
        _maxExt: null,
        _extLabel: null,
        _maxExtChar: 12,
        _stacked: false,
        _resizing: false,

        setup: function( options ) {
            var self = this;

            if( options.context ) {
                this._context = options.context;
                delete options.context;
            }

            if( options.stacked ) {
                this._stacked = true;
                delete options.stacked;
            }

            this._slider = { currEl: null, minBtn: null, maxBtn: null, panBtn: null, 
                    btnGeom: { w: 9, h: 19, r: 3, offset: { x: 4, y: 9 } }, clickDelta: 0, minDist: 10, panHeight: 9, panOffset: 5 };

            this._detailBounds =  { x: { min: null, max: null }, y: { min: null, max: null } };
            this._overlayOptions = options;

            if( this._overlayOptions.xAxis.type === 'datetime' ) {
                this._overlayOptions.xAxis.categories = null;
            }

            if( !this.hasChart() ) {
                this._masterOptions = this._getMasterOptions();
            }

            this._detailBounds.x.min = 0;
            if( options.plotOptions && options.plotOptions.series && options.plotOptions.series.pointStart ) {
                this._detailBounds.x.min = Math.round( options.plotOptions.series.pointStart );
            }

            this._detailBounds.x.max = this._detailBounds.x.min + Math.round( (options.series[0].data.length-1) * options.series[0].pointInterval );
            this._detailBounds.y.min = options.yAxis.floor;
            this._detailBounds.y.max = options.yAxis.ceiling;

            this._parent(options);
            return this;
        },

        hasChart: function() {
            var bool = false;
            if( this._stacked ) {
                if( this._stackedCharts && this._stackedCharts.length ) {
                    bool = true;
                }
            } else {
                bool = this._overlayChart ? true : false;
            }
            return bool;
        },

        getDetailChart: function( index ) {
            var chart;
            if( this._stacked ) {
                chart = this.getStackedChart( index );
            } else {
                chart = this.getOverlayChart();
            }
            return chart;
        },

        getStackedChart: function( index ) {
            var chart;
            if( this._stacked && this._stackedCharts && index >= 0 && index < this._stackedCharts.length ) {
                chart = this._stackedCharts[ index ];
            }
            return chart;
        },

        getOverlayChart: function( ) {
            var chart;
            if( !this._stacked && this._overlayChart ) {
                chart = this._overlayChart;
            }
            return chart;
        },

        render: function () {
            this._makeDetailContainer();

            if( !this._mastercontainer ) {
                this._mastercontainer = UWA.createElement( 'div', { id: '_mastercontainer' } ).inject( this.container );
                this._mastercontainer.classList.add( 'tde-master-container' );
            }
            this._masterOptions && this._masterOptions.chart && (this._masterOptions.chart.renderTo = this._mastercontainer);

            if( !this._overlayOptions.series.length ) {
                TestDataMessage.displayMessage( 'error', i18n['plotdata-insufficient'] );
                return this;
            }

            try {
                this._drawHighcharts( this.hasChart() );
            } catch (e) {
                var errorMessage = (e && e.message) || i18n[ 'plot-creation-failed' ];
                TestDataMessage.displayMessage( 'error', errorMessage );
            }
            return this;
        },

        resize: function () {
            this._resizing = true;

            // resize charts, destroy master and detail chart objects and delete detail series
            if( this._detailcontainer &&  this._mastercontainer && this._context ) {
                this._destroyDetail();

                if( this._masterChart ) {
                    this._masterChart.destroy();
                    this._masterChart = null;
                }

                try {
                    this.render();
                } catch (e) {
                    var errorMessage = (e && e.message) || i18n[ 'plot-creation-failed' ];
                    TestDataMessage.displayMessage( 'error',  errorMessage );
                }
            }
            return this;
        },

        reflow: function () {
            this._masterChart && this._masterChart.reflow();
            if( this._stacked ) {
                this._stackedCharts && this._stackedCharts.forEach( function( chart ) {
                    chart.reflow();
                });
            } else if( this._overlayChart ) {
                this._overlayChart.reflow();
            }

            return this;
        },

        setBounds: function( extremes ) {
            var rmin = Math.round( extremes.min );
            var rmax = Math.round( extremes.max );
            if( this._detailBounds.x.min !== rmin || this._detailBounds.x.max !== rmax ) {
                this._detailBounds.x.min = rmin;
                this._detailBounds.x.max = rmax;
                this._updateZoom( rmin, rmax, false);
                this._createDetail( true );
            }
        },

        getBounds: function() {
            return this._detailBounds;
        },

        setStacked: function( bool ) {
            var stk = this._stacked;
            this._stacked = bool === undefined || bool;
            if( this._stacked !== stk ) {
                this._createDetail( false );
            }
        },

        detailStacked: function() {
            return this._stacked;
        },

        destroy: function () {
            // remove listeners
            window.removeEventListener('mousemove', this.onmove );
            window.removeEventListener('mouseup', this.onUp );
            this._masterChart && this._masterChart.container &&
            this._masterChart.container.removeEventListener('mouseleave', this.onUp );

            if( this._slider ) {
                this._slider.minBtn && this._slider.minBtn.element.removeEventListener('mousedown', this.onMinDown);
                this._slider.maxBtn && this._slider.maxBtn.element.removeEventListener('mousedown', this.onMaxDown);
                this._slider.panBtn && this._slider.panBtn.element.removeEventListener('mousedown', this.onPanDown); 
                this._slider = {};
            }

            // destroy master
            this._masterChart && this._masterChart.destroy();
            this._masterChart = null;

            this._destroyDetail();

            // destroy containers
            this._clearStackedContainers();
            this._detailcontainer && this._detailcontainer.destroy();
            this._detailcontainer = null;

            this._mastercontainer && this._mastercontainer.destroy();
            this._mastercontainer = null;

            this.container && this.container.destroy();
            this._parent();
        },

        _destroyDetail: function() {
            this._overlayChart && this._overlayChart.destroy()
            this._overlayChart = null;

            this._stackedCharts.forEach( function( chart ) {
                chart.destroy();
            });
            this._stackedCharts = [];
            this._destroyItem( this._minExt );
            this._destroyItem( this._extLabel );
            this._destroyItem( this._maxExt );
            this._destroyItem( this._domainLabel );
            this._destroyItem( this._domainContainer );
            
            this._minExt = null;
            this._extLabel = null;
            this._maxExt = null;
            this._domainLabel = null;
            this._domainContainer = null;
        },

        toggleStackedDisplay: function() {
            var stk = !this._stacked;
            this.setStacked( stk );
        },
        
        _destroyItem: function( item ) {
            if(item ) {
                if(item.remove ) {
                   item.remove();
                } else {
                    var container = item.parentNode;
                    if( container && container.removeChild ) {
                        container.removeChild( item );
                    }
                }
            }
        },

        //
        // Private methods
        // 

        _drawHighcharts: function ( appendSeries ) {
            try {
                if( appendSeries ) {
                    this._createDetail( false );
                } else {
                    this._createMaster();
                }
            } catch (e) {
                var errorMessage = (e && e.message) || i18n[ 'plot-master-failed' ];
                TestDataMessage.displayMessage( 'error', errorMessage );
            }
        },

        _createMaster: function() {
            var self = this;
            if( this._masterOptions && this._mastercontainer ) {
                new Highcharts.Chart( this._masterOptions, function( master ) {
                    if( master ) {
                        self._masterChart = master;
                        self._createDetail( false );
                    }
                });
            }
        },

        _createDetail: function( dataReq ) {
            this._makeDetailContainer();
            if( this._context && this._detailcontainer ) {
                var self = this;
                if( dataReq || !this._overlayOptions.series || this._overlayOptions.series.length === 0 ) {
                    // Get overlay plot data, if plots are stacked, plot data will be extracted from overlay data
                    this._overlayOptions.series = [];
                    var bounds = { min: Math.round( self._detailBounds.x.min ), max: Math.round( self._detailBounds.x.max ) };
                    this._context.getChartData( { bounds: bounds } )
                    .then( function( detailData ) {
                        if( detailData ) {
                            self._overlayOptions.series = detailData.seriesData;
                            self._drawDetail();
                        } else {
                            TestDataMessage.displayMessage( i18n[ 'plotdata-insufficient' ] );
                        }
                    })
                    .catch( function( err )  {
                        TestDataMessage.displayMessage( err );
                    });
                } else {
                    this._drawDetail();
                }
            }
        },


        _drawDetail: function() {
            this._destroyDetail();
            var self = this;

            if( this._stacked ) {
                // Stacked chart
                var opts = this._getStackedOptions();

                var last = opts.length - 1;
                opts.forEach( function( opt, index ) {
                    new Highcharts.Chart( opt, 
                            function(chart) { 
                        self._addVerticalBorder( chart );
                        self._stackedCharts.push( chart );
                        self.updateMaxMinDisplay( { index: index } );
                        if( index === last ) {
                            self._addExtentControls( self._detailcontainer );
                        }
                    }
                    );
                });
            } else {
                // Single curve or overlay chart
                var opt = this._overlayOptions;
                if( this.numSeries() > 1) {
                    opt.title && ( opt.title.text = 'Overlay Plot' );
                    opt.yAxis && opt.yAxis.title && ( opt.yAxis.title.text = self._context.getYaxisLabel() ); 
                    opt.legend = { 
                            enabled: true,
                            labelFormatter: function () {
                                return this.name;
                            }
                    };
                }

                opt.yAxis.plotLines = [];
                if( self._context.chartOptions.overlay.showGlobalMaxMinLines ) {
                    var bounds = self._context.getGlobalBounds();
                    if( bounds ) {
                        opt.yAxis.min = bounds.y.min;
                        opt.yAxis.max = bounds.y.max;
                        opt.yAxis.plotLines = self._getGlobalPlotLineOption( bounds.y.min, bounds.y.max );
                    }
                }

                new Highcharts.Chart( this._overlayOptions, 
                        function(chart) { 
                    self._addVerticalBorder( chart );
                    self._overlayChart = chart;
                    self.updateMaxMinDisplay();
                    self._addExtentControls( self._detailcontainer );
                    self._addZoomControls();
                }
                );
            }
        },

        numSeries: function() {
            var num = 0;
            if( this._overlayOptions && this._overlayOptions.series ) {
                num = this._overlayOptions.series.length;
            }
            return num;
        },

        getDetailSeries: function() {
            var series;
            if( this._overlayOptions && this._overlayOptions.series ) {
                series = this._overlayOptions.series;
            }
            return series;
        },

        _getMasterOptions: function( ) {
            var options = null;
            var self = this;
            var masterData = this._context.masterSeries;

            if( masterData ) {
                options = {  
                        chart: { 
                            className: 'tde-master-chart',
                            height: 80,
                            marginTop: 0,
                            marginLeft: 80,  
                            marginRight: 20,
                            reflow: false,
                            zoomType: undefined,
                            resetZoomButton: { theme: { display: 'none' } },
                            events: { redraw: function() { self._addZoomControls(); } }	
                        },
                        title: { text: null },
                        xAxis: { 
                            minTickInterval: 1,
                            maxPadding: 0,
                            minPadding:0,
                            title: { text: null }
                        },
                        yAxis: {
                            gridLineWidth: 0, 
                            labels: { enabled: true, style: { 'color': 'transparent' } }, 
                            title: { text: 'Y', style: { 'color': 'transparent' } } 
                        },
                        series: [ { 
                            name: 'Index',
                            color: '#42a2da',
                            data:  masterData.seriesData[0].data,
                            pointInterval: masterData.seriesData[0].pointInterval,
                            pointStart: masterData.seriesData[0].pointStart
                        }],
                        tooltip: { formatter: function () { return false; } },
                        legend:  { enabled: false },
                        credits: { enabled: false },
                        plotOptions: {
                            series: {
                                fillColor: { linearGradient: [0, 0, 0, 70], stops: [ [0, Highcharts.getOptions().colors[0]], [1, 'rgba(255,255,255,0)'] ] },
                                lineWidth: 1,
                                marker: { enabled: false },
                                shadow: false,
                                states: { hover: { lineWidth: 1 } },
                                enableMouseTracking: false,
                                pointStart: masterData.seriesData[0].pointStart
                            },
                        },
                        exporting: { enabled: false }
                };
            } 
            return options;
        },

        _getStackedOptions: function() {
            var self = this;
            var numSeries = this._overlayOptions.series.length;
            this._makeStackedContainers( numSeries );
            var stackedOptions = [];
            this._overlayOptions.series.forEach( function( item, indx ) {
                // create a stacked options object for each series by cloning the overlay options
                var opt = UWA.clone( self._overlayOptions );
                opt.stacked = true;
                opt.title && ( opt.title.text = item.name );
                opt.legend = {  enabled: false };

                // clear the series array
                opt.series = [];

                // get mutable options from chart view
                var stkChartOpt = self._context.getStackedChartOptions( indx );

                // push a single series object onto the array
                opt.series.push( item );
                opt.chart.renderTo = self._stackedContainers[indx];

                // update the title and global min/max plot lines
                if( opt.yAxis ) {
                    opt.yAxis.min = undefined;
                    opt.yAxis.max = undefined;
                    opt.yAxis.plotLines = undefined;
                    opt.yAxis.title && ( opt.yAxis.title.text = stkChartOpt.yAxisLabel );
                    if( stkChartOpt.showGlobalMaxMinLines ) {
                        var bounds = stkChartOpt.globalBounds;
                        if( bounds ) {
                            opt.yAxis.min = bounds.y.min;
                            opt.yAxis.max = bounds.y.max;
                            opt.yAxis.floor = bounds.y.min;
                            opt.yAxis.ceiling = bounds.y.max;
                            opt.yAxis.plotLines = self._getGlobalPlotLineOption( opt.yAxis.min, opt.yAxis.max);
                        }
                    }
                }
                stackedOptions.push( opt );
            });
            return stackedOptions;
        },

        _getGlobalPlotLineOption: function( minval, maxval ) {
            var opts = [];
            opts.push( { id: 'minglobalvalueline', color: '#ff1493', width: 2, value: minval,  
                zIndex: 5, dashStyle: 'ShortDash', 
                label: { text: minval, enabled: true,  x: 80,  y: 13 } } );

            opts.push( { id: 'maxglobalvalueline', color: '#20b2aa', width: 2, value: maxval,  
                zIndex: 5, dashStyle: 'ShortDash', 
                label: { text: maxval, enabled: true,  x: 80,  y: -7 } } );
            return opts;
        },

        _makeDetailContainer: function() {
            if( !this._detailcontainer ) {
                this._detailcontainer = UWA.createElement( 'div', { id: '_detailcontainer' } ).inject( this.container );
                this._detailcontainer.classList.add( 'tde-detail-container' );
            }
            var nseries = this.numSeries();
            if( this._stacked && nseries > 1 ) {
                this._makeStackedContainers( nseries );
            } else {
                this._clearStackedContainers();
                this._detailcontainer.empty();
                if( this._overlayOptions && this._overlayOptions.chart ) {
                    this._overlayOptions.chart.renderTo = this._detailcontainer;
                    this._overlayOptions.chart.credits = { enabled: false };
                }
            }
        },

        _makeStackedContainers: function( numSeries ) {
            if(  this._detailcontainer ) {
                this._clearStackedContainers();
                this._detailcontainer.empty();
                var height = ( 1/numSeries )*100 + '%';
                for( var i = 0; i < numSeries; ++i ) {
                    var id = '_stackedcontainer_' + i;
                    var stkContainer = UWA.createElement( 'div', { id: id } ).inject( this._detailcontainer );
                    stkContainer.setAttribute( 'containerIndex', i);
                    stkContainer.classList.add( 'tde-detail-stacked-container' );
                    stkContainer.style.height = height;
                    this._stackedContainers.push(stkContainer);
                }
            }
        },

        _clearStackedContainers: function() {
            this._stackedContainers.forEach( function( ctr ) {
                ctr.empty();
            });
            this._stackedContainers = [];
        },
        
        _pixelBounds: function( chart ) {
            var bounds = { min: {}, max: {} };
            var xAxis = chart.xAxis[0];
            var yAxis = chart.yAxis[0];
            var xExt = xAxis.getExtremes();
            var yExt = yAxis.getExtremes();
            bounds.min = { x: xAxis.toPixels(xExt.min), y: yAxis.toPixels(yExt.min) };
            bounds.max = { x: xAxis.toPixels(xExt.max), y: yAxis.toPixels(yExt.max) };
            bounds.mid = { x: ( bounds.min.x + bounds.max.x ) / 2, y: (bounds.min.y + bounds.max.y ) / 2 };
            return bounds;
        },

        _addVerticalBorder: function( chart ) {
            var pixBounds = this._pixelBounds( chart );
            chart.renderer.path( [
                'M', pixBounds.min.x, pixBounds.min.y,
                'L', pixBounds.min.x, pixBounds.max.y,
                'M', pixBounds.max.x, pixBounds.min.y,
                'L', pixBounds.max.x, pixBounds.max.y,
                ] ).attr({
                    'stroke-width': 1,
                    stroke: '#CCD6EB',
                    zIndex: 3
                }).add();
        },

        _addGrips: function( geom ) {
            // the point (geom.x and geom.y) refers to the center of the button
            var path, deltaX, deltaY, len;
            if( geom.num === 3 ) {
                // pan button
                deltaX = 4;
                deltaY = 3;
                len = 5;
                path = this._masterChart.renderer.path( [
                    'M', geom.x - deltaX, geom.y - deltaY,
                    'l', 0, len,
                    'M', geom.x, geom.y - deltaY,
                    'l', 0, len,
                    'M', geom.x + deltaX, geom.y - deltaY,
                    'l', 0, len ] ).attr({ 'stroke-width': 1, stroke: '#999999', zIndex: 5 });
            } else {
                // min/max buttons
                deltaX = 1.5;
                len = this._slider.btnGeom.h - 8;
                deltaY = Math.round( len/2 );
                path = this._masterChart.renderer.path( [
                    'M', geom.x - deltaX, geom.y - deltaY, 
                    'l', 0, len, 
                    'M', geom.x + deltaX, geom.y - deltaY, 
                    'l', 0, len ] ).attr({ 'stroke-width': 1, stroke: '#999999', zIndex: 5 });
            }
            if( path.element.classList ) {
                path.element.classList.add('tde-grip');
            } else if( path.element.className ){
                path.element.className.baseVal = 'tde-grip';
            }
            return path;
        },

        _makeButton: function( geom, handler, options ) {
            // the point (geom.x and geom.y) refers to the center of the button
            var self = this;
            var group = this._masterChart.renderer.g().attr({zIndex: 3}).add();
            var el = group.element;
            if( el.classList ) {
                el.classList.add('tde-group');
            } else if( el.className ){
                el.className.baseVal = 'tde-group';
            }
            
            el.chart = this._masterChart;
            el.bounds = this._detailBounds;
            el.slider = this._slider;
            el.group = group;
            var left = geom.x - Math.round( geom.w/2 );
            var top  = geom.y - Math.round( geom.h/2 );

            el.rect = this._masterChart.renderer.rect( left, top, geom.w, geom.h, geom.r ).attr( 
                    { 'stroke-width': 1, stroke: '#999999', fill: options.color, zIndex: 4 } ).add(group);
            
            el.grips = this._addGrips( { x: geom.x, y: geom.y, w: geom.w, num: geom.grips.num } ).add(group);
            el.addEventListener('mousedown', handler);
            group.name = options.name;
            return group;
        },

        _moveButtonTo: function( button, geom ) {
            // the point (geom.x and geom.y) refers to the center of the button
            var el = button.element;
            var children = el.children ? el.children : el.childNodes;
            if( children ) {
                for( var i = children.length-1; i >= 0; --i ) {
                    var item = children.item(i);
                    if( item.tagName === 'rect' ) {
                        item.setAttribute('x', geom.x - geom.w/2 + 'px'); // set xval to left-side of button
                    } else {
                        (item.destroy && item.destroy()) || (item.remove && item.remove());
                    }
                }
                
                el.grips = this._addGrips({ x: geom.x, y: geom.y, w: geom.w, num: button.name === 'pan' ? 3 : 2} ).add(el.group);
            }
        },

        _isValidZoomValue: function( val ) {
            var xAxis = this._masterChart.xAxis[0];
            var xExt = xAxis.getExtremes();
            return !isNaN( val ) && isFinite( val ) && val >= xExt.dataMin && val <= xExt.dataMax;
        },

        _addZoomControls: function() {
            var self = this;
            var xAxis = this._masterChart.xAxis[0];
            var yAxis = this._masterChart.yAxis[0];
            var pixBounds = this._pixelBounds( this._masterChart );
            var pixmin = { x: xAxis.toPixels(this._detailBounds.x.min), y: yAxis.toPixels(this._detailBounds.y.min) };
            var pixmax = { x: xAxis.toPixels(this._detailBounds.x.max), y: yAxis.toPixels(this._detailBounds.y.max) };

            // min zoom button
            this._slider.minBtn && this._slider.minBtn.destroy();
            var bGeom = { 
                    x: pixmin.x , // button centered on xmin
                    y: pixBounds.mid.y, // button centered on ymid
                    w: this._slider.btnGeom.w, 
                    h: this._slider.btnGeom.h,
                    r: this._slider.btnGeom.r,
                    grips: { num: 2 } };
            this._slider.minBtn = this._makeButton( bGeom, this.onMinDown, { color: '#F0FFF0', name: 'min' } );

            // max zoom button
            this._slider.maxBtn && this._slider.maxBtn.destroy();
            bGeom.x = pixmax.x; // button centered on xmax
            this._slider.maxBtn = this._makeButton( bGeom, this.onMaxDown, { color: '#FFF0F0', name: 'max' } );

            // pan button
            this._slider.panBtn && this._slider.panBtn.destroy();
            bGeom.w = pixmax.x - pixmin.x;
            bGeom.x = pixmin.x + Math.round( bGeom.w/2 );
            bGeom.y = pixBounds.min.y + this._slider.panOffset;
            bGeom.h = this._slider.panHeight;
            bGeom.grips = { deltaX: 4, deltaY: 2, len: 6, num: 3 };
            this._slider.panBtn = this._makeButton( bGeom, this.onPanDown, { color: '#F2F2F2', name: 'pan' } );

            // event handlers
            var boundMove = this.onmove.bind(this);
            window.addEventListener( 'mousemove', boundMove );
            window.addEventListener( 'mouseup', self.onUp.bind(self) );
            this._masterChart.container.addEventListener( 'mouseleave', self.onUp.bind(self) );

            // plot lines
            xAxis.addPlotLine({ id: 'line-before', value: this._detailBounds.x.min, width: 1, color: '#CCCCCC', zIndex: 2 });
            xAxis.addPlotLine({ id: 'line-after',  value: this._detailBounds.x.max, width: 1, color: '#CCCCCC', zIndex: 2 });

            // plot bands
            this._detailBounds.x.min > xAxis.dataMin &&
            xAxis.addPlotBand( { id: 'mask-before', from: xAxis.dataMin, to: this._detailBounds.x.min, color: 'rgba(209, 218, 237, 0.9)' } ) ;

            xAxis.dataMax > this._detailBounds.x.max && 
            xAxis.addPlotBand( { id: 'mask-after',  from: this._detailBounds.x.max, to: xAxis.dataMax, color: 'rgba(209, 218, 237, 0.9)' } ) ;
        },

        _addExtentControls: function( container ) {
            if( !this._domainContainer ) {
                this._domainContainer = document.createElement('div');
                this._domainContainer.classList.add( 'tde-extent-container' );
                container.appendChild( this._domainContainer );
            }
            
            if( !this._domainLabel ) {
                this._domainLabel = document.createElement('label');
                this._domainLabel.classList.add( 'tde-extent-label' );
                this._domainLabel.textContent = i18n.domain;
                this._domainContainer.appendChild( this._domainLabel );
            }
            
            if( !this._minExt ) {
                this._minExt = document.createElement('input');
                this._minExt.type = 'text';
                this._minExt.removeAttribute('readonly');
                this._minExt.name = 'tde-extent-input-min'; // for sahi testing
                this._minExt.classList.add( 'tde-extent-input' );
                
                this._minExt.tooltipInfos = new WUXTooltipModel({ title: i18n.zoom, shortHelp: i18n['zoom-min'], longHelp: i18n['zoom-min-long'] });
                this._minExt.addEventListener('change', function( event ) {
                    var numval = parseFloat( event.target.value );
                    if( this._isValidZoomValue( numval ) && numval < this._detailBounds.x.max ) {
                        this._detailBounds.x.min = numval;
                        this._updateZoom(numval, this._detailBounds.x.max, false);
                        this._createDetail( true );
                    } else {
                        this._minExt.value = this._formatNum( this._detailBounds.x.min );
                        TestDataMessage.displayMessage( 'warning', i18n['bad-val'] );
                    }
                }.bind(this));
                this._domainContainer.appendChild( this._minExt );
            }

            if( !this._extLabel ) {
                this._extLabel = document.createElement('label');
                this._extLabel.classList.add( 'tde-extent-label' );
                this._extLabel.textContent = "-";
                this._domainContainer.appendChild( this._extLabel );
            }

            if( !this._maxExt ) {
                this._maxExt = document.createElement('input');
                this._maxExt.type = 'text';
                this._maxExt.removeAttribute('readonly');
                this._maxExt.name = 'tde-extent-input-max'; // for sahi testing
                this._maxExt.classList.add( 'tde-extent-input' );
                
                this._maxExt.tooltipInfos = new WUXTooltipModel({ title: i18n.zoom, shortHelp: i18n['zoom-max'], longHelp: i18n['zoom-max-long'] });
                this._maxExt.addEventListener('change', function( event ) {
                    var numval = Math.round( parseFloat( event.target.value ) );
                    if( this._isValidZoomValue( numval ) && numval > this._detailBounds.x.min ) {
                        this._detailBounds.x.max = numval;
                        this._updateZoom( this._detailBounds.x.min, numval, false);
                        this._createDetail( true );
                    }else {
                        this._maxExt.value = this._formatNum( this._detailBounds.x.max );
                        TestDataMessage.displayMessage( 'warning', i18n['bad-val'] );
                    }
                }.bind(this));
                this._domainContainer.appendChild( this._maxExt );
            }

            this._minExt.value = this._formatNum( this._detailBounds.x.min );
            this._maxExt.value = this._formatNum( this._detailBounds.x.max );
        },

        _formatNum: function( val ) {
            // TODO handle exponential notation
            var ret = val;
            var str = val.toString();

            var wholeNum = false;
            if( this._overlayOptions.xAxis && this._overlayOptions.xAxis.allowDecimals !== undefined) {
                wholeNum = !this._overlayOptions.xAxis.allowDecimals;
            }

            var loc = str.indexOf('.');
            if( loc !== -1 ) {
                if( wholeNum ) {
                    ret = parseFloat(str.slice( 0, loc ) );
                } else if( str.length > this._maxExtChar && loc < this._maxExtChar ) {
                    ret = parseFloat(str.slice( 0, this._maxExtChar ) );
                }
            }
            return ret;
        },

        _updateZoom: function( xmin, xmax, updateExtents ) {
            var self = this;
            var xAxis = this._masterChart.xAxis[0];
            var yAxis = this._masterChart.yAxis[0];
            var detailData = [];

            xAxis.removePlotBand( 'mask-before' );
            xmin > xAxis.dataMin && xAxis.addPlotBand( { id: 'mask-before', from: xAxis.dataMin, to: xmin, color: 'rgba(209, 218, 237, 0.9)' } ) ;
            xAxis.removePlotLine('line-before');
            xAxis.addPlotLine({ id: 'line-before', value: xmin, width: 1, color: '#CCCCCC', zIndex: 2 });
            updateExtents && this._minExt && ( this._minExt.value = this._formatNum( xmin ));

            xAxis.removePlotBand('mask-after');
            xmax < xAxis.dataMax && xAxis.addPlotBand({ id: 'mask-after', from: xmax, to: xAxis.dataMax, color: 'rgba(209, 218, 237, 0.9)' });
            xAxis.removePlotLine('line-after');
            xAxis.addPlotLine({ id: 'line-after', value: xmax, width: 1, color: '#CCCCCC', zIndex: 2 });
            updateExtents && this._maxExt && (this._maxExt.value = this._formatNum( xmax ));
            
            var xpix = { min: xAxis.toPixels(xmin), max: xAxis.toPixels(xmax) };
            var pixBounds = this._pixelBounds( this._masterChart );
            if( !updateExtents ) {
                this._moveButtonTo(this._slider.minBtn, { x: xpix.min, y: pixBounds.mid.y, w: this._slider.btnGeom.w });
                this._moveButtonTo(this._slider.maxBtn, { x: xpix.max, y: pixBounds.mid.y, w: this._slider.btnGeom.w });
            }

            var el = this._slider.panBtn.element;
            el && el.grips && el.grips.destroy();
            this._slider.panBtn.destroy();
            var width = xpix.max - xpix.min;

            this._slider.panBtn = 
                this._makeButton( { x: xpix.min + Math.round( width/2 ), y: pixBounds.min.y + this._slider.panOffset, w: width, h: 9,
                                    grips: { deltaX: 4, deltaY: 2, len: 6, num: 3 } }, self.onPanDown, { color: '#F2F2F2', name: 'pan' } );
        },

        _updatePan: function(xmin, xmax) {
            if( this._masterChart ) {
                if(this._slider.currEl && this._slider.currEl === this._slider.panBtn.element ) {
                    var maxNumChar = 12;
                    var xAxis = this._masterChart.xAxis[0];
                    var yAxis = this._masterChart.yAxis[0];

                    xAxis.removePlotBand( 'mask-before' );
                    xAxis.removePlotBand('mask-after');

                    xAxis.dataMin < xmin && xAxis.addPlotBand( { id: 'mask-before', from: xAxis.dataMin, to: xmin, color: 'rgba(209, 218, 237, 0.9)' } ) ;
                    xmax < xAxis.dataMax && xAxis.addPlotBand( { id: 'mask-after',  from: xmax, to: xAxis.dataMax, color: 'rgba(209, 218, 237, 0.9)' } );

                    xAxis.removePlotLine('line-before');
                    xAxis.removePlotLine('line-after');

                    xAxis.addPlotLine({ id: 'line-before', value: xmin, width: 1, color: '#CCCCCC', zIndex: 2 });
                    xAxis.addPlotLine({ id: 'line-after',  value: xmax, width: 1, color: '#CCCCCC', zIndex: 2 });

                    this._minExt && (this._minExt.value = this._formatNum( xmin ));
                    this._maxExt && (this._maxExt.value = this._formatNum( xmax ));
                }
            }
        },

        fitAll: function() {
            if( this._context ) {
                var bounds = this._context.getGlobalBounds();
                this._detailBounds.x.min = Math.round( bounds.x.min );
                this._detailBounds.x.max = Math.round( bounds.x.max );
                this._updateZoom && this._updateZoom( bounds.x.min, bounds.x.max, false);
                this._createDetail( true );
            }
        },

        displayMaxMinLines: function( options ) {
            var show = options.show === undefined || options.show;
            var chart;

            if( this._stacked ) {
                if( options.index !== undefined || options.index !== null ) {
                    chart = this.getStackedChart( options.index );
                }
            } else {
                chart = this.getOverlayChart();
            }

            if( chart ) {
                var yAxis = chart.yAxis[0];
                if( yAxis ) {
                    yAxis.removePlotLine( 'minvalueline' );
                    yAxis.removePlotLine( 'maxvalueline' );

                    var extremes = yAxis.getExtremes();
                    var ymin = extremes.dataMin;
                    var ymax = extremes.dataMax;

                    if( show ) {
                        yAxis.addPlotLine( { id: 'minvalueline', width: 2, value: ymin, zIndex: 5, dashStyle: 'LongDash', color: '#c80000',
                            label: { text: ymin, enabled: true, x: 10,  y: -7 }
                        });
                        yAxis.addPlotLine( { id: 'maxvalueline', width: 2, value: ymax, zIndex: 5, dashStyle: 'LongDash', color: '#00c800',
                            label: { text: ymax, enabled: true, x: 10,  y: 13 }
                        });
                    }
                } else {
                    console.log( "INTERNAL ERROR: bad yaxis");
                }
            } else {
                console.log( "INTERNAL ERROR: bad chart or chartOptions");
            }
        },


        updateMaxMinDisplay: function( opt ) {
            // Local max/min lines
            var options = opt ? UWA.clone( opt ) : {};
            options.show = this._context.getMaxMinLineDisplay( options );
            this.displayMaxMinLines( options );
        },

        //
        // Event handlers
        //

        onMinDown: function(e) {
            var chart = e.currentTarget.chart;
            var xAxis = chart.xAxis[0];
            e = chart.pointer.normalize(e);
            e.currentTarget.slider.currEl = e.currentTarget;
            e.currentTarget.slider.clickDelta = e.clientX - xAxis.toPixels(e.currentTarget.bounds.x.min);
        },

        onMaxDown: function(e) {
            var chart = e.currentTarget.chart;
            var xAxis = chart.xAxis[0];
            e = chart.pointer.normalize(e);
            e.currentTarget.slider.currEl = e.currentTarget;
            e.currentTarget.slider.clickDelta = e.clientX - xAxis.toPixels(e.currentTarget.bounds.x.max);
        },

        onPanDown: function(e) {
            var chart = e.currentTarget.chart;
            var xAxis = chart.xAxis[0];
            e = chart.pointer.normalize(e);
            e.currentTarget.slider.currEl = e.currentTarget;
            e.currentTarget.slider.clickDelta = e.clientX - xAxis.toPixels(e.currentTarget.bounds.x.min);
        },

        onmove: function( event ) {
            if( this._slider && this._slider.currEl ) {
                if( this._slider.currEl === this._slider.minBtn.element ) {
                    this.onMinMove(event );
                } else if( this._slider.currEl === this._slider.maxBtn.element ) {
                    this.onMaxMove(event );
                } else if( this._slider.currEl === this._slider.panBtn.element ){
                    this.onPan( event );
                }
            }
        },

        onMinMove: function( event ) {
            if( this._slider && this._slider.minBtn ) {
                var xAxis = this._masterChart.xAxis[0];
                var yAxis = this._masterChart.yAxis[0];
                var pixBounds = this._pixelBounds( this._masterChart );
                
                var pixval = event.clientX - this._slider.clickDelta;
                var xmin = pixval < pixBounds.min.x ? pixBounds.min.x : pixval;
                var xmax = xAxis.toPixels(this._detailBounds.x.max) - this._slider.minDist;
                if( xmin > xmax ) { xmin = xmax; }

                var el = this._slider.minBtn.element;
                var children = el.children ? el.children : el.childNodes;
                if( children ) {
                    for( var i = children.length-1; i >= 0; --i ) {
                        var item = children.item(i);
                        if( item.tagName === 'rect' ) {
                            item.setAttribute('x', (xmin - this._slider.btnGeom.offset.x) + 'px');
                        } else {
                            (item.destroy && item.destroy()) || (item.remove && item.remove());
                        }
                    }
                    this._addGrips({ x: xmin, y: pixBounds.mid.y, w: this._slider.btnGeom.w, num: 2} ).add(el.group);
                    this._updateZoom( xAxis.toValue( xmin ), this._detailBounds.x.max, true);
                }
            }
        },

        onMaxMove: function( event ) {
            if( this._slider && this._slider.maxBtn ) {
                var xAxis = this._masterChart.xAxis[0];
                var yAxis = this._masterChart.yAxis[0];
                var pixBounds = this._pixelBounds( this._masterChart );
                
                var pixval = event.clientX - this._slider.clickDelta;
                var xmax = pixval > pixBounds.max.x ? pixBounds.max.x : pixval;
                var xmin = xAxis.toPixels(this._detailBounds.x.min) + this._slider.minDist;
                if( xmax < xmin ) { xmax = xmin; }

                var el = this._slider.maxBtn.element;
                var children = el.children ? el.children : el.childNodes;
                if( children ) {
                    for( var i = children.length-1; i >= 0; --i ) {
                        var item = children.item(i);
                    if( item.tagName === 'rect' ) {
                        item.setAttribute('x', (xmax - this._slider.btnGeom.offset.x) + 'px');
                    } else {
                        (item.destroy && item.destroy()) || (item.remove && item.remove());
                    }
                }
                this._addGrips({ x: xmax, y: pixBounds.mid.y, w: this._slider.btnGeom.w, num: 2} ).add(el.group);
                this._updateZoom(this._detailBounds.x.min, xAxis.toValue(xmax), true);
                }
            }
        },

        onPan: function( event ) {
            if( this._slider && this._slider.currEl ) {
                var xAxis = this._masterChart.xAxis[0];
                var yAxis = this._masterChart.yAxis[0];
                var pixBounds = this._pixelBounds( this._masterChart );
                
                var pixmin = { x: xAxis.toPixels( this._detailBounds.x.min ) };
                var pixmax = { x: xAxis.toPixels( this._detailBounds.x.max ) };
                var dist = pixmax.x - pixmin.x;

                var pixval = event.clientX - this._slider.clickDelta;
                if( pixval < pixBounds.min.x ) {
                    pixmin.x = pixBounds.min.x ;
                    pixmax.x = pixmin.x + dist;
                } else if( pixval+dist > pixBounds.max.x  ) {
                    pixmax.x = pixBounds.max.x ;
                    pixmin.x = pixmax.x - dist;
                } else {
                    pixmin.x = pixval;
                    pixmax.x = pixmin.x + dist;
                }
                
                this._moveButtonTo(this._slider.minBtn, { x: pixmin.x, y: pixBounds.mid.y, w: this._slider.btnGeom.w});
                this._moveButtonTo(this._slider.maxBtn, { x: pixmax.x, y: pixBounds.mid.y, w: this._slider.btnGeom.w });
                this._moveButtonTo(this._slider.panBtn, { x: ( pixmax.x + pixmin.x ) / 2, y: pixBounds.min.y + this._slider.panOffset, w: dist } );

                this._updatePan(xAxis.toValue( pixmin.x ), xAxis.toValue( pixmax.x ));
            }
        },

        onUp: function( event ) {
            if( this._slider && this._slider.currEl ) {
                var xAxis = this._masterChart.xAxis[0];
                var yAxis = this._masterChart.yAxis[0];
                var pixBounds = this._pixelBounds( this._masterChart );
                var e = this._masterChart.pointer.normalize(event);
                var pix = e.clientX - this._slider.clickDelta;
                
                var pixval = event.clientX - this._slider.clickDelta;
                var bounds = { min: this._detailBounds.x.min, max: this._detailBounds.x.max }; 
                
                var xmin, xmax;
                if( this._slider.currEl === this._slider.minBtn.element ) {
                    xmin = pixval < pixBounds.min.x ? pixBounds.min.x : pixval;
                    xmax = xAxis.toPixels(this._detailBounds.x.max) - this._slider.minDist;
                    if( xmin > xmax ) { xmin = xmax; }
                    bounds.min = xAxis.toValue( xmin );
                } else if( this._slider.currEl === this._slider.maxBtn.element ) {
                    xmax = pixval > pixBounds.max.x ? pixBounds.max.x : pixval;
                    xmin = xAxis.toPixels(this._detailBounds.x.min) + this._slider.minDist;
                    if( xmax < xmin ) { xmax = xmin; }
                    bounds.max = xAxis.toValue( xmax );
                } else {
                    var pixmin = { x: xAxis.toPixels(this._detailBounds.x.min), y: yAxis.toPixels(this._detailBounds.y.min) };
                    var pixmax = { x: xAxis.toPixels(this._detailBounds.x.max), y: yAxis.toPixels(this._detailBounds.y.max) };
                    var dist = pixmax.x - pixmin.x;
                    var deltaMax = dist - this._slider.clickDelta;

                    if( pixval < pixBounds.min.x ) {
                        pixmin.x = pixBounds.min.x ;
                        pixmax.x = pixmin.x + dist;
                    } else if( pixval+dist > pixBounds.max.x  ) {
                        pixmax.x = pixBounds.max.x ;
                        pixmin.x = pixmax.x - dist;
                    } else {
                        pixmin.x = pixval;
                        pixmax.x = pixmin.x + dist;
                    }
                    bounds.min = xAxis.toValue( pixmin.x );
                    bounds.max = xAxis.toValue( pixmax.x );
                }

                var rmin = Math.round( bounds.min );
                var rmax = Math.round( bounds.max );
                if( rmin !== this._detailBounds.x.min ||  rmax !== this._detailBounds.x.max ) {
                    this._detailBounds.x.min = rmin;
                    this._detailBounds.x.max = rmax;
                    this._createDetail( true );
                }
                this._slider.currEl = undefined;
            }
        }
    });

    return Graph;
});

