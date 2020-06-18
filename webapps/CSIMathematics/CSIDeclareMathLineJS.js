define('CSIMathematics/CSIDeclareMathLineJS', ['MathematicsES/MathNameSpace', 'MathematicsES/MathLineJSImpl'], function (cgmMath, MathLine) {
    'use strict';

    /**
     * Declare the CATMathLine type in the CSICommands.
     * It streams a MathLineJSImpl.
     */
    var CSIDeclare = function (CSICommands) {
        var serializeMathLine = function (parameters, line) {
            var scale = line.scale;
            if (scale < 1e-15)
                throw ("CSIDeclareMathLine : the scale is null");
            var directionNormalized = DSMath.Vector3D.multiplyScalar(line.direction, 1. / scale);

            parameters.writeObject('origin'   , 'CATMathPoint', line.origin);
            parameters.writeObject('direction', 'CATMathVector', directionNormalized);
            parameters.writeDouble('scale', scale);
        };

        var unserializeMathLine = function (message) {
           var origin    = message.readObject('origin', 'CATMathPoint');
           var direction = message.readObject('direction', 'CATMathVector');
           var scale     = message.readDouble('scale');

            var line = new MathLine(origin, direction);
            line.scale = scale;

            return line;
        };

        CSICommands.declareType({
            type: 'CATMathLine',
            serialize: serializeMathLine,
            unserialize: unserializeMathLine,
        });
    };

    return CSIDeclare;
});
