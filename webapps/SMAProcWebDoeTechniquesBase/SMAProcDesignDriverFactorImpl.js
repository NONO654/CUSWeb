/**
 * @module SMAProcWebDoeTechniquesBase/SMAProcDesignDriverFactorImpl
 */
define('SMAProcWebDoeTechniquesBase/SMAProcDesignDriverFactorImpl', [],
       function () {
           'use strict';
           var FRACTION_DIGITS  = 5;
            /**
            * SMAProcDesignDriverFactorImpl provides the basic computation methods for various techniques of DOE
            * @memberof module:SMAProcWebDoeTechniquesBase/SMAProcDesignDriverFactorImpl
            */
            var SMAProcDesignDriverFactorImpl = {

                   RELATION_VALUE: 'values',
                   RELATION_DIFF: 'diff',
                   RELATION_PERCENT: '%',

                   /**
                 * Relation options for factors
                 * @type {Array}
                 */
                factorRelationOptions: {
                    type: Array,
                    notify: true,
                    value: ['diff', '%', 'values']
                },
                   /**
                    * Computation for Levels based on which the values will be calculated for
                    * various DOE techniques
                    * @param {String|Number} lower - Lower bound of the factor
                    * @param {String|Number} upper - Upper bound of the factor
                    * @param {String|Number} lower - Number of levels or points based on which the levels will be calculated
                    * @returns {Array} - Levels for the factor
                    */
                   getDistribution: function (lower, upper, numLevels) {
                       console.log('Getting levels for lower: '+ lower +',  upper: ' + upper +  ', numLevels: ' + numLevels);
                       var listLevels = [];

                       if (numLevels === undefined || numLevels=== null)
                           { return null; }

                       var i_lower = parseFloat(lower);
                       var i_upper = parseFloat(upper);

                       /* Check if i_lower or i_upper are non-numeric, if any one of them is non-numeric
                        * alternate between the two starting with lower. */
                        if (isNaN(i_lower) || isNaN(i_upper)) {
                             for (var i = 1; i <= numLevels; i++) {
                               listLevels.push((i % 2) ? i_lower : i_upper);
                           }
                           return listLevels;
                       }
                       //Lower bound is where the levels start
                       listLevels.push(i_lower);

                       if (numLevels === 1)
                           { return listLevels; }

                       /* The delta is calculated and added to the lower bound and the result thereafter
                        * to get the levels so that the values for the parameters can be calculated
                        * The number of levels is either the number of points (as in Latin Hypercube)
                        * or the number of levels*/
                       var dTemp = parseFloat(i_lower);
                       var dDelta = parseFloat(((i_upper - i_lower)/(numLevels - 1)).toFixed(FRACTION_DIGITS));

                       //Calculating the distribution
                       for (var j = 1; j < (numLevels-1); j++) {
                           dTemp += dDelta;
                           listLevels.push(dTemp.toString());
                       }

                       //Upper bound is where the levels end
                       listLevels.push(i_upper);

                       return listLevels;
                   },
                   /**
                    * Computation of values based on levels, baseline and relation
                    * @param {String|Array} levels - Levels of the factor
                    * @param {String|Number} baseline - Baseline
                    * @param {String} relation - Relation, can be one of 'value', 'diff' and '%'
                    * @returns {String} - Space separated values
                    */
                   getValues: function (levels, baseline, relation) {
                       var PERCENT = 0.01;
                       var listValues = [];
                       //Techniques like Box Behnken, save levels as String "-10 0 10", but for further calculations
                       //the string needs to be split to create an array to access each number
                       if (levels) {
                           if (levels.split)
                               { levels = levels.split(' '); }
                           //If the relation has a value of 'value' then the levels are values
                           if (relation === this.RELATION_VALUE)
                               { return levels.join(' '); }

                           var baselineAbs = Math.abs(parseFloat(baseline));

                           for (var i = 0; i < levels.length; i++) {
                               var level = parseFloat(levels[i]);
                               var value;
                               if (isNaN(level) || isNaN(baselineAbs))
                                   { return null; }
                               if (relation === this.RELATION_DIFF)
                                   { value = (parseFloat(baseline) + level).toFixed(FRACTION_DIGITS); }
                               else if (relation === this.RELATION_PERCENT)
                                   { value = (parseFloat(baseline) + baselineAbs*level*PERCENT).toFixed(FRACTION_DIGITS); }
                               else
                                   { continue; }
                               //parseFloat to remove trailing zeroes
                               listValues.push(parseFloat(value).toString());
                           }
                           return listValues.join(' ');
                       }
                   },

                   /**
                    * Filters empty/null/undefined values
                    * @param {String|Number} value value to test
                    * @returns {Boolean} - True if the provided value is not null, undefined and empty
                    */
                   hasEmptyValues: function(value) {
                       return (value !== undefined && value !== null && value !== '');
                   },

                   /**
                   * Returns the index of the factor from the array of factors given the name
                   * @param {String} name - Name of the factor to be found
                   * @param {Array} updatedFactors array of factor to search in
                   * @returns {Number} - Returns the index of the factor in the array, if not found returns -1
                   */
                   findFactor: function(name, updatedFactors) {
                       for (var i = 0; i < updatedFactors.length; i++) {
                           if (updatedFactors[i]['Name'] === name) {
                               return i;
                           }
                       }
                       return -1;
                   }
           };

           return SMAProcDesignDriverFactorImpl;
});
