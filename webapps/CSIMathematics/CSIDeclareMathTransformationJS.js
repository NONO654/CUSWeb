define('CSIMathematics/CSIDeclareMathTransformationJS', ['MathematicsES/TransformationJSImpl'], function (MathTransformation) {
    'use strict';

    /**
     * Declare the CATMathTransformation type in the CSICommands.
     * It streams a TransformationJSImpl.
     */
    var CSIDeclare = function (CSICommands) {
        var serializeMathTransformation = function (parameters, transfo) {
            parameters.writeObject('matrix', 'CATMath3x3Matrix', transfo.matrix);
            parameters.writeObject('vector', 'CATMathVector'  , transfo.vector);
        };

        var unserializeMathTransformation = function (message) {
           var matrix = message.readObject('matrix', 'CATMath3x3Matrix');
           var vector = message.readObject('vector', 'CATMathVector'  );

            var transfo = new MathTransformation();
            transfo.matrix = matrix;
            transfo.vector = vector;

            return transfo;
        };

        CSICommands.declareType({
            type: 'CATMathTransformation',
            serialize: serializeMathTransformation,
            unserialize: unserializeMathTransformation,
        });
    };

    return CSIDeclare;
});
