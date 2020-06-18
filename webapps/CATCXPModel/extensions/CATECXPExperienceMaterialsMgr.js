define('DS/CATCXPModel/extensions/CATECXPExperienceMaterialsMgr',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl'
],
function (UWA, CAT3DXInterfaceImpl) {
	'use strict';

	var CATECXPExperienceMaterialsMgr = CAT3DXInterfaceImpl.extend({

		init: function () {
			this._parent();
		},

		destroy: function () {
			this._parent();
		},

		// --- Interface CATICXPMaterialsMgr
		//virtual HRESULT CreateAndAddMaterialFromAsset(const CATUnicodeString& iMaterialName, CATBaseUnknown* iAsset,
		//const CATI3DExperienceObject_var& iProto, CATICXPMaterial_var& oCreatedMaterial) = 0;
		CreateAndAddMaterialFromAsset: function (iMaterialName, iAsset, iProto, oCreatedMaterial) {

		},
		//virtual HRESULT ListMaterials(CATListValCATI3DExperienceObject_var& oMaterialsList) = 0;
		ListMaterials: function (oMaterialsList) {
			var experienceObject = this.QueryInterface('CATI3DExperienceObject');
			var materials = experienceObject.GetValueByName('materials');

			if (!(oMaterialsList instanceof Array)) {
			    UWA.log('StuInstanceExperienceObject.ListMaterials ERROR : unable to fill parameters, not an array !');
				return;
			}
			oMaterialsList.splice(0, oMaterialsList.length);
			oMaterialsList.length = materials.length;
			var i = materials.length;
			while (i--) { oMaterialsList[i] = materials[i]; }
		},
		//virtual HRESULT RemoveMaterial(CATICXPMaterial_var& iMaterial) = 0;
		RemoveMaterial: function (iMaterial) {
			var experienceObject = this.QueryInterface('CATI3DExperienceObject');
			var materials = experienceObject.GetValueByName('materials');

			materials.splice(materials.indexOf(iMaterial), 1);
			experienceObject.SetValueByName('materials', materials);
		},
		//virtual HRESULT ApplyMaterial(const CATICXPMaterial_var& iMaterial, CATICXPMaterialApplication_var& oMatInst, const CATBaseUnknown* iCnxAsset = NULL) = 0;
		ApplyMaterial: function (iMaterial, oMatInst, iCnxAsset) {
			throw new Error('Should not be called from an Actor. cf cpp Impl');
		}
	});
	return CATECXPExperienceMaterialsMgr;
});
