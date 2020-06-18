/**
 * @exports DS/XCTWebExperienceAppPlay/managers/CXPWebEventListenerManager
 */
define('DS/XCTWebExperienceAppPlay/managers/CXPWebEventListenerManager',
	[
	   'UWA/Core',
	   'DS/WebApplicationBase/W3AAManager',
	   'DS/Core/Events',
	   'DS/EP/EP',
	   'DS/EPTaskPlayer/EPTaskPlayerDefine',
	   'MathematicsES/MathVector2DJSImpl',
	   'DS/VisuEvents/EventsManager',

	   'DS/EPInputs/EPInputsDefine'
	],
	function (UWA, W3AAManager, WUXEvent, EP, EPTaskPlayer, Vector2D, VisuEventsManager) {
		'use strict';

		/**
		* @name DS/XCTWebExperienceAppPlay/managers/CXPWebEventListenerManager
		* @category Manager
		*
		* @description
		* Register mouse events on the DS/VisuEvents/EventsManager
		*
		* @constructor
		* @augments DS/WebApplicationBase/W3AAManager
		*/
		var CXPWebEventListenerManager = W3AAManager.extend(
	/** @lends DS/XCTWebExperienceAppPlay/managers/CXPWebEventListenerManager.prototype **/
	{
		/** 
		* register events on the visu events manager
		* @public
		*/
	    start: function () {
	        var self = this;
			if (this._eventsArray) {
				UWA.log('CXPWebEventListenerManager already started');
				return;
			}

			var canvas = this._experienceBase.webApplication.frmWindow._3dViewer.canvas;
			// start event forwarding 
			// start mouse 
			var mouseEnabled = new EP.MouseEnableEvent();
			EP.EventServices.dispatchEvent(mouseEnabled);

			this._eventsArray = [];

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onMouseMove', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var position = new Vector2D();
				position.x = evt.from[0].currentPosition.x;
				position.y = evt.from[0].currentPosition.y;

				var newEvt = new EP.MouseMoveEvent();
				newEvt.position = position;

				var deltaPosition = new Vector2D();
				deltaPosition.x = evt.from[0].deltaPosition.x;
				deltaPosition.y = evt.from[0].deltaPosition.y;
				newEvt.deltaPosition = deltaPosition;

				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onLeftMouseDown', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MousePressEvent();
				newEvt.position.x = evt.from[0].currentPosition.x;
				newEvt.position.y = evt.from[0].currentPosition.y;
				newEvt.button = EP.Mouse.EButton.eLeft;
				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onLeftMouseUp', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MouseReleaseEvent();
				newEvt.position.x = evt.from[0].currentPosition.x;
				newEvt.position.y = evt.from[0].currentPosition.y;
				newEvt.button = EP.Mouse.EButton.eLeft;
				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onLeftClick', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MouseClickEvent();
				newEvt.position.x = evt.from[0].currentPosition.x;
				newEvt.position.y = evt.from[0].currentPosition.y;
				newEvt.button = EP.Mouse.EButton.eLeft;
				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onLeftDoubleClick', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MouseDoubleClickEvent();
				newEvt.position.x = evt.from[0].currentPosition.x;
				newEvt.position.y = evt.from[0].currentPosition.y;
				newEvt.button = EP.Mouse.EButton.eLeft;
				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onMiddleMouseDown', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MousePressEvent();
				newEvt.position.x = evt.from[0].currentPosition.x;
				newEvt.position.y = evt.from[0].currentPosition.y;
				newEvt.button = EP.Mouse.EButton.eMiddle;
				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onMiddleMouseUp', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MouseReleaseEvent();
				newEvt.position.x = evt.from[0].currentPosition.x;
				newEvt.position.y = evt.from[0].currentPosition.y;
				newEvt.button = EP.Mouse.EButton.eMiddle;
				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onMiddleClick', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MouseClickEvent();
				newEvt.position.x = evt.from[0].currentPosition.x;
				newEvt.position.y = evt.from[0].currentPosition.y;
				newEvt.button = EP.Mouse.EButton.eMiddle;
				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onMiddleDoubleClick', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MouseDoubleClickEvent();
				newEvt.position.x = evt.from[0].currentPosition.x;
				newEvt.position.y = evt.from[0].currentPosition.y;
				newEvt.button = EP.Mouse.EButton.eMiddle;
				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onRightMouseDown', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MousePressEvent();
				newEvt.position.x = evt.from[0].currentPosition.x;
				newEvt.position.y = evt.from[0].currentPosition.y;
				newEvt.button = EP.Mouse.EButton.eRight;
				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onRightMouseUp', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MouseReleaseEvent();
				newEvt.position.x = evt.from[0].currentPosition.x;
				newEvt.position.y = evt.from[0].currentPosition.y;
				newEvt.button = EP.Mouse.EButton.eRight;
				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onRightClick', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MouseClickEvent();
				newEvt.position.x = evt.from[0].currentPosition.x;
				newEvt.position.y = evt.from[0].currentPosition.y;
				newEvt.button = EP.Mouse.EButton.eRight;
				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onRightDoubleClick', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MouseDoubleClickEvent();
				newEvt.position.x = evt.from[0].currentPosition.x;
				newEvt.position.y = evt.from[0].currentPosition.y;
				newEvt.button = EP.Mouse.EButton.eRight;
				self.dispatchEvent(newEvt);
			}));

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onMouseWheel', function (evt) {
				if (evt.from[0].view !== canvas) {
					return;
				}
				var newEvt = new EP.MouseWheelEvent();
				newEvt.position = EP.Devices.getMouse().getPosition();
				newEvt.wheelDeltaValue = evt.gesture.delta;
				self.dispatchEvent(newEvt);
			}));

			//Keyboard
			var keyboardEnabled = new EP.KeyboardEnableEvent();
			EP.EventServices.dispatchEvent(keyboardEnabled);

			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onKeyDown', function (evt) {
				var newEvt = new EP.KeyboardPressEvent();
				newEvt.key = evt.gesture.key;
				self.dispatchEvent(newEvt);
			}));
			this._eventsArray.push(VisuEventsManager.addEvent(document, 'onKeyUp', function (evt) {
				var newEvt = new EP.KeyboardReleaseEvent();
				newEvt.key = evt.gesture.key;
				self.dispatchEvent(newEvt);
			}));

		},

		dispatchEvent:function(iEvent){
		    EP.EventServices.dispatchEvent(iEvent);
		},

		/** 
		* unsubscribe events from the visu events manager
		* @public
		*/
		stop: function () {
			// unsubscribe events 
			if (this._eventsArray) {
				for (var i = this._eventsArray.length; i--;) {
				    VisuEventsManager.removeEventFromToken(this._eventsArray[i]);
					this._eventsArray[i] = null;
				}
				this._eventsArray = null;
			}
		},

		GetType: function () {
			return 'CXPWebEventListenerManager';
		}

	});
		return CXPWebEventListenerManager;
	});
