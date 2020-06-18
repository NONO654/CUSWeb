/*--------------------------------------------------------------------
[xs-widget-adapter JS Document]

Project:		xs
Description:	Defines communication channel between XS and widget
---------------------------------------------------------------------*/
/**
	@module SMAProcXS
	@submodule xs-widget-interface
	@class xs-widget-interface
	@description
       Defines communication channel between XS and widget


	@example
	<h5>HTML</h5>
		<xs-widget-interface></xs-widget-interface>

	@example
	<h5>JS</h5>
		xsWidgetAdapter.init('xs-wg-input-text');
*/

(function () {
	'use strict';
	var Adapter, adapters, instance;
	//Adapter module
	//uses the variable 'instance' from outer context
	Adapter = (function () {
		var Adapter, Canvas, trigger;
		//These are the list of methods which canvas listens to
		// this = adapter which made the call
		Canvas = {
			onSetError: 'onSetError',
			onClearError: 'onClearError'
		};
		//Context is optional
		trigger = function (name, args, context) {
			if (instance._config) {
				return instance._config[name] && instance._config[name].apply(context, args);
			}
			return function (){};
		};

	    /**
        	@class Adapter
        	@constructor
        	@protected
            Note: Adapter should not have any data specific methods
            @param {HTMLELement} widget xs-wg-* UI element instannce
        */
		Adapter = function (widget) {
			adapters[widget.id] = this;
			//Public Properties
			this.widget = widget;
			this.hasError = false;
			this.error = null;
			this._listeners = {};
		};
		Adapter.prototype.define = function (config) {
			this._config = config;
		};

		/**
         * Method to inform in case of any error. In case of multiple errors
         * the description has to be aggregated. Setting new error will
         * override any previously set error by the caller
         * @public
         * @param {object} error - The error object (optional)
        	{
        		title: 'Error title',
        		description: 'The description',
        		focus: function
        	}
        */
		Adapter.prototype.setError = function (error) {
			//Set the defaults
			error = error || {};
			error.title = error.title || this.widget.id;
			error.description = error.description || 'unknown error';
			//Set there is an error
			this.hasError = true;
			this.error = error;

			var listeners = this._listeners.error;
			if (listeners) {
				listeners.forEach(function (listener) {
					listener(error);
				});
			}

			trigger(Canvas.onSetError, arguments, this);
		};

		/**
         * Clears off any previously set error by the caller
         * @public
        */
		Adapter.prototype.clearError = function () {
			//Clear off the error
			this.hasError = false;
			this.error = null;

			var listeners = this._listeners.clearerror;
			if (listeners) {
				listeners.forEach(function (listener) {
					listener();
				});
			}

			trigger(Canvas.onClearError, arguments, this);
		};

		Adapter.prototype.listenOn = function (event, listener, context) {
			context = context || this;

			//Initialize if not yet initialized
			this._listeners[event] = this._listeners[event] || [];
			this._listeners[event].push(listener.bind(context));
		};

	    Adapter.prototype.isInDesignMode = function () {
	      if (instance._config) {
				if (instance._config.isInDesignMode){
					return instance._config.isInDesignMode();
				} else {
					return false;
				}
			}
			return false;
	    };
		Adapter.prototype.whichMode = function () {
			if (instance._config && instance._config.whichMode) {
				return instance._config.whichMode();
			} else {
				return '';
			}
		};
		Adapter.prototype.notify = function (msgData) {
			if (instance._config !== undefined && instance._config.notify !== undefined) {
				return instance._config.notify(msgData);
			}
			return function (){};
		};

		Adapter.prototype.isDisabled = function() {
			if (instance._config !== undefined && instance._config.isDisabled !== undefined) {
				return instance._config.isDisabled();
			} else {
				return false;
			}
		};

		return Adapter;
	})();
	/**
        @class XSWidgetInterface
        @constructor
        @singleton

    **/
	window.Polymer({
		is: 'xs-widget-interface',
		properties: {
			//Properties
			Adapter: {
				value: function () {
					return Adapter;
				}
			},
			hasError: {
				type: Boolean,
				value: false,
				notify: true
			}
		},
		//Life cycle methods
		ready: function () {
			adapters = {};
			//instance is the singleton holder
			instance = instance || this;
		},
		//Public methods
		define: function (config) {
			instance._config = config;
		}
	});
}(this));
