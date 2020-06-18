define('CSIMathematics/CSIDeclareMathLine2DJS', ['MathematicsES/MathNameSpace', 'MathematicsES/MathLine2DJSImpl'], function (cgmMath, MathLine2D) {
    'use strict';

    /**
     * Declare the CATMathLine2D type in the CSICommands.
     * It streams a MathLine2DJSImpl.
     */
    var CSIDeclare = function (CSICommands) {
        var serializeMathLine2D = function (parameters, line) {
            var scale = line.scale;
            if (scale < 1e-15)
                throw ("CSIDeclareMathLine2D : the scale is null");
            var directionNormalized = DSMath.Vector2D.multiplyScalar(line.direction, 1. / scale);

            parameters.writeObject('origin'   , 'CATMathPoint2D', line.origin);
            parameters.writeObject('direction', 'CATMathVector2D', directionNormalized);
            parameters.writeDouble('scale', scale);
        };

        var unserializeMathLine2D = function (message) {
           var origin    = message.readObject('origin', 'CATMathPoint2D');
           var direction = message.readObject('direction', 'CATMathVector2D');
           var scale     = message.readDouble('scale');

            var line = new MathLine2D(origin, direction);
            line.scale = scale;

            return line;
        };

        CSICommands.declareType({
            type: 'CATMathLine2D',
            serialize: serializeMathLine2D,
            unserialize: unserializeMathLine2D,
        });
    };

    return CSIDeclare;
});
