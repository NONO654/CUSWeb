define('DS/ENOPartMgt/ENOGlobalSearchPartActions', ['UWA/Class',
        'UWA/Class/Debug',
        'UWA/Class/Events',
		'DS/WAFData/WAFData',
		'DS/SNInfraUX/SearchUtils',
        'i18n!DS/ENOPartMgt/assets/nls/ENOPartMgtNLS'
    ],
    function(UWAClass,
        UWADebug,
        UWAEvents,
		WAFData,
		SearchUtils,
		NLS
    ) {
        'use strict';
        var sCsrfServiceURL = '/resources/v1/application/E6WFoundation/CSRF';
        var sPartServiceURL = '/resources/v2/partmodeler/parts';
		var securityContext;
		
        var ActionsHandler = UWAClass.singleton(UWAEvents, UWADebug, {
            executeAction: function(actions_data, ui_element_data) {
				var that = this;
				if (!UWA.is(actions_data, 'object') || !UWA.is(actions_data.object_ids, 'array') ||
                    !UWA.is(actions_data.action_id, 'string') || !actions_data.actionsHelper) {
                    throw (NLS.InvalidInputToHandler);
                }

                var partActionHelper = actions_data.actionsHelper;
                
				switch (actions_data.action_id) {
					
					case 'PartSearchDelete':
					{
						var deleteGO = confirm(NLS.DeleteWarning);
						if(deleteGO) {
							var fetchOptions = {
								'method': 'POST',
								'headers': {
									'Accept': 'application/json, application/xml',
									'Content-Type': 'application/json'
								}
							};
							var csrfOptions = {
								'method': 'GET',
								'headers': {
									'Accept': 'application/json, application/xml',
									'Content-Type': 'application/json'
								}
							};
							var payLoadPartService = {
								data:[{"updateAction": "DELETE","id":actions_data.object_ids.join()}]
							}

							partActionHelper.getServiceURL({
								'id': actions_data.object_ids[0],
								'onComplete': function (baseUrl) {
									if (UWA.is(baseUrl, 'string')) {
										//Get CSRF token 
										csrfOptions.url = baseUrl + sCsrfServiceURL;
										csrfOptions.onComplete = function (response, headers) {
											that._initSecurityContext(actions_data,baseUrl);
											SearchUtils.getSecurityContextPromise().then(function () {
												securityContext = SearchUtils.getSecurityContext();
												fetchOptions.url = baseUrl + sPartServiceURL;
												var res = JSON.parse(response);
												payLoadPartService.csrf = res.csrf;
												fetchOptions.data = JSON.stringify(payLoadPartService);
												if (securityContext && securityContext.trim().length > 0) {
													fetchOptions.headers.SecurityContext = "ctx::"+securityContext;
												}
												fetchOptions.onComplete = function (response, headers) {
													//remove the results from the UI
													partActionHelper.deleteResults({
														"ids": actions_data.object_ids
													});
													
													partActionHelper.displayAlert({"message":NLS.PartDeleteSuccess,"className":"success"});
												},
												fetchOptions.onFailure = function (error, response, headers) {
													var joPartDeleteResponse = JSON.parse(response);
													partActionHelper.displayAlert({"message":(joPartDeleteResponse.internalError == undefined ? NLS.PartDeleteError : joPartDeleteResponse.internalError),"className":"error"});
												}
					
												WAFData.authenticatedRequest(fetchOptions.url, fetchOptions);
											});
										}
										csrfOptions.onFailure = function (error, response, headers) {
											var joCSRFResponse = JSON.parse(response);
											partActionHelper.displayAlert({"message":(joCSRFResponse.internalError == undefined ? NLS.PartSpecDeleteError : joCSRFResponse.internalError),"className":"error"});
										}
										WAFData.authenticatedRequest(csrfOptions.url, csrfOptions);
									}
								}
							});
							
						} else {
							partActionHelper.displayAlert({"message":NLS.PartDeleteCancelled,"className":"warning"});
						}
					}
					break;
                }
            },
			
			_initSecurityContext: function(options, url){
			  SearchUtils.initSecurityContext({
				'url': url,
				'tenant': options.actionsHelper.getPlatformID({
				  'id':options.object_ids[0]
				})
			  });
			}
        });
        return ActionsHandler;
    }
);
