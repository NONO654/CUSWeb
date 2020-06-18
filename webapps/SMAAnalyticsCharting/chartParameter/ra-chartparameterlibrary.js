(function(GLOBAL) {
    // define('SMAAnalyticsCharting/chartParameterLibrary',
    // ['DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils'], function(NSLUtils){

    var NLSUtils = GLOBAL.DS.RAObjects.NLSUtils;

    GLOBAL.DS.RAObjects.chartParameterLibrary = new GLOBAL.DS.RAConstructors.
        ChartParameterLibrary();

    var AttributeObjectTemplate =
            GLOBAL.DS.RAConstructors.AttributeObjectTemplate,
        ChartParameterTemplate =
            GLOBAL.DS.RAConstructors.ChartParameterTemplate,
        chartParameterLibrary = GLOBAL.DS.RAObjects.chartParameterLibrary;

    // Title properties attributeObject
    /*
 * <ra-textinputcontrol class="color"></ra-textinputcontrol>
        <ra-slidercontrol class="angle"></ra-slidercontrol>
        <ra-slidercontrol class="size"></ra-slidercontrol>
        <ra-textinputcontrol class="fontFamily"></ra-textinputcontrol>
        <ra-selectcontrol class="fontStyle"></ra-selectcontrol>
        <ra-selectcontrol class="fontWeight"></ra-selectcontrol>
        <ra-selectcontrol class="justification"></ra-selectcontrol>
        <ra-selectcontrol class="horizontalAlignment"></ra-selectcontrol>
        <ra-selectcontrol class="verticalAlignment"></ra-selectcontrol>
 */

    var titlePropertiesAttributes = {
        color: {
            tweaker: {
                typePath: 'color',
                label: NLSUtils.translate('Color'),
                semantics: {}
            }
        },
        angle: {
            'default': 0,
            tweaker: {
                typePath: 'numberslider',
                label: NLSUtils.translate('Angle'),
                displayStyle: 'slider',
                semantics: {
                    displayStyle: 'slider',
                    minValue: -180,
                    maxValue: 180
                }
            }
        },
        size: {
            tweaker: {
                typePath: 'numberslider',
                label: NLSUtils.translate('Size'),
                semantics: { minValue: 8, maxValue: 72, valueType: 'integer' }
            }
        },
        fontFamily: {
            // QW8: I'm leaving this out for now. It's a text box in the AVS
            // implementation, but we should use a drop down instead.  Need to look up
            // values in the server code for what the font options are. Stretch: get
            // some icons for the font options
        },
        fontStyle: {
            'default': 'normal',
            tweaker: {
                label: NLSUtils.translate('Font Style'),
                typePath: 'enumValueToProperty',
                semantics: {
                    possibleValues: {
                        normal: NLSUtils.translate('Normal'),
                        italic: NLSUtils.translate('Italic')
                    }
                }
            }
        },
        fontWeight: {
            'default': 'normal',
            tweaker: {
                label: NLSUtils.translate('Font Weight'),
                typePath: 'enumValueToProperty',
                semantics: {
                    possibleValues: {
                        normal: NLSUtils.translate('Normal'),
                        bold: NLSUtils.translate('Bold')
                    }
                }
            }
        },
        justification: {
            'default': 'end',
            tweaker: {
                label: NLSUtils.translate('Justification'),
                typePath: 'enumValueToProperty',
                semantics: {
                    possibleValues: {
                        start: NLSUtils.translate('Start'),
                        middle: NLSUtils.translate('Middle'),
                        end: NLSUtils.translate('End')
                    }
                }
            }
        },
        horizontalAlignment: {
            'default': 'center',
            tweaker: {
                label: NLSUtils.translate('Horizontal Alignment'),
                typePath: 'enumValueToProperty',
                semantics: {
                    possibleValues: {
                        left: NLSUtils.translate('Left'),
                        center: NLSUtils.translate('Center'),
                        right: NLSUtils.translate('Right')
                    }
                }
            }
        },
        verticalAlignment: {
            'default': 'middle',
            tweaker: {
                label: NLSUtils.translate('Vertical Alignment'),
                typePath: 'enumValueToProperty',
                semantics: {
                    possibleValues: {
                        top: NLSUtils.translate('Top'),
                        middle: NLSUtils.translate('Middle'),
                        bottom: NLSUtils.translate('Bottom'),
                        baseline: NLSUtils.translate('Baseline')
                    }
                }
            }
        }
    };
    var titlePropertiesTemplate = new AttributeObjectTemplate(
        'titleproperties',
        NLSUtils.translate('Properties'),
        titlePropertiesAttributes,
        {},
        chartParameterLibrary
    );

    // Title AttributeObject
    // console.log(NLSUtils); TODO: Get NLSUtils working. require.js for this?
    var titleAttributes = {
        text: { 'default': 'title', tweaker: { typePath: '', label: 'Title' } }
    };
    var titleTemplate = new AttributeObjectTemplate(
        'title',
        NLSUtils.translate('Title'),
        titleAttributes,
        { properties: 'titleproperties' },
        chartParameterLibrary
    );
    // chartParameterLibrary.addAttributeObject('title', titleTemplate);

    // Axis AttributeObject
    var axisAttributes = { style: {} };
    var axisAttributeObjects = { title: 'title' };
    var axisTemplate = new AttributeObjectTemplate(
        'axis',
        NLSUtils.translate('Axis'),
        axisAttributes,
        axisAttributeObjects,
        chartParameterLibrary
    );
    // chartParameterLibrary.addAttributeObject('axis', axisTemplate);

    // Numeric continuous axis
    var numericAxisAttributes = { style: { 'default': 'numeric' } };

    var numericAxisTemplate = new AttributeObjectTemplate(
        'numericAxis',
        NLSUtils.translate('Axis'),
        numericAxisAttributes,
        {},
        chartParameterLibrary
    );
    numericAxisTemplate.extends([axisTemplate]);
    
    // Cumulative continuous axis
    var cumulativeAxisAttributes = { style : {'defualt' : 'forcedNumeric'}};
    var cumulativeAxisTemplate = new AttributeObjectTemplate(
        'cumulativeAxis',
        NLSUtils.translate('Axis'),
        cumulativeAxisAttributes,
        {},
        chartParameterLibrary
    );
    cumulativeAxisTemplate.extends([axisTemplate]);
    

    // Discrete axis
    var discreteAxisAttributes = { style: { 'default': 'auto' } };
    var discreteAxisTemplate = new AttributeObjectTemplate(
        'discreteAxis',
        NLSUtils.translate('Axis'),
        discreteAxisAttributes,
        {},
        chartParameterLibrary
    );
    discreteAxisTemplate.extends([axisTemplate]);
    
    // Numeric continuous axis
    var tabularAxisAttributes = { style: { 'default': 'tabular' } };

    var tabularAxisTemplate = new AttributeObjectTemplate(
        'tabularAxis',
        NLSUtils.translate('Axis'),
        tabularAxisAttributes,
        {},
        chartParameterLibrary
    );
    tabularAxisTemplate.extends([axisTemplate]);
    

    // Base parameter that all other params inherit from.
    // This defines type and guid, which don't have defaults and aren't represented
    // in the tweaker object.
    var baseParamAttributes = { type: {}, guid: {} };
    var baseParamTemplate = new ChartParameterTemplate(
        'base',
        baseParamAttributes,
        {},
        chartParameterLibrary
    );

    // Spatial parameter
    var minLabel = 'Min Filter Percentage',
        maxLabel = 'Max Filter Percentage';

    var spatialAttributes = {
        minFilterPercent: {
            'default': 0,
            tweaker: { label: minLabel, typePath: 'percentage' }
        },
        maxFilterPercent: {
            'default': 100,
            tweaker: { label: maxLabel, typePath: 'percentage' }
        }
    };
    var spatialAttributeObjects = {
        /*'xis'*/
    };
    var spatialParameterTemplate = new ChartParameterTemplate(
        'spatial',
        spatialAttributes,
        spatialAttributeObjects,
        chartParameterLibrary
    );
    spatialParameterTemplate.extends([baseParamTemplate]);

    // Binned numeric spatial parameter
    var binnedNumericSpatialAttributes = {
        numBins: { 'default': 50 },
        type: { 'default': 'binnedEqualWidth' }
    };
    var binnedNumericSpatialAOs = { axisProperties: 'numericAxis' };
    var binnedNumericSpatialTemplate = new ChartParameterTemplate(
        'binnedNumericSpatial',
        binnedNumericSpatialAttributes,
        binnedNumericSpatialAOs,
        chartParameterLibrary
    );
    binnedNumericSpatialTemplate.extends([
        spatialParameterTemplate /*, 'base'*/
    ]); // base is inherited through
    // spatial.
    
    //Binned cumulative parameter
    var binnedCumulativeAOs = {axisProperties: 'cumulativeAxis'};
    var binnedCumulativeTemplate = new ChartParameterTemplate(
            'binnedCumulative',
            {},
            binnedCumulativeAOs,
            chartParameterLibrary
    );
    binnedCumulativeTemplate.extends([
        binnedNumericSpatialTemplate
    ]);

    // Raw numeric parameter
    var rawNumericSettings = { type: { 'default': 'raw' } };
    var rawNumericAOs = { axisProperties: 'numericAxis' };
    var rawNumericTemplate = new ChartParameterTemplate(
        {
            name: 'rawNumeric',
            attributes: {},
            settings: rawNumericSettings,
            attributeObjects: rawNumericAOs
        },
        chartParameterLibrary
    );
    rawNumericTemplate.extends([spatialParameterTemplate]);
    
    // Raw tabular parameter
    var rawTabularSettings = { type: { 'default': 'raw' } };
    var rawTabularAOs = { axisProperties: 'tabularAxis' };
    var rawTabularTemplate = new ChartParameterTemplate(
        {
            name: 'rawTabular',
            attributes: {},
            settings: rawTabularSettings,
            attributeObjects: rawTabularAOs
        },
        chartParameterLibrary
    );
    rawTabularTemplate.extends([spatialParameterTemplate]);
    

    // Discrete spatial parameter
    var discreteSpatialSettings = {
            type: { 'default': 'binnedDiscrete' },
            discreteValues: {
            }
    };
    var discreteSpatialAOs = { axisProperties: 'discreteAxis' };
    var discreteSpatialTemplate = new ChartParameterTemplate(
        'discreteSpatial',
        discreteSpatialSettings,
        discreteSpatialAOs,
        chartParameterLibrary
    );
    discreteSpatialTemplate.extends([spatialParameterTemplate]);

    // Color parameter
    var colorParamAttributes = {
        legend: {
            toggleAttribute: { attribute: 'type', value: 'byData' },
            'default': 'true'
        },
        dataMap: {
            toggleAttribute: { attribute: 'type', value: 'byData' },
            tweaker: {
                label: NLSUtils.translate('Color Map'),
                typePath: 'enumValueToProperty',
                semantics: {
                    possibleValues: function() {
                        var values = {};

                        var maps = GLOBAL.DS.RAObjects.dataMaps.linearColorMaps;
                        var map;

                        for (var key in maps) {
                            map = maps[key];
                            values[map.guid] = map.displayName;
                        }

                        return values;
                    }
                }
            }
        },
        defaultColor: {
            toggleAttribute: { attribute: 'type', value: 'fixed' }
        },
        type: {
            'default': 'fixed',
            tweaker: {
                label: NLSUtils.translate('Type'),
                typePath: 'enumValueToProperty',
                semantics: {
                    possibleValues: {
                        fixed: NLSUtils.translate('Fixed'),
                        byData: NLSUtils.translate('By Data'),
                        bySeries: NLSUtils.translate('By Series')
                    }
                }
            }
        }
    };
    
    var colorParamSettings = {
        type: {
            'default': 'aggregation',
            toggleAttribute: { attribute: 'type', value: 'byData' }
        },
        guid: { toggleAttribute: { attribute: 'type', value: 'byData' } },
        aggregationType: {
            toggleAttribute: { attribute: 'type', value: 'byData' }
        },
        fixedColor: {
            'default': '#ff000',
            tweaker: { typePath: 'color', label: NLSUtils.translate('Color') },
            toggleAttribute: { attribute: 'type', value: 'fixed' }
        }
    };
    
    var colorOptions = {
        name: 'color',
        attributes: colorParamAttributes,
        settings: colorParamSettings,
        attributeObjects: {}
    };

    var colorParamTemplate = new ChartParameterTemplate(
        colorOptions,
        chartParameterLibrary
    );

    var binnedNumericColorAttributes = {};
    var binnedNumericColorSettings = {
        minFilterPercent: {
            'default': 0,
            toggleAttribute: { attribute: 'type', value: 'byData' }
        },
        maxFilterPercent: {
            'default': 100,
            toggleAttribute: { attribute: 'type', value: 'byData' }
        },
        aggregationType: {
            'default': 'MEAN',
            toggleAttribute: { attribute: 'type', value: 'byData' }
        }
    };
    var binnedNumericColorOptions = {
        name: 'binnedNumericColor',
        attributes: binnedNumericColorAttributes,
        settings: binnedNumericColorSettings,
        attributeObjects: {}
    };
    var binnedNumericColorTemplate = new ChartParameterTemplate(
        binnedNumericColorOptions,
        chartParameterLibrary
    );
    binnedNumericColorTemplate.extends([colorParamTemplate]);

    var binnedDiscreteColorParamAttributes = {};
    var binnedDiscreteColorParamSettings = {
        discreteValues: {
            'default': [],
            toggleAttribute: { attribute: 'type', value: 'byData' }
        },
        aggregationType: {
            'default': 'FIRST',
            toggleAttribute: { attribute: 'type', value: 'byData' }
        }
    };
    var binnedDiscreteColorOptions = {
        name: 'binnedDiscreteColor',
        attributes: binnedDiscreteColorParamAttributes,
        settings: binnedDiscreteColorParamSettings,
        attributeObjects: {}
    };

    var binnedDiscreteColorTemplate = new ChartParameterTemplate(
        binnedDiscreteColorOptions,
        chartParameterLibrary
    );
    binnedDiscreteColorTemplate.extends([colorParamTemplate]);

    var discreteColorAttributes = {};
    var discreteColorSettings = {
        type: {
            'default': 'binnedDiscrete',
            toggleAttribute: { attribute: 'type', value: 'byData' }
        },
        discreteValues: {
            'default': [],
            toggleAttribute: { attribute: 'type', value: 'byData' }
        }
    };
    var discreteColorOptions = {
        name: 'discreteColor',
        attributes: discreteColorAttributes,
        settings: discreteColorSettings,
        attributeObjects: {}
    };

    var discreteColorTemplate = new ChartParameterTemplate(
        discreteColorOptions,
        chartParameterLibrary
    );
    discreteColorTemplate.extends([colorParamTemplate]);

    var rawColorAttributes = {};
    var rawColorSettings = {
        type: {
            'default': 'raw',
            toggleAttribute: { attribute: 'type', value: 'byData' }
        },
        minFilterPercent: {
            'default': 0,
            toggleAttribute: { attribute: 'type', value: 'byData' }
        },
        maxFilterPercent: {
            'default': 100,
            toggleAttribute: { attribute: 'type', value: 'byData' }
        }
    };
    var rawColorOptions = {
        name: 'rawColor',
        attributes: rawColorAttributes,
        settings: rawColorSettings,
        attributeObjects: {}
    };

    var rawColorTemplate = new ChartParameterTemplate(
        rawColorOptions,
        chartParameterLibrary
    );
    rawColorTemplate.extends([colorParamTemplate]);
    
    var constraintLineAttributes = {
    	visible: {
    		'default' : true
    	},
    	color : {
    		'default' : '#FF0000',
    		tweaker: { typePath: 'color', label: NLSUtils.translate('Color') },
    	},
    	width : {
    		'default' : 1
    	},
    	style : {
    		'default' : 'solid'
    	}
    };
    var constraintLineAOs = {};
    var constraintLineTemplate = new AttributeObjectTemplate(
    		'constraintLine',
    		NLSUtils.translate('Line'),
    		constraintLineAttributes,
    		constraintLineAOs,
    		chartParameterLibrary);
    
    var constraintSurfaceAttributes = {
    	opacity : {
    		'default' : 1,
    		tweaker: {
                typePath: 'numberslider',
                label: NLSUtils.translate('Opacity'),
                displayStyle: 'slider',
                semantics: {
                    displayStyle: 'slider',
                    minValue: 0,
                    maxValue: 1
                }
            }
    	},
    	color : {
    		'default' : '#FF3333',
    		tweaker: { typePath: 'color', label: NLSUtils.translate('Color') },
    	}
    };
    var constraintSurfaceAOs = {};
    var constraintSurfaceTemplate = new AttributeObjectTemplate(
    		'constraintSurface',
    		NLSUtils.translate('Surface'),
    		constraintSurfaceAttributes,
    		constraintSurfaceAOs,
    		chartParameterLibrary);

    var constraintAttributes = {
    	guid : {},
    	parameterId : {},
    	type : {}
    };
    var constraintSettings = {};

    var constraintAOs = {
    	line : 'constraintLine',
    	surface : 'constraintSurface'
    };
    
    var constraintOptions = {
    	name: 'constraint',
    	attributes: constraintAttributes,
    	settings: constraintSettings,
    	attributeObjects : constraintAOs
    };
    var constraintTemplate = new ChartParameterTemplate(
    		constraintOptions,
    		chartParameterLibrary
    );
    
    /*
     * "data":{
							"guid":"8eaffe9d-1f66-46d9-8ce6-9ca5605c68c0",
							"type":"raw",
							"minFilterPercent":"0",
							"maxFilterPercent":"100"
						},
						"dataMap":"myLocalSizeMap",
						"baseSize":10
     */
    
    //GLOBAL.DS.RAObjects.dataMaps.sizeMaps;
    
    var defaultSizeMap = DS.RAObjects.dataMaps.sizeMaps[0];
    
    var sizeTemplate = new ChartParameterTemplate({
    	name: 'size',
    	attributes : {
    		'baseSize' : {
    			'default' : 10
    		},
    		'dataMap' : {
    			'default' : defaultSizeMap.guid, 
    			//NOTE: Defaults to the first sisze map.
    			tweaker: {
                    label: NLSUtils.translate('Size Map'),
                    typePath: 'enumValueToProperty',
                    semantics: {
                        possibleValues: function() {
                            var values = {};

                            var maps = GLOBAL.DS.RAObjects.dataMaps.sizeMaps;
                            var map;

                            for (var i = 0; i < maps.length; i++) {
                                map = maps[i];
                                values[map.guid] = map.displayName;
                            }

                            return values;
                        }
                    }
                }
    		}
    	},
    	settings : {
    		'guid' : {},
    		'type' : {
    			'default' : 'raw'
    		},
    		'minFilterPercent' : {
    			'default' : 0,
    			toggleAttribute: { attribute: 'type', value: 'raw' }
    		},
    		'maxFilterPercent' : {
    			'default' : 100,
    			toggleAttribute: { attribute: 'type', value: 'raw' }
    		}
    	},
    	attributeObjects : {},
    }, chartParameterLibrary);
    
    var shapeTemplate = new ChartParameterTemplate({
    	name: 'shape',
    	attributes : {
    		'dataMap' : {
    		}
    	},
    	settings : {
    		'guid' : {},
    		'type' : {
    			'default' : 'raw'
    		},
    		'minFilterPercent' : {
    			'default' : 0,
    			toggleAttribute: { attribute: 'type', value: 'raw' }
    		},
    		'maxFilterPercent' : {
    			'default' : 100,
    			toggleAttribute: { attribute: 'type', value: 'raw' }
    		}
    	},
    	attributeObjects : {},
    }, chartParameterLibrary);
    
    var defaultShapeMap = GLOBAL.DS.RAObjects.dataMaps.binnedShapeMaps[0];
    var defaultShapeMapID = defaultShapeMap ? defaultShapeMap.guid:undefined;
    
    var binnedShapeTemplate = new ChartParameterTemplate({
    	name: 'binnedShape',
    	attributes : {
    		'dataMap' : {
    			tweaker: {
                    label: NLSUtils.translate('Shape Map'),
                    'default' : defaultShapeMap,
                    typePath: 'enumValueToProperty',
                    semantics: {
                        possibleValues: function() {
                            var values = {};

                            var maps = GLOBAL.DS.RAObjects.dataMaps.binnedShapeMaps;
                            var map;

                            for (var i = 0; i < maps.length; i++) {
                                map = maps[i];
                                values[map.guid] = map.displayName;
                            }

                            return values;
                        }
                    }
                }
    		}
    	},
    	settings : {},
    	attributeObjects : {},
    }, chartParameterLibrary);
    binnedShapeTemplate.extends(shapeTemplate);
    
    var discreteShapeTemplate = new ChartParameterTemplate({
    	name: 'discreteShape',
    	attributes : {
    		'dataMap' : {
    			'default' : DS.RAObjects.dataMaps.discreteShapeMaps[0].guid, 
    			//NOTE: Defaults to the first shape map.
    			tweaker: {
                    label: NLSUtils.translate('Shape Map'),
                    typePath: 'enumValueToProperty',
                    semantics: {
                        possibleValues: function() {
                            var values = {};

                            var maps = GLOBAL.DS.RAObjects.dataMaps.discreteShapeMaps;
                            var map;

                            for (var key in maps) {
                                map = maps[key];
                                values[map.guid] = map.displayName;
                            }

                            return values;
                        }
                    }
                }
    		}
    	},
    	settings : {},
    	attributeObjects : {},
    }, chartParameterLibrary);
    discreteShapeTemplate.extends(shapeTemplate);
    
    var labelTemplate = new ChartParameterTemplate({
    	name: 'label',
    	attributes : {
    	},
    	settings : {
    		'guid' : {},
    		'type' : {
    			'default' : 'raw'
    		}
    	},
    	attributeObjects : {},
    }, chartParameterLibrary);
})(this);
