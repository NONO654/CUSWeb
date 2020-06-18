(function(GLOBAL) {
    var ArrayTest = {};

    ArrayTest.arrayParamJson =
        '{"@class":"ArrayDataSetVariable","role":"UNKNOWN","notes":null,"comments":null,"elementData":{"x[0][3]":{"min":4,"upperQuartile":4,"median":4,"max":4,"mean":4,"paretoHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"sum":20,"infeasibleHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"stdDev":0,"lowerQuartile":4,"histogramValues":[5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},"x[0][2]":{"min":3,"upperQuartile":3,"median":3,"max":3,"mean":3,"paretoHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"sum":15,"infeasibleHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"stdDev":0,"lowerQuartile":3,"histogramValues":[5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},"x[0][1]":{"min":2,"upperQuartile":2,"median":2,"max":2,"mean":2,"paretoHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"sum":10,"infeasibleHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"stdDev":0,"lowerQuartile":2,"histogramValues":[5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},"x[1][3]":{"min":3,"upperQuartile":33.5,"median":8,"max":55,"mean":17,"paretoHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"sum":1846,"infeasibleHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"stdDev":19.21457779916072,"lowerQuartile":5,"histogramValues":[1,2,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]},"x[1][2]":{"min":2,"upperQuartile":21.5,"median":5,"max":34,"mean":11,"paretoHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"sum":686,"infeasibleHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"stdDev":11.713240371477058,"lowerQuartile":3.5,"histogramValues":[1,2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]},"x[1][1]":{"min":1,"upperQuartile":13.5,"median":3,"max":21,"mean":6.8,"paretoHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"sum":264.79999999999995,"infeasibleHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"stdDev":7.277362159464101,"lowerQuartile":2,"histogramValues":[1,2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]},"x[1][0]":{"min":1,"upperQuartile":8,"median":2,"max":13,"mean":4,"paretoHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"sum":104,"infeasibleHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"stdDev":4.560701700396552,"lowerQuartile":1,"histogramValues":[2,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]},"x[0][0]":{"min":1,"upperQuartile":1,"median":1,"max":1,"mean":"1.00000","paretoHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"sum":5,"infeasibleHistogramValues":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"stdDev":"0.00000","lowerQuartile":1,"histogramValues":[5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"percentiles":["100%","75%","50%","25%","0%"],"percentileNames":["Maximum","Upper Quartile","Median","Lower Quartile","Minimum"],"quantiles":["1.00000","1.00000","1.00000","1.00000","1.00000"],"numValues":5}},"displayName":"x","dataType":"INTEGER","name":"x","ID":"6d272c7e-cc4a-4e7f-ba18-7500577c4cf1","structure":"ARRAY","dimensions":[2,4],"parents":{"depth":0,"parentString":"-root-,"}}';

    ArrayTest.arrayParam = JSON.parse(ArrayTest.arrayParamJson);

    var arrayParam = ArrayTest.arrayParam;

    ArrayTest.xParam = {
        '@class': 'ArrayDataSetVariable',
        ID: arrayParam + '[0]',
        comments: null,
        dataType: 'INTEGER',
        dimensions: [4],
        displayName: 'x[0]',
        elementData: {},
        name: 'x[0]',
        notes: null,
        parents: {}, // not sure what goes here.
        role: 'UNKNOWN',
        structure: 'ARRAY'
    };

    Object.keys(arrayParam.elementData).forEach(function(key) {
        if (key.indexOf('x[0]') !== -1) {
            var newKey = key.slice(0, 1) + key.slice(4);
            ArrayTest.xParam.elementData[newKey] = arrayParam[key];
        }
    });

    ArrayTest.yParam = {
        '@class': 'ArrayDataSetVariable',
        ID: arrayParam + '[1]',
        comments: null,
        dataType: 'INTEGER',
        dimensions: [4],
        displayName: 'x[1]',
        elementData: {},
        name: 'x[1]',
        notes: null,
        parents: {}, // not sure what goes here.
        role: 'UNKNOWN',
        structure: 'ARRAY'
    };

    Object.keys(arrayParam.elementData).forEach(function(key) {
        if (key.indexOf('x[1]') !== -1) {
            var newKey = key.slice(0, 1) + key.slice(4);
            ArrayTest.xParam.elementData[newKey] = arrayParam[key];
        }
    });

    ArrayTest.rowResponse = {
        elements: [
            {
                notes: null,
                rowIndex: 2,
                rowID: 3,
                rowName: '',
                displayProperties: {},
                autoRank: 0,
                userAssignedRank: -1,
                penaltyFunction: 0.0,
                objectiveFunction: 0.0,
                totalScore: 0.0,
                tags: [
                    {
                        name: 'DATA_SET',
                        value: 'DATA_SET_1',
                        id: '15974fcc-0f58-466a-b098-bebade12ce53',
                        version: '1.0'
                    },
                    {
                        name: 'PLMOID',
                        value: '24513.577.10240.65046',
                        id: 'ac94b6f0-6bac-46a4-9a26-f42f29d842da',
                        version: '1.0'
                    }
                ],
                endorsements: [],
                comments: null,
                likes: null,
                grade: 'GRADE_DOMINATED',
                id: '73d9af96-7292-418b-8fda-1f4add0e5c1a',
                version: '1.0',
                parmValues: {
                    '465c9907-6bed-421b-bc5b-48198b8f4b9d': [1, 2, 4, 8],
                    '6d272c7e-cc4a-4e7f-ba18-7500577c4cf1': [
                        [1, 2, 3, 4],
                        [2, 3, 5, 8]
                    ]
                },
                violationFlags: {}
            }
        ]
    };

    GLOBAL.DS.RAObjects.ArrayTest = ArrayTest;
})(this);
