(function(GLOBAL, template) {
    var avsDropPrototype = {
        is: 'ra-avsdropchartelementmatrix',
        behaviors: [GLOBAL.DS.RAComponents.chart]
    };

    avsDropPrototype.setDataProvider = function(dataProvider) {
        this.dataProvider = dataProvider;
    };

    avsDropPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.chart.createdCallback.call(this);
        var that = this;

        this.dimensions = { width: 100, height: 100 };

        this.chart = null;
        this.chartTileCollection = null;
        this.uniqueKey = null;
        this.selectionInfo = null;
        this.clickMode = 'select'; // pan, zoom, select
        this.panDirection = -1;

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.svgs = { root: this.querySelector('svg') };

        this.addClickHandler(function(args) {
            var that = this;

            // Get existing min/max percents
            var minPercentX =
                typeof this.requestObject.chartRequest.minScenePercentX ===
                'undefined'
                    ? 0
                    : this.requestObject.chartRequest.minScenePercentX;
            var maxPercentX =
                typeof this.requestObject.chartRequest.maxScenePercentX ===
                'undefined'
                    ? 100
                    : this.requestObject.chartRequest.maxScenePercentX;
            var minPercentY =
                typeof this.requestObject.chartRequest.minScenePercentY ===
                'undefined'
                    ? 0
                    : this.requestObject.chartRequest.minScenePercentY;
            var maxPercentY =
                typeof this.requestObject.chartRequest.maxScenePercentY ===
                'undefined'
                    ? 100
                    : this.requestObject.chartRequest.maxScenePercentY;

            if (this.clickMode === 'pan') {
                // Simulate a translate of 20 pixels
                var xDeltaPixel = this.panDirection * 40;
                var yDeltaPixel = this.panDirection * 40;

                var xDeltaPercent = xDeltaPixel / this.data.pixelsPerPercent[0];
                var yDeltaPercent = yDeltaPixel / this.data.pixelsPerPercent[1];

                minPercentX += xDeltaPercent;
                maxPercentX += xDeltaPercent;
                minPercentY += yDeltaPercent;
                maxPercentY += yDeltaPercent;

                // Check for valid values.  If max < 0 or min > 100 we are outside
                // the range of data
                if (minPercentX > 100) {
                    minPercentX = 100;
                    this.panDirection *= -1;
                }
                if (maxPercentX < 0) {
                    maxPercentX = 0;
                    this.panDirection *= -1;
                }
                if (minPercentY > 100) {
                    minPercentY = 100;
                    this.panDirection *= -1;
                }
                if (maxPercentY < 0) {
                    maxPercentY = 0;
                    this.panDirection *= -1;
                }

                this.requestObject.chartRequest.minScenePercentX = minPercentX;
                this.requestObject.chartRequest.maxScenePercentX = maxPercentX;
                this.requestObject.chartRequest.minScenePercentY = minPercentY;
                this.requestObject.chartRequest.maxScenePercentY = maxPercentY;
                this.requestObject.chartRequest.axesAtFullRange = false;
                this.removeChartTiles();
                this.renderSvgBack();
                this.renderRequest(
                    this.requestObject,
                    this.chart,
                    this.uniqueKey
                );
                this.renderSvgFront();
            } else if (this.clickMode === 'zoom') {
                // New zoom = old zoom * zoomFactor
                var zoomFactor = 2;
                var zoomLevelX = 100 * zoomFactor / (maxPercentX - minPercentX);
                var zoomLevelY = 100 * zoomFactor / (maxPercentY - minPercentY);

                // Reset zoom level to create a demo loop
                if (zoomLevelX > 128 || zoomLevelY > 128) {
                    zoomLevelX = 1;
                    zoomLevelY = 1;
                }

                // Calculate the new percent ranges (max-min)
                var rangePercentX = 100 / zoomLevelX;
                var rangePercentY = 100 / zoomLevelY;

                // Calculate the location where the user clicked in percent
                var centerPercentX =
                    (this.clickCoordinates[0] - this.data.sceneOffset[0]) /
                    this.data.pixelsPerPercent[0];
                var centerPercentY =
                    100 -
                    (this.clickCoordinates[1] - this.data.sceneOffset[1]) /
                        this.data.pixelsPerPercent[1];

                // Calculate the new min/max percents.  Maintain the same zoom level
                // but keep 0-100
                minPercentX = centerPercentX - rangePercentX / 2;
                if (minPercentX < 0) {
                    minPercentX = 0;
                    maxPercentX = minPercentX + rangePercentX;
                } else {
                    maxPercentX = centerPercentX + rangePercentX / 2;
                    if (maxPercentX > 100) {
                        maxPercentX = 100;
                        minPercentX = maxPercentX - rangePercentX;
                    }
                }
                minPercentY = centerPercentY - rangePercentY / 2;
                if (minPercentY < 0) {
                    minPercentY = 0;
                    maxPercentY = minPercentY + rangePercentY;
                } else {
                    maxPercentY = centerPercentY + rangePercentY / 2;
                    if (maxPercentY > 100) {
                        maxPercentY = 100;
                        minPercentY = maxPercentY - rangePercentY;
                    }
                }

                // Build a new request (limit min/max percent to 0-100)
                this.requestObject.chartRequest.minScenePercentX = minPercentX;
                this.requestObject.chartRequest.maxScenePercentX = maxPercentX;
                this.requestObject.chartRequest.minScenePercentY = minPercentY;
                this.requestObject.chartRequest.maxScenePercentY = maxPercentY;
                this.requestObject.chartRequest.axesAtFullRange = false;
                this.removeChartTiles();
                this.renderSvgBack();
                this.renderRequest(
                    this.requestObject,
                    this.chart,
                    this.uniqueKey
                );
                this.renderSvgFront();
            } else if (this.clickMode === 'select') {
                var clickInteractCallback = function(data) {
                    var clickData = JSON.parse(data);

                    // save the selection info
                    that.selectionInfo = clickData.selectionInfo;

                    // replace the tile info with the refreshed tile (if
                    // highlighting is on)
                    that.updateTileData(clickData);
                    that.clickInteract();
                    that.removeChartTiles();
                    that.renderSvgBack();
                    that.renderChartTiles(that.chart, that.uniqueKey);
                    that.renderSvgFront();
                };

                var clickedTile = this.findClickedTile();
                if (clickedTile == null) {
                    return;
                }
                var requestObject = {
                    clickRequest: {
                        tileId: clickedTile.sceneId,
                        type: 'single',
                        depth: 'all',
                        highlight: true,
                        maxSelectedRows: 5,
                        x: [
                            this.clickCoordinates[0] -
                                clickedTile.left -
                                this.data.sceneOffset[0]
                        ],
                        y: [
                            this.clickCoordinates[1] -
                                clickedTile.top -
                                this.data.sceneOffset[1]
                        ]
                    }
                };
                this.dataProvider.executeSupport(
                    'getClickedObjects',
                    requestObject,
                    clickInteractCallback,
                    this.chart,
                    this.uniqueKey
                );
            } else if (this.clickMode === 'testTileRequest') {
                var tileRequestCallback = function(data) {
                    var tileData = JSON.parse(data).chartTiles;
                    for (var i = 0; i < tileData.length; i++) {
                        var curTile = tileData[i];
                        if (curTile.renderStarted === true) {
                            that.chartTileCollection.push(curTile);
                        }
                    }

                    that.removeChartTiles();
                    that.renderSvgBack();
                    that.renderChartTiles(that.chart, that.uniqueKey);
                    that.renderSvgFront();
                };

                var requestObject = {
                    tileRequest: {
                        tileIds: [
                            this.data.chartTiles[2].id,
                            this.data.chartTiles[3].id
                        ]
                    }
                };
                this.dataProvider.executeSupport(
                    'getChartTiles',
                    requestObject,
                    tileRequestCallback,
                    this.chart,
                    this.uniqueKey
                );
            }
        });

        this.legend = null;
        this.setupClick();
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

    avsDropPrototype.findClickedTile = function() {
        if (this.data.chartTiles == null) {
            return null;
        }
        var xClick = this.clickCoordinates[0] - this.data.sceneOffset[0];
        var yClick = this.clickCoordinates[1] - this.data.sceneOffset[1];

        for (var i = 0; i < this.data.chartTiles.length; i++) {
            var curTile = this.data.chartTiles[i];
            if (curTile.type == 'chartTile') {
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
    avsDropPrototype.removeOverlayDivs = function() {
        var div;
        while ((div = this.overlayDivs.splice(0, 1)[0])) {
            this.removeChild(div);
        }
    };

    /*avsDropPrototype.getOverlayDiv = function(args){
    //FIXME: QW8
    //I think this is old relic code, and that this method should be removed.
    //Overlay divs have been replaced by overlay elements, which are created by
    //anything inheriting from chartElement, I think. (or some other root el.)
    //Args is an object describing the overlay div
    var that = this;

    var height = Math.min(args.height, this.offsetHeight),
        width = Math.min(args.width, this.offsetWidth);

    var shadeDiv;
    if(args.shade === 'true'){
        shadeDiv = document.createElement('div');
        d3.select(shadeDiv).style({
            'background' : '#555',
            'opacity' : 0.5,
            'position' : 'absolute',
            'top' : '0px',
            'bottom' : '0px',
            'left' : '0px',
            'right' : '0px'
        })
        .on('click', function(){
            that.removeOverlayDivs();
        });
    }

    var div = document.createElement('div');
    d3.select(div).style({
        'height' : args.height + 'px',
        'width' : args.width + 'px',
        'background' : '#fff',
        'position' : 'absolute'
    });

    var trueWidth = width,
        trueHeight = height;

    //To match px in border: str.match("[0-9]*px")

    if(typeof args['border-width'] !== 'undefined' || typeof
args['border-color'] !== 'undefined' || typeof args['border-style'] !==
'undefined'){ var borderColor = args['border-color'] || '#777'; var borderWidth
= args['border-width'] || 1; var borderStyle = args['border-style'] || 'solid';
        if(typeof borderWidth === 'string' && borderWidth.includes('px')){
            borderWidth = +borderWidth.substr(0, borderWidth.length - 2)
        } else if(typeof borderWidth === 'string'){
            borderWidth = +borderWidth;
        }

        d3.select(div).style({
            'border-width' : borderWidth + 'px',
            'border-color' : borderColor,
            'border-style' : borderStyle
        });

        trueWidth += borderWidth*2;
        trueHeight += borderWidth*2;
    }

    var x, y;

    //Compute 'x' and 'y' values based on location
    if(args.location === 'top-left'){
    } else if (args.location === 'top'){
    } else if (args.location === 'top-right'){
    } else if (args.location === 'left'){
    } else if (args.location === 'center' || typeof args.location ===
'undefined'){
        //This is the default setting for location.
    } else if (args.location === 'right'){
    } else if (args.location === 'bottom-left'){
    } else if (args.location === 'bottom'){
    } else if (args.location === 'bottom-right'){
    } else if (args.location === 'last-click'){

        x = this.clickCoordinates[0];
        y = this.clickCoordinates[1];

        if(typeof args.alignment !== 'undefined'){
            if(args.alignment.includes('top')){
                y -= trueHeight;
            } else if (!args.alignment.includes('bottom')){
                y -= (trueHeight / 2);
            }

            if(args.alignment.includes('left')){
                x -= trueWidth;
            } else if (!args.alignment.includes('right')){
                x -= (trueWidth / 2);
            }
        }

        if(args.position !== 'absolute'){
            x = Math.min(Math.max(x, 0), this.offsetWidth - trueWidth);
            y = Math.min(Math.max(y, 0), this.offsetHeight - trueHeight);
        }
    }

    d3.select(div).style({
        'left' : x + 'px',
        'top' : y + 'px'
    });

    this.overlayDivs.push(div);

    if(args.shade === 'true'){
        this.overlayDivs.push(shadeDiv);
        this.appendChild(shadeDiv);
    }
    this.appendChild(div);

    return div;
};*/

    avsDropPrototype.clickInteract = function() {
        var that = this;

        this.removeOverlayElements();

        // var overlay = this.getOverlayElement({
        //    'position' : 'last-click',
        //    'height' : 20,
        //    'width' : 110
        //});

        // var contents = document.createElement('span');
        // if(that.data.selectionInfo){
        //  contents.textContent = 'NumRows=' +
        //  that.data.selectionInfo[0].numRowsSelected;
        //}
        // overlay.appendChild(contents);

        var getIcons = function() {
            // This should take URLs for icons.
            return ['icons', 'need', 'work'];
        };

        var overlay = this.getContextMenu({
            title: 'Design',
            items: [
                {
                    title: 'Score',
                    children: [
                        {
                            title: 'Rank: 50',
                            action: function(e) {
                                console.log('clicked rank!');
                                e.stopPropagation();
                                e.preventDefault();
                            },
                            children: [
                                { title: 'subchild' },
                                { title: 'subchild 2' }
                            ]
                        },
                        {
                            title: 'Score 78',
                            action: function() {
                                console.log('clicked score!');
                            }
                        }
                    ]
                },
                {
                    title: function() {
                        if (
                            that.selectionInfo !== null &&
                            that.selectionInfo.length > 0
                        ) {
                            return (
                                'Num Rows = ' +
                                that.selectionInfo[0].numRowsSelected
                            );
                        } else {
                            return 'Num Rows = 0';
                        }
                    }
                },
                { title: 'Icons', icons: getIcons }
            ]
        });

        this.overlayElements.push(overlay);

        /*        if (that.data.renderTiles && that.data.renderTiles.length > 0) {
                that.data = that.data.renderTiles;
                that.removeTiles();
                that.renderTiles();
            }
            */
    };

    avsDropPrototype.renderRequest = function(requestObject, chart, uniqueKey) {
        var that = this;

        var tilesCallback = function(data) {
            that.data = JSON.parse(data);
            that.chartTileCollection = [];
            for (var i = 0; i < that.data.chartTiles.length; i++) {
                var curTile = that.data.chartTiles[i];
                if (curTile.renderStarted === true) {
                    that.chartTileCollection.push(curTile);
                }
            }
            that.renderSvgBack();
            that.renderChartTiles(chart, uniqueKey);
            that.renderSvgFront();
            that.renderLegendTiles(chart, uniqueKey);

            // Output statistics data to console for now
            if (
                typeof that.data.statistics === 'undefined' ||
                that.data.statistics === null
            ) {
                return;
            }
            console.log('Statistics Data');
            for (var i = 0; i < that.data.statistics.length; i++) {
                console.log('Chart[' + i + ']');
                var curChartStats = that.data.statistics[i];
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
        };

        // Test for pan/zoom
        /*        if (typeof requestObject.chartRequest.minScenePercentX ===
     'undefined') { requestObject.chartRequest.minScenePercentX = 25;
                requestObject.chartRequest.maxScenePercentX = 75;
                requestObject.chartRequest.minScenePercentY = 25;
                requestObject.chartRequest.maxScenePercentY = 75;
                requestObject.chartRequest.axesAtFullRange = false;
     //           requestObject.chartRequest.sceneOutput = 'chartsOnly';
            }
    */
        // Save chart object for subsequent click requests
        this.chart = chart;
        this.uniqueKey = uniqueKey;
        this.requestObject = requestObject;

        this.dataProvider.executeSupport(
            'renderAVSChart',
            requestObject,
            tilesCallback,
            chart,
            uniqueKey
        );
    };

    avsDropPrototype.renderSvgBack = function() {
        var that = this;
        if (typeof this.data.svgBack === 'undefined') {
            return;
        }


        this.appendSVGFromString(this.data.svgBack, this.svgs.root);                       
                                
    };

    avsDropPrototype.renderSvgFront = function() {
        var that = this;
        if (typeof this.data.svgFront === 'undefined') {
            return;
        }
              
        
        this.appendSVGFromString(this.data.svgFront, this.svgs.root);
            
    };

    avsDropPrototype.appendSVGFromString = function(
        svgData,
        parentSVG
    ) {
        var svgDataString =
            '<svg xmlns="http://www.w3.org/2000/svg">' + svgData + '</svg>';
        var parser = new DOMParser();
        var svgFromResponse = parser.parseFromString(
            svgDataString,
            'image/svg+xml'
        );
       
        var firstElementChild = svgFromResponse.firstElementChild || svgFromResponse.firstChild;
        
        // add all the children from the response
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
        
    };

    avsDropPrototype.renderLegendTiles = function(chart, uniqueKey) {
        var that = this;
        if (this.legend === null) {
            return;
        }

        var that = this;

        var legendTiles = d3.
            select(this.legend.querySelector('.images')).
            selectAll('.tile').
            data(this.data.legendTiles, function(d) {
                return d.id;
            });

        legendTiles.exit().remove();

        legendTiles.
            enter().
            append('img').
            classed('tile', true).
            attr('width', function(d) {
                return d.width;
            }).
            attr('height', function(d) {
                return d.height;
            }).
            style('position', 'absolute').
            style('left', function(d) {
                return d.left;
            }).
            style('top', function(d) {
                return d.top;
            }).
            each(function(d) {
                var tile = this;

                var callback = function(url) {
                    d3.select(tile).attr('src', url);
                };

                var callback2 = function(json) {
                    console.log(json);
                };

                that.dataProvider.getResourceAsUrl(
                    'renderAVSChart',
                    d.id,
                    callback,
                    chart,
                    uniqueKey
                );
            });
    };

    avsDropPrototype.renderChartTiles = function(chart, uniqueKey) {
        var that = this;

        var sceneOffset = this.data.sceneOffset;

        d3.
            select(this.svgs.root).
            append('g').
            attr('transform', function(d) {
                return (
                    'translate(' + sceneOffset[0] + ',' + sceneOffset[1] + ')'
                );
            }).
            selectAll('.tile').
            data(this.chartTileCollection).
            enter().
            append('image').
            attr('x', function(d) {
                return d.left;
            }).
            attr('y', function(d) {
                return d.top;
            }).
            attr('width', function(d) {
                return d.width;
            }).
            attr('height', function(d) {
                return d.height;
            }).
            attr('class', function(d) {
                return d.type;
            }).
            each(function(d) {
                var tile = this;

                var callback = function(url) {
                    d3.select(tile).attr('xlink:href', url);
                    try {
                        that.parentElement.parentElement.parentElement.hideDropZones();
                    } catch (e) {
                        // ignore and do nothing
                    }
                };

                var callback2 = function(json) {
                    console.log(json);
                };

                that.dataProvider.getResourceAsUrl(
                    'renderAVSChart',
                    d.id,
                    callback,
                    chart,
                    uniqueKey
                );
            });
    };

    avsDropPrototype.removeChartTiles = function() {
        while (this.svgs.root.firstChild) {
            this.svgs.root.removeChild(this.svgs.root.firstChild);
        }
    };

    avsDropPrototype.removeLegendTiles = function() {
        if (typeof legend === 'undefined' || legend === null) {
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
