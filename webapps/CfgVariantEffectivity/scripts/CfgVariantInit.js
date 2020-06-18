/**
 * @module DS/CfgVariantEffectivity/scripts/CfgVariantInit
 */
define('DS/CfgVariantEffectivity/scripts/CfgVariantInit', ['DS/PlatformAPI/PlatformAPI','DS/CfgVariantEffectivity/scripts/CfgVariantTable', 'DS/CfgVariantEffectivity/scripts/CfgVariantUtility','css!DS/CfgVariantEffectivity/assets/styles/styles.css'],
    function(PlatformAPI, CfgVariantTable, CfgVariantUtility) {

        var CfgVariantInit = {};
       
        CfgVariantInit.InitModelOnUI = function(MainDiv, model, collection) {			   
	
            CfgVariantTable.InitModelWithDictionaryOnUI(MainDiv, model, collection);           

        };
		
	CfgVariantInit.RenderModelOnUI = function(model) {			   
	
            CfgVariantTable.RenderModelWithJSONOnUI(model);           

        };
    
        return CfgVariantInit;

    });
