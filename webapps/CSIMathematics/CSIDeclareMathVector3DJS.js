define('CSIMathematics/CSIDeclareMathVector3DJS', ['MathematicsES/MathVector3DJSImpl'], function (MathVector3D) {
   'use strict';

   /**
    * Declare the CATMathVector3D type in the CSICommands.
    * It streams a MathVector3DJSImpl.
    */
   var CSIDeclare = function (CSICommands) {
      var serializeMathVector3D = function (parameters, vector) {
         parameters.writeDouble('x', vector.x);
         parameters.writeDouble('y', vector.y);
         parameters.writeDouble('z', vector.z);
      };

      var unserializeMathVector3D = function (message) {
         var x = message.readDouble('x');
         var y = message.readDouble('y');
         var z = message.readDouble('z');

         var vector = new MathVector3D(x, y, z);

         return vector;
      };

      CSICommands.declareType({
         type: 'CATMathVector',
         serialize: serializeMathVector3D,
         unserialize: unserializeMathVector3D,
      });
   };

   return CSIDeclare;
});

