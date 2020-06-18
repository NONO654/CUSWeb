/**
 * CATECXPObjectUI
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPObjectUI
 * @description Implements {@link DS/CATCXPModel/interfaces/CATICXPObjectUI CATICXPObjectUI}
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATECXPObjectUI',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
	'DS/CAT3DExpModel/CAT3DXModel'
],
function (
	UWA,
	CAT3DXInterfaceImpl,
	CAT3DXModel
	) {
	'use strict';

	var CATECXPObjectUI = UWA.Class.extend(CAT3DXInterfaceImpl,
	/** @lends DS/CATCXPModel/extensions/CATECXPObjectUI.prototype **/
	{
		Build: function () {
		},

		/**
		 * Retrieve the list of actions related to the experience object
		 * @public
		 * @returns {String[]} Array of component Command header names
		 */
		GetActions: function () {
			return CAT3DXModel.GetObjectUI(this.GetObject().GetType(), 'listOfActions');
		},
		/**
		 * List of actions to display in a contextual menu, for a given object.
		 * @public
		 * @param: iContext, EMenuContext enum value
		 * @returns {String} component name
		 */
		FillMenu: function (iContext) {
			throw new Error('Not Implemented Exeption');
		},
		/**
		 * Retrieve the display name  of the experience object
		 * @public
		 * @returns {String} component Title
		 */
		GetTitle: function () {
			return CAT3DXModel.GetObjectUI(this.GetObject().GetType(), 'title');
		},
		/**
		 * Retrieve the description of the experience object
		 * @public
		 * @returns {String} component Description
		 */
		GetDescription: function () {
			return CAT3DXModel.GetObjectUI(this.GetObject().GetType(), 'category');
		},
		/**
		 * Retrieve the category of the experience object
		 * @public
		 * @returns {String} component Category
		 */
		GetCategory: function () {
			return CAT3DXModel.GetObjectUI(this.GetObject().GetType(), 'category');
		},
		/**
		 * Retrieve the tags associated to the experience object
		 * @public
		 * @returns {String} component tags
		 */
		GetTags: function () {
			return CAT3DXModel.GetObjectUI(this.GetObject().GetType(), 'tags');
		},
		/**
		 * Retrieve the icon name of this object.
		 * @public
		 * @returns {String} component Icon path
		 */
		GetIcon: function () {
			return CAT3DXModel.GetObjectUI(this.GetObject().GetType(), 'iconName');
		},
		/**
		 * Retrieve the icon of the experience object
		 * @public
		 * @param: iResolution, 16/20/32/64 size of the icon
		 * @returns {String} component Thumbnail
		 */
		GetThumbnail: function (iResolution) {
			if (!UWA.is(iResolution)) {
				iResolution = 'Default';
			}
			return CAT3DXModel.GetObjectUI(this.GetObject().GetType(), 'iconPath' + iResolution + 'px');
		},
		/**
		 * Retrieve if the experience object is marked as favorite
		 * @public
		 * @returns {Boolean} component Favorite value
		 */
		IsFavorite: function () {
			return CAT3DXModel.GetObjectUI(this.GetObject().GetType(), 'IsFavorite');
		},
		/**
		 * Retrieve if the experience object is marked as abstract
		 * @public
		 * @returns {Boolean} component Abstract value
		 */
		IsAbstract: function () {
			return CAT3DXModel.GetObjectUI(this.GetObject().GetType(), 'IsAbstract');
		}
	});
	return CATECXPObjectUI;
});
