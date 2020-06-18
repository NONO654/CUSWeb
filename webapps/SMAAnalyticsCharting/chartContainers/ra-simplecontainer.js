(function(GLOBAL) {
    var simpleContainerPrototype = {
        is: 'ra-simplecontainer',
        behaviors: [
            GLOBAL.DS.RAComponents.chartcomponent,
            GLOBAL.DS.RAComponents.droptarget,
            GLOBAL.DS.RAComponents.commoncontainer
        ],
        keyPress: { ctrl: false, shift: false, alt: false }
    };

    simpleContainerPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.chartcomponent.createdCallback.call(this);
        GLOBAL.DS.RAComponents.droptarget.createdCallback.call(this);

        // sd4 - This flag indicates that there will only be on chart in the
        // container
        this._singleMode = false;

        this.baseUrl = '';
        var that = this;

        this.setFilter(function(d) {
            if (
                d &&
                d.type !== GLOBAL.DS.RAComponents.chartConstants.dragTypes.CHART
            ) {
                return false;
            }

            return true;
        });
     

        this.setDropListener(function(data, event) {
            var chartUrl;
            var chartName =
                (data.properties && data.properties.tagName) || data.id;
            if (typeof that.baseUrl === 'string') {
                chartUrl =
                    that.baseUrl + data.source + '/' + chartName + '.html';
            } else if (typeof that.baseUrl === 'function') {
                // chartUrl = that.baseUrl(data.source + '/' + chartName + '.html');
                // FIXME: remove hard coded value: SMAAnalyticsCharting
                chartUrl = that.baseUrl(
                    'SMAAnalyticsCharting/' +
                        data.source +
                        '/' +
                        chartName +
                        '.html'
                );
            }
            console.log('dropped!');

            var bounds = that.getBoundingClientRect();

            var frameHeight = 400,
                frameWidth = 500;

            var y = Math.max(
                    frameHeight / 2,
                    event.clientY - bounds.top + this.scrollTop
                ),
                x = Math.max(
                    frameWidth / 2,
                    event.clientX - bounds.left + this.scrollLeft
                );

            var frame = that.getFrame({
                resizable: 'true',
                closeButton: 'true',
                popoutButton: 'false',
                printButton: 'false',
                'element-title': data.properties.title,
                titleEditable: 'true',
                height: frameHeight,
                width: frameWidth,
                position: 'coordinates ' + x + ' ' + y
            });

            var frameContent = frame.querySelector('.content'); // ||
            // frame.shadowRootElement.querySelector('.content');

            frameContent.controls = frameContent.controls || {};
            that.propagateChartEvent({ eventType: 'mask' }, [frameContent]);
            Polymer.Base.importHref(chartUrl, function() {
                var chartElement = document.createElement(data.id);
                chartElement.chartId = that.newGUID();
                chartElement.classList.add('gridChart');
                chartElement.setDataProvider(that.dataProvider);
                chartElement.set3DSpaceURL(that._3DSpaceURL);                
                chartElement.setChartProperties(data);
                chartElement.chartParent = that;
                if (typeof chartElement.initialize === 'function') {
                    chartElement.initialize();
                }

                frameContent = frameContent || frame.querySelector('.content'); // ||
                // frame.shadowRootElement.querySelector('.content');
                frameContent.appendChild(chartElement);
                
                // QW8: copied from gridcontainer --- need to set draggable after chart is initialized, it was earlier in initializeElement call
                // but if chart loading takes time, and during that time user drags the chart, it results in 
                // chart being unstable
                                
                frame.setDraggable();
                
                frame.setChart(chartElement);

                frame.focusElement();
                that.propagateChartEvent({ eventType: 'unmask' }, [
                    frameContent
                ]);
                // add chart to the charts object
                var newChart = {};
                newChart.definition = data;
                newChart.element = chartElement;
                newChart.frame = frame;
                newChart.chartParent = that;
                that.addChart(chartElement.chartId, newChart);
                that.updateChartsConfigPreference(chartElement.chartId);
                
                if(typeof chartElement.renderOnDrop === 'boolean' && chartElement.renderOnDrop){
                	chartElement.renderChart();
                }
                // TODO: We need to create a chart frame and stick our new chart in
                // the chart frame,  then attach that element at the position of the
                // drop. (centered?)
            });
        });

        // Propagate events to all charts
    };

    simpleContainerPrototype.getFrame = function(args) {
        var that = this;
        var el = document.createElement('ra-simpleframe');
        el.setOverlayAttributes(args);

        el.addCallback('titleBlur', function(e) {
            console.log('Title blurred!');
        });

        el.addCallback('titleChange', function(e) {
            console.log('Title changed!');
        });
        el.addCallback('popout', function(e) {
            console.log('popping out the chart');
            console.log(that);
            console.log(el);
        });
        this.appendChild(el);
        // this is called when appended, but for some
        // reason in ff, it's async so stuff is missing
        // that is expected later
        el.initializeElement();

        return el;
    };

    simpleContainerPrototype.focusFrame = function(focusFrame) {
        var frames = this.querySelectorAll('ra-simpleframe');

        Array.prototype.forEach.call(frames, function(frame) {
            if (frame !== focusFrame) {
                frame.blurElement();
            }
        });
        // sd4: Why are we appending this again?
        // i see that ra-gridframe calls this method as
        // this.parentElement.focusFrame(this) --> this is already a child, no????
        // d9u: (answer to above) we're appending this again to put it last in the
        // DOM at this level, this puts it in front of all other charts when it's
        // focused without having to mess around with the z-indexing
        // d9u: this was blocking a click event listener, removing this
        //this.appendChild(focusFrame);

        focusFrame.renderControlPanel(this.controlPanel);
        if (this.paramsControlPanel) {
            focusFrame.renderParametersControl(this.paramsControlPanel);
        }

        if (this.settingsControlPanel) {
            focusFrame.renderSettingsControl(this.settingsControlPanel);
        }

        if (this.stylePanel) {
            focusFrame.renderStylePanel(this.stylePanel);
        }
    };
    
    simpleContainerPrototype.getChartConfig = function(chartId) {
        var chart = this.charts[chartId];
        var savedChart = {};
        if(chart){
	        savedChart.definition = chart.definition;
	        savedChart.configuration = chart.element.getConfiguration();
	        savedChart.frame = {
	            height: chart.frame.dimensions.height,
	            width: chart.frame.dimensions.width,
	            'element-title': chart.frame.getAttribute('element-title'),
	            position:
	                'coordinates ' +
	                (chart.frame.dimensions.x +
	                    chart.frame.dimensions.width / 2) +
	                ' ' +
	                (chart.frame.dimensions.y +
	                    chart.frame.dimensions.height / 2)
	        };
        }
        return savedChart;
    };
    
    
    simpleContainerPrototype.setSingleMode = function(singleMode) {
        this._singleMode = singleMode;
    };
    
    simpleContainerPrototype.restoreChart = function(chart, index, cb) {
        var that = this;
        var chartUrl;
        var data = chart.definition;
        var chartName = (data.properties && data.properties.tagName) || data.id;
        if (typeof that.baseUrl === 'string') {
            chartUrl = that.baseUrl + data.source + '/' + chartName + '.html';
        } else if (typeof that.baseUrl === 'function') {
            // chartUrl = that.baseUrl(data.source + '/' + chartName + '.html');
            // FIXME: remove hardcoded value: SMAAnalyticsCharting
            chartUrl = that.baseUrl(
                'SMAAnalyticsCharting/' +
                    data.source +
                    '/' +
                    chartName +
                    '.html'
            );
        }
        var defaultFrameOptions = {
            resizable: 'true',
            closeButton: 'true',
            popoutButton: 'false',
            printButton: 'false',
            'element-title': chart.frame['element-title'],
            titleEditable: 'true',
            height: chart.frame.height,
            width: chart.frame.width,
            position: chart.frame.position
        };
        if (this._singleMode) {
            defaultFrameOptions = {
                resizable: 'false',
                closeButton: 'false',
                popoutButton: 'false',
                printButton: 'false',
                'element-title': chart.frame['element-title'],
                titleEditable: 'true',
                height: '100%',
                width: '100%',
                position: 'coordinates ' + this.width + ' ' + this.height
            };
        }

        var frame = that.getFrame(defaultFrameOptions);
        var frameContent = frame.querySelector('.content');
        frameContent.controls = frameContent.controls || {};
        that.propagateChartEvent({ eventType: 'mask' }, [frameContent]);
        Polymer.Base.importHref(chartUrl, function() {
            var chartElement = document.createElement(data.id);
            chartElement.chartId = chart.id;
            chartElement.classList.add('gridChart');
            chartElement.setDataProvider(that.dataProvider);
            chartElement.set3DSpaceURL(that._3DSpaceURL);
            chartElement.setChartProperties(data);
            chartElement.chartParent = that;
            if (typeof chartElement.initialize === 'function') {
                chartElement.initialize(chart.configuration);
            }

            // All charts use the popover handler on the grid container.
            chartElement.setPopover(function(args) {
                return that.getPopover(args);
            });
            // make sure frameContent is set
            frameContent = frameContent || frame.querySelector('.content');
            frameContent.appendChild(chartElement);
            
            // need to set draggable after chart is initialized, it was earlier in initializeElement call
            // but if chart loading takes time, and during that time user drags the chart, it results in 
            // chart being unstable
                                
            frame.setDraggable();
            
            frame.setChart(chartElement);

            that.propagateChartEvent({ eventType: 'unmask' }, [frameContent]);

            frame.focusElement();
            chartElement.restore(chart.configuration);

            // add chart to the charts object
            var newChart = {};
            newChart.definition = data;
            newChart.configuration = chart.configuration;
            newChart.element = chartElement;
            newChart.frame = frame;
            newChart.chartParent = that;
            that.addChart(chart.id, newChart);
            cb(data.id);
            // TODO: We need to create a chart frame and stick our new chart in the
            // chart frame,  then attach that element at the position of the drop.
            // (centered?)
        });
    };
    
    // FIXME: IS this the right place to track this information?
    // sd4: store key press information
    // qw8: no idea where to store this info. I'm leaving this here for now since different
    // containers might need different keys stored? Not really sure all of what we're doing with
    // this data.
    simpleContainerPrototype.getKeyPress = function() {
        return simpleContainerPrototype.keyPress;
    };
    
    window.addEventListener(
        'keydown',
        function(event) {
            var vKey = event.keyCode
                ? event.keyCode
                : event.which ? event.which : event.charCode;
            if (vKey === 17) {
                simpleContainerPrototype.keyPress.ctrl = true;
            } else if (vKey === 13) {
                simpleContainerPrototype.keyPress.shift = true;
            } else if (vKey === 18) {
                simpleContainerPrototype.keyPress.alt = true;
            }
        },
        false
    );
    
    window.addEventListener(
        'keyup',
        function(event) {
            var vKey = event.keyCode
                ? event.keyCode
                : event.which ? event.which : event.charCode;
            if (vKey === 17) {
                simpleContainerPrototype.keyPress.ctrl = false;
            } else if (vKey === 13) {
                simpleContainerPrototype.keyPress.shift = false;
            } else if (vKey === 18) {
                simpleContainerPrototype.keyPress.alt = false;
            }
        },
        false
    );
    
    Polymer(simpleContainerPrototype);
    GLOBAL.DS.RAComponents.simplecontainer = simpleContainerPrototype;
})(this);


