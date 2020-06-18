define('DS/CATCXPModel/interfaces/CATICXPMaterialsMgr',
// dependencies
[
    'UWA/Class',
    'DS/WebComponentModeler/CATWebInterface'
],

function (
    UWA,
    CATWebInterface)
{
    'use strict';

    var CATICXPMaterialsMgr = CATWebInterface.singleton(
    {

    	interfaceName: 'CATICXPMaterialsMgr',

    	    required: {
    	    	//virtual HRESULT CreateAndAddMaterialFromAsset(const CATUnicodeString& iMaterialName, CATBaseUnknown* iAsset, 
    	    	//const CATI3DExperienceObject_var& iProto, CATICXPMaterial_var& oCreatedMaterial) = 0;
        	    CreateAndAddMaterialFromAsset: function (iMaterialName, iAsset, iProto, oCreatedMaterial) {
        	    },
        	    //virtual HRESULT ListMaterials(CATListValCATI3DExperienceObject_var& oMaterialsList) = 0;
        	    ListMaterials: function (oMaterialsList) {
        	    },
        	    //virtual HRESULT RemoveMaterial(CATICXPMaterial_var& iMaterial) = 0;
        	    RemoveMaterial: function (iMaterial) {
        	    },
        	    //virtual HRESULT ApplyMaterial(const CATICXPMaterial_var& iMaterial, CATICXPMaterialApplication_var& oMatInst, const CATBaseUnknown* iCnxAsset = NULL) = 0;
        	    ApplyMaterial: function (iMaterial, oMatInst, iCnxAsset) {
        	    }
        },

        /*
        * optional methods 
        * @type {Object}
        * @public
        */
        optional: {

        }
    });

    return CATICXPMaterialsMgr;
});
