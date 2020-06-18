/**
 * @overview Collection of content models
 * @licence Copyright 2006-2014 Dassault Systèmes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOPartMgt/scripts/Collections/PartContentsCollection', [
		'UWA/Core',
		'UWA/Data',
		'UWA/Utils',
		'UWA/Class/Model',
		'DS/ENOPartMgt/scripts/Models/PartModel',
		'UWA/Class/Collection',
		'DS/TagNavigatorProxy/TagNavigatorProxy',
		'DS/WebAppsFoundations/Collections/PageableCollection',
		'DS/Logger/Logger',
		'DS/WebappsUtils/WebappsUtils',
		'DS/WAFData/WAFData',
		'DS/ENOPartMgt/scripts/PartUtility',
		'DS/ENOPartMgt/scripts/TempPlatformServices',
		'i18n!DS/ENOPartMgt/assets/nls/ENOPartMgtNLS'
	],
	function(
		UWACore,
		UWAData,
		UWAUtils,
		UWAModel,
		PartModel,
		UWACollection,
		TagNavProxy,
		PageableCollection,
		Logger,
		WebappsUtils,
		WAFData,
		PartUtility,
		PlatformServices,
		ENGNLS
	) {
		'use strict';
		var isInitialLoad;

		var predicate = ["ds6w:identifier", "ds6w:type", "ds6wg:revision", "ds6w:policy", "ds6wg:description", "ds6w:status", "ds6w:project", "ds6w:organizationResponsible", "ds6w:originator"];
		var query = 'flattenedtaxonomies:"types/Part" AND (NOT policy : "Manufacturing Part")';
		var fileselect = ["icon", "thumbnail_2d"];
		var order_by = "desc";
		var order_field = "relevance";
		var source = ["3dspace"];
		//var tenant ="OnPremise";
		var tenant =(widget&&(widget.getValue('x3dPlatformId') != '' && widget.getValue('x3dPlatformId') != undefined)&&(UWA.is(widget.getValue('x3dPlatformId'))) )? widget.getValue('x3dPlatformId'):"OnPremise";

		var PartContentsCollection = PageableCollection.extend({


			/* Default options set for pageable collection */
			defaultOptions: {
				mode: 'data',
				headers : {
					"Accept": 'application/json',
					"Content-Type": 'application/json'
				},
				data: {
					with_indexing_date: true,
					with_nls: true,
					locale: 'en',
					select_predicate: predicate,
					select_file: fileselect,
					query: query,
					order_by: order_by,
					label:"",
					order_field: order_field,
					nresults: 40,
					start: "0",
					source: source,
					tenant: tenant
				},
				state: {
					firstPage: 0,
					lastPage: null,
					currentPage: 0,
					pageSize: 40,
					totalPages: null,
					totalRecords: null,
					sortKey: null,
					order: -1,
				},
				queryParams: {
					currentPage: 'page',
					pageSize: 'limit',
					totalRecords: 'member'
				}
			},



			next_start: {},

			taggerProxy: {
				filteringMode: 'WithFilteringServices',
				events: {}
			},

			model: PartModel,
			filterTagObj: null,
			isNewFilter: false,


			_initTaggerProxy: function(options) {
				var that = this,
					taggerOptions, /*tenantUrl,*/ taggerProxy, taggerProxyEvents;

				taggerOptions = this.taggerProxy;

				taggerProxyEvents = this._taggerProxyEvents = {
					'onFilterChange': that.onFilterChange,
					'onFilterSubjectsChange': that.onFilterChange,
					'addUnfocusSubjectsListener': that.onUnfocusSubjects
				};

				if (widget) {
					taggerOptions = UWACore.extend({
						widgetId: widget.id
					}, taggerOptions, true);
				} else {
					//ENOVIA frame context for the 3DSpace standalone app
					taggerOptions = UWACore.extend({
						contextId: 'context1',
						filteringMode: 'WithFilteringServices',
					}, taggerOptions, true);
				}

				taggerProxy = this.taggerProxy = TagNavProxy.createProxy(taggerOptions, taggerProxyEvents);

				this.taggerProxy.addFilterSubjectsListener(that.onFilterChange, that);

				return taggerProxy;
			},

			url: function() {
				return PlatformServices.getPlatformServiceURL('3DSearch') + '/search?xrequestedwith=xmlhttprequest';
			},

			collabSpaceUrl: function() {
				return PlatformServices.get3DSpaceURL();
			},

			parseResponseForStateUpdate: function(resp, queryParams, state, options) {
				this.next_start = resp.infos.next_start;
				return {
					totalRecords: resp.infos.nhits,
				};
			},

			parseRecords: function(resp, options) {
				return resp.results;
			},

			sync: function(method, model, options) {
				WAFData.authenticatedRequest(this.url(),options);
			},

			onFilterChange: function(filterTagObj) {
				console.log('In onFilterChange');
				PartUtility.filterSummaryCollection(filterTagObj);
			},

			activateTaggerProxy: function() {
				var taggerProxy = this.taggerProxy;

				if (!this.taggerProxy) {
					return;
				}

				taggerProxy.activate();
			},

			deactivateTaggerProxy: function() {
				var taggerProxy = this.taggerProxy;

				if (!this.taggerProxy) {
					return;
				}

				taggerProxy.deactivate();
			},

			setSubjectTags: function(model) {
				var resp = model;
				var taggerProxy = this.taggerProxy;
				var subjectTags = {};
				for (var myParts in resp) {
					var parts = resp[myParts];
					var attr = resp[myParts]._attributes;
					var result = {};
					for (var key in parts) result[key] = parts[key];
					for (var key in attr) result[key] = attr[key];
					var instSubjectTags = [];
					for (var key in result) {
						var instSubj = {};
						if (key === 'type') {
							instSubj.sixw = 'ds6w:what/' + ENGNLS.ENG_Type;
							instSubj.type = 'xsd:string';
						}
						if (key === 'policy') {
							instSubj.sixw = 'ds6w:what/' + ENGNLS.ENG_Policy;
							instSubj.type = 'xsd:string';
						}
						if (key === 'state') {
							instSubj.sixw = 'ds6w:what/' + ENGNLS.ENG_State;
							instSubj.type = 'xsd:string';
						}
						if (key === 'project') {
							instSubj.sixw = 'ds6w:where/' + ENGNLS.ENG_Project;
							instSubj.type = 'xsd:string';
						}
						if (key === 'organization') {
							instSubj.sixw = 'ds6w:who/' + ENGNLS.ENG_Organization;
							instSubj.type = 'xsd:string';
						}
						if (key === 'owner') {
							instSubj.sixw = 'ds6w:who/' + ENGNLS.ENG_Owner;
							instSubj.type = 'xsd:string';
						}
						if (instSubj) {
							if (Object.keys(instSubj).length > 0) {
								if (key === 'type') {
									instSubj.dispValue = result[key];
									instSubj.object = result[key];
								}
								if (key === 'policy') {
									instSubj.dispValue = result[key];
									instSubj.object = result[key];
								}
								if (key === 'state') {
									instSubj.dispValue = result[key];
									instSubj.object = result[key];
								}
								if (key === 'project') {
									instSubj.dispValue = result[key];
									instSubj.object = result[key];
								}
								if (key === 'organization') {
									instSubj.dispValue = result[key];
									instSubj.object = result[key];
								}
								if (key === 'owner') {
									instSubj.dispValue = result[key];
									instSubj.object = result[key];
								}
								instSubjectTags.push(instSubj);
							}
						}
					}
					if (instSubjectTags.length) {
						subjectTags[result.id] = instSubjectTags;
					}
				}
				taggerProxy.setSubjectsTags(subjectTags);
			},
			
			addQueryForobjectsBasedOncontext: function() {
				var queryWithContext = query;
				if (enoviaServerENGPartWidget && window.enoviaServerENGPartWidget && window.enoviaServerENGPartWidget.query!=null) {
					queryWithContext = "("+queryWithContext+")AND("+window.enoviaServerENGPartWidget.query+")";
				}
				else if (enoviaServerENGPartWidget && enoviaServerENGPartWidget.securityContext && enoviaServerENGPartWidget.userInfo) {
					queryWithContext = query ;
					//queryWithContext = query + ' AND ((organization:"' + enoviaServerENGPartWidget.organization + '" AND project:"' + enoviaServerENGPartWidget.project + '") OR owner:"' + enoviaServerENGPartWidget.userInfo.login + '")';
				}
				return queryWithContext;
			},
			
			fetch: function(options) {
				var taggerProxy = this.taggerProxy,
					filterTagObj, onComplete, filterTag;
				isInitialLoad = options.isInitialLoad;
				if(isInitialLoad==false){
					this.options.data["next_start"] = this.next_start;
					delete this.options.data["start"];
					this.options.data["label"] = enoviaServerENGPartWidget.userInfo.login;
					this.options.data["locale"]=enoviaServerENGPartWidget.locale;
					this.options.data.query = this.addQueryForobjectsBasedOncontext();
					options.data = JSON.stringify(this.options.data);
				} else {
					this.options.data.query = this.addQueryForobjectsBasedOncontext();
					this.options.data["locale"]=enoviaServerENGPartWidget.locale;
					this.options.data["label"] = enoviaServerENGPartWidget.userInfo.login;
					options.data = JSON.stringify(this.options.data);
				}

				options = options ? UWACore.clone(options, false) : {};


				if (taggerProxy) {

					onComplete = options.onComplete;


					filterTagObj = this.filterTagObj;

					if (filterTagObj) {
						filterTag = {
							tags: JSON.stringify(filterTagObj)
						};
						options.data = (options.data ? UWACore.extend(filterTag, options.data) : filterTag);
					}

					options.onComplete = function(that, resp, options) {
						if(options.isInitialLoad!=false){
							that._initTaggerProxy();
						}

						that.setSubjectTags(that._models);
						options.isInitialLoad = false;
						if (UWACore.is(onComplete, 'function')) {
							onComplete(this, resp, options);
						}
					};

				}

				if (this.currentSearchUrl) {
					options.url = this.currentSearchUrl;
				}
				return this._parent(options);

			}
		});


		return PartContentsCollection;
	});
