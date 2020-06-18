/*--------------------------------------------------------------------
[xs-components Javascript Document]
Project:        xs
Version:        1.0
Description:    Component List
---------------------------------------------------------------------*/
/* global Polymer*/
(function () {
	'use strict';

	var FONT_ICON, CLASS, WIDGET_MODEL_ID, FLAG;
	FONT_ICON = {
		'xs-wg-button': 'fonticon-progress-0',
		'xs-wg-checkbox': 'fonticon-check',
		'xs-wg-document-chooser': 'fonticon-search',
		'xs-wg-dropdown': 'fonticon-list',
		'xs-wg-heading': 'fonticon-text-icon',
		'xs-wg-input-text': 'fonticon-progress-0',
		'xs-wg-multi-value-textfield': 'fonticon-progress-3',
		'xs-wg-separator': 'fonticon-doc-text-inv',
		'xs-wg-slider': 'fonticon-progress-1',
		'xs-wg-textarea': 'fonticon-doc-text',
		'xs-wg-timestamp': 'fonticon-calendar',
		'xs-wg-3dplay': 'fonticon-play',
		'xs-wg-media': 'fonticon-picture',
		'xs-wg-xyplot': 'fonticon-chart-line ',
		'xs-wg-table': 'fonticon-table',
		'xs-wg-content-viewer': 'fonticon-docs',
		'xs-wg-layout': 'fonticon fonticon-attributes',
		'xs-wg-section': 'fonticon-view-tag-cloud',
		'xs-wg-run': 'fonticon-play',
		'xs-wg-document-manager': 'fonticon-doc-log',
		'xs-wg-reference-manager': 'fonticon-link',
		'xs-wg-navigation': 'fonticon-right',
		'xs-wg-multiselect': 'fonticon-view-small-tile'
	};
	FLAG = {
		'xs-wg-navigation' : 'XS_RUN',
		'xs-wg-multiselect' : 'XS_BETA',
		'xs-wg-3dplay': 'XS_3DPLAY'
	};
	CLASS = {
		ACTIVE: 'active'
	};
	WIDGET_MODEL_ID = 'item';

	// Prototype
	window.Polymer({ // jshint ignore:line
		is: 'xs-components',
		properties: {
			FONT_ICON: {
				value: function() {
					return FONT_ICON;
				}
			},
			meta: {
				type: Object,
				value: {},
				observer: '__metaChanged',
				notify: true
			},
			disabled: {
				type: Boolean,
				value: false,
				notify: true,
				reflectToAttribute: true
			},
			categories: {
				type: Array,
				notify: true
			}
		},

		__metaChanged: function() {

			if (this.meta && !this.meta.$state && this.meta.hasOwnProperty('categories')) {
				//init private data stores to []
				var categories = [];
				this._meta = [];

				Object.keys(this.meta).forEach(function(tagName) {
					var widget = this.meta[tagName];
					widget.tagName = tagName;
					if (this.isValidFlag(tagName)){
						this._meta.push(widget);
					}
				}.bind(this));

				this.meta.categories.value.forEach(function(cat) {
					//Filter widget list if it has to be listed
					cat.widgetlist = this._meta.filter(function(widget) {
						return !widget.nolist &&
                            ((cat.isDefault && widget.category_id === undefined) || widget.category_id === cat.id); // jshint ignore:line

					});
					if (cat.widgetlist.length > 0) {
						//Alphabetic sort
						cat.widgetlist = cat.widgetlist.sort(function(a, b) {
							if (a.caption < b.caption) {
								return -1;
							}
							if (a.caption > b.caption) {
								return 1;
							}
							return 0;
						});
						//Push in category list
						categories.push(cat);
					}
				}.bind(this));
				this.categories = categories;
			}
		},



		onDragStart: function(event) {
			if (!this.disabled) {
				var eventData = JSON.stringify({
					dropType: 'INSERT',
					item: event.model[WIDGET_MODEL_ID].tagName,
					noWrap: event.model[WIDGET_MODEL_ID].nowrap
				});
				event.dataTransfer.setData('text', eventData);
			}
		},

		onToolClick: function(event) {
			if (!this.disabled) {
				this.fire('toolclick', {
					dropType: 'INSERT',
					item: event.model[WIDGET_MODEL_ID].tagName,
					noWrap: event.model[WIDGET_MODEL_ID].nowrap
				});
			}
			event.stopPropagation();
		},

		toogleCollapse: function(event) {
			var model = event.model[this.$.catList.as];
			var category = this.querySelector('div[data-cat-id="' + model.id + '"]');
			if (category && category.classList.contains(CLASS.ACTIVE)) {
				Polymer.dom(category).classList.remove(CLASS.ACTIVE);
			} else {
				category && Polymer.dom(category).classList.add(CLASS.ACTIVE);
			}
			event.stopPropagation();
		},

		isValidFlag: function(tagName){
			if (FLAG.hasOwnProperty(tagName)){
				return (localStorage.getItem(FLAG[tagName]) === 'true');
			} else if(this.meta && this.meta[tagName] && this.meta[tagName].displayFlag) {
				return (localStorage.getItem(this.meta[tagName].displayFlag) === 'true');
			}
			return true;
		},

		_computeDraggable: function(disabled) {
			return !disabled;
		},

		_computeClass: function(widgetTag) {
			if(FONT_ICON[widgetTag]){
				return FONT_ICON[widgetTag] + ' fonticon';
			}
			else if(this.meta && this.meta[widgetTag] && this.meta[widgetTag].fontIcon) return this.meta[widgetTag].fontIcon + ' fonticon';
		}

	});
}(this));
