/*--------------------------------------------------------------------
[xs-wg-content-viewer JS Document]

	@example
	<xs-wg-content-viewer value="{{objectId}}", readonly='false'>
	</xs-wg-content-viewer>

*/
/* global DS, Polymer*/
(function () {
	'use strict';

	var VALID_TYPE = ['Simulation Document', 'Simulation Document - Versioned', 'Simulation Document - NonVersioned', 'Document'];

	Polymer({ // jshint ignore:line
		is: 'xs-wg-content-viewer',
		properties: {
			_adp: {
				value: null
			},
			value: {
				notify: true
			},
			label: {
				notify: true
			},
			// Attributes
			readonly: {
				type: Boolean,
				value: false,
				notify: true
			},
			rawvalue: {
				type: Object,
				notify: true
			}
		},

		ready: function () {
			this._adp = this.XS();
			this._isValidDataType = false;
			this.listen(this.$.document, 'sp-document-content-ui-files-available', 'validDocument');
		},

		validDocument: function(event){
			this._isValidDataType = event.detail.valid;
		},

		_getContentId: function (rawvalue) {
			// It needs be triggered when value changes as it also triggers rawvalue.physical id change
			return rawvalue.chooser_physicalid; // jshint ignore:line
		},

		_isReadOnly: function (readonly, rawvalue) {
			return readonly ||  !this._isValidType(rawvalue);
		},

		_isValidType: function (rawvalue, _isValidDataType) {
			var type;
			type = rawvalue.DummyDocType || rawvalue.chooser_doc_type; // jshint ignore:line
			return _isValidDataType || (VALID_TYPE.indexOf(type) !== -1);
		},

		_isDisabled: function (rawvalue) {
			this._adp = this._adp || this.XS();
			if (this._adp && this._adp.whichMode() === 'preview' && rawvalue) {
				/* With respect to IR-635266-3DEXPERIENCER2019x, UI modification is made, it now will show on hovering on component about "No interaction",
				 instead of component. Since sp-nls is component and is not util so have to code it like this (Hard coded msg).
				 */
				this.setAttribute('style', 'cursor: no-drop;');
				this.setAttribute('title', 'All interactions are blocked in Preview mode.');
				return true;
			}
			return false;
		},

		_hasNoAccessDuetoPreviewMode: function (rawvalue, _isValidDataType) {
			if (_isValidDataType) {
				return  this._isDisabled(rawvalue);
			} else {
				return this._isValidType(rawvalue) && this._isDisabled(rawvalue);
			}
		},

		_isNotValidType: function(rawvalue, _isValidDataType){
			return !this._isValidType(rawvalue, _isValidDataType);
		},

		notifyCanvas: function (e) {
			var details = e.detail;
			var operation = details.operation.charAt(0).toUpperCase() + details.operation.substr(1).toLowerCase();
			var msg = operation + ' ' + details.status + ': ' + details.filename;
			if (details.msg && details.msg !== '') {
				msg += '\n Reason: ' + details.msg.trim();
			}
			this._adp.notify({
				text: msg,
				type: details.type,
				autoRemove: true
			});
			e.stopPropagation();
		},
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(this));
