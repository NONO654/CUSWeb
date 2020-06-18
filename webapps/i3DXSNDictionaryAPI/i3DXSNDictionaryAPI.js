/**
 * @overview Deprecated starting 2019xFD02. Please use DS/FedDictionaryAccess/FedDictionaryAccessAPI instead. 
 * @overview Provide seamless access to dictionaries of various data-sources
 * @file 3DXSearchDictionaryAccess provides methods in order for Search app to
 *       access ER- as well as RDF-based dictionaries
 * @licence Copyright 2006-2015 Dassault SystÃƒÂ¨mes company. All rights
 *          reserved.
 * @version 1.0.
 * 
 */

/*global define */

define(
		'DS/i3DXSNDictionaryAPI/3DXSearchDictionaryAccess',
		[ 'UWA/Core', 'UWA/Class', 'UWA/Class/Events',
		// 'DS/PlatformManagementComponents/View/PlatformSelector',
		'DS/PlatformAPI/PlatformAPI',
				'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
				'DS/WAFData/WAFData' ],

		/**
		 * <p>
		 * This module aims at providing APIs to access dictionaries of various
		 * 3DExperience platform services (6WTags, 3DSpace, 3DSwym, RDF,...)
		 * <p>
		 * The exposed APIs return their output asynchronously as data may
		 * require a backend request to be retrieved.
		 * </p>
		 * 
		 * @module DS/i3DXSNDictionaryAPI/3DXSearchDictionaryAccess
		 * @deprecated starting 2019xFD02. Please use DS/FedDictionaryAccess/FedDictionaryAccessAPI instead.
		 */
		function(Core, Class, Events, PlatformAPI, PlatformServices, WAFData) {

			var _3DSpaceBaseURLs = null, _6WTagURLs = null;

			PlatformServices.getServiceUrl({
				serviceName : '3DSpace',
				onComplete : function(data) {
					_3DSpaceBaseURLs = data;
				}
			});
			if (_3DSpaceBaseURLs == null)
				_3DSpaceBaseURLs = PlatformAPI
						.getApplicationConfiguration('app.urls.myapps');

			PlatformServices.getServiceUrl({
				serviceName : '6WTags',
				onComplete : function(data) {
					_6WTagURLs = data;
				}
			});
			if (_6WTagURLs == null)
				_6WTagURLs = PlatformAPI
						.getApplicationConfiguration('app.urls.myapps');

			/**
			 * @deprecated starting 2019xFD02. Please use DS/FedDictionaryAccess/FedDictionaryAccessAPI instead.
			 * @exports DS/i3DXSNDictionaryAPI/3DXSearchDictionaryAccess Module
			 *          for dictionary read API. This file is to be used by
			 *          Search App which needs to access dictionary information
			 *          be it ER or RDF-based.
			 * 
			 */
			var dicoReadAPI = {

				/**
				 * Function getOntologyById To get ontology information given
				 * its Id
				 * 
				 * @param {String}
				 *            ontoId must be under format
				 *            {er|rdf}/onto/{ontoName}.
				 * @returns {JSONObject} the Json object representing the
				 *          ontology.
				 * @author AUW
				 * @deprecated starting 2019xFD02. Please use DS/FedDictionaryAccess/FedDictionaryAccessAPI instead.
				 */
				getOntologyById : function(ontoId, cb) {
					var ontoIdArray = ontoId.split("/");
					var ontoInfo = null;
					if (ontoIdArray.length != 2 || ontoIdArray[0] != "onto") {
						log("### Error: Bad identifier!")
						return ontoInfo;
					}

					var dicoRootURL = _6WTagURL[0].url
							+ "/resources/vocabulary/";
					// WS full URL: onto/{ontoName}
					var fullURL = dicoRootURL + ontoId;
					var dicoRequest = UWA.Data.request(fullURL, {
						headers : {
							"Accept" : "application/json"
						},
						method : "GET",
						proxy : "passport",
						onComplete : function(data) {
							cb.onComplete(data);
						},
						onFailure : function(data) {
							if (cb.onFailure) {
								cb.onFailure(data);
							}
						}
					});
					return ontoInfo;
				},

				/**
				 * @deprecated starting 2019xFD02. Please use DS/FedDictionaryAccess/FedDictionaryAccessAPI instead.
				 */
				get6wTagURL : function(itenantID) {
					var i, sixWTagsURL = "";
					//SGA5 - IR-615135: check 3DSpace URL first
					if (Core.is(_3DSpaceBaseURLs) && Core.is(_3DSpaceBaseURLs, 'array')) {
						for (i = 0; i < _3DSpaceBaseURLs.length; i++) {
							if (_3DSpaceBaseURLs[i].platformId == itenantID) {
								sixWTagsURL = _3DSpaceBaseURLs[i].url;
								break;
							}
						}
					}
					if (!sixWTagsURL && Core.is(_6WTagURLs) && Core.is(_6WTagURLs, 'array')) {
						for (i = 0; i < _6WTagURLs.length; i++) {
							if (_6WTagURLs[i].platformId == itenantID) {
								sixWTagsURL = _6WTagURLs[i].url;
								break;
							}
						}
					}
					return sixWTagsURL;
				},

				/**
				 * Function getElementsNls To get the NLS translation of a set
				 * of vocabularies elements
				 * 
				 * @param {JSONObject}
				 *            elementsNames URI's of required elements,
				 *            separated by a comma. options: object containing at
				 *            least onComplete and onFailure function that are
				 *            called when the elements are retrieved or when an
				 *            error occurs
				 * @returns {String} NLS name of the property as string.
				 * @author AUW
				 * @deprecated starting 2019xFD02. Please use DS/FedDictionaryAccess/FedDictionaryAccessAPI instead.
				 */
				getElementsNls : function(elementsNames, options) {

					var language = '';
					if (Core.is(options.lang, 'string')
							&& options.lang.length > 0)
					    language = options.lang;
					else
						language = widget.lang;

					var storageName = "ElementsNLSNames" + language;
					var localValues = sessionStorage.getItem(storageName);
					if (!localValues)
						localValues = {};
					else
						localValues = JSON.parse(localValues);
					var missingVals = "";
					var res = {};

					var reqElts = elementsNames.split(",");

					// get local values that are asked, if any
					if (localValues != null) {
						for (var i = 0; i < reqElts.length; i++) {
							var uri = reqElts[i];
							if (localValues[uri] != null
									&& localValues[uri] != undefined)
								res[uri] = localValues[uri];
							else
								missingVals += (uri + ",");
						}
					} else {
						missingVals = elementsNames;
						sessionStorage.setItem(storageName, "");
					}

					// now, we get the missingValues from WS call
					if (missingVals != "") {
						// remove last ","
						missingVals = missingVals.substring(0,
								missingVals.length - 1);

						var baseURL = null;
						var that = this;
						var tenantID = '', SixWTagURL = '';
						if (options.tenantId)
						    tenantID = options.tenantId;

						if (Core.is(options.TagURL6WId, 'string')
                                && options.TagURL6WId.length > 0)
						    SixWTagURL = options.TagURL6WId;

						else
						    SixWTagURL = this.get6wTagURL(tenantID);

						this.loadElementsNLS(missingVals, SixWTagURL,
                                            options);

						/*PlatformServices.getServiceUrl({
							serviceName : '3DSpace',
							platformId : tenant,
							onComplete : function(data) {
								baseURL = data[0].url;
								that.loadElementsNLS(missingVals, baseURL,
										options);
							
							},
							onFailure : function(data) {
							    if (options.onFailure) {
							        options.onFailure(data);
								}
							}
						});*/
					} else
					    options.onComplete(localValues);

				},
				/**
				 * @deprecated starting 2019xFD02. Please use DS/FedDictionaryAccess/FedDictionaryAccessAPI instead.
				 */
				loadElementsNLS: function (elementsNames, baseURL, options) {

					// /
					var dicoRootURL = baseURL
							+ "/resources/6WVocab/access/ElementsNLSNamesNew";

					//ZUR IR-569034-3DEXPERIENCER2018x
					if (Core.is(options.tenantId, 'string')
							&& options.tenantId.length > 0)	{
						dicoRootURL += "?tenant=" + options.tenantId;
				    }

					var headers = {};
					headers['Accept-Language'] = options.lang;
					headers['Content-Type'] = '';
					headers['Accept'] = 'application/json, text/plain'; 

					var language = options.lang;
					var storageName = "ElementsNLSNames" + language;

					var localValues = sessionStorage.getItem(storageName);
					if (!localValues)
						localValues = {};
					else
						localValues = JSON.parse(localValues);

					WAFData.authenticatedRequest(dicoRootURL, {
						method : 'POST',
						headers : headers,
						timeout : 6000,
						data : elementsNames,
						onComplete : function(response) {
							var responseParse = JSON.parse(response);

							for ( var elt in responseParse) {
								localValues[elt] = responseParse[elt];
							}
							sessionStorage.setItem(storageName, JSON
									.stringify(localValues));
							options.onComplete(localValues);
						},
						onFailure : function(data) {
							// SGA5 IR-646725 18/07/12 If missing elements cannot be retrieved but cached ones are OK, trigger onComplete with correct elements
							console.error("NLS retrieval failed >> " + elementsNames);
							if (localValues && Object.keys(localValues).length > 0)
								options.onComplete(localValues);
							else if (options.onFailure) {
						        options.onFailure(data);
							}
						}
					});

					// ///
				},

				/**
				 * Function getNlsOfPropertiesValues To get the NLS translation
				 * of a set of properties values
				 * 
				 * @param {JSONObject}
				 *            propsValsKeys the id format depends on
				 *            meta-language and type of the resource. - For RDF
				 *            class: it must look like
				 *            rdf/prop/{ontoName}/{propName} - For ER class: it
				 *            must look like rdf/prop/{propName}
				 * @returns {String} NLS name of the property as string.
				 * @author AUW
				 * @deprecated starting 2019xFD02. Please use DS/FedDictionaryAccess/FedDictionaryAccessAPI instead.
				 */
				getNlsOfPropertiesValues : function(propsValsKeys, options) {
					if (!Core.is(options, 'object')
							|| !Core.is(options.onComplete, 'function'))
						return;

					if (!propsValsKeys || propsValsKeys === undefined) {
						options.onComplete();
						return;
					}

					var language = '';
					if (Core.is(options.lang, 'string')
							&& options.lang.length > 0)
						language = options.lang;
					else
						language = widget.lang;

					var missingValues = this.loadLocal(propsValsKeys, options);

					/*
					 * var dicoRootURL = PlatformAPI
					 * .getApplicationConfiguration('app.urls.myapps') +
					 * "/resources/6WVocab/access/PredicateValue";
					 */

					var tenantID = '', SixWTagURL = '';
					if (Core.is(options.tenantId, 'string')
							&& options.tenantId.length > 0)
						tenantID = options.tenantId;
					else
						tenantID = "defaultPredValuesTenant";

					var storageName = "PredsValue" + tenantID + language;

					// nothing's missing
					if (Object.keys(missingValues).length == 0) {
						var asked = JSON.parse(propsValsKeys);

						var res = {};
						var pred;
						var localValues = JSON.parse(sessionStorage
								.getItem(storageName));
						var namesPreds = Object.keys(asked);

						for (var i = 0; i < namesPreds.length; i++) {
							pred = namesPreds[i];
							res[pred] = localValues[pred];
						}
						/*
						 * cbFunc .onComplete(JSON .parse(sessionStorage
						 * .getItem(storageName)));
						 */
						options.onComplete(res);
						return;
					}
					// some things are missing
					// Add for TagURL6WId
					if (Core.is(options.TagURL6WId, 'string')
							&& options.TagURL6WId.length > 0)
						SixWTagURL = options.TagURL6WId;

					else
						SixWTagURL = this.get6wTagURL(tenantID);

					var dicoRootURL = SixWTagURL
							+ "/resources/6WVocab/access/PredicateValue"
							+ "?tenant=" + tenantID;

					// WS URL for RDF property:
					// rdf/prop/{ontoName}/{propName}/domain
					var headers = {
						Accept : 'application/json'
					};
					headers['Content-Type'] = 'application/json';
					// headers['Accept-Language'] = widget.getValue('lang');
					headers['Accept-Language'] = language;

					WAFData
							.authenticatedRequest(
									dicoRootURL,
									{
										method : 'POST',
										headers : headers,
										timeout : 6000,
										data : JSON.stringify(missingValues),
										type : 'json',
										onComplete : function(response) {

											function addtoLocal(response) {
												if (!window.sessionStorage)
													return;
												var localValues = sessionStorage
														.getItem(storageName);
												if (!localValues)
													localValues = {};
												else
													localValues = JSON
															.parse(localValues);

												var dwnlded_preds = response;

												for ( var pred in dwnlded_preds) {
													for ( var val in dwnlded_preds[pred]) {
														if (!localValues
																.hasOwnProperty(pred))
															localValues[pred] = dwnlded_preds[pred];

														localValues[pred][val] = dwnlded_preds[pred][val];
													}
												}
												sessionStorage
														.setItem(
																storageName,
																JSON
																		.stringify(localValues));

											}

											addtoLocal(response);
											var asked = JSON
													.parse(propsValsKeys);

											var res = {};
											var pred;
											var localValues = JSON
													.parse(sessionStorage
															.getItem(storageName));
											var namesPreds = Object.keys(asked);

											for (var i = 0; i < namesPreds.length; i++) {
												pred = namesPreds[i];
												res[pred] = localValues[pred];
											}
											/*
											 * cbFunc .onComplete(JSON
											 * .parse(sessionStorage
											 * .getItem(storageName)));
											 */
											options.onComplete(res);

										},
										onFailure : function(data) {
											if (options.onFailure) {
												options.onFailure(data);
											}
										}

									});
					return;
				},

				/**
				 * @deprecated starting 2019xFD02. Please use DS/FedDictionaryAccess/FedDictionaryAccessAPI instead.
				 */
				loadLocal : function(predsKeys, options) {

					if (!window.sessionStorage) {
						return JSON.parse(predsKeys);
					}

					if (!Core.is(options, 'object')) {
						return JSON.parse(predsKeys);
					}

					var language = '';
					if (Core.is(options.lang, 'string'))
						language = options.lang;
					else
						language = widget.lang;

					var tenantID = '';
					if (Core.is(options.tenantId, 'string')
							&& options.tenantId.length > 0)
						tenantID = options.tenantId;
					else
						tenantID = "defaultPredValuesTenant";

					var storageName = "PredsValue" + tenantID + language;

					var localValues = sessionStorage.getItem(storageName);
					if (!localValues) {
						return JSON.parse(predsKeys);
					} else
						localValues = JSON.parse(localValues);

					var predicatesValues = JSON.parse(predsKeys);

					var preds = [];
					var to_dwnld = {};
					var pred, predVals, vals, local_pred;
					if (predicatesValues === undefined)
						return;

					var namesPreds = Object.keys(predicatesValues);

					for (var i = 0; i < namesPreds.length; i++) {
						pred = namesPreds[i];
						// console.log("ask for predicate: " + pred);
						var localPred = localValues[pred];
						var retr = {};
						if (!localPred) {
							/*
							 * console .log("predicate not retrieved in local ->
							 * need to call WS: " + pred);
							 */
							to_dwnld[pred] = predicatesValues[pred];
						} else {
							// console.log("predicat found in local: " + pred);
							var searchedVals = predicatesValues[pred];
							var nbSearchedVals = searchedVals.length;
							var obj = {};
							vals = new Array();
							for (var j = 0; j < nbSearchedVals; j++) {
								var tmp = searchedVals[j];
								// console.log("looking for value: " + tmp);
								var loc = localPred[tmp];
								if (loc) {
									/*
									 * console .log("retrieved local value: " +
									 * loc);
									 */
								} else {
									/*
									 * console.log("value not retrieved: " + tmp + "
									 * adding it to to_dwnld");
									 */
									vals.push(searchedVals[j]);
								}
							}
							if (vals.length) {
								to_dwnld[pred] = vals;
							}
						}
					}
					return to_dwnld;
				}
			};
			return dicoReadAPI;
		});
