/**
 * @exports DS/CATCXPModel/interfaces/CATICXPObjectUI
*/
define('DS/CATCXPModel/interfaces/CATICXPObjectUI',
// dependencies
[
	'UWA/Class',
	'DS/WebComponentModeler/CATWebInterface'
],

function (
	UWA,
	CATWebInterface) {
	'use strict';

	/**
	* @category Interface
	* @name DS/CATCXPModel/interfaces/CATICXPObjectUI
	* @interface
	* @description 
	* Interface to manage the component name.
	*/

	var CATICXPObjectUI = CATWebInterface.singleton(
	/** @lends DS/CATCXPModel/interfaces/CATICXPObjectUI.prototype **/
	{

		interfaceName: 'CATICXPObjectUI',

		EMenuContext: {
			eTreeView		: 0,
			ePropertiesView	: 1,
			e3DView			: 2,
			eBehaviorEditor	: 3
		},
		/**
		* required methods 
		* @lends DS/CATCXPModel/interfaces/CATICXPObjectUI.prototype
		*/
		required: {
			/**
			 * Retrieve the list of actions related to the experience object
			 * @public
			 * @returns {String} component Command header names
			 */
			GetActions: function () { },
			/**
			 * List of actions to display in a contextual menu, for a given object.
			 * @public
			 * @param: iContext, EMenuContext enum value
			 * @returns {String} component name
			 */
			FillMenu: function (iContext) { },
			/**
			 * Retrieve the display name  of the experience object
			 * @public
			 * @returns {String} component Title
			 */
			GetTitle: function () { },
			/**
			 * Retrieve the description of the experience object
			 * @public
			 * @returns {String} component Description
			 */
			GetDescription: function () { },
			/**
			 * Retrieve the category of the experience object
			 * @public
			 * @returns {String} component Category
			 */
			GetCategory: function () { },
			/**
			 * Retrieve the tags associated to the experience object
			 * @public
			 * @returns {String} component tags
			 */
			GetTags: function () { },
			/**
			 * Retrieve the icon name of this object.
			 * @public
			 * @returns {String} component Icon path
			 */
			GetIcon: function () { },
			/**
			 * Retrieve the icon of the experience object
			 * @public
			 * @param: iResolution, e16px/e20px/e32px/e64px size of the icon
			 * @returns {String} component Thumbnail
			 */
			GetThumbnail: function (iResolution) { },
			/**
			 * Retrieve if the experience object is marked as favorite
			 * @public
			 * @returns {Boolean} component Favorite value
			 */
			IsFavorite: function () { },
			/**
			 * Retrieve if the experience object is marked as abstract
			 * @public
			 * @returns {Boolean} component Abstract value
			 */
			IsAbstract: function () { }

			/* Not Impl
			 * CreateView
			 * CreateContextView
			 * HasEdit
			 * HasEditInCtx
			 * ActivateEditCmd
			 * ActivateEditInCtxCmd
			 */
		},


		optional: {

		}
	});

	return CATICXPObjectUI;
});
