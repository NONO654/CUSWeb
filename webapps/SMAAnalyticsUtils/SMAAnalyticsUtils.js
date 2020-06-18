/*global define */
/**
 * This module does formula evaluation for the Results Analytics
 * Explore page. This module exports three functions:
 * SMAAnalyticsFormulaData: constructor
 * prepareFormula(formula): Check the formula for syntactic and semantic
 *                          consistency
 * computeRowValue: Compute the value of the formula for a specific row
 *
 * This module is designed to be Promise free.
 *
 */
define(
    'DS/SMAAnalyticsUtils/SMAAnalyticsFormulaData',
    [
        'DS/SMAAnalyticsUI/SMAAnalyticsProxy',
        'DS/JSCMM/SMAJSCMMFactory',
        'DS/SMAProcWebCMMCalculator/SMAProcWebCMMCalcNamespace',
        // 'DS/SMAProcWebCMMCalculator/SMAProcWebCMMCalcEvaluator',
        // 'DS/SMAProcWebCMMCalculator/SMAProcWebCMMCalcParser',
        // 'DS/SMAProcWebCMMCalculator/SMAProcWebCMMCalcTokenizer',
        'DS/SMAProcWebCMMCalculator/Parser/SMAProcWebCMMEval',
        'DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils'
    ],
    function(
        proxy,
        SMAJSCMMFactory,
        SMAProcWebCMMCalcNamespace,
        // SMAProcWebCMMCalcEvaluator,
        // SMAProcWebCMMCalcParser,
        // SMAProcWebCMMCalcTokenizer,
        SMAProcWebCMMEval,
        NLSUtils
    ) {
        'use strict';
        var extendNames = window.localStorage.getItem(
            'RA_EXPERIMENTAL_EXTEND_NAMES'
        );
        extendNames = extendNames === undefined ? false : extendNames === '1';
        /************************************************************
         *
         * Constructor of a formulaData Object.
         * @param {string} formula - Formula to evaluate (optional)
         * @param {function} collectChange - Function to call to record
         *                   the changed value
         *
         ***********************************************************/
        function SMAAnalyticsFormulaData(formula, collectChange) {
            this.reset();
            if (formula !== 'undefined') {
                this.prepareFormula(formula);
            }
            if (collectChange === undefined) {
                collectChange = function() {};
            }
            this.collectChange = collectChange;
        }

        SMAAnalyticsFormulaData.prototype = {
            constructor: SMAAnalyticsFormulaData,

            /************************************************************
             *
             * Initialize the fields of the formulaData object
             *
             ***********************************************************/
            reset: function() {
                this.allParameterIds = [];
                this.cmmParams = [];
                this.collectChange = function() {};
                this.formula = '';
                this.nameSpace = SMAProcWebCMMCalcNamespace.getNamespace();
                this.newColumnCmmParam = undefined;
                this.newColumnName = '';
                this.newDisplayName = '';
                this.paramsById = {};
                this.parseTreeArray = [];
                this.usedParameterIdMap = {};
                this.usedParameterIds = [];
            },

            /************************************************************
             *
             * Populate the parameters for one row and compute the value
             * Modifies cmmParams entries values.
             * @param {Object} thisRow - Object holding array of param values
             * @returns {array} List of computed values - should be a singleton
             *
             ***********************************************************/
            computeRowValue: function(thisRow) {

                var inputTextStr = this.formula;
                var calcValue, value = false;

                if (inputTextStr.length === 0) {
                    throw Error(NLSUtils.translate(
                        'no_expression available to evaluate'));
                }

                for (var columnId in this.usedParameterIdMap) {
                    if (this.usedParameterIdMap.hasOwnProperty(columnId)) {
                        var cmmParam = this.usedParameterIdMap[columnId];
                        var newValue = thisRow.parmValues[columnId];
                        if (Array.isArray(newValue)) {
                            for (var idx = 0; idx < newValue.length; idx += 1) {
                                cmmParam.setValue(newValue[idx], idx);
                            }
                        } else {
                            cmmParam.setValue(newValue);
                        }
                    }
                }

                try {
                    calcValue = SMAProcWebCMMEval.evaluate(inputTextStr, this.nameSpace.getParameters(), null, {
                        onlyLogicalExpression: true,
                        restrictUndeclaredParameter: false
                    }).result;
                    
                    value = calcValue.output;
                } catch (err) {
                    // ignore ?
                }
                this.collectChange(thisRow, value);

                return value;

                // var calcValue;
                // if (this.parseTreeArray.length === 0) {
                //     throw Error(
                //         NLSUtils.translate(
                //             'no_expression available to evaluate'
                //         )
                //     );
                // }

                // for (var columnId in this.usedParameterIdMap) {
                //     if (this.usedParameterIdMap.hasOwnProperty(columnId)) {
                //         var cmmParam = this.usedParameterIdMap[columnId];
                //         var newValue = thisRow.parmValues[columnId];
                //         if (Array.isArray(newValue)) {
                //             for (var idx = 0; idx < newValue.length; idx += 1) {
                //                 cmmParam.setValue(newValue[idx], idx);
                //             }
                //         } else {
                //             cmmParam.setValue(newValue);
                //         }
                //     }
                // }
                // calcValue = SMAProcWebCMMCalcEvaluator.Evaluate(
                //     this.parseTreeArray
                // );

                // var value = calcValue[0].getValue();
                // this.collectChange(thisRow, value);
                // return value;
            },

            /************************************************************
             *
             * Create a CMM Format parameter
             * @param {string} name - Parameter name
             * @param {string} displayName - Name with spaces
             * @param {string} type - Parameter type
             * @param {string} mode - Parameter mode
             * @param {string} id - Unique ID
             * @param {string} structure - array/scalar indication
             * @param {string} dims - Space-separted list of dimensions
             * @return {Object} CMMParameter object
             *
             ***********************************************************/
            _createCMMParameter: function(
                name,
                displayName,
                type,
                mode,
                id,
                structure,
                dims
            ) {
                var element = {
                    dataelements: {
                        arraydim: {
                            value: [{ value: dims }]
                        },
                        name: {
                            value: [{ value: name }]
                        },
                        displayName: {
                            value: [{ value: displayName }]
                        },
                        type: {
                            value: [
                                {
                                    value: type
                                }
                            ]
                        },
                        valuetype: {
                            value: [
                                {
                                    value: structure
                                }
                            ]
                        },
                        mode: {
                            value: [
                                {
                                    value: mode
                                }
                            ]
                        }
                    },
                    objectId: id
                };
                var cmmParam = SMAJSCMMFactory.createParameter(element);
                cmmParam.setDisplayName(displayName);
                if (type === undefined) {
                    // Constructor defaults to string - reset to undefined
                    cmmParam.setDataType(-1);
                }
                return cmmParam;
            },

            /************************************************************
             *
             * Construct a parameter list for the calculator
             * @param {array} parameterIds - List of parameter ids
             * @param {array} cmmParams - Out - List of CMM format parameters
             * @param {hash} paramsById - map from id to CMM parameter
             * @param {string} newColumnName - normalized LHS name
             * @param {string} newDisplayName - LHS name
             *
             ***********************************************************/
            _makeCMMParams: function(
                parameterIds,
                cmmParams,
                paramsById,
                newColumnName,
                newDisplayName
            ) {
                /* Construct the JSON Structure
                           Going from a DataSetVariable
                               ID:
                               dataType: REAL/
                               dimensions: null
                               displayName: "City MPG"
                               name: "City%20MPG"
                               parents:
                               role: UNKNOWN/
                               structure: SCALAR

                           To a hash to construct a SMAJSCMMParameter
                               {dataelements
                                   valuetype
                                       'array' |
                                   displayName
                                       value
                                   name
                                       value
                                   type
                                       value: real/integer/boolean/string/timestamp
                                   mode
                                       value: input/output/both/neutral
                                   Value
                                       value
                                   choices
                                       value (list)
                               objectId
                               }
                         */

                for (var i = 0; i < parameterIds.length; i++) {
                    var parameterId = parameterIds[i];
                    var param = proxy.findParameter(parameterId);
                    var paramName;
                    if (extendNames) {
                        var nameList = param.parents.parentList.concat([
                            param.displayName
                        ]);
                        paramName = nameList.join('.');
                    } else {
                        paramName = param.displayName;
                    }
                    if (paramName === newColumnName) {
                        var message =
                            NLSUtils.translate('new_column') +
                            ': ' +
                            newDisplayName;
                        throw new Error(message);
                    }
                    var structure = undefined;
                    var dims = undefined;
                    if (param.structure === 'ARRAY') {
                        structure = 'array';
                        dims = param.dimensions.join(' ');
                    }
                    var cmmParam = this._createCMMParameter(
                        paramName,
                        paramName,
                        param.dataType.toLowerCase(),
                        'unknown',
                        param.ID,
                        structure,
                        dims
                    );
                    cmmParams.push(cmmParam);
                    paramsById[parameterId] = cmmParam;
                }
            },

            /************************************************************
             *
             * Tokenize and parse the formula and verify the parameters
             *
             ***********************************************************/
            // _validateFormula: function() {
            //     var tokensArray = [];
            //     var parseTreeArray = [];

            //     // Pass the string through lexer
            //     // collect warning/error from Lexer
            //     var inputTextStr = this.formula;
            //     tokensArray = SMAProcWebCMMCalcTokenizer.Tokenize(inputTextStr);

            //     // Pass the string through Parser
            //     // collect warning/error from Parser
            //     // Visit all the nodes and crreate parameters
            //     parseTreeArray = SMAProcWebCMMCalcParser.Parse(tokensArray);
            //     this.parseTreeArray = parseTreeArray;
            //     if (parseTreeArray.length !== 1) {
            //         var msg = NLSUtils.translate('simple_assign');
            //         var e = new Error(msg);
            //         throw e;
            //     }

            //     this.nameSpace.setParameters(this.cmmParams);
            //     var outVars = [];
            //     outVars = SMAProcWebCMMCalcEvaluator.ProcessParseTreeForParameters(
            //         parseTreeArray
            //     );

            //     var usedParams = this.usedParameterIds;
            //     var usedParamMap = this.usedParameterIdMap;
            //     var allParams = this.paramsById;
            //     for (var i = 0; i < outVars.length; i++) {
            //         var out = outVars[i];
            //         if (out.ref) {
            //             var thisId = out.ref._id;
            //             usedParams.push(thisId);
            //             usedParamMap[thisId] = out.ref;
            //         } else {
            //             if (out.name === this.newDisplayName) {
            //                 out.ref = this._createCMMParameter(
            //                     out.name,
            //                     this.newDisplayName,
            //                     undefined,
            //                     'unknown',
            //                     ''
            //                 );
            //                 this.newColumnCmmParam = out.ref;
            //                 this.nameSpace.addParameter(out.ref);
            //             } else {
            //                 var ex = new Error(
            //                     NLSUtils.translate('undefined_parameter') +
            //                         ': ' +
            //                         out.name
            //                 );
            //                 throw ex;
            //             }
            //         }
            //     }
            //     this.parseTreeArray = parseTreeArray;
            // },

            /************************************************************
             *
             * Prepare for evaluating the formula
             * @param {string} formula - formula to be evaluated
             *
             ***********************************************************/
            prepareFormula: function(formula) {
                this.reset();
                //  Get the RA parameters
                this.allParameterIds = proxy.getAllParametersAsFlatList(
                    proxy.varGroup,
                    true
                );
                this.formula = formula;

                // Determine the name of the target data column.
                // Extract from the front of the expression
                var newColumnName = undefined;
                var newDisplayName = undefined;
                if (formula.test(/^\s*\w+\s*=/)) {
                    newColumnName = formula.
                        replace(/^\s+/, '').
                        replace(/\s*=.*$/, '');
                    newDisplayName = newColumnName;
                } else if (
                    formula.test(/^\s*'\w[\w ]*\w'\s*=/) ||
                    formula.test(/^\s*'\w'\s*=/)
                ) {
                    newDisplayName = formula.
                        replace(/^\s*'/, '').
                        replace(/'\s*=.*$/, '');
                    newColumnName = newDisplayName;
                    while (newColumnName.test(/\s/)) {
                        newColumnName = newColumnName.replace(/\s/, '%20');
                    }
                }

                if (newColumnName === undefined || newColumnName === '') {
                    throw new Error(
                        NLSUtils.translate('no_target_name') + ': ' + formula
                    );
                }
                this.newColumnName = newColumnName;
                this.newDisplayName = newDisplayName;
                this._makeCMMParams(
                    this.allParameterIds,
                    this.cmmParams,
                    this.paramsById,
                    newColumnName,
                    newDisplayName
                );

                // this._validateFormula();
            }
        };
        return SMAAnalyticsFormulaData;
    }
);

/* global define */
/* global require */
define(
    'DS/SMAAnalyticsUtils/SMAAnalyticsExpressionEvaluator',
    [
        'DS/SMAProcWebCommonControls/Polymer',
        'DS/SMAProcWebCommonControls/utils',
        'DS/JSCMM/SMAJSCMMFactory',
        'DS/SMAProcWebCMMUtils/SMAJSCMMParameterUtils',
        'DS/SMAProcWebCMMUtils/SMAJSCMMUtils',
        'DS/SMAProcWebCMMCalculator/SMAProcWebCMMCalc',
        'DS/SMAProcWebCommonControls/ext/aceBehavior',
        'text!DS/SMAAnalyticsUtils/SMAAnalyticsExpressionEvaluator.html',
        'DS/SMAProcWebCommonControls/Editor'
    ],
    function(
        Polymer,
        controlsUtils,
        SMAJSCMMFactory,
        SMAJSCMMParameterUtils,
        SMAJSCMMUtils,
        SMAProcWebCMMCalc,
        aceBehavior,
        template
    ) {
        'use strict';
        controlsUtils.registerDomModule(template);

        return Polymer({
            is: 'ra-expression-eval',
            properties: {
                expression: {
                    type: String,
                    notify: true
                },

                slider: {
                    type: String,
                    notify: false
                },

                message: {
                    type: String,
                    notify: false
                }
            },

            listeners: {
                'calc.click': 'evaluate'
            },

            behaviors: [aceBehavior],

            ready: function() {
                if (this.expression) {
                    this.evaluate();
                }
            },

            evaluate: function() {
                var me = this;
                require([
                    'DS/SMAAnalyticsUtils/SMAAnalyticsFormulaUtils'
                ], function(formulaUtils) {
                    formulaUtils.onTryClick(me.expression, me.slider);
                });
            },

            __aceEditor: function() {
                return this.$.editor.__aceEditor();
            }
        });
    }
);

define('DS/SMAAnalyticsUtils/SMAAnalyticsParseUtils', [], function() {
    'use strict';
    function ParseUtils() {}
    ParseUtils.prototype = {
        // ====================================================================
        //
        // ====================================================================
        dependableReplaceAll: function(str1, pattern, replacement) {
            var newString = str1;
            var found = true;
            
            // helper function to clear out any meta characters that could blow up the regex 
            // found here: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions
            var escapeRegExp =function (str) {
                return str.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
            }
            
            while (found) {
            	// this was going extremely slow for large datasets
//              newString = newString.replace(pattern, replacement);
            	
            	// use a RegExp instead, with the global set to significantly improve performance
            	newString = newString.replace(new RegExp(escapeRegExp(pattern), 'g'), replacement);
            	
            	// leaving this here, but we may no longer need this at all (since the global option is set)
                found = newString.indexOf(pattern) > -1;
            }
            return newString;
        },
        // ====================================================================
        //
        // ====================================================================
        JSONparse: function(val) {
            // 'use strict';
            if (typeof val === 'string') {
                try {
                    return JSON.parse(val);
                } catch (e) {
                    // sd4 - potentially failing due to NaNs
                    // replace NaNs as nulls
                    var val_nonan = ParseUtils.prototype.dependableReplaceAll(
                        val,
                        'NaN',
                        '"null"'
                    );
                    try {
                        return JSON.parse(val_nonan);
                    } catch (e1) {
                        // sd4 - IR-445356 - next failure will be due to
                        // '-Infinity' this seems shady since there can be a
                        // string called "infinity" in the json.
                        var val_nonan_noninf = ParseUtils.prototype.dependableReplaceAll(
                            val_nonan,
                            '-Infinity',
                            '"null"'
                        );
                        try {
                            return JSON.parse(val_nonan_noninf);
                        } catch (e2) {
                            // sd4 - next failure will be due to 'Infinity'
                            var val_nonan_noninf_noinf = ParseUtils.prototype.dependableReplaceAll(
                                val_nonan_noninf,
                                'Infinity',
                                '"null"'
                            );
                            return JSON.parse(val_nonan_noninf_noinf);
                        }
                    }
                }
            } else {
                return val;
            }
        },
        // ====================================================================
        //
        // ====================================================================
        getJSONFromResponse: function(response) {
            // console.log(response);
            if (response instanceof String || typeof response === 'string') {
                return ParseUtils.prototype.JSONparse(response);
            }
            if (
                response instanceof Array &&
                response.length === 3 &&
                (response[0] instanceof Document ||
                    (response[2] &&
                        typeof response[2].responseText !== 'undefined'))
            ) {
                var jqXHR = response[2];
                if (jqXHR.responseText) {
                    try {
                        response[0] = ParseUtils.prototype.JSONparse(
                            jqXHR.responseText
                        );
                    } catch (e) {
                        console.error(
                            'Syntax error in parsing ' + jqXHR.responseText
                        );
                        if (e.stack) {
                            console.error(e.stack);
                        }
                        response[0] = jqXHR.responseText;
                    }
                } else if (jqXHR.responseXML) {
                    response[0] = jqXHR.responseXML;
                }
                return response[0];
            }
            return response;
        },

        //====================================================================
        //
        // ====================================================================
        overrideMethod: function(method, fn) {
            ParseUtils.prototype[method] = fn;
        }
    };
    return ParseUtils.prototype;
});

/* global define */

// Interface for attaching methods to non-core modules
// Used to pass things like
define('DS/SMAAnalyticsUtils/SMAAnalyticsInterface', [], function() {
    'use strict';
    function AdviseInterface(fns) {
        this.functions = {};

        var i;

        if (fns instanceof Array) {
            for (i = 0; i < fns.length; i++) {
                this.bind(fns[i].name, fns[i].fn);
            }
        } else {
            /* global console */
            console.log(
                'only array inputs are currently supported for interfaces.'
            );
        }

        this.bridge = null;

        // this.bridgeObj = new AdviseInterface(bridgeFns); //External
        // interface, used to communicate back to whatever the interface is being
        // passed to.
    }

    AdviseInterface.prototype.bind = function(string, fn) {
        // this is accessible from all bound functions, giving access to the
        // external interface
        this.functions[string] = fn;
    };

    AdviseInterface.prototype.execute = function(string, args) {
        if (typeof this.functions[string] === 'undefined') {
            return;
        }

        try {
            return this.functions[string].apply(this, args);
        } catch (e) {
            console.log('Interface error: could not execute ' + string);
            console.log('Error isnt handled yet.');
            // throw e;
        }
    };

    AdviseInterface.prototype.bindBridge = function(bridge) {
        this.bridge = bridge;
    };

    // Generalized bridge can now be any object. It should be called directly:
    // i.e. this.bridge.refreshTable

    return AdviseInterface;
});

/* global define */
/* global require */
define(
    'DS/SMAAnalyticsUtils/SMAAnalyticsTryParamRow',
    [
        'DS/SMAProcWebCommonControls/Polymer',
        'DS/SMAProcWebCommonControls/utils',
        'text!DS/SMAAnalyticsUtils/SMAAnalyticsTryParamRow.html'
    ],
    function(
        Polymer,
        controlsUtils,
        template
    ) {
        'use strict';
        var that;
        controlsUtils.registerDomModule(template);
        return Polymer({
            is: 'ra-try-param-row',
            properties: {
                param: {
                    type: String,
                    observer: '_onParamChange'
                },

                input: {
                    type: String,
                    observer: '_onInputChange'
                },

            },

            ready: function() {
                that = this;
            },
            
            _onParamChange: function(newVal, oldVal) {
                var td=this.$$('td.tryParam');
                td.textContent = newVal;
            },
            
            _onInputChange: function(newVal, oldVal) {
                var td=this.$$('td.tryInput');
                td.textContent = newVal;
            }


        });

    }
);

/*global define */
/*global Promise */
define(
    'DS/SMAAnalyticsUtils/SMAAnalyticsFormulaEval',
    [
        'DS/SMAAnalyticsUtils/SMAAnalyticsFormulaData',
        'DS/SMAAnalyticsUI/SMAAnalyticsJQuery',
        'DS/SMAAnalyticsUI/SMAAnalyticsUICommon',
        'DS/SMAAnalyticsUI/SMAAnalyticsProxy'
    ],
    function(SMAAnalyticsFormulaData, $simjq, UICommon, proxy) {
        'use strict';

        /************************************************************
         *
         * Make a Promise to find the values for a chunk of rows
         * @param {SMAAnalyticsFormulaData} formulaData - Formula object
         * @param {array} rowSet - list of row numbers
         * @param {array} changes - output array of changed row values
         * @returns {Promise} Promise to compute row values
         *
         ***********************************************************/
        function _makeRowPromise(formulaData, rowSet, changes) {
            var data = {};
            var rowPromise = proxy.
                getRowListInfo(rowSet, data, formulaData.usedParameterIds).
                then(function() {
                    try {
                        var elements = data.content.elements;
                        for (
                            var elementIdx = 0;
                            elementIdx < elements.length;
                            elementIdx += 1
                        ) {
                            var thisRow = elements[elementIdx];
                            formulaData.computeRowValue(thisRow);
                        }
                    } catch (exc) {
                        return Promise.reject(exc);
                    }
                    return undefined;
                });
            return rowPromise;
        }

        /************************************************************
         *
         * Construct and resolve Promises for several groups of
         * chunks at each recursion level, ultimately returning a Promise
         * to populate the column.
         * @param {SMAAnalyticsFormulaData} formulaData - Formula object
         * @param {Array} allGroups - Array of groups of array of chunks
         * @param {Integer} groupIdx - The current group index/recusion depth
         * @param {Array} changes - output array of changed row values
         * @returns {Promise} Promise to compute all entries for the new column
         *
         ***********************************************************/
        function _recurseThroughGroups(
            formulaData,
            allGroups,
            groupIdx,
            changes
        ) {
            var chunkPromises = [];

            var numGroups = allGroups.length;
            var chunks = allGroups[groupIdx];
            groupIdx += 1;

            for (var chunkIdx = 0; chunkIdx < chunks.length; chunkIdx += 1) {
                var thisChunk = chunks[chunkIdx];
                var rowSet = [];
                var base = thisChunk[0];
                var stop = thisChunk[1];
                for (var row = base; row <= stop; row += 1) {
                    rowSet.push(row);
                }

                chunkPromises.push(
                    _makeRowPromise(formulaData, rowSet, changes)
                );
            }
            return Promise.all(chunkPromises).
                then(function() {
                    if (groupIdx >= numGroups) {
                        return changes;
                    } else {
                        return _recurseThroughGroups(
                            formulaData,
                            allGroups,
                            groupIdx,
                            changes
                        );
                    }
                }).
                catch(function(exc) {
                    return Promise.reject(exc);
                });
        }

        /************************************************************
         *
         * Partition the rows into chunks
         * @param {integer} chunkSize - Size of chunk
         * @param {integer} start -  Base index of range
         * @param {integer} end  - End index of range
         * @returns {array} Array of range pairs
         *
         ***********************************************************/
        function _chunkRows(chunkSize, start, end) {
            var result = [];
            for (var low = start; low < end + 1; low += chunkSize) {
                var hi = Math.min(end, low + chunkSize - 1);
                var range = [low, hi];
                result.push(range);
            }
            return result;
        }

        var exports = {
            /************************************************************
             *
             * Make a Promise to find the values of row entries
             * @param {SMAAnalyticsFormulaData} formulaData - Formula object
             * @param {integer} baseRowId - Starting row to compute
             * @param {integer} endRowId - Ending row to compute
             * @returns {Promise} Promise to compute all entries for the new column
             *
             ***********************************************************/
            computeColumnValues: function(formulaData, baseRowId, endRowId) {
                var changes = {};

                var chunk = 10;
                var chunkGroup = 2;
                // Limit recursion depth
                var recursionLimit = 20;
                var numRows = endRowId - baseRowId + 1;
                if (numRows / chunk / chunkGroup > recursionLimit) {
                    chunk = Math.ceil(numRows / (recursionLimit * chunkGroup));
                }

                var groups = _chunkRows(
                    chunk * chunkGroup,
                    baseRowId,
                    endRowId
                );
                var chunkGroups = [];
                for (var idx = 0; idx < groups.length; idx += 1) {
                    var group = groups[idx];
                    var thisGroup = _chunkRows(chunk, group[0], group[1]);
                    chunkGroups.push(thisGroup);
                }

                var groupIdx = 0;
                try {
                    return _recurseThroughGroups(
                        formulaData,
                        chunkGroups,
                        groupIdx,
                        changes
                    );
                } catch (exc) {
                    return Promise.reject(exc);
                }
            },
            /************************************************************
             *
             * Compute the formula on a set of rows
             * @param {String} formula - Formula to be evaluated
             * @param {integer} baseRowId - First row to be evaluated
             * @param {integer} endRowId - Last row to be evaluated
             * @param {function} collectChange - Callback to record changed
             *                   value
             * @return {Promise} Evaluation promise
             *
             ***********************************************************/
            evalFormula: function(formula, baseRowId, endRowId, collectChange) {
                var formulaData;
                try {
                    formulaData = new SMAAnalyticsFormulaData(
                        formula,
                        collectChange
                    );
                } catch (exc) {
                    return Promise.reject(exc);
                }

                return this.computeColumnValues(
                    formulaData,
                    baseRowId,
                    endRowId
                ).catch(function(exc) {
                    return Promise.reject(exc);
                });
            }
        };

        return exports;
    }
);

/* global define */
define(
    'DS/SMAAnalyticsUtils/SMAAnalyticsExpressionEditor',
    [
        'DS/SMAProcWebCommonControls/Polymer',
        'DS/SMAProcWebCommonControls/utils',
        'DS/SMAProcWebCommonControls/ext/aceBehavior',
        'text!DS/SMAAnalyticsUtils/SMAAnalyticsExpressionEditor.html',
        'DS/SMAAnalyticsUtils/SMAAnalyticsExpressionEvaluator',
        'DS/SMAProcWebCommonControls/Editor',
        'DS/SMAProcWebCommonControls/ExpressionControls'
    ],
    function(Polymer, controlsUtils, aceBehavior, template) {
        'use strict';

        controlsUtils.registerDomModule(template);
        return Polymer({
            is: 'ra-expression-editor',
            properties: {
                expression: {
                    type: String
                },

                context: {
                    type: Object
                }
            },

            listeners: {
                onSelect: '_onSelect'
            },

            behaviors: [aceBehavior],

            ready: function() {},

            _onSelect: function(e) {
                this.insertAtCursorPosition(e.detail.value.name);
            },

            __aceEditor: function() {
                return this.$.editor.__aceEditor();
            }
        });
    }
);

/*global Promise */
/*global Worker */
/*global require */
/*global define */
//XSS_CHECKED
define(
    'DS/SMAAnalyticsUtils/SMAAnalyticsFormulaUtils',
    [
        'DS/SMAAnalyticsUtils/SMAAnalyticsFormulaData',
        'DS/SMAAnalyticsUtils/SMAAnalyticsFormulaEval',
        'DS/SMAAnalyticsUI/SMAAnalyticsJQuery',
        'DS/SMAAnalyticsUI/SMAAnalyticsUICommon',
        'DS/SMAAnalyticsUI/SMAAnalyticsProxy',
        'UWA/Core',
        'DS/Windows/ImmersiveFrame',
        'DS/Controls/ProgressBar',
        'DS/Windows/Dialog',
        'DS/Controls/Button',
        'DS/Controls/Slider',
        'DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils',
        // The following are not referenced in the script but are needed
        // by the constructed HTML.
        'DS/SMAProcWebCommonControls/Editor',
        'DS/SMAAnalyticsUtils/SMAAnalyticsExpressionEditor',
        'DS/SMAAnalyticsUtils/SMAAnalyticsTryParamRow'
    ],
    function(
        SMAAnalyticsFormulaData,
        SMAAnalyticsFormulaEval,
        $simjq,
        UICommon,
        proxy,
        UWA,
        WUXImmersiveFrame,
        WUXProgressBar,
        WUXDialog,
        WUXButton,
        WUXSlider,
        NLSUtils
    ) {
        'use strict';
        var myShopDataTable;
        var exports;

        var extendNames = window.localStorage.getItem(
            'RA_EXPERIMENTAL_EXTEND_NAMES'
        );
        extendNames = extendNames === undefined ? false : extendNames === '1';

        /************************************************************
         * Normalize an exception.
         * @param {(string|Error)} exc - Exception.
         * @return {Error} Updated exception
         ***********************************************************/
        function _normalizeException(exc) {
            var reExc = exc;
            if (exc instanceof Error) {
                // Leave it alone
            } else if (typeof exc === 'string') {
                reExc = new Error(exc);
            } else {
                reExc = new Error(
                    NLSUtils.translate('unexpected_exception') + ': ' + exc
                );
            }
            return reExc;
        }

        /************************************************************
         *
         * Process the formula
         * @param {string} formula - string to be evaluated
         * @param {WUXProgressBar} WUXpBar - Progress bar
         * @param {string} id - id of tag of the dialog
         * @param {integer} numRows - number of rows in the table.
         * @return {Promise} Promise to evaluate the formula
         *
         ***********************************************************/
        function _processFormula(formula, WUXpBar, id, numRows) {
            myShopDataTable.prototype.editMode = true;
            myShopDataTable.prototype.sortFrozen = true;
            var changes = {};
            var reportChange = function(thisRow, value) {
                changes[thisRow.rowIndex] = value;
                var percent = WUXpBar.value / 100;
                var soFar = Math.round(percent * numRows);
                soFar += 1;
                WUXpBar.value = soFar / numRows * 100;
            };

            var formulaData;
            try {
                formulaData = new SMAAnalyticsFormulaData(
                    formula,
                    reportChange
                );
            } catch (exc) {
                return Promise.reject(exc);
            }

            return SMAAnalyticsFormulaEval.computeColumnValues(
                formulaData,
                1,
                numRows
            ).then(function() {
                var event = {};
                var colP = proxy.createDataColumn(
                    {},
                    {
                        name: formulaData.newDisplayName,
                        event: event
                    }
                );
                return Promise.all([colP]).then(function() {
                    var columnId = event.newColumnID;
                    var thisColumn = {};
                    thisColumn[columnId] = changes;
                    var setP = proxy.dataTableProxy.setDataValuesFromIndexShort(
                        thisColumn
                    );
                    return setP;
                });
            });
        }

        /************************************************************
         *
         * Process the formula
         * @param {Element} myContent - Formula UI Element
         * @param {Object} sessionObject - needed to refresh table
         * @param {string} id - id of tag of the dialog
         * @param {integer} numRows - number of rows in the table.
         *
         ***********************************************************/
        function _onOkFormula(myContent, sessionObject, id, numRows) {
            var formula = myContent.expression;
            if (formula !== null && formula !== undefined) {
                var WUXpBar = new WUXProgressBar({
                    emphasize: 'success'
                }).inject(myContent);
                WUXpBar.inject($simjq(myContent).find('#progressDock')[0]);

                _processFormula(formula, WUXpBar, id, numRows).
                    finally(function() {
                        try {
                            myShopDataTable.prototype.editMode = false;
                            myShopDataTable.prototype.sortFrozen = false;
                            var moduleName = 'ra-exp-textarea';
                            var instanceName = moduleName + '_Instance';
                            $simjq('#' + instanceName).remove();
                            sessionObject.shopPage.refreshShopTable();
                            return 0;
                        } catch (exc) {
                            return Promise.reject(exc);
                        }
                    }).
                    catch(function(exc) {
                        var newExc = _normalizeException(exc);
                        UICommon.alertMessage(UICommon.ERROR, newExc.message);
                    });
            }
        }

        /************************************************************
         *
         * Setup the UI for trying an expression on a row.
         * @param {Element} content - Container for the try section
         * @param {Element} editor - Container for the formula
         * @param {integer} numRows - Number of rows
         *
         ***********************************************************/
        function _setupTrySection(content, editor, numRows) {
            var sliderValue = 1;

            var slider = new WUXSlider({
                minValue: 1,
                maxValue: numRows
            });
            slider.inject($simjq(content).find('#sliderDock')[0]);
            var exprEval = $simjq(editor).find('#expressionEval')[0];
            slider.addEventListener('change', function(event) {
                var mySlider = event.dsModel;
                sliderValue = mySlider.value;
                exprEval.slider = sliderValue;
                exprEval.message = 'Alternative: ' + sliderValue;
                $simjq('#SliderTryValue').empty();
                $simjq('#tryValues').empty();
            });
        }

        /************************************************************
         *
         * Add input values to the display
         * @param {Object} myRowData - Row values
         *
         ***********************************************************/
        function _showInputs(myRowData) {
            var parmValues = myRowData.parmValues;
            var table = $simjq('#tryValues');
            $simjq(table).empty();
            for (var id in parmValues) {
                var value = parmValues[id];
                var param = proxy.findParameter(id);
                var name;
                if (extendNames) {
                    var nameList = param.parents.parentList.concat([
                        param.displayName
                    ]);
                    name = nameList.join('.');
                } else {
                    name = param.displayName;
                }
                var tr = new UWA.Element('ra-try-param-row', {
                    param: name ,
                    input: value
                });
                tr.inject(table[0]);
            }
        }

        exports = {
            /************************************************************
             *
             * Trigger evaluation of a single row
             * @param {string} formula - Formula to evaluate
             * @param {integer} rowId - Row to evaluate
             *
             ***********************************************************/
            onTryClick: function(formula, rowId) {
                var myRowData;
                var myValue;
                var collectChange = function(thisRow, value) {
                    myRowData = thisRow;
                    myValue = value;
                };

                SMAAnalyticsFormulaEval.evalFormula(
                    formula,
                    rowId,
                    rowId,
                    collectChange
                ).
                    then(function() {
                        $simjq('#SliderTryValue').text('Result: ' + myValue);
                        _showInputs(myRowData);
                    }).
                    catch(function(exc) {
                        var newExc = _normalizeException(exc);
                        UICommon.alertMessage(UICommon.ERROR, newExc.message);
                    });
            },

            /************************************************************
             *
             * Construct a dialog to compute the formula
             * @param {Object} sessionObject - needed to refresh table
             * @param {Object} shopDataTable - containing page object
             * @param {string} id - new column uid
             * @param {Element} parent - HTML element to hold dialog
             *
             ***********************************************************/
            manageFormula: function(sessionObject, shopDataTable, id, parent) {
                var tableDataP = proxy.dataTableProxy.getTableMetadata();

                Promise.all([tableDataP]).
                    then(function(data) {
                        var info = JSON.parse(data);

                        var numRows = info.metaData.rows;
                        var paramIds = proxy.getAllParametersAsFlatList(
                            proxy.varGroup,
                            true
                        );

                        var paramNames = [];
                        for (var pIdx = 0; pIdx < paramIds.length; pIdx += 1) {
                            var param = proxy.findParameter(paramIds[pIdx]);
                            var name;
                            if (extendNames) {
                                var nameList = param.parents.parentList.concat([
                                    param.displayName
                                ]);
                                name = nameList.join('.');
                            } else {
                                name = param.displayName;
                            }
                            paramNames.push(name);
                        }
                        paramNames.sort();
                        for (var idx = 0; idx < paramNames.length; idx += 1) {
                            if (paramNames[idx].test(/\W/)) {
                                paramNames[idx] = "'" + paramNames[idx] + "'";
                            }
                        }

                        var context = '{';
                        for (var idx = 0; idx < paramNames.length; idx += 1) {
                            context += '"' + paramNames[idx] + '"' + ': 0,';
                        }
                        context = context.replace(/,$/, '}');

                        myShopDataTable = shopDataTable;
                        var container = new UWA.Element('div', {
                            styles: {
                                'vertical-align': 'top',
                                'min-height': '286px',
                                width: '100%',
                                height: '100%',
                                position: 'relative'
                            }
                        });
                        container.id = id;
                        container.inject(parent);

                        // Create the ImmersiveFrame
                        var iFrameFormula = new WUXImmersiveFrame();
                        iFrameFormula.inject(container);

                        var myContent = new UWA.Element('div');
                        var myEditor = new UWA.Element('ra-expression-editor', {
                            context: context
                        });
                        myEditor.inject(myContent);

                        _setupTrySection(myContent, myEditor, numRows);

                        var dialog = new WUXDialog({
                            title: 'Formula',
                            content: myContent,
                            immersiveFrame: iFrameFormula,
                            resizableFlag: true,
                            buttons: {
                                Ok: new WUXButton({
                                    onClick: function() {
                                        _onOkFormula(
                                            myEditor,
                                            sessionObject,
                                            id,
                                            numRows
                                        );
                                    }
                                }),
                                Cancel: new WUXButton({
                                    onClick: function() {
                                        $simjq('#' + id).remove();
                                    }
                                })
                            }
                        });
                        // Listen to the close event
                        dialog.addEventListener('close', function() {
                            $simjq('#' + id).remove();
                        });
                    }).
                    catch(function(exc) {
                        var newExc = _normalizeException(exc);
                        UICommon.alertMessage(UICommon.ERROR, newExc.message);
                    });
            }
        };

        return exports;
    }
);

