define('DS/SMAProcWebCalculator/CalculatorHandler', [
    'DS/SMAProcWebCMMUtils/SMAJSCMMParameterUtils',
    'DS/SMAProcWebCMMCalculator/Parser/SMAProcWebCMMEval'
], function (SMAJSCMMParameterUtils, SMAProcWebCMMEval) {


    var ALLOW_EXCEPTIONAL_VALUES = '#option AllowExceptionalValue\n';

    return {

        validate: function (extensionConfig, parentDataContainer) {

            return new Promise(function (resolve, reject) {
                var prop = extensionConfig.getPropertyByName('expression');
                var expression = extensionConfig.getPropertyValue(prop);
                if (!expression || expression.trim().length == 0) {
                    return reject('Empty script');
                }

                var allowException = false;
                if (expression.indexOf(ALLOW_EXCEPTIONAL_VALUES) > -1) {
                    allowException = true;
                    expression = expression.replace(ALLOW_EXCEPTIONAL_VALUES, '');
                }

                var potentialParameters = SMAJSCMMParameterUtils.getPotentialParameters(parentDataContainer);
                var params = [].concat(potentialParameters.self, potentialParameters.parent, potentialParameters.children, potentialParameters.siblings);

                try {
                    SMAProcWebCMMEval.evaluate(expression, params, parentDataContainer, {
                        restrictUndeclaredParameter: true,
                        allowExceptionalValues: allowException
                    });
                    return resolve('');
                }
                catch (e) {
                    console.log(e);
                    reject('Invalid script');
                }
            });
        }
    };

});
