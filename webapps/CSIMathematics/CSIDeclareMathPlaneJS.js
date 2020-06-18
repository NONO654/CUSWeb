define('CSIMathematics/CSIDeclareMathPlaneJS', ['MathematicsES/MathPlaneJSImpl'], function (MathPlane) {
    'use strict';

    /**
     * Declare the CATMathPlane type in the CSICommands.
     * It streams a MathPlaneJSImpl.
     */
    var CSIDeclare = function (CSICommands) {
        var serializeMathPlane = function (parameters, plane) {
            var vectors = plane.getDirectionsNotCloned();

            parameters.writeObject('origin', 'CATMathPoint', plane.origin);
            parameters.writeObject('direction1', 'CATMathVector', vectors[0]);
            parameters.writeObject('direction2', 'CATMathVector', vectors[1]);
        };

        var unserializeMathPlane = function (message) {
           var origin     = message.readObject('origin', 'CATMathPoint');
           var direction1 = message.readObject('direction1', 'CATMathVector');
           var direction2 = message.readObject('direction2', 'CATMathVector');

            var plane = new MathPlane(origin, direction1, direction2);

            return plane;
        };

        CSICommands.declareType({
            type: 'CATMathPlane'             ,
            serialize: serializeMathPlane    ,
            unserialize: unserializeMathPlane,
        });
    };

    return CSIDeclare;
});
