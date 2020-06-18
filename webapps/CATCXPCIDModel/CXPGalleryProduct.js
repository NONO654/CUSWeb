/**
 * @exports DS/CATCXPCIDModel/CXPGalleryProduct
 */
define('DS/CATCXPCIDModel/CXPGalleryProduct',
// dependencies
[
    'UWA/Core',
	'DS/CATCXPCIDModel/CXPGallery',
	'DS/CATCXPCIDModel/CXPImage',
	'DS/CATCXPCIDModel/CXPUIMapper'
],
function (UWA, CXPGallery, CXPImage, UIMapper) {

	'use strict';

	/**
	* @name DS/CATCXPCIDModel/CXPGalleryProduct
    * @description
    * Product Gallery
	* @constructor
	*/

	var CXPGalleryProduct = CXPGallery.extend(
		/** @lends DS/CATCXPCIDModel/CXPGalleryProduct.prototype **/
		{

			init: function (iUIActor) {
				this._parent(iUIActor);
				this._modelitems = [];
			},

			destroy: function () {
				this._parent();
				this._clearUIItems();
			},

			_refreshItems: function (iModelItems) {
				if (iModelItems) {
					this._modelitems = iModelItems;
				}
				this._clearUIItems();
				for (var i = 0; i < this._modelitems.length; i++) {
					var uiItem = this._createUIItem(this._modelitems[i], i);
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
					this._UIItems[i].image.destroy();
				}
				this._UIItems = [];
			},

			_createUIItem: function (iModelItem) {
				var mappers = [];
				var data = iModelItem.QueryInterface('CATICXPObject').GetFatherObject();
				var gallery = data.QueryInterface('CATICXPObject').GetFatherObject();

				var cxpImage = new CXPImage(this._uiActor);
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
					ui: 'image'
				},
				{
					model: 'product',
					ui: 'src',
					func: function (iValue) {
						if (iValue) {
						    iValue.QueryInterface('CATIPreviewable').GetPreview(function (ev) {
								cxpImage.src = ev;
							}, undefined, true);
						}
					}
				}]));


				mappers.push(new UIMapper(cxpImage, gallery, [{
					model: 'enable',
					ui: 'enable'
				}]));

				cxpImage.getContainer().style.position = 'relative';

				var holder = UWA.createElement('div');
				holder.style.padding = '5px';
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
					image: cxpImage,
					mappers: mappers
				};
			},

			// Register events for play
			registerPlayEvents: function (iSdkObject) {
				this._parent(iSdkObject);

				this._refreshItems(this._modelitems);
				for (var i = 0; i < this._UIItems.length; i++) {
					this._UIItems[i].image.registerPlayEvents(iSdkObject, i);
				}
			},
			
            // Release play events
			releasePlayEvents: function () {
				this._parent();

				for (var i = 0; i < this._UIItems.length; i++) {
					this._UIItems[i].image.releasePlayEvents();
				}
			}

		});
	return CXPGalleryProduct;
});
