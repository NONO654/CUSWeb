define('CSIMathematics/CSIDeclareMathMat3x3JS', ['MathematicsES/MathMat3x3JSImpl'], function (MathMatrix3x3) {
    'use strict';

    /**
     * Declare the CATMath3x3Matrix type in the CSICommands.
     * It streams a MathMat3x3JSImpl.
     */
    var CSIDeclare = function (CSICommands) {
       var serializeMathMat3x3 = function (parameters, matrix) {
          var coefs =  matrix.getArray();
          parameters.writeDoubleArray('coefs', coefs);
        };

       var unserializeMathMat3x3 = function (message) {
          var coefs = message.readDoubleArray('coefs');
          var matrix = new MathMatrix3x3().setFromArray(coefs);
          return matrix;
       };

        CSICommands.declareType({
            type: 'CATMath3x3Matrix',
            serialize: serializeMathMat3x3,
            unserialize: unserializeMathMat3x3,
        });
    };

    return CSIDeclare;
});
