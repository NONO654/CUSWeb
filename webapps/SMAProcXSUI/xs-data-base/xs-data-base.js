/* global DS */
(function () {
	'use strict';
	var XSDataBase, callbackQueue =[];

	window.DS.SMAProcXSUI = window.DS.SMAProcXSUI || {};

	XSDataBase = {
		//Override this
		getData: function(identifier, callback) {
			//method should be overriden with data for that identifier
			//data returned to callback function will have update function which will update that data to db
			callback();
		},

		//Override this
		isDataInitialized: function() {
			return false;
		},

		onDataInitialized: function(callback, context) {
			// Initialize the queue if its empty
			callbackQueue[this.id] = callbackQueue[this.id] || [];
			// Store it so to call it when data is ready
			// Add it as the subscriber
			callbackQueue[this.id].push(callback.bind(context));
			if (this.isDataInitialized()) {
				callback.call(context);
				// Remove callback function from the queue once it's called.
				callbackQueue[this.id] && callbackQueue[this.id].pop();
			}
		},

		//call this function when data is initialized
		clearCallBackQueue: function() {
			this.isInitialized = true;
			Object.keys(callbackQueue).forEach(function (key) {
				var queue = callbackQueue[key];
				if (queue) {
					queue.forEach(function (callback) {
						callback();
					}, this);
				}
			});
		}

	};
	window.DS.SMAProcXSUI.XSDataBase = [DS.SMAProcSP.SPBase, XSDataBase];
}(this));
