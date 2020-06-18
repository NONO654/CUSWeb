
/**
 * @module SMAProcWebDoeTechniquesBase/SMAProcDesignDriverDataHandler
 */
define('SMAProcWebDoeTechniquesBase/SMAProcDesignDriverDataHandler', ['DS/JSCMM/SMAJSCMMProperty', 'DS/SMAProcWebCMMUtils/SMAJSCMMUtils'],
        function(SMAJSCMMProperty, SMAJSCMMUtils) {

    'use strict';
    /**
    * SMAProcDesignDriverFactorImpl provides the basic computation methods for various techniques of DOE
    * @memberof module:SMAProcWebDoeTechniquesBase/SMAProcDesignDriverDataHandler
    */
    var SMAProcDesignDriverDataHandler = {
            /**
             * DOE definition XML - Factors
             * This function creates a corresponding properties object
             * based on the factor attributes
             * @example
             *             <Property name = "Design Parameters" type = "aggregate">
             *                    <Property name = "Response" type = "aggregate">
             *                        <Property name = "Response 0" type = "aggregate">
             *                            <Property name = "Name">
             *                                <Value>c</Value>
             *                            </Property>
             *                            <Property name = "Attributes" type = "aggregate">
             *                                <Property name = "Objective">
             *                                    <Value>target</Value>
             *                                </Property>
             *                                <Property name = "Weight" type = "real">
             *                                    <Value>60</Value>
             *                                </Property>
             *                                <Property name = "Target" type = "real">
             *                                    <Value>100</Value>
             *                                </Property>
             *                            </Property>
             *                        </Property>
             *                        <Property name = "Response 1" type = "aggregate">
             *                            <Property name = "Name">
             *                                <Value>z</Value>
             *                            </Property>
             *                            <Property name = "Attributes" type = "aggregate">
             *                                <Property name = "Objective">
             *                                    <Value>minimize</Value>
             *                                </Property>
             *                                <Property name = "Weight" type = "real">
             *                                    <Value>500</Value>
             *                                </Property>
             *                            </Property>
             *                        </Property>
             *                    </Property>
             *            <Property name = "Factor" type = "aggregate">
             *                  <Property name="Factor 0" type="aggregate">
             *                 <Property name="Name">
             *                    <Value>Parameter1</Value>
             *                 </Property>
             *                 <Property name="Attributes" type="aggregate">
             *                    <Property name="Lower">
             *                       <Value>-25</Value>
             *                    </Property>
             *                    <Property name="Upper">
             *                       <Value>25</Value>
             *                    </Property>
             *                    <Property name="Relation">
             *                       <Value>values</Value>
             *                    </Property>
             *                    <Property name="Baseline">
             *                       <Value>0.0</Value>
             *                    </Property>
             *                 </Property>
             *                  </Property>
             *           </Property>
             *
             *           SMAProcDesignDriverDataHandler.buildDesignParametersProperty(factors, responses);
             *
             * @returns {Array} - Properties array for factors and responses
             */

            buildDesignParametersProperty: function (factors, responses) {
                var designParametersProp = new SMAJSCMMProperty();
                designParametersProp.setName('Design Parameters');
                designParametersProp.setStructure(SMAJSCMMUtils.Structure.client.Aggregate);

                if (this.isEmpty(factors) && this.isEmpty(responses)) {
                    return null;
                }

                if (!this.isEmpty(factors)) {
                    var factorProp = this.buildAttributeProperty(factors, 'Factor');
                    designParametersProp.addProperty(factorProp);
                }

                if (!this.isEmpty(responses)) {
                    var responseProp = this.buildAttributeProperty(responses, 'Response');
                    designParametersProp.addProperty(responseProp);
                }

                return designParametersProp;
            },

            /**
             * Builds the attribute property from the given parameters
             * @param {Array} params - An array of the factors/responses parameters for DOE techniques
             * @param {String} key - Factor or Response string
             * @returns {Object} - An aggregate property or [SMAJSCMMProperty]{@link module:DS/JSCMM/SMAJSCMMProperty.SMAJSCMMProperty} object
             */
            buildAttributeProperty: function (params, key) {
                var factorProp = new SMAJSCMMProperty();
                factorProp.setName(key);
                factorProp.setStructure(SMAJSCMMUtils.Structure.client.Aggregate);

                for (var i = 0; i < params.length; i++){
                    //Factor xx property
                    var factorNumberProp = new SMAJSCMMProperty();
                    factorNumberProp.setName(key+ ' ' + i);
                    factorNumberProp.setStructure(SMAJSCMMUtils.Structure.client.Aggregate);

                    //Attributes of the params
                    var attributeProperty = new SMAJSCMMProperty();
                    attributeProperty.setName('Attributes');
                    attributeProperty.setStructure(SMAJSCMMUtils.Structure.client.Aggregate);

                    // Property structure specific to techniques for the factor attributes
                    for (var attribute in params[i]) {
                        if (attribute === 'Name') {
                            //Name of the parameter property
                            var paramProperty = new SMAJSCMMProperty();
                            paramProperty.setName(attribute);
                            paramProperty.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
                            paramProperty.setValue(params[i][attribute]);
                        } else if (attribute !== 'cellinfo'){
                            var tempProperty;
                            if (attribute !== 'Expression') {
                                tempProperty = new SMAJSCMMProperty();
                                tempProperty.setName(attribute);
                                tempProperty.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
                                tempProperty.setValue(params[i][attribute]);
                            }

                            if (params[i]['Expression'] && attribute in params[i]['Expression']) {
                                var expression = params[i]['Expression'][attribute] ? params[i]['Expression'][attribute] : '';
                                tempProperty.setExpression(expression);
                            }
                            if (attribute === 'Weight' || attribute === 'Target')
                                { tempProperty.setDataType(SMAJSCMMUtils.DataType.client.Real); }
                            if (attribute === '# Levels')
                                { tempProperty.setDataType(SMAJSCMMUtils.DataType.client.Integer); }
                            if (attribute !== 'Expression') {
                                 attributeProperty.addProperty(tempProperty);
                            }
                        }
                    }

                    var factorPropArray = [];
                    factorPropArray.push(paramProperty);
                    factorPropArray.push(attributeProperty);
                    factorNumberProp.setProperties(factorPropArray);

                    factorProp.addProperty(factorNumberProp);

                }
                return factorProp;
            },

            /**
             * Returns true or false if the object is empty or not
             * @param {Object} obj object to test
             * @return {Boolean} - True if the object is empty
             */
            isEmpty: function (obj) {
                return Object.keys(obj).length === 0;
            },

             /**
             * Creates a plugin name property, it simply adds "DOE Technique" as the value,
             * this property needs to be added to technique configuration.
             * @returns {SMAJSCMMProperty} property
             */
            createPluginNameProperty: function () {
                var pluginNameProp = new SMAJSCMMProperty();
                pluginNameProp.setName('PluginName');
                pluginNameProp.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
                pluginNameProp.setValue('DOE Technique');
                return pluginNameProp;
            },

            /**
             * Builds the execution options property for DOE adapter
             * @param {Object} executionOptions - Key value pairs for the execution options
             * @returns {Object} - An aggregate property or [SMAJSCMMProperty]{@link module:DS/JSCMM/SMAJSCMMProperty.SMAJSCMMProperty} object
             */
            buildExecutionOptionsProperty: function (executionOptions) {
                var execOptionsProp = new SMAJSCMMProperty();
                execOptionsProp.setName('Execution Options');
                execOptionsProp.setStructure(SMAJSCMMUtils.Structure.client.Aggregate);

                for (var attribute in executionOptions) {
                    var tempProperty = new SMAJSCMMProperty();
                    tempProperty.setName(attribute);
                    tempProperty.setStructure(SMAJSCMMUtils.Structure.client.Scalar);
                    if (attribute === 'execute subflow once' || attribute === 'parallel' || attribute === 'update baselines') {
                        tempProperty.setDataType(SMAJSCMMUtils.DataType.client.Boolean);
                        tempProperty.setValue(executionOptions[attribute]);
                        if (executionOptions['Expression'] && executionOptions['Expression'][attribute]) {
                            tempProperty.setExpression(executionOptions['Expression'][attribute]);
                        }
                    }
                    if (attribute === 'failed runs policy' || attribute === 'retry number') {
                        tempProperty.setDataType(SMAJSCMMUtils.DataType.client.Integer);
                        tempProperty.setValue(isNaN(executionOptions[attribute])? 0:executionOptions[attribute]);
                    }
                    if (attribute === 'replace pct') {
                        tempProperty.setDataType(SMAJSCMMUtils.DataType.client.Real);
                        tempProperty.setValue(isNaN(executionOptions[attribute])? 0:executionOptions[attribute]);
                    }
                    execOptionsProp.addProperty(tempProperty);
                }

                return execOptionsProp;
            },

            /**
             * Parses the design parameters from the definition and populates the valid facotrs/responses if the factor/response is an activity (containing DOE) parameter
             * @param {Object} designParameters - An aggregate property or [SMAJSCMMProperty]{@link module:DS/JSCMM/SMAJSCMMProperty.SMAJSCMMProperty} object
             * @param {Array}  activityParameters - Parameters on the activity
             * @param {Object}  activity - [SMAJSCMMActivity]{@link module:DS/JSCMM/SMAJSCMMActivity} object
             * @param {Object} factorsObj - Object containing factors
             * @param {Object} responsesObj - Object containing responses
             */
            parseDesignParametersProperty: function(designParameters, activityParameters, activity, factorsObj, responsesObj) {
                var factors;
                for (var i = 0; i < designParameters.getProperties().length; i++) {
                    if (designParameters.getProperties()[i].getName() === 'Factor') {
                        factors = designParameters.getProperties()[i].getProperties();
                        this.parseAttributesProperty(factors, activityParameters, activity, factorsObj);
                    }
                    if (designParameters.getProperties()[i].getName() === 'Response') {
                        var responses = designParameters.getProperties()[i].getProperties();
                        this.parseAttributesProperty(responses, activityParameters, activity, responsesObj);
                    }
                }

            },

            /**
             * Parses the factor for its various attributes
             * @param {Array} params - An array or factors/responses to be parsed
             * @param {Array}  activityParameters - Parameters on the activity
             * @param {Object}  activity - [SMAJSCMMActivity]{@link module:DS/JSCMM/SMAJSCMMActivity} object
             * @param {Object} paramObj - Object containing factors/responses
             */
            parseAttributesProperty: function (params, activityParameters, activity, paramObj) {
                var factorPropArray;
                for (var j = 0; j < params.length; j++) {
                    factorPropArray = {};
                    var propNameAttributes = params[j].getProperties();
                    var paramName = propNameAttributes[0].getValue();
                    //TODO: Will need to fix this once we know how to identify if the property is array element or not
                    if (paramName.indexOf('[') > -1) {
                        paramName = paramName.substring(0, paramName.indexOf('['));
                    }
                    var param = this.findParameterByName(paramName, activityParameters);
                    if (param !== undefined && param !== null
                            && param.getParent() === activity) {
                        factorPropArray[propNameAttributes[0].getName()] = propNameAttributes[0].getValue();
                        if (propNameAttributes[1].getName() === 'Attributes') {
                            var attributes = propNameAttributes[1].getProperties();
                            for (var i = 0; i < attributes.length; i++) {
                                factorPropArray[attributes[i].getName()] = attributes[i].getValue();
                                //Expressions for parameter mapping
                                if (attributes[i].getExpression() !== undefined && attributes[i].getExpression() !== '') {
                                    if (factorPropArray['Expression'] === undefined) {
                                        factorPropArray['Expression'] = {};
                                    }
                                    factorPropArray['Expression'][attributes[i].getName()] = attributes[i].getExpression();
                                }
                            }
                        }
                        paramObj.push(factorPropArray);
                    }
                }

            },

            /**
             * Looks up the parameter object within the activity parameters given the name.
             * @param {String} paramName - Name of the parameter to be looked up
             * @param {String[]} activityParameters - array of parameters
             * @returns parameter if found, null otherwise
             */
            findParameterByName: function(paramName, activityParameters) {
                for (var i = 0; i < activityParameters.length; i++) {
                    if (paramName === activityParameters[i].getName()) {
                        return activityParameters[i];
                    }
                }
                return null;
            }
    };

    return SMAProcDesignDriverDataHandler;
});
