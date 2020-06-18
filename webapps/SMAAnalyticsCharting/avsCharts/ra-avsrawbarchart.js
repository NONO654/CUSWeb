(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.avsrawbarchart !== 'undefined') {
        return;
    }

    var chartLibrary = GLOBAL.DS.RAObjects.chartParameterLibrary;

    var avsChartPrototype = {
        is: 'ra-avsrawbarchart',
        behaviors: [GLOBAL.DS.RAComponents.avsdropchartbase]
    };

    avsChartPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.avsdropchartbase.createdCallback.call(this);

        this.divs.root.removeChild(this.divs.sizeDropZone);
        this.divs.root.removeChild(this.divs.xAxisDropZone);
        
        
        var that = this;
        
        this.divs.labelDropZone.setPlaceholderText(function() {
            if (
                typeof that.parameters.label !== 'undefined' &&
                that.parameters.label !== null
            ) {
                return String(
                    decodeURIComponent(
                        that.parameters.label.displayName ||
                            that.parameters.label.name
                    )
                );
            } else {
                return 'X Axis \n Label';
            }
        });
        
        this.addYLineAxis();

        this.makeZoomable({maxZoom:1});
    };

    avsChartPrototype.getXParameter = function(parameter, attributes) {
        var chartParam,        
        chartParam = chartLibrary.parameterTemplates.rawNumeric.create('X');
        
        return chartParam;
    };
    
    avsChartPrototype.getColorParameter = function(parameter, attributes) {
        var chartParam;
        // Make sure attributes and attributes.data exist
        attributes = attributes || {};
        attributes.data = attributes.data || {};

        if (parameter.dataType === 'STRING') {
            chartParam = chartLibrary.parameterTemplates.discreteColor.create(
                'Color'
            );
            attributes.data.discreteValues = parameter.stringSortedByFreqs;
        } else {
            chartParam = chartLibrary.parameterTemplates.rawColor.create(
                'Color'
            );
        }

        chartParam.update(attributes);

        return chartParam;
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
    
    avsChartPrototype.validateYLineData = function(data) {
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

    avsChartPrototype.renderControlPanel = function(panel) {
        GLOBAL.DS.RAComponents.avsdropchartbase.renderControlPanel.call(
            this,
            panel
        );

        // Modify param panels        
        this.controls.yControl.nParameters(10);
        this.controls.yControl.setShowAxisFilter(true);
        this.controls.yControl.setShowParamFilter(false);
        this.controls.yControl.setShowAggregationType(false);
        this.controls.yControl.setParameterColorSelector(this.getSeriesColorForParameter);
        
        this.controls.yLineControl.setShowAxisFilter(true);
        this.controls.yLineControl.setShowParamFilter(false);
        this.controls.yLineControl.setShowAggregationType(false);
        this.controls.yLineControl.setParameterColorSelector(this.getSeriesColorForParameter);
        
        this.controls.colorControl.setShowAggregationType(false);
    };

    avsChartPrototype.validateRender = function() {
         if (this.parameters.y.length > 0) {
            return true;
        }        
        return false;
    };

    avsChartPrototype.updateRequest = function() {
        var that = this;

        // Populate label parameter
        if (this.parameters.label !== null) {
            this.setXParameter(this.parameters.label);
            
        } else {
            var indexXParam = 
                    {
                        id : 'Index',
                        ID : 'Index',
                        type : 'PARAMETER',
                        displayName : 'Index',
                        name : 'Index',
                        source : this.parameters.y[0].source                        
                    };
            this.setXParameter(indexXParam);
        }
        this.requestObject.chartRequest.charts[0] = that.controls.chartPropertiesControl.getRequest();
        this.requestObject.chartRequest.charts[0].guid = 'bar1';

        var dataParams = { raw: [{ guid: this.parameters.x.id }] };
        var dataMaps = { colorMaps: [] };
        var legends = null;

        // Populate x parameter
        this.requestObject.chartRequest.charts[0].x = {
            data: { type: 'raw', guid: this.parameters.x.id }
        };
        this.addRawParam(this.parameters.x, dataParams.raw);
        //this.requestObject.chartRequest.charts[0].x.axisProperties = that.controls.xControl.getAxisProperties();        

        // Populate y parameter
        var yLabelOverride = null;
        var allParamNames = '';
        
        this.requestObject.chartRequest.charts[0].y = { series: [] };
        for (var i = 0; i < this.parameters.y.length; i++) {
            var ySeries = { type: 'raw', guid: this.parameters.y[i].id };
            
            allParamNames =
                    allParamNames +
                    decodeURIComponent(
                        this.parameters.y[i].displayName ||
                            this.parameters.y[i].name
                    );
                if (i + 1 < this.parameters.y.length) {
                    allParamNames = allParamNames + ', ';
                }
                
            this.requestObject.chartRequest.charts[0].y.series.push(
                ySeries
            );

            this.addRawParam(this.parameters.y[i], dataParams.raw);
        }
        
        if (that.controls.yControl.isUserDefinedAxisTitleText() === false) {
                yLabelOverride = allParamNames;
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
        
        // we need to insert 'ZeroFill' parameter for all parameters on main y axis, otherwise 
        // bars overlap
        for (var i = 0; i < this.parameters.yline.length; i++) {
            var ySeries = {
                type: 'raw',
                guid: 'ZeroFill'
            };
            this.requestObject.chartRequest.charts[0].y.series.push(ySeries);

            this.addRawParam({id:'ZeroFill'}, dataParams.raw);
            
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
                    'raw';
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
            this.requestObject.chartRequest.charts[0].color.type = 'bySeries';
           
            var colorMap = GLOBAL.DS.RAObjects.dataMaps.seriesParametersColorMap;
            var reqColorMap = Object.assign({}, colorMap);
            reqColorMap.colors = [];
                
            for (var i=0; i<this.parameters.y.length; i++) {
                var existingColor = this.getSeriesColorForParameter(this.parameters.y[i].id);                
                reqColorMap.colors.push(existingColor);
            }
                
            for (var i=0; i<this.parameters.yline.length; i++) {
                var existingColor = this.getSeriesColorForParameter("ZeroFill");               
                reqColorMap.colors.push(existingColor);
            }
            this.requestObject.chartRequest.charts[0].color.dataMap =
                colorMap.guid;
            this.addDataMap(reqColorMap, dataMaps.colorMaps);    
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
        
        // Populate x parameter
        this.requestObject.chartRequest.charts[1].x = JSON.parse(
            JSON.stringify(this.requestObject.chartRequest.charts[0].x)
        );
        this.requestObject.chartRequest.charts[1].x.axisProperties = JSON.parse(
            JSON.stringify(this.chartProperties.defaults[1].x.axisProperties)
        );
        
       
        
        var yLabelOverride = null;
        var allParamNames = '';
         
         // Populate y parameter
        this.requestObject.chartRequest.charts[1].y.series = [];
        
        // we need to insert 'ZeroFill' parameter for all parameters on main y axis, otherwise 
        // bars overlap
        for (var i = 0; i < this.parameters.y.length; i++) {
            var ySeries = {
                type: 'raw',
                guid: 'ZeroFill'
            };
            this.requestObject.chartRequest.charts[1].y.series.push(ySeries);

            this.addRawParam({id:'ZeroFill'}, dataParams.raw);
            
        }
        
        for (var i = 0; i < this.parameters.yline.length; i++) {
        
            var ySeries = {
                type: 'raw',
                guid: this.parameters.yline[i].id
            };
            
            allParamNames =
                    allParamNames +
                    decodeURIComponent(
                        this.parameters.yline[i].displayName ||
                            this.parameters.yline[i].name
                    );
                if (i + 1 < this.parameters.yline.length) {
                    allParamNames = allParamNames + ', ';
                }                
            
            
            this.requestObject.chartRequest.charts[1].y.series.push(ySeries);

            this.addRawParam(this.parameters.yline[i], dataParams.raw);
        }
        
        if (that.controls.yLineControl.isUserDefinedAxisTitleText() === false) {
                yLabelOverride = allParamNames;
        }
            
        this.requestObject.chartRequest.charts[1].y.minFilterPercent = that.controls.yLineControl.getAxisMinValue();
        this.requestObject.chartRequest.charts[1].y.maxFilterPercent = that.controls.yLineControl.getAxisMaxValue();
        this.requestObject.chartRequest.charts[1].y.axisProperties = that.controls.yLineControl.getAxisProperties();
        this.requestObject.chartRequest.charts[1].y.axisProperties.position =
            'end';
            
        if (yLabelOverride !== null) {
            this.updateAxisLabel(
                this.requestObject.chartRequest.charts[1].y,
                yLabelOverride
            );
        }
            
        // Populate color parameter
        var type = that.controls.colorControl.getType();
        if (type === 'byData') {
            this.requestObject.chartRequest.charts[1].color = {
                type: 'byData',
                data: { guid: this.parameters.color.id }
            };
            if (this.parameters.color.dataType === 'STRING') {
                this.requestObject.chartRequest.charts[1].color.data.type =
                    'binnedDiscrete';
                this.requestObject.chartRequest.charts[1].color.data.discreteValues = that.controls.colorControl.getDiscreteValues();
            } else {
                this.requestObject.chartRequest.charts[1].color.data.type =
                    'raw';
                this.requestObject.chartRequest.charts[1].color.data.minFilterPercent = that.controls.colorControl.getLinearMinValue();
                this.requestObject.chartRequest.charts[1].color.data.maxFilterPercent = that.controls.colorControl.getLinearMaxValue();
            }
            var colorMap = that.controls.colorControl.getDataMap();
            this.requestObject.chartRequest.charts[1].color.dataMap =
                colorMap.guid;                        

          
        }
        else{
            if (this.parameters.yline.length >= 1) {                
            
                var colorMap = GLOBAL.DS.RAObjects.dataMaps.seriesParametersColorMap;
                var reqColorMap = Object.assign({}, colorMap);
                reqColorMap.colors = [];
                reqColorMap.guid = "RA_COLORMAP_FOR_YLINE_PARAMETERS";                
                
                
                for (var i=0; i<this.parameters.y.length; i++) {
                    var existingColor = this.getSeriesColorForParameter("ZeroFill");                    
                    reqColorMap.colors.push(existingColor);
                }
                
                
                for (var i=0; i<this.parameters.yline.length; i++) {
                    var existingColor = this.getSeriesColorForParameter(this.parameters.yline[i].id);                    
                    reqColorMap.colors.push(existingColor);
                }
                this.addDataMap(reqColorMap, dataMaps.colorMaps);
                type = 'bySeries';
                this.requestObject.chartRequest.charts[1].color.dataMap =
                    reqColorMap.guid;
                               
            }

            this.requestObject.chartRequest.charts[1].color.type = type;
        }
            
        
    };
    

    // support yline
    avsChartPrototype.supportYLine = function() {
        return true;
    };
    
    // support color for yparameter and yline
    avsChartPrototype.supportColorYParamElement = function() {
        return true;
    };
    Polymer(avsChartPrototype);
    GLOBAL.DS.RAComponents.avsrawbarchart = avsChartPrototype;
})(this);
