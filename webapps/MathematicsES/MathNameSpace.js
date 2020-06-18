/**
* @nodoc
*/
var ThreeDS;

/**
* @public
* @namespace DSMath
*/
var DSMath;

/**
* @nodoc
*/
var cgmMath;


define('MathematicsES/MathNameSpace', ['MathematicsES/MathTolerancesJS',
                                       'MathematicsES/MathConstantsJS' ], function (tolerances,
                                                                                    constants) {
    'use strict';

    ThreeDS = ThreeDS || {};
    /**
    * @nodoc
    */
    ThreeDS.Mathematics = {};

    DSMath  = ThreeDS.Mathematics;
    cgmMath = DSMath;

   /**
   * The default tolerances (no scale) used by mathematical objects.
   * @member
   * @instance
   * @name defaultTolerances
   * @public
   * @type { MathTolerances }
   * @memberOf DSMath
   */
   Object.defineProperty(DSMath, "defaultTolerances", {
       value       : tolerances.defaultTolerances,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   /**
   * The pre-computed values used by mathematical objects.
   * @member
   * @instance
   * @name constants
   * @public
   * @type { MathConstants }
   * @memberOf DSMath
   */
   Object.defineProperty(DSMath, "constants", {
       value       : constants,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

    return DSMath;
});

