(function(GLOBAL) {
    var ChartUtils = {};

    ChartUtils.getParametersAsFlatList = function(group) {
        var params = group.parameters || [];

        if (group.groups instanceof Array) {
            group.groups.forEach(function(group) {
                params = params.concat(
                    ChartUtils.getPArametersAsFlatList(group)
                );
            });
        }

        return params;
    };

    ChartUtils.getSubarrayParam = function(arrayParam, indices) {
        var indexString = JSON.stringify(indices);

        var param = {
            ID: arrayParam.ID + indexString,
            dataType: arrayParam.dataType,
            dimensions: arrayParam.dimensions.slice(indices.length),
            displayName: arrayParam.displayName + indexString,
            elementData: {},
            name: arrayParam.name + indexString,
            role: arrayParam.role,
            structure: 'ARRAY'
        };

        if (typeof arrayParam.elementData !== 'undefined') {
            Object.keys(arrayParam.elementData).forEach(function(key) {
                if (key.indexOf(arrayParam.ID + indexString) !== -1) {
                    elementData[key] = arrayParam.elementData[key];
                }
            });
        }

        return param;
    };

    GLOBAL.DS.RAObjects.ChartUtils = ChartUtils;
})(this);
