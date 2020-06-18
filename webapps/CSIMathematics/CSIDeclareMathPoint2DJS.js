define('CSIMathematics/CSIDeclareMathPoint2DJS', ['MathematicsES/MathPoint2DJSImpl'], function (MathPoint2D) {
    'use strict';

    /**
     * Declare the CATMathPoint2D type in the CSICommands.
     * It streams a MathPoint2DJSImpl.
     */
    var CSIDeclare = function (CSICommands) {
        var serializeMathPoint2D = function (parameter, point) {
            parameter.writeDouble('x', point.x);
            parameter.writeDouble('y', point.y);
        };

        var unserializeMathPoint2D = function (message) {
            var x = message.readDouble('x');
            var y = message.readDouble('y');
            var pt = new MathPoint2D(x, y);
            return pt;
        };

        CSICommands.declareType({
            type: 'CATMathPoint2D',
            serialize: serializeMathPoint2D,
            unserialize: unserializeMathPoint2D,
        });
    };

    return CSIDeclare;
});
