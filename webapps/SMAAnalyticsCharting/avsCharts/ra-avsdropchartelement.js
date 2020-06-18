/* global d3 */
/* global Polymer */
(function(GLOBAL, template) {
    'use strict';
    var avsDropPrototype = {
        is: 'ra-avsdropchartelement',
        behaviors: [GLOBAL.DS.RAComponents.chart]
    };
    var REFRESH_THROTTLE_INTERVAL = 150,
        PAN_THROTTLE_INTERVAL = 100;
    
    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;

    avsDropPrototype.setDataProvider = function(dataProvider) {
        this.dataProvider = dataProvider;
    };
    
    avsDropPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.chart.createdCallback.call(this);
        
        var that = this;

        this.dimensions = { width: 100, height: 100 };

        this.clipPositions = {
            xAxis: { position: [0, 0], pan: [0, 0] },
            yAxis: { position: [0, 0], pan: [0, 0] }
        };

        this.legendData = {};
        this.legendElements = {};

        this.chart = null;
        this.chartTileCollection = null;
        this.uniqueKey = null;
        this.selectionInfo = null;

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        // build out the svg
        this.svgs = {
            root: document.createElementNS('http://www.w3.org/2000/svg', 'svg'), // this.querySelector('.root'),

            // middle
            rearGroup: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'g'
            ),
            chartBack: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'g'
            ), // contains bg of chart including behind the axes
            plotBack: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'g'
            ), // will be clipped
            plotBackOuter: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'g'
            ), // will be moved
            plotBackInner: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'g'
            ), // will be moved

            // front
            frontGroup: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'g'
            ),

            // middle
            midGroup: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'g'
            ), // this will be clipped
            midGroupInner: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'g'
            ), // this will be moved
            tilesGroup: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'g'
            ),
            
            selectionRectangle: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'rect'
            ),
            selectionRectangleShadow: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'path'
            )
        };
        
        // make sure that it has this class
        this.svgs.selectionRectangle.setAttribute('class', 'ra-zool-select');

        // set up the rear group
        this.svgs.rearGroup.appendChild(this.svgs.chartBack);
        this.svgs.plotBackInner.appendChild(this.svgs.plotBackOuter);
        this.svgs.plotBack.appendChild(this.svgs.plotBackInner);
        this.svgs.rearGroup.appendChild(this.svgs.plotBack);

        // set up hte mid group
        this.svgs.tilesGroup.setAttribute('class','ra-svgtilesgroup');
        this.svgs.midGroupInner.appendChild(this.svgs.tilesGroup);
        this.svgs.midGroup.appendChild(this.svgs.midGroupInner);

        // no set up for front group

        // build out the clippath info
        this.clipPaths = {
            defs: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'defs'
            ),
            xAxis: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'clipPath'
            ),
            yAxis: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'clipPath'
            ),
            plot: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'clipPath'
            ),
            xTics: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'rect'
            ),
            yTics: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'rect'
            ),
            xText: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'rect'
            ),
            yText: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'rect'
            ),
            plotArea: document.createElementNS(
                'http://www.w3.org/2000/svg',
                'rect'
            )
        };

        // set up the xAxis clips
        this.clipPaths.xAxis.appendChild(this.clipPaths.xTics);
        this.clipPaths.xAxis.appendChild(this.clipPaths.xText);

        // set up the yAxis clips
        this.clipPaths.yAxis.appendChild(this.clipPaths.yTics);
        this.clipPaths.yAxis.appendChild(this.clipPaths.yText);

        // set up the plot clip
        this.clipPaths.plot.appendChild(this.clipPaths.plotArea);

        // add clips to the defs, and append to the root
        this.clipPaths.defs.appendChild(this.clipPaths.xAxis);
        this.clipPaths.defs.appendChild(this.clipPaths.yAxis);
        this.clipPaths.defs.appendChild(this.clipPaths.plot);
        this.svgs.root.appendChild(this.clipPaths.defs);

        // set up the root
        this.svgs.root.appendChild(this.clipPaths.defs);
        this.svgs.root.appendChild(this.svgs.rearGroup);
        this.svgs.root.appendChild(this.svgs.midGroup);
        this.svgs.root.appendChild(this.svgs.frontGroup);
        
        this.appendChild(this.svgs.root);

        this.legend = null;

        this.addChartEventListener(this.refresh, this.selectFilter);
    };
    
    
    avsDropPrototype._initializeToolbar = function(options){
        options = options || {};
        
        // make sure a mode is set
        if(!this.interactMode){
            // default mode is select
            this.interactMode = 'select';
        }
        
        if(this.toolBar || !options.enabled){
            return;
        }
        // create the toolbar
        this.toolbar = document.createElement('ra-charttoolbar');

        // FIXME: need to get these settings from JSON, callbacks should be functions that can be overridden by the charts
        // zoom to fit
        this.toolbar.addButton(
            'fit',
            {
                'displayName' : NLSUtils.translate('Fit_to_View'),
                'clickCallback' : function(){
                    this.resetZoom();
                }.bind(this),
                'classList' : 'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-zoom-fit' // copied from the webux page
            }
        );
        
        // zoom in
        this.toolbar.addButton(
            'zoomin',
            {
                'displayName' : NLSUtils.translate('Zoom_In'),
                'clickCallback' : function(){
                    this.toolbar.activateButton('zoomin');
                    this.interactMode = 'zoomin';
                }.bind(this),
                'classList' : 'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-zoom-in' // copied from the webux page
            }
        );
        
        // zoom out
        this.toolbar.addButton(
            'zoomout',
            {
                'displayName' : NLSUtils.translate('Zoom_Out'),
                'clickCallback' : function(){
                    this.toolbar.activateButton('zoomout');
                    this.interactMode = 'zoomout';
                }.bind(this),
                'classList' : 'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-zoom-out' // copied from the webux page
            }
        );
        
        // trap zoom
        this.toolbar.addButton(
            'trapzoom',
            {
                'displayName' : NLSUtils.translate('Zoom_Trap'),
                'clickCallback' : function(){
                    this.toolbar.activateButton('trapzoom');
                    this.interactMode = 'trapzoom';
                }.bind(this),
                'classList' : 'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-zoom-selected' // copied from the webux page
            }
        );

        // pan
        this.toolbar.addButton(
            'pan',
            {
                'displayName' : NLSUtils.translate('Pan'),
                'clickCallback' : function(){
                    this.toolbar.activateButton('pan');
                    this.interactMode = 'pan';
                    
                    // not sure if I actually need to do this
                    this._updateDragController();
                    
                }.bind(this),
                'classList' : 'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-arrow-double-combo' // copied from the webux page
            }
        );

        // selection
        this.toolbar.addButton(
            'select',
            {
                'displayName' : NLSUtils.translate('Select_Mode'),
                'isActive' : true,
                'clickCallback' : function(){
                    this.toolbar.activateButton('select');
                    this.interactMode = 'select';
                }.bind(this),
                'classList' : 'wux-ui-3ds wux-ui-3ds-1x wux-ui-3ds-touch' // copied from the webux page
            }
        );
        
        this.appendChild(this.toolbar);
    };
    
    avsDropPrototype.resetZoom = function(){
        // reset the translation vector
        this.dragController.translate([0,0]);
        // reset the scales
        this._resetScales();
        
        // reset the bounds
        this.requestObject.chartRequest.minScenePercentX = 0.0;
        this.requestObject.chartRequest.maxScenePercentX = 100.0;
        this.requestObject.chartRequest.minScenePercentY = 0.0;
        this.requestObject.chartRequest.maxScenePercentY = 100.0;
        
        // fire a refresh
        this.propagateChartEvent({ eventType: 'mask' });
        this.refresh();
    };
    
    avsDropPrototype._getRange = function(){
        var range = [480,380];
        if(this.data && this.data.pixelsPerPercent){
            this.computedChartWidth = this.data.scenePixelsPerPercent[0] * 100;
            this.computedChartHeight = this.data.scenePixelsPerPercent[1] * 100;
            range = [this.computedChartWidth,this.computedChartHeight];
        }
        return range;
    };
    
    avsDropPrototype._resetScales = function(){
        // just a defaults
        var range = this._getRange();
        
        var xScale = d3.scale.linear();
        xScale.domain([0, 1]);
        xScale.range([0, range[0]]);

        var yScale = d3.scale.linear();
        yScale.domain([0, 1]);
        yScale.range([range[1], 0]);
        
        if (typeof this.scales === 'undefined') {
            this.scales = { zoom: { x: xScale, y: yScale } };
        } else {
            this.scales.zoom = { x: xScale, y: yScale };
        }
        if(this.dragController){
            this.dragController.x(this.scales.zoom.x);
            this.dragController.y(this.scales.zoom.y);
        }
    };
    
    /**
     * Here we add a unique ID to the clip path since
     */
    avsDropPrototype.setupClipPaths = function(uniqueId) {
        var xClip = this.clipPaths.xAxis,
            yClip = this.clipPaths.yAxis,
            pClip = this.clipPaths.plot;
        if (xClip !== null) {
            this.xClipId = 'xAxisClip' + uniqueId;
            xClip.id = this.xClipId;
        } else {
            console.warn('X-Clip not found');
        }

        if (yClip !== null) {
            this.yClipId = 'yAxisClip' + uniqueId;
            yClip.id = this.yClipId;
        } else {
            console.warn('Y-Clip not found');
        }
        if (pClip !== null) {
            this.pClipId = 'plotClip' + uniqueId;
            pClip.id = this.pClipId;
        } else {
            console.warn('P-Clip not found');
        }
    };

    avsDropPrototype.renderVisibleTilesRequest = function(doNotRenderSVG) {

        var visibleChartTiles = this.getVisibleChartTiles();

        var renderTiles = visibleChartTiles.filter(function() {
            // AFTER REVIEW : uncomment these lines
            // sd4: i'm going to re request the chart tiles.
            //          if(tile.renderStarted === true){
            //              return false;
            //          }

            return true;
        });

        // sd4: why are we doing this??? Isnt that the job of the back end code????
        // are we using this same object to track the state on the client?
        renderTiles.forEach(function(tile) {
            tile.renderStarted = true;
        });

        // sd4: the request needs just the IDs. This needs to match
        // ChartTileRequest.java, not ChartTile.java
        var renderTileIDs = renderTiles.map(function(tile) {
            return tile.id;
        });

        var tileRequestCallback = function() {
            // EXPECT data to have list of tiles that have started rendering
            // if data does not match the renderTiles, then throw warning
            // set the renderStarted to false

            if (!doNotRenderSVG) {
                this.renderSvgBack();
                // correct the psotioning
                this.svgs.plotBackOuter.setAttribute(
                    'transform',
                    'translate(-' +
                        this.sceneOffsetBase[0] +
                        ',-' +
                        this.sceneOffsetBase[1] +
                        ')'
                );
                this.svgs.plotBackInner.setAttribute(
                    'transform',
                    'translate(' +
                        this.data.sceneOffset[0] +
                        ',' +
                        this.data.sceneOffset[1] +
                        ')'
                );
            }
            this.renderVisibleChartTiles();
        }.bind(this);

        var requestObject = { tileRequest: { tileIds: renderTileIDs } };
        this.dataProvider.executeSupport(
            'getChartTiles',
            requestObject,
            tileRequestCallback,
            this.chart,
            this.uniqueKey
        );
        //}
    };

    avsDropPrototype.renderVisibleChartTiles = function() {
        var that = this;

        var sceneOffset = this.data.sceneOffset;
        var visibleTiles = this.getVisibleChartTiles();
        
        this.performanceMarkers.tileRequestStart = Date.now();
        this.performanceMarkers.numOfTilesReturned = 0;
        
        var xOff = sceneOffset[0],
            yOff = sceneOffset[1],
            translation = 'translate(' + xOff + ',' + yOff + ')';
        var tiles = d3.
            select(this.svgs.tilesGroup).
            attr('transform', function() {
                return translation;
            }).
            selectAll('.chartTile').
            data(visibleTiles, function(d) {
                return d.id;
            });

        // defaults to a transparent gif until the image loads
        tiles.
            enter().
            append('image').
            attr('xlink:href','data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==').
            attr('x', function(d) {
                var x = d.left;
                return x;
            }).
            attr('y', function(d) {
                var y = d.top;
                return y;
            }).
            attr('width', function(d) {
                return d.width;
            }).
            attr('height', function(d) {
                return d.height;
            }).
            classed('chartTile', true).
            each(function(d) {
                var tile = this;
                // AFTER REVIEW: set attributes here (perf gain)
                tile.setAttribute('width', d.width);
                //...
                var callback = function(url) {
                    // sd4: preload image and set empty tiles
                    var im = new Image();
                    im.src = url;
                    im.onload = function() {
                        d3.select(tile).attr('xlink:href', url);
                        that.performanceMarkers.tileId[d.id].imageLoaded = Date.now();
                        d.renderStarted = true;
                        ++that.performanceMarkers.numOfTilesReturned;
                        if(that.performanceMarkers.numOfTilesReturned === visibleTiles.length && window.DS.RAObjects.logDebugLevel >= 1){
                            that.performanceMarkers.chartLoaded = Date.now();
                            console.group('Performance_Data');
                            var renderRequestTime = that.performanceMarkers.endRederRequest - that.performanceMarkers.startRederRequest; 
                            console.log('Time to process renderRequest: ' +  renderRequestTime);
                            var axisLoadTime = that.performanceMarkers.tileRequestStart - that.performanceMarkers.endRederRequest;
                            console.log('Time to Load axis: ' +  axisLoadTime);
                            console.log('Number of tiles requested: ' +  visibleTiles.length);
                            
                            for(var tileId in that.performanceMarkers.tileId){
                                console.group('Tile data: ' + tileId);
                                var tilePerformance = that.performanceMarkers.tileId[tileId]; 
                                var tileLoadTime = tilePerformance.imageLoaded - that.performanceMarkers.tileRequestStart;
                                console.log('Time to load image: ' +  tileLoadTime);
                                console.groupEnd();
                            }
                            var totalProcessingTime =   that.performanceMarkers.chartLoaded - that.performanceMarkers.startRederRequest;
                            console.log('Total time to render the chart : ' +  totalProcessingTime);                           
                            console.groupEnd();     
                        }                        
                        
                        
                        that.propagateChartEvent({ eventType: 'unmask' });
                    };
                    im.onerror = function(e) {
                        console.error('Error loading tile from URL: ' + url, e);
                        console.log(tile);
                        // set it to blank tile
                        that.propagateChartEvent({ eventType: 'unmask' });
                    };

                    im.src = url;
                };

                
                that.performanceMarkers.tileId[d.id] = {};
                that.dataProvider.getResourceAsUrl(
                    'renderAVSChart',
                    d.id,
                    callback,
                    that.chart,
                    that.uniqueKey
                );
            });

        tiles.exit().remove();
    };
    // AFTER REVIEW - make sure we fallback to sceneOffset when there is no
    // zoomBehavior check with prev version of the code
    avsDropPrototype.getVisibleChartTiles = function() {
        var that = this;

        var minSceneX = this.requestObject.chartRequest.minScenePercentX * this.data.scenePixelsPerPercent[0],
            minSceneY = (100 - this.requestObject.chartRequest.maxScenePercentY) * this.data.scenePixelsPerPercent[1], 
            maxSceneX = this.requestObject.chartRequest.maxScenePercentX * this.data.scenePixelsPerPercent[0],
            maxSceneY = (100 - this.requestObject.chartRequest.minScenePercentY) * this.data.scenePixelsPerPercent[1];

        var filteredTiles = this.data.chartTiles.filter(function(tile) {
            var tileX = tile.left;
            var tileWidth = tile.width;

            var tileY = tile.top;
            var tileHeight = tile.height;

            if (tileX + tileWidth < minSceneX) {
                return false; // right side is too far to the left
            } else if (tileX > maxSceneX) {
                return false; // left side is too far to the right
            } else if (tileY + tileHeight < minSceneY) {
                return false; // bottom is too high
            } else if (tileY > maxSceneY) {
                return false; // top is too low
            }

            return true;
        }.bind(this));

        return filteredTiles;
    };

    avsDropPrototype.selectFilter = function(args) {
        if (args.eventType === 'selection') {
            return true;
        }
    };
    // only called when config changes (i.e. change to chart parameteres etc OR
    // ZOOM)
    avsDropPrototype.refresh = function() {
        // sd4: I want to throttle the zoom event every few milliseconds
        var that = this;
        var now = new Date().getTime();
        if (this.last && now < this.last + REFRESH_THROTTLE_INTERVAL) {
            // hold on
            clearTimeout(this.throttleTimer);
            this.throttleTimer = setTimeout(function() {
                console.log('refreshing on timeout');
                that.last = now;
                that.renderRequest(
                    that.requestObject,
                    that.chart,
                    that.uniqueKey
                );
            }, REFRESH_THROTTLE_INTERVAL + this.last - now);
        } else {
            // clear any timer and fire the function
            if (this.throttleTimer) {
                clearTimeout(this.throttleTimer);
            }
            this.last = now;
            console.log('refreshing right away');
            that.renderRequest(that.requestObject, that.chart, that.uniqueKey);
        }
    };

    // note: this responds to both right and left clicks
    avsDropPrototype.selectCoordinates = function(x, y) {
        var that = this;

        var clickInteractCallback = function(data) {
            that.propagateChartEvent({ eventType: 'unmask' });
            if (data === '') {
                console.warn('No data returned from click');
                return;
            }
            var clickData = JSON.parse(data);
            // sd4: click data is null if user clicked on an un rendered tile.
            if (clickData === null || !clickData.selectionInfo) {
                return;
            }
            // save the selection info
            that.selectionInfo = clickData.selectionInfo;

            if (
                !(clickData.selectionInfo instanceof Array) ||
                clickData.selectionInfo[0].numRowsSelected === 0
            ) {
                // SD4 *This comment is wrong* --> no data points clicked on, don't
                // refresh the charts
                return;
            }

            // cloning selectionInfo[0]
            var selectionArg = JSON.parse(
                JSON.stringify(clickData.selectionInfo[0])
            );
            selectionArg.eventType = 'selection';

            console.log('SelectionArg:');
            console.log(selectionArg);
            that.propagateChartEvent({ eventType: 'mask' });
            that.propagateChartEvent(selectionArg);
           
        };

        var clickedTile = this.findClickedTile(x, y);
        if (clickedTile === null) {
            return;
        }

        var xOffset = this.data.sceneOffset[0]; 
        var yOffset = this.data.sceneOffset[1]; 


        if (clickedTile.columnIndex > 0) {
            xOffset -= clickedTile.tileOverlapX;
        }
        if (clickedTile.rowIndex > 0) {
            yOffset -= clickedTile.tileOverlapY;
        }

        var gridContainer = document.querySelector('ra-simplecontainer');
        var keyPressed = gridContainer.getKeyPress();
        
        
        var requestObject = {
            clickRequest: {
                tileId: clickedTile.sceneId,
                type: 'single',
                depth: 'all',
                highlight: true,
                maxSelectedRows: 5,
                x: [x - clickedTile.left - xOffset],
                y: [y - clickedTile.top - yOffset],
                keyCtrl: keyPressed.ctrl,
                keyAlt: keyPressed.alt,
                keyShift: keyPressed.shift
            }
        };
        
        that.propagateChartEvent({ eventType: 'mask' });
        
        this.dataProvider.executeSupport(
            'getClickedObjects',
            requestObject,
            clickInteractCallback,
            this.chart,
            this.uniqueKey
        );
    };

    // TODO: should this be on the prototype?
    avsDropPrototype.pan = function() {
        var that = this;
        
        var panImages = function() {
            // adjust the sceneOffset for x
            this.data.sceneOffset[0] =
                this.dragController.x()(0) + this.sceneOffsetBase[0];

            // adjust the sceneOffset for y
            this.data.sceneOffset[1] =
                this.dragController.y()(1) + this.sceneOffsetBase[1];

            this.renderVisibleTilesRequest();
        }.bind(this);
        
        // sd4: I want to throttle the zoom event every few milliseconds
        var that = this;
        var now = new Date().getTime();
        if (this.last && now < this.last + PAN_THROTTLE_INTERVAL) {
            // hold on
            clearTimeout(this.throttleTimer);
            this.throttleTimer = setTimeout(function() {
                that.last = now;
                panImages();
            }, PAN_THROTTLE_INTERVAL + this.last - now);
        } else {
            // clear any timer and fire the function
            if (this.throttleTimer) {
                clearTimeout(this.throttleTimer);
            }
            this.last = now;
            panImages();
        }

        this.panAxes();
    };

    // the old function, it's being called in a lot of places, so lets keep it for now
    avsDropPrototype.makeZoomable = function(options){
        this._initializeToolbar(options);
        // call the new function
        this._updateDragController(options);
    };

    avsDropPrototype._updateDragController = function(options) {
        /*To include in options:
         * -X/Y only zoom
         */

        var that = this;
        this.zoomable = true;

        var translateInitial = [0,0],
            mouseInitial = [0,0],
            clickInitial = [0,0],
            range = this._getRange();
        
        // not sure where else zoomable is used, so making _zoomable a thing
        if(this._zoomable){
            // we don't want to reinitialize the dragController, so just update the scales and the translation vector
            var _x = this.data.sceneOffset[0] - this.sceneOffsetBase[0],
                _y = this.data.sceneOffset[1] - this.sceneOffsetBase[1];
            this._resetScales();
            this.dragController.translate([_x,_y]);
        }else{
            this._zoomable = true;

            // maxZoom used to be supplied as an option, it currently isn't being used at all
            options = options || {};
            
            var _processTranslationVector = function(scale, translate, viewSize) {
                // We need to make sure we're clamping the correct values.
                // This is necessary since the y-scale is inverted, since it needs to
                // measure  starting at the bottom of the plot (the x-axis) and pointing
                // upwards, but  svgs measure from the top down by default. -qw8
                var rangeMin = Math.min.apply(this, scale.range()),
                    rangeMax = Math.max.apply(this, scale.range());
                
                // we used to be getting the min/max of the scales, but since
                // we're not using d3 for zooming they aren't necessary

                // we want the value to be between rangeMin and the viewport size - rangeMax
                translate = Math.max(translate, viewSize - rangeMax);
                translate = Math.min(translate, rangeMin);

                // return the translation and the max range
                return [translate,rangeMax];
            };

            var _clampDomain = function(x, y) {
                var t = that.dragController.translate();
                
                // calculate the new translation vector
                var translateX = _processTranslationVector(x, t[0],that.plotBoxWidth),
                    translateY = _processTranslationVector(y, t[1],that.plotBoxHeight);
                
                // apply the new translation
                that.dragController.translate([translateX[0], translateY[0]]);

                // adjust the bounds used by the server ... 
                that.requestObject.chartRequest.minScenePercentX = -(translateX[0] / translateX[1]) * 100;
                that.requestObject.chartRequest.maxScenePercentX = -(translateX[0] - that.plotBoxWidth) / translateX[1] * 100;
                that.requestObject.chartRequest.minScenePercentY = ((translateY[1] + translateY[0]) / translateY[1]) * 100;
                that.requestObject.chartRequest.maxScenePercentY = ((translateY[1] + translateY[0] - that.plotBoxHeight) / translateY[1]) * 100;
                
                // we need to make sure the new calculations above are between 0 and 100
                _clampZoom();
            };
            
            // this function makes sure that the min/max percent on both the x and y axis are between 0 and 100
            var _clampZoom = function(){
                
                var clampPercentages = function(min,max){
                    // make sure we know what is/not the actual min/max in case we made a mistake earlier
                    var clampedDomain = [Math.min(min,max),Math.max(min,max)],
                        range = clampedDomain[1] - clampedDomain[0];
                    
                    // can't go beyond 100% zoom
                    if(range > 100){
                        return [0.0,100.0];
                    }

                    // we want the min to be between 0 and 100 - the range
                    clampedDomain[0] = Math.min(clampedDomain[0], 100.0 - range);
                    clampedDomain[0] = Math.max(clampedDomain[0], 0);
                    
                    // max is min + range
                    clampedDomain[1] =  clampedDomain[0] + range;
                    
                    return clampedDomain;
                };
                
                // calculate the clamped bounds
                var clampedX = clampPercentages(this.requestObject.chartRequest.minScenePercentX,this.requestObject.chartRequest.maxScenePercentX),
                    clampedY = clampPercentages(this.requestObject.chartRequest.minScenePercentY,this.requestObject.chartRequest.maxScenePercentY);

                // set the bounds
                this.requestObject.chartRequest.minScenePercentX = clampedX[0];
                this.requestObject.chartRequest.maxScenePercentX = clampedX[1];
                this.requestObject.chartRequest.minScenePercentY = clampedY[0];
                this.requestObject.chartRequest.maxScenePercentY = clampedY[1];
            }.bind(this);
            
            var _zoom = function(zoomInterval,zoomCenter) {
                
                // get the bounds (if not defined then set to the defaults)
                var zoomMinX = typeof this.requestObject.chartRequest.minScenePercentX !== 'undefined' ? this.requestObject.chartRequest.minScenePercentX : 0.0,
                    zoomMaxX = typeof this.requestObject.chartRequest.maxScenePercentX !== 'undefined' ? this.requestObject.chartRequest.maxScenePercentX : 100.0,
                    zoomMinY = typeof this.requestObject.chartRequest.minScenePercentY !== 'undefined' ? this.requestObject.chartRequest.minScenePercentY : 0.0,
                    zoomMaxY = typeof this.requestObject.chartRequest.maxScenePercentY !== 'undefined' ? this.requestObject.chartRequest.maxScenePercentY : 100.0;

                // get the new range 
                var zoomRangeX =  Math.max(zoomInterval * (zoomMaxX - zoomMinX),10.0),
                    zoomRangeY = Math.max(zoomInterval * (zoomMaxY - zoomMinY),10.0);

                // set the new bounds
                var zoomMinX = zoomCenter[0] - (zoomRangeX * 0.5),
                    zoomMaxX = zoomCenter[0] + (zoomRangeX * 0.5),
                    zoomMinY = zoomCenter[1] - (zoomRangeY * 0.5),
                    zoomMaxY = zoomCenter[1] + (zoomRangeY * 0.5);
                
                // apply the new bounds to the chartRequest
                this.requestObject.chartRequest.minScenePercentX = zoomMinX;
                this.requestObject.chartRequest.maxScenePercentX = zoomMaxX;
                this.requestObject.chartRequest.minScenePercentY = zoomMinY;
                this.requestObject.chartRequest.maxScenePercentY = zoomMaxY;  

                // clamp the new bounds
                _clampZoom();
                this.propagateChartEvent({ eventType: 'mask' });
                this.refresh();
            }.bind(this);

            var _zoomIn = function(centerCoords){
                var zoomInterval = 0.90, // TODO: should be a constant at the top of the file
                    zoomCenter = centerCoords instanceof Array ? centerCoords : [50.0,50.0];
                _zoom(zoomInterval,zoomCenter);
            }.bind(this);
            
            var _zoomOut = function(centerCoords){
                var zoomInterval = 1.111111111, // TODO: should be a constant at the top of the file
                    zoomCenter = centerCoords instanceof Array ? centerCoords : [50.0,50.0];
                _zoom(zoomInterval,zoomCenter);
            }.bind(this);
            
            var _updateSelectionRectangle = function(initialPosition,finalPosition){
                var x0 = Math.min(initialPosition[0],finalPosition[0]),
                    x1 = Math.max(initialPosition[0],finalPosition[0]),
                    y0 = Math.min(initialPosition[1],finalPosition[1]),
                    y1 = Math.max(initialPosition[1],finalPosition[1]);
                
                // account for the offset ...
                x0 -= that.data.sceneOffset[0];
                x1 -= that.data.sceneOffset[0];
                y0 -= that.data.sceneOffset[1];
                y1 -= that.data.sceneOffset[1];
                
                var w = x1 - x0,
                    h = y1 - y0;

                if(that.svgs.selectionRectangleShadow.parentNode !== that.svgs.tilesGroup){
                    that.svgs.tilesGroup.appendChild(that.svgs.selectionRectangleShadow);
                }
                if(that.svgs.selectionRectangle.parentNode !== that.svgs.tilesGroup){
                    that.svgs.tilesGroup.appendChild(that.svgs.selectionRectangle);
                }
                
                
                d3.select(that.svgs.selectionRectangleShadow)
                    .attr('d','M'+0+','+0+'h'+range[0]+'v'+range[1]+'h-'+range[0]+'zM'+x0+','+y0+'v'+h+'h'+w+'v-'+h+'z')
                    .attr('fill','rgba(30,30,30,0.4)');
                
                d3.select(that.svgs.selectionRectangle)
                    .attr('x',x0)
                    .attr('y',y0)
                    .attr('width',w)
                    .attr('height',h)
                    .attr('fill','none');
            };
            
            var _clearSelectionRectangle = function(){
                d3.select(that.svgs.selectionRectangleShadow)
                    .attr('d', null);
                
                d3.select(that.svgs.selectionRectangle)
                    .attr('x', null)
                    .attr('y', null)
                    .attr('width', null)
                    .attr('height', null)
                    .attr('fill', null);
            };
            
            var _zoomBox = function(initialPosition,finalPosition){
                // find the corners in the right places
                var minX = Math.min(initialPosition[0],finalPosition[0]),
                    maxX = Math.max(initialPosition[0],finalPosition[0]),
                    minY = Math.min(initialPosition[1],finalPosition[1]),
                    maxY = Math.max(initialPosition[1],finalPosition[1]),
                    rangeX = maxX - minX,
                    rangeY = maxY - minY;
                
                if(rangeX < 10.0){
                    var rangeDiffX = (10.0 - rangeX)/2;
                    minX -= rangeDiffX;
                    maxX += 10.0 - rangeX;
                }
                if(rangeY < 10.0){
                    var rangeDiffY = (10.0 - rangeY)/2;
                    minY -= rangeDiffY;
                    maxY += rangeDiffY;
                }

                // this is already in percentages ... so zoom away! (they may be >100 or <0 so prepare)
                this.requestObject.chartRequest.minScenePercentX = Math.max(minX,0.0);
                this.requestObject.chartRequest.maxScenePercentX = Math.min(maxX,100.0);
                this.requestObject.chartRequest.minScenePercentY = Math.max(minY,0.0);
                this.requestObject.chartRequest.maxScenePercentY = Math.min(maxY,100.0);  

                // clamp the zoom percentages
                this.propagateChartEvent({ eventType: 'mask' });
                this.refresh();
                
            }.bind(this);
            
            this.dragController = d3.behavior.zoom()
                .scaleExtent([1, 1]) // no change in zoom levels
                .on('zoomstart', function(){
                    // keep a copy to use later
                    translateInitial = that.dragController.translate().slice()
                    mouseInitial = d3.mouse(this).slice();
                    // update the range
                    range = that._getRange();
                    // we need to account for the y location being flipped between d3 and the servant
                    clickInitial = [((mouseInitial[0] - that.data.sceneOffset[0]) / range[0]) * 100, 100 - ((mouseInitial[1] - that.data.sceneOffset[1]) / range[1]) * 100];
                })
                .on('zoom', function() {
                    d3.event.sourceEvent.stopImmediatePropagation();
                    if(that.interactMode === 'pan'){
                        _clampDomain(that.scales.zoom.x,that.scales.zoom.y);

                        that.pan();
                    }else{
                        // only change this if panning, re-apply the initial
                        that.dragController.translate(translateInitial);
                        
                        if(that.interactMode === 'trapzoom'){
                            var mouseCurrent = d3.mouse(this).slice();
                            _updateSelectionRectangle(mouseInitial,mouseCurrent);
                        }
                    }
                })
                .on('zoomend',function(){
                    if (d3.event.sourceEvent) {
                          d3.event.sourceEvent.stopImmediatePropagation();
                    }
                    var mouseFinal = d3.mouse(this).slice(),
                        // we need to account for the y location being flipped between d3 and the servant
                        clickFinal = [((mouseFinal[0] - that.data.sceneOffset[0]) / range[0]) * 100, 100 - ((mouseFinal[1] - that.data.sceneOffset[1]) / range[1]) * 100];
                    
                    // perform the correct interaction
                    if (that.interactMode === 'zoomin') {
                        _zoomIn(clickFinal);
                    }else if(that.interactMode === 'zoomout'){
                        _zoomOut(clickFinal);
                    }else if(that.interactMode === 'select'){
                        that.selectCoordinates.apply(that,mouseFinal);
                    }else if(that.interactMode === 'trapzoom'){
                        _clearSelectionRectangle();
                        _zoomBox(clickInitial,clickFinal);
                    }
                });            
            this._resetScales();
            var mGI = d3.select(this.svgs.midGroupInner)
            mGI.call(this.dragController);
            mGI.on('wheel.zoom',null); // disable the mouse wheel
        }
    };

    avsDropPrototype.updateTileData = function(refreshedData) {
        if (
            this.data === null ||
            refreshedData === null ||
            this.data.chartTiles === null ||
            this.data.chartTiles.length < 1
        ) {
            return;
        }
        var curNewTiles = refreshedData.chartTiles;
        for (var i = 0; i < this.data.chartTiles.length; i++) {
            var curOldTile = this.data.chartTiles[i];
            for (var j = 0; j < curNewTiles.length; j++) {
                if (curOldTile.sceneId === curNewTiles[j].sceneId) {
                    this.data.chartTiles[i] = curNewTiles[j];
                    break;
                }
                // bring back the previous tile if it was highlighted
                // else {
                //    curOldTile.id = curOldTile.sceneId;
                //}
            }
        }
    };

    avsDropPrototype.updateClipPositions = function() {
        /*
         * We need to update the clip path positions by applying an inverse
         * transform to the sum of all transforms on the parent groups of the
         * mainAxisGroup in each axis (in addition to the transform on that group).
         * This is necessary since the origin for the clip path is defined as the
         * origin of the mainAxisGroup element on which it is defined. Clip paths
         * also CAN NOT HAVE GROUPS, so all transforms are saved and applied at
         * once.
         */

        var that = this;

        var getTransform = function(d) {
            return 'translate(' + d[0] + ',' + d[1] + ')';
        };

        var xTranslate = [0, 0];
        var yTranslate = [0, 0];

        Object.keys(this.clipPositions.xAxis).forEach(function(key) {
            var clip = that.clipPositions.xAxis[key];
            clip.forEach(function(d, i) {
                xTranslate[i] += d;
            });
        });

        Object.keys(this.clipPositions.yAxis).forEach(function(key) {
            var clip = that.clipPositions.yAxis[key];
            clip.forEach(function(d, i) {
                yTranslate[i] += d;
            });
        });

        this.clipPaths.xAxis.setAttribute(
            'transform',
            getTransform(xTranslate)
        );
        this.clipPaths.yAxis.setAttribute(
            'transform',
            getTransform(yTranslate)
        );
    };

    avsDropPrototype.findClickedTile = function(x, y) {
        if (this.data.chartTiles === null) {
            return null;
        }
        var xClick = x - this.data.sceneOffset[0];
        var yClick = y - this.data.sceneOffset[1];

        for (var i = 0; i < this.data.chartTiles.length; i++) {
            var curTile = this.data.chartTiles[i];
            if (curTile.type === 'chartTile') {
                var left = curTile.left;
                var right = left + curTile.width;
                var top = curTile.top;
                var bottom = top + curTile.height;
                if (
                    left < xClick &&
                    right > xClick &&
                    top < yClick &&
                    bottom > yClick
                ) {
                    return curTile;
                }
            }
        }
        return null;
    };

    avsDropPrototype.setBackgroundColor = function(color) {
        d3.select(this.svgs.root).style('background-color', color);
    };

    avsDropPrototype.setTotalHeight = function(totalHeight) {
        this.dimensions.plotHeight = totalHeight;
        d3.select(this.svgs.root).style('height', totalHeight + 'px');
        d3.select(this.svgs.root).style('background-color', 'white');
    };

    avsDropPrototype.setTotalWidth = function(totalWidth) {
        this.dimensions.plotWidth = totalWidth;
        d3.select(this.svgs.root).style('width', totalWidth + 'px');
    };

    avsDropPrototype.setLegend = function(legend) {
        this.legend = legend;
    };

    avsDropPrototype.setLegendFactory = function(factory) {
        this.legendFactory = factory;
    };

    avsDropPrototype.removeOverlayDivs = function() {
        var div;
        // FIXME: investigate why the histogram does not have overlayDivs
        if (this.overlayDivs) {
            while ((div = this.overlayDivs.splice(0, 1)[0])) {
                this.removeChild(div);
            }
        }
    };
    avsDropPrototype.tilesCallback = function(data, callback) {
        this.data = JSON.parse(data);

        this.plotBoxWidth =
            this.data.sceneExtents[2] - this.data.sceneExtents[0];
        this.plotBoxHeight =
            this.data.sceneExtents[1] - this.data.sceneExtents[3];
        this.xAxisHeight =
            this.requestObject.chartRequest.height - this.data.sceneExtents[1];
        this.yAxisWidth = this.data.sceneExtents[0];
        
        this.yAxisSecWidth = this.requestObject.chartRequest.width - this.data.sceneExtents[2];

        this.data.scenePixelsPerPercent =
            this.data.scenePixelsPerPercent || this.data.pixelsPerPercent;
        
        // make sure the scales are in line with the scenePixelsPerPercent from the server,
        // this also calculates the computedChartWidth/Height
        this._resetScales();

        if (
//            this.zoomable &&
            typeof this.sceneOffsetBase === 'undefined' 
        ) {
            // we need to set the base offset for when we start panning
            this.sceneOffsetBase = [];
            this.sceneOffsetBase[0] = Number(this.data.sceneOffset[0]);
            this.sceneOffsetBase[1] = Number(this.data.sceneOffset[1]);
                        
        }
        
        this.chartTileCollection = [];
        for (var i = 0; i < this.data.chartTiles.length; i++) {
            var curTile = this.data.chartTiles[i];
            if (curTile.renderStarted === true) {
                this.chartTileCollection.push(curTile);
            }
        }

        this.renderSvgBack();
        // sending true means that we are not rendering the svg background - which
        // is what we need for the tiles
        this.renderVisibleTilesRequest(true);
        this.renderSvgFront();

        this.updateAxisPositions();

        // Output statistics data to console for now
        if (
            typeof this.data.statistics !== 'undefined' &&
            this.data.statistics !== null
        ) {
            console.log('Statistics Data');
            for (var i = 0; i < this.data.statistics.length; i++) {
                console.log('Chart[' + i + ']');
                var curChartStats = this.data.statistics[i];
                for (var j = 0; j < curChartStats.length; j++) {
                    var curStatSet = curChartStats[j];
                    console.log(
                        'Series=' +
                            curStatSet.seriesIndex +
                            ', ' +
                            curStatSet.statistic +
                            ' = ' +
                            curStatSet.value
                    );
                }
            }
        }

        if (typeof callback === 'function') {
            callback(this.data);
        }
    };
    avsDropPrototype.printRequest = function(
            _requestObject,
            chart,
            uniqueKey,
            callback
        ) {
    	
    		var requestObject = JSON.parse(JSON.stringify(_requestObject));
            // for some reason this blows up if you try replacing a parameter
            // this.requestAxes(requestObject, chart, uniqueKey, function(){

            requestObject.chartRequest.axesAtFullSize = true;
            requestObject.chartRequest.axesAtFullRange = true;
            requestObject.chartRequest.sceneOutput = 'axesAndCharts';
//            if (this.chart === null) {
//                this.setupClipPaths(chart.chartId);
//            }
//            // Save chart object for subsequent click requests
//            this.chart = chart;
//            this.uniqueKey = uniqueKey;
//            this.chart.id = this.chart.chartId;
//
//            // make sure the clipping path to the group is set properly (and the rear
//            // group ...)
//            this.svgs.midGroupInner.setAttribute(
//                'clip-path',
//                'url(#' + this.pClipId + ')'
//            );
//            this.svgs.plotBack.setAttribute(
//                'clip-path',
//                'url(#' + this.pClipId + ')'
//            );
//            this.requestObject = requestObject;
//

           /*var url= this.dataProvider.getURL(
                'printAVSChart',
                requestObject,
                chart,
                uniqueKey
            );*/
           
           this.dataProvider.downloadFile('printAVSChart', requestObject, chart, uniqueKey);
        };

    avsDropPrototype.renderRequest = function(
        requestObject,
        chart,
        uniqueKey,
        callback
    ) {
        // for some reason this blows up if you try replacing a parameter
        // this.requestAxes(requestObject, chart, uniqueKey, function(){

        requestObject.chartRequest.axesAtFullSize = true;
        requestObject.chartRequest.axesAtFullRange = true;
        requestObject.chartRequest.sceneOutput = 'axesAndCharts';
        if (this.chart === null) {
            this.setupClipPaths(chart.chartId);
        }
        // Save chart object for subsequent click requests
        this.chart = chart;
        this.uniqueKey = uniqueKey;
        this.chart.id = this.chart.chartId;

        // make sure the clipping path to the group is set properly (and the rear
        // group ...)
        this.svgs.midGroupInner.setAttribute(
            'clip-path',
            'url(#' + this.pClipId + ')'
        );
        this.svgs.plotBack.setAttribute(
            'clip-path',
            'url(#' + this.pClipId + ')'
        );
        this.requestObject = requestObject;

        var executeCallbacks = function(data) {
            this.performanceMarkers.endRederRequest = Date.now();
            this.tilesCallback.call(this, data, callback);
        }.bind(this);

        
        this.propagateChartEvent({ eventType: 'mask' });
        
        this.performanceMarkers = {};
        this.performanceMarkers.tileId = [];
        this.performanceMarkers.startRederRequest = Date.now();
        
        
        this.dataProvider.executeSupport(
            'renderAVSChart',
            this.requestObject,
            executeCallbacks,
            chart,
            uniqueKey
        );
    };

    avsDropPrototype.requestAxes = function(
        requestObject,
        chart,
        uniqueKey,
        callback
    ) {
        // This should render an axes tile at full size, which can then be
        // repositioned on the pan event.
        
        var axesCallback = function(data) {
            var _data = JSON.parse(data);
            if (!_data.svgFront) {
                console.warn('svgFront is not defined');
            }

            // we'll use the axes from the data from tilesCallback, but we
            // need the axes title/units from this
            this.newFrontSVG = JSON.parse(data).svgFront;

            if (callback) {
                callback.call(this);
            }
        }.bind(this);

        requestObject.chartRequest.sceneOutput = 'axesOnly';
        requestObject.chartRequest.axesAtFullSize = true;
        requestObject.chartRequest.axesAtFullRange = false;
        this.requestObject = requestObject;

        // FIXME: hack
        this.requestObject.chartRequest.data.raw.forEach(function(paramId) {
            if (this.requestObject.data.raw.indexOf(paramId) === -1) {
                this.requestObject.data.raw.push(paramId);
            }
        }, this);

        this.dataProvider.executeSupport(
            'renderAVSChart',
            this.requestObject,
            axesCallback,
            chart,
            uniqueKey
        );
    };

    avsDropPrototype.renderSvgBack = function(svgData) {
        // make sure svgData is set with something
        svgData = svgData || this.data.svgBack;

        if (svgData === 'undefined') {
            return;
        }

        // likely won't work in IE11 ...
        this.processSVGString(svgData, this.svgs.plotBackOuter, function(
            _svgData
        ) {
            if (_svgData && _svgData.childNodes.length > 0) {
                while (_svgData.childNodes.length > 0) {
                    var node = _svgData.childNodes[0];
                    if (node.id === 'sceneBackground') {
                        // FIXME: this should be a class on the servant, not an ID
                        var sceneBack = this.svgs.chartBack.querySelector(
                            '#' + node.id
                        );
                        if (sceneBack !== null) {
                            sceneBack.parentNode.removeChild(sceneBack);
                        }
                        if (this.svgs.chartBack.childNodes.length > 0) {
                            this.svgs.chartBack.insertBefore(
                                node,
                                this.svgs.rearGroup.childNodes[0]
                            );
                        } else {
                            this.svgs.chartBack.appendChild(node);
                        }
                    } else {
                        this.svgs.plotBackOuter.appendChild(node);
                    }
                }
            }
        });

        this.svgs.plotBackOuter.setAttribute(
            'transform',
            'translate(-' +
                this.sceneOffsetBase[0] +
                ',-' +
                this.sceneOffsetBase[1] +
                ')'
        );
        this.svgs.plotBackInner.setAttribute(
            'transform',
            'translate(' +
                this.data.sceneOffset[0] +
                ',' +
                this.data.sceneOffset[1] +
                ')'
        );
    };

    // code for render front and back SVG expecst no SVG tags at first children level, which is no the case 
    // for SVGS generated at servant, replace those svg elements with child if those elements
    
    avsDropPrototype.flattenFirstChildSVG = function(svgElement) {
        
        // first make a list of SVG elements which needs to be remove
        var firstLevelSvgElements = [];
        for(var i = 0; i < svgElement.childNodes.length;++i){
            var firstLevelElement = svgElement.childNodes[i];
            if(firstLevelElement.tagName === 'svg'){
                firstLevelSvgElements.push(firstLevelElement);
            }
        }
        
        var childNodesToBeAdded = [];
        for(var i = 0; i < firstLevelSvgElements.length;++i){
            var svgElementToBeRemoved = firstLevelSvgElements[i];
                        
            for(var j = 0; j < svgElementToBeRemoved.childNodes.length;++j){
                var childNode =  svgElementToBeRemoved.childNodes[j];
                if(childNode.nodeType === 1){ //element node
                    childNodesToBeAdded.push(childNode);
                }
                
            }
            svgElement.removeChild(svgElementToBeRemoved);        
        }
        for(var i = 0; i < childNodesToBeAdded.length;++i){
                var childNode =  childNodesToBeAdded[i];
                childNode.parentNode.removeChild(childNode);
                svgElement.appendChild(childNode);
        }
    };

    avsDropPrototype.processSVGString = function(
        svgData,
        parentSVG,
        postProcessCallback
    ) {
        var svgDataString =
            '<svg xmlns="http://www.w3.org/2000/svg">' + svgData + '</svg>';
        var parser = new DOMParser();
        var svgFromResponse = parser.parseFromString(
            svgDataString,
            'image/svg+xml'
        );
        // empty the parent
        if (parentSVG) {
            d3.
                select(parentSVG).
                selectAll('*').
                remove();
        }
        
        var firstElementChild = svgFromResponse.firstElementChild || svgFromResponse.firstChild;
        
        this.flattenFirstChildSVG(firstElementChild);
         
        // add all the children from the response
        if (typeof postProcessCallback !== 'function') {
            if (firstElementChild) {
                while (
                    firstElementChild.childNodes.length > 0
                ) {
                    var node = firstElementChild.childNodes[0];
                    if (parentSVG) {
                        parentSVG.appendChild(node);
                    }
                }
            }
        } else {
            if (typeof postProcessCallback === 'function') {
                // send the processed response back to be processed
                postProcessCallback.call(
                    this,
                    firstElementChild
                );
            }
        }
    };

    avsDropPrototype.renderSvgFront = function(svgData) {
        // make sure svgData is set with somethign
        svgData = svgData || (this.data && this.data.svgFront);

        if (typeof svgData === 'undefined') {
            console.warn('svgData is undefined: not able to render axes');
            return;
        }

        // FIXME: we should push this structure to the servant
        var fixAxisStructure = function(fullAxis, partialAxis) {
            var mainAxisGroup = fullAxis.querySelector('.mainAxisGroup'),
                mainAxisInnerGroup = fullAxis.querySelector(
                    '.mainAxisInnerGroup'
                );
            if (!mainAxisGroup) {
                //NOTE: fullAxis.classList.add fails in IE. (undefined for SVGs?)
                d3.select(fullAxis).classed('avs-svg-axis', true);

                // we want to clip this group
                mainAxisGroup = document.createElementNS(
                    'http://www.w3.org/2000/svg',
                    'svg'
                );
                d3.select(mainAxisGroup).classed('mainAxisGroup', true);

                // we do not want to translate this group
                var mainAxisOuterGroup = document.createElementNS(
                    'http://www.w3.org/2000/svg',
                    'g'
                );
                d3.select(mainAxisOuterGroup).classed('mainAxisOuterGroup', true);
                mainAxisGroup.appendChild(mainAxisOuterGroup);

                // we want to translate this group
                mainAxisInnerGroup = document.createElementNS(
                    'http://www.w3.org/2000/svg',
                    'g'
                );
                d3.select(mainAxisInnerGroup).classed('mainAxisInnerGroup', true);
                mainAxisOuterGroup.appendChild(mainAxisInnerGroup);

                var elementArray = fullAxis.querySelectorAll('.avs-svg-axis>g');
                [].forEach.call(elementArray, function(el) {
                    if (
                        el.id === 'NumericAxis-text' ||
                        el.id === 'NumericAxis-unit'
                    ) {
                        var _el = partialAxis.querySelector('#' + el.id);
                        if (_el === null) {
                            _el = el;
                        }
                        mainAxisOuterGroup.appendChild(_el);
                        return;
                    }
                    mainAxisInnerGroup.appendChild(el);
                });
                return mainAxisGroup;
            }
            return fullAxis;
        };

        var parseXAxisSVG = function(node, altNode) {
            if (this._xSVG) {
                this.removeChild(this._xSVG);
            }
            this._xSVG = fixAxisStructure(altNode, node);
            var mag = this._xSVG.querySelector('.mainAxisInnerGroup');
            // may need to use something other than plogBoxHeight below
            mag.setAttribute(
                'transform',
                'translate(-' +
                    this.yAxisWidth +
                    ',-' +
                    this.computedChartHeight +
                    ')'
            );

            // position the axis
            this._xSVG.style.position = 'absolute';
            this._xSVG.style.top = this.plotBoxHeight + 'px';
            this._xSVG.style.left = this.yAxisWidth + 'px';
            this._xSVG.style.width = this.plotBoxWidth + 'px';
            this._xSVG.style.height = this.xAxisHeight + 'px';

            // scroll the elements within this :)

            // add to the DOM
            this.appendChild(this._xSVG);
        }.bind(this);

        var parseYAxisSVG = function(node, altNode) {
            if (this._ySVG) {
                this.removeChild(this._ySVG);
            }
            this._ySVG = fixAxisStructure(altNode, node);

            // position the axis
            this._ySVG.style.position = 'absolute';
            this._ySVG.style.top = 0 + 'px'; // check

            this._ySVG.style.left = 0 + 'px'; // check
            this._ySVG.style.width = this.yAxisWidth + 1 + 'px'; // FIXME: extra space to account for sizing bug
            this._ySVG.style.height = this.plotBoxHeight + 'px';

            // add to the DOM
            this.appendChild(this._ySVG);
        }.bind(this);
        
        var parseYAxisSecSVG = function(node, altNode) {
            if (this._ySVGSec) {
                this.removeChild(this._ySVGSec);
            }
            this._ySVGSec = fixAxisStructure(altNode, node);

            // position the axis
            this._ySVGSec.style.position = 'absolute';
            this._ySVGSec.style.top = 0 + 'px'; // check
            this._ySVGSec.style.right = 0 + 'px'; // check
            
            this._ySVGSec.style.width = this.yAxisSecWidth + 1 + 'px'; // FIXME: extra space to account for sizing bug
            this._ySVGSec.style.height = this.plotBoxHeight + 'px';

            // add to the DOM
            this.appendChild(this._ySVGSec);
        }.bind(this);
        
        var altAxes = null;
        this.processSVGString(
            this.data.svgFullRangeFront || svgData,
            null,
            function(_svgData) {
                altAxes = _svgData;
            }
        );

        this.processSVGString(svgData, this.svgs.frontGroup, function(
            _svgData
        ) {
            altAxes = altAxes || _svgData;
            if (_svgData && _svgData.childNodes.length > 0) {
                for (var i = _svgData.childNodes.length - 1; i > -1; i--) {
                    var node = _svgData.childNodes[i],
                        nodeClass = '';
                    if(typeof node.getAttribute === 'function'){
                        nodeClass = node.getAttribute('class');
                    }
                    // can't use className or classList, use getAttribute('class')
                    // and store to a variable to prevent repeated function calls
                    if (nodeClass === 'xAxis') {
                        parseXAxisSVG(
                            node,
                            altAxes.querySelector('.' + nodeClass) || node
                        );
                    } else if (nodeClass === 'yAxis') {
                        parseYAxisSVG(
                            node,
                            altAxes.querySelector('.' + nodeClass) || node
                        );
                    } else if (nodeClass === 'yAxisSecondary') {
                        parseYAxisSecSVG(
                            node,
                            altAxes.querySelector('.' + nodeClass) || node
                        );
                    } else {
                        this.svgs.frontGroup.appendChild(node);
                    }
                }
            }
        });
    };

    avsDropPrototype.updateAxisPositions = function(axisHtml) {
        var that = this;

        var positionXAxis = function(node) {
            if (!this._xSVG) {
                return;
            }
            var mag = this._xSVG.querySelector('.mainAxisInnerGroup');

            var xPos = -this.yAxisWidth,
                yPos = -this.computedChartHeight;
            if (this.data.sceneOffset) {
                xPos += this.data.sceneOffset[0] - this.yAxisWidth;
            }
            // may need to use something other than plogBoxHeight below
            mag.setAttribute(
                'transform',
                'translate(' + xPos + ',' + yPos + ')'
            );

            var axisText = this._xSVG.querySelector('#NumericAxis-text');
            if (axisText) {
                axisText.setAttribute(
                    'transform',
                    'translate(-' +
                        this.yAxisWidth +
                        ',-' +
                        this.plotBoxHeight +
                        ')'
                );
            }
        }.bind(this);

        var positionYAxis = function() {
            if (!this._ySVG) {
                return;
            }
            var mag = this._ySVG.querySelector('.mainAxisInnerGroup');

            // def position is 0, 0
            var xPos = 0,
                yPos = 0;
            if (this.data.sceneOffset) {
                yPos = this.data.sceneOffset[1];
            }

            // may need to use something other than plogBoxHeight below
            mag.setAttribute(
                'transform',
                'translate(' + xPos + ',' + yPos + ')'
            );
        }.bind(this);

        var positionYAxisSec = function() {
            if (!this._ySVGSec) {
                return;
            }
            var mag = this._ySVGSec.querySelector('.mainAxisInnerGroup');

            // def position is 0, 0
            var xPos = 0,
                yPos = 0;
            if (this.data.sceneOffset) {
                yPos = this.data.sceneOffset[1];
            }
            if (typeof this.plotBoxWidth !== 'undefined' && typeof this.yAxisWidth !== 'undefined'){
                xPos = this.plotBoxWidth + this.yAxisWidth;
            }

            // may need to use something other than plogBoxHeight below
            mag.setAttribute(
                'transform',
                'translate(-' + xPos + ',' + yPos + ')'
            );
            
            var axisText = this._ySVGSec.querySelector('#NumericAxis-text');
            if (axisText) {
                axisText.setAttribute(
                    'transform',
                    'translate(-' + xPos + ',' + yPos + ')'
                );
            }
            
        }.bind(this);

        positionXAxis();
        positionYAxis();
        positionYAxisSec();

        // FIXME: shouldn't do this here ..
        this.clipPaths.plotArea.setAttribute(
            'transform',
            'translate(' + this.yAxisWidth + ',0)'
        ); // plotClip.querySelector('rect');
        this.clipPaths.plotArea.setAttribute('width', this.plotBoxWidth);
        this.clipPaths.plotArea.setAttribute('height', this.plotBoxHeight);
    };

    avsDropPrototype.panAxes = function() {
        var sceneOffset = this.data.sceneOffset;
        if (!sceneOffset) {
            return;
        }

        this.updateAxisPositions(this.data.svgFront);
    };

    avsDropPrototype.updatePlotClip = function() {
        var sceneOffset = this.data.sceneOffset;

        // Inverse transform on tiles clip path
        this.clipPaths.plot.setAttribute(
            'transform',
            'translate(' + -sceneOffset[0] + ',' + -sceneOffset[1] + ')'
        );
    };

    avsDropPrototype.removeChartTiles = function() {
        this.clearFrontGroup();
        this.clearRearGroup();
        this.clearChartTiles();
        
        if (this._xSVG) {
            this.removeChild(this._xSVG);
            delete this._xSVG;
        }
        if (this._ySVG) {
            this.removeChild(this._ySVG);
            delete this._ySVG;
        }
        
        if (this._ySVGSec) {
            this.removeChild(this._ySVGSec);
            delete this._ySVGSec;
        }
            
    };

    avsDropPrototype.clearChartTiles = function() {
        var emptyData = [];

        d3.
            select(this.svgs.tilesGroup).
            selectAll('.chartTile').
            data(emptyData).
            exit().
            remove();
    };

    avsDropPrototype.clearFrontGroup = function() {
        while (this.svgs.frontGroup.firstChild) {
            this.svgs.frontGroup.removeChild(this.svgs.frontGroup.firstChild);
        }
    };

    avsDropPrototype.clearRearGroup = function() {
        while (this.svgs.chartBack.firstChild) {
            this.svgs.chartBack.removeChild(this.svgs.chartBack.firstChild);
        }

        while (this.svgs.plotBackOuter.firstChild) {
            this.svgs.plotBackOuter.removeChild(
                this.svgs.plotBackOuter.firstChild
            );
        }
    };

    avsDropPrototype.removeLegendTiles = function() {
        if (typeof this.legend === 'undefined' || this.legend === null) {
            return;
        }
        while (this.legend.querySelector('.images').firstChild) {
            this.legend.
                querySelector('.images').
                removeChild(this.legend.querySelector('.images').firstChild);
        }
    };

    Polymer(avsDropPrototype);
    GLOBAL.DS.RAComponents.avsdropchartelement = avsDropPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
