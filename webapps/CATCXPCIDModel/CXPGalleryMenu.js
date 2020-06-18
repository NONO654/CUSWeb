/**
 * @exports DS/CATCXPCIDModel/CXPGalleryMenu
 */
define('DS/CATCXPCIDModel/CXPGalleryMenu',
// dependencies
[
    'UWA/Core',
	'DS/CATCXPCIDModel/CXPGallery',
	'DS/CATCXPCIDModel/CXPButton',
	'DS/CATCXPCIDModel/CXPUIMapper'
],
function (UWA, CXPGallery, CXPButton, UIMapper) {

	'use strict';

	/**
	* @name DS/CATCXPCIDModel/CXPGalleryMenu
    * @description
    * Menu Gallery
	* @constructor
	*/

	var CXPGalleryMenu = CXPGallery.extend(
		/** @lends DS/CATCXPCIDModel/CXPGalleryMenu.prototype **/
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
					uiItem.button.inject(this._gallery);
					this._UIItems.push(uiItem);
				}
			},

			_clearUIItems: function () {
				for (var i = 0; i < this._UIItems.length; i++) {
					this._UIItems[i].button.remove();
					for (var iMapper = 0; iMapper < this._UIItems[i].mappers.length; iMapper++) {
						this._UIItems[i].mappers[iMapper].destroy();
					}
					this._UIItems[i].button.destroy();
				}
				this._UIItems = [];
			},

			_createUIItem: function (iModelItem) {
				var mappers = [];
				var data = iModelItem.QueryInterface('CATICXPObject').GetFatherObject();
				var gallery = data.QueryInterface('CATICXPObject').GetFatherObject();

				var button = new CXPButton(this._uiActor);
				mappers.push(new UIMapper(button, data, [{
					model: 'itemSize.x',
					ui: 'minWidth'
				},
					{
						model: 'itemSize.y',
						ui: 'minHeight'
					},
					{
						model: 'itemFontHeight',
						ui: 'fontHeight'
					}
				]));

				mappers.push(new UIMapper(button, iModelItem, [
					{
						model: 'label',
						ui: 'label'
					}
				]));

				mappers.push(new UIMapper(button, gallery, [
					{
						model: 'enable',
						ui: 'enable'
					}
				]));

				button.getContainer().style.position = 'relative';
				button.getContainer().style.margin = '5px';

				return {
					button: button,
					mappers: mappers
				};
			},


			// Register events for play
			registerPlayEvents: function (iSdkObject) {
				this._parent(iSdkObject);

				for (var i = 0; i < this._UIItems.length; i++) {
					this._UIItems[i].button.registerPlayEvents(iSdkObject, i);
				}
			},

			// Release play events
			releasePlayEvents: function () {
				this._parent();

				for (var i = 0; i < this._UIItems.length; i++) {
					this._UIItems[i].button.releasePlayEvents();
				}
			}

		});
	return CXPGalleryMenu;
});
