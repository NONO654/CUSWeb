(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.avslinechart !== 'undefined') {
        return;
    }
    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;

    var avsChartPrototype = {
        is: 'ra-avslinechart',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.createdCallback.call(this);

        this.divs.root.removeChild(this.divs.sizeDropZone);
        this.divs.root.removeChild(this.divs.labelDropZone);

        this.addYLineAxis();
        // this.addColorLineDropZone();

        this.makeZoomable({maxZoom:1});
    };
    avsChartPrototype.initialize = function(configuration) {
        GLOBAL.DS.RAComponents.avsdropchartbase.initialize.call(
            this,
            configuration
        );
        if (configuration) {
        } else {
            //this.parameters.yline = [];
            this.parameters.colorline = null;
        }
    };
    

    //  avsChartPrototype.addColorLineDropZone = function(){
    //      var that = this;
    //      //The main chart will be contianed in an ra-droptarget element to handle
    //      drops
    //      //TODO: This should be generalized onto a more specific drop target for
    //      chart drop
    //      //zones, probably.
    //      this.divs.colorLineDropZone =
    //      document.createElement('ra-chartdroptarget');
    //      this.divs.colorLineDropZone.classList.add('avsDropChart-colorLineDropZone');
    //      this.divs.colorLineDropZone.setDragEnterListener(this.divs.colorLineDropZone.showPlaceholder);
    //      this.divs.colorLineDropZone.setDragLeaveListener(this.divs.colorLineDropZone.hidePlaceholder);
    //      this.divs.colorLineDropZone.setParameterListener(this.divs.setColorLineParameter);
    //      this.divs.colorLineDropZone.showPlaceholder();
    //      this.divs.colorLineDropZone.setPlaceholderFilter(this.placeholderFilter.bind(this));
    //
    //      this.divs.colorLineDropZone.setPlaceholderText(function(){
    //          if(typeof that.parameters.colorline !== 'undefined' &&
    //          that.parameters.colorline !== null){
    //              return '' + that.parameters.colorline.name;
    //          } else {
    //              return 'Color Line';
    //          }
    //      });
    //
    //      //Add parameter handler
    //      var paramHandler = document.createElement('ra-drophandler');
    //      paramHandler.setFilter(this.validateColorLineData);
    //      paramHandler.setDropListener(function(param){
    //          console.log('Added color line parameter: ' + param.id);
    //          that.setColorLineParameter(param.properties);
    //          that.controls.colorLineControl.updateController([that.parameters.colorline]);
    //          that.renderChart();
    //      });
    //
    //      this.divs.colorLineDropZone.appendChild(paramHandler);
    //
    //      this.divs.root.appendChild(this.divs.colorLineDropZone);
    //  };



    avsChartPrototype.validateColorLineData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        // and not discrete
        if (data.properties.dataType === 'STRING') {
            console.log('color line parameter cannot be discrete');
            return false;
        }
        return true;
    };

    

    //  avsChartPrototype.setColorLineParameter = function(parameter){
    //      var that = this;
    //      that.parameters.colorline = parameter;
    //        that.divs.colorLineDropZone.updatePlaceholder();
    //  };

    avsChartPrototype.validateRender = function() {
        if (this.parameters.x !== null) {
            return true;
        }
        return false;
    };

    avsChartPrototype.preRender = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.preRender.call(this);

        this.divs.yAxisLineDropZone.hidePlaceholder();
        //      this.divs.colorLineDropZone.hidePlaceholder();
    };

    avsChartPrototype.validateYData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        // and not discrete
        if (data.properties.dataType === 'STRING') {
            console.log('y parameter cannot be discrete');
            return false;
        }
        return true;
    };

    avsChartPrototype.validateColorData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }
        // and not discrete
        if (data.properties.dataType === 'STRING') {
            console.log('color parameter cannot be discrete');
            return false;
        }
        return true;
    };

    avsChartPrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.avsdropchartbase.renderControlPanel.call(
            this,
            panel
        );

        // Modify param panels
        this.controls.yControl.nParameters(10);
        this.controls.yControl.setShowAxisFilter(true);
        this.controls.yControl.setShowParamFilter(false);
    };

    avsChartPrototype.updateRequest = function() {
        var that = this;

        this.requestObject.chartRequest.charts[0] = that.controls.chartPropertiesControl.getRequest();
        this.requestObject.chartRequest.charts[0].guid = 'line1';

        //        if (this.parameters.yline.length == 0) {
        //            this.requestObject.chartRequest.charts.splice(1,1);
        //            return;
        //        }
        //        else if (this.requestObject.chartRequest.charts.length == 1) {
        //          this.requestObject.chartRequest.charts.push(that.controls.lineChartPropertiesControl.getRequest());
        //        }

        var dataParams = { raw: [{ guid: this.parameters.x.id }] };
        var dataMaps = { colorMaps: [] };
        var legends = null;

        // Populate x parameter
        if (this.parameters.x.dataType === 'STRING') {
            this.requestObject.chartRequest.charts[0].x = {
                data: { type: 'binnedDiscrete', guid: this.parameters.x.id }
            };
            this.requestObject.chartRequest.charts[0].x.data.discreteValues = that.controls.xControl.getDiscreteValues();
        } else {
            this.requestObject.chartRequest.charts[0].x = {
                data: {
                    type: 'binnedEqualWidth',
                    numBins: 10,
                    guid: this.parameters.x.id
                }
            };
            this.requestObject.chartRequest.charts[0].x.data.minFilterPercent = that.controls.xControl.getLinearMinValue();
            this.requestObject.chartRequest.charts[0].x.data.maxFilterPercent = that.controls.xControl.getLinearMaxValue();
        }
        this.addRawParam(this.parameters.x, dataParams.raw);
        this.requestObject.chartRequest.charts[0].x.axisProperties = that.controls.xControl.getAxisProperties();

        if (this.parameters.x.dataType !== 'STRING') {
            this.requestObject.chartRequest.charts[0].x.axisProperties.style =
                'numeric';
        }

        // Populate y parameter
        var yLabelOverride = null;
        if (this.parameters.y.length > 0) {
            this.requestObject.chartRequest.charts[0].y = { series: [] };
            for (var i = 0; i < this.parameters.y.length; i++) {
                var ySeries = {
                    type: 'aggregation',
                    guid: this.parameters.y[i].id
                };
                ySeries.aggregationType = that.controls.yControl.getAggregationType(
                    i
                );
                this.requestObject.chartRequest.charts[0].y.series.push(
                    ySeries
                );

                this.addRawParam(this.parameters.y[i], dataParams.raw);
            }
        } else {
            this.requestObject.chartRequest.charts[0].y = {
                series: [
                    {
                        type: 'aggregation',
                        aggregationType: 'COUNT',
                        guid: this.parameters.x.id
                    }
                ]
            };
            if (that.controls.yControl.isUserDefinedAxisTitleText() === false) {
                yLabelOverride = this.parameters.x.displayName + ' (COUNT)';
            }
        }
        this.requestObject.chartRequest.charts[0].y.minFilterPercent = that.controls.yControl.getAxisMinValue();
        this.requestObject.chartRequest.charts[0].y.maxFilterPercent = that.controls.yControl.getAxisMaxValue();
        this.requestObject.chartRequest.charts[0].y.axisProperties = that.controls.yControl.getAxisProperties();
        if (yLabelOverride != null) {
            this.updateAxisLabel(
                this.requestObject.chartRequest.charts[0].y,
                yLabelOverride
            );
        }

        // Populate color parameter
        var type = that.controls.colorControl.getType();
        if (type === 'byData') {
            this.requestObject.chartRequest.charts[0].color = {
                type: 'byData',
                data: { guid: this.parameters.color.id }
            };
            if (this.parameters.color.dataType === 'STRING') {
                this.requestObject.chartRequest.charts[0].color.data.type =
                    'binnedDiscrete';
                this.requestObject.chartRequest.charts[0].color.data.discreteValues = that.controls.colorControl.getDiscreteValues();
            } else {
                this.requestObject.chartRequest.charts[0].color.data.type =
                    'aggregation';
                this.requestObject.chartRequest.charts[0].color.data.aggregationType = that.controls.colorControl.getAggregationType();
                this.requestObject.chartRequest.charts[0].color.data.minFilterPercent = that.controls.colorControl.getLinearMinValue();
                this.requestObject.chartRequest.charts[0].color.data.maxFilterPercent = that.controls.colorControl.getLinearMaxValue();
            }
            var colorMap = that.controls.colorControl.getDataMap();
            this.requestObject.chartRequest.charts[0].color.dataMap =
                colorMap.guid;
            this.addDataMap(colorMap, dataMaps.colorMaps);

            this.addRawParam(this.parameters.color, dataParams.raw);

            var colorLegend = {
                guid: 'colorLegend1',
                type: 'color',
                chartGuid: this.requestObject.chartRequest.charts[0].guid,
                width: 300,
                height: 100
            };
            if (legends === null) {
                legends = [];
            }
            legends.push(colorLegend);
        } else {
            // sd4: We are NOT allowed to do 'fixed' color when there are more than
            // one y
            if (this.parameters.y.length === 1) {
                type = 'fixed';
                this.requestObject.chartRequest.charts[0].color.defaultColor = that.controls.colorControl.getFixedColor();
            } else if (this.parameters.y.length > 1) {
                // Get colormaps from example library
                // This should come from parameter <---> color map
                // TODO: fire event to change parameter color in the parameters tree
                // TODO: I think the colorMAp needs just the colors for the
                // parameters and in the same order  We will have to create this
                // datamap on the fly - I guess
                var colorMap = GLOBAL.DS.RAObjects.dataMaps.seriesParametersColorMap;
                type = 'bySeries';
                this.requestObject.chartRequest.charts[0].color.dataMap =
                    colorMap.guid;
                this.addDataMap(colorMap, dataMaps.colorMaps);
                // sd4: maybe I dont need the legend since the parameters panel will
                // be updated to reflect the colors??
                /* var colorLegend = {"guid":"colorLegend1","type":"color",
             "chartGuid":this.requestObject.chartRequest.charts[0].guid,"width":300,
             "height":100}; if (legends === null) { legends = [];
             }
             legends.push(colorLegend);*/
            }

            this.requestObject.chartRequest.charts[0].color.type = type;
        }

        // Srikanth: There can be more than one constraint added to a chart
        if (
            this.parameters.constraints != null &&
            this.parameters.constraints.length > 0
        ) {
            this.requestObject.chartRequest.charts[0].constraints = [];
            var allC = this.requestObject.chartRequest.charts[0].constraints;
            this.parameters.constraints.forEach(function(c) {
                var constraintRequest = {
                    type: c.properties.type,
                    parameterId: c.properties.parameterID[0],
                    guid: c.id,
                    surface: {
                        opacity: 1.0,
                        color: DS.RAObjects.dataMaps.constraint.color
                    },
                    line: {
                        visible: true,
                        color: DS.RAObjects.dataMaps.constraint.line.color,
                        width: DS.RAObjects.dataMaps.constraint.line.width,
                        style:
                            DS.RAObjects.dataMaps.constraint.line.style ||
                            'solid'
                    }
                };
                allC.push(constraintRequest);
            });
        } else {
            if (this.chartProperties.defaults[0].constraints != null) {
                // TODO get the latest state from the ui panel
                this.requestObject.chartRequest.charts[0].constraints = this.chartProperties.defaults[0].constraints;
                //               var constraintRequest = {"type":"GREATER_THAN",
                //               "guid": "MaxRange < 200"};
                //               this.requestObject.chartRequest.charts[0].constraints[0]
                //               = constraintRequest;
            }
        }

        this.requestObject.chartRequest.data = dataParams;
        this.requestObject.chartRequest.dataMaps = dataMaps;
        this.requestObject.chartRequest.legends = legends;

        this.updateRequestSecondaryLine(dataParams, dataMaps, legends);
    };
    avsChartPrototype.updateRequestSecondaryLine = function(
        dataParams,
        dataMaps,
        legends
    ) {
        var that = this;

        if (this.parameters.yline.length == 0) {
            this.requestObject.chartRequest.charts.splice(1, 1);
            return;
        } else if (this.requestObject.chartRequest.charts.length == 1) {
            this.requestObject.chartRequest.charts.push(
                that.controls.lineChartPropertiesControl.getRequest()
            );
        }

        //          var dataParams = this.requestObject.chartRequest.data;
        //          var dataMaps = this.requestObject.chartRequest.dataMaps;
        //          var legends = this.requestObject.chartRequest.legends;

        // Populate x parameter
        this.requestObject.chartRequest.charts[1].x = JSON.parse(
            JSON.stringify(this.requestObject.chartRequest.charts[0].x)
        );
        this.requestObject.chartRequest.charts[1].x.axisProperties = JSON.parse(
            JSON.stringify(this.chartProperties.defaults[1].x.axisProperties)
        );
        // FIXME: this should be updated by the style panel code as well
        this.requestObject.chartRequest.charts[1].x.data.numBins = 50;
        // Populate y parameter
        this.requestObject.chartRequest.charts[1].y.series = [];
        for (var i = 0; i < this.parameters.yline.length; i++) {
            var ySeries = {
                type: 'aggregation',
                guid: this.parameters.yline[i].id
            };
            ySeries.aggregationType = 'MEAN'; // that.controls.yLineControl.getAggregationType(i);
            this.requestObject.chartRequest.charts[1].y.series.push(ySeries);

            this.addRawParam(this.parameters.yline[i], dataParams.raw);
        }
        this.requestObject.chartRequest.charts[1].y.minFilterPercent = that.controls.yLineControl.getAxisMinValue();
        this.requestObject.chartRequest.charts[1].y.maxFilterPercent = that.controls.yLineControl.getAxisMaxValue();
        this.requestObject.chartRequest.charts[1].y.axisProperties = that.controls.yLineControl.getAxisProperties();
        this.requestObject.chartRequest.charts[1].y.axisProperties.position =
            'end';
        // Populate color parameter
        var type = that.controls.colorControl.getType();
        if (type === 'byData') {
            this.requestObject.chartRequest.charts[1].color = {
                type: 'byData',
                data: { guid: this.parameters.colorline.id }
            };
            if (this.parameters.colorline.dataType === 'STRING') {
                this.requestObject.chartRequest.charts[1].color.data.type =
                    'binnedDiscrete';
                this.requestObject.chartRequest.charts[1].color.data.discreteValues = that.controls.colorControl.getDiscreteValues();
            } else {
                this.requestObject.chartRequest.charts[1].color.data.type =
                    'aggregation';
                this.requestObject.chartRequest.charts[1].color.data.aggregationType = that.controls.colorControl.getAggregationType();
                this.requestObject.chartRequest.charts[1].color.data.minFilterPercent = that.controls.colorControl.getLinearMinValue();
                this.requestObject.chartRequest.charts[1].color.data.maxFilterPercent = that.controls.colorControl.getLinearMaxValue();
            }

            var colorMap = that.controls.colorControl.getDataMap();
            this.requestObject.chartRequest.charts[1].color.dataMap =
                colorMap.guid;
            this.addDataMap(colorMap, dataMaps.colorMaps);

            this.addRawParam(this.parameters.colorline, dataParams.raw);

            var colorLegend = {
                guid: 'colorLegend2',
                type: 'color',
                chartGuid: this.requestObject.chartRequest.charts[1].guid,
                width: 300,
                height: 100
            };
            if (legends === null) {
                legends = [];
            }
            legends.push(colorLegend);
        } else {
            this.requestObject.chartRequest.charts[1].color.type = type;
            if (type === 'fixed') {
                this.requestObject.chartRequest.charts[1].color.defaultColor = that.controls.colorControl.getFixedColor();
            } else {
                var colorMap = that.controls.colorControl.getDataMap();
                this.requestObject.chartRequest.charts[1].color.dataMap =
                    colorMap.guid;
                this.addDataMap(colorMap, dataMaps.colorMaps);

                //                  var colorLegend =
                //                  {"guid":"colorLegend2","type":"color",
                //                  "chartGuid":this.requestObject.chartRequest.charts[1].guid,"width":300,
                //                  "height":100}; if (legends === null) {
                //                      legends = [];
                //                  }
                //                  legends.push(colorLegend);
            }
        }
    };
    
    // support yline
    avsChartPrototype.supportYLine = function() {
        return true;
    };
    
    
    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avslinechart = avsChartPrototype;
})(this);
