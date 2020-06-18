/*--------------------------------------------------------------------
[xs-player JS Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:46:05 GMT
Assigned to:	Aravind Mohan
Description:	TODO: Description
---------------------------------------------------------------------*/
/**

	@module SMAProcXS
	@submodule xs-player
	@class xs-player
	@description
        //TODO: Write the description about the component


	@example
	<h5>HTML</h5>

		<!-- Show how this component can be declared -->
		<xs-player>

		</xs-player>

	@example
	<h5>JS</h5>

		//TODO: Show some API example
*/
/* global SPBase*/
(function (window) {
	'use strict';
	var STATE = {
		failing: 'is-failing',
		visible: 'is-visible',
		updating: 'is-updating'
	};
	var platformAPI;
	//Module variables
	/**
    		@class XSPlayer
    		@constructor

    	**/
	window.XSPlayer = window.Polymer({
		is: 'xs-player',
		properties: {
			//Attributes
			simid: {
            	type: String
			},
			mode: {
				type: String
			}
		},

		//Event handlers
		/**
         * Prevent the event since this is Player mode
         * @param {checkdesignmode} event - Triggered by any component to check if it's in design mode
         */
		onProcessDesignModeAction: function (event) {
			event.preventDefault();
		},
		onViewReady: function (event, detail) {
			var definition;
			this.DOM(this).indexNodesById();
			//Get the layout
			definition = window.JSON.parse(detail.response.templateviewdefinition);
			//Paint the layout
			this.$.canvas.paint(definition ? definition.layout : '');
			require(['DS/PlatformAPI/PlatformAPI'], function (PlatformAPI) {
				platformAPI = PlatformAPI;
			});
			this.addEventListener('updatecomplete', function(data) {
				if (data.detail.ioMode === 'InputOutput'){
					platformAPI.publish('DS/SMAProcPS/modify', {physicalId: this.simid});
				}
			});
		},

		onMetaReady: function(event, detail){
			var meta = detail.response;
			Object.keys(meta).forEach(function(key) {
				//If default props should be available
				var defaultProps = meta[key].nodefaultprops ? [] : this._getDefaultProps();
				meta[key].props = meta[key].props.concat(defaultProps);
			}.bind(this));
			this.meta = meta;
		},

		_getDefaultProps: function() {
			return [{
				caption: 'Hidden',
				name: 'hidden',
				title: 'Sets the visibility',
				type: 'boolean',
				choices: [true, false],
				_targetWrapper: true
			}];
		},

		/**Updates updating attribute everytime PLM data state (~ Update panel state) gets changed
         * @param {Object} event [[Description]]
         */
		onDataStateChanged: function (event) {
			//Doing it here explicitly because it couldn't be declaratively data binded
			this.isupdating = event.detail.currentValue === STATE.updating;
		},
		//Methods
		/**
        * Returns the canvas
        * @return {Object} canva instance
        */
		getCanvas: function () {
			return this.$.canvas;
		},
		behaviors: [SPBase],
		_computeUri: function (simid) {
			return 'simulations/' + simid + '/view';
		},
		_computeUri2: function () {
			return this.resolveUrl('../../SMAProcXSWidgets/assets/meta.json');
		},
		reload: function(type){
			this.$.canvas.reloadPLMData(type);
			if (type !== 'COS') {
				//XS-Player failed to update view data when refreshing PS widget, so explicitly calling
				//templateView webservice to get fresh data from server.
				this.$.templateView.getData();
			}
		}
	});
}(this));
