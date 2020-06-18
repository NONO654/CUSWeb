/*--------------------------------------------------------------------
[xs-widget-binder Javascript Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:46:01 GMT
Assigned to:	Aravind Mohan
Description:    Executes the bindings on UI elements
Connects with:  xs-canvas, xs-wg-item, xs-wg-plm-data
---------------------------------------------------------------------*/
/**
	@module SMAProcXSUI

	@example
		TODO: Provide example on how to use this element
*/
/* global DS, Polymer*/
(function () {
	'use strict';
	var InfoItem;
	//Except description everything is optional
	//@constructor
	//root @Array
	//info @Object
	InfoItem = function (id, info) {
		this.description = info.description;
		this.title = info.title || 'Unknown source';
		this.type = info.type || 'error';
		this.focus = info.focus;
		this.isMandError = info.isMandError;
		this.id = id;
	};

	InfoItem.Init = function () {
		InfoItem._instances = {};
	};

	//Prototype
	Polymer({ // jshint ignore:line
		is: 'xs-info-summary',
		properties: {
			//Attributes
			//Private
			_errorCount: {
				type: Number,
				value: 0
			},
			_warningCount: {
				type: Number,
				value: 0
			},
			infos: {
				notify: true,
				value: []
			},
			_infosIndex: {
				type: Object,
				value: {}
			},
			InfoItemType: {
				value: {
					warning: 'warning',
					error: 'error'
				}
			}
		},
		//Private Methods
		attached: function () {
			// With refrence to IR-633592-3DEXPERIENCER2019x, emptying global variable used in this component as it was storing wrong values from previous run.
			this.infos= [];
			this._infosIndex={};
		},

		/**
         * Pops up information dialog when the Experience status icon is clicked to show more details
         * @param {click} event - Triggered on clicking Experience status icon
         */
		_onShowSummary: function () {
			this.$.modal.show();
		},
		_onClick: function (event) {
			var focus = event.model.item.focus;
			//Hide the dialog
			this.$.modal.hide();
			if (focus) {
				//Set the focus
				focus(event.model.item);
			}
		},
		//Public methods
		/**
               *
         * Returns true if there are any recorded errors
         * @public
               * @return Boolean
              */
		hasErrors: function () {
			return Boolean(this._errorCount);
		},
		createInfoItem: function (id, info) {
			//Get the info item if it already exists
			var infoItem = this._infosIndex[id];

			//Clear if it is forced and has an instance clear it
			if (info.force && infoItem) {
				this.clear(id);
				infoItem = null;
			}
			//If such info item was not yet created
			if (!infoItem) {
				var infoItem = new InfoItem(id, info);
				this.push('infos', infoItem);
				//Add it to the index
				this._infosIndex[id] = infoItem;
				//If it was an error which was recorded
				if (infoItem.type === this.InfoItemType.error) {
					this._errorCount++;
				} else {
					this._warningCount++;
				}
			}

			return infoItem;
		},
		clear: function (id) {
			var infoItem = this._infosIndex[id],
				index = 0;

			if (infoItem) {
				this.infos.every(function (info) {
					if (info.id === infoItem.id) {
						return false;
					} else {
						index++;
						return true;
					}
				});


				this.splice('infos', index, 1);

				//Remove from the index
				delete this._infosIndex[id];

				//If it was an error which was recorded
				if (infoItem.type === this.InfoItemType.error) {
					if (this._errorCount > 0){
						this._errorCount--;
					}
				} else {
					if (this._warningCount > 0){
						this._warningCount--;
					}
				}
			}
		},

		/**
               *
         * Returns true if there are any recorded errors which are not related to Missing values
         * @public
               * @return Boolean
              */
		hasNonMandErrors: function () {
			var nonMandErrors = [];
			nonMandErrors = this.infos.filter(function (info) {
				return !info.isMandError;
			});
			return Boolean(nonMandErrors.length);
		},
		/**
         *
         * Returns true if there are any mandatory errors
         * @public
		* @return Boolean
		*/
		hasMandErrors: function () {
			var hasMandErr = false;
			this.infos.every(function (info) {
				if (info.isMandError) {
					hasMandErr = true;
					return false;
				} else {
					return	true;
				}
			});

			return hasMandErr;
		},
		/**
        /**
        *
        * Shows the summary dialog
        * @public
        * @return none
        */
		showSummary: function () {
			this._onShowSummary();
		},
		behaviors: [DS.SMAProcSP.SPBase]
	});
}(this));

/*
polyup:
 1. Constructor if required needs to be explicitly set window object
 2. Mixins are converted to behaviors
*/
