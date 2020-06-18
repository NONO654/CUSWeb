/*--------------------------------------------------------------------
[xs-wg-run Javascript Document]
Project:        xs
Version:        1.0
Description:    TODO: Write Description
---------------------------------------------------------------------*/
/* global DS*/

(function () {
	'use strict';

	var USER_MSG = 'Activity/Simulation execution is enabled only after instantiation.';

	// Prototype
	window.Polymer({
		is: 'xs-wg-run',
		properties: {
			_adp: {
				type: Object
			},
			value: {
				notify: true
			},
			rawvalue: {
				type: Object,
				observer: 'rawvalueChanged'
			},
			label: {
				type: String,
				notify: true,
				observer: 'labelChanged'
			},
			jobstatus: {
				type: String,
				notify: true,
				value: 'Not Started',
				observer: 'jobstatusChanged'
			},
			disabled: {
				type: Boolean,
				value: true,
				notify: true
			}
		},

		ready: function () {
			this._adp = this.XS();
			this._label = 'No Data Present';
		},

		rawvalueChanged: function () {
			if (this._adp && this._adp.whichMode() !== 'run') {
				this.blockMsg = USER_MSG;
			}

			if (this._adp && this._adp.whichMode() === 'run' && this.rawvalue && !this.isJobRunning(this.rawvalue.jobstate)) {
				this.disabled = false;
			}
		},

		labelChanged: function(value) {
			this._label = this._computeLabel(value);
		},
		// to run Activity
		onClick: function () {
			if (!this.disabled) {
				this.fire('runactivity', {
					objectId: this.rawvalue.objectId,
					title: this.rawvalue.title_display // jshint ignore:line
				});
			}
		},

		_computeLabel: function (label) {
			if (!label || (label && label.length === 0)) {
				return 'No Data Present';
			}
			return label;
		},

		// Put all commonjob states as global variables

		isJobRunning: function(jobstatus){
			return jobstatus === 'Running' || jobstatus === 'Paused' || jobstatus === 'Waiting' || jobstatus === 'Queued';
		},

		jobstatusChanged: function(jobstatus, oldstatus) {
			if (this.isJobRunning(jobstatus)) {
				this.disabled = true;
			} else if (this._adp && this._adp.whichMode() === 'run' && this.rawvalue) {
				this.disabled = false;
			}

			//Get updated data when job is completed - it should not be initial load
			if (oldstatus !== 'Not Started' && jobstatus === 'Completed') {
				this.fire('datarefresh');
			}
		},
		// Inheritance
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(this));
