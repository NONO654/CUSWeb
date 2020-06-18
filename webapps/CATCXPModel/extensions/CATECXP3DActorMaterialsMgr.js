define('DS/CATCXPModel/extensions/CATECXP3DActorMaterialsMgr',
// dependencies
[
	'UWA/Core',
    'DS/Visualization/ThreeJS_DS'
],
function (UWA, THREE) {
	'use strict';

	var CATECXP3DActorMaterialsMgr = UWA.Class.extend({

		init: function () {
			this._parent();
		},

		// --- Interface CATICXPMaterialsMgr
		//virtual HRESULT CreateAndAddMaterialFromAsset(const CATUnicodeString& iMaterialName, CATBaseUnknown* iAsset,
		//const CATI3DExperienceObject_var& iProto, CATICXPMaterial_var& oCreatedMaterial) = 0;
		CreateAndAddMaterialFromAsset: function (iMaterialName, iAsset, iProto, oCreatedMaterial) {
			throw new Error('Should not be called from an Actor. cf cpp Impl');
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
		ApplyMaterial: function (iMaterial, oMatInst) {
			if (!UWA.is(iMaterial)) {
				return;
			}
			var visuObject = this.QueryInterface('CATI3DGeoVisu');

			var node = visuObject.GetNode();

			node.traverse(function (child) {
				if (child instanceof THREE.Mesh) {
					child.material = iMaterial;
				}
				if (child.mesh3js instanceof THREE.Mesh) {
					var parent = child.parents[0];
					parent.removeChild(child);
					child.mesh3js.material = iMaterial;
					parent.addChild(child);
				}
			});

		}
		//
	});
	return CATECXP3DActorMaterialsMgr;
});
