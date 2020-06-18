/**
 * CATE3DXVolatileEO
 * @category Extension
 * @name DS/CAT3DExpModel/extensions/CATE3DXVolatileEO
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DXVolatileEO CATI3DXVolatileEO}
 * @constructor
 */
define('DS/CAT3DExpModel/extensions/CATE3DXVolatileEO',
[
	'UWA/Core',
	'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject',
    'DS/CAT3DExpModel/CAT3DXInterfaceImpl'
],
function (
    UWA,
	CATI3DExperienceObject,
    CAT3DXInterfaceImpl) {
	'use strict';
	/**
	
	 * @category Extension
	 * @name DS/CAT3DExpModel/extensions/CATE3DXVolatileEO
	 * @constructor
	 */
	var CATE3DXVolatileEO = UWA.Class.extend(CAT3DXInterfaceImpl,
	/** @lends DS/CAT3DExpModel/extensions/CATE3DXVolatileEO.prototype **/
    {
		init: function () {
		},

    	// --- Interface CATI3DXVolatileEO
		/** 
		* @public
		*/
		setVolatile: function () {
		    var experienceObject = this.QueryInterface('CATI3DExperienceObject');
		    experienceObject.SetVolatile(true);
			var listVariablesObjects = [];
			experienceObject.ListVariables(listVariablesObjects, CATI3DExperienceObject.VarType.Object);
			for (var i = 0; i < listVariablesObjects.length; i++) {
			    var variableInfo = experienceObject.GetVariableInfo(listVariablesObjects[i]);
			    if (variableInfo.valuationMode === CATI3DExperienceObject.ValuationMode.AggregatingValue) {
			        var value = experienceObject.GetValueByName(listVariablesObjects[i]);
			        if (value) {
			            if (Array.isArray(value)) {
			                for (var indexValue = 0; indexValue < value.length; indexValue++) {
			                    if ((value[indexValue].QueryInterface) && (value[indexValue].QueryInterface('CATI3DXVolatileEO'))) {
			                        value[indexValue].QueryInterface('CATI3DXVolatileEO').setVolatile();
			                    }
			                }
			            }
			            else {
			                if ((value.QueryInterface) && (value.QueryInterface('CATI3DXVolatileEO'))) {
			                    value.QueryInterface('CATI3DXVolatileEO').setVolatile();
			                }
			            }
			        }
			    }
			}
		},

	    /** 
		* @public
		*/
		restorePersistent: function () {
		    var experienceObject = this.QueryInterface('CATI3DExperienceObject');
		    experienceObject.SetVolatile(false);
		    experienceObject.RestorePersistent();
		    var listVariablesObjects = [];
		    experienceObject.ListVariables(listVariablesObjects, CATI3DExperienceObject.VarType.Object);
		    for (var i = 0; i < listVariablesObjects.length; i++) {
		        var variableInfo = experienceObject.GetVariableInfo(listVariablesObjects[i]);
		        if (variableInfo.valuationMode === CATI3DExperienceObject.ValuationMode.AggregatingValue) {
		            var value = experienceObject.GetValueByName(listVariablesObjects[i]);
		            if (value) {
		                if (Array.isArray(value)) {
		                    for (var indexValue = 0; indexValue < value.length; indexValue++) {
		                        if ((value[indexValue].QueryInterface) && (value[indexValue].QueryInterface('CATI3DXVolatileEO'))) {
		                            value[indexValue].QueryInterface('CATI3DXVolatileEO').restorePersistent();
		                        }
		                    }
		                }
		                else {
		                    if ((value.QueryInterface) && (value.QueryInterface('CATI3DXVolatileEO'))) {
		                        value.QueryInterface('CATI3DXVolatileEO').restorePersistent();
		                    }
		                }
		            }
		        }
		    }
		}
	});

	return CATE3DXVolatileEO;
}
);

