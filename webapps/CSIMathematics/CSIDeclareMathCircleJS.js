define('CSIMathematics/CSIDeclareMathCircleJS', ['MathematicsES/MathNameSpace', 'MathematicsES/MathCircleJSImpl'], function (cgmMath, MathCircle) {
    'use strict';

    /**
     * Declare the CATMathCircle type in the CSICommands.
     * It streams a MathCircleJSImpl.
     */
    var CSIDeclare = function (CSICommands) {
        var serializeMathCircle = function (parameters, circle) {
            var dir = circle.getDirectionsNotCloned();
            parameters.writeObject('center', 'CATMathPoint' , circle.center);
            parameters.writeObject('axis1' , 'CATMathVector', dir[0]       );
            parameters.writeObject('axis2' , 'CATMathVector', dir[1]       );
            parameters.writeDouble('radius', circle.radius);
            parameters.writeDouble('scale' , circle.scale );
            parameters.writeDouble('shift' , circle.shift );
        };

        var unserializeMathCircle = function (message) {
           var circle = new MathCircle();
           var dir = circle.getDirectionsNotCloned();

           circle.center = message.readObject('center', 'CATMathPoint' );
           dir[0]        = message.readObject('axis1' , 'CATMathVector');
           dir[1]        = message.readObject('axis2' , 'CATMathVector');
           circle.radius = message.readDouble('radius');
           circle.scale  = message.readDouble('scale' );
           circle.shift  = message.readDouble('shift' );

           return circle;
        };

        CSICommands.declareType({
            type: 'CATMathCircle',
            serialize: serializeMathCircle,
            unserialize: unserializeMathCircle,
        });
    };

    return CSIDeclare;
});
