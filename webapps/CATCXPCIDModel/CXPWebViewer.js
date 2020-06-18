/**
 * @exports DS/CATCXPCIDModel/CXPWebViewer
 */
define('DS/CATCXPCIDModel/CXPWebViewer',
// dependencies
[
    'UWA/Core',
	'DS/CATCXPCIDModel/CXPUIActor'
],
function (UWA, CXPUIActor) {

	'use strict';

	/**
	* @name DS/CATCXPCIDModel/CXPWebViewer
    * @description
    * Web Viewer
	* @constructor
	*/

	var CXPWebViewer = CXPUIActor.extend(
		/** @lends DS/CATCXPCIDModel/CXPWebViewer.prototype **/
	{

		init: function () {
			this._webViewer = UWA.createElement('iframe').inject(this.getContainer());
			//Refused to display 'https: //www.google.com' in a frame because it set 'X-Frame-Options' to 'SAMEORIGIN'. 

			Object.defineProperty(this, 'visible', {
				enumerable: true,
				configurable: true,
				get: function () {
					return this._visible;
				},
				set: function (iValue) {
					this._visible = iValue;
					if (this._visible) {
						this._webViewer.style.display = 'inherit';
					}
					else {
						this._webViewer.style.display = 'none';
					}
				}
			});

			Object.defineProperty(this, 'enable', {
				enumerable: true,
				configurable: true,
				get: function () {
					return this._enable;
				},
				set: function (iValue) {
					this._enable = iValue;
					if (this._enable) {
						this._webViewer.style.pointerEvents = 'inherit';
						this._webViewer.style.filter = 'none';
					}
					else {
						this._webViewer.style.pointerEvents = 'none';
						this._webViewer.style.filter = 'brightness(70%) grayscale(100%)';
					}
				}
			});

			Object.defineProperty(this, 'opacity', {
				enumerable: true,
				configurable: true,
				get: function () {
					return this._opacity;
				},
				set: function (iValue) {
					this._opacity = iValue;
					this._webViewer.style.opacity = this._opacity/255;
				}
			});

			Object.defineProperty(this, 'minWidth', {
				enumerable: true,
				configurable: true,
				get: function () {
					return this._minWidth;
				},
				set: function (iValue) {
					this._minWidth = iValue;
					this._webViewer.style.width = this._minWidth + 'px';
				}
			});

			Object.defineProperty(this, 'minHeight', {
				enumerable: true,
				configurable: true,
				get: function () {
					return this._minHeight;
				},
				set: function (iValue) {
					this._minHeight = iValue;
					this._webViewer.style.height = this._minHeight + 'px';
				}
			});

			Object.defineProperty(this, 'url', {
				enumerable: true,
				configurable: true,
				get: function () {
					return this._url;
				},
				set: function (iValue) {
					this._url = iValue;
					this._webViewer.src = this._url;
				}
			});

			//Object.defineProperty(this, 'message', {
			//	enumerable: true,
			//	configurable: true,
			//	get: function () {
			//		return this._message;
			//	},
			//	set: function (iValue) {
			//		this._message = iValue;
			//	}
			//});
			//
			//Object.defineProperty(this, 'script', {
			//	enumerable: true,
			//	configurable: true,
			//	get: function () {
			//		return this._script;
			//	},
			//	set: function (iValue) {
			//		this._script = iValue;
			//	}
			//});

		},




		// Register events for play
		// Click and double click
		registerPlayEvents: function (iSdkObject) {
			this._parent(iSdkObject);
		},

		// Release play events
		releasePlayEvents: function () {
			this._parent();
		}

	});
	return CXPWebViewer;
});




