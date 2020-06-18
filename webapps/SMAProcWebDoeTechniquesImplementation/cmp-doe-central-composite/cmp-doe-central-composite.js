/**
 * @class element:cmp-doe-central-composite
 * @noinstancector
 * @description
 * This component implements the Central Composite technique in DOE.
 * The Central Composite Design technique is a statistically based technique
 * in which a 2-level full-factorial experiment is augmented with additional points.
 */

require(['SMAProcWebDoeTechniquesBase/SMAProcDesignDriverFactorImpl'],
function (SMAProcDesignDriverFactorImpl) {
    'use strict';
    Polymer(/** @lends element:cmp-doe-central-composite# */{
        is: 'cmp-doe-central-composite',
        properties: /** @lends element:cmp-doe-central-composite# */{
            /**
             * Keys of the columns to be rendered for the factors table
             * @type {Array}
             */
            factorColumns: {
                type: Array,
                notify: true,
                value: ['Alpha', 'Lower', 'Upper', 'Levels', 'Relation', 'Baseline', 'Values']
            },
            /**
             * Names of the properties to be saved in the definition
             * @type {Array}
             */
            factorAttributes: {
                type: Array,
                notify: true,
                value: ['Lower', 'Upper', 'Levels', 'Relation', 'Baseline', 'Values', 'Alpha', 'User Alpha']
            },
            /**
             * The default values of the attributes for each factor
             * @type {Object}
             */
            factorAtrributeDefaultValues: {
                type: Object,
                value: {
                    Alpha: '',
                    'User Alpha': false,
                    Lower: '-10',
                    Upper: '10',
                    Levels: '-10 0 10',
                    Relation: 'diff',
                    Baseline: '0.0',
                    Values: '-10 0.0 10'
                }
            },
            /**
             * The factors are added/updated in this array as and when they are selected/updated by the user
             * @type {Array}
             */
            updatedFactors: {
                type: Array,
                notify: true,
                value: function() { return []; }
            }
        },

        /**
         * Called after the element is attached to the document. Can be called multiple times during the lifetime of an element.
         * The first `attached` callback is guaranteed not to fire until after `ready`.
         */
        attached:function(){
            var that = this;
            this.async(function(){
                that.fire('techniqueloaded', that);
            });
        },

        /**
         * Updates the values column in the Factors tab of DOE.
         * Once the parameter/factor is selected, the values of the factor are calculated based on
         * the default values of the other attributes as defined in factorAttributes.
         * If the factor is updated then the values are recalculated.
         * @param {Object} factor - The factor that is to be updated based on its other attributes
         */
        populateFactorValues: function(factor) {
            var cellinfo = factor.cellinfo;
            var levels;
            if (cellinfo.colName === 'Alpha') {
                factor['User Alpha'] = true;
            }
            if (factor['User Alpha'] === false || factor['User Alpha'] === 'false') {
                factor.Alpha = Math.sqrt(this.updatedFactors.length);
                cellinfo.DOMrow.cells[8].getElementsByClassName('textInp')[0].value = factor.Alpha;
                cellinfo.DOMrow.cells[8].getElementsByClassName('textInp')[0].title = factor.Alpha;
            }

            levels = SMAProcDesignDriverFactorImpl.getDistribution(factor.Lower, factor.Upper, 3);
            var SUpper = parseFloat(factor.Baseline) + (parseFloat(factor.Upper) - parseFloat(factor.Baseline)) * parseFloat(factor.Alpha);
            var SLower = parseFloat(factor.Baseline) - (parseFloat(factor.Baseline) - parseFloat(factor.Lower)) * parseFloat(factor.Alpha);
            values = SLower + ' ' + values + ' ' + SUpper;
            factor.Levels = SLower + ' ' + levels.join(' ') + ' ' + SUpper;
            var values = SMAProcDesignDriverFactorImpl.getValues(factor.Levels, factor.Baseline, factor.Relation);
            cellinfo.DOMrow.cells[5].getElementsByClassName('textInp')[0].value = factor.Levels;
            cellinfo.DOMrow.cells[5].getElementsByClassName('textInp')[0].title = factor.Levels;
            factor.Values = values;
            cellinfo.DOMrow.cells[9].textContent = values;
            cellinfo.DOMrow.cells[9].title = values;
        },

        /**
         * It updates the factor information when the user edits any of the columns in the factors table.
         * @param {Object} cellinfo - The cell information that has the column name and the value that was updated.
         * @param {String} paramName - Name of the parameter that was updated
         */
        updateFactorInfo: function (cellinfo, paramName) {
            var index = SMAProcDesignDriverFactorImpl.findFactor(paramName, this.updatedFactors);
            if (this.updatedFactors[index][cellinfo.colName]) {
                this.updatedFactors[index][cellinfo.colName] = cellinfo.value;
                this.updatedFactors[index].cellinfo = cellinfo;
                this.populateFactorValues(this.updatedFactors[index]);
            }
        },

        /**
         * Populates the cells in the factors table for the given factor.
         * @param {Object} factor - The factor that is to be updated based on its other attributes
         */
        populateFactorRow: function(factor) {
            var cellinfo = factor.cellinfo;
            cellinfo.DOMrow.cells[3].getElementsByClassName('textInp')[0].value = factor.Lower;
            cellinfo.DOMrow.cells[3].getElementsByClassName('textInp')[0].title = factor.Lower;
            cellinfo.DOMrow.cells[4].getElementsByClassName('textInp')[0].value = factor.Upper;
            cellinfo.DOMrow.cells[4].getElementsByClassName('textInp')[0].title = factor.Upper;
            cellinfo.DOMrow.cells[5].getElementsByClassName('textInp')[0].value = factor.Levels;
            cellinfo.DOMrow.cells[5].getElementsByClassName('textInp')[0].title = factor.Levels;
            cellinfo.DOMrow.cells[6].getElementsByTagName('select')[0].disabled = false;
            cellinfo.DOMrow.cells[6].children[0].selectedIndex = SMAProcDesignDriverFactorImpl.factorRelationOptions.value.indexOf(factor.Relation);
            cellinfo.DOMrow.cells[6].children[0].title = factor.Relation;
            cellinfo.DOMrow.cells[7].getElementsByClassName('textInp')[0].value = factor.Baseline;
            cellinfo.DOMrow.cells[7].getElementsByClassName('textInp')[0].title = factor.Baseline;
            for (var i = 0; i < this.updatedFactors.length; i++)
                { this.populateFactorValues(this.updatedFactors[i]); }

        },

        /**
         * Populates the default values in the table for the factors on parameter selection,
         * also update the data structure for the parameters updatedFactors
         * @param {Object} cellinfo - The corresponding cell information of the selected factor to be updated
         * @param {String} paramName - Name of the parameter
         */
        populateDefaults: function(cellinfo, paramName) {

            if (SMAProcDesignDriverFactorImpl.findFactor(paramName, this.updatedFactors) < 0) {
                var factor = {
                        Name: paramName
                };
                for (var j = 0; j < this.factorAttributes.length; j++) {
                    factor[this.factorAttributes[j]] = this.factorAtrributeDefaultValues[this.factorAttributes[j]];
                    if (this.factorAttributes[j] === 'Baseline' && (cellinfo.paraminfo && cellinfo.paraminfo.value !== null && cellinfo.paraminfo.value !== undefined)) {
                        factor[this.factorAttributes[j]] = cellinfo.paraminfo.value;
                    }
                }
                if (parseFloat(factor['Baseline']) !== 0) {
                    factor['Relation'] = '%';
                }
                factor['cellinfo'] = cellinfo;
                this.push('updatedFactors', factor);
                this.populateFactorRow(factor);
            }
            return this.updatedFactors;
        },

        /**
         * The other factors are updated on removing factors from the table
         * @param {Object} cellinfo - The corresponding cell information of the selected factor to be updated
         */
        factorRemoved: function(cellinfo) {
            if ((cellinfo.DOMcell.type === 'checkbox') && (cellinfo.srcElement.checked === false)) {
                for (var i = 0; i < this.updatedFactors.length; i++)
                    { this.populateFactorValues(this.updatedFactors[i]); }
            }
        },

        /**
         * Revisits each of the and its attributes and re-populates/re-calculates any missing attribute for the factors
         * @param {Array} factors - An array of factors containing the attributes
         */
        reviseFactorAttributes: function(factors) {
            var alpha =  Math.sqrt(factors.length);
            for (var i = 0; i < factors.length; i++) {
                var revisedFactor = {};
                var levels = [];
                if ((factors[i]['Levels'] !== undefined) && (factors[i]['Levels'] !== ''))
                {
                    if (factors[i]['Levels'].split)
                        { levels = factors[i]['Levels'].split(' ').filter(SMAProcDesignDriverFactorImpl.hasEmptyValues); }
                }
                revisedFactor['Name'] = factors[i]['Name'];
                for (var j = 0; j < this.factorAttributes.length; j++){
                    switch (this.factorAttributes[j])
                    {
                        case 'Lower':
                            if ((factors[i]['Lower'] !== undefined) && (factors[i]['Lower'] !== ''))
                            {
                                revisedFactor['Lower'] = factors[i]['Lower'];
                            }
                            else if ((factors[i]['Levels'] !== undefined) && (factors[i]['Levels'] !== ''))
                            {
                                revisedFactor['Lower'] = levels[0];
                            }
                            else
                            {
                                revisedFactor['Lower'] = this.factorAtrributeDefaultValues['Lower'];
                            }
                        break;

                        case 'Upper':
                            if ((factors[i]['Upper'] !== undefined) && (factors[i]['Upper'] !== ''))
                            {
                                revisedFactor['Upper'] = factors[i]['Upper'];
                            }
                            else if ((factors[i]['Levels'] !== undefined) && (factors[i]['Levels'] !== ''))
                            {
                                revisedFactor['Upper'] = levels[levels.length - 1];
                            }
                            else
                            {
                                revisedFactor['Upper'] = this.factorAtrributeDefaultValues['Upper'];
                            }
                        break;

                        case 'Levels':
                            if ((revisedFactor['Lower'] !== undefined) && (revisedFactor['Lower'] !== '') &&
                                    (revisedFactor['Upper'] !== undefined) && (revisedFactor['Upper'] !== ''))
                            {
                                revisedFactor['Levels'] = SMAProcDesignDriverFactorImpl.getDistribution(revisedFactor['Lower'], revisedFactor['Upper'], 3);
                            }
                            else if ((factors[i]['Levels'] !== undefined) && (factors[i]['Levels'] !== ''))
                            {
                                revisedFactor['Lower'] = levels[0];
                                revisedFactor['Upper'] = levels[levels.length - 1];
                            }
                            else
                            {
                                revisedFactor['Levels'] = this.factorAtrributeDefaultValues['Levels'];
                            }
                        break;

                        case 'Relation':
                            if ((factors[i]['Relation'] !== undefined) && (factors[i]['Relation'] !== ''))
                            {
                                revisedFactor['Relation'] = factors[i]['Relation'];
                            }
                            else
                            {
                                revisedFactor['Relation'] = this.factorAtrributeDefaultValues['Relation'];
                            }
                        break;

                        case 'Baseline':
                            if ((factors[i]['Baseline'] !== undefined) && (factors[i]['Baseline'] !== ''))
                            {
                                revisedFactor['Baseline'] = factors[i]['Baseline'];
                            }
                            else
                            {
                                revisedFactor['Baseline'] = this.factorAtrributeDefaultValues['Baseline'];
                            }
                        break;

                        case 'Alpha':
                            revisedFactor['Alpha'] = alpha;
                        break;

                        case 'User Alpha':
                            revisedFactor['User Alpha'] = false;
                        break;
                    }
                }
                this.push('updatedFactors', revisedFactor);
            }
            return this.updatedFactors;
        }
    });
});
