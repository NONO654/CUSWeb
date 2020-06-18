define('CSIMathematics/CSIDeclareMathAxisJS', ['MathematicsES/MathAxisJSImpl'], function (MathAxis) {
   'use strict';

   /**
    * Declare the CATMathAxis type in the CSICommands.
    * It streams a MathAxisJSImpl.
    */
   var CSIDeclare = function (CSICommands) {
      var serializeMathAxis = function (parameters, axis) {
         var vectors = axis.getDirectionsNotCloned();

         parameters.writeObject('origin', 'CATMathPoint', axis.origin);
         parameters.writeObject('direction1', 'CATMathVector', vectors[0]);
         parameters.writeObject('direction2', 'CATMathVector', vectors[1]);
         parameters.writeObject('direction3', 'CATMathVector', vectors[2]);
      };

      var unserializeMathAxis = function (message) {
         var origin = message.readObject('origin', 'CATMathPoint');
         var direction1 = message.readObject('direction1', 'CATMathVector');
         var direction2 = message.readObject('direction2', 'CATMathVector');
         var direction3 = message.readObject('direction3', 'CATMathVector');

         var axis = new MathAxis();
         axis.origin = origin;
         axis.setVectors(direction1, direction2, direction3);

         return axis;
      };

      CSICommands.declareType({
         type: 'CATMathAxis',
         serialize: serializeMathAxis,
         unserialize: unserializeMathAxis,
      });
   };

   return CSIDeclare;
});
