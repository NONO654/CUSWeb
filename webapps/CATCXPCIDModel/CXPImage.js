/**
 * @exports DS/CATCXPCIDModel/CXPImage
 */
define('DS/CATCXPCIDModel/CXPImage',
// dependencies
[
    'UWA/Core',
	'DS/CATCXPCIDModel/CXPUIActor'
],
function (UWA, CXPUIActor) {

	'use strict';
	/**
	* @name DS/CATCXPCIDModel/CXPImage
	* @description
	* Create an image ui actor rep (<img>)
	* Define specific properties and bind them to the rep
	* @constructor
	*/

	var CXPImage = CXPUIActor.extend(
		/** @lends DS/CATCXPCIDModel/CXPImage.prototype **/
		{

			init: function (iUIActor) {
				this._parent(iUIActor);

				this._img = UWA.createElement('img').inject(this.getContainer());

				Object.defineProperty(this, 'visible', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._visible;
					},
					set: function (iValue) {
						this._visible = iValue;
						if (iValue) {
							this._img.style.display = 'inherit';
						}
						else {
							this._img.style.display = 'none';
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
							this._img.style.pointerEvents = 'inherit';
							this._img.style.filter = 'none';
						}
						else {
							this._img.style.pointerEvents = 'none';
							this._img.style.filter = 'brightness(70%) grayscale(100%)';
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
						this._img.style.opacity = this._opacity/255;
					}
				});

				Object.defineProperty(this, 'width', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._width;
					},
					set: function (iValue) {
						this._width = iValue;
						this._img.width = this._width;
					}
				});

				Object.defineProperty(this, 'height', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._height;
					},
					set: function (iValue) {
						this._height = iValue;
						this._img.height = this._height;
					}
				});

				Object.defineProperty(this, 'image', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._image;
					},
					set: function (iValue) {
						this._image = iValue;
						if (this._image) {
							var assetHolder = this._image.QueryInterface('CATI3DXAssetHolder');
							if (!UWA.is(assetHolder)) { /*return*/ console.error('not an asset holder'); }
							var self = this;
							assetHolder.resolveAsset().done(function (iImage) {
								if (iImage) { //check stream exists
									self._img.src = iImage.src;
								}
							});
						}
						else {
							this._img.src = '';
						}
					}
				});

				Object.defineProperty(this, 'src', {
					enumerable: true,
					configurable: true,
					get: function () {
						return this._src;
					},
					set: function (iValue) {
						this._src = iValue;
						if ((this._src) && (!this.image)) {
							this._img.src = this._src;
						}
					}
				});
			},

			// Register events for play
			// Click and double click
			registerPlayEvents: function (iSdkObject, index) {
				this._parent(iSdkObject);
				index = UWA.is(index) ? index : 0;

				this._img.addEventListener('click', this._clickEvent = function () {
					iSdkObject.doUIDispatchEvent('UIClicked', index);
				});

				this._img.addEventListener('dblclick', this._dblclickEvent = function () {
					iSdkObject.doUIDispatchEvent('UIDoubleClicked', index);
				});
			},

			// Release play events
			releasePlayEvents: function () {
				this._parent();

				this._img.removeEventListener('click', this._clickEvent);
				this._img.removeEventListener('dblclick', this._dblclickEvent);
			}

		});
	return CXPImage;
});



