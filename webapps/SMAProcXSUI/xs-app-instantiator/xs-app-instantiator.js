(function () {
	'use strict';

	var queryStringParser,
		xsInstantiator,

        // Methods
		initializeInstantiator;

	queryStringParser = document.getElementById('querystringParser');
	xsInstantiator = document.getElementById('instantiator');

    /**
     * Initialize xs-designer attributes based on the parameters Experience studio is launched with
     * @param {Object} params - Object containing all information designer needs
     */
	initializeInstantiator = function (params) {
		var templateData = {
			objectId: params.templateId,
			displayName: params.templateTitle
		};
		if (params.parentOID !== null && params.parentOID !== undefined && params.parentOID.length > 0 && params.parentOID !== params.templateId) {
			templateData.parentOID = params.parentOID;
		}
		xsInstantiator.templateData = templateData;
	};

    /* Register an event listener for WebComponentsReady which indicates
    *all polymer element have been registered/upgraded
    */
	window.addEventListener('WebComponentsReady', function () {
		initializeInstantiator(queryStringParser.params);
	});
}());
