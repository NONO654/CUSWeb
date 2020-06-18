/*--------------------------------------------------------------------
[xs-wg-document-chooser JS Document]

Project:        xs-wg
Version:        1.0
Last change:    Wed, 11 Nov 2015 15:46:38 GMT
Assigned to:    Thomas Esterle (TEE1)
Description:    TODO: Description
---------------------------------------------------------------------*/
/**

    @module SMAProcXS-WG
    @submodule xs-wg-document-chooser
    @class xs-wg-document-chooser
    @description
        //TODO: Write the description about the component


    @example
    <h5>HTML</h5>

        <!-- Show how this component can be declared -->
        <xs-wg-document-chooser>

        </xs-wg-document-chooser>

    @example
    <h5>JS</h5>

        //TODO: Show some API example
*/
/* global DS, Polymer*/
(function() {
	'use strict';

	Polymer({ // jshint ignore:line
		is: 'xs-wg-document-chooser',
		properties: {
			contentid: { notify: true },
			_adp: {value: null},
			contenttitle: {
				type: String,
				value: 'Click to modify Content',
				notify: true
			},
			label: { notify: true },
			rawvalue: {
				notify: true,
				observer: 'rawvalueChanged'
			},
			accept: {
				type: String,
				notify: true,
				value: 'DOCUMENTS'
			},
			//Attributes
			readonly: {
				type: Boolean,
				value: false,
				notify: true
			},
			value: {
				type: String,
				notify: true
			}
		},
		ready: function() {
			this._adp = this.XS();
		},
		rawvalueChanged: function(){
			//this.$.chooser.strictMatch =  this.rawvalue.syncAssist === 'Parameter' ? false : true;
			this.$.chooser.parentType = this.rawvalue.type;
			this.$.chooser.dummyDocType = this.rawvalue.DummyDocType;
			if (this.rawvalue.syncAssist === 'Parameter') {
				this.accept = '3DShape, Chapter, DesignSight, FEM, GenerativeStress, Material,' +
                    'PLMCoreRepReference, PLMReference, Part, PlmParameter, Products, ' +
                    'Requirement, SpotFastener, Test Case, Use Case, VPMReference, XRep, DOCUMENTS, Approximation, Simulation Folder, Workspace Vault, Test Execution';
			}
			//content chooser search will show following type of objects except children of 'DOCUMENTS' type
			else {
				if (this.rawvalue.type !=='DOCUMENTS'){
					this.accept = '3DShape, Chapter, DesignSight, FEM, GenerativeStress, Material,' +
                    'PLMCoreRepReference, PLMReference, Part, PlmParameter, Products, ' +
                        'Requirement, SpotFastener, Test Case, Use Case, VPMReference, XRep, Approximation, Simulation Folder, Workspace Vault, Test Execution';
				}
				else {
					//content chooser search will show only children of 'DOCUMENTS' parent type
					this.accept = 'DOCUMENTS';
				}
			}
		},
		_isReadonly: function(datatype, readonly) {
			//readonly should be true if it is Owned document or readonly property becomes true from property-inspector
			return (datatype !== 'chooser') || readonly;
		},
		_onSelect: function() {
			this.value = this.$.chooser.objectId;
		},
		spError: function(event) {
			this._adp.notify({
				text: event.detail.errorCode === 'SMAProcSP.SPSearch.1' ? this.$.noSearchMsg.value : event.detail.message,
				type: 'error',
				autoRemove: true
			});
			event.stopPropagation();
		},
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});

}(this));
