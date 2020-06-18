define('CSIMathematics/CSIDeclareMathMat2x2JS', ['MathematicsES/MathMat2x2JSImpl'], function (MathMatrix2x2) {
    'use strict';

    /**
     * Declare the CATMath2x2Matrix type in the CSICommands.
     * It streams a MathMat2x2JSImpl.
     */
    var CSIDeclare = function (CSICommands) {
       var serializeMathMat2x2 = function (parameters, matrix) {
          var coefs =  matrix.getArray();
          parameters.writeDoubleArray('coefs', coefs);
        };

       var unserializeMathMat2x2 = function (message) {
          var coefs  = message.readDoubleArray('coefs');
          var matrix = new MathMatrix2x2().setFromArray(coefs);
          return matrix;
       };

        CSICommands.declareType({
            type: 'CATMath2x2Matrix',
            serialize: serializeMathMat2x2,
            unserialize: unserializeMathMat2x2,
        });
    };

    return CSIDeclare;
});
