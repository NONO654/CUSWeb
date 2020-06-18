(function(GLOBAL, template) {
    var chartElementPrototype = {
        is: 'ra-avschartelement',
        behaviors: [GLOBAL.DS.RAComponents.chart]
    };

    avsDropPrototype.setDataProvider = function(dataProvider) {
        this.dataProvider = dataProvider;
    };

    avsDropPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.chart.createdCallback.call(this);
        var that = this;

        // Set default dimensions
        this.dimensions = { width: 100, height: 100 };

        // Append template (contains an svg)
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.svgs = { root: this.querySelector('svg') };

        this.legend = null;
    };
    // SD4: 8/16/2017 - this seems unused
    //  avsDropPrototype.addDefaultClickHandler = function(){
    //      //Copied from AVS code, originally in the created callback.
    //      var that = this;
    //
    //      this.addClickHandler(function(e){
    //
    //            var clickInteractCallback = function(data){
    //               that.data =  JSON.parse(data);
    //               that.clickInteract();
    //          };
    //            var gridContainer = document.querySelector('ra-gridcontainer');
    //            var keyPressed = gridContainer.getKeyPress();
    //          var requestObject =
    //          {'clickRequest':{'type':'single','depth':'all','highlight':true,'maxSelectedRows':5,
    //                                 'x':[this.clickCoordinates[0]],'y':[this.clickCoordinates[1]],
    //                                 keyCtrl: keyPressed.ctrl, keyAlt:
    //                                 keyPressed.alt, keyShift: keyPressed.shift}};
    //          this.dataProvider.executeSupport('getClickedObjects', requestObject,
    //          clickInteractCallback);
    //        });
    //
    //      this.setupClick();
    //  };

    avsDropPrototype.setTotalHeight = function(totalHeight) {
        this.dimensions.plotHeight = totalHeight;
        d3.select(this.svgs.root).style('height', totalHeight + 'px');
    };

    avsDropPrototype.setTotalWidth = function(totalWidth) {
        this.dimensions.plotWidth = totalWidth;
        d3.select(this.svgs.root).style('width', totalWidth + 'px');
    };

    avsDropPrototype.setLegend = function(legend) {
        this.legend = legend;
    };

    avsDropPrototype.renderRequest = function(requestObject) {
        var that = this;

        var tilesCallback = function(data) {
            that.data = JSON.parse(data);
            that.renderChartTiles();
            that.renderLegendTiles();
        };

        this.dataProvider.executeSupport(
            'renderAVSChart',
            requestObject,
            tilesCallback
        );
    };

    avsDropPrototype.renderLegendTiles = function() {
        var that = this;
        if (this.legend === null) {
            return;
        }

        var that = this;

        d3.
            select(this.legend.querySelector('.images')).
            selectAll('.tile').
            data(this.data.legendTiles).
            enter().
            append('img').
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

                that.dataProvider.getResourceAsUrl(
                    'renderAVSChart',
                    d.id,
                    callback
                );
            });
    };

    avsDropPrototype.renderChartTiles = function() {
        var that = this;

        d3.
            select(this.svgs.root).
            selectAll('.tile').
            data(this.data.chartTiles).
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
                    var im = new Image();
                    im.src = url;
                    im.onload = (function(tile, url) {
                        d3.select(tile).attr('xlink:href', url);
                    })(tile, url);
                    im.onerror = (function(tile) {
                        // set it to blank tile
                        d3.select(tile).attr('xlink:href', null);
                    })(tile);
                };

                var callback2 = function(json) {
                    console.log(json);
                };

                that.dataProvider.getResourceAsUrl(
                    'renderAVSChart',
                    d.id,
                    callback
                );
            });
    };

    avsDropPrototype.removeTiles = function() {
        //     d3.selectAll('image').remove();
        while (this.svgs.root.firstChild) {
            this.svgs.root.removeChild(this.svgs.root.firstChild);
        }
    };

    Polymer(avsDropPrototype);
    GLOBAL.DS.RAComponents.avschartelement = avsDropPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
