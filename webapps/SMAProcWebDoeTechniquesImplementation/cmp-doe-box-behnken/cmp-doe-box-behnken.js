/**
 * @class element:cmp-doe-box-behnken
 * @noinstancector
 * @description
 * This component implements the Box-Behnken technique in DOE.
 * The Box-Behnken technique is a class of incomplete three-level factorial designs
 * consisting of orthogonal blocks that exclude extreme (corner) points.
 */

require(['SMAProcWebDoeTechniquesBase/SMAProcDesignDriverFactorImpl'],
function (SMAProcDesignDriverFactorImpl) {
    'use strict';
    Polymer(/** @lends element:cmp-doe-box-behnken# */{
        is: 'cmp-doe-box-behnken',
        properties: /** @lends element:cmp-doe-box-behnken# */ {

            /**
             * Keys of the columns to be rendered for the factors table
             * @type {Array}
             */
            factorColumns: {
                type: Array,
                notify: true,
                value: ['Levels', 'Relation', 'Baseline', 'Values']
            },

            /**
             * Names of the properties to be saved in the definition
             * @type {Array}
             */
            factorAttributes: {
                type: Array,
                notify: true,
                value: ['Levels', 'Relation', 'Baseline', 'Values']
            },

            /**
             * The default values of the attributes for each factor
             * @type {Object}
             */
            factorAtrributeDefaultValues: {
                type: Object,
                value: {
                    Levels: '-10 0 10',
                    Relation: 'diff',
                    Baseline: '0',
                    Values: ''
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
            var values = SMAProcDesignDriverFactorImpl.getValues(factor.Levels, factor.Baseline, factor.Relation);
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
            this.updatedFactors[index][cellinfo.colName];
            if (this.updatedFactors[index][cellinfo.colName]) {
                this.updatedFactors[index][cellinfo.colName] = cellinfo.value;
                this.populateFactorRow(this.updatedFactors[index]);
            }
        },

        /**
         * Populates the cells in the factors table for the given factor.
         * @param {Object} factor - The factor that is to be updated based on its other attributes
         */
        populateFactorRow: function(factor) {
            var cellinfo = factor.cellinfo;
            cellinfo.DOMrow.cells[5].getElementsByClassName('textInp')[0].value = factor.Levels;
            cellinfo.DOMrow.cells[5].getElementsByClassName('textInp')[0].title = factor.Levels;
            cellinfo.DOMrow.cells[6].getElementsByTagName('select')[0].disabled = false;
            cellinfo.DOMrow.cells[6].children[0].selectedIndex = SMAProcDesignDriverFactorImpl.factorRelationOptions.value.indexOf(factor.Relation);
            cellinfo.DOMrow.cells[6].children[0].title = factor.Relation;
            cellinfo.DOMrow.cells[7].getElementsByClassName('textInp')[0].value = factor.Baseline;
            cellinfo.DOMrow.cells[7].getElementsByClassName('textInp')[0].title = factor.Baseline;
            var values =
                SMAProcDesignDriverFactorImpl.getValues(factor.Levels.split(' '), factor.Baseline, factor.Relation);
            factor['Values'] = values;
            cellinfo.DOMrow.cells[9].textContent = values;
            cellinfo.DOMrow.cells[9].title = values;

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
                for (var j = 0; j < this.factorAttributes.length; j++){
                    factor[this.factorAttributes[j]] = this.factorAtrributeDefaultValues[this.factorAttributes[j]];
                    if (this.factorAttributes[j] === 'Baseline' && (cellinfo.paraminfo && cellinfo.paraminfo.value !== null && cellinfo.paraminfo.value !== undefined)) {
                        factor[this.factorAttributes[j]] = cellinfo.paraminfo.value;
                    }
                }
                if (parseFloat(factor['Baseline']) !== 0) {
                    factor['Relation'] = '%';
                }
                factor['cellinfo'] = cellinfo;
                this.populateFactorRow(factor);
                this.push('updatedFactors', factor);
            }

            return this.updatedFactors;
        },

        /**
         * Revisits each of the and its attributes and re-populates/re-calculates any missing attribute for the factors
         * @param {Array} factors - An array of factors containing the attributes
         */
        reviseFactorAttributes: function(factors) {
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
                    case 'Levels':
                        if ((factors[i]['Levels'] !== undefined) && (factors[i]['Levels'] !== ''))
                        {
                            revisedFactor['Levels'] = levels.join(' ');
                        }
                        else if ((revisedFactor['Lower'] !== undefined) && (revisedFactor['Lower'] !== '') &&
                                (revisedFactor['Upper'] !== undefined) && (revisedFactor['Upper'] !== ''))
                        {
                            revisedFactor['Levels'] = SMAProcDesignDriverFactorImpl.getDistribution(revisedFactor['Lower'], revisedFactor['Upper'], 3).join(' ');
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
                    }
                }
                this.push('updatedFactors', revisedFactor);
            }
            return this.updatedFactors;
        }
    });
});
