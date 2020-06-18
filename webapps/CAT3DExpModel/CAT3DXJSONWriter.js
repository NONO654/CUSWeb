/**
 * @exports DS/CAT3DExpModel/CAT3DXJSONWriter
*/
define('DS/CAT3DExpModel/CAT3DXJSONWriter',
    [
        'UWA/Core',
		'DS/CAT3DExpModel/interfaces/CATI3DExperienceObject',
        'DS/VCXWebExperienceLoader/VCXExperienceSaverBase'
    ],
	function (UWA, CATI3DExperienceObject, VCXExperienceSaverBase) {
    	'use strict';

    /**
    * @name DS/CAT3DExpModel/CAT3DXJSONWriter
    * @description 
    * Class to serialize components in JSON
    * @constructor
    */

    var JSONWriter = UWA.Class.extend(
    /** @lends DS/CAT3DExpModel/CAT3DXJSONWriter.prototype **/
    {
        init: function () {
            this._expSaverBase = new VCXExperienceSaverBase();
    	},

    	writeJSON: function (iObject, iLinkContext, iForceNewLinkContext) {
    		var self = this;

    		return new UWA.Promise(function (success, fail) {
    			var promises = [];
    			var objectSerialized = self._getObjectExposition(iObject, iLinkContext, promises, iForceNewLinkContext);
    			UWA.Promise.all(promises).then(function () {
    				if (!objectSerialized) {
    					console.error('error serialization');
    					fail();
    					return;
    				}
    				success(JSON.stringify(objectSerialized));
    			})['catch'](function (e) {
    				console.error(e.stack);
    			});
    		});
    	},

    	_getObjectExposition: function (iObject, iLinkContext, iPromises, iForceNewLinkContext) {
    		var exposition = {};
    		if (!iObject) {
    		    return iObject;
    		}
    		if (!iObject.QueryInterface) {
    		    return iObject;
    		}

    		exposition.IDs = {
    		    PathOfIds: iObject.GetID().split(',')
    		};
    		exposition.Prototype = iObject.GetType();

    		var experienceObject = iObject.QueryInterface('CATI3DExperienceObject');
    		if (!experienceObject) {
    		    return exposition;
    		}   		   

    		if (experienceObject.HasVariable('_varName')) {
    		    exposition.Name = experienceObject.GetValueByName('_varName');
    		}
    		else {
    		    exposition.Name = iObject.GetType();
    		}
    		    
    		var variablesNames = [];
    		var variablesExposition = [];
    		experienceObject.ListVariables(variablesNames, CATI3DExperienceObject.VarType.All);
    		for (var i = 0; i < variablesNames.length; i++) {
    		    var variableInfo = experienceObject.GetVariableInfo(variablesNames[i]);
    		    var value = experienceObject.GetValueByName(variablesNames[i]);
    		    var varExposition = {};
    		    varExposition.IDs = {
    		        PathOfIds: variableInfo.id.split(','),
    		    };

    		    varExposition.Name = variableInfo.name;
    		    varExposition.MaxSize = variableInfo.maxNumberOfValues;
    		    varExposition.ValuationMode = variableInfo.valuationMode;
    		    varExposition.VariableType = variableInfo.type;
    		    if (variableInfo.type === CATI3DExperienceObject.VarType.Object && Boolean(value)) {
    		        // pour l'instant on ne gere pas les pointing variables
    		    	if (variableInfo.valuationMode === CATI3DExperienceObject.ValuationMode.AggregatingValue) {
    		    	    if (variableInfo.maxNumberOfValues === 1) {
    		    	        varExposition.Value = [this._getObjectExposition(value, iLinkContext, iPromises, iForceNewLinkContext)];
    		            }
    		            else {
    		                var listObjExposition = [];
    		                for (var j = 0; j < value.length; j++) {
    		                    listObjExposition[j] = this._getObjectExposition(value[j], iLinkContext, iPromises, iForceNewLinkContext);
    		                }
    		                varExposition.Value = listObjExposition;
    		            }
    		        }
    		    	else if (variableInfo.valuationMode === CATI3DExperienceObject.ValuationMode.ReferencingValue) {
    		    	    if (variableInfo.maxNumberOfValues === 1) {
    		                varExposition.Value = [{
    		                    PathOfIds: value.GetID().split(','),
    		                }];
    		            }
    		            else {
    		                var listObjExposition = [];
    		                for (var j = 0; j < value.length; j++) {
    		                    listObjExposition[j] = {
    		                        PathOfIds: value[j].GetID().split(','),
    		                    };
    		                }
    		                varExposition.Value = listObjExposition;
    		            }
    		        }

    		        else {
    		    	    console.warn('not exposed object variable :' + variableInfo.name);
    		        }
    		    }
    		    else if (variableInfo.type === CATI3DExperienceObject.VarType.Color && Boolean(value)) {
    		    	if (variableInfo.maxNumberOfValues === 1) {
					    var propValueJSON = this._expSaverBase._PropertyToJson(value);
					    varExposition.Value = propValueJSON;
					}
				}
    		    else {
    		    	if (varExposition.ValuationMode === CATI3DExperienceObject.ValuationMode.AggregatingValue) {
    		    	    if (variableInfo.maxNumberOfValues === 1) {
    		    	        varExposition.Value = [value];
    		            }
    		            else {
    		    	        varExposition.Value = value;
    		            }
    		        }
    		        else {
    		    	    console.warn('not exposed litteral variable :' + variableInfo.name);
    		        }
    		    }
    		    variablesExposition[i] = varExposition;
    		}
    		exposition.Variables = variablesExposition;

    		var jsonAssetHolderArray = [];
    		var assetHolder = experienceObject.QueryInterface('CATI3DXAssetHolder');
        // skip exposition on CXPExperience
    		if (assetHolder &&
                UWA.is(assetHolder.getLinkContext()) &&
                !experienceObject.GetObject().IsKindOf('CXPExperience_Spec')) {

    		    var jsonAssetHolder = {};
    		    var objectLinkContext = assetHolder.getLinkContext();
    		    var objectLinkContextDescription = objectLinkContext.getJSONDescription();
    		    var objectLinkDescription = assetHolder.getLinkDescription();
    		    if ((!objectLinkContextDescription) || (iForceNewLinkContext)) {
    		    	if (iLinkContext) {
    		    		iPromises.push(
                            new UWA.Promise(function (resolve) {
                                objectLinkContext.resolveLinkAsStream(objectLinkDescription).then(function (iStream) {
                                    return iLinkContext.pushStream(iStream);
                                }).then(function (iLinkDescription) {
                                    jsonAssetHolder.LinkDescription = iLinkDescription;
                                    resolve();
                                })['catch'](function (e) {
                                    console.error(e.stack);
                                });
                            })
                        );
    		    	} else {
    		    		console.warn('unable to write ' + experienceObject.GetValueByName('_varName'));
    		    	}
    		    }
    		    else {
    		    	jsonAssetHolder.LinkContextDescription = objectLinkContextDescription;
    		    	jsonAssetHolder.LinkDescription = objectLinkDescription;
    		    }

    		    var cache = assetHolder.getCache();
    		    if (cache){
    		    	this._serializeCache(cache);
    		    	jsonAssetHolder.Cache = cache;
    		    }

    		    jsonAssetHolderArray.push(jsonAssetHolder);
    		}
    		exposition.AssetHolders = jsonAssetHolderArray;

    		return exposition;
    	},

    	_serializeCache: function (iCache) {
    		for (var key in iCache) {
    			if (iCache.hasOwnProperty(key)) {
    				if (typeof iCache[key] === 'object') {
    					if (iCache[key].GetID) {
    					    iCache[key] = {
    					        PathOfIds: iCache[key].GetID().split(','),
    					    };
    					} else {
    						this._serializeCache(iCache[key]);
    					}
    				}
    			}
    		}
    	}

    });
    return JSONWriter;
});
