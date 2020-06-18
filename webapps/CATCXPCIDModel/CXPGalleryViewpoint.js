/**
 * @exports DS/CATCXPCIDModel/CXPGalleryViewpoint
 */
define('DS/CATCXPCIDModel/CXPGalleryViewpoint',
// dependencies
[
    'UWA/Core',
	'DS/CATCXPCIDModel/CXPGallery',
	'DS/CATCXPCIDModel/CXPCameraViewer',
	'DS/CATCXPCIDModel/CXPUIMapper',
	'DS/CATCXPCIDModel/CXPImage'
],
function (UWA, CXPGallery, CXPCameraViewer, UIMapper, CXPImage) {

	'use strict';

	/**
	* @name DS/CATCXPCIDModel/CXPGalleryViewpoint
    * @description
    * Viewpoint Gallery
	* @constructor
	*/

	var CXPGalleryViewpoint = CXPGallery.extend(
		/** @lends DS/CATCXPCIDModel/CXPGalleryViewpoint.prototype **/
		{

			init: function (iUIActor) {
				this._parent(iUIActor);
			},

			destroy: function () {
				this._parent();
				this._clearUIItems();
			},

			_refreshItems: function (iModelItems) {
				this._clearUIItems();
				for (var i = 0; i < iModelItems.length; i++) {
					var uiItem = this._createUIItem(iModelItems[i]);
					uiItem.holder.inject(this._gallery);
					this._UIItems.push(uiItem);
				}
			},

			_clearUIItems: function () {
				for (var i = 0; i < this._UIItems.length; i++) {
					this._UIItems[i].holder.remove();
					for (var iMapper = 0; iMapper < this._UIItems[i].mappers.length; iMapper++) {
						this._UIItems[i].mappers[iMapper].destroy();
					}
					this._UIItems[i].cxpViewer.destroy();
					this._UIItems[i].cxpImage.destroy();
				}
				this._UIItems = [];
			},

			_createUIItem: function (iModelItem) {
				var mappers = [];
				var data = iModelItem.QueryInterface('CATICXPObject').GetFatherObject();
				var gallery = data.QueryInterface('CATICXPObject').GetFatherObject();

				var holder = UWA.createElement('div');
				holder.style.padding = '5px';

				var cxpCameraViewer = new CXPCameraViewer(this._uiActor);
				mappers.push(new UIMapper(cxpCameraViewer, data, [{
					model: 'itemSize.x',
					ui: 'minWidth'
				},
				{
					model: 'itemSize.y',
					ui: 'minHeight'
				},
				{
					model: 'liveUpdate',
					ui: 'liveUpdate'
				}]));

				mappers.push(new UIMapper(cxpCameraViewer, iModelItem, [{
					model: 'camera',
					ui: 'camera'
				}]));

				mappers.push(new UIMapper(cxpCameraViewer, gallery, [{
					model: 'enable',
					ui: 'enable'
				}]));

				cxpCameraViewer.getContainer().style.position = 'relative';
				cxpCameraViewer.inject(holder);

				var cxpImage = new CXPImage();
				mappers.push(new UIMapper(cxpImage, data, [{
					model: 'itemSize.x',
					ui: 'width'
				},
				{
					model: 'itemSize.y',
					ui: 'height'
				}]));

				mappers.push(new UIMapper(cxpImage, iModelItem, [{
					model: 'image',
					ui: 'image',
					func: function (iValue) {
						if (iValue) {
							cxpCameraViewer.getContainer().hide();
							cxpImage.getContainer().show();
						}
						else {
							cxpCameraViewer.getContainer().show();
							cxpImage.getContainer().hide();
						}
						return iValue;
					}
				}]));

				mappers.push(new UIMapper(cxpImage, gallery, [{
					model: 'enable',
					ui: 'enable'
				}]));

				cxpImage.getContainer().style.position = 'relative';
				cxpImage.inject(holder);

				var divLabel = UWA.createElement('div').inject(holder);
				divLabel.style.textAlign = 'center';
				var label = UWA.createElement('span').inject(divLabel);
				label.style.fontSize = '18px';

				mappers.push(new UIMapper(divLabel, data, [{
					model: 'itemSize.x',
					ui: 'style.width',
					func: function (iValue) {
						return iValue + 'px';
					}
				}]));

				mappers.push(new UIMapper(label, iModelItem, [{
					model: 'label',
					ui: 'innerHTML'
				}]));

				return {
					holder: holder,
					cxpViewer: cxpCameraViewer,
					cxpImage: cxpImage,
					mappers: mappers
				};
			},

			// Register events for play
			registerPlayEvents: function (iSdkObject) {
				this._parent(iSdkObject);

				for (var i = 0; i < this._UIItems.length; i++) {
					this._UIItems[i].cxpViewer.registerPlayEvents(iSdkObject, i);
					this._UIItems[i].cxpImage.registerPlayEvents(iSdkObject, i);
				}
			},

			// Release play events
			releasePlayEvents: function () {
				this._parent();

				for (var i = 0; i < this._UIItems.length; i++) {
					this._UIItems[i].cxpViewer.releasePlayEvents();
					this._UIItems[i].cxpImage.releasePlayEvents();
				}
			}

		});
	return CXPGalleryViewpoint;
});
