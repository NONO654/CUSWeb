(function(GLOBAL) {
    var carpetPlotPrototype = {
        is: 'ra-carpetplot',
        behaviors: [GLOBAL.DS.RAComponents.chart]
    };

    carpetPlotPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.chart.createdCallback.call(this);

        this.divs = { root: document.createElement('div') };
        this.divs.root.classList.add('carpetPlot-rootDiv');
        this.appendChild(this.divs.root);

        this.addXAxis();
        this.addYAxis();
        this.addChart();

        this.parameters = { outputs: { x: null, y: null }, inputs: [] };

        this.approxId = null;
    };

    carpetPlotPrototype.addXAxis = function() {
        var that = this;

        // Create axis element
        this.xAxis = document.createElement('ra-axis');
        var axis = this.xAxis;
        axis.setOrientation('bottom');
        axis.classList.add('carpetPlot-xAxis');

        axis.setFilter(this.validateXData);
        axis.setDragEnterListener(function(data) {
            axis.highlight();
        });
        axis.setDropListener(function(data) {
            axis.unHighlight();
            console.log('Drop on x axis!');
            that.setXParameter(data.properties);
            that.controls.xControl.updateController([data.properties]);
        });
        this.xAxis.setPlaceholderText(function() {
            // This now points to the axis.
            if (
                typeof this.parameter !== 'undefined' &&
                typeof this.parameter.name !== 'undefined'
            ) {
                return 'Output Parameter: ' + this.parameter.name;
            } else {
                return 'Output Parameter';
            }
        });

        this.divs.root.appendChild(this.xAxis);
    };

    carpetPlotPrototype.validateXData = function(data) {
        // First we ensure that the data is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }

        // Next we ensure it is an approximation input
        if (data.properties.parameterType !== 'approximation') {
            return false;
        }
        if (data.properties.parameterRole !== 'output') {
            return false;
        }

        // Finally, we make an internal check to ensure that, if we have a defined
        // approximation  for this element, it is the same approximation that this
        // parameter is from  NOTE: Temporarily disabled since all approximations have
        // the same parameters.  if(that.approxId && that.approxId !== data.source){
        //  return false
        //}

        return true;
    };

    carpetPlotPrototype.addYAxis = function() {
        var that = this;

        // Create axis element
        this.yAxis = document.createElement('ra-axis');
        var axis = this.yAxis;
        axis.setOrientation('left');
        axis.setFilter(this.validateYData);
        axis.setDragEnterListener(function(data) {
            axis.highlight();
        });
        axis.setDropListener(function(data) {
            axis.unHighlight();
            console.log('Drop on y axis!');
            that.setYParameter(data.properties);
            that.controls.yControl.updateController([data.properties]);
        });
        this.yAxis.classList.add('carpetPlot-yAxis');
        this.yAxis.setPlaceholderText(function() {
            // This now points to the axis.
            if (
                typeof this.parameter !== 'undefined' &&
                typeof this.parameter.name !== 'undefined'
            ) {
                return 'Output Parameter: ' + this.parameter.name;
            } else {
                return 'Output Parameter';
            }
        });

        this.divs.root.appendChild(this.yAxis);
    };

    carpetPlotPrototype.validateYData = function(data) {
        // First we ensure that the data is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }

        // Next we ensure it is an approximation input
        if (data.properties.parameterType !== 'approximation') {
            return false;
        }
        if (data.properties.parameterRole !== 'output') {
            return false;
        }

        // Finally, we make an internal check to ensure that, if we have a defined
        // approximation  for this element, it is the same approximation that this
        // parameter is from  NOTE: Temporarily disabled since all parameters have the
        // same outputs.  if(that.approxId && that.approxId !== data.source){
        //  return false
        //}

        return true;
    };

    carpetPlotPrototype.addChart = function() {
        var that = this;
        // The main chart will be contianed in an ra-droptarget element to handle
        // drops
        // TODO: This should be generalized onto a more specific drop target for
        // chart drop  zones, probably.
        this.divs.chartDropZone = document.createElement('ra-chartdroptarget');
        this.divs.chartDropZone.classList.add('carpetPlot-chartDropZone');
        this.divs.chartDropZone.setDragEnterListener(
            this.divs.chartDropZone.highlight
        );
        this.divs.chartDropZone.setDragLeaveListener(
            this.divs.chartDropZone.unhighlight
        );
        this.divs.chartDropZone.setParameterListener(
            this.divs.addInputParameter
        );
        this.divs.chartDropZone.setPlaceholderFilter(
            this.placeholderFilter.bind(this)
        );

        this.divs.chartDropZone.setPlaceholderText(function() {
            if (that.parameters.inputs.length === 0) {
                return 'Input Parameters';
            } else {
                var text = 'Input Parameters:',
                    i;
                for (i = 0; i < that.parameters.inputs.length; i++) {
                    text += '\n' + that.parameters.inputs[i].name;
                }
                return text;
            }
        });

        // Add parameter handler
        var paramHandler = document.createElement('ra-drophandler');
        paramHandler.setFilter(this.validateInputData);
        paramHandler.setDropListener(function(param) {
            that.addInputParameter(param);
            that.controls.inputsControl.updateController(
                that.parameters.inputs
            );
        });

        this.divs.chartDropZone.appendChild(paramHandler);

        this.divs.root.appendChild(this.divs.chartDropZone);
    };

    carpetPlotPrototype.validateInputData = function(data) {
        // check that datum is a parameter
        if (
            data.type !==
            GLOBAL.DS.RAComponents.chartConstants.dragTypes.PARAMETER
        ) {
            return false;
        }

        // Is an approx input parameter
        if (
            data.properties.parameterType !== 'approximation' ||
            data.properties.parameterRole !== 'input'
        ) {
            return false;
        }

        // If we have an approximation, make sure it is the same as the one on the
        // parameter being dragged.  if(typeof this.approxId !== 'undefined' &&
        // this.approxId !== data.properties.source){
        //  return false;
        //}

        return true;
    };

    carpetPlotPrototype.setInputParameters = function(parameters) {
        if (parameters.length === 0) {
            this.approxId === null;
        } else {
            this.approxId = parameters[0].source;
        }

        this.parameters.inputs = parameters;

        this.divs.chartDropZone.updatePlaceholder();

        if (this.parameters.inputs.length === 2) {
            this.renderCarpetPlot();
        }
    };

    carpetPlotPrototype.updateInputsControl = function() {};

    carpetPlotPrototype.updateXControl = function() {};

    carpetPlotPrototype.updateYControl = function() {};

    // TODO: Generalize data structure by adding functions to retrieve max, min, id
    // for a parameter
    carpetPlotPrototype.addInputParameter = function(parameter) {
        var that = this;

        if (this.approxId === null) {
            this.approxId = parameter.source;
        }

        if (this.parameters.inputs.length < 2) {
            this.parameters.inputs.push(parameter.properties);
            this.divs.chartDropZone.updatePlaceholder();
            this.renderCarpetPlot();
        }
    };

    carpetPlotPrototype.setXParameter = function(parameter) {
        var that = this;

        if (this.approxId === null) {
            this.approxId = parameter.source;
        }

        that.parameters.outputs.x = parameter;
        that.xAxis.setParameter(parameter);

        that.renderCarpetPlot();
    };

    carpetPlotPrototype.setYParameter = function(parameter) {
        var that = this;

        if (this.approxId === null) {
            this.approxId = parameter.source;
        }

        that.parameters.outputs.y = parameter;
        that.yAxis.setParameter(parameter);

        that.renderCarpetPlot();
    };

    carpetPlotPrototype.renderCarpetPlot = function() {
        var that = this;

        if (
            !(
                this.parameters.inputs.length === 2 &&
                this.parameters.outputs.x !== null &&
                this.parameters.outputs.y !== null
            )
        ) {
            return;
        }

        this.divs.chartDropZone.hidePlaceholder();

        var carpetPlot = document.createElement('ra-carpetplotelement');

        carpetPlot.setTotalHeight(this.divs.chartDropZone.offsetHeight);
        carpetPlot.setTotalWidth(this.divs.chartDropZone.offsetWidth);

        this.divs.chartDropZone.appendChild(carpetPlot);

        carpetPlot.setX(this.parameters.outputs.x);
        carpetPlot.setY(this.parameters.outputs.y);

        // Set input values before setting them:
        var paramSamples = 9;

        var input1 = { id: this.parameters.inputs[0].id, values: [] },
            input2 = { id: this.parameters.inputs[1].id, values: [] },
            _input1 = this.parameters.inputs[0],
            _input2 = this.parameters.inputs[1];

        for (var i = 0; i < paramSamples; i++) {
            input1.values.push(
                _input1.min +
                    (_input1.max - _input1.min) * (i / (paramSamples - 1))
            );
            input2.values.push(
                _input2.min +
                    (_input2.max - _input2.min) * (i / (paramSamples - 1))
            );
        }

        carpetPlot.setCarpetParam1(input1);
        carpetPlot.setCarpetParam2(input2);

        this.getPlotData(input1, input2, function(data) {
            carpetPlot.setData(data);

            that.yAxis.setScale(carpetPlot.scales.y);
            that.yAxis.refresh();
            that.xAxis.setScale(carpetPlot.scales.x);
            that.xAxis.refresh();

            carpetPlot.render();
        });

        console.log('rendering carpet plot!');
    };

    carpetPlotPrototype.getPlotData = function(input1, input2, dataCallback) {
        var paramSamples = 9;

        var that = this;

        var approxCallback = function(approxOutputs) {
            // Data is structured into arrays of 2-arrays, representing values
            // across values for inputs param1 and param2.

            var data = { x: [], y: [] };

            var i, j;
            for (i = 0; i < approxOutputs.length; i++) {
                var xRow = [],
                    yRow = [];
                for (var j = 0; j < approxOutputs[0].length; j++) {
                    xRow.push(
                        approxOutputs[i][j][that.parameters.outputs.x.id]
                    );
                    yRow.push(
                        approxOutputs[i][j][that.parameters.outputs.y.id]
                    );
                }
                data.x.push(xRow);
                data.y.push(yRow);
            }

            dataCallback(data);
        };

        var baselinePointCallback = function(baselinePoint) {
            var param1 = input1,
                param2 = input2;

            var plotData = {
                baselinePoint: baselinePoint,
                param1: input1,
                param2: input2
            };

            var request = { approxId: that.approxId, data: plotData };

            that.dataProvider.executeSupport(
                'evaluateApproximation',
                request,
                approxCallback
            );
        };

        this.dataProvider.executeSupport(
            'getBaselinePoint',
            { approxId: this.approxId },
            baselinePointCallback
        );
    };
    // Update x scale

    carpetPlotPrototype.renderControlPanel = function(panel) {
        var that = this;

        // Add input params panel
        var inputsControl = panel.getControl('ra-parametercontrol');
        inputsControl.title('Inputs');
        inputsControl.nParameters(2);
        inputsControl.setFilter(this.validateInputData);
        inputsControl.setChangeListener(function(params) {
            that.setInputParameters(params);
        });
        if (this.parameters.inputs instanceof Array) {
            inputsControl.updateController(this.parameters.inputs);
        }

        // Add x param panel
        var xParamControl = panel.getControl('ra-parametercontrol');
        xParamControl.title('X Parameter');
        xParamControl.nParameters(1);
        xParamControl.setFilter(this.validateXData);
        xParamControl.setChangeListener(function(params) {
            that.setXParameter(params[0]);
        });
        if (this.parameters.outputs.x) {
            xParamControl.updateController([this.parameters.outputs.x]);
        }

        // Add y param panel
        var yParamControl = panel.getControl('ra-parametercontrol');
        yParamControl.title('Y Parameter');
        yParamControl.nParameters(1);
        yParamControl.setFilter(this.validateYData);
        yParamControl.setChangeListener(function(params) {
            that.setYParameter(params[0]);
        });
        if (this.parameters.outputs.y) {
            yParamControl.updateController([this.parameters.outputs.y]);
        }

        this.controls = {
            inputsControl: inputsControl,
            xControl: xParamControl,
            yControl: yParamControl
        };
    };

    Polymer(carpetPlotPrototype);
    GLOBAL.DS.RAComponents.carpetplot = carpetPlotPrototype;
})(this);
