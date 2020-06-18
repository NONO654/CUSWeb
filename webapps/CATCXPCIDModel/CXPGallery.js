/**
 * @exports DS/CATCXPCIDModel/CXPGallery
 */
define('DS/CATCXPCIDModel/CXPGallery',
// dependencies
[
    'UWA/Core',
	'DS/CATCXPCIDModel/CXPUIActor'
],
function (UWA, CXPUIActor) {

	'use strict';

	/**
	* @name DS/CATCXPCIDModel/CXPGallery
    * @description
    * Gallery
	* @constructor
	*/

	var CXPGallery = CXPUIActor.extend(
		/** @lends DS/CATCXPCIDModel/CXPGallery.prototype **/
		{

			init: function (iUIActor) {
				this._parent(iUIActor);

				this._UIItems = [];

				this._gallery = UWA.createElement('div').inject(this.getContainer());

				Object.defineProperty(this, 'visible', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._visible;
					},
					set: function (iValue) {
						this._visible = iValue;
						if (this._visible) {
							if (this.orientation === 1) {
								this._gallery.style.display = 'inherit';
							}
							else {
								this._gallery.style.display = 'flex';
							}
						}
						else {
							this._gallery.style.display = 'none';
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
						this._gallery.style.opacity = this._opacity/255;
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
						if (this.stretchToContent) {
							this._gallery.style.minWidth = this._minWidth + 'px';
							this._gallery.style.width = '';
						}
						else {
							this._gallery.style.width = this._minWidth + 'px';
							this._gallery.style.minWidth = '';
						}
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
						if (this.stretchToContent) {
							this._gallery.style.minHeight = this._minHeight + 'px';
							this._gallery.style.height = '';
						}
						else {
							this._gallery.style.height = this._minHeight + 'px';
							this._gallery.style.minHeight = '';
						}
					}
				});


				//Object.defineProperty(this, 'itemSize', {
				//	enumerable: true,
				//	configurable: true,
				//	get: function () {
				//		return this._itemSize;
				//	},
				//	set: function (iValue) {
				//		this._itemSize = iValue;
				//	}
				//});

				Object.defineProperty(this, 'items', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._items;
					},
					set: function (iValue) {
						this._items = iValue;
						this._refreshItems(this._items);
					}
				});

				Object.defineProperty(this, 'orientation', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._orientation;
					},
					set: function (iValue) {
						this._orientation = iValue;
						if (this.visible) {
							if (this._orientation === 1) {
								this._gallery.style.display = 'inherit';
							}
							else {
								this._gallery.style.display = 'flex';
							}
						}
						else {
							this._gallery.style.display = 'none';
						}
					}
				});

				Object.defineProperty(this, 'stretchToContent', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._stretchToContent;
					},
					set: function (iValue) {
						this._stretchToContent = iValue;
						if (this._stretchToContent) {
							this._gallery.style.overflow = 'visible';
							this._gallery.style.minWidth = this.minWidth + 'px';
							this._gallery.style.minHeight = this.minHeight + 'px';
							this._gallery.style.width = '';
							this._gallery.style.height = '';
						}
						else {
							this._gallery.style.overflow = 'auto';
							this._gallery.style.width = this.minWidth + 'px';
							this._gallery.style.height = this.minHeight + 'px';
							this._gallery.style.minWidth = '';
							this._gallery.style.minHeight = '';
						}
					}
				});
			},

			// Register events for play
			registerPlayEvents: function (iSdkObject) {
				this._parent(iSdkObject);
			},

			// Release play events
			releasePlayEvents: function () {
				this._parent();
			}

		});
	return CXPGallery;
});




