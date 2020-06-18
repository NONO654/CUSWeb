/**
 * @overview Define the skeleton options for the content facet.
 * @licence Copyright 2006-2014 Dassault Systemes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define(
	'DS/ENOPartMgt/scripts/SkeletonUtils/PartSkeleton', [
		'UWA/Drivers/Alone',
		'UWA/Core',
		'DS/W3DXComponents/Skeleton',
		'DS/W3DXComponents/Views/EmptyView',
		'DS/W3DXComponents/Views/Layout/GridScrollView',
		'DS/W3DXComponents/Views/Layout/ListView',
		'DS/W3DXComponents/Views/Item/TileView',
		'DS/W3DXComponents/Views/Item/RowView',
		'DS/W3DXComponents/Views/Item/ThumbnailView',
		'DS/W3DXComponents/Views/Layout/TableScrollView',
		'DS/ENOPartMgt/scripts/Views/PropertiesView',
		'DS/ENOPartMgt/scripts/Models/PartModel',
		'DS/W3DXComponents/Collections/ActionsCollection',
		'DS/ENOPartMgt/scripts/Collections/PartContentsCollection',
		'DS/ENOPartMgt/scripts/PartUtility',
		'i18n!DS/ENOPartMgt/assets/nls/ENOPartMgtNLS'
	],
	function(
		UWA,
		UWACore,
		Skeleton,
		EmptyView,
		GridScrollView,
		ListView,
		TileView,
		RowView,
		ThumbnailView,
		TableScrollView,
		PropertiesView,
		PartModel,
		ActionsCollection,
		PartContentsCollection,
		PartUtility,
		ENGNLS
	) {

		'use strict';

		var isInitialLoad = true;
		var contentViews = [{
			'id': 'thumbnail',
			'view': GridScrollView,
			'itemView': ThumbnailView,
			'default': true
		}, {
			'id': 'tile',
			'view': GridScrollView,
			'itemView': TileView,
		}, {
			'id': 'table',
			'view': TableScrollView,
			'itemView': RowView
		}, {
			// List view on the left shown when IdCard is opened
			id: 'list',
			view: ListView,
			selectionMode: 'oneToOne'
		}];



		function onItemViewSelect(a,b) {

			if (widget) {
				widget.setTitle(b.model._attributes.name);
			}
			var bones = enoviaServerENGPartWidget.mySkeleton;
			var collection = bones.getCollectionAt(0);
			collection.deactivateTaggerProxy();

		}

		function onItemViewUnSelect() {

			if (widget) {
				widget.setTitle(ENGNLS.ENG_Part_List);
			}
			var bones = enoviaServerENGPartWidget.mySkeleton;
			var collection = bones.getCollectionAt(0);
			collection.activateTaggerProxy();

		}


		function onInfiniteScroll() {
			var that = this,
				collection = this.collection,fetchOptions = PartSkeleton.getFetchOptions();
			that.container.removeClassName('loading');
			fetchOptions.onComplete = function() {
				if (that.container.offsetParent) {
					that.container.removeClassName('loading');
					Object.keys(that.contentsViews).map(function(value) {
						that.contentsViews[value].scrollView.endLoading();
					});
				}
			};

			if (collection.state.totalRecords === null) {
				collection.getFirstPage(fetchOptions);

			} else {

				if (!this.collection.taggerProxy._attributes.hasFilter) {
					if (collection.hasNextPage()) {
						fetchOptions.isInitialLoad = false;
						collection.getNextPage(UWACore.extend(fetchOptions, {
							remove: false,
							reset: false
						}));
					} else {
						that.container.removeClassName('loading');
						Object.keys(that.contentsViews).map(function(value) {
							that.contentsViews[value].scrollView.useInfiniteScroll(false);
						});
					}

				} else {
					that.container.removeClassName('loading');
					Object.keys(that.contentsViews).map(function(value) {
						that.contentsViews[value].scrollView.useInfiniteScroll(false);
					});
				}

			}

		}

		function onPullToRefresh() {
			var that = this;

			if (!UWACore.is(this.collection.getFirstPage, 'function')) {
				return this.collection.fetch(UWACore.extend({
					onComplete: function() {
						that.scrollView.useInfiniteScroll(false);
						that.scrollView.endLoading();
					}
				}, PartSkeleton.getFetchOptions()));
			}
		}

		var PartSkeleton = {

			getFetchOptions: function() {
				var options = {
					type: 'json',
					reset: true,
					isInitialLoad: isInitialLoad,
					headers : {
						"Accept": 'application/json',
						"Content-Type": 'application/json'
					},
					method : 'POST'
				};

				return options;
			},

			getIdCardOptions: function(config) {
				return {
					collapsed: config.minimizeIdCardView,
					thumbnailUrl: function() {},
					attributesMapping: {
						title: function() {
							var title = this._attributes.name;
							return title;
						}
					},
					actions: function() {
						var arrActions = [];
						arrActions.push({
							text: ENGNLS.ENG_OpenWithCollaborationAndApprovals,
							icon: 'fonticon fonticon-window',
							handler: function(options) {
								console.log('open In Collaborative and Approvals');
								var collection = new PartContentsCollection();
								var z = options.model.id;
								var w = "/common/emxTree.jsp?mode=insert&objectId=" + z;
								var x = "";
								var v = window.open();
								PartUtility.retrieveSecurityContext().then(function(resp) {
									x = collection.collabSpaceUrl() + "/common/emxFrameworkContextManager.jsp?SecurityContext=" + resp.SecurityContext + "&forwardUrl=" + w;
									v.opener = null;
									v.location.href = x;
								});
							}
						});
						return arrActions;
					},
					facets: [{
						name: '0',
						text: ENGNLS.ENG_Properties,
						icon: 'doc-text',
						handler: Skeleton.getRendererHandler(PropertiesView)
					}]
				};
			},

			getContentSetOptions: function() {
				var that = this;
				return {
					className: 'loading',
					contents: {
						selectionMode: 'oneToOne',
						useInfiniteScroll: true,
						headerOnEmpty: false,
						views: contentViews,
						defaultView: 'thumbnail',
						headers: [{
							'property': 'title',
							'icon': 'typeicon',
							'sortable': true,
							'label': ENGNLS.ENG_Name
						}, {
							'property': 'type',
							'label': ENGNLS.ENG_Type
						}, {
							'property': 'revision',
							'label': ENGNLS.ENG_Revision
						}, {
							'property': 'policy',
							'label': ENGNLS.ENG_Policy
						}, {
							'property': 'state',
							'label': ENGNLS.ENG_State
						}, {
							'property': 'project',
							'label': ENGNLS.ENG_Project
						}, {
							'property': 'organization',
							'label': ENGNLS.ENG_Organization
						}, {
							'property': 'owner',
							'label': ENGNLS.ENG_Owner
						}, {
							'label': ENGNLS.ENG_Action,
							'actions': true
						}],
						itemViewOptions: {
							mapping: {
								'title': 'name',
								'subtitle': 'type',
								'content': 'revision',
								'icon': 'typeicon',
								'image': 'picture'
							},
							contextualActions: function() {
								var arrActions = [];
								arrActions.push({
									text: ENGNLS.ENG_OpenWithCollaborationAndApprovals,
									fonticon: 'fonticon fonticon-window',
									handler: function(options) {
										console.log('open In Collaborative and Approvals');
										var collection = new PartContentsCollection();
										var z = options.model.id;
										var w = "/common/emxTree.jsp?mode=insert" + "&objectId=" + z;
										var x = "";
										var v = window.open();
										PartUtility.retrieveSecurityContext().then(function(resp) {
											x = collection.collabSpaceUrl() + "/common/emxFrameworkContextManager.jsp?SecurityContext=" + resp.SecurityContext + "&forwardUrl=" + w;
											v.opener = null;
											v.location.href = x;
										});
									}
								});
								return arrActions;
							},
							icon: 'icon',
							title: ENGNLS.ENG_EmptyContentTitle,
						},

						emptyView: EmptyView,
						events: {
							'onItemViewSelect': onItemViewSelect,
							'onItemViewUnSelect': onItemViewUnSelect
						}
					},
					events: {
						'onPullToRefresh': onPullToRefresh,
						'onInfiniteScroll': onInfiniteScroll
					}
				};
			}
		};

		return PartSkeleton;
	});
