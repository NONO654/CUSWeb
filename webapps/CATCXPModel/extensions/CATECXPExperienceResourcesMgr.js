/**
 * CATECXPExperienceResourcesMgr
*  @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPExperienceResourcesMgr
 * @description Implements {@link DS/CATCXPModel/interfaces/CATICXPResourcesMgr CATICXPResourcesMgr}
 * @constructor
 */

define('DS/CATCXPModel/extensions/CATECXPExperienceResourcesMgr',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
	'DS/CAT3DExpModel/CAT3DXModel'
],
// Declaration
function (
	UWA, CAT3DXInterfaceImpl, CAT3DXModel
	) {
	'use strict';

	var CATECXPExperienceResourcesMgr = CAT3DXInterfaceImpl.extend(
	/** @lends DS/CATCXPModel/extensions/CATECXPExperienceResourcesMgr.prototype **/
	{
		init: function () {
			this._parent();
		},

		destroy: function () {
			this._parent();
		},

		/**  
		* @public
		*/
		CreateAndAddResourceFromAsset: function (iResourceName/*, iResourceInfo*/) {
			var expObj = this.QueryInterface('CATI3DExperienceObject');
			var resources = expObj.GetValueByName('resources');

			for (var i = 0; i < resources.length; ++i) {
				if (resources[i].QueryInterface('CATI3DExperienceObject').GetValueByName('_varName') === iResourceName) {
					console.error('a resource named ' + iResourceName + ' is allready registered.');
					return UWA.Promise.resolve(resources[i]);
				}
			}
			return CAT3DXModel.CreateResource('CXPPictureResource_Spec', iResourceName);
		},

		/**
		* @public
		*/
		AddResource: function (iResource) {
			var expObj = this.QueryInterface('CATI3DExperienceObject');
			var resources = expObj.GetValueByName('resources');

			for (var i = 0; i < resources.length; ++i) {
				if (resources[i].QueryInterface('CATI3DExperienceObject').GetValueByName('_varName') === iResource.QueryInterface('CATI3DExperienceObject').GetValueByName('_varName')) {
					return resources[i];
				}
			}
			resources.push(iResource);
			expObj.SetValueByName('resources', resources);
			return resources;
		},

		/**  
		* @public
		*/
		ListResources: function () {
			var expObject = this.QueryInterface('CATI3DExperienceObject');
			return expObject.GetValueByName('resources');
		},

		/**  
		* @public
		*/
		RemoveResource: function (iResource) {
			var expObject = this.QueryInterface('CATI3DExperienceObject');
			var res = expObject.GetValueByName('resources');

			res.splice(res.indexOf(iResource), 1);
			expObject.SetValueByName('resources', res);
		},

		/**  
		* @public
		*/
		Count: function () {
			var expObject = this.QueryInterface('CATI3DExperienceObject');
			return expObject.GetValueByName('resources').length;
		},

		/**  
		* @public
		*/
		GetResource: function (iResourceName) {
			var expObject = this.QueryInterface('CATI3DExperienceObject');
			var res = expObject.GetValueByName('resources');

			var idx = res.map(function (it) {
				return it.QueryInterface('CATI3DExperienceObject').GetValueByName('_varName');
			}).indexOf(iResourceName);
			if (idx === -1) {
				return undefined;
			}
			return res[idx];
		}
	});

	return CATECXPExperienceResourcesMgr;
});

