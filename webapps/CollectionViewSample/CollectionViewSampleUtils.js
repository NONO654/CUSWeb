define('DS/CollectionViewSample/CollectionViewSampleUtils', [
    'DS/TreeModel/TreeDocument',
    'DS/TreeModel/TreeNodeModel'
], function (TreeDocument, TreeNodeModel) {

    var _states = ['Study', 'In Work', 'Released', 'Obsolete'];
    var _instanceNames = ['Right Front Propeller', 'Left Front Propeller', 'Rear Right Propeller', 'Rear Left Propeller'];
    var _variants = ['Variant A', 'Variant B', 'Variant C', 'Variant D', 'Variant E', 'Variant F', 'Variant G', 'Variant H'];

    return {
        createBaseTileViewData: function () {
            var treeDocument = new TreeDocument({
                useAsyncPreExpand: true
            });
            var nodes = [];

            for (var i = 0; i < 5000; i++) {
            	var state = _states[Math.floor(Math.random() * 4)];
            	var instanceName = _instanceNames[Math.floor(Math.random() * 4)];

                nodes.push(new TreeNodeModel({
                    data: {
                        shading: '#0099cc', 
                        disabled: (Math.random() > 0.9) ? true : false,
                        isSelected: false,
                        isActive: false,
                        title: 'Propeller Red T' + i,
                        version: 'v' + Math.floor(Math.random() * 5),
                        primaryAttribute: {name: 'State', value: state},
                        secondaryAttribute: instanceName,
                        attributes: [
                            {name: 'Owner', value: 'Brad SPACEY'},
                            {name: 'Part Number', value: 'A-0000158-01'},
                            {name: 'Creation', value: '01/05/2016'},
                            {name: 'Last Modification', value: '01/05/2016'},
                            {name: 'Material', value: 'Plastic'}
                        ],
                        _allAttributes: [
                        	{name: 'State', value: state},
                        	{name: 'Instance Name', value: instanceName},
                            {name: 'Owner', value: 'Brad SPACEY'},
                            {name: 'Part Number', value: 'A-0000158-01'},
                            {name: 'Creation', value: '01/05/2016'},
                            {name: 'Last Modification', value: '01/05/2016'},
                            {name: 'Material', value: 'Plastic'}
                        ],
                        dropdown: {
                            items: [
                                {text: 'Action', fonticon: 'switch'},
                                {text: 'Another action', fonticon: 'cw'},
                                {text: 'Something else here' }
                            ]
                        },
                        thumbnail: 'data:image/png;base64,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'
                    }
                }));
            }

            return nodes;
        },

        createExpandableTileViewData: function () {
            var treeDocument = new TreeDocument({
                useAsyncPreExpand: true
            });

            var nodes = [];
            nodes.push(new TreeNodeModel({
                data: {
                    shading: '#0099cc',
                    isSelected: false,
                    isActive: false,
                    title: 'Wheel01',
                    version: 'A.1',
                    primaryAttribute: '2 instances',
                    thumbnail: 'data:image/png;base64,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',
                    attributes: [{
                        name: 'State',
                        value: 'In Work'
                    }, {
                        name: 'Part Number',
                        value: 'None',
                    }, {
                        name: 'Creation Date',
                        value: '10/25/2017'
                    }, {
                        name: 'Modification Date',
                        value: '10/25/2017'
                    }, {
                        name: 'Owner',
                        value: 'A2N'
                    }],
                    dropdown: {
                        items: [
                            { text: 'Action', fonticon: 'switch' },
                            { text: 'Another action', fonticon: 'cw' },
                            { text: 'Something else here' },
                            { className: "divider" },
                            { text: 'Header example', className: 'header' },
                            { text: 'Action', fonticon: 'camera' }
                        ],
                    }
                }}), new TreeNodeModel({
                    data: {
                        shading: '#0099cc',
                        isSelected: false,
                        isActive: false,
                        title: 'Wheel03',
                        version: 'A.4',
                        primaryAttribute: '3 instances (!)',
                        thumbnail: 'data:image/png;base64,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',
                        attributes: [{
                            name: 'State',
                            value: 'Released'
                        }, {
                            name: 'Part Number',
                            value: 'None',
                        }, {
                            name: 'Creation Date',
                            value: '10/2/2017'
                        }, {
                            name: 'Modification Date',
                            value: '10/2/2017'
                        }, {
                            name: 'Owner',
                            value: 'OB'
                        }]
                    }
                })
            );

            /** Add occurences */
            nodes[0].addChild(new TreeNodeModel({
                data: {
                    primaryAttribute: 'Right Front Wheel',
                    secondaryAttribute: 'Effectivity 1',
                    dropdown: {
                        items: [
                            { text: 'Action', fonticon: 'switch' },
                            { text: 'Another action', fonticon: 'cw' }
                        ],
                    }
                }
            }));
            nodes[0].addChild(new TreeNodeModel({
                data: {
                    primaryAttribute: 'Left Front Wheel',
                    secondaryAttribute: 'Effectivity 2'
                }
            }));
            nodes[1].addChild(new TreeNodeModel({
                data: {
                    primaryAttribute: 'Right Rear Wheel',
                    secondaryAttribute: 'Effectivity 3'
                }
            }));
            nodes[1].addChild(new TreeNodeModel({
                data: {
                    primaryAttribute: 'Left Rear Wheel',
                    secondaryAttribute: 'Effectivity 4'
                }
            }));

            return nodes;
        }
    };
});
