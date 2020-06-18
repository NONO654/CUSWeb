define('CSIMathematics/CSIDeclareMathPointJS', ['MathematicsES/MathPointJSImpl'], function (MathPoint) {
    'use strict';

    /**
     * Declare the CATMathPoint type in the CSICommands.
     * It streams a MathPointJSImpl.
     */
    var CSIDeclare = function (CSICommands) {
        var serializeMathPoint = function (parameter, point) {
            parameter.writeDouble('x', point.x);
            parameter.writeDouble('y', point.y);
            parameter.writeDouble('z', point.z);
        };

        var unserializeMathPoint = function (message) {
            var x = message.readDouble('x');
            var y = message.readDouble('y');
            var z = message.readDouble('z');
            var pt = new MathPoint(x, y, z);
            return pt;
        };

        CSICommands.declareType({
            type: 'CATMathPoint',
            serialize: serializeMathPoint,
            unserialize: unserializeMathPoint,
        });
    };

    return CSIDeclare;
});
