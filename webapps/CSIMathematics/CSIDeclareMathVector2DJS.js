define('CSIMathematics/CSIDeclareMathVector2DJS', ['MathematicsES/MathVector2DJSImpl'], function (MathVector2D) {
    'use strict';

    /**
     * Declare the CATMathVector2D type in the CSICommands.
     * It streams a MathVector2DJSImpl.
     */
    var CSIDeclare = function (CSICommands) {
        var serializeMathVector2D = function (parameters, vector) {
            parameters.writeDouble('x', vector.x);
            parameters.writeDouble('y', vector.y);

        };

        var unserializeMathVector2D = function (message) {
            var x = message.readDouble('x');
            var y = message.readDouble('y');

            var vector = new MathVector2D(x, y);

            return vector;
        };

        CSICommands.declareType({
            type: 'CATMathVector2D',
            serialize: serializeMathVector2D,
            unserialize: unserializeMathVector2D,
        });
    };

    return CSIDeclare;
});

