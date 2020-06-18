(function(GLOBAL, template) {
    var avsTestPrototype = {
        is: 'ra-avstestchart',
        behaviors: [GLOBAL.DS.RAComponents.chart]
    };

    avsTestPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.chart.createdCallback.call(this);

        this.dimensions = { width: 100, height: 100 };

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);

        this.svgs = { root: this.querySelector('svg') };

        this.images = { root: this.querySelector('div') };

        this.maps = { root: this.querySelector('div') };

        this.addClickHandler(function(args) {
            var that = this;

            var clickInteractCallback = function(data) {
                that.data = JSON.parse(data);
                that.clickInteract();
            };
            var gridContainer = document.querySelector('ra-gridcontainer');
            var keyPressed = gridContainer.getKeyPress();
            var requestObject = {
                clickRequest: {
                    type: 'single',
                    depth: 'all',
                    highlight: true,
                    maxSelectedRows: 5,
                    x: [this.clickCoordinates[0]],
                    y: [this.clickCoordinates[1]],
                    keyCtrl: keyPressed.ctrl,
                    keyAlt: keyPressed.alt,
                    keyShift: keyPressed.shift
                }
            };
            this.dataProvider.executeSupport(
                'getClickedObjects',
                requestObject,
                clickInteractCallback
            );
        });

        this.setupClick();
    };

    avsTestPrototype.clickInteract = function() {
        var that = this;

        this.removeOverlayDivs();

        var overlay = this.getOverlayDiv({
            location: 'last-click',
            height: 20,
            width: 110,
            border: '2px solid',
            'border-width': '2px',
            'border-color': 'blue'
        });

        var contents = document.createElement('span');
        contents.textContent =
            'NumRows=' + that.data.selectionInfo[0].numRowsSelected;
        overlay.appendChild(contents);

        if (that.data.renderTiles.length > 0) {
            that.data = that.data.renderTiles;
            that.renderTiles();
        }
    };

    avsTestPrototype.attachedCallback = function() {
        this.dimensions.width = Math.floor(this.offsetWidth / 2) * 2;
        this.dimensions.height = this.dimensions.width;

        d3.
            select(this.svgs.root).
            style('height', this.dimensions.height + 'px');
        d3.select(this.svgs.root).style('width', this.dimensions.width + 'px');

        this.render();
    };

    avsTestPrototype.render = function() {
        var that = this;
        var cellWidth = this.dimensions.width / 2,
            cellHeight = this.dimensions.height / 2;

        var requestObject = {
            chartRequest: {
                width: 349,
                height: 370,
                data: {
                    raw: [
                        { guid: '8fe2a8f7-35d5-4e87-9b1d-13641d63cc7a' },
                        { guid: 'f86ce75e-efe1-4556-b51a-8c2a7fefa29e' },
                        { guid: 'dff2c691-2212-4212-8df4-9c30cbb695d0' },
                        { guid: '26f8583f-0ba7-4e0e-9b34-ee661a04143e' },
                        { guid: '8e5707be-6f82-4d1c-8c76-c0398deb4780' },
                        { guid: 'ba3e896c-0792-4596-b1ac-8c269302481b' }
                    ],
                    preFilter: [
                        {
                            guid: 'prefilterX',
                            type: 'threshold',
                            input: {
                                guid: 'f86ce75e-efe1-4556-b51a-8c2a7fefa29e'
                            },
                            min: '-320',
                            max: '3000'
                        }
                        //                                    {"guid":"prefilterY",
                        //                                    "type":"threshold",
                        //                                     "input":{"guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"},
                        //                                     "min":"-10","max":"15"},
                        //                                    {"guid":"prefilterString",
                        //                                    "type":"discrete",
                        //                                     "input":{"guid":"8fe2a8f7-35d5-4e87-9b1d-13641d63cc7a"},
                        //                                     "inclusionList":["ALCast","CFRTM"]},
                        //                                    {"guid":"prefilterBoolean",
                        //                                    "type":"boolean",
                        //                                     "input":{"guid":"BooleanTest"},
                        //                                     "filterValue":"NONE"}
                    ]
                },
                legend: { width: 640, height: 60, orientation: 'horizontal' },
                charts: [
                    /*     {
                         "type":"scatter",
                         "guid":"2D Scatter",

                         "x":{"data":{"type":"raw",
                   "guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                         "y":{"data":{"type":"raw",
                   "guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
                         "color":{"type":"byData", "data":{"type":"raw",
                   "guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                         "constraints":[{"type":"EQUAL_TO", "guid":"Vertical",
                   "onTop":true} ]
                     } */
                    /*    {
                        "type":"scatter",
                        "guid":"2D Bubble Chart",

                        "x":{"data":{"type":"raw",
                   "guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                        "y":{"data":{"type":"raw",
                   "guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
                        "color":{"type":"byData", "data":{"type":"raw",
                   "guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                        "size":{"data":{"type":"raw","guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"},
                   "scale":"3.0"}, "shape":{"type":"circle"},
                    } */
                    /*   {
                       "type":"scatter",
                       "guid":"Line Chart - regular",

                       "x":{"data":{"type":"raw",
"guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}}, "y":{"data":{"type":"raw",
"guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
//                        "color":{"type":"fixed", "defaultColor":"#c74646"}},
                       "size":{"scale":"4.0"},
                       "shape":{"type":"circle"},
                       "lineOn":true
                   } */
                    /*   {
                       "type":"line",
                       "guid":"Line Chart - Array 1D vs indices",
                       "orientation":"horizontal",

                       // Binned X data with glyph color/size
                       "x":{"data":{"type":"binnedEqualWidth","numBins":10,"guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                       "y":{"series":[{"type":"aggregation","aggregationType":"COUNT","guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}],
                           "axisProperties":{"axle":{"color":"#c74646"},
                                             "minorTickMarks":{"visible":false},
                                             "majorTickMarks":{"visible":false},
                                             "majorTickLines":{"style":"dot",
                   "visible":true}}}, "color":{"type":"byData",
                   "data":{"type":"aggregation","aggregationType":"COUNT","guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}}
                   }  */
                    /*  {
                      "type":"line",
                      "guid":"Line Chart - Area",

                      // Binned X data with glyph color/size
                      "x":{"data":{"type":"binnedEqualWidth","numBins":10,"guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                      "y":{"series":[{"type":"aggregation","aggregationType":"COUNT","guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}]},
                      "color":{"type":"byData",
                  "data":{"type":"aggregation","aggregationType":"COUNT","guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                      "areaOn":true,
                      "symbolsOn":false
                  } */
                    /*    {
                         "type":"scatter",
                         "x":{"data":{"type":"binnedEqualWidth","numBins":10,"guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"},"visible":true},
                         "y":{"data":{"type":"binnedDiscrete","guid":"8fe2a8f7-35d5-4e87-9b1d-13641d63cc7a","isUnique":true},"visible":true},
                         "color":{"type":"byData",
 "data":{"type":"aggregation","aggregationType":"MEAN","guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
 //
 "size":{"data":{"type":"aggregation","aggregationType":"MEAN","guid":"8fe2a8f7-35d5-4e87-9b1d-13641d63cc7a"}},
                         "constraints":[{"type":"LESS_THAN",
 "guid":"Vertical-f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}]
                     } */
                    {
                        type: 'bar',
                        guid: 'Histogram (frequency)',
                        orientation: 'horizontal',
                        layout: 'clustered',

                        // Binned X data
                        x: {
                            data: {
                                type: 'binnedEqualWidth',
                                numBins: 10,
                                guid: 'f86ce75e-efe1-4556-b51a-8c2a7fefa29e'
                            }
                        },
                        y: {
                            series: [
                                {
                                    type: 'aggregation',
                                    aggregationType: 'MINIMUM',
                                    guid: 'dff2c691-2212-4212-8df4-9c30cbb695d0'
                                },
                                {
                                    type: 'aggregation',
                                    aggregationType: 'MAXIMUM',
                                    guid: 'dff2c691-2212-4212-8df4-9c30cbb695d0'
                                }
                            ],
                            axisProperties: {
                                axle: { color: '#c74646' },
                                minorTickMarks: { visible: false },
                                majorTickMarks: { visible: false },
                                majorTickLines: { style: 'dot', visible: true }
                            }
                        },
                        //                        "color":{"type":"byData",
                        //                        "data":{"type":"aggregation","aggregationType":"COUNT","guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
                        color: { type: 'bySeries' },
                        bordersOn: true,
                        barWidth: '0.5',
                        barStartValue: 2.0,
                        constraints: [
                            { type: 'GREATER_THAN', guid: 'Vertical' }
                        ]
                    }
                    /*   {
                      "type":"bar",
                      "guid":"Paretto",

                      // Binned X data
                      "x":{"data":{"type":"binnedDiscrete","guid":"8fe2a8f7-35d5-4e87-9b1d-13641d63cc7a"},"visible":false},
                      "y":{"series":[{"type":"aggregation","aggregationType":"SUM","guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}]},
                      "bordersOn":true,
                      "barWidth":"0.9",
                      "layout":"paretto"
                   } */
                    /*   {
                      "type":"bar",
                      "guid":"Cumulative",

                      // Binned X data
                      "x":{"data":{"type":"binnedEqualWidth","numBins":10,"guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                      "y":{"series":[{"type":"aggregation","aggregationType":"COUNT","guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}]},
                      "bordersOn":true,
                      "barWidth":"0.9",
                      "layout":"cumulative"
                   } */
                    /*      {
                         "type":"scatter",
                         "guid":"Paretto",

                         // Binned X data
                         "x":{"data":{"type":"binnedDiscrete","guid":"8fe2a8f7-35d5-4e87-9b1d-13641d63cc7a"}},
                         "y":{"data":{"type":"raw","guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}}
                      } */
                    //                    {
                    //                        "type":"scatter",
                    //
                    //                        // Raw Data Case (Random scatter
                    //                        background) "x":{"data":{"type":"raw",
                    //                        "guid":"26f8583f-0ba7-4e0e-9b34-ee661a04143e"},"visible":true},
                    //                        "y":{"data":{"type":"raw",
                    //                        "guid":"ba3e896c-0792-4596-b1ac-8c269302481b"},"visible":true},
                    //                        "color":{"type":"byData",
                    //                        "data":{"type":"raw",
                    //                        "guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
                    //                        "size":{"data":{"type":"raw",
                    //                        "guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}}
                    //                    },
                    //                    {
                    //                        "type":"scatter",
                    //
                    //                        // Discrete X data vs binned Y data
                    //                        with glyph color/size
                    //                        "x":{"data":{"type":"binnedDiscrete","guid":"8fe2a8f7-35d5-4e87-9b1d-13641d63cc7a"},"visible":true},
                    //                        "y":{"data":{"type":"binnedEqualWidth","numBins":10,"guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"},"visible":true},
                    //                        "color":{"type":"byData",
                    //                        "data":{"type":"aggregation","aggregationType":"MEAN","guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                    //                        "size":{"data":{"type":"aggregation","aggregationType":"MEAN","guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
                    //                        "constraints":[{"type":"GREATER_THAN",
                    //                        "guid":"Horizontal"}]
                    //                    }
                    /* {
                     "type":"scatter",
                     "guid":"XYBinnedScatter1",

                     // Binned XY data with glyph color/size
                     "x":{"data":{"type":"binnedEqualWidth","numBins":10,"startValue":0.0,"endValue":1000.0,"guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                     "y":{"data":{"type":"binnedEqualWidth","numBins":10,"startValue":0.0,"endValue":10.0,"guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
                     "color":{"type":"byData",
"data":{"type":"aggregation","aggregationType":"MEAN","guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                     "size":{"data":{"type":"aggregation","aggregationType":"MEAN","guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
                     "constraints":[{"type":"LESS_THAN", "guid":"Vertical"}]
//                        "constraints":[{"type":"GREATER_THAN",
"guid":"Horizontal"}]
//
//                        // Post filtering on color aggregate (in future will
be handled through color map)
//
"postFilter":[{"guid":"postfilterX","type":"threshold","input":{"guid":"color"},"min":"-320","max":"1250"}]
                 } */
                    //                  // Other single chart examples
                    /*   {
                       "type":"scatter",
                       "guid":"RawScatter1",
                       "orientation":"vertical",

                      // Raw Data Case Max Range vs. Endurance
                       "x":{"data":{"type":"raw",
"guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}}, "y":{"data":{"type":"raw",
"guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
//                        "z":{"data":{"type":"raw",
"guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}}, "color":{"type":"byData",
"data":{"type":"raw", "guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                       "size":{"data":{"type":"raw",
"guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
//                        "shape":{"data":{"type":"raw",
"guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
                       "constraints":[{"type":"GREATER_THAN",
"guid":"Vertical"}]
//                        "constraints":[{"type":"GREATER_THAN",
"guid":"Horizontal"}]
//                        "constraints":[{"type":"LESS_THAN",
"guid":"Island","onTop":false,"gridOn":true}]
                   } */
                    /*                    {
                                        "type":"scatter",
                                        "guid":"XRawYBinnedScatter1",

                                        // Raw Data Case Max Range vs. Endurance
                (binned) "x":{"data":{"type":"raw",
                "guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                                        "y":{"data":{"type":"binnedEqualWidth","numBins":10,"guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"},"visible":true},
                                        "color":{"type":"byData",
                "data":{"type":"raw",
                "guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                                        "size":{"data":{"type":"raw",
                "guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
                                        "constraints":[{"type":"GREATER_THAN",
                "guid":"Vertical"}]
                //                        "constraints":[{"type":"GREATER_THAN",
                "guid":"Horizontal"}]
                //                        "constraints":[{"type":"LESS_THAN",
                "guid":"Island","onTop":false,"gridOn":true}]
                                    } */
                    //                    {
                    //                        "type":"scatter",
                    //
                    //                        // Raw Data Case Max Range vs.
                    //                        Endurance w/ binned color map
                    //                        "x":{"data":{"type":"raw",
                    //                        "guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                    //                        "y":{"data":{"type":"raw",
                    //                        "guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
                    //                        "color":{"type":"byData",
                    //                        "data":{"type":"binnedEqualWidth","numBins":10,
                    //                        "guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                    //                        "size":{"data":{"type":"raw",
                    //                        "guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}}
                    //                    }
                    //                    {
                    //                        "type":"scatter",
                    //
                    //                        // Binned XY data with glyph color
                    //                        (binned) + size
                    //                        "x":{"data":{"type":"binnedEqualWidth","numBins":10,"guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                    //                        "y":{"data":{"type":"binnedEqualWidth","numBins":10,"guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
                    //                        "color":{"type":"byData",
                    //                        "data":{"type":"binnedEqualWidth","numBins":10,"guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                    //                        "size":{"data":{"type":"aggregation","aggregationType":"COUNT","guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}}
                    //                        "shape":{"data":{"type":"aggregation","aggregationType":"COUNT","guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}}
                    //                    }
                    //                    {
                    //                        "type":"scatter",
                    //
                    //                        // Raw Data Case Max Range vs.
                    //                        Endurance (binned axis map for Y)
                    //                        "x":{"data":{"type":"raw",
                    //                        "guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                    //                        "y":{"data":{"type":"binnedEqualWidth","numBins":10,"guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}},
                    //                        "color":{"type":"byData",
                    //                        "data":{"type":"raw",
                    //                        "guid":"f86ce75e-efe1-4556-b51a-8c2a7fefa29e"}},
                    //                        "size":{"data":{"type":"raw",
                    //                        "guid":"dff2c691-2212-4212-8df4-9c30cbb695d0"}}
                    //                    }
                ]
            }
        };

        var tilesCallback = function(data) {
            that.data = JSON.parse(data);
            that.renderTiles();
        };

        this.dataProvider.executeSupport(
            'renderAVSChart',
            requestObject,
            tilesCallback
        );
    };

    avsTestPrototype.renderTiles = function() {
        var that = this;
        /*
    d3.select(this.maps.root).selectAll('.tile')
        .data(this.data)
        .enter()
        .append('map')
        .attr('name', function(d){
            return d.id + '-map';
        })
        .each(function(d){
            var tile = this;

            var callback = function(map){
                d3.select(tile).attr('area', map);
            };

            var callback2 = function(json){
                console.log(json);
            }

            that.dataProvider.getResourceAsUrl('renderAVSChart', d.id+'-map',
    callback);
        });
        */
        /*      d3.select(this.images.root).selectAll('.tile')
                .data(this.data)
                .enter()
                .append('img')
                .attr('width', function(d){
                    return d.width;
                })
                .attr('height', function(d){
                    return d.height;
                })
                .style('position', 'absolute')
                .style('left', function(d){
                    return d.left;
                })
                .style('top', function(d){
                    return d.top;
                })
                .attr('usemap', function(d){
                    return d.id + '-map';
                })
                .each(function(d){
                    var tile = this;

                    var callback = function(url){
                        d3.select(tile).attr('src', url);
                    };

                    var callback2 = function(json){
                        console.log(json);
                    }

                    that.dataProvider.getResourceAsUrl('renderAVSChart', d.id,
       callback);
                });
     */
        d3.
            select(this.svgs.root).
            selectAll('.tile').
            data(this.data).
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
            each(function(d) {
                var tile = this;

                var callback = function(url) {
                    d3.select(tile).attr('xlink:href', url);
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

    Polymer(avsTestPrototype);
    GLOBAL.DS.RAComponents.avsTestChart = avsTestPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
