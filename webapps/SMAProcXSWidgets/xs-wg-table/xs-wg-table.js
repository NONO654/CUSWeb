// Copyright 2016 Dassault Systemes Simulia Corp.

/*  @module SMAProcXSWidgets.mweb
	@submodule xs-wg-xyplot

	@description
				This Polymer webcomponent is used to show the plot using 2D Array

	@example
	<xs-wg-xyplot id="xsplot" value="{{xs_wg_plm_data_1}}"></xs-wg-xyplot>

*/
/* global DS, Polymer*/

(function () {
	'use strict';

	// Prototype
	Polymer({ // jshint ignore:line
		is: 'xs-wg-table',
		properties: {
			_adp: { value: null },
			value: {
				type: String,
				notify: true
			},

			_data: {
				type: Array,
				notify: true,
				computed: '_getArrayData(value)'
			},

			label: {
				type: String,
				notify: true
			},

			col: {
				type: String,
				notify: true
			},

			row: {
				type: String,
				notify: true
			},

			readonly: {
				type: Boolean,
				value: false,
				notify: true
			},

			datatype: {
				type: String,
				value: 'real',
				notify: true
			}
		},

		attached: function () {
			this._adp = this.XS();
			if (this._hidden(this.row, this.col)) {
				this.$.blank.hidden = true;
			}
		},

		_getArrayData: function (value) {
			if (!value) {
				return [[0]];
			}
			if (value.indexOf('{') === 0) {
				return [[0]];
			}
			this.$.container.classList.remove('no-data');
			return JSON.parse(value);
		},

		_updateCell: function (event) {
			var eventModel = event;
		  if (String(eventModel.target.value).length > 3) {
		    eventModel.target.title = eventModel.target.value;
		  } else {
		    eventModel.target.title = '';
		}
		  if (eventModel.target.value === '' || isNaN(eventModel.target.value)) {
		  	if (this.datatype === 'integer') {
		  		eventModel.target.value = 0;
		  	} else if (this.datatype === 'real') {
		  		eventModel.target.value = '0.0';
		  	}
		  } else {
		  	eventModel.target.value = eventModel.target.value === '-' ? 0 : Number(eventModel.target.value);
		  }
		  eventModel.model.colvalue.data = event.target.value;
		  this.value = JSON.stringify(this._data);
		},

		_edit: function (event) {
		  if (this.readonly === false) {
		     event.target.removeAttribute('readonly');
		  }
		},

		_getArray: function (value) {
		  if (value && value.length > 0) {
		    	return value.split(',');
		  }
			return [];
		},

		_hidden: function (row, col) {
		    if (row && col && row.length > 0 && col.length > 0) {
		      return false;
		    }
		    return true;
		},

		_makeReadonly: function (event) {
		  if (!event.target.hasAttribute('readonly')) {
		    event.target.setAttribute('readonly', true);
		  }
		},

		_computeTitle: function (value) {
		    if (value && value.length > 3) {
		      return value;
		    }
		    return null;
		},

		_computeClass: function (value) {
		  if (value !== undefined && value.length === 0) {
		      return 'cell error';
		    }
		      return 'cell';
		},

		// keypress event listener to prevent wrong inputs
		_keypressed: function (event) {
        	if (this.datatype === 'integer' && event.key === '.') {
        		event.preventDefault();
        	}
		},
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(this));
