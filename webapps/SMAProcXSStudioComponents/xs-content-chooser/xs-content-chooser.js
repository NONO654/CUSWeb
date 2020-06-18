/*!  Copyright 2015 Dassault Systemes. All rights reserved. */
/**
 * @description xs-content-chooser displays a text box for selecting any object type
 *
 * @class element:xs-content-chooser
 * @noinstancector
 * @example
 * Display a document selector:
 * &lt;xs-content-chooser object-id="SAMPLE_ID" object-title="Sample title">&lt;/xs-content-chooser>
 * Display a read only document
 * &lt;xs-content-chooser object-id="SAMPLE_ID" object-title="Sample title readonly" readonly>&lt;/xs-content-chooser>
 * Display a reference content chooser for type Requirements and DOCUMENTS
 * &lt;xs-content-chooser object-id="SAMPLE_ID" object-title="Sample title - requirement and DOCUMENTS" accept="Requirement,DOCUMENTS">&lt;/xs-content-chooser>
 */
/* global*/
(function (window) {
	'use strict';
	window.Polymer({  // jshint ignore:line
		is: 'xs-content-chooser',
		properties: {
			/**
             * This attribute indicates the types of PLM objects the server accepts.
             * The value must be a comma-separated list of unique content type specifiers
             * @type {String}
             * @memberof element:xs-content-chooser#
             */
			accept: {
				type: String,
				value: 'DOCUMENTS',
				notify: true
			},
			/**
             * PLM object ID of the selected content
             * @type {String}
             * @memberof element:xs-content-chooser#
             */
			objectId: {
				type: String,
				notify: true,
				value: null
			},
			placeholder: {
				type: String,
				notify: true,
				value: 'Select Document...'
			},
			objectTitle: {
				type: String,
				notify: true
			},
			name: {
				type: String,
				notify: true
			},
			searchString: {
				type: String,
				notify:true
			},
			value: {
				type: Object,
				notify:true
			}
		},

		listeners: {
			drop: 'onDrop',
			dragover: 'onDragOver',
			dragleave: 'onDragLeave',
			close: 'onClose'
		},

		ready: function(){
			this.displayName = null;
		},
		launchSearch: function () {
			if (this.hasAttribute('readonly')){
        	  return;
			}

			this.$.objectSearch.search(this.searchString);
			//
			//this.$.objectSearch.search("");
			// this.selectResult({
			//   objectId : '123123',
			//   objectType: 'Simulation Process',
			//   displayName : 'My Document'
			// });
		},

		onClose: function(event) {
            event.stopPropagation && event.stopPropagation();
            event.stopImmediatePropagation && event.stopImmediatePropagation();
		},
		
		onSearchResultChange: function (results) {
			results.preventDefault();
			results.stopPropagation();
			var selectedObjects = results.detail.getSelectedObjects();
			if (selectedObjects && selectedObjects[0]) {
				this.selectResult(selectedObjects[0]);
			}
		},

		selectResult: function (result) {
			this.value = result;
			this.displayName = result.displayName;
			this.fire('change', {});
		},

		setObject: function(objectdata){
			this.value = objectdata;
			this.displayName = objectdata.displayName;
			this.fire('change', {});
		},

		resetObject: function(){
			this.displayName = null;
			this.value = null;
		},

		clearObject: function(){
			if (this.hasAttribute('readonly')){
        	return;
			}

			this.resetObject();
			this.fire('clear', {});
		},

		onDragOver: function (event) {
			event.stopPropagation();
			event.preventDefault();
			this.$.container.classList.add('drop');
		},

		onDrop: function (event) {
			var parsedData;
			this.onDragLeave(event);
			try {
				var data = event.dataTransfer.getData('text');
				parsedData = JSON.parse(data);
			} catch (e) {
				parsedData = null;
			}
			if (parsedData && parsedData.data && parsedData.data.items) {
				var value = parsedData.data.items[0];
				if (value.objectType === 'Simulation' || value.objectType === 'Simulation Activity') {
					this.displayName = value.displayName;
					this.value = value;
					this.fire('change', {});
				} else {
					this.showInvalidDrop();
				}
			} else {
				this.showInvalidDrop();
			}
		},

		showInvalidDrop: function() {
			//
		},

		onDragLeave: function (event) {
			event.stopPropagation();
			event.preventDefault();
			this.$.container.classList.remove('drop');
		},

		behaviors: [window.DS.SMAProcSP.SPBase]
	});
}(this));
