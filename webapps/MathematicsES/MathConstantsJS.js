define('MathematicsES/MathConstantsJS', function () {
   'use strict';

/**
* @typedef MathConstants
* @type Object
* @property {Number} PI         Pre-computed value of Pi.
* @property {Number} PI2        Pre-computed value of 2*Pi.
* @property {Number} PI3        Pre-computed value of 3*Pi.
* @property {Number} PIBY2      Pre-computed value of Pi/2.
* @property {Number} PI3BY2     Pre-computed value of 3*Pi/2.
* @property {Number} PIBY4      Pre-computed value of Pi/4.
* @property {Number} PI3BY4     Pre-computed value of 3*Pi/4.
* @property {Number} INV_PI     Pre-computed value of 1.0/Pi.
* @property {Number} INV_PI2    Pre-computed value of 1.0/(2*Pi).
* @property {Number} SQRT2      Pre-computed value of the 2 square root.
* @property {Number} SQRT3      Pre-computed value of the 3 square root.
* @property {Number} INV_SQRT2  Pre-computed value of the 1.0/2.0 square root.
* @property {Number} INV_SQRT3  Pre-computed value of the 1.0/3.0 square root.
* @property {Number} RAD_TO_DEG Pre-computed value 180/Pi.
* @property {Number} DEG_TO_RAD Pre-computed value of Pi/180.
*/
   var Constants = {};

   Object.defineProperty(Constants, "PI", {
       value       : Math.PI,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "PI2", {
       value       : 2*Math.PI,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "PI3", {
       value       : 3*Math.PI,
       writable    : false,
       enumerable  : true,
       configurable: false
   });
   
   Object.defineProperty(Constants, "PIBY2", {
       value       : Math.PI/2.0,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "PI3BY2", {
       value       : (3*Math.PI)/2.0,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "PIBY4", {
       value       : Math.PI/4.0,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "PI3BY4", {
       value       : (3*Math.PI)/4.0,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "INV_PI", {
       value       : 1.0/Math.PI,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "INV_PI2", {
       value       : 1.0/(2*Math.PI),
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "SQRT2", {
       value       : Math.SQRT2,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "INV_SQRT2", {
       value       : Math.SQRT1_2,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "SQRT3", {
       value       : 1.73205080756887729352,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "INV_SQRT3", {
       value       : 0.57735026918962576451,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "RAD_TO_DEG", {
       value       : 180/Math.PI,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "DEG_TO_RAD", {
       value       : Math.PI/180,
       writable    : false,
       enumerable  : true,
       configurable: false
   });


// ================= DEPRECATED ================== //
   Object.defineProperty(Constants, "INVPI", {
       value       : Constants.INV_PI,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "INV2PI", {
       value       : Constants.INV_PI2,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "INVSQRT2", {
       value       : Constants.INV_SQRT2,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "INVSQRT3", {
       value       : Constants.INV_SQRT3,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "RadToDeg", {
       value       : Constants.RAD_TO_DEG,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   Object.defineProperty(Constants, "DegToRad", {
       value       : Constants.DEG_TO_RAD,
       writable    : false,
       enumerable  : true,
       configurable: false
   });

   return Constants;
});
