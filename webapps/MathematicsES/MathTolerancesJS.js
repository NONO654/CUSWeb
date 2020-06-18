define('MathematicsES/MathTolerancesJS', function () {
   'use strict';

   // Mathematics constants.
   var Epsilon = 1e-15;
   var Epsg    = 1e-12;
   
   /**
   * Class representing a set of mathematical tolerances.
   * <br>
   * The tolerances does not take the scale into account yet.
   * @constructor
   * @exports MathTolerances
   * @class
   * @public
   */
   var MathTolerances = function(){

       /**
       * The scale. Currently, always equals 1.0.
       * @member
       * @instance
       * @name scale
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "scale", {
          value       : 1.0,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

// ============== Angle ============= //
       /**
       * The numerical tolerance used to perform absolute tests homogeneous to an angle.
       * @member
       * @instance
       * @name epsgForAngleTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsgForAngleTest", {
          value       : Epsg,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform absolute tests homogeneous to the square of an angle.
       * @member
       * @instance
       * @name epsgForSquareAngleTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsgForSquareAngleTest", {
          value       : this.epsgForAngleTest*this.epsgForAngleTest,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform absolute tests homogeneous to the square root of an angle.
       * @member
       * @instance
       * @name epsgForSqrtAngleTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsgForSqrtAngleTest", {
          value       : Math.sqrt(this.epsgForAngleTest),
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform the most absolute tests homogeneous to an angle.
       * @member
       * @instance
       * @name epsilonForAngleTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsilonForAngleTest", {
          value       : Epsilon,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform the most absolute tests homogeneous to the square of an angle.
       * @member
       * @instance
       * @name epsilonForSquareAngleTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsilonForSquareAngleTest", {
          value       : this.epsilonForAngleTest*this.epsilonForAngleTest,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform the most absolute tests homogeneous to the square root of an angle.
       * @member
       * @instance
       * @name epsilonForSqrtAngleTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsilonForSqrtAngleTest", {
          value       : Math.sqrt(this.epsilonForAngleTest),
          writable    : false,
          enumerable  : true,
          configurable: false
      });

// ============== Relative ============= //
       /**
       * The numerical tolerance used to perform relative tests homogeneous to a scale invariant value.
       * @member
       * @instance
       * @name epsgForRelativeTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsgForRelativeTest", {
          value       : Epsg,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform relative tests homogeneous to a square scale invariant value.
       * @member
       * @instance
       * @name epsgForSquareRelativeTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsgForSquareRelativeTest", {
          value       : this.epsgForRelativeTest*this.epsgForRelativeTest,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform relative tests homogeneous to a square root scale invariant value.
       * @member
       * @instance
       * @name epsgForSqrtRelativeTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsgForSqrtRelativeTest", {
          value       : Math.sqrt(this.epsgForRelativeTest),
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform the most relative tests homogeneous to a scale invariant value.
       * @member
       * @instance
       * @name epsilonForRelativeTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsilonForRelativeTest", {
          value       : Epsilon,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform the most relative tests homogeneous to a square scale invariant value.
       * @member
       * @instance
       * @name epsilonForSquareRelativeTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsilonForSquareRelativeTest", {
          value       : this.epsilonForRelativeTest*this.epsilonForRelativeTest,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform the most relative tests homogeneous to a square root scale invariant value.
       * @member
       * @instance
       * @name epsilonForSqrtRelativeTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsilonForSqrtRelativeTest", {
          value       : Math.sqrt(this.epsilonForRelativeTest),
          writable    : false,
          enumerable  : true,
          configurable: false
      });

// ============== Length ============= //
       /**
       * The numerical tolerance used to perform absolute tests homogeneous to a length.
       * @member
       * @instance
       * @name epsgForLengthTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsgForLengthTest", {
          value       : this.scale*Epsg,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform absolute tests homogeneous to a square of length.
       * @member
       * @instance
       * @name epsgForSquareLengthTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsgForSquareLengthTest", {
          value       : this.epsgForLengthTest*this.epsgForLengthTest,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform absolute tests homogeneous to a square root of length.
       * @member
       * @instance
       * @name epsgForSqrtLengthTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsgForSqrtLengthTest", {
          value       : Math.sqrt(this.epsgForLengthTest),
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform the most absolute tests homogeneous to a length.
       * @member
       * @instance
       * @name epsilonForLengthTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsilonForLengthTest", {
          value       : this.scale*Epsilon,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform the most absolute tests homogeneous of a square of length.
       * @member
       * @instance
       * @name epsilonForSquareLengthTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsilonForSquareLengthTest", {
          value       : this.epsilonForLengthTest*this.epsilonForLengthTest,
          writable    : false,
          enumerable  : true,
          configurable: false
      });

       /**
       * The numerical tolerance used to perform the most absolute tests homogeneous of a square root of length.
       * @member
       * @instance
       * @name epsilonForSqrtLengthTest
       * @public
       * @type { Number }
       * @memberOf MathTolerances
       */
       Object.defineProperty(this, "epsilonForSqrtLengthTest", {
          value       : Math.sqrt(this.epsilonForLengthTest),
          writable    : false,
          enumerable  : true,
          configurable: false
      });
   };


   var defaultTolerances = new MathTolerances();
   /*
   * The default tolerance.
   */
   Object.defineProperty(MathTolerances, "defaultTolerances", {
       value       : defaultTolerances,
       writable    : false,
       enumerable  : true,
       configurable: false
   });


   return MathTolerances;
});

